//
//  Notification.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 31.03.2021.
//

import Foundation

struct NotificationItem: Codable {
    
    let id: Int
    let byUserId: Int
    let userId: Int
    let type: String
    let viewed: String?
    let dateCreated: String
    let fullName: String
    let email: String
    let ava: String
    let cover: String
    let bio: String?
    

    private enum CodingKeys: String, CodingKey {
        case id
        case byUserId = "byUser_id"
        case userId = "user_id"
        case type
        case viewed
        case dateCreated = "date_created"
        case fullName
        case email
        case ava
        case cover
        case bio
    }
    
}
