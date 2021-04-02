//
//  MyFriendCell.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 1.04.2021.
//

import UIKit

class MyFriendCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: MyFriendCellViewModel? {
        didSet { configure() }
    }
    
    // MARK: - Views
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    
    
    //MARK: - LifeCycle
    
    // first loading func
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureUI()
        
    }
    
    
    //MARK: - API
    
    
    
    
    //MARK: - Private Functions
    
    
    
    
    // MARK: - Action
    
    
    
    // MARK: - Helpers
    
    private func configureUI() {
        // create border for the remove button
        let border = CALayer()
        border.borderWidth = 2
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: removeButton.frame.width, height: removeButton.frame.height)
        
        // assign border and make corners rounded
        removeButton.layer.addSublayer(border)
        removeButton.layer.cornerRadius = 3
        removeButton.layer.masksToBounds = true
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
    }
    
    func configure() {
        
        guard let viewModel = viewModel else { return }
        
        fullNameLabel.text = viewModel.fullName.capitalized
        
        guard let avaUrl = viewModel.avaPath else { return }
        avaImageView.downloadedFrom(url: avaUrl, placeHolderImage: #imageLiteral(resourceName: "userImage"))
        
    }
    
    
}

