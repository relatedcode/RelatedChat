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
class EditProfileView: UIViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var viewHeader: UIView!
	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var cellFirstname: UITableViewCell!
	@IBOutlet var cellLastname: UITableViewCell!
	@IBOutlet var cellCountry: UITableViewCell!
	@IBOutlet var cellLocation: UITableViewCell!
	@IBOutlet var cellPhone: UITableViewCell!
	@IBOutlet var fieldFirstname: UITextField!
	@IBOutlet var fieldLastname: UITextField!
	@IBOutlet var labelPlaceholder: UILabel!
	@IBOutlet var labelCountry: UILabel!
	@IBOutlet var fieldLocation: UITextField!
	@IBOutlet var fieldPhone: UITextField!

	private var isOnboard = false

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(isOnboard isOnboard_: Bool) {

		super.init(nibName: nil, bundle: nil)

		isOnboard = isOnboard_
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Edit Profile"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tableView.addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.cancelsTouchesInView = false

		tableView.tableHeaderView = viewHeader

		loadUser()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		dismissKeyboard()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func dismissKeyboard() {

		view.endEditing(true)
	}

	// MARK: - Backend actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadUser() {

		let user = FUser.currentUser()

		labelInitials.text = user.initials()
		DownloadManager.startUser(user.objectId(), pictureAt: user.pictureAt()) { image, error in
			if (error == nil) {
				self.imageUser.image = image
				self.labelInitials.text = nil
			}
		}

		fieldFirstname.text = user[FUSER_FIRSTNAME] as? String
		fieldLastname.text = user[FUSER_LASTNAME] as? String

		labelCountry.text = user[FUSER_COUNTRY] as? String
		fieldLocation.text = user[FUSER_LOCATION] as? String

		fieldPhone.text = user[FUSER_PHONE] as? String

		fieldPhone.isUserInteractionEnabled = (user.loginMethod() != LOGIN_PHONE)

		updateDetails()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveUser(firstname: String, lastname: String, country: String, location: String, phone: String) {

		let user = FUser.currentUser()

		user[FUSER_FIRSTNAME] = firstname
		user[FUSER_LASTNAME] = lastname
		user[FUSER_FULLNAME] = "\(firstname) \(lastname)"
		user[FUSER_COUNTRY] = country
		user[FUSER_LOCATION] = location
		user[FUSER_PHONE] = phone

		user.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveUserPictureAt() {

		let user = FUser.currentUser()
		user[FUSER_PICTUREAT] = ServerValue.timestamp()
		user.saveInBackground(block: { error in
			if (error == nil) {
				user.fetchInBackground()
			} else {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCancel() {

		if (isOnboard) {
			Userx.logout()
		}
		dismiss(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		let firstname = fieldFirstname.text ?? ""
		let lastname = fieldLastname.text ?? ""
		let country = labelCountry.text ?? ""
		let location = fieldLocation.text ?? ""
		let phone = fieldPhone.text ?? ""

		if (firstname.count == 0)	{ ProgressHUD.showError("Firstname must be set.");		return	}
		if (lastname.count == 0)	{ ProgressHUD.showError("Lastname must be set.");		return	}
		if (country.count == 0)		{ ProgressHUD.showError("Country must be set.");		return	}
		if (location.count == 0)	{ ProgressHUD.showError("Location must be set.");		return	}
		if (phone.count == 0)		{ ProgressHUD.showError("Phone number must be set.");	return	}

		saveUser(firstname: firstname, lastname: lastname, country: country, location: location, phone: phone)

		dismiss(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPhoto(_ sender: Any) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Open Camera", style: .default, handler: { action in
			ImagePicker.cameraPhoto(target: self, edit: true)
		}))
		alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
			ImagePicker.photoLibrary(target: self, edit: true)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCountries() {

		let countriesView = CountriesView()
		countriesView.delegate = self
		let navController = NavigationController(rootViewController: countriesView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func uploadUserPicture(image: UIImage) {

		let squared = Image.square(image: image, size: 300)
		if let data = image.jpegData(compressionQuality: 0.6) {
			UploadManager.user(FUser.currentId(), data: data, completion: { error in
				if (error == nil) {
					DownloadManager.saveUser(FUser.currentId(), data: data)
					self.labelInitials.text = nil
					self.imageUser.image = squared
					self.saveUserPictureAt()
				} else {
					ProgressHUD.showError("Picture upload error.")
				}
			})
		}
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails() {

		labelPlaceholder.isHidden = labelCountry.text != nil
	}
}

// MARK: - UIImagePickerControllerDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		if let image = info[.editedImage] as? UIImage {
			uploadUserPicture(image: image)
		}
		picker.dismiss(animated: true)
	}
}

// MARK: - CountriesDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: CountriesDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectCountry(name: String, code: String) {

		labelCountry.text = name
		fieldLocation.becomeFirstResponder()
		updateDetails()
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 2
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 4 }
		if (section == 1) { return 1 }

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellFirstname	}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellLastname	}
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellCountry	}
		if (indexPath.section == 0) && (indexPath.row == 3) { return cellLocation	}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellPhone		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 2) { actionCountries()		}
	}
}

// MARK: - UITextFieldDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension EditProfileView: UITextFieldDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if (textField == fieldFirstname)	{ fieldLastname.becomeFirstResponder()	}
		if (textField == fieldLastname)		{ actionCountries()						}
		if (textField == fieldLocation)		{ fieldPhone.becomeFirstResponder()		}
		if (textField == fieldPhone)		{ actionDone()							}

		return true
	}
}
