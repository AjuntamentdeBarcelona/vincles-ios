//
//  AuthResponse.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import SwiftyJSON
import RealmSwift

class AuthResponse: Object{
    @objc dynamic var refresh_token = ""
    @objc dynamic var access_token = ""
    @objc dynamic var expirationDate = Date(timeIntervalSince1970: 1)
    @objc dynamic var id = 0
    @objc dynamic var userId = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience required init(json: JSON) {
        self.init()
        refresh_token = json["refresh_token"].stringValue
        access_token = json["access_token"].stringValue
        if let expiration = Calendar.current.date(byAdding: .second, value: json["expires_in"].intValue, to: Date()){
            expirationDate = expiration
        }
       
    }
}
