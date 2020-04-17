//
//  CirclesGroupsModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import RealmSwift
import SwiftyJSON

class CirclesGroupsModelManager: CirclesGroupsModelManagerProtocol{

    private(set) static var shared:CirclesGroupsModelManager = {
        return CirclesGroupsModelManager()
    }()
    
    private init(){
        
    }
    
    var numberOfContacts: Int{
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).first{
            return user.circles.count
        }
        
        return 0
    }
    
    var circles: List<User>?{
        let realm = try! Realm()

        if let user = realm.objects(User.self).first{
            return user.circles
        }
        
        return nil
    }
    

    
    func contactAt(index: Int) -> User{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.circles[index]
    }
    
    func contactWithId(id: Int) -> User?{
        let realm = try! Realm()
        
        if (realm.objects(User.self).first?.circles.filter("id == %i", id).count)! > 0{
            return realm.objects(User.self).first?.circles.filter("id == %i", id).first!
        }
        
        return nil
    }
    
   
    func dinamitzadorWithId(id: Int) -> User?{
        let realm = try! Realm()
        
        if (realm.objects(User.self).first?.dinamizadores.filter("id == %i", id).count)! > 0{
            return realm.objects(User.self).first?.dinamizadores.filter("id == %i", id).first!
        }
        
        return nil
    }
    
    
    
    func userWithId(id: Int) -> User?{
        let realm = try! Realm()
        return realm.objects(User.self).filter("id == %i", id).first
    }
    
    
    var groups: List<Group>?{
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).first{
            return user.groups
        }
        
        return nil
    }
    
    
    var numberOfGroups: Int{
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).first{
            return user.groups.count
        }
        
        return 0
    }
    
    func groupAt(index: Int) -> Group{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.groups[index]
    }
    
    func groupWithId(id: Int) -> Group?{
        let realm = try! Realm()
       
         return realm.objects(Group.self).filter("id == %i", id).first
    }
    
    func userGroupWithId(id: Int) -> Group?{
        let realm = try! Realm()
        
        if (realm.objects(User.self).first?.groups.filter("id == %i", id).count)! > 0{
            return realm.objects(User.self).first?.groups.filter("id == %i", id).first!
        }
        
        return nil
    }
    
    func userGroupWithIdChat(idChat: Int) -> Group?{
        let realm = try! Realm()
        
        if (realm.objects(User.self).first?.groups.filter("idChat == %i", idChat).count)! > 0{
            return realm.objects(User.self).first?.groups.filter("idChat == %i", idChat).first!
        }
        
        return nil
    }
    
    func groupWithChatId(idChat: Int) -> Group?{
        let realm = try! Realm()
        return realm.objects(Group.self).filter("idChat == %i", idChat).first
    }
    
    func dinamitzadorWithChatId(idChat: Int) -> Group?{
        
        if let groups = groups{
            for group in groups{
                if group.idDynamizerChat == idChat{
                    return group
                }
            }
        }

        return nil
    }
    
    func dinamitzadorWithChatIdInDB(idChat: Int) -> Group?{
        
        let realm = try! Realm()
        let groupsDB = realm.objects(Group.self)
        
            for group in groupsDB{
                if group.idDynamizerChat == idChat{
                    return group
                }
            }
        
        
        return nil
    }
    
    
    func groupParticipantAt(index: Int, id: Int) -> User?{
        let profileModelManager = ProfileModelManager()
        let me = profileModelManager.getUserMe()
        
        if let group = self.groupWithId(id: id){
         //   return group.users.filter("id != %i", me?.id ?? -1)[index]
            return group.users[index]

        }
        
        return nil
        
    }
    
    var numberOfDinamizadores: Int{
        let realm = try! Realm()
        
        if let user = realm.objects(User.self).first{
            return user.dinamizadores.count
        }
        
        return 0
    }
    
    func dinamizadorAt(index: Int) -> User{
        let realm = try! Realm()
        
        let user = realm.objects(User.self).first!
        return user.dinamizadores[index]
    }
    
    func addCircles(array: [[String:Any]]) -> Bool{
        var changes = false
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            
            var ids = [Int]()
            
            for dict in array{

                if let userDict = dict["user"] as? [String:AnyObject], let relation = dict["relationship"] as? String{
                    let contact = User(json: JSON(userDict), relation: relation)
                    if contact.active == 1{
                        ids.append(contact.id)
                        
                        if realm.objects(User.self).first?.circles.filter("id == %i", contact.id).count == 0{
                            changes = true
                            try! realm.write {
                                realm.add(contact, update: true)
                                if user.circles.index(of: contact) == nil{
                                    user.circles.append(contact)
                                }
                                
                            }
                        }
                    }
                    
                    
                    
                }
            }
            
           
            
        }
        
        return changes
        
    }
    
    func addCircle(dict: [String:Any]) -> User?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            if let userDict = dict["userVincles"] as? [String:AnyObject], let relation = dict["relationship"] as? String{
                let contact = User(json: JSON(userDict), relation: relation)
                if contact.active == 1{
                    try! realm.write {
                        realm.add(contact, update: true)
                        if user.circles.index(of: contact) == nil{
                            user.circles.append(contact)
                        }
                        
                    }
                }
              
               
                
                return contact
            }
            
        }
        return nil
        
    }
    
    func addContact(dict: [String:Any]) -> User?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
                let contact = User(json: JSON(dict), relation: "")
                if contact.active == 1{
                    try! realm.write {
                        realm.add(contact, update: true)
                        if user.circles.index(of: contact) == nil && user.dinamizadores.index(of: contact) == nil{
                            user.circles.append(contact)
                        }
                        
                    }
                }
              
                
                return contact
            
            
        }
        return nil
        
    }
    
    func updateUser(dict: [String:Any]) -> User?{
        let realm = try! Realm()
        
        if let id = dict["id"] as? Int{
            if let contact = self.userWithId(id: id){
               
                try! realm.write {
                    if let name = dict["name"] as? String{
                        contact.name = name
                    }
                    if let lastname = dict["lastname"] as? String{
                        contact.lastname = lastname
                    }
                    if let alias = dict["alias"] as? String{
                        contact.alias = alias
                    }
                    if let gender = dict["gender"] as? String{
                        contact.gender = gender
                    }
                    if let idContentPhoto = dict["idContentPhoto"] as? Int{
                        if contact.idContentPhoto != idContentPhoto{
                            contact.idContentPhoto = idContentPhoto
                            ProfileImageManager.sharedInstance.removeProfilePicture(userId: id)
                        }
                    }
                   
                }
                
                return contact
                
            }
        }
       
        return nil
        
    }
    
    func addCirclesVinculat(array: [[String:Any]]) -> Bool{
        var changes = false
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            try! realm.write {
                user.circles.removeAll()
            }
            
            var ids = [Int]()
            
            
            for dict in array{

                
                if let circleDict = dict["circle"] as? [String:AnyObject], let userDict = circleDict["userVincles"] as? [String:AnyObject],  let relation = dict["relationship"] as? String{
                    let contact = User(json: JSON(userDict), relation: relation)
                    
                    if contact.active == 1{
                        ids.append(contact.id)
                        if realm.objects(User.self).first?.circles.filter("id == %i", contact.id).count == 0{
                            changes = true
                            
                            try! realm.write {
                                realm.add(contact, update: true)
                                if user.circles.index(of: contact) == nil{
                                    user.circles.append(contact)
                                }
                                
                            }
                        }
                    }
                   
                    
                   
                }
            }
            
            if self.removeUnexistingCircleItems(apiItems: ids){
                changes = true
            }
        }
        
        return changes
    }
    
    
    func addGroups(array: [[String:Any]]) -> Bool{
        var changes = false
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            
            var ids = [Int]()
            
            for dict in array{
                
                if let groupDict = dict["group"] as? [String:AnyObject], let idDynamizerChat = dict["idDynamizerSharedChat"] as? Int{
                    let group = Group(json: JSON(groupDict), idDynChat: idDynamizerChat)
                    ids.append(group.id)
                    
                    if realm.objects(User.self).first?.groups.filter("id == %i", group.id).count == 0{
                        changes = true
                        try! realm.write {
                            realm.add(group, update: true)
                            
                            if user.groups.index(of: group) == nil{
                                user.groups.append(group)
                            }
                            
                            if let dynam = group.dynamizer{
                                
                                if realm.objects(User.self).first?.dinamizadores.filter("id == %i", dynam.id).count == 0{
                                    changes = true
                                    if user.dinamizadores.index(of: dynam) == nil{
                                        user.dinamizadores.append(dynam)
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                    }
                   
                    
                    
                }
                
            }
            
            if self.removeUnexistingGroupItems(apiItems: ids){
                changes = true
            }
            
        }
        
        return changes
    }
    
    // REMOVE
    
    func removeContactItem(id: Int) -> Bool{
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            if let contact = user.circles.filter("id == %i",id).first{
                try! realm.write {
                    user.circles.remove(at: user.circles.index(of: contact)!)
                  //  realm.delete(contact)
                }
                return true
            }
            else{
                return false
            }

        }
        return false
    }
    
    func removeContactItemCircle(id: Int) -> Bool{
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            if let contact = user.circles.filter("idCircle == %i",id).first{
                try! realm.write {
                    user.circles.remove(at: user.circles.index(of: contact)!)
                   // realm.delete(contact)
                    
                }
                return true

            }
            else{
                return false
            }
            
        }
        return false

    }
    
    func removeGroupItem(id: Int) -> Bool{
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            if let group = user.groups.filter("id == %i",id).first{
                try! realm.write {
                    user.groups.remove(at: user.groups.index(of: group)!)
                   // realm.delete(group)
                    
                    var deleteDinam = true
                    let idDynam = group.idUserDynamizer
                    for group in user.groups{
                        if group.idUserDynamizer == idDynam{
                            deleteDinam = false
                        }
                    }
                    
                    
                    if deleteDinam{
                        if let dinam = user.dinamizadores.filter("id == %i",idDynam).first{
                            user.dinamizadores.remove(at: user.dinamizadores.index(of: dinam)!)
                        }
                    }
                    
                }
                return true
            }
            else{
                return false
            }
            
        }
        
        return false

    }
    
    func removeUserFromGroup(idGroup: Int, idUser: Int) -> Bool{
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            if let group = user.groups.filter("id == %i",idGroup).first, let user = group.users.filter("id == %i",idUser).first{
                try! realm.write {
                    group.users.remove(at: group.users.index(of: user)!)
                    
                }
                return true

            }
            else{
                return false
            }
            
        }
        return false

    }
    
    
    
    func removeUnexistingGroupItems(apiItems: [Int]) -> Bool{
        var changes = false
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            let groups = user.groups
            for group in groups{
                var remove = true
                for id in apiItems{
                    if group.id == id{
                        remove = false
                    }
                }
                if remove{
                    try! realm.write {
                        changes = true
                        
                        let dynamId = group.dynamizer?.id
                        
                        user.groups.remove(at: user.groups.index(of: group)!)
                        realm.delete(group)
                        
                        if let id = dynamId, let dinam = realm.objects(User.self).first?.dinamizadores.filter("id == %i", id).first{
                            user.dinamizadores.remove(at: user.dinamizadores.index(of: dinam)!)
                            realm.delete(dinam)
                        }
                        
                    }
                    
                }
            }
            
        }
        return changes
    }
    
    func removeUnexistingCircleItems(apiItems: [Int]) -> Bool{
        var changes = false
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
            let circles = user.circles
            for circle in circles{
                var remove = true
                for id in apiItems{
                    if circle.id == id{
                        remove = false
                    }
                }
                if remove{
                    changes = true
                    try! realm.write {
                        user.circles.remove(at: user.circles.index(of: circle)!)
                        realm.delete(circle)
                        
                    }
                    
                }
            }
            
        }
        return changes
    }
    
    func addGroupParticipants(id: Int, array: [[String:Any]]) -> Bool{
        
        let realm = try! Realm()
        
        if let group = self.groupWithId(id: id){
                        
            for dict in array{
               
                
           
                    try! realm.write {
                         let contact = realm.create(User.self, value: ["name": dict["name"], "lastname": dict["lastname"], "alias": dict["alias"], "id": dict["id"], "idContentPhoto": dict["idContentPhoto"]], update: true)
                        realm.add(contact, update: true)
                        if group.users.index(of: contact) == nil{
                            group.users.append(contact)
                        }
                        
                    }
                }
            
            
        }
        
        return true
        
    }
    
    func updateGroup(id: Int, dict: [String:Any]) -> Bool{
        let realm = try! Realm()
        
        if let groupDict = dict["group"] as? [String:AnyObject], let idDynamizerChat = dict["idDynamizerSharedChat"] as? Int, let dinamDict = groupDict["dynamizer"] as? [String:AnyObject]{
            if let group = self.groupWithId(id: id){
                
                GroupImageManager.sharedInstance.removeGroupPicture(groupId: id)
                
                try! realm.write {
                    group.idDynamizerChat = idDynamizerChat
                    if let name = groupDict["name"] as? String{
                        group.name = name
                    }
                    if let topic = groupDict["topic"] as? String{
                        group.topic = topic
                    }
                    if let descript = groupDict["description"] as? String{
                        group.descript = descript
                    }
                    if let idUserDynamizer = groupDict["idUserDynamizer"] as? Int{
                        group.idUserDynamizer = idUserDynamizer
                    }
                    if let idChat = groupDict["idChat"] as? Int{
                        group.idChat = idChat
                    }
                    if let neighborhoodDict = dict["neighborhood"] as? [String:AnyObject]{
                       let neighborhood = Neighborhood(json: JSON(neighborhoodDict))
                       group.neighborhood = neighborhood
                        
                    }
                    
                }
                
                let jsonUser = JSON(dinamDict)
                let realm = try! Realm()
                try! realm.write {
                    let user = realm.create(User.self, value: ["name": jsonUser["name"].stringValue, "lastname": jsonUser["lastname"].stringValue, "gender": jsonUser["gender"].stringValue, "active": jsonUser["active"].intValue, "alias": jsonUser["alias"].stringValue, "id": jsonUser["id"].intValue, "idContentPhoto": jsonUser["idContentPhoto"].intValue], update: true)
                    
                    
                    group.dynamizer = user
                }
                return true

            }
            else{
                return false
            }
        }
        else{
            return false
        }
        
       
        
    }
    
   
}
