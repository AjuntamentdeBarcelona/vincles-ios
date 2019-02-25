//
//  GroupMessage.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import RealmSwift
import SwiftyJSON
import UIKit

class GroupMessage: Object  {
    
    @objc dynamic var fullNameUserSender = ""
    @objc dynamic var id = -1
    @objc dynamic var idChat = -1
    @objc dynamic var idContent = -1
    @objc dynamic var idUserSender = -1
    @objc dynamic var metadataTipus = ""
    @objc dynamic var sendTime = Date(timeIntervalSince1970: 1)
    @objc dynamic var text = ""
    @objc dynamic var watched = false

    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON) {
        self.init()

        id = json["id"].intValue
        idChat = json["idChat"].intValue
        
        if json["idContent"].type != .null{
            idContent = json["idContent"].intValue
        }
        idUserSender = json["idUserSender"].intValue
        metadataTipus = json["metadataTipus"].stringValue
        fullNameUserSender = json["fullNameUserSender"].stringValue
        text = json["text"].stringValue
        sendTime = Date(timeIntervalSince1970: TimeInterval(json["sendTime"].int64Value / 1000))

        let profileModelManager = ProfileModelManager()
        if profileModelManager.getUserMe()?.id == idUserSender{
            watched = true
        }
        else if let lastAccess = UserDefaults.standard.value(forKey: "\(idChat)") as? Int64{
            if lastAccess > json["sendTime"].int64Value{
                watched = true
            }
        }
        
    }
    
    
    
    
}
