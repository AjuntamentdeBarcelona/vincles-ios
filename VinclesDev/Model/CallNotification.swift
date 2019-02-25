//
//  CallNotification.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

import RealmSwift
import SwiftyJSON

class CallNotification: Object {
    
    /*
     ▿ Optional<String>
     - some : "{\"idUser\":268,\"idRoom\":\"IOS-268-100-1528899512641\",\"push_notification_type\":\"INCOMING_CALL\",\"push_notification_time\":1528899517609}"
     */
    
    @objc dynamic var idUser = 0
    @objc dynamic var idRoom = ""
    @objc dynamic var push_notification_type = ""
    @objc dynamic var push_notification_time: Int64 = 0

    
    convenience required init(json: JSON) {
        self.init()
        
        idUser = json["idUser"].intValue
        idRoom = json["idRoom"].stringValue
        push_notification_type = json[push_notification_type].stringValue
        push_notification_time = json["push_notification_time"].int64Value
 
    }
    
    
    
}
