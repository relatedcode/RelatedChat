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
class ChatsView: UIViewController {

	@IBOutlet var viewTitle: UIView!
	@IBOutlet var segmentedControl: UISegmentedControl!
	
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!

	private var dbchats: RLMResults = DBChat.objects(with: NSPredicate(value: false))

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		tabBarItem.image = UIImage(named: "tab_chats")
		tabBarItem.title = "Chats"

		NotificationCenter.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTableView), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTabCounter), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTableView), name: NOTIFICATION_REFRESH_CHATS)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTabCounter), name: NOTIFICATION_REFRESH_CHATS)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		navigationItem.titleView = viewTitle

		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chats_dialogflow"), style: .plain, target: self, action: #selector(actionDialogflow))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(actionCompose))

		tableView.register(UINib(nibName: "ChatsCell", bundle: nil), forCellReuseIdentifier: "ChatsCell")

		tableView.tableFooterView = UIView()

		loadChats()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (FUser.currentId() != "") {
			if (FUser.isOnboardOk()) {
				refreshTableView()
			} else { Userx.onboard(target: self) }
		} else { Userx.login(target: self) }
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadChats() {

		var predicate = NSPredicate(format: "isArchived == NO AND isDeleted == NO")

		if let text = searchBar.text {
			if (text.count != 0) {
				predicate = NSPredicate(format: "isArchived == NO AND isDeleted == NO AND details CONTAINS[c] %@", text)
			}
		}

		dbchats = DBChat.objects(with: predicate).sortedResults(usingKeyPath: FCHAT_LASTMESSAGEDATE, ascending: false)

		refreshTableView()
		refreshTabCounter()
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView() {

		tableView.reloadData()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTabCounter() {

		var total: Int = 0

		for i in 0..<dbchats.count {
			let dbchat = dbchats[i] as! DBChat
			if (dbchat.counter != 0) { total += 1 }
		}

		let item = tabBarController?.tabBar.items?[0]
		item?.badgeValue = (total != 0) ? "\(total)" : nil

		UIApplication.shared.applicationIconBadgeNumber = total
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDialogflow() {

		let dialogflowView = DialogflowView()
		let navController = NavigationController(rootViewController: dialogflowView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCompose() {

		let selectUserView = SelectUserView()
		selectUserView.delegate = self
		let navController = NavigationController(rootViewController: selectUserView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionNewChat() {

		if (tabBarController?.tabBar.isHidden ?? true) { return }

		tabBarController?.selectedIndex = 0

		actionCompose()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionRecentUser(userId: String) {

		if (tabBarController?.tabBar.isHidden ?? true) { return }

		tabBarController?.selectedIndex = 0

		actionChatPrivate(recipientId: userId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatPrivate(recipientId: String) {

		if (segmentedControl.selectedSegmentIndex == 0) {
			let chatPrivateView = ChatPrivateView(recipientId: recipientId)
			chatPrivateView.hidesBottomBarWhenPushed = true
			navigationController?.pushViewController(chatPrivateView, animated: true)
		}

		if (segmentedControl.selectedSegmentIndex == 1) {
			let chatPrivateView = MKChatPrivateView(recipientId: recipientId)
			chatPrivateView.hidesBottomBarWhenPushed = true
			navigationController?.pushViewController(chatPrivateView, animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatGroup(groupId: String) {

		let chatGroupView = ChatGroupView(groupId: groupId)
		chatGroupView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(chatGroupView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMore(index: Int) {

		let dbchat = dbchats[UInt(index)] as! DBChat
		if (dbchat.mutedUntil < Date().timestamp()) {
			actionMoreMute(index: index)
		} else {
			actionMoreUnmute(index: index)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMoreMute(index: Int) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Mute", style: .default, handler: { action in
			self.actionMute(index: index)
		}))
		alert.addAction(UIAlertAction(title: "Archive", style: .default, handler: { action in
			self.actionArchive(index: index)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMoreUnmute(index: Int) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Unmute", style: .default, handler: { action in
			self.actionUnmute(index: index)
		}))
		alert.addAction(UIAlertAction(title: "Archive", style: .default, handler: { action in
			self.actionArchive(index: index)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMute(index: Int) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "10 hours", style: .default, handler: { action in
			self.actionMute(index: index, until: 10)
		}))
		alert.addAction(UIAlertAction(title: "7 days", style: .default, handler: { action in
			self.actionMute(index: index, until: 168)
		}))
		alert.addAction(UIAlertAction(title: "1 month", style: .default, handler: { action in
			self.actionMute(index: index, until: 720)
		}))
		alert.addAction(UIAlertAction(title: "1 year", style: .default, handler: { action in
			self.actionMute(index: index, until: 8760)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMute(index: Int, until hours: Int) {

		let dbchat = dbchats[UInt(index)] as! DBChat

		let dateUntil = Date().addingTimeInterval(TimeInterval((hours * 60 * 60)))
		let mutedUntil = dateUntil.timestamp()

		Chat.updateMutedUntils(chatId: dbchat.chatId, mutedUntil: mutedUntil)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnmute(index: Int) {

		let dbchat = dbchats[UInt(index)] as! DBChat

		Chat.updateMutedUntils(chatId: dbchat.chatId, mutedUntil: 0)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionArchive(index: Int) {

		let dbchat = dbchats[UInt(index)] as! DBChat

		dbchat.updateItem(isArchived: true)

		let indexPath = IndexPath(row: index, section: 0)
		tableView.deleteRows(at: [indexPath], with: .fade)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.refreshTableView()
			self.refreshTabCounter()
			Chat.updateArchiveds(chatId: dbchat.chatId, value: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionDelete(index: Int) {

		let dbchat = dbchats[UInt(index)] as! DBChat

		dbchat.updateItem(isDeleted: true)

		let indexPath = IndexPath(row: index, section: 0)
		tableView.deleteRows(at: [indexPath], with: .fade)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.refreshTableView()
			self.refreshTabCounter()
			Chat.updateDeleteds(chatId: dbchat.chatId, value: true)
		}
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		refreshTableView()
		refreshTabCounter()
	}
}

// MARK: - SelectUserDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatsView: SelectUserDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectUser(dbuser: DBUser) {

		actionChatPrivate(recipientId: dbuser.objectId)
	}
}

// MARK: - MGSwipeTableCellDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatsView: MGSwipeTableCellDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {

		if (index == 0) { actionDelete(index: cell.tag) }
		if (index == 1) { actionMore(index: cell.tag)	}

		return true
	}
}

// MARK: - UIScrollViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatsView: UIScrollViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatsView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return Int(dbchats.count)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsCell

		cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.red),
							 MGSwipeButton(title: "More", backgroundColor: UIColor.lightGray)]

		cell.delegate = self
		cell.tag = indexPath.row

		let dbchat = dbchats[UInt(indexPath.row)] as! DBChat
		cell.bindData(dbchat: dbchat)
		cell.loadImage(dbchat: dbchat, tableView: tableView, indexPath: indexPath)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatsView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbchat = dbchats[UInt(indexPath.row)] as! DBChat

		if (dbchat.recipientId.count != 0) {
			actionChatPrivate(recipientId: dbchat.recipientId)
		}
		if (dbchat.groupId.count != 0) {
			actionChatGroup(groupId: dbchat.groupId)
		}
	}
}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatsView: UISearchBarDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadChats()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

		searchBar.setShowsCancelButton(true, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

		searchBar.text = ""
		searchBar.resignFirstResponder()
		loadChats()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
