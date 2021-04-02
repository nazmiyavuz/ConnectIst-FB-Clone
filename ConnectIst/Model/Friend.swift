//
//  Friend.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 1.04.2021.
//

import Foundation

struct Friend: Decodable {
    
    let id: Int
    let userId: Int
    let friendId: Int
    let dateCreated: String
    let email: String
    let fullName: String
    let ava: String
    let cover: String
    let bio: String?
    let allowFriends: Int
    let allowFollow: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case friendId = "friend_id"
        case dateCreated = "date_created"
        case email
        case fullName
        case ava
        case cover
        case bio
        case allowFriends = "allow_friends"
        case allowFollow = "allow_follow"
    }
    
}
