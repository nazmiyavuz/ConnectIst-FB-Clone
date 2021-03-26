//
//  AuthService.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 17.02.2021.
//

import UIKit
import Alamofire

struct AuthCreditentials {
    let email: String
    let password: String
    let fullName: String
    let userName: String
}


struct AuthService {
    
    
    func kisiEkle(kisi_ad:String,kisi_tel:String){
        
        let parametreler:Parameters = ["kisi_ad":kisi_ad,"kisi_tel":kisi_tel]
        
        
        AF.request("http://kasimadalan.pe.hu/kisiler/insert_kisiler.php", method: .post, parameters: parametreler).responseJSON { response in
            if let data  = response.data{
                do{
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]{
                        print(json)
                    }
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
//    func tumKisilerAl(){
//
//        AF.request("http://kasimadalan.pe.hu/kisiler/tum_kisiler.php",method: .get).responseJSON{
//            response in
//            if let data  = response.data{
//                do{
//                    let cevap = try JSONDecoder().decode(KisiCevap.self, from: data)
//                    if let gelenKisiListesi = cevap.kisiler{
//                        self.kisilerListe = gelenKisiListesi
//                    }else{
//                        self.kisilerListe = [Kisiler]()
//                    }
//                    DispatchQueue.main.async {
//                        self.kisilerTableView.reloadData()
//                    }
//                }catch{
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
    
    // MARK: - LogUserIn
    
    static func logUserIn(email: String, password: String, selfVC: UIViewController,
                          isLoginVC: Bool,
                          completion: @escaping(Error?) -> Void ) {
        
        let urlString = "http://localhost/connectIst/login.php"
        guard let url = URL(string: urlString)  else { return }
        let parameters = ["email": email, "password": password]
        
        
        DispatchQueue.main.async {
            
            AF.request(url, method: .post, parameters: parameters).responseJSON { response in
                
                
                // error
                if let error = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: error.localizedDescription, in: selfVC)
                    return
                }
                
                // fetch JSON if no error
                do {
                    // save mode of casting data
                    guard let data = response.data else {
                        Helper.shared.showAlert(title: "Data Error", message: response.error?.localizedDescription ?? "", in: selfVC)
                        return
                    }
                    
                    // fetching all JSON received from the server
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save mode of casting JSON NSDictionary
                    guard let parsedJSON = json else { print("Parsing Error"); return }
                    print("DEBUG: Parsed JSON data is written below \n \(parsedJSON)")
                    
                    // STEP 4. Create Scenarios
                    // Successfully Registered In
                    if parsedJSON["status"] as! String == "200" {
                        
                        Helper.shared.instantiateViewController(identifier: "TabBar", animated: true, presentStyle: .fullScreen, by: selfVC, completion: nil)
                        
                        
                        Helper.shared.fetchUserInfo(parsedJSON: parsedJSON)
                        
                        // Some error occurred related to the entered data, like: wrong password, wrong email, etc
                    } else {

                        // save mode of casting / checking existence of Server Message
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            Helper.shared.showAlert(title: "Error", message: message, in: selfVC)
                        }
                    }
                    
                    // error while fetching JSON
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                }
            }
            
        }
        
    }
    
    
    //MARK: - Registration
    
    static func registerUser(withCredentials credentials: AuthCreditentials, selfVC: UIViewController,
                             isLoginVC: Bool,
                             completion: @escaping(Error?) -> Void ) {
        
        // STEP 1. Declaring URL of the request; declaring the body to the URL; declaring request with the safest method - POST, that no one can grab our info.
        let urlString = "http://localhost/connectIst/register.php"
        guard let url = URL(string: urlString) else { return }
        let parameters = ["email": credentials.email.lowercased(),
                          "password": credentials.password.lowercased(),
                          "userName": credentials.userName.lowercased(),
                          "fullName": credentials.fullName.lowercased()]
        
        
        DispatchQueue.main.async {
            
            AF.request(url, method: .post, parameters: parameters).responseJSON { response in
                
                // error
                if let err = response.error {
                    Helper.shared.showAlert(title: "Server Error", message: err.localizedDescription, in: selfVC)
                    return
                }
                
                // fetch JSON if no error
                do {
                    // save mode of casting data
                    guard let data = response.data else {
                        Helper.shared.showAlert(title: "Data Error", message: response.error?.localizedDescription ?? "", in: selfVC)
                        return
                    }
                    
                    // fetching all JSON received from the server
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save mode of casting JSON
                    guard let parsedJSON = json else { print("Parsing Error"); return }
                    print("DEBUG: Parsed JSON data is written below \n \(parsedJSON)")
                    
                    // STEP 4. Create Scenarios
                    // Successfully Registered In
                    if parsedJSON["status"] as! String == "200" {
                        
                        Helper.shared.instantiateViewController(identifier: "TabBar", animated: true, presentStyle: .fullScreen, by: selfVC, completion: nil)
                        
                        // saving logged user properties
//                        if let userId = parsedJSON["id"] as? String {
//                            currentUserId = Int(userId)
//                            UserDefaults.standard.set(currentUserId, forKey: "currentUserId")
//                        }
                        
                        Helper.shared.fetchUserInfo(parsedJSON: parsedJSON)
                        
                        let controller = HomeController()
                        LoginController().navigationController?.pushViewController(controller, animated: true)
                        
                        // Some error occurred related to the entered data, like: wrong password, wrong email, etc
                    } else {
                        
                        // save mode of casting / checking existence of Server Message
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            Helper.shared.showAlert(title: "Error", message: message, in: selfVC)
                        }
                        
                    }
                    
                // error while fetching JSON
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                }
            }
        }
    }
    
    
    
    
}
