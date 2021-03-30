//
//  RecommendedUser.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 27.03.2021.
//

import Foundation

struct RecommendedUser: Decodable {
    
    let id: Int
    let fullName: String
    let email: String
    let ava: String
    let cover: String
    let bio: String?
    let allowFriends: Int
    let allowFollow: Int
    let requestSender: Int?
    let requestReceiver: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case email
        case ava
        case cover
        case bio
        case allowFriends = "allow_friends"
        case allowFollow = "allow_follow"
        case requestSender = "request_sender"
        case requestReceiver = "request_receiver"
    }
}
