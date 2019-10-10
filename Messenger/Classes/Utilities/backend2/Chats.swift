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
class Chats: NSObject {

	var chatIdActive = ""

	private var refreshUIChats = false
	private var refreshUIMessages2 = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Chats = {
		let instance = Chats()
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

		firebase = Database.database().reference(withPath: FCHAT_PATH)
		let child = "\(FCHAT_LINKEDS)/\(FUser.currentId())"
		let query = firebase?.queryOrdered(byChild: child).queryEqual(toValue: true)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			if let chat = snapshot.value as? [String: Any] {
				if (chat[FCHAT_CREATEDAT] as? Int64 != nil) {
					DispatchQueue(label: "Chats").async {
						self.updateRealm(chat: chat)
						self.refreshUIChats = true
						self.refreshUIMessages2(chat: chat)
					}
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			if let chat = snapshot.value as? [String: Any] {
				if (chat[FCHAT_CREATEDAT] as? Int64 != nil) {
					DispatchQueue(label: "Chats").async {
						self.updateRealm(chat: chat)
						self.refreshUIChats = true
						self.refreshUIMessages2(chat: chat)
					}
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(chat: [String: Any]) {

		var temp = chat

		//-----------------------------------------------------------------------------------------------------------------------------------------
		let members = chat[FCHAT_MEMBERS] as! [String]
		let linkeds = chat[FCHAT_LINKEDS] as? [String: Bool]

		temp[FCHAT_MEMBERS] = Convert.arrayToString(members)
		temp[FCHAT_LINKEDS] = Convert.dictToString(linkeds)

		//-----------------------------------------------------------------------------------------------------------------------------------------
		let currentId = FUser.currentId()
		let senderId = chat[FCHAT_SENDERID] as! String
		let groupId = chat[FCHAT_GROUPID] as! String

		if (groupId.count == 0) {
			if (senderId != currentId) {
				temp[FCHAT_SENDERID]		= chat[FCHAT_RECIPIENTID]
				temp[FCHAT_SENDERFULLNAME]	= chat[FCHAT_RECIPIENTFULLNAME]
				temp[FCHAT_SENDERINITIALS]	= chat[FCHAT_RECIPIENTINITIALS]
				temp[FCHAT_SENDERPICTUREAT]	= chat[FCHAT_RECIPIENTPICTUREAT]

				temp[FCHAT_RECIPIENTID]			= chat[FCHAT_SENDERID]
				temp[FCHAT_RECIPIENTFULLNAME]	= chat[FCHAT_SENDERFULLNAME]
				temp[FCHAT_RECIPIENTINITIALS]	= chat[FCHAT_SENDERINITIALS]
				temp[FCHAT_RECIPIENTPICTUREAT]	= chat[FCHAT_SENDERPICTUREAT]
			}
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		let chatId = chat[FCHAT_CHATID] as! String
		let text = chat[FCHAT_LASTMESSAGETEXT] as! String

		temp[FCHAT_LASTMESSAGETEXT] = Cryptor.decrypt(text: text, chatId: chatId)

		//-----------------------------------------------------------------------------------------------------------------------------------------
		let typings = chat[FCHAT_TYPINGS] as? [String: Int64]
		let lastReads = chat[FCHAT_LASTREADS] as? [String: Int64]
		let mutedUntils = chat[FCHAT_MUTEDUNTILS] as? [String: Int64]

		temp[FCHAT_TYPINGS] = Convert.dictToJson(typings)
		temp[FCHAT_LASTREADS] = Convert.dictToJson(lastReads)
		temp[FCHAT_MUTEDUNTILS] = Convert.dictToJson(mutedUntils)

		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let lastRead = lastReads?[FUser.currentId()]		{ temp["lastRead"] = lastRead		}
		if let mutedUntil = mutedUntils?[FUser.currentId()]	{ temp["mutedUntil"] = mutedUntil	}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (groupId.count == 0) { temp["details"] = temp[FCHAT_RECIPIENTFULLNAME]	}
		if (groupId.count != 0) { temp["details"] = chat[FCHAT_GROUPNAME]			}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let lastRead = lastReads?[FUser.currentId()] {
			if let lastMessageDate = chat[FCHAT_LASTMESSAGEDATE] as? Int64 {
				if (lastRead >= lastMessageDate) {
					temp["counter"] = 0
				}
			}
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let archiveds = chat[FCHAT_ARCHIVEDS] as? [String: Bool]	{ temp["isArchived"] = archiveds[currentId]	}
		if let deleteds = chat[FCHAT_DELETEDS] as? [String: Bool]	{ temp["isDeleted"] = deleteds[currentId]	}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (members.contains(FUser.currentId()) == false) {
			temp["isDeleted"] = true
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBChat.createOrUpdate(in: realm, withValue: temp)
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
	func refreshUIMessages2(chat: [String: Any]) {

		let chatId = chat[FCHAT_CHATID] as! String

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

		if (refreshUIMessages2) {
			NotificationCenter.post(notification: NOTIFICATION_REFRESH_MESSAGES2)
			refreshUIMessages2 = false
		}
	}
}
