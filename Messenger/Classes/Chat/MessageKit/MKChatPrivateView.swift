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

import MessageKit
import InputBarAccessoryView

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MKChatPrivateView: MessagesViewController {

	private var recipientId = ""
	private var chatId = ""
	private var isBlocker = false

	private var dbchats: RLMResults = DBChat.objects(with: NSPredicate(value: false))
	private var dbmessages: RLMResults = DBMessage.objects(with: NSPredicate(value: false))

	private var mkmessages: [String: MKMessage] = [:]
	private var avatarImages: [String: UIImage] = [:]

	private var messageToDisplay: Int = 0
	private var messageTotalLast: Int = 0

	private var typingCounter: Int = 0
	private var lastRead: Int64 = 0

	let currentUser = MKSender(senderId: FUser.currentId(), displayName: FUser.fullname())

	open lazy var audioController = MKAudioController(messageCollectionView: messagesCollectionView)

	let refreshControl = UIRefreshControl()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(recipientId recipientId_: String) {

		super.init(nibName: nil, bundle: nil)

		recipientId = recipientId_

		chatId = Chat.chatId(recipientId: recipientId)
		isBlocker = Blocker.isBlocker(userId: recipientId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		NotificationCenter.addObserver(target: self, selector: #selector(refreshCollectionView1), name: NOTIFICATION_REFRESH_MESSAGES1)
		NotificationCenter.addObserver(target: self, selector: #selector(refreshCollectionView2), name: NOTIFICATION_REFRESH_MESSAGES2)

		configureMessageCollectionView()
		configureMessageInputBar()

		loadChats()
		loadMessages()

		messageToDisplay = 12
		messageTotalLast = messageTotalCount()

		DispatchQueue.main.async {
			self.messagesCollectionView.reloadData()
			self.messagesCollectionView.scrollToBottom()
		}
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

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var preferredStatusBarStyle: UIStatusBarStyle {

		return .lightContent
	}

	// MARK: - Configure methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func configureMessageCollectionView() {

		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messageCellDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messagesCollectionView.messagesLayoutDelegate = self

		scrollsToBottomOnKeyboardBeginsEditing = true
		maintainPositionOnKeyboardFrameChanged = true

		messagesCollectionView.refreshControl = refreshControl
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func configureMessageInputBar() {

		messageInputBar.delegate = self

		let button = InputBarButtonItem()
		button.image = UIImage(named: "mkchat_attach")
		button.setSize(CGSize(width: 36, height: 36), animated: false)

		button.onKeyboardSwipeGesture { item, gesture in
			if (gesture.direction == .left)	 { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)		}
			if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)	}
		}

		button.onTouchUpInside { item in
			self.actionAttachMessage()
		}

		messageInputBar.setStackViewItems([button], forStack: .left, animated: false)

		messageInputBar.sendButton.title = nil
		messageInputBar.sendButton.image = UIImage(named: "mkchat_send")
		messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)

		messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
		messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)

		messageInputBar.inputTextView.isImagePasteEnabled = false
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
	func mkmessageBy(_ messageId: String) -> MKMessage? {

		return mkmessages[messageId]
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func mkmessageAt(_ indexPath: IndexPath) -> MKMessage {

		let dbmessage = dbmessageAt(indexPath)
		let messageId = dbmessage.objectId

		if let mkmessage = mkmessageBy(messageId) {
			return mkmessage
		}

		let mkmessage = MKMessage(dbmessage: dbmessage)

		if (dbmessage.type == MESSAGE_PHOTO) { MKLoaderPhoto.start(mkmessage, in: messagesCollectionView) }
		if (dbmessage.type == MESSAGE_VIDEO) { MKLoaderVideo.start(mkmessage, in: messagesCollectionView) }
		if (dbmessage.type == MESSAGE_AUDIO) { MKLoaderAudio.start(mkmessage, in: messagesCollectionView) }

		mkmessages[messageId] = mkmessage

		return mkmessage
	}

	// MARK: - Typing indicator methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorUpdate() {

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
	@objc func updateTitleDetails() {

		let predicate = NSPredicate(format: "objectId == %@", recipientId)
		if let dbuser = DBUser.objects(with: predicate).firstObject() as? DBUser {
			title = dbuser.fullname
		}
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshCollectionView1() {

		refreshTyping()
		refreshLastRead()

		messageToDisplay += messageTotalCount() - messageTotalLast
		messageTotalLast = messageTotalCount()

		messagesCollectionView.reloadData()
		messagesCollectionView.performBatchUpdates(nil, completion: { _ in
			self.scrollToBottomIfVisible()
		})

		Chat.updateLastReads(chatId: chatId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshCollectionView2() {

		refreshTyping()
		refreshLastRead()

		messagesCollectionView.reloadData()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToBottomIfVisible() {

		if (messageLoadedCount() != 0) {
			let indexPath = IndexPath(item: 0, section: Int(messageLoadedCount()-1))
			if (messagesCollectionView.indexPathsForVisibleItems.contains(indexPath)) {
				self.messagesCollectionView.scrollToBottom(animated: true)
			}
		}
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

		setTypingIndicatorViewHidden((typeCount == 0), animated: false, whilePerforming: nil) { [weak self] success in
			if (success) { self?.scrollToBottomIfVisible() }
		}
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

		MessageQueue.send(chatId: chatId, recipientId: recipientId, text: text, photo: photo, video: video, audio: audio)

		Shortcut.update(userId: recipientId)
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionAttachMessage() {

		messageInputBar.inputTextView.resignFirstResponder()

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
		if #available(iOS 13.0, *) {
			navController.isModalInPresentation = true
			navController.modalPresentationStyle = .fullScreen
		}
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionLocation() {

		messageSend(text: nil, photo: nil, video: nil, audio: nil)
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCleanup() {

		audioController.stopAnyOngoingPlaying()

		Chats.resignChatId()
		Messages.resignChatId()

		Chat.updateTypings(chatId: chatId, value: false)

		NotificationCenter.removeObserver(target: self)
	}

	// MARK: - UIScrollViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

		if (refreshControl.isRefreshing) {
			if (messageToDisplay < messageTotalCount()) {
				messageToDisplay += 12
				messagesCollectionView.reloadDataAndKeepOffset()
			}
			refreshControl.endRefreshing()
		}
	}
}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MKChatPrivateView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
extension MKChatPrivateView: AudioDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didRecordAudio(path: String) {

		messageSend(text: nil, photo: nil, video: nil, audio: path)
	}
}

// MARK: - StickersDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MKChatPrivateView: StickersDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectSticker(sticker: UIImage) {

		messageSend(text: nil, photo: sticker, video: nil, audio: nil)
	}
}

// MARK: - MessagesDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MKChatPrivateView: MessagesDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func currentSender() -> SenderType {

		return currentUser
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

		return messageLoadedCount()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

		return mkmessageAt(indexPath)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

		if (indexPath.section % 3 == 0) {
			let showLoadMore = (indexPath.section == 0) && (messageTotalCount() > messageToDisplay)
			let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
			let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
			let color = showLoadMore ? UIColor.blue : UIColor.darkGray
			return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
		}
		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

		if (isFromCurrentSender(message: message)) {
			var status = STATUS_QUEUED

			let dbmessage = dbmessageAt(indexPath)
			if (dbmessage.status != STATUS_QUEUED) {
				status = (dbmessage.createdAt > lastRead) ? STATUS_SENT : STATUS_READ
			}

			return NSAttributedString(string: status, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
		}

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

		return nil
	}
}

// MARK: - MessageCellDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MKChatPrivateView: MessageCellDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didTapAvatar(in cell: MessageCollectionViewCell) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didTapMessage(in cell: MessageCollectionViewCell) {

		if let indexPath = messagesCollectionView.indexPath(for: cell) {
			let mkmessage = mkmessageAt(indexPath)
			if (mkmessage.mediaStatus == MEDIASTATUS_MANUAL) {
				switch mkmessage.kind {
				case .photo:
					MKLoaderPhoto.manual(mkmessage, in: messagesCollectionView)
				case .video:
					MKLoaderVideo.manual(mkmessage, in: messagesCollectionView)
				case .audio:
					MKLoaderAudio.manual(mkmessage, in: messagesCollectionView)
				default:
					break
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didTapPlayButton(in cell: AudioMessageCell) {

		if let indexPath = messagesCollectionView.indexPath(for: cell) {
			let mkmessage = mkmessageAt(indexPath)
			if (mkmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
				audioController.toggleSound(for: mkmessage, in: cell)
			}
		}
	}
}

// MARK: - MessagesDisplayDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MKChatPrivateView: MessagesDisplayDelegate {

	// MARK: - Text Messages
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {

		return isFromCurrentSender(message: message) ? .white : .darkText
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {

		switch detector {
		case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
		default: return MessageLabel.defaultAttributes
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {

		return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
	}

	// MARK: - All Messages
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {

		return isFromCurrentSender(message: message) ? MKDefaults.bubbleColorOutgoing : MKDefaults.bubbleColorIncoming
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

		let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
		return .bubbleTail(tail, .curved)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

		let mkmessage = mkmessageAt(indexPath)
		var imageAvatar = avatarImages[mkmessage.senderId]

		if (imageAvatar == nil) {
			if let path = DownloadManager.pathUser(mkmessage.senderId) {
				imageAvatar = UIImage(contentsOfFile: path)
				avatarImages[mkmessage.senderId] = imageAvatar
			}
		}

		if (imageAvatar == nil) {
			DownloadManager.startUser(mkmessage.senderId, pictureAt: mkmessage.senderPictureAt) { image, error in
				if (error == nil) {
					self.messagesCollectionView.reloadData()
				}
			}
		}

		avatarView.set(avatar: Avatar(image: imageAvatar, initials: mkmessage.senderInitials))
	}

	// MARK: - Media Messages
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

		let mkmessage = mkmessageAt(indexPath)
		if let messageContainerView = imageView.superview as? MessageContainerView {
			updateMediaMessageStatus(mkmessage, in: messageContainerView)
		}
	}

	// MARK: - Location Messages
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {

		if let image = UIImage(named: "mkchat_annotation") {
			let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
			annotationView.image = image
			annotationView.centerOffset = CGPoint(x: 0, y: -image.size.height / 2)
			return annotationView
		}
		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {

		let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: span)
	}

	// MARK: - Audio Messages
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {

		return isFromCurrentSender(message: message) ? MKDefaults.audioTextColorOutgoing : MKDefaults.audioTextColorIncoming
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {

		audioController.configureAudioCell(cell, message: message)

		if let mkmessage = mkmessageBy(message.messageId) {
			updateMediaMessageStatus(mkmessage, in: cell.messageContainerView)
		}
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateMediaMessageStatus(_ mkmessage: MKMessage, in messageContainerView: MessageContainerView) {

		let color: UIColor = isFromCurrentSender(message: mkmessage) ? MKDefaults.bubbleColorOutgoing : MKDefaults.bubbleColorIncoming

		if (mkmessage.mediaStatus == MEDIASTATUS_LOADING) {
			messageContainerView.showOverlayView(color)
			messageContainerView.showActivityIndicator()
			messageContainerView.hideManualDownloadIcon()
		}
		if (mkmessage.mediaStatus == MEDIASTATUS_MANUAL) {
			messageContainerView.showOverlayView(color)
			messageContainerView.hideActivityIndicator()
			messageContainerView.showManualDownloadIcon()
		}
		if (mkmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
			messageContainerView.hideOverlayView()
			messageContainerView.hideActivityIndicator()
			messageContainerView.hideManualDownloadIcon()
		}
	}
}

// MARK: - MessagesLayoutDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MKChatPrivateView: MessagesLayoutDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

		if (indexPath.section % 3 == 0) {
			if ((indexPath.section == 0) && (messageTotalCount() > messageToDisplay)) {
				return 40
			}
			return 18
		}
		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

		return isFromCurrentSender(message: message) ? 17 : 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

		return 0
	}
}

// MARK: - MessageInputBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MKChatPrivateView: InputBarAccessoryViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

		typingIndicatorUpdate()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

		for component in inputBar.inputTextView.components {
			if let text = component as? String {
				messageSend(text: text, photo: nil, video: nil, audio: nil)
			}
		}
		messageInputBar.inputTextView.text = ""
		messageInputBar.invalidatePlugins()
	}
}
