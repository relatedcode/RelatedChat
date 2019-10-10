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
class AllMediaCell: UICollectionViewCell {

	@IBOutlet var imageItem: UIImageView!
	@IBOutlet var imageVideo: UIImageView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(dbmessage: DBMessage) {

		imageItem.image = UIImage(named: "allmedia_blank")

		if (dbmessage.type == MESSAGE_PHOTO) {
			bindPicture(dbmessage: dbmessage)
		}
		if (dbmessage.type == MESSAGE_VIDEO) {
			bindVideo(dbmessage: dbmessage)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindPicture(dbmessage: DBMessage) {

		imageVideo.isHidden = true

		if let path = DownloadManager.pathPhoto(dbmessage.objectId) {
			if let image = UIImage(contentsOfFile: path) {
				imageItem.image = Image.square(image: image, size: 320)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindVideo(dbmessage: DBMessage) {

		imageVideo.isHidden = false

		if let path = DownloadManager.pathVideo(dbmessage.objectId) {
			DispatchQueue(label: "bindVideo").async {
				let image = Video.thumbnail(path: path)
				DispatchQueue.main.async {
					self.imageItem.image = Image.square(image: image, size: 320)
				}
			}
		}
	}
}
