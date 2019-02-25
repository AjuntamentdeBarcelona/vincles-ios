//
//  RequiredTextField.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class RequiredTextField: BaseTextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        alertText = L10n.requiredField
    }
    
    func reloadAlert(){
        alertText = L10n.requiredField
    }
    
    override var isValid: Bool {
        get {
            return self.text!.count > 0
        }
        set {}
    }
}
