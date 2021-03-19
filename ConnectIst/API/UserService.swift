//
//  UpdateUserService.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 25.02.2021.
//

import UIKit
import Alamofire

// to minimize error 
enum UserServiceAction: String {
    case search = "search"
    case reject = "reject" // FIXME: Change this location or delete
    case add = "add" // FIXME:  Change this location location or delete
    case requests = "requests"
    case confirm = "confirm"
    case delete = "delete" // FIXME:  Change this location location or delete
}

struct UserService {
    
    static let shared = UserService()
    
    //MARK: - Update
    
    func updateUser(id:Int, email: String, userName: String, firstName: String,
                    lastName: String, password: String, isPasswordChanged:Bool,
                    selfVC: UIViewController ) {
        
        
        // convert for JSON value
        let idString = String(id)
        let fullName = "\(firstName) \(lastName)"
        
        // prepare request
        let url = URL(string: "http://localhost/connectIst/updateUser.php")!
        let body = "id=\(idString)&email=\(email.lowercased())&userName=\(userName.lowercased())&fullName=\(fullName.lowercased())&newPassword=\(isPasswordChanged)&password=\(password)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                    
                    // convert data to being json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // cast json in the safe mode
                    guard let parsedJSON = json else { return }
                    
                    // show alert once saved
                    if parsedJSON["status"] as! String == "200" {
                        
                        // saving uploaded user related information (e.g. ava's path, cover's path)
                        Helper.shared.fetchUserInfo(parsedJSON: parsedJSON, isLoginVC: false)
                                                
                        Helper.shared.showAlert(title: "Success!", message: "Information has been saved", in: selfVC)
                        
                    }
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                    return
                }
            }
        }.resume()
    }
    
    
    //MARK: - Search
    
    // http request to fetch users from the database
    func searchUsers(name: String, limit: Int, offset: Int, action:UserServiceAction,
                     selfVC: UIViewController,
                     completion: @escaping (Result<[User], Error>)->() ) {
        
        let actionRaw = action.rawValue
        
        // save method of access id to be sent to the server
        guard let id = currentUser?.id else { return }
        
        let urlString = "http://localhost/connectIst/friends.php"
//        let urlString = "\(urlMain)?action=search&name=\(name)&id=\(id)&limit=\(limit)&offset=\(offset)"
        
        guard let url = URL(string: urlString)  else { return }
        let parameters = [
            "action": actionRaw,
            "name": name,
            "id": id,
            "limit": limit,
            "offset": offset
        ] as [String : Any]
        
        DispatchQueue.main.async {
        
            AF.request(url, method: .post, parameters: parameters).responseJSON { (response) in
                
                // error
                if let err = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: err.localizedDescription, in: selfVC)
                    return
                }
                
                do {
                    
                    // save mode of casting data
                    guard let data = response.data else {
                        Helper.shared.showAlert(title: "Data Error", message: response.error?.localizedDescription ?? "", in: selfVC)
                        return
                    }
                    let users = try JSONDecoder().decode([User].self, from: data)
                    completion(.success(users))
                    
                } catch {
                    completion(.failure(error))
                }
                
            }
        }
    }
    
    
    //MARK: - Send Friendship Request
    
    func sendFriendRequest(userId: Int, friendId: Int, action:UserServiceAction, selfVC: UIViewController,
                     completion: @escaping (Result<NSDictionary, Error>) -> () ) {
        
        // http://localhost/connectIst/friends.php?action=add&user_id=11&friend_id=12
        
        let actionRaw = action.rawValue
        
        let urlString = "http://localhost/connectIst/friends.php"
        guard let url = URL(string: urlString)  else { return }
        
        let parameters = [
            "action": actionRaw,
            "user_id": userId,
            "friend_id": friendId
        ] as [String : Any]
        
        AF.request(url, method: .post, parameters: parameters).responseJSON { (response) in
            
            DispatchQueue.main.async {
                
                if let err = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: err.localizedDescription, in: selfVC)
                    return
                }
                
                do {
                    guard let data = response.data else {
                        Helper.shared.showAlert(title: "Data Error", message: response.error?.localizedDescription ?? "", in: selfVC)
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    guard let parsedJSON = json else { return }
                    
                    completion(.success(parsedJSON))
                    
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                    completion(.failure(error))
                    return
                }
                
            }
            
        }
        
    }
    
    //MARK: - LoadRequests
    
    // load all requests sent to current user
    func loadRequests(limit: Int, offset: Int, action:UserServiceAction, selfVC: UIViewController,
                      completion: @escaping (Result<[RequestedUser], Error>)->() ) {
        
        // http://localhost/connectIst/friends.php?action=requets&id=11&limit=100&offset=0
        
        guard let id = currentUser?.id else { return }
        
        let urlString = "http://localhost/connectIst/friends.php"
//        let urlString = "\(urlMain)?action=search&name=\(name)&id=\(id)&limit=\(limit)&offset=\(offset)"
        
        guard let url = URL(string: urlString)  else { return }
        let parameters = [
            "action": action.rawValue,
            "id": id,
            "limit": limit,
            "offset": offset
        ] as [String : Any]
        
        DispatchQueue.main.async {
            
            AF.request(url, method: .post, parameters: parameters).responseJSON { (response) in
                
                // error
                if let err = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: err.localizedDescription, in: selfVC)
                    return
                }
                
                do {
                    
                    // save mode of casting data
                    guard let data = response.data else {
                        Helper.shared.showAlert(title: "Data Error", message: response.error?.localizedDescription ?? "", in: selfVC)
                        return
                    }
                    
                    let users = try JSONDecoder().decode([RequestedUser].self, from: data)
                    completion(.success(users))
                    
                } catch {
                    completion(.failure(error))
                }
                
            }
        }
    }
    
    func confirmRejectRequestOrDeleteFriend(userId: Int, friendId: Int, action:UserServiceAction, selfVC: UIViewController,
                                            completion: @escaping (Result<Status, Error>)->()) {
        
        let actionRaw = action.rawValue
        
        let urlString = "http://localhost/connectIst/friends.php"
        guard let url = URL(string: urlString)  else { return }
        
        let parameters = [
            "action": actionRaw,
            "user_id": userId,
            "friend_id": friendId
        ] as [String : Any]
        
        AF.request(url, method: .post, parameters: parameters).responseJSON { (response) in
            
            DispatchQueue.main.async {
                
                if let err = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: err.localizedDescription, in: selfVC)
                    return
                }
                
                do {
                    guard let data = response.data else {
                        Helper.shared.showAlert(title: "Data Error", message: response.error?.localizedDescription ?? "", in: selfVC)
                        return
                    }
                    
                    let status = try JSONDecoder().decode(Status.self, from: data)
                    
                    completion(.success(status))
                    
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                    completion(.failure(error))
                    return
                }
                
            }
            
        }
        
    }
    
    
    
    func deleteFriendship(userId: Int, friendId: Int, action:UserServiceAction, selfVC: UIViewController,
                                completion: @escaping (Result<Status, Error>)->()) {
        
        let actionRaw = action.rawValue
        
        let urlString = "http://localhost/connectIst/friends.php"
        guard let url = URL(string: urlString)  else { return }
        
        let parameters = [
            "action": actionRaw,
            "user_id": userId,
            "friend_id": friendId
        ] as [String : Any]
        
        AF.request(url, method: .post, parameters: parameters).responseJSON { (response) in
            
            DispatchQueue.main.async {
                
                if let err = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: err.localizedDescription, in: selfVC)
                    return
                }
                
                do {
                    guard let data = response.data else {
                        Helper.shared.showAlert(title: "Data Error", message: response.error?.localizedDescription ?? "", in: selfVC)
                        return
                    }
                    
                    let status = try JSONDecoder().decode(Status.self, from: data)
                    
                    completion(.success(status))
                    
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                    completion(.failure(error))
                    return
                }
                
            }
            
        }
        
    }
    
}
