//
//  AuthModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class AuthModelManager: AuthModelManagerProtocol {
    var hasUser: Bool{
        let realm = try! Realm()
        
        if realm.objects(AuthResponse.self).first != nil{
            return true
        }
        
        return false
    }
    
    func saveAuthResponse(dict: [String:Any]){
        let json = JSON(dict)
        let authResponse = AuthResponse(json: json)
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(authResponse, update: true)
        }
    }
    
    func getAuthResponse() -> AuthResponse?{
        let realm = try! Realm()
        
        if let authResponse = realm.objects(AuthResponse.self).filter("id == 0").first {
            return authResponse
        }
        return nil
    }
    
    func updateAuthResponse(accessToken: String, refreshToken: String, expiresIn: Int){
        let realm = try! Realm()
        
        if let authResponse = realm.objects(AuthResponse.self).filter("id == 0").first {
            
            try! realm.write {
                authResponse.access_token = accessToken
                authResponse.refresh_token = refreshToken
                authResponse.expirationDate = Calendar.current.date(byAdding: .second, value: expiresIn, to: Date())!
            }
            
        }
    }
    
    func getAccessToken() -> String?{

        let realm = try! Realm()

            if let authResponse = realm.objects(AuthResponse.self).filter("id == 0").first {
                if !authResponse.isInvalidated{

                    return authResponse.access_token

                }
            }
        

        return nil
    }
    
    func getRefreshToken() -> String?{
        let realm = try! Realm()
        
        if let authResponse = realm.objects(AuthResponse.self).filter("id == 0").first {
            return authResponse.refresh_token
        }
        return nil
    }
}
