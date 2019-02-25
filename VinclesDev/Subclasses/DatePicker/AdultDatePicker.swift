//
//  AdultDatePicker.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class AdultDatePicker: UIDatePicker {

    var isValid: Bool {
        get {
            let dateOfBirth = self.date

            let gregorian = Calendar(identifier: .gregorian)
            let ageComponents = gregorian.dateComponents([.year], from: dateOfBirth, to: Date())
            let age = ageComponents.year!
            
            return age >= 14
        }
        set {}
    }
}
