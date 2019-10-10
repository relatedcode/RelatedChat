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
class Userx: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func logout() {

		resignOneSignalId()
		updateLastTerminate(fetch: false)

		if (FUser.logOut()) {
			CacheManager.cleanupManual(logout: true)
			RealmManager.cleanupDatabase()
			NotificationCenter.post(notification: NOTIFICATION_USER_LOGGED_OUT)
		} else {
			ProgressHUD.showError("Logout error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func login(target: Any) {

		let viewController = target as! UIViewController
		let welcomeView = WelcomeView()
		if #available(iOS 13.0, *) {
			welcomeView.isModalInPresentation = true
			welcomeView.modalPresentationStyle = .fullScreen
		}
		viewController.present(welcomeView, animated: true) {
			viewController.tabBarController?.selectedIndex = Int(DEFAULT_TAB)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func onboard(target: Any) {

		let viewController = target as! UIViewController
		let editProfileView = EditProfileView(isOnboard: true)
		let navController = NavigationController(rootViewController: editProfileView)
		if #available(iOS 13.0, *) {
			navController.isModalInPresentation = true
			navController.modalPresentationStyle = .fullScreen
		}
		viewController.present(navController, animated: true)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loggedIn(loginMethod: String) {

		updateSettings(loginMethod)
		updateOneSignalId()
		updateLastActive()

		if (FUser.isOnboardOk()) {
			ProgressHUD.showSuccess("Welcome back!")
		} else {
			ProgressHUD.showSuccess("Welcome!")
		}

		NotificationCenter.post(notification: NOTIFICATION_USER_LOGGED_IN)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func updateSettings(_ loginMethod: String) {

		var update = false
		let user = FUser.currentUser()

		if (user[FUSER_STATUS] as? String == nil)		{ update = true; user[FUSER_STATUS] = "Available"			}

		if (user[FUSER_KEEPMEDIA] as? Int == nil)		{ update = true; user[FUSER_KEEPMEDIA] = KEEPMEDIA_FOREVER	}
		if (user[FUSER_NETWORKPHOTO] as? Int == nil)	{ update = true; user[FUSER_NETWORKPHOTO] = NETWORK_ALL		}
		if (user[FUSER_NETWORKVIDEO] as? Int == nil)	{ update = true; user[FUSER_NETWORKVIDEO] = NETWORK_ALL		}
		if (user[FUSER_NETWORKAUDIO] as? Int == nil)	{ update = true; user[FUSER_NETWORKAUDIO] = NETWORK_ALL		}

		if (user[FUSER_LOGINMETHOD] as? String == nil)	{ update = true; user[FUSER_LOGINMETHOD] = loginMethod		}

		if (user[FUSER_LASTACTIVE] as? Int64 == nil)	{ update = true; user[FUSER_LASTACTIVE] = 0					}
		if (user[FUSER_LASTTERMINATE] as? Int64 == nil)	{ update = true; user[FUSER_LASTTERMINATE] = 0				}

		if (user[FUSER_PICTUREAT] as? Int64 == nil)		{ update = true; user[FUSER_PICTUREAT] = 0					}

		if (update) {
			user.saveInBackground()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateOneSignalId() {

		if (FUser.currentId() != "") {
			if let oneSignalId = UserDefaults.string(key: ONESIGNALID) {
				assignOneSignalId(oneSignalId)
			} else {
				resignOneSignalId()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func assignOneSignalId(_ oneSignalId: String) {

		if (FUser.oneSignalId() != oneSignalId) {
			let user = FUser.currentUser()
			user[FUSER_ONESIGNALID] = oneSignalId
			user.saveInBackground()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func resignOneSignalId() {

		if (FUser.oneSignalId() != "") {
			let user = FUser.currentUser()
			user[FUSER_ONESIGNALID] = ""
			user.saveInBackground()
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateLastActive() {

		if (FUser.currentId() != "") {
			let user = FUser.currentUser()
			user[FUSER_LASTACTIVE] = ServerValue.timestamp()
			user.saveInBackground(block: { error in
				user.fetchInBackground()
			})
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateLastTerminate(fetch: Bool) {

		if (FUser.currentId() != "") {
			let user = FUser.currentUser()
			user[FUSER_LASTTERMINATE] = ServerValue.timestamp()
			user.saveInBackground(block: { error in
				if (fetch) {
					user.fetchInBackground()
				}
			})
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func lastActive(dbuser: DBUser) -> String {

		if (Blocker.isBlocker(userId: dbuser.objectId) == false) {
			if (dbuser.lastActive < dbuser.lastTerminate) {
				let elapsed = Convert.timestampToElapsed(dbuser.lastTerminate)
				return "last active: \(elapsed)"
			}
			return "online now"
		}
		return ""
	}
}
