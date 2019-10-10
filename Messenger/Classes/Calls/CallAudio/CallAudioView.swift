//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//-------------------------------------------------------------------------------------------------------------------------------------------------
class CallAudioView: UIViewController {

	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!
	@IBOutlet var viewButtons: UIView!
	@IBOutlet var buttonMute: UIButton!
	@IBOutlet var buttonSpeaker: UIButton!
	@IBOutlet var buttonVideo: UIButton!
	@IBOutlet var viewButtons1: UIView!
	@IBOutlet var viewButtons2: UIView!
	@IBOutlet var viewEnded: UIView!

	private var dbuser: DBUser!
	private var timer: Timer?

	private var incoming = false
	private var outgoing = false
	private var muted = false
	private var speaker = false

	private var call: SINCall?
	private var audioController: SINAudioController?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(call call_: SINCall?) {

		super.init(nibName: nil, bundle: nil)

		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
			self.modalPresentationStyle = .fullScreen
		}

		let app = UIApplication.shared.delegate as? AppDelegate

		call = call_
		call?.delegate = self

		audioController = app?.sinchService?.audioController()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(userId: String) {

		super.init(nibName: nil, bundle: nil)

		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
			self.modalPresentationStyle = .fullScreen
		}

		let app = UIApplication.shared.delegate as? AppDelegate

		call = app?.sinchService?.callClient().callUser(withId: userId)
		call?.delegate = self

		audioController = app?.sinchService?.audioController()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		audioController?.unmute()
		audioController?.disableSpeaker()

		buttonMute.setImage(UIImage(named: "callaudio_mute1"), for: .normal)
		buttonMute.setImage(UIImage(named: "callaudio_mute1"), for: .highlighted)

		buttonSpeaker.setImage(UIImage(named: "callaudio_speaker1"), for: .normal)
		buttonSpeaker.setImage(UIImage(named: "callaudio_speaker1"), for: .highlighted)

		buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .normal)
		buttonVideo.setImage(UIImage(named: "callaudio_video1"), for: .highlighted)

		incoming = (call?.direction == .incoming)
		outgoing = (call?.direction == .outgoing)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if (incoming) { audioController?.startPlayingSoundFile(Dir.application("call_incoming.wav"), loop: true) }

		updateDetails1()

		loadUser()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

		return .portrait
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {

		return .portrait
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var shouldAutorotate: Bool {

		return false
	}

	// MARK: - Backend actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadUser() {

		if let remoteUserId = call?.remoteUserId {
			let predicate = NSPredicate(format: "objectId == %@", remoteUserId)
			dbuser = DBUser.objects(with: predicate).firstObject() as? DBUser

			labelInitials.text = dbuser.initials()
			DownloadManager.startUser(dbuser.objectId, pictureAt: dbuser.pictureAt) { image, error in
				if (error == nil) {
					self.imageUser.image = image
					self.labelInitials.text = nil
				}
			}

			labelName.text = dbuser.fullname
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveCall() {

		if let details = call?.details {
			Call.createItem(userId: FUser.currentId(), recipientId: dbuser.objectId, name: dbuser.fullname, details: details)
			Call.createItem(userId: dbuser.objectId, recipientId: dbuser.objectId, name: FUser.fullname(), details: details)
		}
	}

	// MARK: - Timer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func timerStart() {

		timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
			self.updateStatus()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func timerStop() {

		timer?.invalidate()
		timer = nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateStatus() {

		if let date = call?.details.establishedTime {
			let interval = Date().timeIntervalSince(date)
			let seconds = Int(interval) % 60
			let minutes = Int(interval) / 60
			labelStatus.text = String(format: "%02d:%02d", minutes, seconds)
		}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionMute(_ sender: Any) {

		if (muted) {
			muted = false
			buttonMute.setImage(UIImage(named: "callaudio_mute1"), for: .normal)
			buttonMute.setImage(UIImage(named: "callaudio_mute1"), for: .highlighted)
			audioController?.unmute()
		} else {
			muted = true
			buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .normal)
			buttonMute.setImage(UIImage(named: "callaudio_mute2"), for: .highlighted)
			audioController?.mute()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionSpeaker(_ sender: Any) {

		if (speaker) {
			speaker = false
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker1"), for: .normal)
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker1"), for: .highlighted)
			audioController?.disableSpeaker()
		} else {
			speaker = true
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .normal)
			buttonSpeaker.setImage(UIImage(named: "callaudio_speaker2"), for: .highlighted)
			audioController?.enableSpeaker()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionVideo(_ sender: Any) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHangup(_ sender: Any) {

		call?.hangup()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionAnswer(_ sender: Any) {

		call?.answer()
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails1() {

		if (incoming) { labelStatus.text = "Ringing..." }
		if (outgoing) { labelStatus.text = "Calling..."	}

		viewButtons.isHidden = incoming
		viewButtons1.isHidden = outgoing
		viewButtons2.isHidden = incoming

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails2() {

		labelStatus.text = "00:00"

		viewButtons.isHidden = false
		viewButtons1.isHidden = true
		viewButtons2.isHidden = false

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails3() {

		labelStatus.text = "Ended"

		viewEnded.isHidden = false
	}
}

// MARK: - SINCallDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension CallAudioView: SINCallDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidProgress(_ call_: SINCall?) {

		audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidEstablish(_ call_: SINCall?) {

		timerStart()
		audioController?.stopPlayingSoundFile()
		updateDetails2()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidEnd(_ call_: SINCall?) {

		timerStop()
		audioController?.stopPlayingSoundFile()
		updateDetails3()

		if (outgoing) { saveCall() }

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.dismiss(animated: true)
		}
	}
}
