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
class MessageQueue: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func send(chatId: String, recipientId: String, text: String?, photo: UIImage?, video: URL?, audio: String?) {

		let predicate = NSPredicate(format: "objectId == %@", recipientId)
		let dbuser = DBUser.objects(with: predicate).firstObject() as! DBUser

		let message = FObject(path: FMESSAGE_PATH)

		message.objectIdInit()

		message[FMESSAGE_CHATID] = chatId
		message[FMESSAGE_MEMBERS] = [FUser.currentId(), recipientId]

		message[FMESSAGE_SENDERID] = FUser.currentId()
		message[FMESSAGE_SENDERFULLNAME] = FUser.fullname()
		message[FMESSAGE_SENDERINITIALS] = FUser.initials()
		message[FMESSAGE_SENDERPICTUREAT] = FUser.pictureAt()

		message[FMESSAGE_RECIPIENTID] = recipientId
		message[FMESSAGE_RECIPIENTFULLNAME] = dbuser.fullname
		message[FMESSAGE_RECIPIENTINITIALS] = dbuser.initials()
		message[FMESSAGE_RECIPIENTPICTUREAT] = dbuser.pictureAt

		message[FMESSAGE_GROUPID] = ""
		message[FMESSAGE_GROUPNAME] = ""

		message[FMESSAGE_TYPE] = ""
		message[FMESSAGE_TEXT] = ""

		message[FMESSAGE_PHOTOWIDTH] = 0
		message[FMESSAGE_PHOTOHEIGHT] = 0
		message[FMESSAGE_VIDEODURATION] = 0
		message[FMESSAGE_AUDIODURATION] = 0

		message[FMESSAGE_LATITUDE] = 0
		message[FMESSAGE_LONGITUDE] = 0

		message[FMESSAGE_STATUS] = STATUS_QUEUED
		message[FMESSAGE_ISDELETED] = false

		let timestamp = Date().timestamp()
		message[FMESSAGE_CREATEDAT] = timestamp
		message[FMESSAGE_UPDATEDAT] = timestamp

		if (text != nil)		{ sendMessageText(message: message, text: text!)		}
		else if (photo != nil)	{ sendMessagePhoto(message: message, photo: photo!)		}
		else if (video != nil)	{ sendMessageVideo(message: message, video: video!)		}
		else if (audio != nil)	{ sendMessageAudio(message: message, audio: audio!)		}
		else					{ sendMessageLoaction(message: message)					}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func send(chatId: String, groupId: String, text: String?, photo: UIImage?, video: URL?, audio: String?) {

		let predicate = NSPredicate(format: "objectId == %@", groupId)
		let dbgroup = DBGroup.objects(with: predicate).firstObject() as! DBGroup

		let message = FObject(path: FMESSAGE_PATH)

		message.objectIdInit()

		message[FMESSAGE_CHATID] = chatId
		message[FMESSAGE_MEMBERS] = Convert.stringToArray(dbgroup.members)

		message[FMESSAGE_SENDERID] = FUser.currentId()
		message[FMESSAGE_SENDERFULLNAME] = FUser.fullname()
		message[FMESSAGE_SENDERINITIALS] = FUser.initials()
		message[FMESSAGE_SENDERPICTUREAT] = FUser.pictureAt()

		message[FMESSAGE_RECIPIENTID] = ""
		message[FMESSAGE_RECIPIENTFULLNAME] = ""
		message[FMESSAGE_RECIPIENTINITIALS] = ""
		message[FMESSAGE_RECIPIENTPICTUREAT] = 0

		message[FMESSAGE_GROUPID] = groupId
		message[FMESSAGE_GROUPNAME] = dbgroup.name

		message[FMESSAGE_TYPE] = ""
		message[FMESSAGE_TEXT] = ""

		message[FMESSAGE_PHOTOWIDTH] = 0
		message[FMESSAGE_PHOTOHEIGHT] = 0
		message[FMESSAGE_VIDEODURATION] = 0
		message[FMESSAGE_AUDIODURATION] = 0

		message[FMESSAGE_LATITUDE] = 0
		message[FMESSAGE_LONGITUDE] = 0

		message[FMESSAGE_STATUS] = STATUS_QUEUED
		message[FMESSAGE_ISDELETED] = false

		let timestamp = Date().timestamp()
		message[FMESSAGE_CREATEDAT] = timestamp
		message[FMESSAGE_UPDATEDAT] = timestamp

		if (text != nil)		{ sendMessageText(message: message, text: text!)		}
		else if (photo != nil)	{ sendMessagePhoto(message: message, photo: photo!)		}
		else if (video != nil)	{ sendMessageVideo(message: message, video: video!)		}
		else if (audio != nil)	{ sendMessageAudio(message: message, audio: audio!)		}
		else					{ sendMessageLoaction(message: message)					}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func forward(recipientId: String, dbmessage: DBMessage) {

		let predicate = NSPredicate(format: "objectId == %@", recipientId)
		let dbuser = DBUser.objects(with: predicate).firstObject() as! DBUser

		let message = FObject(path: FMESSAGE_PATH)

		message.objectIdInit()

		message[FMESSAGE_CHATID] = Chat.chatId(recipientId: recipientId)
		message[FMESSAGE_MEMBERS] = [FUser.currentId(), recipientId]

		message[FMESSAGE_SENDERID] = FUser.currentId()
		message[FMESSAGE_SENDERFULLNAME] = FUser.fullname()
		message[FMESSAGE_SENDERINITIALS] = FUser.initials()
		message[FMESSAGE_SENDERPICTUREAT] = FUser.pictureAt()

		message[FMESSAGE_RECIPIENTID] = recipientId
		message[FMESSAGE_RECIPIENTFULLNAME] = dbuser.fullname
		message[FMESSAGE_RECIPIENTINITIALS] = dbuser.initials()
		message[FMESSAGE_RECIPIENTPICTUREAT] = dbuser.pictureAt

		message[FMESSAGE_GROUPID] = ""
		message[FMESSAGE_GROUPNAME] = ""

		message[FMESSAGE_TYPE] = dbmessage.type
		message[FMESSAGE_TEXT] = dbmessage.text

		message[FMESSAGE_PHOTOWIDTH] = dbmessage.photoWidth
		message[FMESSAGE_PHOTOHEIGHT] = dbmessage.photoHeight
		message[FMESSAGE_VIDEODURATION] = dbmessage.videoDuration
		message[FMESSAGE_AUDIODURATION] = dbmessage.audioDuration

		message[FMESSAGE_LATITUDE] = dbmessage.latitude
		message[FMESSAGE_LONGITUDE] = dbmessage.longitude

		message[FMESSAGE_STATUS] = STATUS_QUEUED
		message[FMESSAGE_ISDELETED] = false

		let timestamp = Date().timestamp()
		message[FMESSAGE_CREATEDAT] = timestamp
		message[FMESSAGE_UPDATEDAT] = timestamp

		if (dbmessage.type == MESSAGE_TEXT)			{ createMessage(message: message)								}
		if (dbmessage.type == MESSAGE_PHOTO)		{ forwardMessagePhoto(dbmessage: dbmessage, message: message)	}
		if (dbmessage.type == MESSAGE_VIDEO)		{ forwardMessageVideo(dbmessage: dbmessage, message: message)	}
		if (dbmessage.type == MESSAGE_AUDIO)		{ forwardMessageAudio(dbmessage: dbmessage, message: message)	}
		if (dbmessage.type == MESSAGE_LOCATION)		{ createMessage(message: message)								}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func forward(groupId: String, dbmessage: DBMessage) {

		let predicate = NSPredicate(format: "objectId == %@", groupId)
		let dbgroup = DBGroup.objects(with: predicate).firstObject() as! DBGroup

		let message = FObject(path: FMESSAGE_PATH)

		message.objectIdInit()

		message[FMESSAGE_CHATID] = Chat.chatId(groupId: groupId)
		message[FMESSAGE_MEMBERS] = Convert.stringToArray(dbgroup.members)

		message[FMESSAGE_SENDERID] = FUser.currentId()
		message[FMESSAGE_SENDERFULLNAME] = FUser.fullname()
		message[FMESSAGE_SENDERINITIALS] = FUser.initials()
		message[FMESSAGE_SENDERPICTUREAT] = FUser.pictureAt()

		message[FMESSAGE_RECIPIENTID] = ""
		message[FMESSAGE_RECIPIENTFULLNAME] = ""
		message[FMESSAGE_RECIPIENTINITIALS] = ""
		message[FMESSAGE_RECIPIENTPICTUREAT] = 0

		message[FMESSAGE_GROUPID] = groupId
		message[FMESSAGE_GROUPNAME] = dbgroup.name

		message[FMESSAGE_TYPE] = dbmessage.type
		message[FMESSAGE_TEXT] = dbmessage.text

		message[FMESSAGE_PHOTOWIDTH] = dbmessage.photoWidth
		message[FMESSAGE_PHOTOHEIGHT] = dbmessage.photoHeight
		message[FMESSAGE_VIDEODURATION] = dbmessage.videoDuration
		message[FMESSAGE_AUDIODURATION] = dbmessage.audioDuration

		message[FMESSAGE_LATITUDE] = dbmessage.latitude
		message[FMESSAGE_LONGITUDE] = dbmessage.longitude

		message[FMESSAGE_STATUS] = STATUS_QUEUED
		message[FMESSAGE_ISDELETED] = false

		let timestamp = Date().timestamp()
		message[FMESSAGE_CREATEDAT] = timestamp
		message[FMESSAGE_UPDATEDAT] = timestamp

		if (dbmessage.type == MESSAGE_TEXT)			{ createMessage(message: message)								}
		if (dbmessage.type == MESSAGE_PHOTO)		{ forwardMessagePhoto(dbmessage: dbmessage, message: message)	}
		if (dbmessage.type == MESSAGE_VIDEO)		{ forwardMessageVideo(dbmessage: dbmessage, message: message)	}
		if (dbmessage.type == MESSAGE_AUDIO)		{ forwardMessageAudio(dbmessage: dbmessage, message: message)	}
		if (dbmessage.type == MESSAGE_LOCATION)		{ createMessage(message: message)								}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func forwardMessagePhoto(dbmessage: DBMessage, message: FObject) {

		if let path = DownloadManager.pathPhoto(dbmessage.objectId) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				DownloadManager.savePhoto(message.objectId(), data: data)
				createMessage(message: message)
			}
		} else {
			ProgressHUD.showError("Missing media photo.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func forwardMessageVideo(dbmessage: DBMessage, message: FObject) {

		if let path = DownloadManager.pathVideo(dbmessage.objectId) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				DownloadManager.saveVideo(message.objectId(), data: data)
				createMessage(message: message)
			}
		} else {
			ProgressHUD.showError("Missing media video.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func forwardMessageAudio(dbmessage: DBMessage, message: FObject) {

		if let path = DownloadManager.pathAudio(dbmessage.objectId) {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				DownloadManager.saveAudio(message.objectId(), data: data)
				createMessage(message: message)
			}
		} else {
			ProgressHUD.showError("Missing media audio.")
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessageText(message: FObject, text: String) {

		message[FMESSAGE_TYPE] = Emoji.isEmoji(text: text) ? MESSAGE_EMOJI : MESSAGE_TEXT
		message[FMESSAGE_TEXT] = text

		createMessage(message: message)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessagePhoto(message: FObject, photo: UIImage) {

		message[FMESSAGE_TYPE] = MESSAGE_PHOTO
		message[FMESSAGE_TEXT] = "[Photo message]"

		if let data = photo.jpegData(compressionQuality: 0.6) {
			DownloadManager.savePhoto(message.objectId(), data: data)
			message[FMESSAGE_PHOTOWIDTH] = Int(photo.size.width)
			message[FMESSAGE_PHOTOHEIGHT] = Int(photo.size.height)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Photo data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessageVideo(message: FObject, video: URL) {

		message[FMESSAGE_TYPE] = MESSAGE_VIDEO
		message[FMESSAGE_TEXT] = "[Video message]"

		if let data = try? Data(contentsOf: video) {
			DownloadManager.saveVideo(message.objectId(), data: data)
			message[FMESSAGE_VIDEODURATION] = Video.duration(path: video.path)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Video data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessageAudio(message: FObject, audio: String) {

		message[FMESSAGE_TYPE] = MESSAGE_AUDIO
		message[FMESSAGE_TEXT] = "[Audio message]"

		if let data = try? Data(contentsOf: URL(fileURLWithPath: audio)) {
			DownloadManager.saveAudio(message.objectId(), data: data)
			message[FMESSAGE_AUDIODURATION] = Audio.duration(path: audio)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Audio data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessageLoaction(message: FObject) {

		message[FMESSAGE_TYPE] = MESSAGE_LOCATION
		message[FMESSAGE_TEXT] = "[Location message]"

		message[FMESSAGE_LATITUDE] = LocationManager.latitude()
		message[FMESSAGE_LONGITUDE] = LocationManager.longitude()

		createMessage(message: message)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createMessage(message: FObject) {

		updateRealm(message: message.values)

		NotificationCenter.post(notification: NOTIFICATION_REFRESH_MESSAGES1)

		Audio.playMessageOutgoing()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateRealm(message: [String: Any]) {

		var temp = message

		let members = message[FMESSAGE_MEMBERS] as? [String]
		temp[FMESSAGE_MEMBERS] = Convert.arrayToString(members)

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBMessage.createOrUpdate(in: realm, withValue: temp)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}
}
