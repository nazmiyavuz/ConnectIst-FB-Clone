//
//  GuestViewModelForRequests.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 29.03.2021.
//

import Foundation


struct RequestUserCellViewModel {
     
    let requestedUser: RequestedUser
    
    var id: Int {
        return requestedUser.id
    }
    
    var fullName: String {
        return requestedUser.fullName
    }
    
    var avaPath: URL? {
        return URL(string: requestedUser.ava)
    }
    
    var coverPath: URL? {
        return URL(string: requestedUser.cover)
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
    
    init(requestedUser: RequestedUser) {
        self.requestedUser = requestedUser
    }
}

