//
//  KeychainManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import KeychainAccess

class KeychainManager: NSObject {
    
    let keyChainId = Bundle.main.bundleIdentifier!

    func saveCredentials(email: String, password: String){
        let keychain = Keychain(service:keyChainId )
        keychain["email"] = email
        keychain["password"] = password
    }
    
    func removeCredentials(){
        let keychain = Keychain(service:keyChainId )
        keychain["email"] = nil
        keychain["password"] = nil
    }
    
    func getCredentials() -> (String?, String?){
        let keychain = Keychain(service:keyChainId )
        return (keychain["email"], keychain["password"])
    }
}
