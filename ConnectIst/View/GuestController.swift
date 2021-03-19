//
//  GuestController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 10.03.2021.
//

import UIKit

//MARK: - Protocol

// in order to reload tableView and change friend icon in FriendsController
protocol GuestControllerDelegate {
    func didChangeFriendList()
    func didChangeRequestList()
}


private let reuseIdentifier = "PicCell"

class GuestController: UITableViewController {
    
    
    // MARK: - Properties
    
    var guestControllerDelegate: GuestControllerDelegate?
    
    var guestViewModel: GuestViewModel?
    var guestViewModelForRequest: GuestViewModelForRequests?
    
    var comingFromTableView: String = ""
//    var id = Int()
//    var fullName = String()
//    var avaPath = String()
//    var coverPath = String()
//    var bio = String()
    
    // post obj
    var isLoadingPost = false
    var posts = [Post]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var postLikes = [Int]()
    var skip = 0
    var limit = 10
    
    // trigger ti check is guest requested to be friend or not
    var friendshipStatus = 0
    
    // MARK: - Views
    
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configure()
        
        configureUI()
        configure_avaImageView()
        
        loadPosts(isLoadMore: false)
        
        
    }
    
    // pre load function
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - API
    
    
    
    private func loadPosts(isLoadMore: Bool) {
        
        isLoadingPost = true
        
        guard let id = guestViewModel?.id else { return }
        
        
        PostService.shared.loadPosts(id: id, offset: skip, limit: limit, selfVC: self) { (response) in
            
            switch response {
            
            case .failure(let error):
                Helper.shared.showAlert(title: "End Of The Posts", message: "All Posts are downloaded. ", in: self)
                self.isLoadingPost = false
                print("DEBUG: Error: \(error.localizedDescription)")
                
                
            case .success(let data):
                
                if !isLoadMore {
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts = data
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = self.posts.count
                    
                    // clean up likes for the refetching in order to enhance user experience
                    self.postLikes.removeAll(keepingCapacity: false)
                    
                } else {
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts.append(contentsOf: data)
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = self.posts.count
                    
                }
                                
                // logic of tracking liked posts
                for post in self.posts {
                    if post.liked == nil {
                        self.postLikes.append(Int())
                    } else {
                        self.postLikes.append(1)
                    }
                }
                
                // reloading tableView to have an affect - show posts
                self.tableView.reloadData()
                
                self.isLoadingPost = false
            }
        }
    }
    
    private func updateFriendshipRequest(action: UserServiceAction, userId: Int, friendId: Int) {

        UserService.shared.sendFriendRequest(userId: userId, friendId: friendId, action: action,
                                             selfVC: self) { (response) in
            
            switch response {
            
            case .failure(let error) :
                print("DEBUG: JSON Error: ", error.localizedDescription)
                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                
            case .success(let data) :
                
                // if sent request is successfully, sent notification to FriendController to update the status of request
                if data["status"] as! String == "200" {
                    
//                    NotificationCenter.default.post(name: Notification.Name("friend"), object: nil)
                    print("DEBUG: Request has been \(action)ed successfully, \nDEBUG: Data: \(data)")
                }
            }
        }
    }
    
    private func confirmRejectRequestOrDeleteFriend(action: UserServiceAction, userId: Int, friendId: Int) {
        
        
        UserService.shared.confirmRejectRequestOrDeleteFriend(userId: userId, friendId: friendId, action: action,
                                                  selfVC: self) { (response) in
            switch response {
            
            case .failure(let error) :
                print("DEBUG: JSON Error: ", error.localizedDescription)
                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                
            case .success(let status):
                
                if status.status == "200" {
                    print("DEBUG: Request has been \(action.rawValue)ed successfully, \nDEBUG: Data: \(status)")
                }
            }
        }
    }
    
    //MARK: - Private Functions
    
    
    
    
    // MARK: - Action
    
    
    // this function executed when like button has been clicked
    @IBAction func likeButton_clicked(_ likeButton: UIButton) {
        //FIXME: There is a bug for like function. If you like a post then everyUser has liked too.
        
        
        // get the index of the cell in order to access relevant post's id
        let indexPathRow = likeButton.tag
        // access id of the current user
        guard let user_id = currentUser?.id else { return }
        // access id of the certain post which is related to the cell where the button has been clicked
        let post_id = posts[indexPathRow].id
        
        
        // building logic / trigger / switcher to like or unlike the post
        if postLikes[indexPathRow] == 1 {
            // call likePost function to unlike the relevant post
            PostService.shared.likePost(post_id: post_id, user_id: user_id, action: "delete", selfVC: self)
            
            // keep in front-end that is post (at this indexPath.row) has been liked
            postLikes[indexPathRow] = Int()
            
            //change icon of the button
            likeButton.setImage(UIImage(named: "unlike"), for: .normal)
            likeButton.tintColor = .darkGray
            
        } else {
            // call likePost function to like the relevant post
            PostService.shared.likePost(post_id: post_id, user_id: user_id, action: "insert", selfVC: self)
            
            // keep in front-end that is post (at this indexPath.row) has been liked
            postLikes[indexPathRow] = 1
            
            //change icon of the button
            likeButton.setImage(UIImage(named: "like"), for: .normal)
            likeButton.tintColor = K.Button.Color.likeButtonColor
        }
        
        
        likeButton.setAnimationForFacebook(scaleX: 1.3, y: 1.3)
        
    }
    
    // executed when the show segue is about to be launched
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // getting index of the cell where in comments button has been pressed
        let indexPathRow = (sender as! UIButton).tag
        
        
        // accessing segue we need -> CommentsController
        if segue.identifier == K.Segue.guestVCToCommentsVC {
            // accessing destination we need -> CommentsController
            let controller = segue.destination as! CommentsController
            // assigning values to the vars of CommentsController
            controller.avaImage = avaImageView.image ?? UIImage()
            controller.fullNameString = fullNameLabel.text ?? ""
            controller.dateString = Helper.shared.formatDateCreated(with: self.posts[indexPathRow].date_created)
            
            controller.textString = posts[indexPathRow].text
            
            // sending ID of the post
            controller.postId = posts[indexPathRow].id
            print("DEBUG: postID \(posts[indexPathRow].id)")
            // sending image to the CommentsController
//            let indexPath = IndexPath(item: indexPathRow, section: 0)
//            guard let cell = tableView.cellForRow(at: indexPath) as? PicCell else { return }
            
            controller.pictureImage = pictures[indexPathRow]
            
            // hide nav bar in commentsController
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
    }
    
    
    @IBAction func friendButton_clicked(_ button: UIButton) {
        
        // accessing indexPath.row of pressed button
        let indexPathRow = friendButton.tag
        
        // access id of current user stored in the global var - currentUser
        guard let userId = currentUser?.id else { return }
        // accessing id of the user searched and clicked on
        
        var friendId = Int()
        
        if comingFromTableView == "search" {
            
            friendId = guestViewModel?.id ?? 0
            
        } else if comingFromTableView == "friend" {
            
            friendId = guestViewModelForRequest?.id ?? 0
        }
        
        // current user didn't send friendship request -> send it
        if friendshipStatus == 0 {
            //update status in the app logic
            friendshipStatus = 1
            // send request to the server
            updateFriendshipRequest(action: .add, userId: userId, friendId: friendId)
            friendButton.manipulateAddFriendButton(friendRequestType: friendshipStatus, isShowingTitle: false)
            guestControllerDelegate?.didChangeFriendList()
            guestControllerDelegate?.didChangeRequestList()

        // current user sent friendship request -> cancel it
        } else if friendshipStatus == 1 {
            //update status in the app logic
            friendshipStatus = 0
            // send request to the server
            updateFriendshipRequest(action: .reject, userId: userId, friendId: friendId)
            
            friendButton.manipulateAddFriendButton(friendRequestType: self.friendshipStatus, isShowingTitle: false)
            guestControllerDelegate?.didChangeFriendList()
            guestControllerDelegate?.didChangeRequestList()

        //current user received friendship request -> show action sheet
        } else if friendshipStatus == 2 {
            //show action sheet to update request: confirm or delete
            showActionSheet(button: friendButton, friendUserId: friendId, currentUserId: userId)
            
        // current user and searched users are friends -> show action sheet
        } else if friendshipStatus == 3 {
            // show action sheet to update friendship: delete
            showActionSheet(button: friendButton, friendUserId: friendId, currentUserId: userId)
        }
        
        
        
        print(self.friendshipStatus)
        
        
        // STEP 2: Animation of zooming / popping
        button.setAnimationForFacebook(scaleX: 0.7, y: 0.7)
        
    }
    
    // shows action sheet for friendship further action
    private func showActionSheet(button: UIButton,friendUserId: Int, currentUserId: Int) {
        
        // declaring sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            // send request
            if self.friendshipStatus == 2 { // current user received friendship request -> trigger rejection
                self.confirmRejectRequestOrDeleteFriend(action: .reject, userId: friendUserId , friendId: currentUserId)
            } else { // current user received friendship request -> trigger delete
                self.confirmRejectRequestOrDeleteFriend(action: .delete, userId: currentUserId , friendId: friendUserId)
                self.confirmRejectRequestOrDeleteFriend(action: .delete, userId: friendUserId , friendId: currentUserId)
            }
            // update status -> no more any relations
            self.friendshipStatus = 0
            button.manipulateAddFriendButton(friendRequestType: self.friendshipStatus, isShowingTitle: false)
            self.guestControllerDelegate?.didChangeFriendList()
            self.guestControllerDelegate?.didChangeRequestList()
        }
        
        // confirm button
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            // update status -> now friends
            self.friendshipStatus = 3
            // accept request
            self.confirmRejectRequestOrDeleteFriend(action: .confirm, userId: friendUserId, friendId: currentUserId)
            button.manipulateAddFriendButton(friendRequestType: self.friendshipStatus, isShowingTitle: false)
            self.guestControllerDelegate?.didChangeFriendList()
            self.guestControllerDelegate?.didChangeRequestList()

        }
        // cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // assigning all buttons to the sheet
        sheet.addAction(delete)
        // show confirm button only if current user received friendship request. Hide confirm button if users are already friends
        if friendshipStatus == 2 {
            sheet.addAction(confirm)
        }
        sheet.addAction(cancel)
        // showing sheet
        present(sheet, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Helpers
    
    
    private func configureUI() {
        view.backgroundColor = .white
        
        tableView.rowHeight = UITableView.automaticDimension
        
        // bar buttons
        friendButton.centerVertically()
        followButton.centerVertically()
        messageButton.centerVertically()
        moreButton.centerVertically()
        
    }
    
    // configuring the appearance of AvaImageView
    private func configure_avaImageView() {
        
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
    
    private func configure() {
        
        if comingFromTableView == "search" {
            
            guard let viewModel = guestViewModel else { return }
            let avaPath = viewModel.avaPath
            Helper.shared.downloadImage(from: avaPath, showIn: avaImageView, orShow: #imageLiteral(resourceName: "userImage"))
            
            let coverPath = viewModel.coverPath
            Helper.shared.downloadImage(from: coverPath, showIn: coverImageView, orShow:  #imageLiteral(resourceName: "homeCoverImage"))
            
            
            if let bio = viewModel.bio {
                bioLabel.text = bio
            } else {
                headerView.frame.size.height -= 40
                bioLabel.isHidden = true
                stackViewTopConstraint.constant -= 60
                stackView.layoutIfNeeded()
            }
            
            fullNameLabel.text = viewModel.fullName.capitalized
            
            // manipulate the appearance of addFriend Button based on has request been sent or not
            let isRequested = friendshipStatus
            friendButton.manipulateAddFriendButton(friendRequestType: isRequested, isShowingTitle: true)
            print("DEBUG: is friend requested : \(isRequested)")
            
        } else if comingFromTableView == "friend" {
            
            guard let viewModel = guestViewModelForRequest else { return }
            if let avaPath = viewModel.avaPath {
                Helper.shared.downloadImage(from: avaPath, showIn: avaImageView, orShow: #imageLiteral(resourceName: "userImage"))
            }
            let coverPath = viewModel.coverPath
            Helper.shared.downloadImage(from: coverPath, showIn: coverImageView, orShow:  #imageLiteral(resourceName: "homeCoverImage"))
            
            
            if let bio = viewModel.bio {
                bioLabel.text = bio
            } else {
                headerView.frame.size.height -= 40
                bioLabel.isHidden = true
                stackViewTopConstraint.constant -= 60
                stackView.layoutIfNeeded()
            }
            
            fullNameLabel.text = viewModel.fullName.capitalized
            
            // manipulate the appearance of addFriend Button based on has request been sent or not
            let isRequested = friendshipStatus
            friendButton.manipulateAddFriendButton(friendRequestType: isRequested, isShowingTitle: true)
            
        }
        
    }
    
    
    
    
    
    
}


//MARK: - UITableViewDataSource
extension GuestController {
    
    // returning number of rows in the tableView - number of comments
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    //assign data to the cell's objects
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the cell from MainStoryboard
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PicCell
        let post = posts[indexPath.row]
        cell.viewModel = PostViewModel(post: post)
        
        
        // avas logic
        let avaString = posts[indexPath.row].ava!
        
        if let avaURL = URL(string: avaString) {
            
            // if there are still avas to be loaded
            if posts.count != avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.avas.append(image)
//                            print("DEBUG: AVA assigned")
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.avas.append(image)
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
                    cell.avaImageView.image = self.avas[indexPath.row]
                }
            }
            
        // unable to convert empty string (or whatever the reason) to be a proper url
        } else {
            
            // append array of avas with the placeholder image
            let placeHolderImage = #imageLiteral(resourceName: "userImage")
            self.avas.append(placeHolderImage)
            
        }
        
        
        
        
        // pictures logic
        let pictureString = posts[indexPath.row].picture
        
        if let pictureURL = URL(string: pictureString) {
        
            // if there are still pictures to be loaded
            if posts.count != pictures.count {
                
                URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.pictures.append(image)
//                          print("DEBUG: PIC assigned")
                            
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                            }
                        }
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.pictures.append(image)
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
                    cell.pictureImageView.image = self.pictures[indexPath.row]
                }
            }
            
        // unable to convert empty string (or whatever the reason) to be a proper url
        } else {
            
            // blank image in the backend array
            self.pictures.append(UIImage())
            
            // resize picture height -> resize cell (as per auto layout)
            cell.pictureImageView_height.constant = 0
            cell.updateConstraints()
            
            
        }
        // get the index of the cell in order to get certain post's id
        cell.likeButton.tag = indexPath.row
        cell.commentsButton.tag = indexPath.row
        cell.optionsButton.tag = indexPath.row
        
        //manipulating the appearance of the button based is the post has been liked or not
        DispatchQueue.main.async {
            if self.postLikes[indexPath.row] == 1 {
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


//MARK: - UITableViewDelegate

extension GuestController {
    
    // executed always whenever tableView is scrolling
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {


        // load more post when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y
        let b = tableView.contentSize.height - tableView.frame.height + 60

        if a > b && isLoadingPost == false {
            loadPosts(isLoadMore: true)
        }
    }
    
}


