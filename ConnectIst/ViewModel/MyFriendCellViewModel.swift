//
//  MyfriendCellViewmodel.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 1.04.2021.
//

import Foundation

// MyFriendCellViewModel
struct MyFriendCellViewModel {
    
    let friend: Friend
    
    var id: Int {
        return friend.id
    }
    
    var userId: Int {
        return friend.userId
    }
    
    var friendId: Int {
        return friend.friendId
    }
    
    var email: String {
        return friend.email
    }
    
    var fullName: String {
        return friend.fullName
    }
    
    var avaPath: URL? {
        return URL(string: friend.ava)
    }
    
    var coverPath: URL? {
        return URL(string: friend.cover)
    }
    
    var bio: String? {
        return friend.bio
    }
    
    var allowFriends: Int {
        return friend.allowFriends
    }
    
    var allowFollow: Int {
        return friend.allowFollow
    }
    
    init(friend: Friend) {
        self.friend = friend
    }
    
}
