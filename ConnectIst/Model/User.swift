//
//  User.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 17.02.2021.
//

import Foundation

struct User: Decodable {
    
    var id: Int
    var email: String
    var userName: String
    var fullName: String
    var cover: String
    var ava: String
    var bio: String?
    var dateCreated: String?
    var requestSender: Int?
    var requestReceiver: Int?
    var friendshipSender: Int?
    var friendshipReceiver: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case userName
        case fullName
        case cover
        case ava
        case bio
        case dateCreated = "date_created"
        case requestSender = "request_sender"
        case requestReceiver = "request_receiver"
        case friendshipSender = "friendship_sender"
        case friendshipReceiver = "friendship_receiver"
    }
    
}


struct RequestedUser: Decodable {
    
    var id: Int
    var email: String
    var userName: String
    var fullName: String
    var ava: String
    var cover: String
    var bio: String?
    var dateCreated: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case userName
        case fullName
        case ava
        case cover
        case bio
        case dateCreated = "date_created"
    }
    
}
