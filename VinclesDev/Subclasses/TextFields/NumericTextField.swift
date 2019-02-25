//
//  NumericTextField.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class NumericTextField: BaseTextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.keyboardType = .phonePad
        alertText = L10n.phoneNumeric
    }
    
    func reloadAlert(){
        alertText = L10n.phoneNumeric
    }
    
    
    override var isValid: Bool {
        get {
            guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: self.text!)) else {
                return false
            }
            
            return self.text!.count > 0
        }
        set {}
    }
}

