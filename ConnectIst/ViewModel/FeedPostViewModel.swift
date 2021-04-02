//
//  FeedPostViewModel.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 2.04.2021.
//

import Foundation

struct FeedPostViewModel {
    
    let feedPost: FeedPost
    
    var id: Int {
        return feedPost.id
    }
    
    var userId: Int {
        return feedPost.userId
    }
    
    var text: String {
        return feedPost.text
    }
    
    var picturePath: URL? {
        return URL(string: feedPost.picture)
    }
    
    var dateCreated: String {
        return feedPost.dateCreated
    }
    
    var email: String {
        return feedPost.email
    }
    
    var fullName: String {
        return feedPost.fullName
    }
    
    var avaPath: URL? {
        return URL(string: feedPost.ava)
    }
    
    var coverPath: URL? {
        return URL(string: feedPost.cover)
    }
    
    var bio: String? {
        return feedPost.bio
    }
    
    
    var liked: Int? {
        return feedPost.liked
    }
    
    init(post: FeedPost) {
        self.feedPost = post
    }
    
    
    
    
    
    
}
