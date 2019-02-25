//
//  RoundedView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class RoundedView: UIView {

    var radius: CGFloat = 0.0
    var options: UIRectCorner? {
        didSet {
            if let options = options{
                let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners:options, cornerRadii: CGSize.init(width: radius, height: radius))
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.bounds
                maskLayer.path = maskPath.cgPath
                self.layer.mask = maskLayer
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
           
        if let options = options{
            let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners:options, cornerRadii: CGSize.init(width: radius, height: radius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = maskPath.cgPath
            self.layer.mask = maskLayer
        }

    }
    
    

}
