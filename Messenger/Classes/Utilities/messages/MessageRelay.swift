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
class MessageRelay: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func send(dbmessage: DBMessage, completion: @escaping (_ error: Error?) -> Void) {

		let message = FObject(path: FMESSAGE_PATH)

		message[FMESSAGE_OBJECTID] = dbmessage.objectId

		message[FMESSAGE_CHATID] = dbmessage.chatId
		message[FMESSAGE_MEMBERS] = Convert.stringToArray(dbmessage.members)

		message[FMESSAGE_SENDERID] = dbmessage.senderId
		message[FMESSAGE_SENDERFULLNAME] = dbmessage.senderFullname
		message[FMESSAGE_SENDERINITIALS] = dbmessage.senderInitials
		message[FMESSAGE_SENDERPICTUREAT] = dbmessage.senderPictureAt

		message[FMESSAGE_RECIPIENTID] = dbmessage.recipientId
		message[FMESSAGE_RECIPIENTFULLNAME] = dbmessage.recipientFullname
		message[FMESSAGE_RECIPIENTINITIALS] = dbmessage.recipientInitials
		message[FMESSAGE_RECIPIENTPICTUREAT] = dbmessage.recipientPictureAt

		message[FMESSAGE_GROUPID] = dbmessage.groupId
		message[FMESSAGE_GROUPNAME] = dbmessage.groupName

		message[FMESSAGE_TYPE] = dbmessage.type
		message[FMESSAGE_TEXT] = Cryptor.encrypt(text: dbmessage.text, chatId: dbmessage.chatId)

		message[FMESSAGE_PHOTOWIDTH] = dbmessage.photoWidth
		message[FMESSAGE_PHOTOHEIGHT] = dbmessage.photoHeight
		message[FMESSAGE_VIDEODURATION] = dbmessage.videoDuration
		message[FMESSAGE_AUDIODURATION] = dbmessage.audioDuration

		message[FMESSAGE_LATITUDE] = dbmessage.latitude
		message[FMESSAGE_LONGITUDE] = dbmessage.longitude

		message[FMESSAGE_STATUS] = STATUS_SENT
		message[FMESSAGE_ISDELETED] = dbmessage.isDeleted

		message[FMESSAGE_CREATEDAT] = ServerValue.timestamp()
		message[FMESSAGE_UPDATEDAT] = ServerValue.timestamp()

		if (dbmessage.type == MESSAGE_TEXT)		{ sendMessage(message: message, completion: completion) 		}
		if (dbmessage.type == MESSAGE_EMOJI)	{ sendMessage(message: message, completion: completion)			}
		if (dbmessage.type == MESSAGE_PHOTO)	{ sendMessagePhoto(message: message, completion: completion) 	}
		if (dbmessage.type == MESSAGE_VIDEO)	{ sendMessageVideo(message: message, completion: completion)	}
		if (dbmessage.type == MESSAGE_AUDIO)	{ sendMessageAudio(message: message, completion: completion)	}
		if (dbmessage.type == MESSAGE_LOCATION)	{ sendMessage(message: message, completion: completion)			}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessagePhoto(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		let chatId = message[FMESSAGE_CHATID] as! String

		if let path = DownloadManager.pathPhoto(message.objectId()) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				if let crypted = Cryptor.encrypt(data: data, chatId: chatId) {
					UploadManager.photo(message.objectId(), data: crypted, completion: { error in
						if (error == nil) {
							sendMessage(message: message, completion: completion)
						} else { completion(NSError.description("Media upload error.", code: 100)) }
					})
				} else { completion(NSError.description("Media encryption error.", code: 101)) }
			} else { completion(NSError.description("Media file error.", code: 102)) }
		} else { completion(NSError.description("Missing media file.", code: 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessageVideo(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		let chatId = message[FMESSAGE_CHATID] as! String

		if let path = DownloadManager.pathVideo(message.objectId()) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				if let crypted = Cryptor.encrypt(data: data, chatId: chatId) {
					UploadManager.video(message.objectId(), data: crypted, completion: { error in
						if (error == nil) {
							sendMessage(message: message, completion: completion)
						} else { completion(NSError.description("Media upload error.", code: 100)) }
					})
				} else { completion(NSError.description("Media encryption error.", code: 101)) }
			} else { completion(NSError.description("Media file error.", code: 102)) }
		} else { completion(NSError.description("Missing media file.", code: 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessageAudio(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		let chatId = message[FMESSAGE_CHATID] as! String

		if let path = DownloadManager.pathAudio(message.objectId()) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				if let crypted = Cryptor.encrypt(data: data, chatId: chatId) {
					UploadManager.audio(message.objectId(), data: crypted, completion: { error in
						if (error == nil) {
							sendMessage(message: message, completion: completion)
						} else { completion(NSError.description("Media upload error.", code: 100)) }
					})
				} else { completion(NSError.description("Media encryption error.", code: 101)) }
			} else { completion(NSError.description("Media file error.", code: 102)) }
		} else { completion(NSError.description("Missing media file.", code: 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessage(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		var multiple: [String: Any] = [:]

		for userId in message[FMESSAGE_MEMBERS] as! [String] {
			let path = "\(userId)/\(message.objectId())"
			multiple[path] = message.values
		}

		let firebase = Database.database().reference(withPath: FMESSAGE_PATH)
		firebase.updateChildValues(multiple, withCompletionBlock: { error, ref in
			if (error == nil) {
				Chat.updateItem(message: message)
				PushNotification.send(message: message)
				completion(nil)
			} else {
				completion(NSError.description("Message sending failed.", code: 104))
			}
		})
	}
}
