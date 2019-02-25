//
//  PasswordTextField.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class PasswordTextField: BaseTextField {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSecureTextEntry = true
        
        if self.text!.count < 8 || self.text!.count > 16{
            alertText = L10n.invalidPassword
        }
        if let partner = partnerTextField{
            if partner.text != self.text{
                alertText = L10n.differentPasswords
            }
        }
        
    }
    
    func reloadAlert(){
        if self.text!.count < 8 || self.text!.count > 16{
            alertText = L10n.invalidPassword
        }
        if let partner = partnerTextField{
            if partner.text != self.text{
                alertText = L10n.differentPasswords
            }
        }
        
    }
    
    
    override var isValid: Bool {
        get {
            if self.text!.count < 8 || self.text!.count > 16{
                alertText = L10n.invalidPassword
                return false
            }
            if let partner = partnerTextField{
                if partner.text != self.text{
                    alertText = L10n.differentPasswords
                    return false
                }
            }

            return true
        }
        set {}
    }

}
