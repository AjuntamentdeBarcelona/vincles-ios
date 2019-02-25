//
//  CirclesManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SwiftyJSON

class CirclesManager: NSObject {
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager()
    lazy var profileModelManager = ProfileModelManager()

    func getCirclesUser(onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        var changes = false
        if profileModelManager.userIsVincle{
            ApiClient.getCirclesUser(onSuccess: { (array) in
                
                changes = self.circlesGroupsModelManager.addCircles(array: array)
                
                onSuccess(changes)
                
            }) { (error) in
                print(error)
            }
        }
        else{
            ApiClient.getCirclesUserVinculat(onSuccess: { (array) in
                
                changes = self.circlesGroupsModelManager.addCirclesVinculat(array: array)
                
                onSuccess(changes)
                
            }) { (error) in
                print(error)
            }
        }
      
    }
        
    func getGroupsUser(onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        var changes = false

        ApiClient.getGroupsUser(onSuccess: { (array) in
            
           changes = self.circlesGroupsModelManager.addGroups(array: array)

            onSuccess(changes)
            
        }) { (error) in
            print(error)
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
            print(error)
        }
    }
    
    func removeContact(contactId: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        ApiClient.removeContact(contactId: contactId, onSuccess: {
            
           // let mediaManager = MediaManager()
          //  mediaManager.removeFiles(contactId: contactId)
            self.circlesGroupsModelManager.removeContactItem(id: contactId)
            HUDHelper.sharedInstance.hideHUD()
            
            onSuccess()
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError("")
        }
    }
    
    
    func removeContactFromVinculat(idCircle: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        ApiClient.removeContactFromVinculat(idCircle: idCircle, onSuccess: {
            self.circlesGroupsModelManager.removeContactItemCircle(id: idCircle)
           HUDHelper.sharedInstance.hideHUD()
            
            onSuccess()
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError("")
        }
    }
    
    
    
    func addCode(code: String, relationShip: String, onSuccess: @escaping (User) -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        
        ApiClient.addCode(code: code, relationShip: relationShip, onSuccess: { (respDict) in
            
            
            onSuccess(self.circlesGroupsModelManager.addCircle(dict: respDict)!)

            HUDHelper.sharedInstance.hideHUD()

        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
       
    }
    
    func getUserBasicInfo(id: Int, onSuccess: @escaping (User) -> (), onError: @escaping (String, Int) -> ()) {
        
        
        ApiClient.getUserBasicInfo(id: id, onSuccess: { (respDict) in
            
            if let user = self.circlesGroupsModelManager.updateUser(dict: respDict){
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
            
            if let user = self.circlesGroupsModelManager.addContact(dict: respDict){
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
        let numberOfGroups = circlesGroupsModelManager.numberOfGroups
        var completed = 0
        if let groups = circlesGroupsModelManager.groups{
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
                        onError("")
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
            changes = self.circlesGroupsModelManager.addGroupParticipants(id: id, array: array)
            
            onSuccess(changes)
        }) { (error, status) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error, status)
        }
        
        
    }
    
    func userIsCircle(id: Int) -> Bool{
        if let circles = circlesGroupsModelManager.circles{
            for user in circles{
                if user.id == id{
                    return true
                }
            }
        }
        
        
        return false
    }
    
    func userIsDinamitzador(id: Int) -> Bool{
        if let groups = circlesGroupsModelManager.groups{
            for group in groups{
                if group.dynamizer?.id == id{
                    return true
                }
            }
        }
        
        
        return false
    }
    
    
    func userIsCircleOrDynamizer(id: Int) -> Bool{
        if let circles = circlesGroupsModelManager.circles{
            for user in circles{
                if user.id == id{
                    return true
                }
            }
        }
    
        
        if let groups = circlesGroupsModelManager.groups{
            for group in groups{
                if group.dynamizer?.id == id{
                    return true
                }
            }
        }

       
        return false
    }
    
    func groupForDinamitzador(id: Int) -> Group?{
        if let groups = circlesGroupsModelManager.groups{
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
                        if self.circlesGroupsModelManager.updateGroup(id: id, dict: dict){
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
