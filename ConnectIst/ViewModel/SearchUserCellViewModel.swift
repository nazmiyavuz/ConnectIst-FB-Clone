//
//  GuestViewModel.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 11.03.2021.
//

import Foundation

struct SearchUserCellViewModel {
    
    let user: User
    
    var id: Int {
        return user.id
    }
    
    var fullName: String {
        return user.fullName
    }
    
    var avaPath: URL? {
        return URL(string: user.ava)
    }
    
    var coverPath: URL? {
        return URL(string: user.cover)
    }
    
    var bio: String? {
        return user.bio
    }
    
    var allowFriends: Int {
        return user.allowFriends
    }
    
    var allowFollow: Int {
        return user.allowFollow
    }
    
    var followedUser: Int? {
        return user.followedUser
    }
    
    
    
    init(user: User) {
        self.user = user        
    }
    
}

