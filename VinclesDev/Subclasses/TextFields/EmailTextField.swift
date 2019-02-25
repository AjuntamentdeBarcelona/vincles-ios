//
//  EmailTextField.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class EmailTextField: BaseTextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.keyboardType = .emailAddress
        alertText = L10n.invalidEmail
    }
    
    func reloadAlert(){
        alertText = L10n.invalidEmail
    }
    
    override var isValid: Bool {
        get {
            return self.text!.isValidEmail()
        }
        set {}
    }

}
