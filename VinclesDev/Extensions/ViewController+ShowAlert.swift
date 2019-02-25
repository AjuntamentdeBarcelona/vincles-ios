//
//  ViewController+ShowAlert.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

extension UIViewController {
    func showAlert(withTitle title: String, message: String, button: String? = L10n.ok, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: button, style: .default) { (alert) in
            guard let completion = completion else {
                return
            }
            completion()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

