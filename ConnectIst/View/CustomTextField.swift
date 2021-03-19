//
//  CustomTextField.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 15.02.2021.
//

import UIKit

class LoginAndRegistrationTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        
        // add blank view to the left side of the TextField (it'll act as a blank gap)
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        leftView = spacer
        leftViewMode = .always
        
        // declare background color (you should generally use UIColor to support dark mode / dynamic color)
        backgroundColor = UIColor(named: K.TextField.Color.signBackground)!
        
        // rounded corners
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        // show clear button while editing
        clearButtonMode = .whileEditing
        
        // text properties (color and font)
        textColor = UIColor(named: K.TextField.Color.signText)!
        font = UIFont(name: K.TextField.Font.sign, size: 15)!
        
        // setting placeholder color and font properties
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(named: K.TextField.Color.signText)!.withAlphaComponent(0.5),
                .font: UIFont(name: K.TextField.Font.sign, size: 15)!
            ]
        )
        
        
        keyboardAppearance = .dark
        setHeight(50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

