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
class Friend: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(userId: String) {

		let object = FObject(path: FFRIEND_PATH, subpath: FUser.currentId())

		object[FFRIEND_OBJECTID] = userId
		object[FFRIEND_FRIENDID] = userId
		object[FFRIEND_ISDELETED] = false

		object.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItem(userId: String) {

		let object = FObject(path: FFRIEND_PATH, subpath: FUser.currentId())

		object[FFRIEND_OBJECTID] = userId
		object[FFRIEND_ISDELETED] = true

		object.updateInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func isFriend(userId: String) -> Bool {

		let predicate = NSPredicate(format: "friendId == %@ AND isDeleted == NO", userId)
		let dbfriend = DBFriend.objects(with: predicate).firstObject() as? DBFriend

		return (dbfriend != nil)
	}
}
