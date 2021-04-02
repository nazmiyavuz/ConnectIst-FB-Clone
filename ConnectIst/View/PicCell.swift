//
//  PicCell.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 27.02.2021.
//

import UIKit

class PicCell: UITableViewCell {

// MARK: - Properties
    
    // declare view model to assign values to the UIObjects
    var postViewModel: PostViewModel? {
        didSet {
            
            configure()
//            if comingFromVC == "other" {
//                configure(isComingFromFeed: false)
//            }
        }
    }
    
    var feedPostViewModel: FeedPostViewModel? {
        didSet {
            configureWithFeedVC()
//            if comingFromVC == "feed" {
//                configure(isComingFromFeed: true)
//            }
        }
    }
    
            
// MARK: - Views
                
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var pictureImageView_height: NSLayoutConstraint!
    
    
//MARK: - LifeCycle
        
        // first load function
        override func awakeFromNib() {
            super.awakeFromNib()
            
            // rounded corners
            avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
            avaImageView.clipsToBounds = true
            
        }

        

//MARK: - API
            
            
            
// MARK: - Action
            
            
            
// MARK: - Helpers
    
    
//    private func configurePictureImageView() {
//
//        let image = pictureImageView.image
//
////        let ratio = image!.size.width / image!.size.height
//
//        let newHeight = image!.size.width
//        let newWidth = image!.size.height
//
//        pictureImageView.frame.size = CGSize(width: newWidth, height: newHeight)
//
//
//    }
    
    
    
    
    // configure UIObjects values that come from server and HomeController
    
    private func configureWithFeedVC() {
        guard let viewModel = feedPostViewModel else { return }
        
        fullNameLabel.text = viewModel.fullName.capitalized
        dateLabel.text = Helper.shared.formatDateCreated(with: viewModel.dateCreated)
        postTextLabel.text = viewModel.text
        
        guard let avaUrl = viewModel.avaPath else { return }
        avaImageView.downloadedFrom(url: avaUrl, placeHolderImage: #imageLiteral(resourceName: "userImage"))
        
        guard let pictureUrl = viewModel.picturePath else { return }
        pictureImageView.downloadedFrom(url: pictureUrl, placeHolderImage: #imageLiteral(resourceName: "homeCoverImage"))
        
        DispatchQueue.main.async { [self] in
            if viewModel.liked != nil {
                likeButton.setImage(UIImage(named: "like"), for: .normal)
                likeButton.tintColor = K.Button.Color.likeButtonColor
            } else {
                likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                likeButton.tintColor = .darkGray
            }
        }
    }
    
    
    private func configure() {
        
        
        
        guard let viewModel = postViewModel else { return }
        
        // fullName logic
        fullNameLabel.text = viewModel.fullName.capitalized
        // date logic
        dateLabel.text = Helper.shared.formatDateCreated(with: viewModel.date_created)
        // text logic
        postTextLabel.text = viewModel.text
        
        
        
//        //manipulating the appearance of the button based is the post has been liked or not
//        if viewModel.liked != nil {
//            likeButton.setImage(UIImage(named: "like"), for: .normal)
//        } else {
//            likeButton.setImage(UIImage(named: "unlike"), for: .normal)
//        }
        
    }
}


