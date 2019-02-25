//
//  NavigationManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SlideMenuControllerSwift

class NavigationManager: NSObject {

    lazy var dbModelManager = DBModelManager()
    func showUnauthorizedLogin(){
        
        if dbModelManager.databaseHasItems(){
            dbModelManager.removeAllItemsFromDatabase()
            
            let loginVC = StoryboardScene.Auth.loginViewController.instantiate()
            loginVC.hideBack = true
            
            if let topController = UIApplication.shared.keyWindow?.rootViewController as? SlideMenuController {
                if let nav = topController.mainViewController as? UINavigationController {
                    nav.pushViewController(loginVC, animated: true)
                }
                else if let vc = topController.mainViewController {
                    vc.navigationController?.pushViewController(loginVC, animated: true)
                }
                
                // topController should now be your topmost view controller
            }
        }
    
        
    }
}
