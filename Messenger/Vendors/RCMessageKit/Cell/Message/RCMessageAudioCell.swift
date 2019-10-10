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
class RCMessageAudioCell: RCMessageCell {

	private var imageViewPlay: UIImageView!
	private var labelDuration: UILabel!
	private var imageViewManual: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.audioBubbleColorIncoming : RCDefaults.audioBubbleColorOutgoing

		if (imageViewPlay == nil) {
			imageViewPlay = UIImageView()
			viewBubble.addSubview(imageViewPlay)
		}

		if (labelDuration == nil) {
			labelDuration = UILabel()
			labelDuration.font = RCDefaults.audioFont
			labelDuration.textAlignment = .right
			viewBubble.addSubview(labelDuration)
		}

		if (activityIndicator == nil) {
			activityIndicator = UIActivityIndicatorView(style: .white)
			viewBubble.addSubview(activityIndicator)
		}

		if (imageViewManual == nil) {
			imageViewManual = UIImageView(image: RCDefaults.audioImageManual)
			viewBubble.addSubview(imageViewManual)
		}

		if (rcmessage.audioStatus == AUDIOSTATUS_STOPPED) { imageViewPlay.image = RCDefaults.audioImagePlay		}
		if (rcmessage.audioStatus == AUDIOSTATUS_PLAYING) { imageViewPlay.image = RCDefaults.audioImagePause	}

		labelDuration.textColor = rcmessage.incoming ? RCDefaults.audioTextColorIncoming : RCDefaults.audioTextColorOutgoing

		if (rcmessage.audioDuration < 60) {
			labelDuration.text = String(format: "0:%02ld", rcmessage.audioDuration)
		} else {
			labelDuration.text = String(format: "%ld:%02ld", rcmessage.audioDuration / 60, rcmessage.audioDuration % 60)
		}

		if (rcmessage.mediaStatus == MEDIASTATUS_LOADING) {
			imageViewPlay.isHidden = true
			labelDuration.isHidden = true
			activityIndicator.startAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MEDIASTATUS_SUCCEED) {
			imageViewPlay.isHidden = false
			labelDuration.isHidden = false
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = true
		}

		if (rcmessage.mediaStatus == MEDIASTATUS_MANUAL) {
			imageViewPlay.isHidden = true
			labelDuration.isHidden = true
			activityIndicator.stopAnimating()
			imageViewManual.isHidden = false
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCMessageAudioCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		let widthPlay = imageViewPlay.image?.size.width ?? 0
		let heightPlay = imageViewPlay.image?.size.height ?? 0
		let yPlay = (size.height - heightPlay) / 2
		imageViewPlay.frame = CGRect(x: 10, y: yPlay, width: widthPlay, height: heightPlay)

		labelDuration.frame = CGRect(x: size.width - 100, y: 0, width: 90, height: size.height)

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

		return CGSize(width: RCDefaults.audioBubbleWidht, height: RCDefaults.audioBubbleHeight)
	}
}
