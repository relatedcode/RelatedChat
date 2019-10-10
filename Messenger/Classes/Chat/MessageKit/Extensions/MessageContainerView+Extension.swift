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

//-------------------------------------------------------------------------------------------------------------------------------------------------
private var overlayViewAssociationKey: Void?
private var activityIndicatorAssociationKey: Void?
private var manualDownloadIconAssociationKey: Void?

//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MessageContainerView {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func showOverlayView(_ color: UIColor) {

		createOverlayView()

		self.overlayView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		self.overlayView?.backgroundColor = color
		self.overlayView?.isHidden = false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func hideOverlayView() {

		self.overlayView?.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createOverlayView() {

		if (self.overlayView != nil) { return }

		let viewOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
		viewOverlay.isUserInteractionEnabled = false
		self.addSubview(viewOverlay)

		self.overlayView = viewOverlay
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private var overlayView: UIView? {

		get {
			return objc_getAssociatedObject(self, &overlayViewAssociationKey) as? UIView
		}
		set(value) {
			objc_setAssociatedObject(self, &overlayViewAssociationKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	//MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func showActivityIndicator() {

		createActivityIndicator()

		self.activityIndicator?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		self.activityIndicator?.style = (self.frame.height > 50) ? .whiteLarge : .white
		self.activityIndicator?.startAnimating()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func hideActivityIndicator() {

		self.activityIndicator?.stopAnimating()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createActivityIndicator() {

		if (self.activityIndicator != nil) { return }

		let activityIndicator = UIActivityIndicatorView(style: .white)
		activityIndicator.isUserInteractionEnabled = false
		activityIndicator.hidesWhenStopped = true
		self.addSubview(activityIndicator)

		self.activityIndicator = activityIndicator
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private var activityIndicator: UIActivityIndicatorView? {

		get {
			return objc_getAssociatedObject(self, &activityIndicatorAssociationKey) as? UIActivityIndicatorView
		}
		set(value) {
			objc_setAssociatedObject(self, &activityIndicatorAssociationKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	//MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func showManualDownloadIcon() {

		createManualDownloadIcon()

		self.manualDownloadIcon?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		self.manualDownloadIcon?.isHidden = false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func hideManualDownloadIcon() {

		self.manualDownloadIcon?.isHidden = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createManualDownloadIcon() {

		if (self.manualDownloadIcon != nil) { return }

		let viewManualDownload = UIImageView(image: UIImage(named: "mkchat_manual"))
		viewManualDownload.isUserInteractionEnabled = false
		viewManualDownload.contentMode = .center
		self.addSubview(viewManualDownload)

		self.manualDownloadIcon = viewManualDownload
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private var manualDownloadIcon: UIImageView? {

		get {
			return objc_getAssociatedObject(self, &manualDownloadIconAssociationKey) as? UIImageView
		}
		set(value) {
			objc_setAssociatedObject(self, &manualDownloadIconAssociationKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}
