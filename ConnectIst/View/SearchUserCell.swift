//
//  SearchUserCell.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 7.03.2021.
//

import UIKit

class SearchUserCell: UITableViewCell {
    
    
    // MARK: - Properties
        
       
        
    
    // MARK: - Views
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var friendButton: UIButton!
    
    
    
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
    }
    
   

}
