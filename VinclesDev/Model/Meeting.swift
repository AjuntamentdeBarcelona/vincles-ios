//
//  Meeting.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class Meeting: Object {

    
    @objc dynamic var id = -1
    @objc dynamic var date: Int64 = -1
    @objc dynamic var duration = -1
    @objc dynamic var descrip = ""
    @objc dynamic var hostInfo: User?
    let guests = List<MeetingGuest>()
    @objc dynamic var day = -1
    @objc dynamic var month = -1
    @objc dynamic var year = -1

    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON) {
        self.init()
        
        id = json["id"].intValue
        date = json["date"].int64Value
        duration = json["duration"].intValue
      //  hostId = json["hostId"].intValue
        descrip = json["description"].stringValue
        let jsonHost = json["hostInfo"]

        let initDate = Date(timeIntervalSince1970: TimeInterval(date / 1000))
        let calendar = Calendar.current
       
        day = calendar.component(.day, from: initDate)
        month = calendar.component(.month, from: initDate)
        year = calendar.component(.year, from: initDate)

        let realm = try! Realm()
        try! realm.write {
            let user = realm.create(User.self, value: ["name": jsonHost["name"].stringValue, "lastname": jsonHost["lastname"].stringValue, "id": jsonHost["userId"].intValue, "idContentPhoto": jsonHost["idContentPhoto"].intValue], update: true)
            print(user.name)
            hostInfo = user
        }
        
        for jsonGuest in json["guests"].arrayValue{
            let guest = MeetingGuest(json: jsonGuest)
            guests.append(guest)
        }
        
    }
}
