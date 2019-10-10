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
enum RCDefaults {

	// Section
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let sectionHeaderMargin			= CGFloat(8)
	static let sectionFooterMargin			= CGFloat(8)

	// Header upper
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let headerUpperHeight			= CGFloat(20)
	static let headerUpperLeft				= CGFloat(10)
	static let headerUpperRight				= CGFloat(10)

	static let headerUpperColor				= UIColor.lightGray
	static let headerUpperFont				= UIFont.systemFont(ofSize: 12)

	// Header lower
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let headerLowerHeight			= CGFloat(15)
	static let headerLowerLeft				= CGFloat(50)
	static let headerLowerRight				= CGFloat(50)

	static let headerLowerColor				= UIColor.lightGray
	static let headerLowerFont				= UIFont.systemFont(ofSize: 12)

	// Footer upper
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let footerUpperHeight			= CGFloat(15)
	static let footerUpperLeft				= CGFloat(50)
	static let footerUpperRight				= CGFloat(50)

	static let footerUpperColor				= UIColor.lightGray
	static let footerUpperFont				= UIFont.systemFont(ofSize: 12)

	// Footer lower
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let footerLowerHeight			= CGFloat(15)
	static let footerLowerLeft				= CGFloat(10)
	static let footerLowerRight				= CGFloat(10)

	static let footerLowerColor				= UIColor.lightGray
	static let footerLowerFont				= UIFont.systemFont(ofSize: 12)

	// Bubble
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let bubbleMarginLeft				= CGFloat(40)
	static let bubbleMarginRight			= CGFloat(40)
	static let bubbleRadius					= CGFloat(15)

	// Avatar
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let avatarDiameter				= CGFloat(30)
	static let avatarMarginLeft				= CGFloat(5)
	static let avatarMarginRight			= CGFloat(5)

	static let avatarBackColor				= UIColor.groupTableViewBackground
	static let avatarTextColor				= UIColor.white

	static let avatarFont					= UIFont.systemFont(ofSize: 12)

	// Text cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let textBubbleWidthMin			= CGFloat(45)
	static let textBubbleHeightMin			= CGFloat(35)

	static let textBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let textBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
	static let textTextColorOutgoing		= UIColor.white
	static let textTextColorIncoming		= UIColor.black

	static let textFont						= UIFont.systemFont(ofSize: 16)

	static let textInsetLeft				= CGFloat(10)
	static let textInsetRight				= CGFloat(10)
	static let textInsetTop					= CGFloat(10)
	static let textInsetBottom				= CGFloat(10)

	static let textInset = UIEdgeInsets.init(top: textInsetTop, left: textInsetLeft, bottom: textInsetBottom, right: textInsetRight)

	// Emoji cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let emojiBubbleWidthMin			= CGFloat(45)
	static let emojiBubbleHeightMin			= CGFloat(30)

	static let emojiBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let emojiBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

	static let emojiFont					= UIFont.systemFont(ofSize: 46)

	static let emojiInsetLeft				= CGFloat(10)
	static let emojiInsetRight				= CGFloat(10)
	static let emojiInsetTop				= CGFloat(10)
	static let emojiInsetBottom				= CGFloat(10)

	static let emojiInset = UIEdgeInsets.init(top: emojiInsetTop, left: emojiInsetLeft, bottom: emojiInsetBottom, right: emojiInsetRight)

	// Photo cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let photoBubbleWidth				= CGFloat(200)

	static let photoBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let photoBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

	static let photoImageManual				= UIImage(named: "rcmessages_manual")!

	// Video cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let videoBubbleWidth				= CGFloat(200)
	static let videoBubbleHeight			= CGFloat(200)

	static let videoBubbleColorOutgoing		= UIColor.lightGray
	static let videoBubbleColorIncoming		= UIColor.lightGray

	static let videoImagePlay				= UIImage(named: "rcmessages_videoplay")!
	static let videoImageManual				= UIImage(named: "rcmessages_manual")!

	// Audio cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let audioBubbleWidht				= CGFloat(150)
	static let audioBubbleHeight			= CGFloat(40)

	static let audioBubbleColorOutgoing		= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let audioBubbleColorIncoming		= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
	static let audioTextColorOutgoing		= UIColor.white
	static let audioTextColorIncoming		= UIColor.black

	static let audioImagePlay				= UIImage(named: "rcmessages_audioplay")!
	static let audioImagePause				= UIImage(named: "rcmessages_audiopause")!
	static let audioImageManual				= UIImage(named: "rcmessages_manual")!

	static let audioFont					= UIFont.systemFont(ofSize: 16)

	// Location cell
	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let locationBubbleWidth			= CGFloat(200)
	static let locationBubbleHeight 		= CGFloat(200)

	static let locationBubbleColorOutgoing	= UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
	static let locationBubbleColorIncoming	= UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
}
