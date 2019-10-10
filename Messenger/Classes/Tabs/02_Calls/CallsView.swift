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
class CallsView: UIViewController {

	@IBOutlet var tableView: UITableView!

	private var dbcalls: RLMResults = DBCall.objects(with: NSPredicate(value: false))

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		tabBarItem.image = UIImage(named: "tab_calls")
		tabBarItem.title = "Calls"

		NotificationCenter.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTableView), name: NOTIFICATION_REFRESH_CALLS)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Calls"

		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(actionClearAll))

		tableView.tableFooterView = UIView()

		loadCalls()
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
	func loadCalls() {

		let predicate = NSPredicate(format: "isDeleted == NO")
		dbcalls = DBCall.objects(with: predicate).sortedResults(usingKeyPath: FCALL_CREATEDAT, ascending: false)

		refreshTableView()
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func deleteCalls() {

		for i in 0..<dbcalls.count {
			let dbcall = dbcalls[i] as! DBCall
			Call.deleteItem(objectId: dbcall.objectId)
		}
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView() {

		tableView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionClearAll() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { action in
			self.deleteCalls()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCallAudio(userId: String) {

		let callAudioView = CallAudioView(userId: userId)
		present(callAudioView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCallVideo(userId: String) {

		let callVideoView = CallVideoView(userId: userId)
		present(callVideoView, animated: true)
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		refreshTableView()
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension CallsView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return min(Int(dbcalls.count), 25)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		let dbcall = dbcalls[UInt(indexPath.row)] as! DBCall
		cell.textLabel?.text = dbcall.text

		cell.detailTextLabel?.text = dbcall.status
		cell.detailTextLabel?.textColor = UIColor.gray

		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
		label.text = Convert.timestampToElapsed(dbcall.startedAt)
		label.textAlignment = .right
		label.textColor = UIColor.gray
		label.font = UIFont.systemFont(ofSize: 11)
		cell.accessoryView = label

		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

		return true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

		let dbcall = dbcalls[UInt(indexPath.row)] as! DBCall

		dbcall.updateItem(isDeleted: true)

		tableView.deleteRows(at: [indexPath], with: .fade)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			Call.deleteItem(objectId: dbcall.objectId)
		}
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension CallsView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbcall = dbcalls[UInt(indexPath.row)] as! DBCall
		let userId = (dbcall.recipientId == FUser.currentId()) ? dbcall.initiatorId : dbcall.recipientId

		if (dbcall.type == CALL_AUDIO) { actionCallAudio(userId: userId)	}
		if (dbcall.type == CALL_VIDEO) { actionCallVideo(userId: userId)	}
	}
}
