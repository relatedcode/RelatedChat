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
class RCMessagePhotoCell: RCMessageCell {

	private var imageViewPhoto: UIImageView!
	private var imageViewManual: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.photoBubbleColorIncoming : RCDefaults.photoBubbleColorOutgoing

		if (imageViewPhoto == nil) {
			imageViewPhoto = UIImageView()
			imageViewPhoto.layer.masksToBounds = true
			imageViewPhoto.layer.cornerRadius = RCDefaults.bubbleRadius
			viewBubble.addSubview(imageViewPhoto)
		}

		if (activityIndicator == nil) {
			activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
			viewBubble.addSubview(activityIndicator)
		}

		if (imageViewManual == nil) {
			imageViewManual = UIImageView(image: RCDefaults.photoImageManual)
			viewBubble.addSubview(imageViewManual)
		}

		if (rcmessage.mediaStatus == MEDIASTATUS_LOADING) {
			imageViewPhoto.image = nil
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
			imageViewPhoto.image = rcmessage.photoImage
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MEDIASTATUS_MANUAL) {
			imageViewPhoto.image = nil
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = false
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCMessagePhotoCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		imageViewPhoto.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		let widthActivity = activityIndicator.frame.size.width
		let heightActivity = activityIndicator.frame.size.height
		let xActivity = (size.width - widthActivity) / 2
		let yActivity = (size.height - heightActivity) / 2
		activityIndicator.frame = CGRect(x: xActivity, y: yActivity, width: widthActivity, height: heightActivity)

		let widthManual = imageViewManual.image?.size.width ?? 0
		let heightManual = imageViewManual.image?.size.height ?? 0
		let xManual = (size.width - widthManual) / 2
		let yManual = (size.height - heightManual) / 2
		imageViewManual.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGFloat {

		let size = self.size(messagesView, at: indexPath)
		return size.height
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func size(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGSize {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		let photoWidth = CGFloat(rcmessage.photoWidth)
		let photoHeight = CGFloat(rcmessage.photoHeight)

		let width = CGFloat.minimum(RCDefaults.photoBubbleWidth, photoWidth)
		return CGSize(width: width, height: photoHeight * width / photoWidth)
	}
}
