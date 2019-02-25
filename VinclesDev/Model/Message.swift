//
//  Message.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import RealmSwift
import SwiftyJSON
import UIKit

class Message: Object  {
 
    @objc dynamic var id = 0
    let idAdjuntContents = List<Int>()
    @objc dynamic var idUserFrom = 0
    @objc dynamic var idUserTo = 0
    let idUserToList = List<Int>()
    @objc dynamic var metadataTipus = ""
    @objc dynamic var sendTime = Date(timeIntervalSince1970: 1)
    @objc dynamic var messageText = ""
    @objc dynamic var watched = false

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON) {
        self.init()
        
        id = json["id"].intValue
        idUserFrom = json["idUserFrom"].intValue
        for id in json["idAdjuntContents"].arrayValue{
            idAdjuntContents.append(id.intValue)
        }
        idUserTo = json["idUserTo"].intValue
        for id in json["idUserToList"].arrayValue{
            idUserToList.append(id.intValue)
        }
        metadataTipus = json["metadataTipus"].stringValue
        sendTime = Date(timeIntervalSince1970: TimeInterval(json["sendTime"].int64Value / 1000))
        messageText = json["text"].stringValue
        watched = json["watched"].boolValue


    }
    
    
    

}
