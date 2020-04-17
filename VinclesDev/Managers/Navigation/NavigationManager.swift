//
//  NavigationManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SlideMenuControllerSwift
import Alamofire

class NavigationManager: NSObject {

    lazy var dbModelManager = DBModelManager()
    func showUnauthorizedLogin(){
        
        ApiClient.manager.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
        
        let notificationName = Notification.Name(NOTI_TOKEN_EXPIRED)
        NotificationCenter.default.post(name: notificationName, object: nil)

        let mediaManager = MediaManager()
        mediaManager.clearCacheFolder()
        
        ContentManager.sharedInstance.downloadingIds.removeAll()
        ContentManager.sharedInstance.errorIds.removeAll()
        ContentManager.sharedInstance.corruptedIds.removeAll()
        ProfileImageManager.sharedInstance.downloadingIds.removeAll()
        ProfileImageManager.sharedInstance.errorIds.removeAll()
        
        if dbModelManager.databaseHasItems(){
            
            let loginVC = StoryboardScene.Auth.loginViewController.instantiate()
            loginVC.hideBack = true
            
            

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if !appDelegate.showingLogin{
                appDelegate.showingLogin = true

                if let topController = UIApplication.shared.keyWindow?.rootViewController as? SlideMenuController {
                    topController.closeLeft()

                    if let nav = topController.mainViewController as? UINavigationController {
                        nav.pushViewController(loginVC, animated: true)
                        
                    }
                    else if let vc = topController.mainViewController {
                        vc.navigationController?.pushViewController(loginVC, animated: true)
                        
                    }
                    
                    
                    
                    // topController should now be your topmost view controller
                }
                else if let topController = UIApplication.shared.keyWindow?.rootViewController as? UIViewController {
                    topController.dismiss(animated: false) {
                        
                        Timer.after(0.2.second, {
                            if let topController = UIApplication.shared.keyWindow?.rootViewController as? SlideMenuController {
                                topController.closeLeft()
                                
                                if let nav = topController.mainViewController as? UINavigationController {
                                    
                                    nav.pushViewController(loginVC, animated: true)
                                    
                                }
                                else if let vc = topController.mainViewController {
                                    vc.navigationController?.pushViewController(loginVC, animated: true)
                                    
                                }
                                
                                
                                
                            }
                        })
                        
                    }
                }
            }
            
            
          
        }
    
        
    }
}
