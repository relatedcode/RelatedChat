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
class Blocker: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(userId: String) {

		let object = FObject(path: FBLOCKER_PATH, subpath: userId)

		object[FBLOCKER_OBJECTID] = FUser.currentId()
		object[FBLOCKER_BLOCKERID] = FUser.currentId()
		object[FBLOCKER_ISDELETED] = false

		object.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItem(userId: String) {

		let object = FObject(path: FBLOCKER_PATH, subpath: userId)

		object[FBLOCKER_OBJECTID] = FUser.currentId()
		object[FBLOCKER_BLOCKERID] = FUser.currentId()
		object[FBLOCKER_ISDELETED] = true

		object.updateInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func isBlocker(userId: String) -> Bool {

		let predicate = NSPredicate(format: "blockerId == %@ AND isDeleted == NO", userId)
		let dbblocker = DBBlocker.objects(with: predicate).firstObject() as? DBBlocker

		return (dbblocker != nil)
	}
}
