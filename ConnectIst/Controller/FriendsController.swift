//
//  SearchController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 7.03.2021.
//

import UIKit



private let reuseIdentifierForFriend = "FriendsCell"
private let reuseIdentifierForRequests = "RequestCell"



class FriendsController: UIViewController {
    
// MARK: - Properties
        
    // PART 1 Searching
    // users objects
    var searchedUsers = [User]()
//    var searchedUsers = [NSDictionary]()
    var searchedUsersAvas = [UIImage]()
    var friendshipStatus = [Int]()
        
    // Int TODO: Be careful while using skip the cause of most json error is wrong usage of skip.
    var limitOfSearch: Int = 15
    var skipOfSearch: Int = 0
    
    
    // Bool
    var isLoadingUsers: Bool = false
    var isLoadingRequests: Bool = false
    var isSearchedUserStatusUpdated = false
    
    
    // PART 2 Requests and Friends
    var requestedUsers = [RequestedUser]()
    var requestedUsersAvas = [UIImage]()
    var limitOfRequestedUsers: Int = 15
    var skipOfRequestedUsers: Int = 0
    var requestedHeaders = ["FRIEND REQUESTS"]
    var friendStatusForRequest = [Int]()
    
    
    
// MARK: - Views
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    let searchBar = UISearchBar()
    
//MARK: - LifeCycle

    // first loading func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call functions
        createSearchBar()
        configureUI()
        
        loadRequests(isFirstLoading: true)
        
    }
    
    // last load func
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        NotificationCenter.default.removeObserver(Notification.Name("friend"))
    }
    
    
//MARK: - API
    
    
    private func searchUsers(isFirstLoading: Bool) {

        guard let searchText = searchBar.text else { return }

        isLoadingUsers = true

        UserService.shared.searchUsers(name: searchText, limit: limitOfSearch, offset: skipOfSearch, action: .search, selfVC: self) { (response) in

            switch response {

            case .failure(let error):
                print("DEBUG: JSON Error: ", error.localizedDescription)
//                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                self.isLoadingUsers = false
                
                self.removeSearchedDatas()
                
                self.searchTableView.reloadData()
                
                
            case .success(let users):
                
                if isFirstLoading {
                    self.searchedUsers = users
//                    print("DEBUG: request id unFollowed user =  ",self.searchedUsers[3].requested)
                    
                    self.loadIsFriendshipStatusToAvoidAnyBug(with: self.searchedUsers)
                    
                    if self.searchedUsers.count > self.limitOfSearch {
                        // update skip value for further load (skip already loaded users
                        self.skipOfSearch = users.count
                    }
                    self.searchTableView.reloadData()

                } else {
                    // add in existing array with data, more data
                    self.searchedUsers.append(contentsOf: users)
                    // increment offset (skip all previously loaded users
                    self.skipOfSearch += users.count
                    
                    self.loadIsFriendshipStatusToAvoidAnyBug(with: self.searchedUsers)

                    // insert new cells
                    self.searchTableView.beginUpdates()

                    for i in 0 ..< users.count {
                        let lastSectionIndex = self.searchTableView.numberOfSections - 1
                        let lastRowIndex = self.searchTableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.searchTableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    self.searchTableView.endUpdates()
                }
                self.isLoadingUsers = false
            }
        }
    }
    
    
    private func searchUserss(isFirstLoading: Bool) {
        
    }
    
    private func loadAvaImageViews(indexPathRow: Int, imageView: UIImageView) {
        
        // avas logic
        let avaString = searchedUsers[indexPathRow].ava
        let avaURL = URL(string: avaString)!
        
        // if there are still avas to be loaded
        if searchedUsers.count != searchedUsersAvas.count {
            
            URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                
                // failed downloading - assign placeholder
                if error != nil {
                    if let image = UIImage(named: "userImage") {
                        
                        self.searchedUsersAvas.append(image)
//                            print("DEBUG: AVA assigned")
                        
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }
                
                // downloaded
                if let image = UIImage(data: data!) {
                    
                    self.searchedUsersAvas.append(image)
//                        print("DEBUG: AVA loaded")
                    
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
                
            }.resume()
            
        // cached ava
        } else {
//                print("DEBUG: AVA cached")
            
            DispatchQueue.main.async {
                imageView.image = self.searchedUsersAvas[indexPathRow]
            }
        }
    }
    
    // update request (confirm / reject / send based on the action)
    private func updateFriendshipRequest(action: UserServiceAction ,userId: Int, friendId:Int) {
        
        UserService.shared.sendFriendRequest(userId: userId, friendId: friendId, action: action,
                                             selfVC: self) { (response) in
            
            switch response {
            
            case .failure(let error) :
                print("DEBUG: JSON Error: ", error.localizedDescription)
                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                
            case .success(let data) :
                
                if data["status"] as! String == "200" {

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
    
    
    private func loadRequests(isFirstLoading: Bool) {
        
        isLoadingRequests = true
        
        UserService.shared.loadRequests(limit: limitOfRequestedUsers, offset: skipOfRequestedUsers,
                                        action: .requests,
                                        selfVC: self) { (response) in
            
            switch response {
            
            case .failure(let error):
                
                print("DEBUG: JSON Error: ", error.localizedDescription)
                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                self.isLoadingRequests = false
                
            case .success(let users):
                
                if isFirstLoading {
                    // assigning all loaded requests from json to [RequestedUser]
                    self.requestedUsers = users
                    
                    for _ in users {
                        self.friendStatusForRequest.append(2)
                    }
                    // assigning skip value to skip already loaded requests in further pagination
                    self.skipOfRequestedUsers = users.count
                    // reloading tableView to show all requests
                    self.friendsTableView.reloadData()
                    
                }
            }
        }
    }
    
    
    private func loadAvaImageViewsForRequests(indexPathRow: Int, imageView: UIImageView) {
        
        // avas logic
        let avaString = requestedUsers[indexPathRow].ava ?? String()
        let avaURL = URL(string: avaString)!
        
        // if there are still avas to be loaded
        if requestedUsers.count != requestedUsersAvas.count {
            
            URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                
                // failed downloading - assign placeholder
                if error != nil {
                    if let image = UIImage(named: "userImage") {
                        
                        self.requestedUsersAvas.append(image)
//                            print("DEBUG: AVA assigned")
                        
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }
                
                // downloaded
                if let image = UIImage(data: data!) {
                    
                    self.requestedUsersAvas.append(image)
//                        print("DEBUG: AVA loaded")
                    
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
                
            }.resume()
            
        // cached ava
        } else {
//                print("DEBUG: AVA cached")
            
            DispatchQueue.main.async {
                imageView.image = self.requestedUsersAvas[indexPathRow]
            }
        }
    }
    
//MARK: - Private Functions
    
    
    private func loadIsFriendshipStatusToAvoidAnyBug(with searchedUsers: [User]) {
        
        guard let currentUserId = currentUser?.id else { return }
        
        self.friendshipStatus.removeAll(keepingCapacity: false)
        
        // checking friendship status of every user
        for user in searchedUsers {
            
            // request sender is current user
            if user.requestSender != nil && user.requestSender == currentUserId {
                self.friendshipStatus.append(1)
            // request is received by current user
            } else if user.requestReceiver != nil && user.requestReceiver == currentUserId {
                self.friendshipStatus.append(2)
            // current user is the one who sent invitation of friendship which got accepted
            } else if user.friendshipSender != nil {
                self.friendshipStatus.append(3)
            // current user is the one who accepted the friendship
            } else if user.friendshipReceiver != nil {
                self.friendshipStatus.append(3)
            // all other possible scenarios or failures
            } else {
                self.friendshipStatus.append(0)
            }
        }
    }
    
    
//    private func changeFriendButtonImage(indexPathRow: Int, friendButton: UIButton) {
//
//        // in the extension document
//        friendButton.manipulateAddFriendButton(friendRequestType: self.isRequestedUsers[indexPathRow], isShowingTitle: false)
//
//    }
    
    private func removeSearchedDatas() {
        searchedUsers.removeAll(keepingCapacity: false)
        searchedUsersAvas.removeAll(keepingCapacity: false)
        friendshipStatus.removeAll(keepingCapacity: false)
    }
    
    private func removeRequestDatas() {
        requestedUsers.removeAll(keepingCapacity: false)
        requestedUsersAvas.removeAll(keepingCapacity: false)
        skipOfRequestedUsers = 0
    }
    
// MARK: - Action
    
    // in the searchUserCell
    @IBAction func friendButton_clicked(_ friendButton: UIButton) {
        
        // accessing indexPath.row of pressed button
        let indexPathRow = friendButton.tag
        
        // access id of current user stored in the global var - currentUser
        guard let userId = currentUser?.id else { return }
        // accessing id of the user searched and clicked on
        let friendId = searchedUsers[indexPathRow].id
        
        
        // current user didn't send friendship request -> send it
        if friendshipStatus[indexPathRow] == 0 {
            //update status in the app logic
            friendshipStatus[indexPathRow] = 1
            // send request to the server
            updateFriendshipRequest(action: .add, userId: userId, friendId: friendId)
            friendButton.manipulateAddFriendButton(friendRequestType: self.friendshipStatus[indexPathRow], isShowingTitle: false)
            
            
        // current user sent friendship request -> cancel it
        } else if friendshipStatus[indexPathRow] == 1 {
            //update status in the app logic
            friendshipStatus[indexPathRow] = 0
            // send request to the server
            updateFriendshipRequest(action: .reject, userId: userId, friendId: friendId)
            
            friendButton.manipulateAddFriendButton(friendRequestType: self.friendshipStatus[indexPathRow], isShowingTitle: false)
        //current user received friendship request -> show action sheet
        } else if friendshipStatus[indexPathRow] == 2 {
            //show action sheet to update request: confirm or delete
            showActionSheet(button: friendButton, friendUserId: friendId, currentUserId: userId, indexPathRow: indexPathRow)
            
            
        // current user and searched users are friends -> show action sheet
        } else if friendshipStatus[indexPathRow] == 3 {
            // show action sheet to update friendship: delete
            showActionSheet(button: friendButton, friendUserId: friendId, currentUserId: userId, indexPathRow: indexPathRow)
        }
        
        
        print(self.friendshipStatus[indexPathRow])
        
    }
    
    
    
    // shows action sheet for friendship further action
    private func showActionSheet(button: UIButton,friendUserId: Int, currentUserId: Int, indexPathRow: Int) {
        
        // declaring sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            // send request
            if self.friendshipStatus[indexPathRow] == 2 { // current user received friendship request -> trigger rejection
                self.confirmRejectRequestOrDeleteFriend(action: .reject, userId: friendUserId , friendId: currentUserId)
            } else { // current user received friendship request -> trigger delete
                self.confirmRejectRequestOrDeleteFriend(action: .delete, userId: currentUserId , friendId: friendUserId)
                self.confirmRejectRequestOrDeleteFriend(action: .delete, userId: friendUserId , friendId: currentUserId)
            }
            // update status -> no more any relations
            self.friendshipStatus[indexPathRow] = 0
            button.manipulateAddFriendButton(friendRequestType: self.friendshipStatus[indexPathRow], isShowingTitle: false)
            
        }
        
        // confirm button
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            // update status -> now friends
            self.friendshipStatus[indexPathRow] = 3
            // accept request
            self.confirmRejectRequestOrDeleteFriend(action: .confirm, userId: friendUserId, friendId: currentUserId)
            button.manipulateAddFriendButton(friendRequestType: self.friendshipStatus[indexPathRow], isShowingTitle: false)
        }
        // cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // assigning all buttons to the sheet
        sheet.addAction(delete)
        // show confirm button only if current user received friendship request. Hide confirm button if users are already friends
        if friendshipStatus[indexPathRow] == 2 {
            sheet.addAction(confirm)
        }
        sheet.addAction(cancel)
        // showing sheet
        present(sheet, animated: true, completion: nil)
    }
    
    
    
    // executed before segue finishes
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // access controller in order to its vars
        let guestController = segue.destination as! GuestController
        
        // going Guest from SearchTableView (tapped on the searched user)
        // exec-d once GuestVC-Segue (id) is executed (id is declared in Main.storyboard)
        if segue.identifier == K.Segue.friendVCToGuestVC_searchTableView {
            
            // access index of selected cell in order to access index of searchedUsers
            guard let indexPath = searchTableView.indexPathForSelectedRow else { return }
            
            guestController.comingFromTableView = "search"
            guestController.guestControllerDelegate = self
            guestController.friendshipStatus = friendshipStatus[indexPath.row]
            guestController.guestViewModel = GuestViewModel(user: searchedUsers[indexPath.row])
            
            print("***************************************************************")
            
            print("DEBUG: passed user information \(searchedUsers[indexPath.row])")
            
            
        // going Guest from FriendsTableView (tapped on a friend or request)
        } else if segue.identifier == K.Segue.friendVCToGuestVC_friendTableView {
            
            // access index of selected cell in order to access index of searchedUsers
            guard let indexPath = friendsTableView.indexPathForSelectedRow else { return }
            
            guestController.comingFromTableView = "friend"
            guestController.friendshipStatus = friendStatusForRequest[indexPath.row]
            guestController.guestControllerDelegate = self
            guestController.guestViewModelForRequest = GuestViewModelForRequests(
                requestedUser: requestedUsers[indexPath.row]) // =3 -> request is received by current user
            
        }
    }
    
    
    
// MARK: - Helpers
    
    
    // configure user interface
    private func configureUI(){
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        // auto-determined cell height (tableView row height)
//        tableViewToSearch.rowHeight = UITableView.automaticDimension
//        tableViewToSearch.estimatedRowHeight = 100
        
    }
    
    // create search bar programmatically
    func createSearchBar() {
        
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        
        // accessing child view - textField inside of searchBar
        let searchBar_textField = searchBar.value(forKey: "searchField") as? UITextField
        searchBar_textField?.textColor = .white
        searchBar_textField?.tintColor = .white
        // inserting search bar into navigationBar
        self.navigationItem.titleView = searchBar
        
        
        
    }
    
    // executed always whenever tableView is scrolling
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        // load more post when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = searchTableView.contentOffset.y
        let b = searchTableView.contentSize.height - searchTableView.frame.height + 60

        if a > b && isLoadingUsers == false && searchedUsers.count > limitOfSearch {
            
            searchUsers(isFirstLoading: false)
            
        }
    }
    
    
}



//MARK: - UISearchBar

extension FriendsController: UISearchBarDelegate {
    // once searchBar is tapped
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // show cancel button
        searchBar.setShowsCancelButton(true, animated: true)
        
        // show tableView that presents searched users
//        tableViewToSearch.isHidden = false
    }
    
    // cancel button in the searchBar has been clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // hide cancel button
        searchBar.setShowsCancelButton(false, animated: true)
        // reload friendsTableView data from server
        self.removeRequestDatas()
        self.loadRequests(isFirstLoading: true)
        self.friendsTableView.reloadData()
        
        removeSearchedDatas()
        searchTableView.reloadData()
        // hide tableView that presents searched users
        searchTableView.isHidden = true
        self.removeRequestDatas()
        self.loadRequests(isFirstLoading: true)
        
        self.searchBar.text = ""
        
        self.skipOfSearch = 0
        
        // hide keyboard
        searchBar.resignFirstResponder()
    }
    
    // called whenever we type any letter in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            self.skipOfSearch = 0
            // reload friendsTableView data from server
            self.removeRequestDatas()
            self.loadRequests(isFirstLoading: true)
            self.friendsTableView.reloadData()
            
            removeSearchedDatas()
            self.searchTableView.reloadData()
            self.searchTableView.isHidden = true
            
            
        } else {
            self.searchTableView.isHidden = false
            searchUsers(isFirstLoading: true)
        }

    }
    
    
}


//MARK: - UITableViewDataSource
extension FriendsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // for tableViewToSearch shows total number of cells equal to searchedUsers
        if tableView == searchTableView {
            return searchedUsers.count
            
        // for other tableViews (tableViewToHandleRequests) shows total number of cells equal to requestedUsers
        } else {
            return requestedUsers.count
        }
        
    }
    
    // section header of cells
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // for tableViewToHandleRequests only show headers
        if tableView == friendsTableView {
            if section < requestedHeaders.count {
                return requestedHeaders[section]
            }
        }
        
        return nil
    }
    
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if tableView == searchTableView {
            
            let cell = searchTableView.dequeueReusableCell(withIdentifier: reuseIdentifierForFriend, for: indexPath) as! SearchUserCell
            
            let user = searchedUsers[indexPath.row]
            cell.fullNameLabel.text = user.fullName.capitalized
            cell.friendButton.tag = indexPath.row
            
            loadAvaImageViews(indexPathRow: indexPath.row, imageView: cell.avaImageView)
            
            // manipulate appearance of friendButton
            DispatchQueue.main.async {
                // if searched user is not allowing a friendship request - hide "send request button" in the cell
                if self.searchedUsers[indexPath.row].allowFriends == 0 && self.friendshipStatus[indexPath.row] != 2 {
                    cell.friendButton.isHidden = true
                    cell.accessoryType = .disclosureIndicator
                } else {
                    cell.friendButton.isHidden = false
                    cell.accessoryType = .none
                }
                
                let requestType = self.friendshipStatus[indexPath.row]
                cell.friendButton.manipulateAddFriendButton(friendRequestType: requestType, isShowingTitle: false)
                
            }
            return cell
            
        // configure cell of tableViewToHandleRequests
        } else {
            
            let cell = friendsTableView.dequeueReusableCell(withIdentifier: reuseIdentifierForRequests, for: indexPath) as! RequestUserCell
            
            let user = requestedUsers[indexPath.row]
            cell.fullNameLabel.text = user.fullName.capitalized
            cell.userId = user.id
            // creating delegate relations from the cell to current vc in order to access protocols of the delegate class
            cell.requestUserCellDelegate = self
            
            loadAvaImageViewsForRequests(indexPathRow: indexPath.row, imageView: cell.avaImageView)
            
            
            return cell
        }
        
    }
    
    
    
}


//MARK: - UITableViewDelegate

extension FriendsController: UITableViewDelegate {

    // height of cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // accessing header
        let header = view as! UITableViewHeaderFooterView
        
        // change font and text color
        header.textLabel?.font = UIFont(name: K.Font.helveticaNeue_light, size: 12)!
        header.textLabel?.textColor = .darkGray
        
        
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }

}

//MARK: - GuestControllerDelegate


extension FriendsController: GuestControllerDelegate {
    
    
    func didChangeFriendList() {
        
            
        searchedUsers.removeAll(keepingCapacity: false)
        searchedUsersAvas.removeAll(keepingCapacity: false)
        friendshipStatus.removeAll(keepingCapacity: false)
        
        searchUsers(isFirstLoading: true)
         
    }
    
    func didChangeRequestList() {
        // reload content of arrays
        requestedUsers.removeAll(keepingCapacity: false)
        requestedUsersAvas.removeAll(keepingCapacity: false)
        // FIXME: Add status
        skipOfRequestedUsers = 0
        
        loadRequests(isFirstLoading: true)
        
        friendsTableView.reloadData()
    }
}

//MARK: - RequestUserCellDelegate

extension FriendsController: RequestUserCellDelegate {
    
    // @delegate received / caught from the cell. This delegate is having assigned data / information to: 'action' and 'cell' vars
    func updateFriendshipRequestDelegate(status: Int, from cell: UITableViewCell) {
        
        // getting indexPath of the cell
        guard let indexPath = friendsTableView.indexPath(for: cell) else { return }
        // if added as friend, update in app logic
//        if action.rawValue == "confirm" {
//            friendshipStatus.append(3)
//        } else {
//            friendshipStatus.append(0)
//        }
        
        friendStatusForRequest.insert(status, at: indexPath.row)
        
        // getting userId (person who wants to add to be his/her friend)
        let userId = requestedUsers[indexPath.row].id
        // getting friendId (currentUser.id)
        guard let friendId = currentUser?.id else { return }
        
        
        
    }
}



