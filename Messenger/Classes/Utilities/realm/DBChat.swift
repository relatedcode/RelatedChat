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
class DBChat: RLMObject {

	@objc dynamic var objectId = ""
	@objc dynamic var chatId = ""

	@objc dynamic var members = ""
	@objc dynamic var linkeds = ""

	@objc dynamic var senderId = ""
	@objc dynamic var senderFullname = ""
	@objc dynamic var senderInitials = ""
	@objc dynamic var senderPictureAt: Int64 = 0

	@objc dynamic var recipientId = ""
	@objc dynamic var recipientFullname = ""
	@objc dynamic var recipientInitials = ""
	@objc dynamic var recipientPictureAt: Int64 = 0

	@objc dynamic var groupId = ""
	@objc dynamic var groupName = ""

	@objc dynamic var lastMessageText = ""
	@objc dynamic var lastMessageDate: Int64 = 0

	@objc dynamic var typings = ""
	@objc dynamic var lastReads = ""
	@objc dynamic var mutedUntils = ""

	@objc dynamic var lastRead: Int64 = 0
	@objc dynamic var mutedUntil: Int64 = 0

	@objc dynamic var details = ""
	@objc dynamic var counter: Int = 0

	@objc dynamic var isArchived = false
	@objc dynamic var isDeleted = false

	@objc dynamic var createdAt: Int64 = 0
	@objc dynamic var updatedAt: Int64 = 0

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override static func primaryKey() -> String? {

		return FCHAT_OBJECTID
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateItem(isArchived isArchived_: Bool) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			isArchived = isArchived_
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateItem(isDeleted isDeleted_: Bool) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			isDeleted = isDeleted_
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateCounter() {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			counter = counter + 1
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func initCounter(chatId: String) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()

			let dbchat = DBChat()
			dbchat.objectId = chatId
			dbchat.chatId = chatId
			dbchat.counter = 1
			dbchat.isDeleted = true
			realm.addOrUpdate(dbchat)

			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}
}
