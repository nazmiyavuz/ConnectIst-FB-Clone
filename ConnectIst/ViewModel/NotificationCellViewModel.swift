//
//  NotificationCellViewModel.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 31.03.2021.
//

import Foundation


struct NotificationCellViewModel {
    
    let notificationItem: NotificationItem
    
    var id: Int {
        return notificationItem.id
    }
    
    var type: String {
        return notificationItem.type
    }
    
    var viewed: String? {
        return notificationItem.viewed
    }
    
    var fullName: String {
        return notificationItem.fullName
    }
    
    var email: String {
        return notificationItem.email
    }
    
    var avaPath: URL? {
        return URL(string: notificationItem.ava)
    }
    
    var coverPath: URL? {
        return URL(string: notificationItem.cover)
    }
    
    var bio: String? {
        return notificationItem.bio
    }
    
    init(notificationItem: NotificationItem) {
        self.notificationItem = notificationItem
    }
    
}
