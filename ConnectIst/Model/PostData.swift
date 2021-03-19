//
//  PostManager.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 27.02.2021.
//

import Foundation


//class PostData: Decodable {
//    let posts: [Post]?
//    
//}


struct Post: Decodable {
    let id: Int
    let user_id: Int
    let text: String
    let picture: String
    let date_created: String
    let fullName: String
    let cover: String?
    let ava: String?
    let liked: Int?
    
    
}
