//
//  String+Numeric.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

extension String {
    var keepNumericsOnly: String {
        return self.components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined(separator: "")
    }
}
