//
//  NoPicCell.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 27.02.2021.
//

import UIKit

class NoPicCell: UITableViewCell {

// MARK: - Properties
    
    // declare view model to assign values to the UIObjects
    var postViewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    var feedPostViewModel: FeedPostViewModel? {
        didSet {
            configureWithFeedVC()
        }
    }
    
     
// MARK: - Views
            
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    
    
    
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
    
    private func configureWithFeedVC() {
        guard let viewModel = feedPostViewModel else { return }
        
        fullNameLabel.text = viewModel.fullName.capitalized
        dateLabel.text = Helper.shared.formatDateCreated(with: viewModel.dateCreated)
        postTextLabel.text = viewModel.text
        
        guard let avaUrl = viewModel.avaPath else { return }
        avaImageView.downloadedFrom(url: avaUrl, placeHolderImage: #imageLiteral(resourceName: "userImage"))
        
        
        
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
    
    // configure UIObjects values that come from server and HomeController
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
