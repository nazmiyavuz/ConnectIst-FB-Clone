//
//  CommentData.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 2.03.2021.
//

import Foundation

struct Comment: Decodable {
    let id: Int
    let postId: Int
    let userId: Int
    let comment: String
    let dateCreated: String
    let text: String
    let picture: String?
    let fullName: String
    let ava: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case comment
        case dateCreated = "date_created"
        case text
        case picture
        case fullName
        case ava
        
    }
    
}

struct NewComment: Codable {
    let id: Int
    let postId: String
    let userId: String
    let comment: String
    let dateCreated: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case comment
        case dateCreated = "date_created"
    }
}
