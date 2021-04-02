//
//  NotificationService.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 30.03.2021.
//

import UIKit

// to minimize error
enum NotificationAction: String {
    case insert = "insert"
    case delete = "delete"
    case update = "update"
}

enum NotificationType: String {
    case friend = "friend"
    case follow = "follow"
    case like = "like"
    case comment = "comment"
    case bio = "bio"
    case ava = "ava"
    case cover = "cover"
    case request = "request"
}

extension String {
    mutating func appendNotificationBody(type: NotificationType, action: NotificationAction) {
        let body = "&type=\(type.rawValue)&action=\(action.rawValue)"
        self.append(body)
    }
}

struct NotificationService {
    
//    static let shared = NotificationService()
    //MARK: - Send
    
    static func friendFollowNotifications(userId: Int, friendId:Int, action: UserServiceAction) {
        
        // http://localhost/connectIst/notification.php?byUser_id=12&user_id=13&type=like&action=insert
        
        // send notification to the server
        let notificationURL = "http://localhost/connectIst/notification.php"
        var notificationBody = "byUser_id=\(userId)&user_id=\(friendId)"
        
        switch action {
        case .confirm:
            notificationBody.appendNotificationBody(type: .friend, action: .insert)
        case .delete:
            notificationBody.appendNotificationBody(type: .friend, action: .delete)
        case .follow:
            notificationBody.appendNotificationBody(type: .follow, action: .insert)
        case .unfollow:
            notificationBody.appendNotificationBody(type: .follow, action: .delete)
        case .search:
            break
        case .reject:
            break
        case .add:
            break
        case .requests:
            break
        }
        
        _ = Helper.sendHTTPRequest(url: notificationURL, body: notificationBody, success: {}, failure: {})
        
    }
    
    
    
    static func sendNotification(userId: Int, friendId:Int, type: NotificationType, action: NotificationAction) {
        // send notification to the server
        let notificationURL = "http://localhost/connectIst/notification.php"
        var notificationBody = "byUser_id=\(userId)&user_id=\(friendId)"
        
        notificationBody.appendNotificationBody(type: type, action: action)
        
        _ = Helper.sendHTTPRequest(url: notificationURL, body: notificationBody, success: {}, failure: {})
    }
    
    //MARK: - Load
    
    static func loadNotifications(userId: Int, limit: Int, offset: Int, selfVC: UIViewController,
                                  completion: @escaping (Result<[NotificationItem], Error>)-> Void ) {
        // http://localhost/connectIst/notification.php?user_id=11&limit=10&offset=0&action=select
        
        guard let url = URL(string: "http://localhost/connectIst/notification.php") else { return }
        let body = "user_id=\(userId)&limit=\(limit)&offset=\(offset)&action=select"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        // send request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // error
                if error != nil {
                    Helper.shared.showAlert(title: "Server Error", message: error!.localizedDescription, in: selfVC)
                    return
                }
                do {
                    // access data received from the server in the safe mode
                    guard let data = data else {
                        Helper.shared.showAlert(title: "Data Error", message: error!.localizedDescription, in: selfVC)
                        return
                    }
                    
                    print(String(data: data, encoding: .utf8))
                    // convert data to being json
                    let users = try JSONDecoder().decode([NotificationItem].self, from: data)
                    print(users)
                    completion(.success(users))
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Update
    
    static func updateNotification(id: Int, viewed: String) {
        
        // http://localhost/connectIst/notification.php?id=17&viewed=yes&action=update
        
        // send notification to the server
        let notificationURL = "http://localhost/connectIst/notification.php"
        let notificationBody = "id=\(id)&viewed=\(viewed)&action=update"
        
        _ = Helper.sendHTTPRequest(url: notificationURL, body: notificationBody, success: {}, failure: {})
        
    }
    
    
    
    
}

