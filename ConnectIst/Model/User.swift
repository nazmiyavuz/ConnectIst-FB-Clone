//
//  User.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 17.02.2021.
//

import Foundation

struct User: Decodable {
    
    let id: Int
    let email: String
    let userName: String
    let fullName: String
    let cover: String
    let ava: String
    let bio: String?
    let allowFriends: Int
    let allowFollow: Int
    let dateCreated: String?
    let requestSender: Int?
    let requestReceiver: Int?
    let friendshipSender: Int?
    let friendshipReceiver: Int?
    let followedUser: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case userName
        case fullName
        case cover
        case ava
        case bio
        case allowFriends = "allow_friends"
        case allowFollow = "allow_follow"
        case dateCreated = "date_created"
        case requestSender = "request_sender"
        case requestReceiver = "request_receiver"
        case friendshipSender = "friendship_sender"
        case friendshipReceiver = "friendship_receiver"
        case followedUser = "followed_user"
    }
    
}

struct RequestedUser: Decodable {
    
    let id: Int
    let email: String
    let userName: String
    let fullName: String
    let ava: String
    let cover: String
    let bio: String?
    let allowFriends: Int
    let allowFollow: Int
    let followedUser: Int?
    let dateCreated: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case userName
        case fullName
        case ava
        case cover
        case bio
        case allowFriends = "allow_friends"
        case allowFollow = "allow_follow"
        case followedUser = "followed_user"
        case dateCreated = "date_created"
    }
    
}


struct CurrentUser {
    
    var id: Int
    var email: String
    var userName: String
    var fullName: String
    var cover: String?
    var ava: String?
    var bio: String?
    var allowFriends: String
    var allowFollow: String
    
}
