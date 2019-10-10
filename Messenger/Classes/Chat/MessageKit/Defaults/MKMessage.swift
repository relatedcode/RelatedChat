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
struct MKSender: SenderType, Equatable {

	var senderId: String
	var displayName: String
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MKPhotoItem: NSObject, MediaItem {

	var url: URL?
	var image: UIImage?
	var placeholderImage: UIImage
	var size: CGSize

	init(width: Int, height: Int) {

		self.placeholderImage = UIImage()
		self.size = CGSize(width: width, height: height)
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MKVideoItem: NSObject, MediaItem {

	var url: URL?
	var image: UIImage?
	var placeholderImage: UIImage
	var size: CGSize

	init(duration: Int) {

		self.placeholderImage = UIImage()
		self.size = CGSize(width: 240, height: 240)
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MKAudioItem: NSObject, AudioItem {

	var url: URL
	var size: CGSize
	var duration: Float

	init(duration: Int) {

		self.url = URL(fileURLWithPath: "")
		self.size = CGSize(width: 160, height: 35)
		self.duration = Float(duration)
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MKLocationItem: NSObject, LocationItem {

	var location: CLLocation
	var size: CGSize

	init(location: CLLocation) {

		self.location = location
		self.size = CGSize(width: 240, height: 240)
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MKMessage: NSObject, MessageType {

	var chatId: String
	var messageId: String

	var senderId: String
	var senderFullname: String
	var senderInitials: String
	var senderPictureAt: Int64

	var mksender: MKSender

	var kind: MessageKind
	var photoItem: MKPhotoItem?
	var videoItem: MKVideoItem?
	var audioItem: MKAudioItem?

	var sentDate: Date
	var mediaStatus: Int32

	var sender: SenderType { return mksender }

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(dbmessage: DBMessage) {

		self.chatId = dbmessage.chatId
		self.messageId = dbmessage.objectId

		self.senderId = dbmessage.senderId
		self.senderFullname = dbmessage.senderFullname
		self.senderInitials = dbmessage.senderInitials
		self.senderPictureAt = dbmessage.senderPictureAt

		self.mksender = MKSender(senderId: dbmessage.senderId, displayName: dbmessage.senderFullname)

		switch dbmessage.type {
			case MESSAGE_TEXT:
				self.kind = MessageKind.text(dbmessage.text)

			case MESSAGE_EMOJI:
				self.kind = MessageKind.emoji(dbmessage.text)

			case MESSAGE_PHOTO:
				let photoItem = MKPhotoItem(width: dbmessage.photoWidth, height: dbmessage.photoHeight)
				self.kind = MessageKind.photo(photoItem)
				self.photoItem = photoItem

			case MESSAGE_VIDEO:
				let videoItem = MKVideoItem(duration: dbmessage.videoDuration)
				self.kind = MessageKind.video(videoItem)
				self.videoItem = videoItem

			case MESSAGE_AUDIO:
				let audioItem = MKAudioItem(duration: dbmessage.audioDuration)
				self.kind = MessageKind.audio(audioItem)
				self.audioItem = audioItem

			case MESSAGE_LOCATION:
				let location = CLLocation(latitude: dbmessage.latitude, longitude: dbmessage.longitude)
				let locationItem = MKLocationItem(location: location)
				self.kind = MessageKind.location(locationItem)

			default:
				self.kind = MessageKind.text(dbmessage.text)
		}

		self.sentDate = Date.date(timestamp: dbmessage.createdAt)
		self.mediaStatus = MEDIASTATUS_UNKNOWN
	}
}
