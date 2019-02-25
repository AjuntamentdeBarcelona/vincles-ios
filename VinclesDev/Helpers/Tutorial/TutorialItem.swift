//
//  TutorialItem.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.




import Foundation
import UIKit

@objc open class TutorialItem: NSObject {
    
    let sourceView: UIView
    let paddingX: CGFloat
    let paddingY: CGFloat
    let radius: CGFloat
    let tutorialText: String
    let leftAlignment: Bool

    public init(sourceView: UIView, paddingX: CGFloat, paddingY: CGFloat, radius: CGFloat, tutorialText: String, leftAlignment: Bool) {
        self.sourceView = sourceView
        self.paddingX = paddingX
        self.paddingY = paddingY
        self.radius = radius
        self.tutorialText = tutorialText
        self.leftAlignment = leftAlignment
    }

}
