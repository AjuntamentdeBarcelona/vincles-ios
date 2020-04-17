//
//  DBModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import RealmSwift

class DBModelManager: DBModelManagerProtocol {
    func databaseHasItems() -> Bool{
        let realm = try! Realm()
        
        if realm.objects(AuthResponse.self).first != nil{
            return true
        }
        return false
    }
    
    
    func removeAllItemsFromDatabase(){
        let realm = try! Realm()

        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Could not delete object.\n\(String(describing: error.localizedDescription))")
            
        }
        
       
        /*
        for user in realm.objects(User.self){
            do {
                try realm.write {
                    realm.delete(user)
                }
            } catch {
                print("Could not delete object.\n\(String(describing: error.localizedDescription))")
                
            }
        }
        
        

        let allNotifications = realm.objects(VincleNotification.self)
        do {
            try realm.write {
                realm.delete(allNotifications)
            }
        } catch {
            print("Could not delete object.\n\(String(describing: error.localizedDescription))")
            
        }
        
      
        let allContents = realm.objects(Content.self)
        do {
            try realm.write {
                realm.delete(allContents)
            }
        } catch {
            print("Could not delete object.\n\(String(describing: error.localizedDescription))")
            
        }
        
        let allGroups = realm.objects(Group.self)
        do {
            try realm.write {
                realm.delete(allGroups)
            }
        } catch {
            print("Could not delete object.\n\(String(describing: error.localizedDescription))")
            
        }
        
        let allAuth = realm.objects(AuthResponse.self)
        do {
            try realm.write {
                realm.delete(allAuth)
            }
        } catch {
            print("Could not delete object.\n\(String(describing: error.localizedDescription))")
            
        }
       */
        /*
        let allMessages = realm.objects(Message.self)
        do {
            try realm.write {
                realm.delete(allMessages)
            }
        } catch {
            print("Could not delete object.\n\(String(describing: error.localizedDescription))")
            
        }
 */
        
        
 
    }
}
