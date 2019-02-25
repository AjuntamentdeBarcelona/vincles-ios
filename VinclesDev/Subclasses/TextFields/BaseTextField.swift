//
//  BaseTextField.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol BaseTextFieldDelegate {
    func showAlert(alert: String)
}

class BaseTextField: UITextField {

    typealias Validation = () -> Bool
    var validationMethod: Bool!
    var baseTextFieldDelegate: BaseTextFieldDelegate?
    
    var isValid = false
    var alertText = ""
    var partnerTextField: PasswordTextField?

    override func awakeFromNib() {
        self.layer.cornerRadius = 6.0
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 5, height: 20))
        self.leftView = paddingView
        self.leftViewMode = .always

        let alertView = UIView.init(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        let alertButton = UIButton(frame: CGRect(x: 5, y: 0, width: 20, height: 20))
        alertButton.setImage(UIImage(named: "alert"), for: .normal)
        alertView.addSubview(alertButton)
        self.rightView = alertView
        self.rightViewMode = .always

        self.rightView?.isHidden = false
        
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        alertButton.addTarget(self, action: #selector(alertClicked(_:)), for: .touchUpInside)
    }
    
    // MARK: Targets
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValid()
        if let partner = partnerTextField{
            partner.checkValid()

        }
        /*
        if textField.text!.count > 0{
            checkValid()
        }
        else{
            self.rightView?.isHidden = true
        }
 */
    }
    
    @objc func alertClicked(_ button: UIButton) {
        baseTextFieldDelegate?.showAlert(alert: alertText)
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        checkValid()
        return true
    }
    
    func checkValid(){
        self.rightView?.isHidden = isValid

    }
    
}
