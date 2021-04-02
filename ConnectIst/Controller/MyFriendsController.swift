//
//  MyFriendsController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 1.04.2021.
//

import UIKit

import UIKit

private let reuseIdentifier = "MyFriendsCell"

class MyFriendsController: UITableViewController {
    
    
    // MARK: - Properties
    
    var myFriends: [Friend]? = [Friend]()
    var limitOfFriends = 10
    var skipOfFriends = 0
    var friendshipStatus = [Int]()
    
    var isLoadMoreFriends = false
    
    // MARK: - Views
    
    
    
    //MARK: - LifeCycle
    
    // first loading func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavBar()
        // run func
        loadMyFriends(isLoadMore: false)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - API
    
    
    private func loadMyFriends(isLoadMore: Bool) {
        guard let id = currentUser?.id else { return }
        
        UserService.loadFriends(id: id, limit: limitOfFriends, offset: skipOfFriends, selfVC: self) { (response) in
            switch response {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let friends):
                
                if !isLoadMore {
                    self.myFriends = friends
                    if friends.count == self.limitOfFriends {
                        self.skipOfFriends += friends.count
                        self.isLoadMoreFriends = true
                    }
                    
                    for _ in friends {
                        self.friendshipStatus.append(3)
                    }
                    print("DEBUG: Friendship Status = \(self.friendshipStatus)")
                    self.tableView.reloadData()
                    
                } else {
                    
                    self.myFriends?.append(contentsOf: friends)
                    
                    self.skipOfFriends += friends.count
                    
                    for _ in friends {
                        self.friendshipStatus.append(3)
                    }
                    self.isLoadMoreFriends = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // update friendship: delete friend or send a request
    private func updateFriendshipRequest(action: UserServiceAction, userId: Int, friendId: Int) {
        
        
        UserService.shared.confirmRejectRequestOrDeleteFriend(userId: userId, friendId: friendId,
                                                              action: action,
                                                              selfVC: self) { (response) in
            switch response {
            case .failure(let error) :
                print("DEBUG: JSON Error: ", error.localizedDescription)
                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
            case .success(let status):
                if status.status == "200" {
                    print("DEBUG: Request has been \(action.rawValue)ed successfully, \nDEBUG: Data: \(status)")
                    // register notification in the server
                    if action == .delete {
                        // FIXME: There is a problem with .delete action because of this .delete meaning is for deleting notification not friend
                        NotificationService.sendNotification(userId: userId, friendId: friendId, type: .friend, action: .delete)
                    } else if action == .add {
                        NotificationService.sendNotification(userId: userId, friendId: friendId, type: .friend, action: .insert)
                    } else if action == .reject {
                        NotificationService.sendNotification(userId: userId, friendId: friendId, type: .request, action: .insert)
                    }
                    
                    
                }
            }
        }
    }
    
    //MARK: - Private Functions
    
    // create action sheet and its behavior
    private func showAlert(indexPathRow: Int, delete: @escaping () -> Void) {
        guard let currentUserId = currentUser?.id, let friends = myFriends else { return }
        let friendId = friends[indexPathRow].friendId
        
        // creating alert controller
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // creating buttons for action sheet
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            // consider both scenarios: current user is initiator of the friendship AND current user is the one who has accepted friednship
            self.updateFriendshipRequest(action: .delete, userId: currentUserId, friendId: friendId)
            self.updateFriendshipRequest(action: .delete, userId: friendId, friendId: currentUserId)
            delete()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // add buttons to the alert controller
        sheet.addAction(delete)
        sheet.addAction(cancel)
        // show alert controller
        present(sheet, animated: true, completion: nil)
    }
    
    
    // MARK: - Action
    
    @IBAction func removeButton_clicked(_ removeButton: UIButton) {
        
        let indexPathRow = removeButton.tag
        print("DEBUG: \(removeButton.tag). remove button clicked.. ")
        
        guard let currentUserId = currentUser?.id, let friends = myFriends else { return }
        var friendId = Int()
        if currentUserId == friends[indexPathRow].friendId {
            friendId = friends[indexPathRow].userId
        } else {
            friendId = friends[indexPathRow].friendId
        }
        
        // if the user is currently a friend of the current user -? show sheet to delete the friend
        if friendshipStatus[indexPathRow] == 3 {
            showAlert(indexPathRow: indexPathRow) {
                removeButton.setTitle("Add", for: .normal)
                removeButton.setTitleColor(.white, for: .normal)
                removeButton.backgroundColor = K.facebookColor
                for layer in removeButton.layer.sublayers! {
                    layer.borderColor = UIColor.white.cgColor
                    layer.cornerRadius = 3
                }
                // update friendship request in the front end's logic. 0 means no relations
                self.friendshipStatus[indexPathRow] = 0
            }
         // once the request is sent -> cancel the request
        } else if friendshipStatus[indexPathRow] == 1 {
            // remove request from the server
            self.updateFriendshipRequest(action: .reject, userId: currentUserId, friendId: friendId)
            // no more relations, even requests
            friendshipStatus[indexPathRow] = 0
            // update the button
            removeButton.setTitle("Add", for: .normal)
        } else { // if the (friend) was deleted -> don't show sheet, send friendship request
            self.updateFriendshipRequest(action: .add, userId: currentUserId, friendId: friendId)
            // update friendship request in the front end's logic. 1 means current user send a request
            friendshipStatus[indexPathRow] = 1
            removeButton.setTitle("Cancel", for: .normal)
            removeButton.setTitleColor(.black, for: .normal)
            removeButton.backgroundColor = .white
        }
        
    }
    
    // executed before segue finishes
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // access controller in order to its vars
        let guestController = segue.destination as! GuestController
        // going Guest from SearchTableView (tapped on the searched user)
        // exec-d once GuestVC-Segue (id) is executed (id is declared in Main.storyboard)
        if segue.identifier == K.Segue.myFriendsVCToGuestVC {
            
            // access index of selected cell in order to access index of searchedUsers
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let myFriends = self.myFriends else { return }
            
            guestController.comingFromTableView = K.myFriendCell
//            guestController.guestControllerDelegate = self
            guestController.friendshipStatus = friendshipStatus[indexPath.row]
            guestController.guestViewModelForMyFriendCell = MyFriendCellViewModel(friend: myFriends[indexPath.row])
            
        }
    }
    
    
    // MARK: - Helpers
    
    
    private func configureUI() {
        
        
        
    }
    
    private func configureNavBar() {
        
        
    }
    
    
}


//MARK: - UITableViewDataSource
extension MyFriendsController {
    
    // returning number of rows in the tableView - number of comments
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let myFriends = self.myFriends else { return 0 }
        return myFriends.count
    }
    
    //assign data to the cell's objects
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the cell of the tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MyFriendCell
        
        guard let myFriends = self.myFriends else { return UITableViewCell()}
        let friend = myFriends[indexPath.row]
        cell.viewModel = MyFriendCellViewModel(friend: friend)
        // assign index of the button to its tag, so later on we can access the index via tag
        cell.removeButton.tag = indexPath.row
        return cell
        
    }
    
}


//MARK: - UITableViewDelegate

extension MyFriendsController {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // load more post when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y
        let b = tableView.contentSize.height - tableView.frame.height + 60

        if a > b && isLoadMoreFriends == true {
            loadMyFriends(isLoadMore: true)
        }
    }
    
}



