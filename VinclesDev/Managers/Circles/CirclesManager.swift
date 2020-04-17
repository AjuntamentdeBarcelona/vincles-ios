//
//  CirclesManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SwiftyJSON

class CirclesManager: NSObject {
    lazy var profileModelManager = ProfileModelManager()

    func getCirclesUser(onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        var changes = false
        if profileModelManager.userIsVincle{
            ApiClient.getCirclesUser(onSuccess: { (array) in
                
                changes = CirclesGroupsModelManager.shared.addCircles(array: array)
                
                onSuccess(changes)
                
            }) { (error) in
                print(error)
                onError(error)
            }
        }
        else{
            ApiClient.getCirclesUserVinculat(onSuccess: { (array) in
                
                changes = CirclesGroupsModelManager.shared.addCirclesVinculat(array: array)
                
                onSuccess(changes)
                
            }) { (error) in
                print(error)
                onError(error)
            }
        }
      
    }
        
    func getGroupsUser(onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        var changes = false

        ApiClient.getGroupsUser(onSuccess: { (array) in
            
           changes = CirclesGroupsModelManager.shared.addGroups(array: array)

            onSuccess(changes)
            
        }) { (error) in
            print(error)
            onError(error)
        }
    }
    
   
    
    func generateCode(onSuccess: @escaping (String) -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.generateCode(onSuccess: { (dict) in
            
            if let registerCode = dict["registerCode"] as? String{
                onSuccess(registerCode)
            }
            else{
                onSuccess("")
            }
            
        }) { (error) in
            onError( L10n.errorNetworkCodi)
            print(error)
        }
    }
    
    func removeContact(contactId: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        ApiClient.removeContact(contactId: contactId, onSuccess: {
            
            CirclesGroupsModelManager.shared.removeContactItem(id: contactId)
            HUDHelper.sharedInstance.hideHUD()
            onSuccess()
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
    }
    
    
    func removeContactFromVinculat(idCircle: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        ApiClient.removeContactFromVinculat(idCircle: idCircle, onSuccess: {
            CirclesGroupsModelManager.shared.removeContactItemCircle(id: idCircle)
            HUDHelper.sharedInstance.hideHUD()
            onSuccess()
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
    }
    
    
    
    func addCode(code: String, relationShip: String, onSuccess: @escaping (User) -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        ApiClient.addCode(code: code, relationShip: relationShip, onSuccess: { (respDict) in
            
            onSuccess(CirclesGroupsModelManager.shared.addCircle(dict: respDict)!)
            HUDHelper.sharedInstance.hideHUD()
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
       
    }
    
    func getUserBasicInfo(id: Int, onSuccess: @escaping (User) -> (), onError: @escaping (String, Int) -> ()) {
        
        ApiClient.getUserBasicInfo(id: id, onSuccess: { (respDict) in
            
            if let user = CirclesGroupsModelManager.shared.updateUser(dict: respDict){
                onSuccess(user)
            }
            else{
                onError("", 403)
            }
        }) { (error, status) in
            onError(error, status)
        }
        
    }
    
    func getUserFullInfo(id: Int, onSuccess: @escaping (User) -> (), onError: @escaping (String, Int) -> ()) {
        
        ApiClient.getUserFullInfo(id: id, onSuccess: { (respDict) in
            
            if let user = CirclesGroupsModelManager.shared.addContact(dict: respDict){
                onSuccess(user)
            }
            else{
                onError("", 0)
            }
        }) { (error, status) in
            onError(error, status)
        }
        
    }
    
    
    func getAllGroupsParticipants(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        let numberOfGroups = CirclesGroupsModelManager.shared.numberOfGroups
        var completed = 0
        if let groups = CirclesGroupsModelManager.shared.groups{
            if groups.count == 0{
                onSuccess()
                
            }
            else{
                for group in groups{
                    self.getGroupParticipants(id: group.id, onSuccess: { (hasChanges) in
                        completed += 1
                        if completed == numberOfGroups{
                            onSuccess()
                        }
                    }) { (error, status) in
                        onError(error)
                    }
                  
                }
            }
            
            
        }
        else{
            onSuccess()
        }
        
    }
    
    
    func getGroupParticipants(id: Int, onSuccess: @escaping (Bool) -> (), onError: @escaping (String, Int) -> ()) {
        var changes = false
        
        ApiClient.getGroupParticipants(id: id, onSuccess: { (array) in
            changes = CirclesGroupsModelManager.shared.addGroupParticipants(id: id, array: array)
            
            onSuccess(changes)
        }) { (error, status) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error, status)
        }
        
        
    }
    
    func userIsCircle(id: Int) -> Bool{
        if let circles = CirclesGroupsModelManager.shared.circles{
            for user in circles{
                if user.id == id{
                    return true
                }
            }
        }
        return false
    }
    
    func userIsDinamitzador(id: Int) -> Bool{
        if let groups = CirclesGroupsModelManager.shared.groups{
            for group in groups{
                if group.dynamizer?.id == id{
                    return true
                }
            }
        }
        
        
        return false
    }
    
    
    func userIsCircleOrDynamizer(id: Int) -> Bool{
        if let circles = CirclesGroupsModelManager.shared.circles{
            for user in circles{
                if user.id == id{
                    return true
                }
            }
        }
    
        
        if let groups = CirclesGroupsModelManager.shared.groups{
            for group in groups{
                if group.dynamizer?.id == id{
                    return true
                }
            }
        }

       
        return false
    }
    
    func groupForDinamitzador(id: Int) -> Group?{
        if let groups = CirclesGroupsModelManager.shared.groups{
            for group in groups{
                if group.dynamizer?.id == id{
                    return group
                }
            }
        }
        
        
        return nil
    }
    
    
    
    func updateGroup(id: Int, onSuccess: @escaping () -> (), onError: @escaping (String, Int) -> ()) {
        
        ApiClient.getGroupsUser(onSuccess: { (array) in
            
            var found = false
            for dict in array{
                if let groupDict = dict["group"] as? [String:AnyObject]{
                    if let dictId = groupDict["id"] as? Int, dictId == id{
                        found = true
                        if CirclesGroupsModelManager.shared.updateGroup(id: id, dict: dict){
                            onSuccess()
                        }
                        else{
                            onError("", 403)
                        }
                    }
                }
                
             
            }
            if found == false{
                onError("", 403)
            }
            
        }) { (error) in
            onError(error, 0)
        }
    }
    
    func inviteUserFromGroup(groupId: Int, userId: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        ApiClient.inviteUserFromGroup(groupId: groupId, userId: userId, onSuccess: {
            HUDHelper.sharedInstance.hideHUD()
            onSuccess()

        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)

        }
    }
  
}
