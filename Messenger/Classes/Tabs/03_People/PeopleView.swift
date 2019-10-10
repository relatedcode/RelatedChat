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
class PeopleView: UIViewController {

	@IBOutlet var viewTitle: UIView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!

	private var blockerIds: [String] = []
	private var friendIds: [String] = []
	private var dbusers: RLMResults = DBUser.objects(with: NSPredicate(value: false))

	private var sections: [[DBUser]] = []
	private let collation = UILocalizedIndexedCollation.current()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		tabBarItem.image = UIImage(named: "tab_people")
		tabBarItem.title = "People"

		NotificationCenter.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)
		NotificationCenter.addObserver(target: self, selector: #selector(loadBlockers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(loadBlockers), name: NOTIFICATION_REFRESH_BLOCKERS)
		NotificationCenter.addObserver(target: self, selector: #selector(loadFriends), name: NOTIFICATION_REFRESH_FRIENDS)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTableView), name: NOTIFICATION_REFRESH_USERS)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		navigationItem.titleView = viewTitle

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAddFriends))

		tableView.register(UINib(nibName: "PeopleCell", bundle: nil), forCellReuseIdentifier: "PeopleCell")

		tableView.tableFooterView = UIView()

		loadBlockers()
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
	@objc func loadBlockers() {

		blockerIds.removeAll()

		let predicate = NSPredicate(format: "isDeleted == NO")
		let dbblockers = DBBlocker.objects(with: predicate)

		for i in 0..<dbblockers.count {
			let dbblocker = dbblockers[i] as! DBBlocker
			blockerIds.append(dbblocker.blockerId)
		}

		loadFriends()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadFriends() {

		friendIds.removeAll()

		let predicate = NSPredicate(format: "isDeleted == NO")
		let dbfriends = DBFriend.objects(with: predicate)

		for i in 0..<dbfriends.count {
			let dbfriend = dbfriends[i] as! DBFriend
			friendIds.append(dbfriend.friendId)
		}

		loadUsers()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadUsers() {

		var predicate = NSPredicate(format: "NOT objectId IN %@ AND objectId IN %@", blockerIds, friendIds)

		if let text = searchBar.text {
			if (text.count != 0) {
				predicate = NSPredicate(format: "NOT objectId IN %@ AND objectId IN %@ AND fullname CONTAINS[c] %@", blockerIds, friendIds, text)
			}
		}

		dbusers = DBUser.objects(with: predicate).sortedResults(usingKeyPath: FUSER_FULLNAME, ascending: true)

		refreshTableView()
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView() {

		setObjects()
		tableView.reloadData()

		labelTitle.text = "(\(dbusers.count) friends)"

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.setSpotlightSearch()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func setObjects() {

		sections.removeAll()

		let selector = #selector(getter: DBUser.fullname)
		sections = Array(repeating: [], count: collation.sectionTitles.count)

		var unsorted: [DBUser] = []
		for i in 0..<dbusers.count {
			unsorted.append(dbusers[i] as! DBUser)
		}

		if let sorted = collation.sortedArray(from: unsorted, collationStringSelector: selector) as? [DBUser] {
			for dbuser in sorted {
				let section = collation.section(for: dbuser, collationStringSelector: selector)
				sections[section].append(dbuser)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func setSpotlightSearch() {

		var items: [CSSearchableItem] = []

		let bundleId = Bundle.main.bundleIdentifier

		for i in 0..<dbusers.count {
			let dbuser = dbusers[i] as! DBUser

			let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
			attributeSet.title = dbuser.fullname
			attributeSet.displayName = dbuser.fullname
			attributeSet.contentDescription = dbuser.country
			attributeSet.keywords = [dbuser.firstname, dbuser.lastname, dbuser.country]

			DownloadManager.startUser(dbuser.objectId, pictureAt: dbuser.pictureAt) { image, error in
				if (error == nil) {
					attributeSet.thumbnailData = image?.pngData()
				}
			}

			items.append(CSSearchableItem(uniqueIdentifier: dbuser.objectId, domainIdentifier: bundleId, attributeSet: attributeSet))
		}

		CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [bundleId!], completionHandler: { error in
			if (error == nil) {
				CSSearchableIndex.default().indexSearchableItems(items, completionHandler: { error in
					if (error != nil) { ProgressHUD.showError("Spotlight search indexing error.") }
				})
			} else { ProgressHUD.showError("Spotlight search delete error.") }
		})
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionAddFriends() {

		let addFriendsView = AddFriendsView()
		let navController = NavigationController(rootViewController: addFriendsView)
		present(navController, animated: true)
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		refreshTableView()
	}
}

// MARK: - UIScrollViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UIScrollViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return sections.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return sections[section].count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		return (sections[section].count != 0) ? collation.sectionTitles[section] : nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {

		return collation.sectionIndexTitles
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

		return collation.section(forSectionIndexTitle: index)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleCell

		let dbuser = sections[indexPath.section][indexPath.row]
		cell.bindData(dbuser: dbuser)
		cell.loadImage(dbuser: dbuser, tableView: tableView, indexPath: indexPath)

		return cell
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbuser = sections[indexPath.section][indexPath.row]

		let profileView = ProfileView(userId: dbuser.objectId, chat: true)
		profileView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(profileView, animated: true)
	}
}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension PeopleView: UISearchBarDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadUsers()
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
		loadUsers()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
