//
//  ProfileManagerTest.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
@testable import VinclesDev
import SwiftyJSON

class ProfileManagerTest: ProfileModelManagerProtocol {
    
    var user: User?
    
    var userIsVincle: Bool{
        if let user = user{
            return user.idCircle != -1
        }
        return false
    }
    
    func getUserMe() -> User? {
        return user
    }
    
    func addOrUpdateUser(dict: [String : Any]) {
        let json = JSON(dict)
        user = User(json: json)
        
    }
    

}
