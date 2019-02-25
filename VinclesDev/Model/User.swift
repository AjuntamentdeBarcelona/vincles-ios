//
//  User.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class User: Object {
    @objc dynamic var idInstallation = 0
    @objc dynamic var name = ""
    @objc dynamic var email = ""
    @objc dynamic var lastname = ""
    @objc dynamic var gender = ""
    @objc dynamic var active = 0
    @objc dynamic var idLibrary = 0
    @objc dynamic var birthdate = Date(timeIntervalSince1970: 1)
    @objc dynamic var username = ""
    @objc dynamic var alias = ""
    @objc dynamic var idCircle = 0
    @objc dynamic var id = 0
    @objc dynamic var idCalendar = 0
    @objc dynamic var idContentPhoto = 0
    @objc dynamic var phone = ""
    @objc dynamic var liveInBarcelona = false
    @objc dynamic var relationship = ""
    let circles = List<User>()
    let contents = List<Content>()
    let groups = List<Group>()
    let dinamizadores = List<User>()
    let messages = List<Message>()
    let meetings = List<Meeting>()

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(json: JSON, relation: String = "") {
        self.init()
        idInstallation = json["idInstallation"].intValue
        name = json["name"].stringValue
        email = json["email"].stringValue
        lastname = json["lastname"].stringValue
        if json["gender"].type != .null{

            gender = json["gender"].stringValue
        }
        active = json["active"].intValue
        idLibrary = json["idLibrary"].intValue
        birthdate = Date(timeIntervalSince1970: TimeInterval(json["birthdate"].int64Value / 1000))
        username = json["username"].stringValue
        alias = json["alias"].stringValue
        idCircle = json["idCircle"].intValue
        id = json["id"].intValue
        idCalendar = json["idCalendar"].intValue
        idContentPhoto = json["idContentPhoto"].intValue
        phone = json["phone"].stringValue
        liveInBarcelona = json["liveInBarcelona"].boolValue
        relationship = relation
        print("preactive \(active)")

    }
}

