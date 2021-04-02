//
//  CommentsController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 2.03.2021.
//

import UIKit

private let reuseIdentifier = "CommentsCell"

class CommentsController: UIViewController {

    
// MARK: - Properties
    
    // variables will store data passed from the previous / mother viewController
    var avaImage = UIImage()
    var fullNameString = String()
    var dateString = String()
    
    var textString = String()
    var pictureImage = UIImage()
    var commentsTextView_bottom_identity = CGFloat()
    
    // comment obj
    var postId = Int()
    var avas = [UIImage]()
    var avasURL = [String]()
    var fullNames = [String]()
    var comments = [String]()
    var commentIds = [Int]()
    var userIdsOfComments = [Int]()
    var postOwnerId = Int()
    
    
    var limit = 10
    var skip = 0
    var commentsArray: [Comment] = [Comment]()
    
    // feed vc
    var comingFromVC = ""
    var avaPath = ""

    
// MARK: - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    // top bar obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // post bar obj
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    // messaging bar obj
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTextView_bottom: NSLayoutConstraint!
    @IBOutlet weak var commentTextView_height: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    
//MARK: - LifeCycle

    // first loading func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // run func
        configureUI()
        configurePropertiesOfObjects()
        loadComments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // pre last func
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove observers of notification when the viewController is left
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
//MARK: - API

    // send a HTTP request to insert the comment
    private func insertComment() {
        // validating vars before sending the server
        guard let user_id = currentUser?.id, let comment = commentTextView.text,
              let ava = currentUserAvaImage, let avaPath = currentUser?.ava else {
            // converting url string to the  valid URL
            if let url = URL(string: currentUser?.ava ?? "" ){
                // downloading all data from the URL
                guard let data = try? Data(contentsOf: url) else { return }
                // converting downloaded data to the image
                guard let image = UIImage(data: data) else { return }
                // assigning image to the global variable
                currentUserAvaImage = image
            }
            return
        }
        
        // send notification to the server
        NotificationService.sendNotification(userId: user_id, friendId: postOwnerId, type: .comment, action: .insert)
        
        
        
        // refresh UI, add new comment in the front end
        guard let fullName = currentUser?.fullName.capitalized else { return }
        
        // insert new comment into front-end's arrays
        print("DEBUG: self.comments.endIndex : \(self.comments.endIndex)")
        avasURL.insert(avaPath, at: self.comments.endIndex)
//        avasURL.insert(avaPath, at: 0)
        avas.insert(ava, at: self.comments.endIndex)
        fullNames.insert(fullName, at: self.comments.endIndex)
        
        userIdsOfComments.append(user_id) // FIXME: fatal error
        
        // send request
        CommentService.shared.insertComment(post_id: postId, user_id: user_id, action: .insert, comment: comment, selfVC: self) { (response) in
            
            switch response {
            
            case .failure(let error) :
                print("DEBUG: error.localizedDescription : \(error.localizedDescription)")
                
            case .success(let data) :
                let newComment = data
                let id = newComment.id
                let dateCreated = newComment.dateCreated
                self.commentIds.append(id)
                print("DEBUG: self.commentIds : \(self.commentIds)")
                let addingComment = Comment(id: id, postId: self.postId, userId: user_id,
                                            comment: comment, dateCreated: dateCreated, text: self.textString,
                                            picture: "Now no need for front-end", fullName: self.fullNameString, ava: "Now no need for front-end ")
                self.commentsArray.append(addingComment)
            }
            
        }
        
        
        
        comments.insert(comment, at: self.comments.endIndex)
        
        // update tableView
        let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        // scroll to the bottom
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // FIXME: Look again
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//            let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
//            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//        }
        
        // empty text view
        commentTextView.text = ""
        textViewDidChange(commentTextView)
      
                
    }
    
    // loading comments from the server via@objc  PHP protocol
    private func loadComments() {
        
        CommentService.shared.loadComments(post_id: postId, offset: skip, action: .select, limit: limit, selfVC: self) { data in
            
            DispatchQueue.main.async {
                // assigning all successfully loaded comments to our Class Var - comments (after it got loaded successfully)
                self.commentsArray = data
                // loop to access every object (comment related pack of information) and fetch certain data
                for comment in self.commentsArray {
                    // appending fetch information to the segmented array
                    
                    self.fullNames.append(comment.fullName)
                    self.comments.append(comment.comment)
                    self.commentIds.append(comment.id)
                    self.userIdsOfComments.append(comment.userId)
                    
                    if let ava = comment.ava{
                        self.avasURL.append(ava)
                    }
                }
                
                
                // reload tableView with updated information
                self.tableView.reloadData()
                
                // scroll to the latest index with safe method (latest cell -> bottom)
                if self.comments.isEmpty == false {
                    let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
   

    
// MARK: - Action
    
    // back button has been  pressed
    @IBAction func backButton_clicked(_ sender: UIButton) {
        // come back to previous vc With Show Segue
        navigationController?.popViewController(animated: true)
    }
    
    // executed once notification is caught -> KeyboardWillShow
    @objc func keyboardWillShow(_ notification: Notification) {
    
        if commentTextView_bottom.constant == commentsTextView_bottom_identity {
            // getting the size of the keyboard
            if let keyboard_size = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

                // increasing the bottom constraint by the keyboard's height
                commentTextView_bottom.constant += keyboard_size.height

            }

            // updating the layout with animation
            let info = notification.userInfo!
            let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        // scroll to the latest index with safe method (latest cell -> bottom)
        if self.comments.isEmpty == false {
            let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // exec-d once notification is caught -> KeyboardWillHide
    @objc func keyboardWillHide(_ notification: Notification) {
        
        // bring back the commentTextView to the initial position
        commentTextView_bottom.constant = commentsTextView_bottom_identity

        // updating the layout with animation
        let info = notification.userInfo!
        let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func sendButton_clicked(_ sender: UIButton) {
        
        // call func
        if commentTextView.text != "" {
            insertComment()
            // hide keyboard
            commentTextView.resignFirstResponder()
        } // FIXME: insert else statement and white space protection
        // hide keyboard
        commentTextView.resignFirstResponder()
        
    }
    
    
    
// MARK: - Helpers
    
    // assigning to the objects values received from the previous controller
    private func configurePropertiesOfObjects() {
        avaImageView.image = avaImage
        fullNameLabel.text = fullNameString
        dateLabel.text = dateString
        
        textLabel.text = textString
        pictureImageView.image = pictureImage
        
        // if post is without the picture - resize the post
        if pictureImage.size.width == 0 {
            pictureImageView.removeFromSuperview()
            containerView.frame.size.height -= pictureImageView.frame.height
        }
        
    }
    
    // declaring UI objects' properties for first loading
    private func configureUI() {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        commentTextView.delegate = self
        
        // keyboard dismiss function when tableView is dragging
        tableView.keyboardDismissMode = .onDrag
        
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        commentTextView.layer.cornerRadius = 10
        
        // cache the commentTextView's position
        commentsTextView_bottom_identity = commentTextView_bottom.constant
        
        // add notification observation
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        
        if comingFromVC == "feed" {
            avaImageView.downloadedFrom(link: self.avaPath, placeHolderImage: #imageLiteral(resourceName: "userImage"))
        }
        
    }
    
    
}

//MARK: - UITextViewDelegate

extension CommentsController: UITextViewDelegate {
    // executed whenever delegated textview has been changed by chars
    func textViewDidChange(_ textView: UITextView) {
        
        // declaring new size of the textView. We increase the height
        let newSize = textView.sizeThatFits(CGSize.init(width: textView.frame.width, height: CGFloat(MAXFLOAT)))
        
        // assign new size to the textView
        textView.frame.size = CGSize.init(width: CGFloat(fmaxf(Float(newSize.width), Float(textView.frame.width))), height: newSize.height)
        // resize the textView
        self.commentTextView_height.constant = newSize.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - UITableViewDataSource
extension CommentsController: UITableViewDataSource {
    
    // returning number of rows in the tableView - number of comments
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    //assign data to the cell's objects
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the cell of the tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CommentsCell
        
        
        //assigning data to the cell's objects
        cell.fullNameLabel.text = fullNames[indexPath.row]
        cell.commentLabel.text = comments[indexPath.row]
        
        
        // loading and catching avas
        let avaString = avasURL[indexPath.row]
        let avaURL = URL(string: avaString)!
        
        // not all avas have been cought
        if comments.count != avas.count {
            
            // request to download the image
            let data = URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                
                // failed to load broken image -> Caught Placeholder
                if error != nil {
                    let image = UIImage(named: K.userImage)!
                    self.avas.append(image)
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }
                    return
                }
                
                guard let data = data else { return }
                
                // loaded successfully -> Caught User's Ava
                if let image = UIImage(data: data) {
                    self.avas.append(image)
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }
                }
            }
            data .resume()
            
        // all avas have been loaded, show them in the cell
        } else {
            cell.avaImageView.image = avas[indexPath.row]
        }
        
        return cell
    }
    
    // allow to edit cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let userId = currentUser?.id else { return false }
        // if commentator is current user then allow to delete the comment
        if userIdsOfComments[indexPath.row] == userId { //FIXME: FATAL ERROR
            return true
        } else {
            return false
        }
    }
    
    
    // declaring action for the deleting cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // enable delete action of cell - swipe to delete
        if editingStyle == .delete {
            
            print(indexPath.row)
            print(commentIds)
            
            // here cell / comment gets deleted
            let id = commentIds[indexPath.row]
            
            // remove the cell from the front-end
            // clean up of the arrays (datas, which are stored in the cell in the background of the app)
            avas.remove(at: indexPath.row)
            avasURL.remove(at: indexPath.row)
            fullNames.remove(at: indexPath.row)
            comments.remove(at: indexPath.row)
            commentsArray.remove(at: indexPath.row)
            commentIds.remove(at: indexPath.row)
            userIdsOfComments.remove(at: indexPath.row)
            
            // remove the cell itself
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            CommentService.shared.deleteComment(id: id, action: .delete, indexPath: indexPath, selfVC: self)
            // send notification to the server
            guard let currentUserId = currentUser?.id else { return }
            NotificationService.sendNotification(userId: currentUserId, friendId: postOwnerId, type: .comment, action: .delete)
            
        }
    }
}


//MARK: - UITableViewDelegate

extension CommentsController: UITableViewDelegate {

}
