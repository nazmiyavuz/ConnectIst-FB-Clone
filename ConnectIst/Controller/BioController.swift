//
//  BioVC.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 21.02.2021.
//

import UIKit

class BioController: UIViewController {
    
    // MARK: - Properties
    
    
    
    
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
    
    
    // create text view under profile imageView to post bio\
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: K.Font.helveticaNeue, size: 15)
//        tv.layer.borderWidth = 1
//        tv.layer.borderColor = UIColor.systemGray.cgColor
        tv.textAlignment = NSTextAlignment.justified
        return tv
    }()
    
    // create placeholderLabel inside the textView
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "What's on your mind?"
        label.font = UIFont(name: K.Font.helveticaNeue, size: 15)
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

    
    
    
    //MARK: - LifeCycle

    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()

        // run func
        configureUI()
        configureNavBar()
        loadUser()
    }
    
    
    //MARK: - API
    
    // loads all user related information to be shown in the header
    func loadUser() {
        // safe method of accessing user related information in glob variables
        if let fullName = currentUser?.fullName {
            // assigning vars which we accessed from global var, to fullNameLabel
            nameLabel.text = fullName.capitalized
        }
        
        // downloading the images and assigning to certain imageViews
        if let avaPath = currentUser?.ava {
            Helper().downloadImage(from: avaPath, showIn: avaImageView, orShow: #imageLiteral(resourceName: "userImage"))
        }
       
    }
    
    
    // MARK: - Action
    
    // cancel button has been clicked
    @objc func cancelButton_clicked() {
        dismiss(animated: true, completion: nil)
    }
    
    // runs when save button has been clicked
    @objc func saveButton_clicked() {
        guard let bio = textView.text else { return }
        
        // run update function if there are no whiteLines and whiteSpaces
        if textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false {
            BioUploader().updateBio(bioText: bio, selfVC: self) { (error) in
                if let error = error {
                    print("DEBUG: Failed to log user in \(error.localizedDescription)")
                    return
                }

            }
            
            
        }
        
        
    }
    
    // MARK: - Helpers
    
    // declaring UI obj auto layout properties
    private func configureUI() {
        view.backgroundColor = .white
        textView.delegate = self
        
        // add profile imageView under view and declare its auto layout
        view.addSubview(avaImageView)
        avaImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                                paddingTop: 10, paddingLeft: 20)
        avaImageView.setDimensions(height: 50, width: 50)
        avaImageView.layer.cornerRadius = 50 / 2
        
        // add name label near the profileImageView and its layouts
        view.addSubview(nameLabel)
        nameLabel.centerY(inView: avaImageView, leftAnchor: avaImageView.rightAnchor, paddingLeft: 5)
        
        // add bio textView and declare its layouts
        view.addSubview(textView)
        textView.anchor(top: avaImageView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                        right: view.safeAreaLayoutGuide.rightAnchor,
                        paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 70)
        
        view.addSubview(placeholderLabel)
        placeholderLabel.anchor(top: textView.topAnchor, left: textView.leftAnchor,
                                paddingTop: 8, paddingLeft: 5)
        
        // deploy counter label auto layout
        view.addSubview(counterLabel)
        counterLabel.anchor(top: textView.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,
                            paddingTop: 5, paddingRight: 20)
    }
    
    // configure the navigation bar
    func configureNavBar() {
        // add left bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelButton_clicked))
        // create a right bar button
        let saveButton = UIBarButtonItem(title: "Save",
                                        style: .plain,
                                        target: self,
                                        action: #selector(saveButton_clicked))
        
        // adding right bar button items. I did this style to show different options while creating bar buttons.
        navigationItem.rightBarButtonItems = [saveButton]
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationItem.rightBarButtonItems![0].tintColor = .systemBlue
        navigationItem.title = "Edit Bio"
        
    }
    
}

// MARK: - UITextFieldDelegate

extension BioController: UITextViewDelegate {
    
    // executed whenever we are typing some text in the textview object which has delegate relation with the viewController.
    func textViewDidChange(_ textView: UITextView) {
        
        // calculation of characters
        let allowed = 101
        let typed = textView.text.count
        let remaining = allowed - typed
        counterLabel.text = "\(remaining)/101"
        
        // if some text is in textView -> hide placeholder, otherwise, show it
        placeholderLabel.isHidden = textView.text.isEmpty == true ? false : true
        
    }
    
    // this func executed firstly whenever textView is about to be changed. return TRUE -> allow change,, return FALSE -> do not allow
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // do not allowed white lines (brakes)
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else { return false }
        
        // stop entry while 101 characters
        return textView.text.count + (text.count - range.length) <= 101
        
    }
    
    
}
