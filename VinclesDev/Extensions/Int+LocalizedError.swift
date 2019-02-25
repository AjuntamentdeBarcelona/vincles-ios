//
//  String+LocalizedError.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

extension Int{
    func localizedError() -> String{
        
        let language = UserDefaults.standard.string(forKey: "i18n_language")
        let path = Bundle.main.path(forResource: language! , ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString("Error\(self)", bundle: bundle, comment: "")
        
        return localizedString
    }
}
