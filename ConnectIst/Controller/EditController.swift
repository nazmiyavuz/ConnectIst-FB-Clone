//
//  EditController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 25.02.2021.
//

import UIKit

class EditController: UITableViewController, UINavigationControllerDelegate {

    
// MARK: - Properties
    
    // code obj (to build logic of distinguishing tapped / show Cover / Ava)
    var isCoverSelected = false
    var isAvaSelected = false
    var imageViewTapped = ""
    var isPasswordChange = false
    var passwordTryToChange = false
        
// MARK: - Views
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    
    // textFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var friendsSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    

    
    
    
    
//MARK: - LifeCycle

    // first load function
    override func viewDidLoad() {
        super.viewDidLoad()

        // assign fullName to the textFields
        firstNameTextField.delegate = self
        // run func
        configure_avaImageView()
        configureGestureRecognizer()
        
        loadUser()
    }
    
    // executed after laying out the viewController
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // call functions
        configure_addBioButton()
    }
    
    
//MARK: - API
    
    // loads all user related information to be shown in the header
    func loadUser() {
        
        // safe method of accessing user related information in glob variables
        if let fullName = currentUser?.fullName {
            // assigning var which we accessed from global var, to fullNameLabel
            fullNameLabel.text = fullName.capitalized
        }
        // assigning var which we accessed from global var, to emailTextField
        if let email = currentUser?.email {
            emailTextField.text = email
        }
        // assigning var which we accessed from global var, to userNameTextField
        if let userName = currentUser?.userName {
            userNameTextField.text = userName
        }
        
        // downloading the images and assigning to certain imageViews
        if let coverPath = currentUser?.cover {
            Helper.shared.downloadImage(from: coverPath, showIn: coverImageView, orShow: #imageLiteral(resourceName: "homeCoverImage"))
        }
        if let avaPath = currentUser?.ava {
            Helper.shared.downloadImage(from: avaPath, showIn: avaImageView, orShow: #imageLiteral(resourceName: "userImage"))
        }
        
        // check is currently user allowing friendship and follow
        // manipulate switcher based on the user's settings received from the server
        if let allowFriends = currentUser?.allowFriends {
            if Int(allowFriends) == 0 {
                friendsSwitch.isOn = false
            }
        }
        
        if let allowFollow = currentUser?.allowFollow {
            if Int(allowFollow) == 0 {
                followSwitch.isOn = false
            }
        }
        
    }
    
    // update user in terms of informations that are entered by user
    func updateUser() {
        guard let id = currentUser?.id  else { return }
        
        // send notification to the server
        if isAvaSelected {
            NotificationService.sendNotification(userId: id, friendId: id, type: .ava, action: .insert)
        } else if isCoverSelected {
            NotificationService.sendNotification(userId: id, friendId: id, type: .cover, action: .insert)
        }
        
        
        let email = emailTextField.text!
        let userName = userNameTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let password = passwordTextField.text!
        // adjust front end's logic to the backend logic
        var allowFriends = 1
        if friendsSwitch.isOn == true {
            allowFriends = 1
//            print("DEBUG: Allow friends: \(allowFriends) ")
        } else {
            allowFriends = 0
//            print("DEBUG: Allow friends: \(allowFriends) ")
        }
        
        var allowFollow = 0
        if followSwitch.isOn == true {
            allowFollow = 1
//            print("DEBUG: Allow follow: \(allowFollow) ")
        } else {
            allowFollow = 0
//            print("DEBUG: Allow follow: \(allowFollow) ")
        }
        
        // logic of validation
        if Helper.shared.isValid(email: email) == false {
            Helper.shared.showAlert(title: "Invalid E-mail", message: "Please use valid E-mail address", in: self)
            return
        } else if Helper.shared.isValid(userName: userName) == false {
            Helper.shared.showAlert(title: "Invalid username", message: "Please use valid username", in: self)
            return
        } else if Helper.shared.isValid(name: firstName) == false {
            Helper.shared.showAlert(title: "Invalid name", message: "Please use valid name", in: self)
            return
        } else if Helper.shared.isValid(name: lastName) == false {
            Helper.shared.showAlert(title: "Invalid surname", message: "Please use valid surname", in: self)
            return
        } else {
            
            if passwordTryToChange {
                if password.count < 6 {
                    Helper.shared.showAlert(title: "Invalid Password", message: "Password must contain at least 6 characters", in: self)
                    return
                } else {
                    UserService.shared.updateUser(id: id, email: email, userName: userName, firstName: firstName,
                                                  lastName: lastName, password: password, isPasswordChanged: true,
                                                  allowFriends: allowFriends, allowFollow: allowFollow,
                                                  selfVC: self)
                    // call update images according to the user info
                    updateImages()
                    saveNotificationObserver()
                }
            } else {
                
                UserService.shared.updateUser(id: id, email: email, userName: userName, firstName: firstName,
                                              lastName: lastName, password: password, isPasswordChanged: false,
                                              allowFriends: allowFriends, allowFollow: allowFollow,
                                              selfVC: self)
                // call update images according to the user info
                updateImages()
                saveNotificationObserver()
            }
        }
        
    }
    
    func updateImages() {
        
        // upload files
        if isAvaSelected {
            ImageUploader.shared.updateImage(from: avaImageView, imageViewTapped: "ava",
                                      isAvaTrue: true, isCoverTrue: false, selfVC: self)
            Helper.shared.saveIsAva(true)
//            helper.showAlert(title: "Success!", message: "Ava has been updated", in: self)
        }
        
        if isCoverSelected {
            ImageUploader.shared.updateImage(from: coverImageView, imageViewTapped: "cover",
                                      isAvaTrue: false, isCoverTrue: true, selfVC: self)
            Helper.shared.saveIsCover(true)
        }
    }
    
    // to call new informations on HomeController
    func saveNotificationObserver() {
        // sending notification to other vcs
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBio"), object: nil)
    }
    
// MARK: - Action
    
    // go back to the HomeController
    @IBAction func cancelButton_clicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // save changed informations of current user
    @IBAction func saveButton_clicked(_ sender: UIBarButtonItem) {
        // run func
        updateUser()
        print("DEBUG: Save button pressed..")
        
    }
    
    // executed when Cover is tapped
    @objc func coverImageView_tapped() {
        // switching trigger
        imageViewTapped = "cover"
        
        // launch action sheet calling function
        showActionSheet()
    }
    
    // executed when Ava is tapped
    @objc func avaImageView_tapped() {
        // switching trigger
        imageViewTapped = "ava"
        // launch action sheet calling function
        showActionSheet()
        
    }
    
    // go to BioController
    @IBAction func addBioButton_clicked(_ sender: UIButton) {
        let controller = UINavigationController(rootViewController: BioController())
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    // executed whenever connected textField has been changed
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        passwordTryToChange = true
        print("DEBUG: trying change")
        if textField == passwordTextField && passwordTextField.text!.count > 5 {
            isPasswordChange = true
        } else if textField == passwordTextField && passwordTextField.text!.count <= 5 {
            isPasswordChange = false
        }
    }
    
    
// MARK: - Helpers
    
    // configuring the appearance of AvaImageView
    func configure_avaImageView() {
        
        // creating layer that will be applying avaImageView (layer - borders of ava)
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: avaImageView.frame.size.width, height: avaImageView.frame.size.height)
        avaImageView.layer.addSublayer(border)
        
        avaImageView.layer.cornerRadius = 10
        avaImageView.layer.masksToBounds = true
        avaImageView.clipsToBounds = true
    }
    
    func configure_addBioButton() {
        
        let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
//        border.borderColor = UIColor(red: 68/255, green: 105/255, blue: 176/255, alpha: 1).cgColor
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: addBioButton.frame.width, height: addBioButton.frame.height)
        
        // assign border to the obj (button)
        addBioButton.layer.addSublayer(border)
        
        // rounded corner
        addBioButton.layer.cornerRadius = 5
        addBioButton.layer.masksToBounds = true
//        addBioButton.clipsToBounds = true
    }
    
    // declare gesture recognizer to show imagePicker
    func configureGestureRecognizer() {
        
        // handle gesture recognizer to change COVER image
        let gestureA = UITapGestureRecognizer(target: self, action:  #selector(coverImageView_tapped) )
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(gestureA)
        
        // handle gesture recognizer to change AVA image
        let gestureB = UITapGestureRecognizer(target: self, action:  #selector(avaImageView_tapped) )
        avaImageView.isUserInteractionEnabled = true
        avaImageView.addGestureRecognizer(gestureB)
        
        
        
    }
    
    
// MARK: - ActionSheet
    
    // takes us to PickerController (Controller that allows us to select picture)
    private func showPicker(with source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
        
    }
    

    // this function launches action sheet for the photos.
    private func showActionSheet() {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring camera button
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            // if camera available device then show
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.showPicker(with: .camera)
            }
        }
        
        // declaring library button
        let library = UIAlertAction(title: "Library", style: .default) { (action) in
            
            // checking availability of photo library
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                self.showPicker(with: .photoLibrary)
            }
        }
                
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        // declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // deleting profile picture (ava), by returning placeholder
            if self.imageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "userImage")
                Helper.shared.saveIsAva(false)
            } else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "homeCoverImage")
                Helper.shared.saveIsCover(false)
            }
        }
        
        // manipulating appearance of delete button for each scenarios
        if imageViewTapped == "ava" && isAva == false {
            delete.isEnabled = false
        } else if imageViewTapped == "cover" && isCover == false {
            delete.isEnabled = false
        }
        
        // adding buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        sheet.addAction(delete)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
    }
    
}



// MARK:- ImagePickerControlerDelegate

extension EditController: UIImagePickerControllerDelegate {
    
    // executed once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        // access image selected from pickerController
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        
        // based on the trigger we are assigning selected pictures to the appropriated imageView
        if imageViewTapped == "cover" {
            // assign selected image to CoverImageView
            self.coverImageView.image = image
            
            
        } else if imageViewTapped == "ava" {
            // assign selected image to AvaImageView
            self.avaImageView.image = image
            
        }
        
        // completion handler, to communicate to the project that images has been selected (enable delete button)
        dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCoverSelected = true
                print("DEBUG: isCoverSelected: \(self.isCoverSelected)")
                print("DEBUG: isAvaSelected: \(self.isAvaSelected)")
            } else if self.imageViewTapped == "ava" {
                self.isAvaSelected = true
                print("DEBUG: isAvaSelected: \(self.isAvaSelected)")
                print("DEBUG: isCoverSelected: \(self.isCoverSelected)")
            }
        }
    }
}




// MARK: - UITextFieldDelegate

extension EditController: UITextFieldDelegate {
    
    // It is called when text field activated in order to delete the text of the fullNameLabel
    func textFieldDidBeginEditing(_ textField: UITextField) {
        fullNameLabel.text = ""
    }
    
}




// MARK: - UITableViewDataSource

extension EditController {
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 100
//    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        var array = [Int]()
//
//        for num in 1...100 {
//            array.append(num)
//        }
//        let num = array[indexPath.row]
//        cell.textLabel?.text = "\(num). Cell"
//        cell.backgroundColor = .systemGray5
//        return cell
//    }
}
