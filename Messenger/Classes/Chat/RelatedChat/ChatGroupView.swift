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
class ChatGroupView: RCMessagesView, UIGestureRecognizerDelegate {

	private var groupId = ""
	private var chatId = ""

	private var dbchats: RLMResults = DBChat.objects(with: NSPredicate(value: false))
	private var dbmessages: RLMResults = DBMessage.objects(with: NSPredicate(value: false))

	private var rcmessages: [String: RCMessage] = [:]
	private var avatarImages: [String: UIImage] = [:]

	private var messageToDisplay: Int = 0

	private var typingCounter: Int = 0
	private var lastRead: Int64 = 0

	private var indexForward: IndexPath?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(groupId groupId_: String) {

		super.init(nibName: "RCMessagesView", bundle: nil)

		groupId = groupId_
		chatId = Chat.chatId(groupId: groupId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationController?.interactivePopGestureRecognizer?.delegate = self

		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chat_back"), style: .plain, target: self, action: #selector(actionBack))

		let wallpaper = FUser.wallpaper()
		if (wallpaper.count != 0) {
			tableView.backgroundView = UIImageView(image: UIImage(named: wallpaper))
		}

		NotificationCenter.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_CLEANUP_CHATVIEW)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTableView1), name: NOTIFICATION_REFRESH_MESSAGES1)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshTableView2), name: NOTIFICATION_REFRESH_MESSAGES2)

		messageToDisplay = Int(INSERT_MESSAGES)

		loadChats()
		loadMessages()
		refreshTableView2()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		Chats.assignChatId(chatId: chatId)
		Messages.assignChatId(chatId: chatId)

		Chat.updateLastReads(chatId: chatId)

		updateTitleDetails()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidDisappear(_ animated: Bool) {

		super.viewDidDisappear(animated)

		if (isMovingFromParent) {
			actionCleanup()
		}
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadChats() {

		let predicate = NSPredicate(format: "chatId == %@", chatId)
		dbchats = DBChat.objects(with: predicate)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadMessages() {

		let predicate = NSPredicate(format: "chatId == %@ AND isDeleted == NO", chatId)
		dbmessages = DBMessage.objects(with: predicate).sortedResults(usingKeyPath: FMESSAGE_CREATEDAT, ascending: true)
	}

	// MARK: - Message methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageTotalCount() -> Int {

		return Int(dbmessages.count)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageLoadedCount() -> Int {

		return min(messageToDisplay, messageTotalCount())
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func dbmessageAt(_ indexPath: IndexPath) -> DBMessage {

		let offset = messageTotalCount() - messageLoadedCount()
		let index = UInt(indexPath.section + offset)

		return dbmessages[index] as! DBMessage
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {

		let dbmessage = dbmessageAt(indexPath)
		let messageId = dbmessage.objectId

		if let rcmessage = rcmessages[messageId] {
			return rcmessage
		}

		let rcmessage = RCMessage(dbmessage: dbmessage)

		if (rcmessage.type == MESSAGE_PHOTO) { LoaderPhoto.start(rcmessage, in: tableView) }
		if (rcmessage.type == MESSAGE_VIDEO) { LoaderVideo.start(rcmessage, in: tableView) }
		if (rcmessage.type == MESSAGE_AUDIO) { LoaderAudio.start(rcmessage, in: tableView) }

		if (rcmessage.type == MESSAGE_LOCATION) {

			rcmessage.mediaStatus = MEDIASTATUS_LOADING

			var region: MKCoordinateRegion = MKCoordinateRegion()
			region.center.latitude = rcmessage.latitude
			region.center.longitude = rcmessage.longitude
			region.span.latitudeDelta = CLLocationDegrees(0.005)
			region.span.longitudeDelta = CLLocationDegrees(0.005)

			let options = MKMapSnapshotter.Options()
			options.region = region
			options.size = CGSize(width: RCDefaults.locationBubbleWidth, height: RCDefaults.locationBubbleHeight)
			options.scale = UIScreen.main.scale

			let snapshotter = MKMapSnapshotter(options: options)
			snapshotter.start(with: DispatchQueue.global(qos: .default), completionHandler: { snapshot, error in
				if (snapshot != nil) {
					DispatchQueue.main.async {
						UIGraphicsBeginImageContextWithOptions(snapshot!.image.size, true, snapshot!.image.scale)
						do {
							snapshot!.image.draw(at: CGPoint.zero)
							let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
							var point = snapshot!.point(for: CLLocationCoordinate2DMake(rcmessage.latitude, rcmessage.longitude))
							point.x += pin.centerOffset.x - (pin.bounds.size.width / 2)
							point.y += pin.centerOffset.y - (pin.bounds.size.height / 2)
							pin.image!.draw(at: point)
							rcmessage.locationThumbnail = UIGraphicsGetImageFromCurrentImageContext()
						}
						UIGraphicsEndImageContext()
						rcmessage.mediaStatus = MEDIASTATUS_SUCCEED
						self.tableView.reloadData()
					}
				}
			})
		}

		rcmessages[messageId] = rcmessage

		return rcmessage
	}

	// MARK: - Avatar methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarInitials(_ indexPath: IndexPath) -> String {

		let rcmessage = rcmessageAt(indexPath)
		return rcmessage.senderInitials
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarImage(_ indexPath: IndexPath) -> UIImage? {

		let rcmessage = rcmessageAt(indexPath)
		var imageAvatar = avatarImages[rcmessage.senderId]

		if (imageAvatar == nil) {
			if let path = DownloadManager.pathUser(rcmessage.senderId) {
				imageAvatar = UIImage(contentsOfFile: path)
				avatarImages[rcmessage.senderId] = imageAvatar
			}
		}

		if (imageAvatar == nil) {
			DownloadManager.startUser(rcmessage.senderId, pictureAt: rcmessage.senderPictureAt) { image, error in
				if (error == nil) {
					self.tableView.reloadData()
				}
			}
		}

		return imageAvatar
	}

	// MARK: - Header, Footer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textHeaderUpper(_ indexPath: IndexPath) -> String? {

		if (indexPath.section % 3 == 0) {
			let rcmessage = rcmessageAt(indexPath)
			return Convert.timestampToDayMonthTime(rcmessage.createdAt)
		} else {
			return nil
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textHeaderLower(_ indexPath: IndexPath) -> String? {

		let rcmessage = rcmessageAt(indexPath)
		if (rcmessage.incoming) {
			return rcmessage.senderFullname
		}
		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textFooterUpper(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textFooterLower(_ indexPath: IndexPath) -> String? {

		let rcmessage = rcmessageAt(indexPath)
		if (rcmessage.outgoing) {
			let dbmessage = dbmessageAt(indexPath)
			if (dbmessage.status != STATUS_QUEUED) {
				return (dbmessage.createdAt > lastRead) ? STATUS_SENT : STATUS_READ
			}
			return STATUS_QUEUED
		}
		return nil
	}

	// MARK: - Menu controller methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func menuItems(_ indexPath: IndexPath) -> [Any]? {

		let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(actionMenuCopy(_:)))
		let menuItemSave = RCMenuItem(title: "Save", action: #selector(actionMenuSave(_:)))
		let menuItemDelete = RCMenuItem(title: "Delete", action: #selector(actionMenuDelete(_:)))
		let menuItemForward = RCMenuItem(title: "Forward", action: #selector(actionMenuForward(_:)))

		menuItemCopy.indexPath = indexPath
		menuItemSave.indexPath = indexPath
		menuItemDelete.indexPath = indexPath
		menuItemForward.indexPath = indexPath

		let rcmessage = rcmessageAt(indexPath)

		var array: [RCMenuItem] = []

		if (rcmessage.type == MESSAGE_TEXT)		{ array.append(menuItemCopy) }
		if (rcmessage.type == MESSAGE_EMOJI)	{ array.append(menuItemCopy) }

		if (rcmessage.type == MESSAGE_PHOTO)	{ array.append(menuItemSave) }
		if (rcmessage.type == MESSAGE_VIDEO)	{ array.append(menuItemSave) }
		if (rcmessage.type == MESSAGE_AUDIO)	{ array.append(menuItemSave) }

		array.append(menuItemDelete)
		array.append(menuItemForward)

		return array
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		if (action == #selector(actionMenuCopy(_:)))	{ return true }
		if (action == #selector(actionMenuSave(_:)))	{ return true }
		if (action == #selector(actionMenuDelete(_:)))	{ return true }
		if (action == #selector(actionMenuForward(_:)))	{ return true }

		return false
	}

	// MARK: - Typing indicator methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func typingIndicatorUpdate() {

		typingCounter += 1
		Chat.updateTypings(chatId: chatId, value: true)

		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			self.typingIndicatorStop()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorStop() {

		typingCounter -= 1
		if (typingCounter == 0) {
			Chat.updateTypings(chatId: chatId, value: false)
		}
	}

	// MARK: - Title details methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateTitleDetails() {

		let predicate = NSPredicate(format: "objectId == %@", groupId)
		if let dbgroup = DBGroup.objects(with: predicate).firstObject() as? DBGroup {
			let members = Convert.stringToArray(dbgroup.members)

			labelTitle1.text = dbgroup.name
			labelTitle2.text = "\(members.count) members"
		}
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView1() {

		refreshTableView2()
		scrollToBottom(animated: true)
		Chat.updateLastReads(chatId: chatId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView2() {

		loadEarlierShow(messageToDisplay < dbmessages.count)
		refreshTyping()
		refreshLastRead()
		tableView.reloadData()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTyping() {

		var typeCount: Int64 = 0
		if let dbchat = dbchats.firstObject() as? DBChat {
			let typings = Convert.jsonToDict(dbchat.typings)
			for userId in Array(typings.keys) {
				if (userId != FUser.currentId()) {
					if let typing = typings[userId] {
						typeCount = typeCount + typing
					}
				}
			}
		}
		self.typingIndicatorShow((typeCount != 0), animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshLastRead() {

		if let dbchat = dbchats.firstObject() as? DBChat {
			let lastReads = Convert.jsonToDict(dbchat.lastReads)
			for userId in Array(lastReads.keys) {
				if (userId != FUser.currentId()) {
					if let lastRead = lastReads[userId] {
						if (lastRead > self.lastRead) {
							self.lastRead = lastRead
						}
					}
				}
			}
		}
	}

	// MARK: - Message send methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageSend(text: String?, photo: UIImage?, video: URL?, audio: String?) {

		MessageQueue.send(chatId: chatId, groupId: groupId, text: text, photo: photo, video: video, audio: audio)
	}

	// MARK: - Message delete methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageDelete(_ indexPath: IndexPath) {

		let dbmessage = dbmessageAt(indexPath)
		Message.deleteItem(dbmessage: dbmessage)
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionBack() {

		navigationController?.popViewController(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTitle() {

		let groupView = GroupView(groupId: groupId)
		navigationController?.pushViewController(groupView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionAttachMessage() {

		dismissKeyboard()

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let alertCamera = UIAlertAction(title: "Camera", style: .default, handler: { action in
			ImagePicker.cameraMulti(target: self, edit: true)
		})
		let alertPhoto = UIAlertAction(title: "Photo", style: .default, handler: { action in
			ImagePicker.photoLibrary(target: self, edit: true)
		})
		let alertVideo = UIAlertAction(title: "Video", style: .default, handler: { action in
			ImagePicker.videoLibrary(target: self, edit: true)
		})
		let alertAudio = UIAlertAction(title: "Audio", style: .default, handler: { action in
			self.actionAudio()
		})
		let alertStickers = UIAlertAction(title: "Sticker", style: .default, handler: { action in
			self.actionStickers()
		})
		let alertLocation = UIAlertAction(title: "Location", style: .default, handler: { action in
			self.actionLocation()
		})

		alertCamera.setValue(UIImage(named: "chat_camera"), forKey: "image"); 		alert.addAction(alertCamera)
		alertPhoto.setValue(UIImage(named: "chat_picture"), forKey: "image");		alert.addAction(alertPhoto)
		alertVideo.setValue(UIImage(named: "chat_video"), forKey: "image");			alert.addAction(alertVideo)
		alertAudio.setValue(UIImage(named: "chat_audio"), forKey: "image");			alert.addAction(alertAudio)
		alertStickers.setValue(UIImage(named: "chat_sticker"), forKey: "image");	alert.addAction(alertStickers)
		alertLocation.setValue(UIImage(named: "chat_location"), forKey: "image");	alert.addAction(alertLocation)

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionSendMessage(_ text: String) {

		messageSend(text: text, photo: nil, video: nil, audio: nil)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionAudio() {

		let audioView = AudioView()
		audioView.delegate = self
		let navController = NavigationController(rootViewController: audioView)
		if #available(iOS 13.0, *) {
			navController.isModalInPresentation = true
			navController.modalPresentationStyle = .fullScreen
		}
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionStickers() {

		let stickersView = StickersView()
		stickersView.delegate = self
		let navController = NavigationController(rootViewController: stickersView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionLocation() {

		messageSend(text: nil, photo: nil, video: nil, audio: nil)
	}

	// MARK: - User actions (load earlier)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionLoadEarlier() {

		messageToDisplay += Int(INSERT_MESSAGES)
		refreshTableView2()
	}

	// MARK: - User actions (bubble tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTapBubble(_ indexPath: IndexPath) {

		let rcmessage = rcmessageAt(indexPath)

		if (rcmessage.type == MESSAGE_PHOTO) {
			if (rcmessage.mediaStatus == MEDIASTATUS_MANUAL) {
				LoaderPhoto.manual(rcmessage, in: tableView)
				tableView.reloadData()
			}
			if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
				let dictionary = PictureView.photos(messageId: rcmessage.messageId, chatId: chatId)
				if let photoItems = dictionary["photoItems"] as? [NYTPhoto] {
					if let initialPhoto = dictionary["initialPhoto"] as? NYTPhoto {
						let pictureView = PictureView(photos: photoItems, initialPhoto: initialPhoto)
						pictureView.setMessages(messages: true)
						present(pictureView, animated: true)
					}
				}
			}
		}

		if (rcmessage.type == MESSAGE_VIDEO) {
			if (rcmessage.mediaStatus == MEDIASTATUS_MANUAL) {
				LoaderVideo.manual(rcmessage, in: tableView)
				tableView.reloadData()
			}
			if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
				let url = URL(fileURLWithPath: rcmessage.videoPath)
				let videoView = VideoView(url: url)
				present(videoView, animated: true)
			}
		}

		if (rcmessage.type == MESSAGE_AUDIO) {
			if (rcmessage.mediaStatus == MEDIASTATUS_MANUAL) {
				LoaderAudio.manual(rcmessage, in: tableView)
				tableView.reloadData()
			}
			if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
				if (rcmessage.audioStatus == AUDIOSTATUS_STOPPED) {
					if let sound = Sound(contentsOfFile: rcmessage.audioPath) {
						sound.completionHandler = { didFinish in
							rcmessage.audioStatus = AUDIOSTATUS_STOPPED
							self.tableView.reloadData()
						}
						SoundManager.shared().playSound(sound)
						rcmessage.audioStatus = AUDIOSTATUS_PLAYING
						tableView.reloadData()
					}
				} else if (rcmessage.audioStatus == AUDIOSTATUS_PLAYING) {
					SoundManager.shared().stopAllSounds(false)
					rcmessage.audioStatus = AUDIOSTATUS_STOPPED
					tableView.reloadData()
				}
			}
		}

		if (rcmessage.type == MESSAGE_LOCATION) {
			let location = CLLocation(latitude: rcmessage.latitude, longitude: rcmessage.longitude)
			let mapView = MapView(location: location)
			let navController = NavigationController(rootViewController: mapView)
			present(navController, animated: true)
		}
	}

	// MARK: - User actions (avatar tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTapAvatar(_ indexPath: IndexPath) {

		let rcmessage = rcmessageAt(indexPath)
		let senderId = rcmessage.senderId

		if (senderId != FUser.currentId()) {
			let profileView = ProfileView(userId: senderId, chat: false)
			navigationController?.pushViewController(profileView, animated: true)
		}
	}

	// MARK: - User actions (menu)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuCopy(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			let rcmessage = rcmessageAt(indexPath)
			UIPasteboard.general.string = rcmessage.text
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuSave(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			let rcmessage = rcmessageAt(indexPath)

			if (rcmessage.type == MESSAGE_PHOTO) {
				if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
					if let image = rcmessage.photoImage {
						UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
					}
				}
			}

			if (rcmessage.type == MESSAGE_VIDEO) {
				if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
					UISaveVideoAtPathToSavedPhotosAlbum(rcmessage.videoPath, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
				}
			}

			if (rcmessage.type == MESSAGE_AUDIO) {
				if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
					let path = File.temp(ext: "mp4")
					File.copy(src: rcmessage.audioPath, dest: path, overwrite: true)
					UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuDelete(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			messageDelete(indexPath)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuForward(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			indexForward = indexPath
			
			let selectUsersView = SelectUsersView()
			selectUsersView.delegate = self
			let navController = NavigationController(rootViewController: selectUsersView)
			present(navController, animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

		if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

		if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return messageLoadedCount()
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		Chats.resignChatId()
		Messages.resignChatId()

		Chat.updateTypings(chatId: chatId, value: false)

		NotificationCenter.removeObserver(target: self)
	}
}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		let video = info[.mediaURL] as? URL
		let picture = info[.editedImage] as? UIImage

		messageSend(text: nil, photo: picture, video: video, audio: nil)

		picker.dismiss(animated: true)
	}
}

// MARK: - AudioDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: AudioDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didRecordAudio(path: String) {

		messageSend(text: nil, photo: nil, video: nil, audio: path)
	}
}

// MARK: - StickersDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: StickersDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectSticker(sticker: UIImage) {

		messageSend(text: nil, photo: sticker, video: nil, audio: nil)
	}
}

// MARK: - SelectUsersDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension ChatGroupView: SelectUsersDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectUsers(users: [DBUser]) {

		if let indexPath = indexForward {
			let dbmessage = dbmessageAt(indexPath)

			for dbuser in users {
				MessageQueue.forward(recipientId: dbuser.objectId, dbmessage: dbmessage)
			}

			indexForward = nil
		}
	}
}
