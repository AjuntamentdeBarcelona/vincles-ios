//
//  ProfileManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SwiftyJSON
import RealmSwift

class ProfileManager: NSObject {
    lazy var profileModelManager = ProfileModelManager()

    func getSelfProfile(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.getUserSelfInfo(onSuccess: { (dict) in
            self.profileModelManager.addOrUpdateUser(dict: dict)
            
            let profileManager = ProfileManager()
            profileManager.sendInstallation(onSuccess: {
                
            }, onError: { (error) in
                
            })
            
            onSuccess()
   
        }) { (error) in
            print(error)
        }
        
        
    }

    func getSelfProfileNoValidation(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.getUserSelfInfoNoValidation(onSuccess: { (dict) in
            self.profileModelManager.addOrUpdateUser(dict: dict)
            
            let profileManager = ProfileManager()
            profileManager.sendInstallation(onSuccess: {
                
            }, onError: { (error) in
                
            })
            
            onSuccess()
        }) { (error) in
            print(error)

        }
        
        
    }

    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func changeUserPhoto(photo: UIImage, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.changeUserPhoto(imageData: photo.jpegData(compressionQuality: 0.8)!, onSuccess: { (respDict) in
            onSuccess()
        }) { (error) in
            onError("")
        }
        
    }
    
    func updateUser(name: String, lastname: String, phone: String, liveInBarcelona: Bool, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        HUDHelper.sharedInstance.showHud(message: "")

        ApiClient.updateUser(name: name, lastname: lastname, phone: phone, liveInBarcelona: liveInBarcelona, onSuccess: { (result) in
            HUDHelper.sharedInstance.hideHUD()
            self.profileModelManager.updateUserName(name: name)
            self.profileModelManager.updateUserSurname(lastname: lastname)
            self.profileModelManager.updateUserPhone(phone: phone)
            self.profileModelManager.updateUserBcn(liveInBarcelona: liveInBarcelona)

            onSuccess()
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()

            onError(error)
        }
    }
    
    func changePassword(newPassword: String, currentPassword: String, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        HUDHelper.sharedInstance.showHud(message: "")
        
        ApiClient.changePassword(newPassword: newPassword, currentPassword: currentPassword, onSuccess: { (dict) in
            HUDHelper.sharedInstance.hideHUD()
            if let signInInfo = dict["signInInfo"] as? [String:AnyObject], let refresh_token = signInInfo["refresh_token"] as? String, let access_token = signInInfo["access_token"] as? String,  let expires_in = signInInfo["expires_in"] as? Int {
                
               
                let realm = try! Realm()
                
                let authResponse = realm.objects(AuthResponse.self).first!
                try! realm.write {
                    if let expiration = Calendar.current.date(byAdding: .second, value: expires_in, to: Date()){
                        authResponse.expirationDate = expiration
                    }
                    authResponse.access_token = access_token
                    authResponse.refresh_token = refresh_token

                }

                onSuccess()
                
            }
            else{
                onError(L10n.errorGenerico)

            }
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)

        }
    }
    
    
    func sendInstallation(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        let profileManager = ProfileModelManager()
      
        if let userId = profileManager.getUserMe()?.id, let pushkitToken = profileManager.getPushkitToken(){
            
            let installationId = "\(UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""))\(userId)"
            ApiClient.sendInstallation(so: "IOS", pushToken: "", imei: installationId, idUser: userId, pushkitToken: pushkitToken, onSuccess: {
                
            }, onError: { (error) in
                
            })
            
        }
        
     
    }
    
}
