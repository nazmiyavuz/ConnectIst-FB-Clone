//
//  RequestedUser.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 27.03.2021.
//

import Foundation

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
