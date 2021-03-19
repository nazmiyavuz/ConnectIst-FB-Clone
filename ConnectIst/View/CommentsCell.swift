//
//  CommentsCell.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 3.03.2021.
//

import UIKit

class CommentsCell: UITableViewCell {

    
// MARK: - Properties
    
    
    
// MARK: - Views
    // UI obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    
//MARK: - LifeCycle

    // first loading func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
        
    }

    
    
    
//MARK: - API

    
    
// MARK: - Action
    
    
    
// MARK: - Helpers
    
    
    
    
}


