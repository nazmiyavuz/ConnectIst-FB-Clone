//
//  BioUploader.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 22.02.2021.
//

import UIKit

struct BioUploader {
    
    //MARK: - Update
    
    // updating bio by sending request to the server
    func updateBio(bioText: String?, selfVC: UIViewController,
                   completion: @escaping(Error?) -> Void) {
        
        // STEP !. Access var / params to be sent to the server
        guard let id = currentUser?.id, let bio = bioText else { return }
        
        // Step 2. Declare URL, Request, Method, etc
        let url = URL(string: "http://localhost//connectIst/updateBio.php")!
        let body = "id=\(id)&bio=\(bio)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // STEP 3. Execute and Launch Request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                let helper = Helper()
                // error occurred
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: selfVC)
                    return
                }
                
                // go to data and jsoning
                do {
                    
                    // safe method of casting data received from the server
                    guard let data = data else {
                        helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: selfVC)
                        return
                    }
                    
                    // STEP 4. Parse json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                        // save method of accessing json casting
                        guard let parsedJSON = json else { return }
                        print(parsedJSON)
                        
                        // uploaded successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        let currentUserBio = parsedJSON["bio"] as? String
                        UserDefaults.standard.set(currentUserBio, forKey: "currentUserBio")
                        
                        // post notification -> update Bio on Home Page
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBio"), object: nil)
                        
                        selfVC.dismiss(animated: true, completion: nil)
                        
                        // error while updating (e.g. Status = 400)
                    } else {
                        helper.showAlert(title: "400", message: "Error while updating the bio", in: selfVC)
                    }
                    
                    
                    // error while processing json/ accessing json
                } catch {
                    helper.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                }
            }
        }.resume()
        
    }

    //MARK: - Delete
    
    // deleting bio by sending request to the server
    func deleteBio(selfVC: UIViewController, bioLabel: UILabel, bioButton:UIButton,
                   completion: @escaping(Error?) -> Void) {
        
        // STEP !. Access var / params to be sent to the server
        guard let id = currentUser?.id else { return }
        let bio = " "
        
        // Step 2. Declare URL, Request, Method, etc
        let url = URL(string: "http://localhost//connectIst/updateBio.php")!
        let body = "id=\(id)&bio=\(bio)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // STEP 3. Execute and Launch Request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occurred
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: selfVC)
                    return
                }
                
                // go to data and jsoning
                do {
                    
                    // safe method of casting data received from the server
                    guard let data = data else {
                        Helper.shared.showAlert(title: "Data Error", message: error!.localizedDescription, in: selfVC)
                        return
                    }
                    
                    // STEP 4. Parse json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                        // save method of accessing json casting
                        guard let parsedJSON = json else { return }
                        print(parsedJSON)
                        
                        // uploaded successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        let currentUserBio = parsedJSON["bio"] as? String
                        UserDefaults.standard.set(currentUserBio, forKey: "currentUserBio")
                        
                        // delete bio -> hide bioLabel -> show addBioButton on HomeVC
                        bioLabel.text = ""
                        bioLabel.isHidden = true
                        bioButton.isHidden = false
                                                
                        // error while updating (e.g. Status = 400)
                    } else {
                        Helper.shared.showAlert(title: "400", message: "Error while updating the bio", in: selfVC)
                    }
                    
                    
                    // error while processing json/ accessing json
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                }
            }
        }.resume()
        
    }
    
}
