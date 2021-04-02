//
//  Helpers.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 15.02.2021.
//

import UIKit


struct Helper {
    
    static let shared = Helper()
    
    //MARK: - isValid
    // validate email address function / logic
    func isValid(email: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the regex to current state. Verifying the result (email = rule)
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: email)
        
        return result
    }
    
    
    // validate name function / logic
    func isValid(name: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the regex to current state. Verifying the result (email = rule)
        let regex = "[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: name)
        
        return result
    }
    
    // validate name function / logic
    func isValid(userName: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the regex to current state. Verifying the result (email = rule)
        let regex = "[A-Z0-9a-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: userName)
        
        return result
    } //
    
    // validate name function / logic
    func isValid(fullName: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the regex to current state. Verifying the result (email = rule)
        let regex = "([A-Za-z ]+)"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: fullName)
        
        return result
    }
    
    
    //MARK: - showAlert
    
    // show alert message to the user
    func showAlert(title: String, message: String, in vc: UIViewController) {
        
        // creating alertController; creating button to the alertController; assigning button to alertController; presenting alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - instantiateViewController
    
    // allows us to go to another ViewController programmatically
    func instantiateViewController(identifier: String, animated: Bool, presentStyle: UIModalPresentationStyle, by vc: UIViewController, completion: (() -> Void)?) {
        
        // accessing any ViewController from Main.storyboard via ID
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        // to show with fullscreen
        newViewController.modalPresentationStyle = presentStyle //.fullScreen or .overFullScreen for transparency
        
        // presenting accessed ViewController
        vc.present(newViewController, animated: animated, completion: completion)
        
    }
    
    
    //MARK: - MIME for the Image
    // MIME for the Image
    func body(with parameters: [String: Any]?, filename: String, filePathKey: String?, imageDataKey: Data, boundary:String) -> NSData {
        
        let body = NSMutableData()
        
        // MIME Type for Parameters [id: 777, name: michael]
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        
        // MIME Type for Image
        let mimetype = "image/jpg"
        
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        
        body.append(imageDataKey)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
    
    //MARK: - fetchUserInfo
    
    func fetchUserInfo(parsedJSON: NSDictionary) {
        
        // save values to the userDefaults
        if let userId = parsedJSON["id"] as? String {
            let currentId = Int(userId)
            currentUser?.id = currentId!
            UserDefaults.standard.set(currentId, forKey: "currentUserId")
        }
        
        let currentUserEmail = parsedJSON["email"] as! String
        currentUser?.email = currentUserEmail
        UserDefaults.standard.set(currentUserEmail, forKey: "currentUserEmail")
        
        let currentUserUserName = parsedJSON["userName"] as! String
        currentUser?.userName = currentUserUserName
        UserDefaults.standard.set(currentUserUserName, forKey: "currentUserUserName")
        
        let currentUserFullName = parsedJSON["fullName"] as! String
        currentUser?.fullName = currentUserFullName
        UserDefaults.standard.set(currentUserFullName, forKey: "currentUserFullName")
        
        
        let currentUserCover = parsedJSON["cover"] as? String
        currentUser?.cover = currentUserCover ?? "http://localhost/connectIst/cover/0/cover.jpg"
        UserDefaults.standard.set(currentUserCover, forKey: "currentUserCover")
        
        let currentUserAva = parsedJSON["ava"] as? String
        currentUser?.ava = currentUserAva ?? "http://localhost/connectIst/ava/0/ava.jpg"
        UserDefaults.standard.set(currentUserAva, forKey: "currentUserAva")
        
        let currentUserBio = parsedJSON["bio"] as? String
        currentUser?.bio = currentUserBio
        UserDefaults.standard.set(currentUserBio, forKey: "currentUserBio")
        
        let currentUserAllowFriends = parsedJSON["allow_friends"] as! String
        currentUser?.allowFriends = currentUserAllowFriends
        UserDefaults.standard.set(currentUserAllowFriends, forKey: "currentUserAllowFriends")
        
        let currentUserAllowFollow = parsedJSON["allow_follow"] as! String
        currentUser?.allowFollow = currentUserAllowFollow
        UserDefaults.standard.set(currentUserAllowFollow, forKey: "currentUserAllowFollow")
        
            
        
    }
    
    //MARK: - downloadImage
    // allows us to download image from certain url string
    func downloadImage(from path: String, showIn imageView: UIImageView, orShow placeHolder: UIImage) {
        // if avaPath string is having a valid url, IT'S NOT EMPTY (e.g. if ava isn'T assigned, than in DB the link is stored as blank string)
        if String(describing: path).isEmpty == false {
            DispatchQueue.main.async {
                // converting url string to the  valid URL
                if let url = URL(string: path ){
                    // downloading all data from the URL
                    guard let data = try? Data(contentsOf: url) else {
                        imageView.image = placeHolder
                        return
                    }
                    // converting downloaded data to the image
                    guard let image = UIImage(data: data) else {
                        imageView.image = placeHolder
                        return
                    }
                    // assigning image to the imageView
                    imageView.image = image
                }
            }
        }
    }
    
    //MARK: - showBioactionSheet
    
    func showBioActionSheet(selfVC: UIViewController, bioLabel: UILabel, bioButton:UIButton) {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring newBio button
        let bio = UIAlertAction(title: "New Bio", style: .default) { (action) in
            // go to Bio Page
            let controller = UINavigationController(rootViewController: BioController())
            controller.modalPresentationStyle = .fullScreen
            selfVC.present(controller, animated: true, completion: nil)
            
        }
        
        
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        // declaring delete button
        let delete = UIAlertAction(title: "Delete Bio", style: .destructive) { (action) in
            
            guard let id = currentUser?.id else { return }
            NotificationService.sendNotification(userId: id, friendId: id, type: .bio, action: .delete)
            
            BioUploader.deleteBio(selfVC: selfVC, bioLabel: bioLabel, bioButton: bioButton) { (error) in
                if let error = error {
                    print("DEBUG: Failed to log user in \(error.localizedDescription)")
                    return
                }                
            }
        }
        
        // adding buttons to the sheet
        sheet.addAction(bio)
        sheet.addAction(cancel)
        sheet.addAction(delete)
        
        // present action sheet to the user finally
        selfVC.present(sheet, animated: true, completion: nil)
    }
    
    
    // MARK: - Saving Cover/Ava
    // save Cover / Ava to the user defoults
    func saveIsCover(_ isTrue:Bool) {
        isCover = isTrue
        UserDefaults.standard.set(isTrue, forKey: "isCover")
    }
    
    func saveIsAva(_ isTrue:Bool) {
        isAva = isTrue
        UserDefaults.standard.set(isTrue, forKey: "isAva")
    }
    
    // MARK: - DateFormatter
    
    // change date format which is belong to date comes from server to the string that how we want to show
    func formatDateCreated(with date: String) -> String {
        // taking the date received from the server and putting it in the following format to be recognized as being Date()
        let formatterGet = DateFormatter()
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdDate = formatterGet.date(from: date)!
        
        // we are writing a new readable format and putting Date() into this format and converting the string to be shown to the user
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMM dd yyyy - HH:mm"
        let dateShow = formatterShow.string(from: createdDate)
        return dateShow
    }
    
    //MARK: - HTTPRequest
    // sends HTTP requests and return JSON results
    static func sendHTTPRequest(url: String, body: String, success: @escaping () -> Void, failure: @escaping () -> Void) -> Status {
        // var to be returned
        var result : Status?
        // preparing request
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // errors
                if error != nil {
                    failure()
                    return
                }
                
                do {
                    // casting data received from the server
                    guard let data = data else {
                        failure()
                        return
                    }
                    // casting json from data
                    let status = try JSONDecoder().decode(Status.self, from: data)
                    // completionHandler. This can be customized whenever this func is called from any other swift classes / files
                    if status.status == "200" {
                        success()
                    } else {
                        failure()
                    }
                    // assigning json data to the result var to be returned with the func
                    result = status
                } catch {
                    failure()
                    return
                }
            }
        }.resume()
        // returning json
        guard let status = result else { return Status(status: "400", message: "Not complete")}
        
        return status
    }
    
    
    
}








