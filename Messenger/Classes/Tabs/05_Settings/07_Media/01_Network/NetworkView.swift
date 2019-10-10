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
class NetworkView: UIViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var cellManual: UITableViewCell!
	@IBOutlet var cellWiFi: UITableViewCell!
	@IBOutlet var cellAll: UITableViewCell!

	private var mediaType: Int32 = 0
	private var selectedNetwork: Int32 = 0

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(mediaType mediaType_: Int32) {

		super.init(nibName: nil, bundle: nil)

		mediaType = mediaType_
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		if (mediaType == MEDIA_PHOTO) { title = "Photo" }
		if (mediaType == MEDIA_VIDEO) { title = "Video" }
		if (mediaType == MEDIA_AUDIO) { title = "Audio" }

		loadUser()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		saveUser()
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadUser() {

		if (mediaType == MEDIA_PHOTO) { selectedNetwork = FUser.networkPhoto() }
		if (mediaType == MEDIA_VIDEO) { selectedNetwork = FUser.networkVideo() }
		if (mediaType == MEDIA_AUDIO) { selectedNetwork = FUser.networkAudio() }

		updateDetails()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveUser() {

		let user = FUser.currentUser()

		if (mediaType == MEDIA_PHOTO) { user[FUSER_NETWORKPHOTO] = selectedNetwork }
		if (mediaType == MEDIA_VIDEO) { user[FUSER_NETWORKVIDEO] = selectedNetwork }
		if (mediaType == MEDIA_AUDIO) { user[FUSER_NETWORKAUDIO] = selectedNetwork }

		user.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails() {

		cellManual.accessoryType = (selectedNetwork == NETWORK_MANUAL) ? .checkmark : .none
		cellWiFi.accessoryType	 = (selectedNetwork == NETWORK_WIFI) ? .checkmark : .none
		cellAll.accessoryType	 = (selectedNetwork == NETWORK_ALL) ? .checkmark : .none

		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension NetworkView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 3
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellManual	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellWiFi	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellAll	}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension NetworkView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 0) { selectedNetwork = NETWORK_MANUAL	}
		if (indexPath.section == 0) && (indexPath.row == 1) { selectedNetwork = NETWORK_WIFI	}
		if (indexPath.section == 0) && (indexPath.row == 2) { selectedNetwork = NETWORK_ALL		}

		updateDetails()
	}
}
