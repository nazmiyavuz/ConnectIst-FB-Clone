//
//  RequestUserCell.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 14.03.2021.
//

import UIKit

// Delegate protocol to be sent to the motherViewController along with the data (s.g. action, cell)
protocol RequestUserCellDelegate: class {
    
    func updateFriendshipRequestDelegate(status: Int, from cell: UITableViewCell)
    
}


class RequestUserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var requestUserCellDelegate: RequestUserCellDelegate?
    
    var userId = Int()
    
    
    
    // MARK: - Views
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    //MARK: - LifeCycle
    
    // first loading func
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureUI()
        
    }
    
    
    //MARK: - API
    
    
    private func confirmRejectRequestOrDeleteFriend(action: UserServiceAction, userId: Int, friendId: Int) {
        
        
        UserService.shared.confirmRejectRequestOrDeleteFriend(userId: userId, friendId: friendId, action: action,
                                                  selfVC: FriendsController()) { (response) in
            switch response {
            
            case .failure(let error) :
                print("DEBUG: JSON Error: ", error.localizedDescription)
                Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: FriendsController())
                
            case .success(let status):
                
                if status.status == "200" {
                    print("DEBUG: Request has been \(action.rawValue)ed successfully, \nDEBUG: Data: \(status)")
                }
                
                
            }
        }
    }
    
    
    //MARK: - Private Functions
    
    private func hideButtonsShowMessage() {
        
        // hide buttons and show label
        confirmButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        
    }
    
    // MARK: - Action
    

    @IBAction func confirmButton_clicked(_ sender: UIButton) {
        guard let friendID = currentUser?.id else { return }
        // massage in the label
        messageLabel.text = "Request accepted"
        
        hideButtonsShowMessage()
        
        confirmRejectRequestOrDeleteFriend(action: .confirm, userId: userId, friendId: friendID)
        
        // execute / send protocol and assign to it data: 'confirm' and 'current cell'
        requestUserCellDelegate?.updateFriendshipRequestDelegate(status: 3, from: self)
        
        
    }
    
    @IBAction func deleteButton_clicked(_ sender: UIButton) {
        guard let friendID = currentUser?.id else { return }
        // massage in the label
        messageLabel.text = "Request removed"
        
        hideButtonsShowMessage()
        confirmRejectRequestOrDeleteFriend(action: .reject, userId: userId, friendId: friendID)
        // execute / send protocol and assign to it data: 'confirm' and 'current cell'
        requestUserCellDelegate?.updateFriendshipRequestDelegate(status: 0, from: self)
        
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        
        // border for delete button
        let border = CALayer()
        border.borderWidth = 1.5
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: deleteButton.frame.width, height: deleteButton.frame.height)
        
        // assigning border to delete button and making corners rounded
        deleteButton.layer.addSublayer(border)
        deleteButton.layer.cornerRadius = 3
        deleteButton.layer.masksToBounds = true
        
        // rounded corners for confirmButton
        confirmButton.layer.cornerRadius = 3
        confirmButton.layer.masksToBounds = true
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
    }
    
    
    
    
    
}

