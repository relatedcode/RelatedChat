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
class DialogflowView: RCMessagesView {

	var rcmessages: [RCMessage] = []

	private var apiAI: ApiAI?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)

		let wallpaper = FUser.wallpaper()
		if (wallpaper.count != 0) {
			tableView.backgroundView = UIImageView(image: UIImage(named: wallpaper))
		}

		apiAI = ApiAI.shared()

		loadEarlierShow(false)
		updateTitleDetails()
	}

	// MARK: - Message methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func rcmessageAt(_ indexPath: IndexPath) -> RCMessage {

		return rcmessages[indexPath.section]
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func addMessage(text: String, incoming: Bool) {

		let rcmessage = RCMessage(text: text, incoming: incoming)
		rcmessages.append(rcmessage)
		refreshTableView1()
	}

	// MARK: - Avatar methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarInitials(_ indexPath: IndexPath) -> String {

		let rcmessage = rcmessageAt(indexPath)

		if (rcmessage.outgoing) {
			return FUser.initials()
		} else {
			return "AI"
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarImage(_ indexPath: IndexPath) -> UIImage? {

		return nil
	}

	// MARK: - Header, Footer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textHeaderUpper(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textHeaderLower(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textFooterUpper(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textFooterLower(_ indexPath: IndexPath) -> String? {

		return nil
	}

	// MARK: - Menu controller methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func menuItems(_ indexPath: IndexPath) -> [Any]? {

		let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(actionMenuCopy(_:)))

		menuItemCopy.indexPath = indexPath

		return [menuItemCopy]
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		if (action == #selector(actionMenuCopy(_:))) { return true 		}
		return false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var canBecomeFirstResponder: Bool {

		return true
	}

	// MARK: - Typing indicator methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorShow(_ show: Bool, animated: Bool, delay: CGFloat) {

		DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
			self.typingIndicatorShow(show, animated: animated)
		}
	}

	// MARK: - Title details methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateTitleDetails() {

		labelTitle1.text = "AI interface"
		labelTitle2.text = "online now"
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView1() {

		refreshTableView2()
		scrollToBottom(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView2() {

		tableView.reloadData()
	}

	// MARK: - Dialogflow methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func sendDialogflowRequest(text: String) {

		typingIndicatorShow(true, animated: true, delay: 0.5)

		let aiRequest: AITextRequest? = apiAI?.textRequest()
		aiRequest?.query = [text]

		aiRequest?.setCompletionBlockSuccess({ request, response in
			if let dictionary = response as? [AnyHashable: Any] {
				self.typingIndicatorShow(false, animated: true, delay: 1.0)
				self.displayDialogflowResponse(dictionary: dictionary, delay: 1.1)
			}
		}, failure: { request, error in
			ProgressHUD.showError("Dialogflow request error.")
		})

		apiAI?.enqueue(aiRequest)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func displayDialogflowResponse(dictionary: [AnyHashable: Any], delay: CGFloat) {

		DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
			self.displayDialogflowResponse(dictionary: dictionary)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func displayDialogflowResponse(dictionary: [AnyHashable: Any]) {

		if let result = dictionary["result"] as? [AnyHashable: Any] {
			if let fulfillment = result["fulfillment"] as? [AnyHashable: Any] {
				if let speech = fulfillment["speech"] as? String {
					addMessage(text: speech, incoming: true)
					Audio.playMessageIncoming()
				}
			}
		}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		dismiss(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionSendMessage(_ text: String) {

		addMessage(text: text, incoming: false)
		Audio.playMessageOutgoing()

		sendDialogflowRequest(text: text)
	}

	// MARK: - User actions (menu)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuCopy(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			let rcmessage = rcmessageAt(indexPath)
			UIPasteboard.general.string = rcmessage.text
		}
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return rcmessages.count
	}
}
