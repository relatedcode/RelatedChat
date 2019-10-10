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
class Messages: NSObject {

	var chatIdActive = ""

	private var refreshUIChats = false
	private var refreshUIMessages1 = false
	private var refreshUIMessages2 = false
	private var playMessageIncoming = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Messages = {
		let instance = Messages()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func assignChatId(chatId: String) {

		shared.chatIdActive = chatId
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func resignChatId() {

		shared.chatIdActive = ""
	}

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

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func initObservers() {

		if (FUser.currentId() != "") {
			if (firebase == nil) {
				createObservers()
			}
		}
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createObservers() {

		let lastUpdatedAt = DBMessage.lastUpdatedAt()

		firebase = Database.database().reference(withPath: FMESSAGE_PATH).child(FUser.currentId())
		let query = firebase?.queryOrdered(byChild: FMESSAGE_UPDATEDAT).queryStarting(atValue: lastUpdatedAt + 1)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			if let message = snapshot.value as? [String: Any] {
				if (message[FMESSAGE_CREATEDAT] as? Int64 != nil) {
					DispatchQueue(label: "Messages").async {
						self.updateRealm(message: message)
						self.updateCounter(message: message)
						self.refreshUIMessages1(message: message)
					}
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			if let message = snapshot.value as? [String: Any] {
				if (message[FMESSAGE_CREATEDAT] as? Int64 != nil) {
					DispatchQueue(label: "Messages").async {
						self.updateRealm(message: message)
						self.refreshUIMessages2(message: message)
					}
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(message: [String: Any]) {

		var temp = message

		let members = message[FMESSAGE_MEMBERS] as? [String]
		temp[FMESSAGE_MEMBERS] = Convert.arrayToString(members)

		let chatId = message[FMESSAGE_CHATID] as! String
		let text = message[FMESSAGE_TEXT] as! String
		temp[FMESSAGE_TEXT] = Cryptor.decrypt(text: text, chatId: chatId)

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBMessage.createOrUpdate(in: realm, withValue: temp)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateCounter(message: [String: Any]) {

		let chatId = message[FMESSAGE_CHATID] as! String
		let senderId = message[FMESSAGE_SENDERID] as! String
		let createdAt = message[FMESSAGE_CREATEDAT] as! Int64

		if (senderId != FUser.currentId()) {
			let predicate = NSPredicate(format: "chatId == %@", chatId)
			let dbchats = DBChat.objects(with: predicate)

			if let dbchat = dbchats.firstObject() as? DBChat {
				if (createdAt > dbchat.lastRead) {
					dbchat.updateCounter()
					refreshUIChats = true
				}
			} else {
				DBChat.initCounter(chatId: chatId)
			}
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
	func refreshUIMessages1(message: [String: Any]) {

		let chatId = message[FMESSAGE_CHATID] as! String
		let senderId = message[FMESSAGE_SENDERID] as! String

		if (chatId == chatIdActive) {
			refreshUIMessages1 = true
			if (senderId != FUser.currentId()) {
				playMessageIncoming = true
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUIMessages2(message: [String: Any]) {

		let chatId = message[FMESSAGE_CHATID] as! String

		if (chatId == chatIdActive) {
			refreshUIMessages2 = true
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUserInterface() {

		if (refreshUIChats) {
			NotificationCenter.post(notification: NOTIFICATION_REFRESH_CHATS)
			refreshUIChats = false
		}

		if (refreshUIMessages1) {
			NotificationCenter.post(notification: NOTIFICATION_REFRESH_MESSAGES1)
			refreshUIMessages1 = false
		}

		if (refreshUIMessages2) {
			NotificationCenter.post(notification: NOTIFICATION_REFRESH_MESSAGES2)
			refreshUIMessages2 = false
		}

		if (playMessageIncoming) {
			Audio.playMessageIncoming()
			playMessageIncoming = false
		}
	}
}
