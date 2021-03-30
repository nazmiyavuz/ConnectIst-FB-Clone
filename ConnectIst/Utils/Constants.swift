//
//  Constants.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 15.02.2021.
//

import UIKit


// use constant values in order to minimize error during code
struct K {
    
    static let userImage = "userImage"
    static let homeCoverImage = "homeCoverImage"
    static let facebookColor = UIColor(named: "facebookColor")
    static let searchTableView = "search"
    static let friendsTableViewRequestCell = "request"
    static let friendsTableViewRecommendedCell = "recommended"
    
    //    static let cellIdentifier = "ReusableCell"
    //    static let cellNibName = "MessageCell"
    //    static let registerSegue = "RegisterToChat"
    //    static let loginSegue = "LoginToChat"
    
    struct Segue {
        static let homeVCToCommentVC = "CommentsVC"
        static let friendVCToGuestVC_searchTableView = "ToGuestVCSearchTableView"
        static let friendVCToGuestVC_friendTableView = "ToGuestVCFriendTableView"
        static let guestVCToCommentsVC = "ToCommentsVC"
        static let friendVCToGuestVC_recommendedUserCell = "ToGuestVCRecommendedCell"
    }
    
    
    // set screen attributes
    struct Screen {
        static let backGroundColor = "loginAndRegistrationSecreenBackgroundColor"
    }
    
    // set Labels attributes
    struct Label {
        
        // set font properties
        struct Font {
            static let homeName = "HelveticaNeue"
        }
        
    }
    
    
    
    // set TextFields attributes
    struct TextField {
        
        // set textfield color property
        struct Color {
            static let signBackground = "signTextFieldBackgroundColor"
            static let signText = "signTextFieldTextColor"
        }
        
        // set font properties
        struct Font {
            static let sign = "HelveticaNeue"
        }
        
        
    }
    
    
    // set Buttons attributes
    struct Button {
        
        // set button color property
        struct Color {
            static let signText = "signButtonTextColor"
            static let signBackground = "signButtonsBackgroundColor"
            static let alreadySignAndNewUser = "alreadyRegisteredAndNewUserButtonText"
            static let likeButtonColor = UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1)
        }
        
        // set button font properties
        struct Font {
            static let sign = "HelveticaNeue"
            static let signMedium = "HelveticaNeue-Medium"
            
        }
    }
    
    // custom font in order to minimize errors
    struct Font {
        
        static let helveticaNeue_bold = "HelveticaNeue-Bold"
        static let helveticaNeue_medium = "HelveticaNeue-Medium"
        static let helveticaNeue = "HelveticaNeue"
        static let helveticaNeue_light = "HelveticaNeue-Light"
    }
    
    
    
    
}
