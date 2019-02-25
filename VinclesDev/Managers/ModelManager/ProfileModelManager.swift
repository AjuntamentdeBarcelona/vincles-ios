//
//  ProfileModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import RealmSwift
import SwiftyJSON

class ProfileModelManager: ProfileModelManagerProtocol {
    var userIsVincle: Bool{
        let realm = try! Realm()
     
        if let user = realm.objects(User.self).first{
            return user.idCircle != -1
        }
        
        return false
    }
    
    
    
    func getUserMe() -> User?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            return user
        }
        return nil
    }
    
    func addOrUpdateUser(dict: [String:Any]){
        let realm = try! Realm()
        
        let json = JSON(dict)
        
        if let auth = realm.objects(AuthResponse.self).first{
            try! realm.write {
                auth.userId = json["id"].intValue
            }
        }
        
        try! realm.write {
            realm.create(User.self, value: ["idInstallation": json["idInstallation"].intValue, "name": json["name"].stringValue, "email": json["email"].stringValue, "lastname": json["lastname"].stringValue, "gender": json["gender"].stringValue, "active": json["active"].boolValue, "idLibrary": json["idLibrary"].intValue, "birthdate": Date(timeIntervalSince1970: TimeInterval(json["birthdate"].int64Value)), "username": json["username"].stringValue, "alias": json["alias"].stringValue, "idCircle": json["idCircle"].intValue,"id": json["id"].intValue, "idCalendar": json["idCalendar"].intValue, "idContentPhoto": json["idContentPhoto"].intValue, "phone": json["phone"].stringValue, "liveInBarcelona": json["liveInBarcelona"].boolValue], update: true)
        }
      
    }
    
    func updateUserName(name: String){
        let realm = try! Realm()

        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            try! realm.write {
                user.name = name
            }
        }
        
       
    }
    
    func updateUserSurname(lastname: String){
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            try! realm.write {
                user.lastname = lastname
            }
        }
        
        
    }
    
    func updateUserPhone(phone: String){
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            try! realm.write {
                user.phone = phone
            }
        }
        
        
    }
    
    func updateUserBcn(liveInBarcelona: Bool){
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            try! realm.write {
                user.liveInBarcelona = liveInBarcelona
            }
        }
        
        
    }
    
    func setPushToken(token: String){
        UserDefaults.standard.set(token, forKey: "pushToken")
    }
    
    func getPushToken() -> String?{
        return UserDefaults.standard.value(forKey: "pushToken") as? String
    }
    
    func setPushkitToken(token: String){
        UserDefaults.standard.set(token, forKey: "pushkitToken")

    }
    
    func getPushkitToken() -> String?{
        return UserDefaults.standard.value(forKey: "pushkitToken")  as? String
    }
    
    
    func removePushkitToken(){
        UserDefaults.standard.set(nil, forKey: "pushkitToken")
    }
    
}
