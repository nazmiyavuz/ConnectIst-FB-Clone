//
//  MainTabController.swift
//  ConnectIst
//
//  Created by Nazmi Yavuz on 18.02.2021.
//

import UIKit


class MainTabController: UITabBarController {
    
    // MARK: - Properties
        
    //MARK: - LifeCycle
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    
    
    // MARK: - Helpers
    
    // Declare Controllers, tabBar attributes and navigation controller attributes
    func configureViewControllers() {
        // declaring screen background color of the whole controllers under the MainTabBarController
        view.backgroundColor = UIColor(named: K.Screen.backGroundColor)
        
        // declare HomeVC under the MainTabBarController
        let home = templateNavigationController(
            selectedImage: UIImage(systemName: "house.fill")!,
            unselectedImage: UIImage(systemName: "house")!,
            tabbarIconTitle: "Home",
            navbarTitle: "Home",
            rootViewController: Home2VC())
        
        
        // add viewControllers in the tabBarController
        viewControllers = [home]
        
        // declaring the color of tabBar icon and name
//        tabBar.tintColor = UIColor(named: K.Screen.backGroundColor)
        
        // tabbar background color
        tabBar.barTintColor = UIColor(named: K.Screen.backGroundColor)
        
        // tabBar background color isTranslucent = false
        tabBar.isTranslucent = false
    }
    
    // Declare navigation bar attributes
    func templateNavigationController(selectedImage: UIImage,unselectedImage: UIImage,  tabbarIconTitle: String, navbarTitle: String, rootViewController: UIViewController) -> UINavigationController{
        
        // create a nav bar variable to return 
        let nav = UINavigationController(rootViewController: rootViewController)
        
        // Executing an icon of the tabBar for unSelected condition
        nav.tabBarItem.image = unselectedImage
        // Executing an icon of the tabBar for selected condition
        nav.tabBarItem.selectedImage = selectedImage
        
        // declare tabBar a title under the tabBar icon
        nav.tabBarItem.title = tabbarIconTitle
        
        // Declaring navigation bar background color
        nav.navigationBar.barTintColor = UIColor(named: K.Screen.backGroundColor)
        nav.navigationBar.isTranslucent = false
        
        // declare navigation title at the upper part of the screen and execute title attributes
        rootViewController.navigationItem.title = navbarTitle
//        nav.navigationBar.titleTextAttributes = [
//            NSAttributedString.Key.font: UIFont(name: K.Fonts.navBarTitleFont,
//                                                size: view.frame.width/17)!,
//            NSAttributedString.Key.foregroundColor:UIColor(named: K.Colors.navBarTitleColor)!
//        ]
        return nav
    }
    
    
    
}
