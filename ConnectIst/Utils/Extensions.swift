//
//  Extensions.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 15.02.2021.
//

import UIKit
//import JGProgressHUD


//MARK: - UIViewController


extension UIViewController {
//    static let hud = JGProgressHUD(style: .dark)
    
    func configureGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
//    func showLoader(_ show: Bool) {
//        view.endEditing(true)
//
//        if show {
//            UIViewController.hud.show(in: view)
//        } else {
//            UIViewController.hud.dismiss()
//        }
//    }
    
    func showMessage(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UILabel

extension UILabel {
    
    func attributedDetailText(firstPart: String, secondPart: String) {
        
        let boldText = firstPart
        let firstAttrs = [NSAttributedString.Key.font : UIFont(name: "Georgia", size: 15),
                          .foregroundColor: UIColor.red]
        let attributedString = NSMutableAttributedString(string:"\(boldText) ", attributes:firstAttrs as [NSAttributedString.Key : Any])
        let normalText = secondPart
        let secondAttrs = [NSAttributedString.Key.font : UIFont(name: "Georgia", size: 15),
                           .foregroundColor: UIColor.systemBlue]
        let normalString = NSMutableAttributedString(string:normalText, attributes: secondAttrs as [NSAttributedString.Key : Any])
        attributedString.append(normalString)
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        textAlignment = .justified
        
    }
}


//MARK: - UITextField







//MARK: - UIButton

// To cut more line of codes for creating UIButtons instead of creating new class and swift file.
extension UIButton {
    
    // adjust the icon and title position
    func centerVertically() {
        
        // adjust title's width
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: -15)
        
        // vertical position of the title
        let padding = self.frame.height + 10
        
        // accessing sizes
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        // applying the final appearance of the icon's insets
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleSize.height)
        
        // applying the final position of title by vertical
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.height, bottom: -(totalHeight - titleSize.height), right: 0)
    }
    
    // manipulate the appearance of addFriend Button based on has request been sent or not
    func manipulateAddFriendButton (friendRequestType: Int, isShowingTitle: Bool) {
        // title of the button
        showTitleOfFriendButton(friendRequestType, showTitle: isShowingTitle)
        
        // icon of the button
        if friendRequestType == 1 { // current user got requested by the guest (guest-user)
            setBackgroundImage(#imageLiteral(resourceName: "friend"), for: .normal)
            tintColor = K.facebookColor
        } else if friendRequestType == 0 { // not requested
            setBackgroundImage(#imageLiteral(resourceName: "unfriend"), for: .normal)
            tintColor = .darkGray

        } else if friendRequestType == 2 { // user requested currentUser to be his/her friend
            setBackgroundImage(#imageLiteral(resourceName: "respond"), for: .normal)
            tintColor = K.facebookColor
            
        } else if friendRequestType == 3 { // they are friends
            setBackgroundImage(#imageLiteral(resourceName: "friends"), for: .normal)
            tintColor = K.facebookColor
        }
        
        
    }
    
    // associated with func above
    private func showTitleOfFriendButton(_ requestType: Int, showTitle: Bool) {
        if showTitle {
            if requestType == 1 {
                setTitle("Requested", for: .normal)
                titleLabel?.textColor = K.facebookColor
            } else if requestType == 0 {
                setTitle("Add", for: .normal)
                titleLabel?.textColor = .darkGray
            } else if requestType == 2 {
                setTitle("Respond", for: .normal)
                titleLabel?.textColor = K.facebookColor
            } else if requestType == 3 {
                setTitle("Friends", for: .normal)
                titleLabel?.textColor = K.facebookColor
            }
        }
    }
    //manipulate related button
    func updateButtonIconTitleColor(backgroundImage: UIImage, title: String, color: UIColor) {
        setBackgroundImage(backgroundImage, for: .normal)
        setTitle(title, for: .normal)
        tintColor = color
        titleLabel?.textColor = color
    }
    
    
//    func manipulateFollowButton(followedUser: Int?) {
//        
//        if followedUser != nil {
//            setBackgroundImage(#imageLiteral(resourceName: "follow"), for: .normal)
//            setTitle("Followed", for: .normal)
//            tintColor = UIColor(named: K.facebookColor)
//            titleLabel?.textColor = UIColor(named: K.facebookColor)
//        }
//        
//    }
    
    
    // MARK: -
    
    
    
    
    func attributedTitle(firstPart: String, secondPart: String) {
        let atts: [NSAttributedString.Key: Any] = [
            
            .foregroundColor: UIColor(named: K.Button.Color.alreadySignAndNewUser)!,
            .font: UIFont(name: K.Button.Font.sign, size: 15)!
            
        ]
        
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart) ", attributes: atts)
        
        let boldAtts: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: K.Button.Color.alreadySignAndNewUser)!,
            .font: UIFont(name: K.Button.Font.signMedium, size: 15)!
        ]
        attributedTitle.append(NSAttributedString(string: secondPart, attributes: boldAtts))
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    
    // Creating sign button extensions to handle same UIButton obj
    func createSignButton(buttonLabel: String) {
        
        setTitle(buttonLabel, for: .normal)
        setTitleColor(UIColor(named: K.Button.Color.signText)!.withAlphaComponent(0.5), for: .normal)
        titleLabel?.font = UIFont(name: K.Button.Font.sign, size: 20)
        
        // background color before isEnable = true 
        backgroundColor = UIColor(named: K.Button.Color.signBackground)!.withAlphaComponent(0.5)
        
        // rounded corners
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        // after typing to the textfield it become isEnable = true
        isEnabled = false
        
        setHeight(50)
        
    }
    
    // Change color in order to show how buttons are enabled
    func enableSignButton() {
        isEnabled = true
        setTitleColor(UIColor(named: K.Button.Color.signText)!, for: .normal)
        backgroundColor = UIColor(named: K.Button.Color.signBackground)!
    }
    
    // create HomeVC small buttons
    
    func createSmallBtnHomeScreen(image: UIImage) {
        setImage(image, for: .normal)
        setDimensions(height: 50, width: 50)
        backgroundColor = .clear
        titleLabel?.shadowColor = .clear
        imageView?.contentMode = .scaleAspectFit
        
    }
    
    
    
    
    // MARK: SettingButtons
    
    // Creating new class causes a problem with enabling that's why I created createSettingButtons below.
    func createButtonWithImage(buttonLabel: String, imageName: String) {
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .default)
        let largeBoldDoc = UIImage(systemName: imageName, withConfiguration: largeConfig)
        setImage(largeBoldDoc, for: .normal)
        tintColor = UIColor.white
        
        setTitle(buttonLabel, for: .normal)
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = UIColor.systemBlue
        
        layer.cornerRadius = 10
        titleLabel?.font = UIFont(name: "Georgia", size: 20)
        
        contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        contentEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
    }
    
    func createFeedbackButtonWithImage(buttonLabel: String, imageName: String) {

        let image = UIImage(named: imageName)
        setImage(image, for: .normal)
        tintColor = UIColor.white
        
        setTitle(buttonLabel, for: .normal)
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = UIColor.systemBlue
        
        layer.cornerRadius = 10
        titleLabel?.font = UIFont(name: "Georgia", size: 16)
        
//        imageEdgeInsets = UIEdgeInsets(top: 10, left:15, bottom:10, right:0)
        contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        contentEdgeInsets = UIEdgeInsets(top: 0,left: 15,bottom: 0,right: 0)
    }
    
}

//MARK: - UIImageView

extension UIImageView {
    func downloadedFrom(url: URL, placeHolderImage:UIImage, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                self.image = placeHolderImage
                return
            }
            
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
        }.resume()
    }
    
    func downloadedFrom(link: String, placeHolderImage:UIImage, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, placeHolderImage: placeHolderImage, contentMode: mode)
    }
}


//MARK: - UIView

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, rightAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, paddingRight: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
        
        if let right = rightAnchor {
            anchor(right: right, paddingRight: paddingRight)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor, left: view.leftAnchor,
               bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    //MARK: Animation
    // i have created this in order to execute animation for related view
    func setAnimationForFacebook(scaleX sx: CGFloat, y sy: CGFloat) {
        // animation of zooming / popping
        UIView.animate(withDuration: 0.15) {
            // scale by 30% -> 1.3
            self.transform = CGAffineTransform(scaleX: sx, y: sy)
        } completion: { (completed) in
            // return the initial state
            UIView.animate(withDuration: 0.15) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
}


// MARK: - Hide Keyboard
// called when the screen is tapped (outside of any obj-s)

extension UIViewController {
    // add this function related viewController's viewDidLoad that we want to hide keyboard 
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
