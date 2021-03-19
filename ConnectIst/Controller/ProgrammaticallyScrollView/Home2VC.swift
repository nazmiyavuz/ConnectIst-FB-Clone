//
//  HomeVc.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 17.02.2021.
//

import UIKit

class Home2VC: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate {

    // MARK: - Properties
    
    // code obj (to build logic of distinguishing tapped / show Cover / Ava)
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    
    
    
    
    // MARK: - Views
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.backgroundColor = .white
        sv.autoresizingMask = .flexibleHeight
        sv.showsVerticalScrollIndicator = false
        sv.bounces = true
        return sv
    }()
    
    
    private let containerView = UIView()
        
    // declare upper view in order to insert uiViews inside
    private let upperView = UIView()
    
    // create cover image view to show the COVER image of any user who is shown in the screen
    private let coverImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "homeCoverImage"))
        iv.contentMode = .scaleToFill
        iv.setHeight(207)
        return iv
    }()
    
    // create ava image view to show the AVA image of any user who is shown in the screen
    private let avaImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "userImage"))
        iv.contentMode = .scaleAspectFit
        iv.layer.borderWidth = 5
        iv.layer.borderColor = UIColor.white.cgColor
        iv.setDimensions(height: 150, width: 150)
        // round corner
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        return iv
    }()
    
    // create name and lastName label under the ava imageView
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Firstname Lastname"
        label.font = UIFont(name: K.Label.Font.homeName, size: 21)
        return label
    }()
    
    // create add tamporary bio button
    private let temporaryBioButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add temporary bio", for: .normal)
        return btn
    }()
    
    // create post button
    private let postButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.createSmallBtnHomeScreen(image: #imageLiteral(resourceName: "postImage"))
        return btn
    }()
    
    // create edit button
    private let editButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.createSmallBtnHomeScreen(image: #imageLiteral(resourceName: "editImage"))
        return btn
    }()
    
    // create log button
    private let logButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.createSmallBtnHomeScreen(image: #imageLiteral(resourceName: "logImage"))
        return btn
    }()
    
    // create more button
    private let moreButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.createSmallBtnHomeScreen(image: #imageLiteral(resourceName: "moreImage"))
        return btn
    }()
    
    // create tableView
    private let tableView = UITableView()
    
    // create more button
    private let pageUpButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "chevron.up.square"), for: .normal)
        btn.setDimensions(height: 30, width: 30)
        btn.addTarget(self, action: #selector(handleGoPageUp), for: .touchUpInside)
        return btn
    }()
    
    
    //MARK: - LifeCycle

    // executed once the Auto-Layout has been applied / executed
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tableView.dataSource = self
        tableView.delegate = self
        scrollView.delegate = self
    }
    
    // executed EVERYTIME when view will appear to the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    //MARK: - API
    
    
    
    // MARK: - Action
    
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
    // handle up function to go the upper part of the screen for looking pictures
    @objc func handleGoPageUp() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // MARK: - Helpers
    
    // declaring UI obj auto layout properties
    private func configureUI() {
        // hide navigation bar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = true
     
        // fetch the screen height and width
        let screenWidth = self.view.frame.width
        
        let contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 450)
        
        // declare scrollView attributes and autoLayout
        scrollView.frame = view.bounds
        scrollView.contentSize = contentViewSize
        view.addSubview(scrollView)
        
        // adding container view and declare size attribute
        containerView.frame.size = contentViewSize
        scrollView.addSubview(containerView)
        
        // adding upperView under containerView and declaring its auto layout
        containerView.addSubview(upperView)
        upperView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor)
        upperView.setHeight(500)
        
        // adding coverImageView under upperView and declaring its auto layout
        upperView.addSubview(coverImageView)
        coverImageView.anchor(top: upperView.topAnchor, left: upperView.leftAnchor, right: upperView.rightAnchor)
        coverImageView.setWidth(screenWidth)
        
        // adding avaImageView under upperView and declaring its auto layout
        scrollView.addSubview(avaImageView)
        avaImageView.centerX(inView: scrollView, topAnchor: coverImageView.bottomAnchor, paddingTop: -75)
        
        // add name label under uppView and declaring its auto layout
        upperView.addSubview(nameLabel)
        nameLabel.centerX(inView: upperView)
        nameLabel.anchor(top: avaImageView.bottomAnchor, paddingTop: 25)
        
        // add temporaryBioButton under uppView and declaring its auto layout
        upperView.addSubview(temporaryBioButton)
        temporaryBioButton.centerX(inView: upperView)
        temporaryBioButton.anchor(top: nameLabel.bottomAnchor, paddingTop: 25)
        
        
        // creating stackView to deploy smallButtons inside
        let stact = UIStackView(arrangedSubviews: [postButton, editButton, logButton, moreButton])
        stact.axis = .horizontal
        stact.distribution = .fillEqually
        
        // declaring stackView auto layout
        upperView.addSubview(stact)
        stact.anchor(top: temporaryBioButton.bottomAnchor, left: upperView.leftAnchor,
                     right: upperView.rightAnchor, paddingTop: 25, paddingLeft: 50, paddingRight: 50)
        
        containerView.addSubview(pageUpButton)
        pageUpButton.anchor(bottom: containerView.bottomAnchor, right: containerView.rightAnchor)
        
        // declaring tableView and its auto layout
        containerView.addSubview(tableView)
        tableView.anchor(top: upperView.bottomAnchor, left: containerView.leftAnchor,
                         bottom: pageUpButton.topAnchor, right: containerView.rightAnchor)
        
        
        // handle gesture recognizer to change COVER image
        let gestureA = UITapGestureRecognizer(target: self, action:  #selector(coverImageView_tapped) )
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(gestureA)
        
        // handle gesture recognizer to change AVA image
        let gestureB = UITapGestureRecognizer(target: self, action:  #selector(avaImageView_tapped) )
        avaImageView.isUserInteractionEnabled = true
        avaImageView.addGestureRecognizer(gestureB)
        
        
    }
    
    
    
}

//MARK: - UITableViewDataSource

extension Home2VC: UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var array = [Int]()
        
        for num in 1...100 {
            array.append(num)
        }
        let num = array[indexPath.row]
        cell.textLabel?.text = "\(num). Cell"
        cell.backgroundColor = .systemBlue
        return cell
    }
    
    
}


//MARK: - UITableViewDelegate


extension Home2VC: UITableViewDelegate {
    
    
    
    
}



// MARK: - UIImagePickerControllerDelegate



extension Home2VC: UIImagePickerControllerDelegate {
    
    // executed once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // access image selected from pickerController
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        
        // based on the trigger we are assigning selected pictures to the appropriated imageView
        if imageViewTapped == "cover" {
            self.coverImageView.image = image
        } else if imageViewTapped == "ava" {
            self.avaImageView.image = image
        }
        
        // completion handler, to communicate to the project that images has been selected (enable delete button)
        dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
            }
        }
    }
    
    // takes us to PickerController (Controller that allows us to select picture)
    func showPicker(with source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
        
    }
    
    
//MARK: ShowActionSheet
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
        
        // declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // deleting profile picture (ava), by returning placeholder
            if self.imageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "user.png")
                self.isAva = false
            } else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
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

