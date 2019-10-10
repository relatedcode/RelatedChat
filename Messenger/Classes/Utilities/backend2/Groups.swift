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
class Groups: NSObject {

	private var refreshUIGroups = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Groups = {
		let instance = Groups()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_APP_STARTED)
		NotificationCenter.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)

		Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
			self.refreshUserInterface()
		}
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func initObservers() {

		if (FUser.currentId() != "") {
			if (firebase == nil) {
				createObservers()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createObservers() {

		firebase = Database.database().reference(withPath: FGROUP_PATH)
		let child = "\(FGROUP_LINKEDS)/\(FUser.currentId())"
		let query = firebase?.queryOrdered(byChild: child).queryEqual(toValue: true)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			if let group = snapshot.value as? [String: Any] {
				if (group[FGROUP_CREATEDAT] as? Int64 != nil) {
					DispatchQueue(label: "Groups").async {
						self.updateRealm(group: group)
						self.refreshUIGroups = true
					}
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			if let group = snapshot.value as? [String: Any] {
				if (group[FGROUP_CREATEDAT] as? Int64 != nil) {
					DispatchQueue(label: "Groups").async {
						self.updateRealm(group: group)
						self.refreshUIGroups = true
					}
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(group: [String: Any]) {

		var temp = group

		let members = group[FGROUP_MEMBERS] as! [String]
		let linkeds = group[FGROUP_LINKEDS] as? [String: Bool]

		temp[FGROUP_MEMBERS] = Convert.arrayToString(members)
		temp[FGROUP_LINKEDS] = Convert.dictToString(linkeds)

		if (members.contains(FUser.currentId()) == false) {
			temp[FGROUP_ISDELETED] = true
		}

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBGroup.createOrUpdate(in: realm, withValue: temp)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		firebase?.removeAllObservers()
		firebase = nil
	}

	// MARK: - Notification methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUserInterface() {

		if (refreshUIGroups) {
			NotificationCenter.post(notification: NOTIFICATION_REFRESH_GROUPS)
			refreshUIGroups = false
		}
	}
}
