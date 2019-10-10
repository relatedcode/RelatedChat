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
class Chat: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateItem(message: FObject) {

		let groupId	= message[FMESSAGE_GROUPID] as! String
		let members	= message[FMESSAGE_MEMBERS] as! [String]
		var linkeds	= Convert.arrayToDict(members)

		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (groupId.count != 0) {
			let predicate = NSPredicate(format: "objectId == %@", groupId)
			let dbgroup = DBGroup.objects(with: predicate).firstObject() as! DBGroup
			linkeds = Convert.stringToDict(dbgroup.linkeds)
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		let object = FObject(path: FCHAT_PATH)

		object[FCHAT_OBJECTID] = message[FMESSAGE_CHATID]
		object[FCHAT_CHATID] = message[FMESSAGE_CHATID]

		object[FCHAT_MEMBERS] = members
		object[FCHAT_LINKEDS] = linkeds

		object[FCHAT_SENDERID] = message[FMESSAGE_SENDERID]
		object[FCHAT_SENDERFULLNAME] = message[FMESSAGE_SENDERFULLNAME]
		object[FCHAT_SENDERINITIALS] = message[FMESSAGE_SENDERINITIALS]
		object[FCHAT_SENDERPICTUREAT] = message[FMESSAGE_SENDERPICTUREAT]

		object[FCHAT_RECIPIENTID] = message[FMESSAGE_RECIPIENTID]
		object[FCHAT_RECIPIENTFULLNAME] = message[FMESSAGE_RECIPIENTFULLNAME]
		object[FCHAT_RECIPIENTINITIALS] = message[FMESSAGE_RECIPIENTINITIALS]
		object[FCHAT_RECIPIENTPICTUREAT] = message[FMESSAGE_RECIPIENTPICTUREAT]

		object[FCHAT_GROUPID] = message[FMESSAGE_GROUPID]
		object[FCHAT_GROUPNAME] = message[FMESSAGE_GROUPNAME]

		object[FCHAT_LASTMESSAGETEXT] = message[FMESSAGE_TEXT]
		object[FCHAT_LASTMESSAGEDATE] = message[FMESSAGE_CREATEDAT]

		object[FCHAT_ARCHIVEDS] = Convert.arrayToDict(members, false)
		object[FCHAT_DELETEDS] = Convert.arrayToDict(members, false)

		object.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateTypings(chatId: String, value: Bool) {

		if (initialized(chatId: chatId)) {
			let reference = Database.database().reference(withPath: FCHAT_PATH).child(chatId).child(FCHAT_TYPINGS)
			reference.updateChildValues([FUser.currentId(): value])
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateLastReads(chatId: String) {

		if (initialized(chatId: chatId)) {
			let reference = Database.database().reference(withPath: FCHAT_PATH).child(chatId).child(FCHAT_LASTREADS)
			reference.updateChildValues([FUser.currentId(): ServerValue.timestamp()])
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateMutedUntils(chatId: String, mutedUntil: Int64) {

		let reference = Database.database().reference(withPath: FCHAT_PATH).child(chatId).child(FCHAT_MUTEDUNTILS)
		reference.updateChildValues([FUser.currentId(): mutedUntil])
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateArchiveds(chatId: String, value: Bool) {

		let reference = Database.database().reference(withPath: FCHAT_PATH).child(chatId).child(FCHAT_ARCHIVEDS)
		reference.updateChildValues([FUser.currentId(): value])
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateDeleteds(chatId: String, value: Bool) {

		let reference = Database.database().reference(withPath: FCHAT_PATH).child(chatId).child(FCHAT_DELETEDS)
		reference.updateChildValues([FUser.currentId(): value])
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateMembers(chatId: String, members: [String]) {

		if (initialized(chatId: chatId)) {
			let object = FObject(path: FCHAT_PATH)

			object[FCHAT_OBJECTID] = chatId
			object[FCHAT_MEMBERS] = members

			object.updateInBackground(block: { error in
				if (error != nil) {
					ProgressHUD.showError("Network error.")
				}
			})
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateDeleteds(chatId: String, members: [String]) {

		if (initialized(chatId: chatId)) {
			let object = FObject(path: FCHAT_PATH)

			object[FCHAT_OBJECTID] = chatId
			object[FCHAT_DELETEDS] = Convert.arrayToDict(members, true)

			object.updateInBackground(block: { error in
				if (error != nil) {
					ProgressHUD.showError("Network error.")
				}
			})
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func initialized(chatId: String) -> Bool {

		let predicate = NSPredicate(format: "chatId == %@", chatId)
		let dbchats = DBChat.objects(with: predicate)

		return (dbchats.count != 0)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func chatId(recipientId: String) -> String {

		let members = [FUser.currentId(), recipientId]

		let sorted = members.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
		let joined = sorted.joined(separator: "")

		return joined.md5()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func chatId(groupId: String) -> String {

		return groupId.md5()
	}
}
