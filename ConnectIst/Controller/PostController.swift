//
//  PostController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 23.02.2021.
//

import UIKit

class PostController: UIViewController, UINavigationControllerDelegate {

    
// MARK: - Properties
    
    var isPictureSelected = false
    
// MARK: - Views
 
    // create profile image view to show the AVA image of any user who is shown in the screen
    private let avaImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "userImage"))
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    // create name and lastName label near the profile imageView
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Firstname Lastname"
        label.font = UIFont(name: K.Font.helveticaNeue_bold, size: 21)
        return label
    }()
    
    // create add Save button
    private let addPictureButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add picture", for: .normal)
        btn.titleLabel?.font = UIFont(name: K.Font.helveticaNeue_medium, size: 17)
        btn.addTarget(self, action: #selector(addPictureButton_clicked), for: .touchUpInside)
        return btn
    }()
    
    
    // create text view under profile imageView to post bio\
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: K.Font.helveticaNeue, size: 20)
//        tv.layer.borderWidth = 1
//        tv.layer.borderColor = UIColor.systemGray.cgColor
        tv.textAlignment = NSTextAlignment.justified
        return tv
    }()
    
    // create placeholderLabel inside the textView
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "What's new?"
        label.font = UIFont(name: K.Font.helveticaNeue, size: 20)
        label.textColor = .lightGray
        return label
    }()
    
    // create counter label under the textView
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.text = "101/101"
        label.font = UIFont(name: K.Font.helveticaNeue, size: 15)
        return label
    }()
    
    // create post image view to show the COVER image of any user who is shown in the screen
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // create Cancel button
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.addTarget(self, action: #selector(cancelButton_clicked), for: .touchUpInside)
        return btn
    }()
    
//MARK: - LifeCycle

    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        // declare navigation bar
        configureNavBar()
        loadUser()
        configureGestureRecognizer()
        
    }
    
    
//MARK: - API
    
    // loads all user related information to be shown in the header
    func loadUser() {
        DispatchQueue.main.async {
            // safe method of accessing user related information in glob variables
            if let fullName = currentUser?.fullName {
                // assigning vars which we accessed from global var, to fullNameLabel
                self.nameLabel.text = fullName.capitalized
            }
            
            // downloading the images and assigning to certain imageViews
            if let avaPath = currentUser?.ava {
                Helper.shared.downloadImage(from: avaPath, showIn: self.avaImageView, orShow: #imageLiteral(resourceName: "userImage"))
            }
        }
    }
    
// MARK: - Action
    
    // cancel button has been clicked
    @objc func cancelButton_clicked() {
        dismiss(animated: true, completion: nil)
    }
    
    // once the button Share has been pressed
    @objc func shareButton_clicked() {
        guard let text = textView.text else { return }
        
        PostService.shared.uploadPost(from: postImageView, text: text, isSelectedPicture: isPictureSelected, selfVC: self)
        
        
            
    }
    
    // launched when addPicture has been clicked
    @objc func addPictureButton_clicked() {
        print("DEBUG: addPictureButton_clicked..")
        showActionSheet()
        
    }
    
    // execute when postImageView has been tapped
    @objc func postImageView_tapped() {
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.postImageView.image = UIImage()
            
        }
        
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // adding buttons to the sheet
        sheet.addAction(delete)
        sheet.addAction(cancel)
        
        
        self.present(sheet, animated: true, completion: nil)
        
        
        
    }
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        textView.resignFirstResponder()
    }
    
    
// MARK: - Helpers
    
    
    // declaring UI obj auto layout properties
    private func configureUI() {
        view.backgroundColor = .white
        // declare delegation of UITextViewDelegate
        textView.delegate = self
        
        
        // add profile imageView under view and declare its auto layout
        view.addSubview(avaImageView)
        avaImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                            paddingTop: 20, paddingLeft: 20)
        avaImageView.setDimensions(height: 50, width: 50)
        avaImageView.layer.cornerRadius = 50 / 2
        
        // add name label near the profileImageView and its layouts
        view.addSubview(addPictureButton)
        addPictureButton.centerY(inView: avaImageView, rightAnchor: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        // add name label near the profileImageView and its layouts
        view.addSubview(nameLabel)
        nameLabel.centerY(inView: avaImageView, leftAnchor: avaImageView.rightAnchor, paddingLeft: 5)
        
//        // add name label near the profileImageView and its layouts
//        view.addSubview(addPictureButton)
//        addPictureButton.centerY(inView: avaImageView, rightAnchor: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        // add bio textView and declare its layouts
        view.addSubview(textView)
        textView.anchor(top: avaImageView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                        right: view.safeAreaLayoutGuide.rightAnchor,
                        paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 150)
        
        view.addSubview(placeholderLabel)
        placeholderLabel.anchor(top: textView.topAnchor, left: textView.leftAnchor,
                                paddingTop: 8, paddingLeft: 5)
        
        // deploy counter label auto layout
        view.addSubview(postImageView)
        postImageView.anchor(top: textView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,
                             paddingTop: 10, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        
    }
        
    // configure the navigation bar
    func configureNavBar() {
        // add left bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelButton_clicked))
        // create a right bar button
        let shareButton = UIBarButtonItem(title: "Share",
                                        style: .plain,
                                        target: self,
                                        action: #selector(shareButton_clicked))
        
        // adding right bar button items. I did this style to show different options while creating bar buttons.
        navigationItem.rightBarButtonItems = [shareButton]
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationItem.rightBarButtonItems![0].tintColor = .systemBlue
        navigationItem.title = "Create Post"
        
    }
    
    // declare gesture recognizer to show imagePicker
    func configureGestureRecognizer() {
        
        // handle gesture recognizer to change COVER image
        let gestureA = UITapGestureRecognizer(target: self, action:  #selector(postImageView_tapped) )
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(gestureA)
        
        
        
    }
    
    
    // MARK: - ActionSheets
    // this function launches action sheet for the photos.
    func showActionSheet() {
        
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
        
        
        
        // adding buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
    }
    
    // takes us to PickerController (Controller that allows us to select picture)
    func showPicker(with source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
        
    }
}
    

// MARK: - UITextFieldDelegate

extension PostController: UITextViewDelegate {
    
    // executed whenever we are typing some text in the textview object which has delegate relation with the viewController.
    func textViewDidChange(_ textView: UITextView) {
        
        // if some text is in textView -> hide placeholder, otherwise, show it
        placeholderLabel.isHidden = textView.text.isEmpty == true ? false : true
        
    }
    
}

// MARK:- ImagePickerControlerDelegate

extension PostController: UIImagePickerControllerDelegate {
    
    // executed whenever the image has been picked via pickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // access image selected from pickerController
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        
        // assigning selected image to pictureImageView
        postImageView.image = image
        
        // cast boolean as TRUE -> picture is selected
        isPictureSelected = true
        
        // remove picker controller
        dismiss(animated: true, completion: nil)
        
    }
}
