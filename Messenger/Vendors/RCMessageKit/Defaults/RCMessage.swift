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
class RCMessage: NSObject {

	var chatId: String = ""
	var messageId: String = ""

	var senderId: String = ""
	var senderFullname: String = ""
	var senderInitials: String = ""
	var senderPictureAt: Int64 = 0

	var type: String = ""
	var text: String = ""

	var photoWidth: Int = 0
	var photoHeight: Int = 0
	var videoDuration: Int = 0
	var audioDuration: Int = 0

	var latitude: CLLocationDegrees = 0
	var longitude: CLLocationDegrees = 0

	var createdAt: Int64 = 0

	var incoming: Bool = false
	var outgoing: Bool = false

	var videoPath: String = ""
	var audioPath: String = ""

	var photoImage: UIImage?
	var videoThumbnail: UIImage?
	var locationThumbnail: UIImage?

	var audioStatus: Int32 = AUDIOSTATUS_STOPPED
	var mediaStatus: Int32 = MEDIASTATUS_UNKNOWN

	// MARK: - Initialization methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(dbmessage: DBMessage) {

		super.init()

		self.chatId = dbmessage.chatId
		self.messageId = dbmessage.objectId

		self.senderId = dbmessage.senderId
		self.senderFullname = dbmessage.senderFullname
		self.senderInitials = dbmessage.senderInitials
		self.senderPictureAt = dbmessage.senderPictureAt

		self.type = dbmessage.type
		self.text = dbmessage.text

		self.photoWidth = dbmessage.photoWidth
		self.photoHeight = dbmessage.photoHeight
		self.videoDuration = dbmessage.videoDuration
		self.audioDuration = dbmessage.audioDuration

		self.latitude = dbmessage.latitude
		self.longitude = dbmessage.longitude

		self.createdAt = dbmessage.createdAt

		let currentId = FUser.currentId()
		self.incoming = (dbmessage.senderId != currentId)
		self.outgoing = (dbmessage.senderId == currentId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(text: String, incoming: Bool) {

		super.init()

		self.incoming = incoming
		self.outgoing = !incoming

		self.type = MESSAGE_TEXT
		self.text = text
	}
}
