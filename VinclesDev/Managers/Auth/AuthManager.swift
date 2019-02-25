//
//  AuthManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SwiftyJSON
import EventKit

// MARK: Handler
class AuthManager: NSObject {
   
    lazy var dbModelManager = DBModelManager()
    lazy var authModelManager = AuthModelManager()

  
    func login(email: String, password: String, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        
        ApiClient.loginWith(username: "\(email)\(SUFFIX_LOGIN)", password: password, onSuccess: { (responseDict) in

        
         //   self.dbModelManager.removeAllItemsFromDatabase()
            
            self.authModelManager.saveAuthResponse(dict: responseDict)
            onSuccess()

          
            
            
        }) { (error) in
            self.dbModelManager.removeAllItemsFromDatabase()
            onError(error)
        }
        
    }
    
    func recoverPassword(email: String, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: L10n.cargando)
        
        ApiClient.recoverPassword(username: email, onSuccess: { () in
            HUDHelper.sharedInstance.hideHUD()
            
            onSuccess()
            
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
        
    }
    
    func registerVinculat(params: [String: Any], image: UIImage, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: L10n.cargando)

        ApiClient.registerVinculat(email: params["email"] as! String, password: params["password"] as! String, name: params["name"] as! String, lastname: params["lastname"] as! String, birthdate: params["birthdate"] as! Int, phone: params["phone"] as! String, gender: params["gender"] as! String, liveInBarcelona: params["liveInBarcelona"] as! Bool, photoMimeType: params["photoMimeType"] as? String, onSuccess: { (response) in
            if (response["id"] as? Int) != nil{
                let mediaManager = MediaManager()
                mediaManager.saveUserPhotoRegister(userId: params["email"] as! String, image: image, onCompletion: {
                    
                })
            }
            HUDHelper.sharedInstance.hideHUD()
            onSuccess()

        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
    }
    
    func validateRegister(email: String, code: String, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: L10n.cargando)
        
        ApiClient.validateRegister(username: email, code: code, onSuccess: { (responseDict) in
            HUDHelper.sharedInstance.hideHUD()
            
            onSuccess()
            
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
        
    }
    
    func logout(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {

        if let token = authModelManager.getAccessToken(){
            
            let authorizationStatus = EKEventStore.authorizationStatus(for: .event);
            switch authorizationStatus {
            case .notDetermined:
                print("notDetermined");
            case .restricted:
                print("restricted");
            case .denied:
                print("denied");
            case .authorized:
                EventsLoader.removeAllEvents()
                EventsLoader.removeCalendar()

            }
            
            UserDefaults.standard.set(nil, forKey: "loginTime")
            UserDefaults.standard.set(false, forKey: "tutorialShown")
            HUDHelper.sharedInstance.showHud(message: L10n.cargando)
            ApiClient.logoutWith(token: token, onSuccess: {
                HUDHelper.sharedInstance.hideHUD()
                
                let mediaManager = MediaManager()
                mediaManager.clearCacheFolder()
                
                UserDefaults.standard.set(false, forKey: "loginDone")
               // self.dbModelManager.removeAllItemsFromDatabase()
                
       
                onSuccess()
                
            }) { (error) in
                HUDHelper.sharedInstance.hideHUD()
                
                let mediaManager = MediaManager()
                mediaManager.clearCacheFolder()
                UserDefaults.standard.set(false, forKey: "loginDone")

                // self.dbModelManager.removeAllItemsFromDatabase()
                
        
                onError(error)
            }
        }
        
        
    }
    
    
}


