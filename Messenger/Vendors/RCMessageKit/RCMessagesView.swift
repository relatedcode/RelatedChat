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

import InputBarAccessoryView

//-------------------------------------------------------------------------------------------------------------------------------------------------
class RCMessagesView: UIViewController {

	@IBOutlet var viewTitle: UIView!
	@IBOutlet var labelTitle1: UILabel!
	@IBOutlet var labelTitle2: UILabel!
	@IBOutlet var buttonTitle: UIButton!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var viewLoadEarlier: UIView!
	@IBOutlet var viewTypingIndicator: UIView!

	var messageInputBar = InputBarAccessoryView()
	private var keyboardManager = KeyboardManager()

	private var initialized = false

	private var heightKeyboard: CGFloat = 0
	private var keyboardWillShow = false

	//---------------------------------------------------------------------------------------------------------------------------------------------
	convenience init() {

		self.init(nibName: "RCMessagesView", bundle: nil)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationItem.titleView = viewTitle

		tableView.register(RCHeaderUpperCell.self, forCellReuseIdentifier: "RCHeaderUpperCell")
		tableView.register(RCHeaderLowerCell.self, forCellReuseIdentifier: "RCHeaderLowerCell")

		tableView.register(RCMessageTextCell.self, forCellReuseIdentifier: "RCMessageTextCell")
		tableView.register(RCMessageEmojiCell.self, forCellReuseIdentifier: "RCMessageEmojiCell")
		tableView.register(RCMessagePhotoCell.self, forCellReuseIdentifier: "RCMessagePhotoCell")
		tableView.register(RCMessageVideoCell.self, forCellReuseIdentifier: "RCMessageVideoCell")
		tableView.register(RCMessageAudioCell.self, forCellReuseIdentifier: "RCMessageAudioCell")
		tableView.register(RCMessageLocationCell.self, forCellReuseIdentifier: "RCMessageLocationCell")

		tableView.register(RCFooterUpperCell.self, forCellReuseIdentifier: "RCFooterUpperCell")
		tableView.register(RCFooterLowerCell.self, forCellReuseIdentifier: "RCFooterLowerCell")

		tableView.tableHeaderView = viewLoadEarlier

		let notificationWillShow = UIResponder.keyboardWillShowNotification
		let notificationWillHide = UIResponder.keyboardWillHideNotification

		NotificationCenter.addObserver(target: self, selector: #selector(keyboardWillShow(_:)), name: notificationWillShow.rawValue)
		NotificationCenter.addObserver(target: self, selector: #selector(keyboardWillHide(_:)), name: notificationWillHide.rawValue)

		configureMessageInputBar()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {

		super.viewDidLayoutSubviews()

		layoutTableView()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (initialized == false) {
			initialized = true
			scrollToBottom(animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		dismissKeyboard()
	}

	// MARK: - Load earlier methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadEarlierShow(_ show: Bool) {

		viewLoadEarlier.isHidden = !show
		var frame: CGRect = viewLoadEarlier.frame
		frame.size.height = show ? 50 : 0
		viewLoadEarlier.frame = frame
		tableView.reloadData()
	}

	// MARK: - Message methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {

		return RCMessage()
	}

	// MARK: - Avatar methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func avatarInitials(_ indexPath: IndexPath) -> String {

		return ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func avatarImage(_ indexPath: IndexPath) -> UIImage? {

		return nil
	}

	// MARK: - Header, Footer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textHeaderUpper(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textHeaderLower(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textFooterUpper(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textFooterLower(_ indexPath: IndexPath) -> String? {

		return nil
	}

	// MARK: - Menu controller methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func menuItems(_ indexPath: IndexPath) -> [Any]? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		return false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var canBecomeFirstResponder: Bool {

		return true
	}

	// MARK: - Typing indicator methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorShow(_ show: Bool, animated: Bool) {

		if show {
			tableView.tableFooterView = viewTypingIndicator
			scrollToBottom(animated: animated)
		} else {
			UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
				self.tableView.tableFooterView = nil
			})
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorUpdate() {

	}

	// MARK: - Keyboard methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardWillShow(_ notification: Notification?) {

		if (heightKeyboard != 0) { return }

		keyboardWillShow = true

		if let info = notification?.userInfo {
			if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
				if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
					DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
						if (self.keyboardWillShow) {
							self.heightKeyboard = keyboard.size.height
							self.layoutTableView()
							self.scrollToBottom(animated: true)
						}
					}
				}
			}
		}

		UIMenuController.shared.menuItems = nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardWillHide(_ notification: Notification?) {

		heightKeyboard = 0
		keyboardWillShow = false

		layoutTableView()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func dismissKeyboard() {

		messageInputBar.inputTextView.resignFirstResponder()
	}

	// MARK: - Message input bar methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func configureMessageInputBar() {

		view.addSubview(messageInputBar)

		keyboardManager.bind(inputAccessoryView: messageInputBar)
		keyboardManager.bind(to: tableView)

		messageInputBar.delegate = self

		let button = InputBarButtonItem()
		button.image = UIImage(named: "rcmessage_attach")
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
		messageInputBar.sendButton.image = UIImage(named: "rcmessage_send")
		messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)

		messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
		messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)

		messageInputBar.inputTextView.isImagePasteEnabled = false
	}

	// MARK: - User actions (title)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionTitle(_ sender: Any) {

		actionTitle()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionTitle() {

	}

	// MARK: - User actions (load earlier)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLoadEarlier(_ sender: Any) {

		actionLoadEarlier()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionLoadEarlier() {

	}

	// MARK: - User actions (bubble tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionTapBubble(_ indexPath: IndexPath) {

	}

	// MARK: - User actions (avatar tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionTapAvatar(_ indexPath: IndexPath) {

	}

	// MARK: - User actions (input panel)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionAttachMessage() {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionSendMessage(_ text: String) {

	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func layoutTableView() {

		let widthView	= view.frame.size.width
		let heightView	= view.frame.size.height

		let leftSafe	= view.safeAreaInsets.left
		let rightSafe	= view.safeAreaInsets.right

		let heightInput = messageInputBar.bounds.height

		let widthTable = widthView - leftSafe - rightSafe
		let heightTable = heightView - heightInput - heightKeyboard

		tableView.frame = CGRect(x: leftSafe, y: 0, width: widthTable, height: heightTable)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollToBottom(animated: Bool) {

		if (tableView.numberOfSections > 0) {
			let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
			tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
		}
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 5
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.row == 0)						{ return cellForHeaderUpper(tableView, at: indexPath)		}
		if (indexPath.row == 1)						{ return cellForHeaderLower(tableView, at: indexPath)		}

		if (indexPath.row == 2) {
			let rcmessage = rcmessageAt(indexPath)
			if (rcmessage.type == MESSAGE_TEXT)		{ return cellForMessageText(tableView, at: indexPath)		}
			if (rcmessage.type == MESSAGE_EMOJI)	{ return cellForMessageEmoji(tableView, at: indexPath)		}
			if (rcmessage.type == MESSAGE_PHOTO)	{ return cellForMessagePhoto(tableView, at: indexPath)		}
			if (rcmessage.type == MESSAGE_VIDEO)	{ return cellForMessageVideo(tableView, at: indexPath)		}
			if (rcmessage.type == MESSAGE_AUDIO)	{ return cellForMessageAudio(tableView, at: indexPath)		}
			if (rcmessage.type == MESSAGE_LOCATION)	{ return cellForMessageLocation(tableView, at: indexPath)	}
		}

		if (indexPath.row == 3)						{ return cellForFooterUpper(tableView, at: indexPath)		}
		if (indexPath.row == 4)						{ return cellForFooterLower(tableView, at: indexPath)		}

		return UITableViewCell()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForHeaderUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderUpperCell", for: indexPath) as! RCHeaderUpperCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForHeaderLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCHeaderLowerCell", for: indexPath) as! RCHeaderLowerCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForMessageText(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageTextCell", for: indexPath) as! RCMessageTextCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForMessageEmoji(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageEmojiCell", for: indexPath) as! RCMessageEmojiCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForMessagePhoto(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessagePhotoCell", for: indexPath) as! RCMessagePhotoCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForMessageVideo(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageVideoCell", for: indexPath) as! RCMessageVideoCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForMessageAudio(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageAudioCell", for: indexPath) as! RCMessageAudioCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForMessageLocation(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCMessageLocationCell", for: indexPath) as! RCMessageLocationCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForFooterUpper(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterUpperCell", for: indexPath) as! RCFooterUpperCell
		cell.bindData(self, at: indexPath)
		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func cellForFooterLower(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "RCFooterLowerCell", for: indexPath) as! RCFooterLowerCell
		cell.bindData(self, at: indexPath)
		return cell
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

		view.tintColor = UIColor.clear
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

		view.tintColor = UIColor.clear
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		if (indexPath.row == 0)						{ return RCHeaderUpperCell.height(self, at: indexPath)		}
		if (indexPath.row == 1)						{ return RCHeaderLowerCell.height(self, at: indexPath)		}

		if (indexPath.row == 2) {
			let rcmessage = rcmessageAt(indexPath)
			if (rcmessage.type == MESSAGE_TEXT)		{ return RCMessageTextCell.height(self, at: indexPath)		}
			if (rcmessage.type == MESSAGE_EMOJI)	{ return RCMessageEmojiCell.height(self, at: indexPath)		}
			if (rcmessage.type == MESSAGE_PHOTO)	{ return RCMessagePhotoCell.height(self, at: indexPath)		}
			if (rcmessage.type == MESSAGE_VIDEO)	{ return RCMessageVideoCell.height(self, at: indexPath)		}
			if (rcmessage.type == MESSAGE_AUDIO)	{ return RCMessageAudioCell.height(self, at: indexPath)		}
			if (rcmessage.type == MESSAGE_LOCATION)	{ return RCMessageLocationCell.height(self, at: indexPath)	}
		}

		if (indexPath.row == 3)						{ return RCFooterUpperCell.height(self, at: indexPath)		}
		if (indexPath.row == 4)						{ return RCFooterLowerCell.height(self, at: indexPath)		}

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return RCDefaults.sectionHeaderMargin
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return RCDefaults.sectionFooterMargin
	}
}

// MARK: - InputBarAccessoryViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension RCMessagesView: InputBarAccessoryViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

		typingIndicatorUpdate()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.scrollToBottom(animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

		for component in inputBar.inputTextView.components {
			if let text = component as? String {
				actionSendMessage(text)
			}
		}
		messageInputBar.inputTextView.text = ""
		messageInputBar.invalidatePlugins()
	}
}
