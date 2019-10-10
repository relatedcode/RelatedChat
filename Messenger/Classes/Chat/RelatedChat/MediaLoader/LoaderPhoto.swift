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
class LoaderPhoto: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func start(_ rcmessage: RCMessage, in tableView: UITableView) {

		if let path = DownloadManager.pathPhoto(rcmessage.messageId) {
			showMedia(rcmessage, path: path, in: tableView)
		} else {
			loadPhotoMedia(rcmessage, in: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func manual(_ rcmessage: RCMessage, in tableView: UITableView) {

		DownloadManager.clearManualPhoto(rcmessage.messageId)
		downloadMedia(rcmessage, in: tableView)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func loadPhotoMedia(_ rcmessage: RCMessage, in tableView: UITableView) {

		let network = FUser.networkPhoto()

		if (network == NETWORK_MANUAL) || ((network == NETWORK_WIFI) && (Connectivity.isReachableViaWiFi() == false)) {
			rcmessage.mediaStatus = MEDIASTATUS_MANUAL
		} else {
			downloadMedia(rcmessage, in: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func downloadMedia(_ rcmessage: RCMessage, in tableView: UITableView) {

		rcmessage.mediaStatus = MEDIASTATUS_LOADING

		DownloadManager.startPhoto(rcmessage.messageId) { path, error in
			if (error == nil) {
				Cryptor.decrypt(path: path, chatId: rcmessage.chatId)
				showMedia(rcmessage, path: path, in: tableView)
			} else {
				rcmessage.mediaStatus = MEDIASTATUS_MANUAL
			}
			tableView.reloadData()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func showMedia(_ rcmessage: RCMessage, path: String, in tableView: UITableView) {

		rcmessage.photoImage = UIImage(contentsOfFile: path)
		rcmessage.mediaStatus = MEDIASTATUS_SUCCEED
	}
}
