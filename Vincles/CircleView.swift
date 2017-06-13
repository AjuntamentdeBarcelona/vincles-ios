/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class CircleView: UIView {

    var circleLayer: CAShapeLayer!
    
    override func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        if circleLayer == nil {
            circleLayer = CAShapeLayer()
            let radius: CGFloat = 150.0
            circleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).CGPath
            circleLayer.position = CGPoint(x: CGRectGetMidX(self.frame) - radius, y: CGRectGetMidY(self.frame) - radius)
            circleLayer.fillColor = UIColor.redColor().CGColor
            self.layer.addSublayer(circleLayer)
        }
    }
}
