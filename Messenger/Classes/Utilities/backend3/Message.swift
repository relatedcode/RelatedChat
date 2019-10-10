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
class Message: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItem(dbmessage: DBMessage) {

		if (dbmessage.status == STATUS_SENT) {
			deleteItemSent(dbmessage: dbmessage)
		}
		if (dbmessage.status == STATUS_QUEUED) {
			deleteItemQueued(dbmessage: dbmessage)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItemSent(dbmessage: DBMessage) {

		let object = FObject(path: FMESSAGE_PATH, subpath: FUser.currentId())

		object[FMESSAGE_OBJECTID] = dbmessage.objectId
		object[FMESSAGE_ISDELETED] = true

		object.updateInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItemQueued(dbmessage: DBMessage) {

		dbmessage.updateItem(isDeleted: true)

		NotificationCenter.post(notification: NOTIFICATION_REFRESH_MESSAGES1)
	}
}
