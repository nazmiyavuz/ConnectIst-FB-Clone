//
//  HomeVCTableViewController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 19.02.2021.
//

import UIKit

private let noPicReuseIdentifier = "NoPicCell"
private let picReuseIdentifier = "PicCell"
private let friendsCellIdentifier = "FriendsCell"

class HomeController: UITableViewController, UINavigationControllerDelegate {

    
// MARK: - Properties
            
    // code obj (to build logic of distinguishing tapped / show Cover / Ava)
    var nameOfImageViewTapped = ""
    
    var postsList: [Post] = [Post]()
    var userAvasList = [UIImage]()
    var postsPicturesList = [UIImage]()
    var postLikesList: [Int] = [Int]()
    
    
    var skip = 0
    var limit = 5
    
    
    var isLoadingPost: Bool = false
            
    // friends obj
    var myFriends: [Friend]? = [Friend]()
    
        
        

    
// MARK: - Views
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    

    
// MARK: - Lifecycle
    
    // executed once the Auto-Layout has been applied / executed
    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // run observer function
        configureNotificationObservers()
        
        // run func
        configure_avaImageView()
        configureGestureRecognizer()
        loadUser()
        loadPosts(isLoadMore: false)
        loadMyFriends()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
// MARK: - API
    
    // loads all user related information to be shown in the header
    @objc func loadUser() {
        
        
        // safe method of accessing user related information in glob variables
        if let fullName = currentUser?.fullName {
            // assigning vars which we accessed from global var, to fullNameLabel
            fullNameLabel.text = fullName.capitalized
        }
        
        // downloading the images and assigning to certain imageViews
        if let coverPath = currentUser?.cover {
            Helper.shared.downloadImage(from: coverPath, showIn: coverImageView, orShow: #imageLiteral(resourceName: "homeCoverImage"))
        }
        if let avaPath = currentUser?.ava {
            Helper.shared.downloadImage(from: avaPath, showIn: avaImageView, orShow: #imageLiteral(resourceName: "userImage"))
        }
        
        // if bi is empty or emptySpace in the server -> hide bio label, otherwise, show bio label
        let bio = currentUser?.bio
        if bio == nil || bio == " " {
            bioLabel.isHidden = true
            addBioButton.isHidden = false
        } else {
            bioLabel.text = bio
            bioLabel.isHidden = false
            addBioButton.isHidden = true
        }
        
        // save in the background thread the user's profile picture
        DispatchQueue.main.async {
            currentUserAvaImage = self.avaImageView.image
        }
    }
    
    
    
    private func loadPosts(isLoadMore: Bool) {
        
        isLoadingPost = true
        
        // save method of access 2 values to be sent to the server
        guard let id = currentUser?.id else { return }
//        let idString = String(id) // FIXME: Delete if necessary
        
        PostService.shared.loadPosts(id: id, offset: skip, limit: limit, selfVC: self) { (response) in
            
            switch response {
            
            case .failure(let error):
                Helper.shared.showAlert(title: "End Of The Posts", message: "All Posts are downloaded. ", in: self)
                self.isLoadingPost = false
                print("DEBUG: Error: \(error.localizedDescription)")
                
                
            case .success(let data):
                
                if !isLoadMore {
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.postsList = data
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = self.postsList.count
                    
                    // clean up likes for the refetching in order to enhance user experience
                    self.postLikesList.removeAll(keepingCapacity: false)
                    
                } else {
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.postsList.append(contentsOf: data)
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = self.postsList.count
                    
                }
                                
                // logic of tracking liked posts
                for post in self.postsList {
                    if post.liked == nil {
                        self.postLikesList.append(Int())
                    } else {
                        self.postLikesList.append(1)
                    }
                }
                
                // reloading tableView to have an affect - show posts
                self.tableView.reloadData()
                
                self.isLoadingPost = false
            }
        }
    }
    
    
    @objc func loadNewPost() {
        
        isLoadingPost = true
        
        // save method of access 2 values to be sent to the server
        guard let id = currentUser?.id else { return }
        
        //skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
        PostService.shared.loadPosts(id: id, offset: 0, limit: (skip + 1), selfVC: self) { (response) in
            
            switch response {
            
            case .failure(let error):
                Helper.shared.showAlert(title: "End Of The Posts", message: "All Posts are downloaded. ", in: self)
                self.isLoadingPost = false
                print("DEBUG: Error: \(error.localizedDescription)")
            case .success(let data):
                // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                self.postsList = data
                
                // we are skipping already loaded numb of posts for the next load - pagination
                self.skip = self.postsList.count
                
                self.postLikesList.insert(Int(), at: 0)
                
                // reloading tableView to have an affect - show posts
                self.tableView.reloadData()
                self.isLoadingPost = false
            }
        }
    }
    
    // responsible for deleting posts
    func deletePost(indexPath: IndexPath) {
        
        // accessing id of the post which is stored in the tapped cell
        let id = postsList[indexPath.row].id
        
        // call function which is responsible to delete post from the server, is in PostService.swift
        PostService.shared.deletePost(id: id, selfVC: self) { (response) in
            switch response {
            case .failure(let err):
                print("DEBUG: Failure to fetch data: \(err)")
            case .success(let json):
                print("DEBUG: Success to fetch data: \(json)")
                // clean up of the the data stored in the background of our logic in order to keep everything synchronized.
                self.postsList.remove(at: indexPath.row)
                self.userAvasList.remove(at: indexPath.row)
                self.postsPicturesList.remove(at: indexPath.row)
                self.postLikesList.remove(at: indexPath.row)
                
                // remove the cell itself from the tableView
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    
    private func loadMyFriends() {
        guard let id = currentUser?.id else { return }
        
        UserService.loadFriends(id: id, limit: 6, offset: 0, selfVC: self) { (response) in
            switch response {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let friends):
                
                self.myFriends = friends
                print(self.myFriends!)
            }
        }
    }
    
    
// MARK: - Action
    
    // executed when Cover is tapped
    @objc func coverImageView_tapped() {
        // switching trigger
        nameOfImageViewTapped = "cover"
        // launch action sheet calling function
        showActionSheet()
        
    }
    
    // executed when Ava is tapped
    @objc func avaImageView_tapped() {
        
        // switching trigger
        nameOfImageViewTapped = "ava"
        // launch action sheet calling function
        showActionSheet()
    }
    
    // in order to change bio
    @objc func bioLabel_tapped() {
        Helper.shared.showBioActionSheet(selfVC: self, bioLabel: bioLabel, bioButton: addBioButton)
    }
    
    // go BioVC in order to save newBio
    @IBAction func bioButton_clicked(_ sender: UIButton) {
        let controller = UINavigationController(rootViewController: BioController())
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
        
    }
    
    // go PostVC
    @IBAction func postButton_clicked(_ sender: UIButton) {
        
        let controller = UINavigationController(rootViewController: PostController())
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func moreButton_clicked(_ sender: UIButton) {
        // creating action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            let controller = UINavigationController(rootViewController: LoginController())
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true) {
                
                if let appDomain = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: appDomain)
                    }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // add buttons to the actionSheet
        sheet.addAction(logout)
        sheet.addAction(cancel)
        // show action sheet
        present(sheet, animated: true, completion: nil)
    }
    
    // this function executed when like button has been clicked
    @IBAction func likeButton_clicked(_ likeButton: UIButton) {
        
        
        
        // get the index of the cell in order to access relevant post's id
        let indexPathRow = likeButton.tag
        // access id of the current user
        guard let user_id = currentUser?.id else { return }
        // access id of the certain post which is related to the cell where the button has been clicked
        let post_id = postsList[indexPathRow].id
        
        
        // building logic / trigger / switcher to like or unlike the post
        if postLikesList[indexPathRow] == 1 {
            // call likePost function to unlike the relevant post
            PostService.shared.likePost(post_id: post_id, user_id: user_id, action: "delete", selfVC: self)
            NotificationService.sendNotification(userId: user_id, friendId: user_id, type: .like, action: .delete)
            
            // keep in front-end that is post (at this indexPath.row) has been liked
            postLikesList[indexPathRow] = Int()
            
            //change icon of the button
            likeButton.setImage(UIImage(named: "unlike"), for: .normal)
            likeButton.tintColor = .darkGray
            
        } else {
            // call likePost function to like the relevant post
            PostService.shared.likePost(post_id: post_id, user_id: user_id, action: "insert", selfVC: self)
            NotificationService.sendNotification(userId: user_id, friendId: user_id, type: .like, action: .insert)
            // keep in front-end that is post (at this indexPath.row) has been liked
            postLikesList[indexPathRow] = 1
            
            //change icon of the button
            likeButton.setImage(UIImage(named: "like"), for: .normal)
            likeButton.tintColor = K.Button.Color.likeButtonColor
        }
        
        // execute animation (in the extension
        likeButton.setAnimationForFacebook(scaleX: 1.3, y: 1.3)
                
    }
    
    // executed when the show segue is about to be launched
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // getting index of the cell where in comments button has been pressed
        let indexPathRow = (sender as! UIButton).tag
        
        
        // accessing segue we need -> CommentsController
        if segue.identifier == K.Segue.homeVCToCommentVC {
            // accessing destination we need -> CommentsController
            let controller = segue.destination as! CommentsController
            // assigning values to the vars of CommentsController
            controller.avaImage = avaImageView.image ?? UIImage()
            controller.fullNameString = fullNameLabel.text ?? ""
            controller.dateString = Helper.shared.formatDateCreated(with: self.postsList[indexPathRow].date_created)
            controller.textString = postsList[indexPathRow].text
            // sending ID of the post
            controller.postId = postsList[indexPathRow].id
            controller.postOwnerId = postsList[indexPathRow].user_id
            // sending image to the CommentsController
            let indexPath = IndexPath(item: indexPathRow, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? PicCell else { return }
            controller.pictureImage = cell.pictureImageView.image ?? UIImage()
            
        }
    }
    
    // called when options button has been clicked
    @IBAction func optionsButton_clicked(_ optionButton: UIButton) {
        // TODO: creating IndexPath
        // accessing indexPath of the button / cell
        let indexPath = IndexPath(row: optionButton.tag, section: 0)
        
        // creating action sheet
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating Delete button
        let delete = UIAlertAction(title: "Delete Post", style: .destructive) { (delete) in
            
            self.deletePost(indexPath: indexPath)
        }
        
        // creating Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // assigning buttons to the sheet
        alert.addAction(delete)
        alert.addAction(cancel)
        
        // showing actionSheet
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logButton_clicked(_ sender: UIButton) {
        
        self.tabBarController?.selectedIndex = 2
        
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
        
        // handle gesture recognizer to change bioLabel image
        let gestureC = UITapGestureRecognizer(target: self, action:  #selector(bioLabel_tapped) )
        bioLabel.isUserInteractionEnabled = true
        bioLabel.addGestureRecognizer(gestureC)
        
    }
    
    // add observers to reload UIObjects
    func configureNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateBio"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPost), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        
    }
    
    
// MARK: - ActionSheets
    
    // takes us to PickerController (Controller that allows us to select picture)
    func showPicker(with source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
        
    }
    

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
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [self] (action) in
            
            // deleting profile picture (ava), by returning placeholder
            if self.nameOfImageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "userImage")
                ImageUploader.shared.uploadImage(from: avaImageView, imageViewTapped: nameOfImageViewTapped, selfVC: self)
                
                // refresh global variable storing the users profile picture
                currentUserAvaImage = self.avaImageView.image
                Helper.shared.saveIsAva(false)
                print("DEBUG: after deleting isAva: \(isAva)")
            } else if self.nameOfImageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "homeCoverImage")
                ImageUploader.shared.uploadImage(from: coverImageView, imageViewTapped: nameOfImageViewTapped, selfVC: self)
                Helper.shared.saveIsCover(false)
                print("DEBUG: after deleting isCover: \(isCover)")
            }
        }
        
        // manipulating appearance of delete button for each scenarios
        if nameOfImageViewTapped == "ava" && isAva == false {
            delete.isEnabled = false
        } else if nameOfImageViewTapped == "cover" && isCover == false {
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
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 1
    //    }
}

// MARK: - UITableViewDataSource

extension HomeController {
    // section 1 = friendsView; section 2 = posts
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // number of posts
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 { // friends
            return 1
        } else { // posts
            return postsList.count
        }
        
    }
    
    // configuration of cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // section 0 which includes 1 cell that shows myFriends
        if indexPath.section == 0 {
            
            // accessing the cell from MainStoryboard
            let cell = tableView.dequeueReusableCell(withIdentifier: friendsCellIdentifier, for: indexPath)
            
            // shortcuts, parameters of frame
            let gap : CGFloat = 15
            var x : CGFloat = 15
            var y : CGFloat = 50
            let width = (cell.contentView.frame.width / 3) - 20
            let height = width
            // add multiple views depending on the total number of elements in the array
            if let friends = self.myFriends {
                
                for i in 0 ..< friends.count {
                    let frame = CGRect(x: x, y: y, width: width, height: height)
                    let button = UIButton()
                    button.frame = frame
                    button.tag = i
                    button.backgroundColor = .red
                    button.setTitleColor(.black, for: .normal)
                    button.titleLabel?.font = UIFont(name: K.Font.helveticaNeue_medium, size: 14)
                    button.setTitle(friends[i].fullName.capitalized, for: .normal)
                    button.centerVertically(gap: 30)
                    cell.contentView.addSubview(button)
                    // declare new x and y (coordinate) for the following button
                    x += width + gap
                    // if already 3 elements are shown, show the following elements in the new row.
                    if i == 2 {
                        x = 15
                        y += height + 30 + gap
                    }
                    button.setBackgroundImageFrom(link: friends[i].ava, placeHolderImage: #imageLiteral(resourceName: "userImage"))
                    
                }
            }
            
            
            
//            cell.backgroundColor = .systemRed
            return cell
            
        } else { // section 1 (or any other sections) which which shows all the posts of the user
            // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
            let pictureURL = postsList[indexPath.row].picture
            
            // no picture in the post
            if pictureURL.isEmpty {
                // accessing the cell from MainStoryboard
                let cell = tableView.dequeueReusableCell(withIdentifier: noPicReuseIdentifier, for: indexPath) as! NoPicCell
                let post = postsList[indexPath.row]
                cell.postViewModel = PostViewModel(post: post)
                
                // avas logic
                let avaString = postsList[indexPath.row].ava!
                let avaURL = URL(string: avaString)!
                
                
                // if there are still avas to be loaded
                if postsList.count != userAvasList.count {
                    
                    URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.userAvasList.append(image)
    //                            print("DEBUG: AVA assigned")
                                
                                DispatchQueue.main.async {
                                    cell.avaImageView.image = image
                                }
                            }
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.userAvasList.append(image)
    //                        print("DEBUG: AVA loaded")
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        
                    }.resume()
                    
                // cached ava
                } else {
    //                print("DEBUG: AVA cached")
                    
                    DispatchQueue.main.async {
                        cell.avaImageView.image = self.userAvasList[indexPath.row]
                    }
                }
                // picture logic
                postsPicturesList.append(UIImage())
                
                // get the index of the cell in order to get certain post's id
                cell.likeButton.tag = indexPath.row
                cell.commentsButton.tag = indexPath.row
                cell.optionsButton.tag = indexPath.row
                
                //manipulating the appearance of the button based is the post has been liked or not
                DispatchQueue.main.async {
                    if self.postLikesList[indexPath.row] == 1 {
                        cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                        cell.likeButton.tintColor = K.Button.Color.likeButtonColor
                    } else {
                        cell.likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                        cell.likeButton.tintColor = .darkGray
                    }
                }

                return cell
                
            // picture in the post
            } else {
                // accessing the cell from MainStoryboard
                let cell = tableView.dequeueReusableCell(withIdentifier: picReuseIdentifier, for: indexPath) as! PicCell
                let post = postsList[indexPath.row]
                cell.postViewModel = PostViewModel(post: post)
                
                
                // avas logic
                let avaString = postsList[indexPath.row].ava!
                let avaURL = URL(string: avaString)!
                
                // if there are still avas to be loaded
                if postsList.count != userAvasList.count {
                    
                    URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.userAvasList.append(image)
    //                            print("DEBUG: AVA assigned")
                                
                                DispatchQueue.main.async {
                                    cell.avaImageView.image = image
                                }
                            }
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.userAvasList.append(image)
    //                        print("DEBUG: AVA loaded")
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        
                    }.resume()
                    
                // cached ava
                } else {
    //                print("DEBUG: AVA cached")
                    
                    DispatchQueue.main.async {
                        cell.avaImageView.image = self.userAvasList[indexPath.row]
                    }
                }
                
                
                // pictures logic
                let pictureString = postsList[indexPath.row].picture
                let pictureURL = URL(string: pictureString)!
                
                // if there are still pictures to be loaded
                if postsList.count != postsPicturesList.count {
                    
                    URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.postsPicturesList.append(image)
    //                            print("DEBUG: PIC assigned")
                                
                                DispatchQueue.main.async {
                                    cell.pictureImageView.image = image
                                }
                            }
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.postsPicturesList.append(image)
    //                        print("DEBUG: PIC loaded")
                            
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                            }
                        }
                    }.resume()
                    
                // cached picture
                } else {
    //                print("DEBUG: PIC cached")
                    
                    DispatchQueue.main.async {
                        cell.pictureImageView.image = self.postsPicturesList[indexPath.row]
                    }
                }
                
                // get the index of the cell in order to get certain post's id
                cell.likeButton.tag = indexPath.row
                cell.commentsButton.tag = indexPath.row
                cell.optionsButton.tag = indexPath.row
                
                //manipulating the appearance of the button based is the post has been liked or not
                DispatchQueue.main.async {
                    if self.postLikesList[indexPath.row] == 1 {
                        cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                        cell.likeButton.tintColor = K.Button.Color.likeButtonColor
                    } else {
                        cell.likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                        cell.likeButton.tintColor = .darkGray
                    }
                }
                
                return cell
                
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension HomeController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // height of the cell in section 0 (cell to show the friends)
        if indexPath.section == 0 {
            guard let friends = self.myFriends else { return 0 }
            if friends.count < 4 {
                return 200
            } else {
                return 350
            }
        } else { // height of the cell in section 1 (cell to show the posts)
            return UITableView.automaticDimension
        }
    }
    
    
    // executed always whenever tableView is scrolling
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {


        // load more post when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y
        let b = tableView.contentSize.height - tableView.frame.height + 60

        if a > b && isLoadingPost == false {
            loadPosts(isLoadMore: true)
        }
    }
    
    /*
    // executed whenever new is to be displayed
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
        let pictureURL = postsList[indexPath.row].picture
        
        // no picture in the post
        if pictureURL.isEmpty {
            // accessing the cell from MainStoryboard
            let cell = tableView.dequeueReusableCell(withIdentifier: noPicReuseIdentifier, for: indexPath) as! NoPicCell
            let post = postsList[indexPath.row]
            cell.viewModel = PostViewModel(post: post)
            
            // avas logic
            let avaString = postsList[indexPath.row].ava!
            let avaURL = URL(string: avaString)!
            
            
            // if there are still avas to be loaded
            if postsList.count != userAvasList.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.userAvasList.append(image)
//                            print("DEBUG: AVA assigned")
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.userAvasList.append(image)
//                        print("DEBUG: AVA loaded")
                        
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    
                }.resume()
                
            // cached ava
            } else {
//                print("DEBUG: AVA cached")
                
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.userAvasList[indexPath.row]
                }
            }
            // picture logic
            postsPicturesList.append(UIImage())
            
            // get the index of the cell in order to get certain post's id
            cell.likeButton.tag = indexPath.row
            cell.commentsButton.tag = indexPath.row
            cell.optionsButton.tag = indexPath.row
            
            //manipulating the appearance of the button based is the post has been liked or not
            DispatchQueue.main.async {
                if self.postLikesList[indexPath.row] == 1 {
                    cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                    cell.likeButton.tintColor = K.Button.Color.likeButtonColor
                } else {
                    cell.likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                    cell.likeButton.tintColor = .darkGray
                }
            }
            
        // picture in the post
        } else {
            // accessing the cell from MainStoryboard
            let cell = tableView.dequeueReusableCell(withIdentifier: picReuseIdentifier, for: indexPath) as! PicCell
            let post = postsList[indexPath.row]
            cell.viewModel = PostViewModel(post: post)
            
            
            // avas logic
            let avaString = postsList[indexPath.row].ava!
            let avaURL = URL(string: avaString)!
            
            // if there are still avas to be loaded
            if postsList.count != userAvasList.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.userAvasList.append(image)
//                            print("DEBUG: AVA assigned")
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.userAvasList.append(image)
//                        print("DEBUG: AVA loaded")
                        
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    
                }.resume()
                
            // cached ava
            } else {
//                print("DEBUG: AVA cached")
                
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.userAvasList[indexPath.row]
                }
            }
            
            
            // pictures logic
            // avas logic
            let pictureString = postsList[indexPath.row].picture
            let pictureURL = URL(string: pictureString)!
            
            // if there are still pictures to be loaded
            if postsList.count != postsPicturesList.count {
                
                URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.postsPicturesList.append(image)
//                            print("DEBUG: PIC assigned")
                            
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.postsPicturesList.append(image)
//                        print("DEBUG: PIC loaded")
                        
                        DispatchQueue.main.async {
                            cell.pictureImageView.image = image
                        }
                    }
                }.resume()
                
            // cached picture
            } else {
//                print("DEBUG: PIC cached")
                
                DispatchQueue.main.async {
                    cell.pictureImageView.image = self.postsPicturesList[indexPath.row]
                }
            }
            
            // get the index of the cell in order to get certain post's id
            cell.likeButton.tag = indexPath.row
            cell.commentsButton.tag = indexPath.row
            cell.optionsButton.tag = indexPath.row
            
            //manipulating the appearance of the button based is the post has been liked or not
            DispatchQueue.main.async {
                if self.postLikesList[indexPath.row] == 1 {
                    cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                    cell.likeButton.tintColor = K.Button.Color.likeButtonColor
                } else {
                    cell.likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                    cell.likeButton.tintColor = .darkGray
                }
            }
            
            
        }
    }
     */
    
}

// MARK:- ImagePickerControlerDelegate

extension HomeController: UIImagePickerControllerDelegate {
    
    // executed once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        // access image selected from pickerController
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        
        // based on the trigger we are assigning selected pictures to the appropriated imageView
        if nameOfImageViewTapped == "cover" {
            // assign selected image to CoverImageView
            self.coverImageView.image = image
            // upload image to the server
            ImageUploader.shared.uploadImage(from: coverImageView, imageViewTapped: nameOfImageViewTapped, selfVC: self)
            Helper.shared.saveIsCover(true)
        } else if nameOfImageViewTapped == "ava" {
            // assign selected image to AvaImageView
            self.avaImageView.image = image
            
            // refresh global variable storing the users profile picture
            currentUserAvaImage = self.avaImageView.image
            
            // upload image to the server
            ImageUploader.shared.uploadImage(from: avaImageView, imageViewTapped: nameOfImageViewTapped, selfVC: self)
            Helper.shared.saveIsAva(true)
        }
        
        // completion handler, to communicate to the project that images has been selected (enable delete button)
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


// Helper function inserted by Swift 4.2 migrator.
func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
