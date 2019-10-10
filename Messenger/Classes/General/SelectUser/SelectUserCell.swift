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
class SelectUserCell: UITableViewCell {

	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(dbuser: DBUser) {

		labelName.text = dbuser.fullname
		labelStatus.text = dbuser.status
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(dbuser: DBUser, tableView: UITableView, indexPath: IndexPath) {

		if let path = DownloadManager.pathUser(dbuser.objectId) {
			imageUser.image = UIImage(contentsOfFile: path)
			labelInitials.text = nil
		} else {
			imageUser.image = UIImage(named: "selectuser_blank")
			labelInitials.text = dbuser.initials()
			downloadImage(dbuser: dbuser, tableView: tableView, indexPath: indexPath)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func downloadImage(dbuser: DBUser, tableView: UITableView, indexPath: IndexPath) {

		DownloadManager.startUser(dbuser.objectId, pictureAt: dbuser.pictureAt) { image, error in
			let indexSelf = tableView.indexPath(for: self)
			if ((indexSelf == nil) || (indexSelf == indexPath)) {
				if (error == nil) {
					self.imageUser.image = image
					self.labelInitials.text = nil
				} else if (error!.code() == 102) {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.downloadImage(dbuser: dbuser, tableView: tableView, indexPath: indexPath)
					}
				}
			}
		}
	}
}
