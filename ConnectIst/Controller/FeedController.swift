//
//  FeedController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 2.04.2021.
//

import UIKit


import UIKit

private let reuseIdentifierNoPicCell = "NoPicCellForFeed"
private let reuseIdentifierPicCell = "PicCellForFeed"

class FeedController: UITableViewController {
    
    
    // MARK: - Properties
    
    var feedPosts = [FeedPost]()
    var limitOfFeedPosts = 5
    var skipOfFeedPosts = 0
    
    var isLoadMoreFeedPosts = false
    
    // MARK: - Views
    
    
    
    //MARK: - LifeCycle
    
    // first loading func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
       
        loadFeedPosts(isLoadMore: false)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - API
    
    
    private func loadFeedPosts(isLoadMore: Bool) {
        guard let id = currentUser?.id else { return }
        
        PostService.loadFeedPots(id: id, offset: skipOfFeedPosts, limit: limitOfFeedPosts, selfVC: self) { (response) in
            switch response {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let posts):
                
                if isLoadMore == false {
                    self.feedPosts = posts
                    
                    if posts.count == self.limitOfFeedPosts {
                        self.skipOfFeedPosts += posts.count
                        self.isLoadMoreFeedPosts = true
                    }
                    
                    self.tableView.reloadData()
                    print("*******************************************")
                    print(self.feedPosts[0])
                    print(self.feedPosts[1])
                    print("*******************************************")
                    
                } else {
                    self.feedPosts.append(contentsOf: posts)
                    
                    self.skipOfFeedPosts += posts.count
                    
                    self.isLoadMoreFeedPosts = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    //MARK: - Private Functions
    
    
    
    // create action sheet and its behavior
    private func showReportAlert(postId:Int, indexPathRow: Int) {
        // creating alert controller
        let alert = UIAlertController(title: "Report", message: "Please explain the reason.", preferredStyle: .alert)
        // creating buttons for action sheet
        let send = UIAlertAction(title: "Send", style: .default) { (action) in
            print("DEBUG: Send button clicked...")
            guard let currentUserId = currentUser?.id else { return }
            let userId = self.feedPosts[indexPathRow].userId
            // access reason from alert's textField
            let textField = alert.textFields![0]
            
            ReportService.shared.uploadReport(postId: postId, userId: userId, reason: textField.text!,
                                              byUserId: currentUserId, selfVC: self)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // add buttons to the alert controller and add textfield
        alert.addAction(send)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            textField.placeholder = "Please provide more details."
            textField.font = UIFont(name: K.Font.helveticaNeue, size: 17)
        }
        // show alert controller
        present(alert, animated: true, completion: nil)
    }
    
    
    // create action sheet and its behavior
    private func showReportSheet(postId:Int, indexPathRow: Int) {
        
        // creating alert controller
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // creating buttons for action sheet
        let report = UIAlertAction(title: "Report", style: .default) { (action) in
            self.showReportAlert(postId: postId, indexPathRow: indexPathRow)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // add buttons to the alert controller
        sheet.addAction(report)
        sheet.addAction(cancel)
        // show alert controller
        present(sheet, animated: true, completion: nil)
    }
    
    
    // MARK: - Action
    
    // executed when the show segue is about to be launched
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // getting index of the cell where in comments button has been pressed
        let indexPathRow = (sender as! UIButton).tag
        
        
        // accessing segue we need -> CommentsController
        if segue.identifier == K.Segue.feedPostToCommentVC {
            // accessing destination we need -> CommentsController
            let controller = segue.destination as! CommentsController
            // assigning values to the vars of CommentsController
            controller.comingFromVC = "feed"
            controller.avaPath = feedPosts[indexPathRow].ava
//            controller.avaImageView.downloadedFrom(link: feedPosts[indexPathRow].ava, placeHolderImage: #imageLiteral(resourceName: "userImage"))
            controller.fullNameString = feedPosts[indexPathRow].fullName
            controller.dateString = Helper.shared.formatDateCreated(with: feedPosts[indexPathRow].dateCreated)
            controller.textString = feedPosts[indexPathRow].text
            // sending ID of the post
            controller.postId = feedPosts[indexPathRow].id
            controller.postOwnerId = feedPosts[indexPathRow].userId
            // sending image to the CommentsController
            let indexPath = IndexPath(item: indexPathRow, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? PicCell else { return }
            controller.pictureImage = cell.pictureImageView.image ?? UIImage()
            
        }
    }
    
    
    // this function executed when like button has been clicked
    @IBAction func likeButton_clicked(_ likeButton: UIButton) {
        
        
        
        // get the index of the cell in order to access relevant post's id
        let indexPathRow = likeButton.tag
        // access id of the current user
        guard let userId = currentUser?.id else { return }
        // access id of the certain post which is related to the cell where the button has been clicked
        let postId = feedPosts[indexPathRow].id
        
        
        // building logic / trigger / switcher to like or unlike the post
        if feedPosts[indexPathRow].liked != nil || feedPosts[indexPathRow].liked == 0{
            // call likePost function to unlike the relevant post
            PostService.shared.likePost(post_id: postId, user_id: userId, action: "delete", selfVC: self)
            NotificationService.sendNotification(userId: userId, friendId: userId, type: .like, action: .delete)
            
            // keep in front-end that is post (at this indexPath.row) has been liked
            feedPosts[indexPathRow].liked = 0
            
            //change icon of the button
            likeButton.setImage(UIImage(named: "unlike"), for: .normal)
            likeButton.tintColor = .darkGray
            
        } else {
            // call likePost function to like the relevant post
            PostService.shared.likePost(post_id: postId, user_id: userId, action: "insert", selfVC: self)
            NotificationService.sendNotification(userId: userId, friendId: userId, type: .like, action: .insert)
            // keep in front-end that is post (at this indexPath.row) has been liked
            feedPosts[indexPathRow].liked = 1
            
            //change icon of the button
            likeButton.setImage(UIImage(named: "like"), for: .normal)
            likeButton.tintColor = K.Button.Color.likeButtonColor
        }
        
        // execute animation (in the extension
        likeButton.setAnimationForFacebook(scaleX: 1.3, y: 1.3)
                
    }
    
    @IBAction func optionButton_clicked(_ optionButton: UIButton) {
        // accessing indexPath.row of the cell
        let indexPathRow = optionButton.tag
        // accessing id of the post in order to specify it in the server
        let postId = feedPosts[indexPathRow].id
        // calling function which shows action sheet for reporting
        showReportSheet(postId: postId, indexPathRow: indexPathRow)
        
    }
    
    
    
    
}


//MARK: - UITableViewDataSource
extension FeedController {
    
    // returning number of rows in the tableView - number of comments
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedPosts.count
    }
    
    //assign data to the cell's objects
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let post = feedPosts[indexPath.row]
        let picture = post.picture
        
        if picture.isEmpty {
            
            // accessing the cell from MainStoryboard
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNoPicCell, for: indexPath) as! NoPicCell
            
            cell.feedPostViewModel = FeedPostViewModel(post: post)
            cell.likeButton.tag = indexPath.row
            cell.commentsButton.tag = indexPath.row
            cell.optionsButton.tag = indexPath.row
            
            return cell
        } else {
            
            // accessing the cell from MainStoryboard
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierPicCell, for: indexPath) as! PicCell
            
            cell.feedPostViewModel = FeedPostViewModel(post: post)
            cell.likeButton.tag = indexPath.row
            cell.commentsButton.tag = indexPath.row
            cell.optionsButton.tag = indexPath.row
            
            return cell
            
        }
        
    }
    
}


//MARK: - UITableViewDelegate

extension FeedController {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // load more post when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y
        let b = tableView.contentSize.height - tableView.frame.height + 60

        if a > b && isLoadMoreFeedPosts == true {
            loadFeedPosts(isLoadMore: true)
        }
    }
}





