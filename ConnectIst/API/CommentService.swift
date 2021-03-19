//
//  CommentService.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 2.03.2021.
//

import UIKit

// to minimize error 
enum CommentActions: String {
    case insert = "insert"
    case delete = "delete"
    case select = "select"
}

struct CommentService {
    
    static let shared = CommentService()
    
    
    //MARK: - Insert
    
    // send a HTTP request to insert the comment
    func insertComment(post_id: Int, user_id: Int, action: CommentActions, comment: String,
                       selfVC: UIViewController,
                       completion: @escaping (Result<NewComment, Error>)->() ) {

        let actionRaw = action.rawValue
        
        // declaring URL and prepare request
        let url = URL(string: "http://localhost/connectIst/comments.php")!
        let body = "post_id=\(post_id)&user_id=\(user_id)&action=\(actionRaw)&comment=\(comment)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)

        // send request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {

                // error happened
                if let error = error {
                    Helper.shared.showAlert(title: "Server Error", message: error.localizedDescription, in: selfVC)
                    return
                }

                do {
                    // access safe mode data received from the server
                    guard let data = data else {
                        Helper.shared.showAlert(title: "Data Error", message: error!.localizedDescription, in: selfVC)
                        return
                    }

                    // converting received data from the server into the JSON
                    let newComment = try JSONDecoder().decode(NewComment.self, from: data)
                    
                    completion(.success(newComment))
                    // json error
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                    completion(.failure(error))
                    return
                }
            }
        }
        task.resume()
    }
    
    // http://localhost/connectIst/comments.php?action=select&post_id=57&limit=100&offset=0

    //MARK: - Load
    
    // for loading comments from the server via PHP protocol with CommentData Item
    func loadComments(post_id: Int, offset: Int, action: CommentActions, limit: Int, selfVC: UIViewController,
                      completion: @escaping ([Comment])->() ) {
        
        let actionRaw = action.rawValue
        
        let postIdString = String(post_id)
        
        // prepare request
        let commentURL = "http://localhost/connectIst/comments.php"
        let urlString = "\(commentURL)?action=\(actionRaw)&post_id=\(postIdString)&offset=\(offset)&limit=\(limit)"
        guard let url = URL(string: urlString) else { return }
        
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async {
                // error occurred
                if error != nil {
                    Helper.shared.showAlert(title: "Server Error", message: error!.localizedDescription, in: selfVC)
                    return
                }
                
                guard let data = data else {
                    Helper.shared.showAlert(title: "Data Error", message: error!.localizedDescription, in: selfVC)
                    return
                }
                
                do {
                    let comments = try JSONDecoder().decode([Comment].self, from: data)
                    completion(comments)
                    
                // error while accessing data or json
                } catch {
                    print("DEBUG: JSON Error \(error.localizedDescription)")
                }
                
            }
        }
        task.resume()
    }
    
    //MARK: - Delete
    
    // responsible for deleting cell and comment from the database
    func deleteComment(id: Int, action: CommentActions, indexPath: IndexPath, selfVC: UIViewController) {
        
        let actionRaw = action.rawValue
        
        
        // prepare request
        let url = URL(string: "http://localhost/connectIst/comments.php")!
        let body = "id=\(id)&action=\(actionRaw)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // error occurred
                if error != nil {
                    Helper.shared.showAlert(title: "Server Error", message: error!.localizedDescription, in: selfVC)
                    return
                }
                
                // processing data and json
                do {
                    // safe mode of accessing and fetching data from the server (fetching a new const
                    guard let data = data else {
                        Helper.shared.showAlert(title: "Data Error", message: error!.localizedDescription, in: selfVC)
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    print(json)
                    
                // json error
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                    return
                }
            }
        }
        task.resume()
    }
    
}

