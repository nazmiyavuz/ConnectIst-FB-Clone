//
//  SceneDelegate.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 15.02.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene as! UIWindowScene)
//        window?.rootViewController = HomeVC()
//        isUserLoggedIn = defaults.bool(forKey: "currentUser")
        
        currentUser = getUserInfosFromUserDefault()
        
        let userId = currentUser?.id
        print(currentUser)
        if userId != nil && userId != 0 {
            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar")
            window?.rootViewController = TabBar
        } else {
            window?.rootViewController = UINavigationController(rootViewController: LoginController())
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func getUserInfosFromUserDefault() -> CurrentUser {
        
        let id = UserDefaults.standard.integer(forKey: "currentUserId")
        let email = UserDefaults.standard.string(forKey: "currentUserEmail") ?? ""
        let userName = UserDefaults.standard.string(forKey: "currentUserUserName") ?? ""
        let fullName = UserDefaults.standard.string(forKey: "currentUserFullName") ?? ""
        let cover = UserDefaults.standard.string(forKey: "currentUserCover") ?? ""
        let ava = UserDefaults.standard.string(forKey: "currentUserAva") ?? ""
        let bio = UserDefaults.standard.string(forKey: "currentUserBio")
        let allowFriends = UserDefaults.standard.string(forKey: "currentUserAllowFriends") ?? "1"
        let allowFollow = UserDefaults.standard.string(forKey: "currentUserAllowFollow") ?? "1"
        
        
        let user = CurrentUser(id: id, email: email, userName: userName, fullName: fullName,
                               cover: cover, ava: ava, bio: bio,
                               allowFriends: allowFriends, allowFollow: allowFollow)
        
        return user
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

