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
class FObject: NSObject {

	private var pathX: String!
	private var subpathX: String?
	var values: [String: Any] = [:]

	// MARK: - Init methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(path: String, subpath: String?) {

		super.init()

		pathX = path
		subpathX = subpath
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(path: String) {

		self.init(path: path, subpath: nil)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(path: String, dictionary: [String: Any]) {

		self.init(path: path, subpath: nil, dictionary: dictionary)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	convenience init(path: String, subpath: String?, dictionary: [String: Any]) {

		self.init(path: path, subpath: subpath)

		for (key, value) in dictionary {
			values[key] = value
		}
	}

	// MARK: - Accessors
	//---------------------------------------------------------------------------------------------------------------------------------------------
	subscript(key: String) -> Any? {

		get {
			return values[key]
		}
		set {
			values[key] = newValue
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func objectId() -> String {

		return values["objectId"] as! String
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func objectIdInit() {

		if (values["objectId"] == nil) {
			let reference = databaseReference()
			values["objectId"] = reference.key
		}
	}

	// MARK: - Save methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveInBackground() {

		let reference = databaseReference()

		if (values["objectId"] == nil) {
			values["objectId"] = reference.key
		}

		if (values["createdAt"] == nil) {
			values["createdAt"] = ServerValue.timestamp()
		}

		values["updatedAt"] = ServerValue.timestamp()

		reference.updateChildValues(values)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveInBackground(block: @escaping (_ error: Error?) -> Void) {

		let reference = databaseReference()

		if (values["objectId"] == nil) {
			values["objectId"] = reference.key
		}

		if (values["createdAt"] == nil) {
			values["createdAt"] = ServerValue.timestamp()
		}

		values["updatedAt"] = ServerValue.timestamp()

		reference.updateChildValues(values, withCompletionBlock: { error, ref in
			block(error)
		})
	}

	// MARK: - Update methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateInBackground() {

		if (values["objectId"] != nil) {
			values["updatedAt"] = ServerValue.timestamp()

			let reference = databaseReference()
			reference.updateChildValues(values)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateInBackground(block: @escaping (_ error: Error?) -> Void) {

		if (values["objectId"] != nil) {
			values["updatedAt"] = ServerValue.timestamp()

			let reference = databaseReference()
			reference.updateChildValues(values, withCompletionBlock: { error, ref in
				block(error)
			})
		} else {
			block(NSError.description("Object cannot be updated.", code: 101))
		}
	}

	// MARK: - Delete methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func deleteInBackground() {

		if (values["objectId"] != nil) {
			let reference = databaseReference()
			reference.removeValue()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func deleteInBackground(block: @escaping (_ error: Error?) -> Void) {

		if (values["objectId"] != nil) {
			let reference = databaseReference()
			reference.removeValue(completionBlock: { error, ref in
				block(error)
			})
		} else {
			block(NSError.description("Object cannot be deleted.", code: 102))
		}
	}

	// MARK: - Fetch methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func fetchInBackground() {

		let reference = databaseReference()
		reference.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			if (snapshot.exists()) {
				if let dictionary = snapshot.value as? [String: Any] {
					self.values = dictionary
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func fetchInBackground(block: @escaping (_ error: Error?) -> Void) {

		let reference = databaseReference()
		reference.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			if (snapshot.exists()) {
				if let dictionary = snapshot.value as? [String: Any] {
					self.values = dictionary
					block(nil)
				} else {
					block(NSError.description("Object not found.", code: 103))
				}
			} else {
				block(NSError.description("Object not found.", code: 103))
			}
		})
	}

	// MARK: - Private methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func databaseReference() -> DatabaseReference {

		var reference: DatabaseReference!

		if (subpathX == nil) {
			reference = Database.database().reference(withPath: pathX)
		} else {
			reference = Database.database().reference(withPath: pathX).child(subpathX!)
		}

		if (values["objectId"] == nil) {
			return reference.childByAutoId()
		} else {
			let objectId = values["objectId"] as! String
			return reference.child(objectId)
		}
	}
}
