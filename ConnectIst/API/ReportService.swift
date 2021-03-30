//
//  ReportService.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 26.03.2021.
//

import UIKit

//typealias NetworkCompletion = (Error?) -> Void

struct ReportService {
    
    static let shared = ReportService()
    
    func uploadReport(postId: Int, userId: Int, reason: String, byUserId: Int,
                      selfVC: UIViewController) {
        
        //http://localhost/connectIst/report.php?post_id=64&user_id=13&reason=inappropriate&byUser_id=11
        
        guard let url = URL(string: "http://localhost/connectIst/report.php") else { return }
        let body = "post_id=\(postId)&user_id=\(userId)&reason=\(reason)&byUser_id=\(byUserId)"
        
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
                    let json = try JSONDecoder().decode(Status.self, from: data)
//                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
//                    print(json)
                    if json.status == "200" {
                        Helper.shared.showAlert(title: "Success!", message: "Report has been sent successfully.", in: selfVC)
                    } else {
                        Helper.shared.showAlert(title: "Error!", message: json.message, in: selfVC)
                    }
                    
                } catch {
                    Helper.shared.showAlert(title: "JSON Error", message: error.localizedDescription, in: selfVC)
                    return
                }
            }
            
        }
        task.resume()
    }
    
}
