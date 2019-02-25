//
//  AlphaButton.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class AlphaButton: UIButton {

    override func awakeFromNib() {
        self.alpha = 0.5
    }
    
    override var isEnabled: Bool{
        didSet{
            isEnabled ? (self.alpha = 1) : (self.alpha = 0.5)
        }
    }
}
