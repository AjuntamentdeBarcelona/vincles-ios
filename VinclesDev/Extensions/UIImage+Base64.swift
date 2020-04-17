//
//  UIImage+Base64.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

extension UIImage{
    func base64String() -> String {
        
        let imageData = self.pngData()!

        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
}
