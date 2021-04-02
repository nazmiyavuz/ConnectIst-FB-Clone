//
//  NotificationCell.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 31.03.2021.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: NotificationCellViewModel? {
        didSet { configure() }
    }
    
    // MARK: - Views
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    //MARK: - LifeCycle
    
    // first loading func
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureUI()
        
    }
    
    
    //MARK: - API
    
    
    
    // MARK: - Action
    
    
    
    // MARK: - Helpers
    
    private func configureUI() {
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        
        
    }
    
    
    func configure() {
        
        guard let viewModel = viewModel else { return }
        // change the color of the cell if notification has been viewed already by the current user
        if let viewed = viewModel.viewed {
            if viewed == "yes" {
                contentView.backgroundColor = .white
            }
        } else {
            contentView.backgroundColor = K.facebookColor!.withAlphaComponent(0.15)
        }
        var message = ""
        
        switch viewModel.type {
        case "friend":
            message = " now is your friend."
            iconImageView.image = UIImage(named: "notifications_friend")
        case "follow":
            message = " has started following you."
            iconImageView.image = UIImage(named: "notifications_follow")
        case "like":
            message = " liked your post."
            iconImageView.image = UIImage(named: "notifications_like")
        case "comment":
            message = " has commented your post."
            iconImageView.image = UIImage(named: "notifications_comment")
        case "ava":
            message = " has changed her/his profile picture."
            iconImageView.image = UIImage(named: "notifications_update")
        case "cover":
            message = " has changed her/his cover."
            iconImageView.image = UIImage(named: "notifications_update")
        case "bio":
            message = " has updated her/his bio"
            iconImageView.image = UIImage(named: "notifications_update")
        default:
            message = ""
        }
        
        // custom format of the message: bold + regular
        let boldString = NSMutableAttributedString(string: viewModel.fullName.capitalized, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.boldSystemFont(ofSize: 17)])
        let regularString = NSMutableAttributedString(string: message)
        boldString.append(regularString)
        messageLabel.attributedText = boldString
        
        guard let avaUrl = viewModel.avaPath else { return }
        avaImageView.downloadedFrom(url: avaUrl, placeHolderImage: #imageLiteral(resourceName: "userImage"))
        
    }
    
    
    
}

