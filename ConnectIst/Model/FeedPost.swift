//
//  FeedPost.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 2.04.2021.
//

import Foundation

struct FeedPost: Decodable {
    
    let id: Int
    let userId: Int
    let text: String
    let picture: String
    let dateCreated: String
    let email: String
    let fullName: String
    let ava: String
    let cover: String
    let bio: String?
    var liked: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case text
        case picture
        case dateCreated = "date_created"
        case email
        case fullName
        case ava
        case cover
        case bio
        case liked
        
    }
    
}
