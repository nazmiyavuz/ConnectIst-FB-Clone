//
//  GuestViewModel.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 11.03.2021.
//

import Foundation

struct GuestViewModel {
    
    let user: User
    
    var id: Int {
        return user.id
    }
    
    var fullName: String {
        return user.fullName
    }
    
    var avaPath: String {
        return user.ava
    }
    
    var coverPath: String {
        return user.cover
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
    
    
    
}

struct GuestViewModelForRequests {
     
    let requestedUser: RequestedUser
    
    var id: Int {
        return requestedUser.id
    }
    
    var fullName: String {
        return requestedUser.fullName
    }
    
    var avaPath: String?{
        return requestedUser.ava
    }
    
    var coverPath: String {
        return requestedUser.cover
    }
    
    var bio: String? {
        return requestedUser.bio
    }
    
    var allowFriends: Int {
        return requestedUser.allowFriends
    }
    
    var allowFollow: Int {
        return requestedUser.allowFollow
    }
    
    var followedUser: Int? {
        return requestedUser.followedUser
    }
    
    
}
