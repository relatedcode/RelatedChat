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
class CallVideoView: UIViewController {

	@IBOutlet var viewBackground: UIView!
	@IBOutlet var viewDetails: UIView!
	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!
	@IBOutlet var viewButtons1: UIView!
	@IBOutlet var viewButtons2: UIView!
	@IBOutlet var buttonMute: UIButton!
	@IBOutlet var buttonSwitch: UIButton!
	@IBOutlet var viewEnded: UIView!

	private var dbuser: DBUser!

	private var incoming = false
	private var outgoing = false
	private var muted = false
	private var switched = false

	private var call: SINCall?
	private var audioController: SINAudioController?
	private var videoController: SINVideoController?

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

		audioController = app?.sinchService?.client().audioController()
		videoController = app?.sinchService?.client().videoController()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(userId: String) {

		super.init(nibName: nil, bundle: nil)

		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
			self.modalPresentationStyle = .fullScreen
		}

		let app = UIApplication.shared.delegate as? AppDelegate

		call = app?.sinchService?.client().call().callUserVideo(withId: userId)
		call?.delegate = self

		audioController = app?.sinchService?.client().audioController()
		videoController = app?.sinchService?.client().videoController()
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

		videoController?.captureDevicePosition = .front

		if let remoteView = videoController?.remoteView() {
			viewBackground.addSubview(remoteView)
		}
		if let localView = videoController?.localView() {
			viewBackground.addSubview(localView)
		}

		videoController?.localView().contentMode = .scaleAspectFill
		videoController?.remoteView().contentMode = .scaleAspectFill

		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionTap))
		videoController?.remoteView().addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.cancelsTouchesInView = false

		buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
		buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)

		buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
		buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)

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

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTap() {

		viewButtons2.isHidden = !viewButtons2.isHidden
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionMute(_ sender: Any) {

		if (muted) {
			muted = false
			buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .normal)
			buttonMute.setImage(UIImage(named: "callvideo_mute1"), for: .highlighted)
			audioController?.unmute()
		} else {
			muted = true
			buttonMute.setImage(UIImage(named: "callvideo_mute2"), for: .normal)
			buttonMute.setImage(UIImage(named: "callvideo_mute2"), for: .highlighted)
			audioController?.mute()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionHangup(_ sender: Any) {

		call?.hangup()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionAnswer(_ sender: Any) {

		call?.answer()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionSwitch(_ sender: Any) {

		if (switched) {
			switched = false
			buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .normal)
			buttonSwitch.setImage(UIImage(named: "callvideo_switch1"), for: .highlighted)
			videoController?.captureDevicePosition = .front
		} else {
			switched = true
			buttonSwitch.setImage(UIImage(named: "callvideo_switch2"), for: .normal)
			buttonSwitch.setImage(UIImage(named: "callvideo_switch2"), for: .highlighted)
			videoController?.captureDevicePosition = .back
		}
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails1() {

		let screenWidth = UIScreen.main.bounds.size.width
		let screenHeight = UIScreen.main.bounds.size.height

		videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		videoController?.localView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)

		viewDetails.isHidden = false

		if (incoming) { labelStatus.text = "Ringing..." }
		if (outgoing) { labelStatus.text = "Calling..."	}

		viewButtons1.isHidden = outgoing
		viewButtons2.isHidden = incoming

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails2() {

		let screenWidth = UIScreen.main.bounds.size.width
		let screenHeight = UIScreen.main.bounds.size.height

		videoController?.remoteView().frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
		videoController?.localView().frame = CGRect(x: 20, y: 20, width: 70, height: 100)

		viewDetails.isHidden = true

		labelStatus.text = nil

		viewButtons1.isHidden = true
		viewButtons2.isHidden = false

		viewEnded.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails3() {

		viewDetails.isHidden = false

		labelStatus.text = "Ended"

		viewEnded.isHidden = false
	}
}

// MARK: - SINCallDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension CallVideoView: SINCallDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidProgress(_ call_: SINCall?) {

		audioController?.startPlayingSoundFile(Dir.application("call_ringback.wav"), loop: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidEstablish(_ call_: SINCall?) {

		audioController?.stopPlayingSoundFile()
		audioController?.enableSpeaker()

		updateDetails2()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func callDidEnd(_ call_: SINCall?) {

		audioController?.stopPlayingSoundFile()
		audioController?.disableSpeaker()

		updateDetails3()

		if (outgoing) { saveCall() }

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.dismiss(animated: true)
		}
	}
}
