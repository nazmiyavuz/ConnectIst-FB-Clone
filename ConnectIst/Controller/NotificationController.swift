//
//  NotificationController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 31.03.2021.
//

import UIKit

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationController: UITableViewController {
    
    
    // MARK: - Properties
    
    var notificationItems = [NotificationItem]()
    var limitOfNotification = 15
    var skipOfNotification = 0
    
    var isMoreLoadingNotification = false
    
    // MARK: - Views
    
    
    
    //MARK: - LifeCycle
    
    // first loading func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavBar()
        
        loadNotifications(isFirstLoading: true)
        
    }
    
    
    //MARK: - API
    
    private func loadNotifications(isFirstLoading: Bool) {
        
        guard let currentUserId = currentUser?.id else { return }
        
        NotificationService.loadNotifications(userId: currentUserId, limit: limitOfNotification, offset: skipOfNotification,
                                              selfVC: self) { [self] (response) in
            switch response {
            case .failure(let error):
                print("DEBUG: JSON Error: ", error.localizedDescription)
                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                
            case .success(let items):
                
                if isFirstLoading {
                    self.notificationItems = items
                    
                    if items.count == self.limitOfNotification {
                        // update skip value for further load (skip already loaded users
                        self.skipOfNotification = items.count
                        isMoreLoadingNotification = true
                    }
                    self.tableView.reloadData()
                } else {
                    self.notificationItems.append(contentsOf: items)
                    self.skipOfNotification += items.count
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.reloadData()
                    }
                }
                for item in items {
                    NotificationService.updateNotification(id: item.id, viewed: "yes")
                }
            }
        }
    }
    
    //MARK: - Private Functions
    
    
    private func showActionSheet(indexPath: IndexPath) {
        
        // creating alert controller
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // creating buttons for action sheet
        let hide = UIAlertAction(title: "Hide", style: .default) { (action) in
            // update view status on the server
            NotificationService.updateNotification(id: self.notificationItems[indexPath.row].id,
                                                   viewed: "ignore")
            // remove notification from the skeleton - clean up array from the element
            self.notificationItems.remove(at: indexPath.row)
            // remove the cell itself
            self.tableView.deleteRows(at: [indexPath], with: .left)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView.reloadData()
            }
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // add buttons to the alert controller
        sheet.addAction(hide)
        sheet.addAction(cancel)
        // show alert controller
        present(sheet, animated: true, completion: nil)
        
    }
    
    // MARK: - Action
    
    
    
    // MARK: - Helpers
    
    
    private func configureUI() {

//        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func configureNavBar() {
        
        
    }
    
    
}


//MARK: - UITableViewDataSource
extension NotificationController {
    
    // returning number of rows in the tableView - number of comments
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationItems.count
    }
    
    //assign data to the cell's objects
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the cell of the tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        
        let item = notificationItems[indexPath.row]
        cell.viewModel = NotificationCellViewModel(notificationItem: item)
        
        return cell
        
    }
    
}


//MARK: - UITableViewDelegate

extension NotificationController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // executed always whenever tableView is scrolling
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {


        // load more post when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y
        let b = tableView.contentSize.height - tableView.frame.height + 60

        if a > b && isMoreLoadingNotification == true {
            loadNotifications(isFirstLoading: false)
            print("*******************************************")
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showActionSheet(indexPath: indexPath)
    }
}


