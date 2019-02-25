//
//  Notification.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class VincleNotification: Object {

    @objc dynamic var id = 0
    @objc dynamic var type = ""
    @objc dynamic var idUser = -1
    @objc dynamic var idMessage = -1
    @objc dynamic var processed = false
    @objc dynamic var creationTimeInt: Int64 = 0
    @objc dynamic var idChat = -1
    @objc dynamic var idChatMessage = -1
    @objc dynamic var idGroup = -1
    @objc dynamic var watched = false
    @objc dynamic var removed = false
    @objc dynamic var idMeeting = -1
    @objc dynamic var callStarted = false
    @objc dynamic var idRoom = ""
    @objc dynamic var code = ""
    @objc dynamic var idHost = -1
    @objc dynamic var idGalleryContent = -1

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON) {
        self.init()
        
        id = json["id"].intValue
        type = json["type"].stringValue
        creationTimeInt = json["creationTime"].int64Value
        if let info = json["info"].dictionary{
            if info["idUser"] != nil{
                idUser = info["idUser"]!.intValue
            }
            if info["idMessage"] != nil{
                idMessage = info["idMessage"]!.intValue
            }
            if info["idChat"] != nil{
                idChat = info["idChat"]!.intValue
            }
            if info["idChatMessage"] != nil{
                idChatMessage = info["idChatMessage"]!.intValue
            }
            if info["idGroup"] != nil{
                idGroup = info["idGroup"]!.intValue
            }
            if info["idMeeting"] != nil{
                idMeeting = info["idMeeting"]!.intValue
            }
            if info["idRoom"] != nil{
                idRoom = info["idRoom"]!.stringValue
            }
            if info["idHost"] != nil{
                idHost = info["idHost"]!.intValue
            }
            if info["code"] != nil{
                code = info["code"]!.stringValue
            }
            if info["idGalleryContent"] != nil{
                idGalleryContent = info["idGalleryContent"]!.intValue
            }
        }
       
    }
    
    
    
}
