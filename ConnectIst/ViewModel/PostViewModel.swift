//
//  PostViewModel.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 27.02.2021.
//

import Foundation


struct PostViewModel {
    let post: Post
    
    var id: Int {
        return post.id
    }
    
    var user_id: Int {
        return post.user_id
    }
    
    var text: String {
        return post.text
    }
    
    var picture: String {
        return post.picture
    }
    
    var date_created: String {
        return post.date_created
    }
    
    var fullName: String {
        return post.fullName
    }
    
    var cover: String? {
        return post.cover
    }
    
    var ava: String? {
        return post.ava
    }
    
    var liked: Int? {
        return post.liked
    }
    
    init(post: Post) {
        self.post = post
    }
    
}
