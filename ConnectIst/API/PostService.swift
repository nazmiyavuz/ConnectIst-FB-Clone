//
//  PostUploader.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 25.02.2021.
//

import UIKit
import Alamofire

struct PostService {
    
    static let shared = PostService()
    
    // MARK: - Upload
    
    // sent request to the server to upload the Image
    func uploadPost(from imageView: UIImageView, text: String?, isSelectedPicture: Bool,
                    selfVC: UIViewController) {
        
        // save method of access 2 values to be sent to the server
        guard let id = currentUser?.id, let text = text else { return }
        let idString = String(id)
        // declaring keys and values to be sent to the server
        let params = ["user_id": idString, "text": text]
        
        // declaring URL and request
        let url = URL(string: "http://localhost/connectIst/uploadPost.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // web development and MIME Type of passing information to the web server.
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // access / convert image to Data for sending to the server
        var imageData = Data()
        
        // if picture has been selected, compress the picture before sending to the server
        if isSelectedPicture {
            imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
        }
        
        // building the full body along with the string, text, file parameters
        request.httpBody = Helper().body(with: params, filename: "\(NSUUID().uuidString).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
        // run the session
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // if error
                if error != nil {
                    Helper.shared.showAlert(title: "Server Error", message: error!.localizedDescription, in: selfVC)
                    return
                }
                
                // access data
                do {
                    // safe method of accessing data from the server
                    guard let data = data else {
                        Helper.shared.showAlert(title: "Data Error", message: error!.localizedDescription, in: selfVC)
                        return
                    }
                    
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // safe mode of accessing / casting JSON
                    guard let parsedJSON = json else { return }
                    
                    // if post is uploaded successfully -> come back to HomeVC, else -> show error message
                    if parsedJSON["status"] as! String == "200" {
                        
                        // post notification in order to update posts of the user in other viewConrollers
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
                        
                        // comeback
                        selfVC.dismiss(animated: true, completion: nil)
                    } else {
                        Helper.shared.showAlert(title: "Error", message: parsedJSON["message"] as! String, in: selfVC)
                        return
                    }
                    
                    // error while accessing data or json
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                }
            }
        }.resume()
    }
    
    // MARK: - Load

    // for loading posts from the server via PHP protocol with PostData Item
    func loadPosts(id: Int ,offset: Int, limit: Int, selfVC: UIViewController,
                   completion: @escaping (Result<[Post], Error>)->() ) {
                
        // prepare request
        let postURL = "http://localhost/connectIst/selectPosts.php"
        let urlString = "\(postURL)?id=\(id)&offset=\(offset)&limit=\(limit)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
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
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                    
                
                // error while accessing data or json
                } catch {
                    completion(.failure(error))
                    
                    print("DEBUG: JSON Error \(error.localizedDescription)")
                }
            }
            
        }.resume()
    }
    
    //MARK: - Like
    
    func likePost(post_id: Int, user_id: Int, action: String, selfVC: UIViewController){
        
        
        // prepare request
        let url = URL(string: "http://localhost/connectIst/like.php")!
        let body = "post_id=\(post_id)&user_id=\(user_id)&action=\(action)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request to the server
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occurred
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
                    
                    // converting data to the JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    
                    
                    print("DEBUG: JSON: \(json)")
                    
                    
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                }
            }
        }
        
        task.resume()
        
        
    }
    
    //MARK: - Delete
    
    // responsible for deleting post
    func deletePost(id: Int, selfVC: UIViewController,
                    completion: @escaping (Result<NSDictionary, Error>) -> ()) {
        
        // prepare request
        let urlString = "http://localhost/connectIst/deletePost.php"
        guard let url = URL(string: urlString) else { return }
        let params = ["id": id]
        
        AF.request(url, method: .post, parameters: params).responseJSON { response in
            
            DispatchQueue.main.async {
                
                // error
                if let error = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: error.localizedDescription, in: selfVC)
                    return
                }
                // safe mode of casting data
                guard let data = response.data else {
                    Helper.shared.showAlert(title: "Data Error", message: response.error!.localizedDescription, in: selfVC)
                    return
                }
                // fetch json if no error
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    guard let parsedJSON = json else { print("Parsing Error"); return }
                    
                    completion(.success(parsedJSON))
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    //MARK: - Load FeedPosts
    
    static func loadFeedPots(id: Int ,offset: Int, limit: Int, selfVC: UIViewController, completion: @escaping (Result<[FeedPost], Error>)-> Void ) {
        
        // http://localhost/connectIst/selectPosts.php?id=11&limit=100&offset=0&action=feed
        
        guard let url = URL(string: "http://localhost/connectIst/selectPosts.php") else { return }
        let body = "id=\(id)&limit=\(limit)&offset=\(offset)&action=feed"
        
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
                    // convert data to being json
                    let feedPosts = try JSONDecoder().decode([FeedPost].self, from: data)
                    completion(.success(feedPosts))
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    
}
