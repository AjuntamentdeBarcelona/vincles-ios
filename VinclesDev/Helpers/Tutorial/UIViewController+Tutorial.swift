//
//  UIViewController+Tutorial.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

extension UIViewController: TutorialViewDelegate {

    public var tutorialView: TutorialView? {
        return attachToTutorial()
    }
    
    public var ongoingTutorial: Bool {
        return tutorialView != .none
    }
    
    public func maketutorialView() -> TutorialView {
        let v = TutorialView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
    
    public func startTutorial(_ tutorialView: TutorialView) {
        if ongoingTutorial {
            finishTutorial()
        }
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["tutorialView": tutorialView]
        
        window.addSubview(tutorialView)
        window.bringSubview(toFront: tutorialView)
        
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tutorialView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tutorialView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        window.setNeedsLayout()
    }
    
    public func attachToTutorial() -> TutorialView? {
        guard let window = UIApplication.shared.keyWindow else { return .none }
        
        for rootSubview in window.subviews {
            if let tutorial = rootSubview as? TutorialView {
                tutorial.delegate = self
                return tutorial
            }
        }
        
        return .none
    }
    
    public func finishTutorial() {
        tutorialView?.removeFromSuperview()
    }
    
}
