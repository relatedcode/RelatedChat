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
class ProfileView: UIViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var viewHeader: UIView!
	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelDetails: UILabel!
	@IBOutlet var cellStatus: UITableViewCell!
	@IBOutlet var cellCountry: UITableViewCell!
	@IBOutlet var cellLocation: UITableViewCell!
	@IBOutlet var cellPhone: UITableViewCell!
	@IBOutlet var buttonCallPhone: UIButton!
	@IBOutlet var cellMedia: UITableViewCell!
	@IBOutlet var cellChat: UITableViewCell!
	@IBOutlet var cellFriend: UITableViewCell!
	@IBOutlet var cellBlock: UITableViewCell!

	private var userId = ""
	private var isBlocker = false
	private var isChatEnabled = false

	private var dbuser: DBUser!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(userId userId_: String, chat chat_: Bool) {

		super.init(nibName: nil, bundle: nil)

		userId = userId_
		isChatEnabled = chat_

		isBlocker = Blocker.isBlocker(userId: userId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Profile"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.tableHeaderView = viewHeader

		loadUser()
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadUser() {

		let predicate = NSPredicate(format: "objectId == %@", userId)
		dbuser = DBUser.objects(with: predicate).firstObject() as? DBUser

		labelInitials.text = dbuser.initials()
		DownloadManager.startUser(dbuser.objectId, pictureAt: dbuser.pictureAt) { image, error in
			if (error == nil) {
				self.imageUser.image = image
				self.labelInitials.text = nil
			}
		}

		labelName.text = dbuser.fullname
		labelDetails.text = Userx.lastActive(dbuser: dbuser)

		cellStatus.detailTextLabel?.text = dbuser.status
		cellCountry.detailTextLabel?.text = dbuser.country
		cellLocation.detailTextLabel?.text = dbuser.location

		buttonCallPhone.setTitle(dbuser.phone, for: .normal)

		cellFriend.textLabel?.text = Friend.isFriend(userId: userId) ? "Remove Friend" : "Add Friend"
		cellBlock.textLabel?.text = Blocked.isBlocked(userId: userId) ? "Unblock User" : "Block User"

		tableView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPhoto(_ sender: Any) {

		if let picture = imageUser.image {
			let photoItems = PictureView.photos(picture: picture)
			let pictureView = PictureView(photos: photoItems)
			present(pictureView, animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionCallPhone(_ sender: Any) {

		let number1 = "tel://\(dbuser.phone)"
		let number2 = number1.replacingOccurrences(of: " ", with: "")

		if let url = URL(string: number2) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionCallAudio(_ sender: Any) {

		let callAudioView = CallAudioView(userId: dbuser.objectId)
		present(callAudioView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionCallVideo(_ sender: Any) {

		let callVideoView = CallVideoView(userId: dbuser.objectId)
		present(callVideoView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMedia() {

		let recipientId = dbuser.objectId
		let chatId = Chat.chatId(recipientId: recipientId)

		let allMediaView = AllMediaView(chatId: chatId)
		navigationController?.pushViewController(allMediaView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatPrivate() {

		let chatPrivateView = ChatPrivateView(recipientId: dbuser.objectId)
		navigationController?.pushViewController(chatPrivateView, animated: true)
	}

	// MARK: - User actions (Friend/Unfriend)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionFriendOrUnfriend() {

		Friend.isFriend(userId: userId) ? actionUnfriend() : actionFriend()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionFriend() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Add Friend", style: .default, handler: { action in
			self.actionFriendUser()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionFriendUser() {

		Friend.createItem(userId: userId)
		cellFriend.textLabel?.text = "Remove Friend"
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnfriend() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Remove Friend", style: .default, handler: { action in
			self.actionUnfriendUser()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnfriendUser() {

		Friend.deleteItem(userId: userId)
		cellFriend.textLabel?.text = "Add Friend"
	}

	// MARK: - User actions (Block/Unblock)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionBlockOrUnblock() {

		Blocked.isBlocked(userId: userId) ? actionUnblock() : actionBlock()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionBlock() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Block User", style: .destructive, handler: { action in
			self.actionBlockUser()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionBlockUser() {

		Blocked.createItem(userId: userId)
		Blocker.createItem(userId: userId)
		cellBlock.textLabel?.text = "Unblock User"
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnblock() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Unblock User", style: .destructive, handler: { action in
			self.actionUnblockUser()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnblockUser() {

		Blocked.deleteItem(userId: userId)
		Blocker.deleteItem(userId: userId)
		cellBlock.textLabel?.text = "Block User"
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 3
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return isBlocker ? 3 : 4		}
		if (section == 1) { return isChatEnabled ? 2 : 1	}
		if (section == 2) { return 2						}

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellStatus			}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellCountry		}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellLocation		}
		if (indexPath.section == 0) && (indexPath.row == 3) { return cellPhone			}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellMedia			}
		if (indexPath.section == 1) && (indexPath.row == 1) { return cellChat			}
		if (indexPath.section == 2) && (indexPath.row == 0) { return cellFriend			}
		if (indexPath.section == 2) && (indexPath.row == 1) { return cellBlock			}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ProfileView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 1) && (indexPath.row == 0) { actionMedia()				}
		if (indexPath.section == 1) && (indexPath.row == 1) { actionChatPrivate()		}
		if (indexPath.section == 2) && (indexPath.row == 0) { actionFriendOrUnfriend()	}
		if (indexPath.section == 2) && (indexPath.row == 1) { actionBlockOrUnblock()	}
	}
}
