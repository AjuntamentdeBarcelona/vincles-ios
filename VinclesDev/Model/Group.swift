//
//  Group.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import RealmSwift
import SwiftyJSON


class Neighborhood: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var idDistrict = 0
    @objc dynamic var nameDistrict = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON) {
        self.init()
        id = json["id"].intValue
        name = json["name"].stringValue
        idDistrict = json["idDistrict"].intValue
        nameDistrict = json["nameDistrict"].stringValue
    }
    
}

class Group: Object {
    @objc dynamic var idDynamizerChat = 0
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var topic = ""
    @objc dynamic var neighborhood: Neighborhood?
    @objc dynamic var descript = ""
    @objc dynamic var idUserDynamizer = 0
    @objc dynamic var dynamizer: User?
    @objc dynamic var idChat = 0
    let messages = List<GroupMessage>()
    let dynamizerMessages = List<GroupMessage>()
    let users = List<User>()

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON, idDynChat: Int = 0) {
        self.init()
        idDynamizerChat = idDynChat
        id = json["id"].intValue
        name = json["name"].stringValue
        topic = json["topic"].stringValue
        neighborhood = Neighborhood(json:  json["neighborhood"])
        descript = json["description"].stringValue
        idUserDynamizer = json["idUserDynamizer"].intValue
        idChat = json["idChat"].intValue

        let jsonUser = json["dynamizer"]
        
        let realm = try! Realm()
        try! realm.write {
            let user = realm.create(User.self, value: ["name": jsonUser["name"].stringValue, "lastname": jsonUser["lastname"].stringValue, "gender": jsonUser["gender"].stringValue, "active": jsonUser["active"].boolValue, "alias": jsonUser["alias"].stringValue, "id": jsonUser["id"].intValue, "idContentPhoto": jsonUser["idContentPhoto"].intValue], update: true)
            
            
            dynamizer = user
        }  
    }
    
}
