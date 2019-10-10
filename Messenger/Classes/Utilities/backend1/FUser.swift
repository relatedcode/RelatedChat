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
class FUser: FObject {

	// MARK: - Class methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func currentId() -> String {

		if let currentUser = Auth.auth().currentUser {
			return currentUser.uid
		}
		return ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func currentUser() -> FUser {

		if let dictionary = UserDefaults.standard.object(forKey: "CurrentUser") as? [String: Any] {
			return FUser(path: "User", dictionary: dictionary)
		}
		return FUser(path: "User")
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func userWithId(userId: String) -> FUser {

		let user = FUser(path: "User")
		user["objectId"] = userId
		return user
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func signIn(email: String, password: String, completion: @escaping (_ user: FUser?, _ error: Error?) -> Void) {

		Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
			if (error == nil) {
				let firuser = authResult!.user
				FUser.load(firuser: firuser) { user, error in
					if (error == nil) {
						completion(user, nil)
					} else {
						try? Auth.auth().signOut()
						completion(nil, error)
					}
				}
			} else {
				completion(nil, error)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createUser(email: String, password: String, completion: @escaping (_ user: FUser?, _ error: Error?) -> Void) {

		Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
			if (error == nil) {
				let firuser = authResult!.user
				FUser.create(uid: firuser.uid, email: email) { user, error in
					if (error == nil) {
						completion(user, nil)
					} else {
						firuser.delete(completion: { error in
							if (error != nil) {
								try? Auth.auth().signOut()
							}
						})
						completion(nil, error)
					}
				}
			} else {
				completion(nil, error)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func signIn(credential: AuthCredential, completion: @escaping (_ user: FUser?, _ error: Error?) -> Void) {

		Auth.auth().signIn(with: credential) { authResult, error in
			if (error == nil) {
				let firuser = authResult!.user
				FUser.load(firuser: firuser) { user, error in
					if (error == nil) {
						completion(user, nil)
					} else {
						try? Auth.auth().signOut()
						completion(nil, error)
					}
				}
			} else {
				completion(nil, error)
			}
		}
	}

	// MARK: - Logut methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@discardableResult class func logOut() -> Bool {

		do {
			try Auth.auth().signOut()
			UserDefaults.standard.removeObject(forKey: "CurrentUser")
			UserDefaults.standard.synchronize()
			return true
		} catch {
			return false
		}
	}

	// MARK: - Private methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func load(firuser: User, completion: @escaping (_ user: FUser?, _ error: Error?) -> Void) {

		let user = FUser.userWithId(userId: firuser.uid)

		user.fetchInBackground(block: { error in
			if (error != nil) {
				self.create(uid: firuser.uid, email: firuser.email, completion: completion)
			} else {
				completion(user, nil)
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func create(uid: String, email: String?, completion: @escaping (_ user: FUser?, _ error: Error?) -> Void) {

		let user = FUser.userWithId(userId: uid)

		if (email != nil) {
			user["email"] = email!
		}

		user.saveInBackground(block: { error in
			if (error == nil) {
				completion(user, nil)
			} else {
				completion(nil, error)
			}
		})
	}

	// MARK: - Instance methods
	// MARK: - Current user methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func isCurrent() -> Bool {
		
		if let objectId = self["objectId"] as? String {
			return (objectId == FUser.currentId())
		}
		return false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveLocalIfCurrent() {

		if (isCurrent()) {
			UserDefaults.standard.set(values, forKey: "CurrentUser")
			UserDefaults.standard.synchronize()
		}
	}

	// MARK: - Save methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func saveInBackground() {

		saveLocalIfCurrent()
		super.saveInBackground()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func saveInBackground(block: @escaping (_ error: Error?) -> Void) {

		saveLocalIfCurrent()
		super.saveInBackground(block: { error in
			if (error == nil) {
				self.saveLocalIfCurrent()
			}
			block(error)
		})
	}

	// MARK: - Fetch methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func fetchInBackground() {

		super.fetchInBackground(block: { error in
			if (error == nil) {
				self.saveLocalIfCurrent()
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func fetchInBackground(block: @escaping (_ error: Error?) -> Void) {

		super.fetchInBackground(block: { error in
			if (error == nil) {
				self.saveLocalIfCurrent()
			}
			block(error)
		})
	}
}
