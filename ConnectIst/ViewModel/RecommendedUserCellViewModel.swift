//
//  GuestViewModelForRecommendedUser.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 29.03.2021.
//

import Foundation

struct RecommendedUserCellViewModel {
    
    let recommendedUser: RecommendedUser
    
    var id: Int {
        return recommendedUser.id
    }
    
    var fullName: String {
        return recommendedUser.fullName
    }
    
    var email: String {
        return recommendedUser.email
    }
    
    var avaPath: URL? {
        return URL(string: recommendedUser.ava)
    }
    
    var coverPath: URL? {
        return URL(string: recommendedUser.cover)
    }
    
    var bio: String? {
        return recommendedUser.bio
    }
    
    var allowFriends: Int {
        return recommendedUser.allowFriends
    }
    
    var allowFollow: Int {
        return recommendedUser.allowFollow
    }
    
    init(recommendedUser: RecommendedUser) {
        self.recommendedUser = recommendedUser
    }
    
    
}
