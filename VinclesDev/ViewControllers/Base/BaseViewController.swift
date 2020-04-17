//
//  ViewController+NavBarConfig.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class BaseViewController: UIViewController {
    
    var rightButtonTitle: String?{
        didSet{
            navigationBar.rightTitle = rightButtonTitle
        }
    }
    
    var leftButtonTitle: String?{
        didSet{
            navigationBar.leftTitle = leftButtonTitle
        }
    }
    
    var leftButtonImage: UIImage?{
        didSet{
            navigationBar.leftImage = leftButtonImage
        }
    }
    var rightButtonImage: UIImage?{
        didSet{
            navigationBar.rightImage = rightButtonImage
        }
    }
    
    var leftButtonHightlightedImage: UIImage?{
        didSet{
            navigationBar.leftHightlightedImage = leftButtonHightlightedImage
        }
    }
    var rightButtonHightlightedImage: UIImage?{
        didSet{
            navigationBar.rightHightlightedImage = rightButtonHightlightedImage
        }
    }
    
    var navTitle: String?{
        didSet{
            navigationBar.navTitle = navTitle
        }
    }

    
    var leftAction: ((_ params:Any...) -> Any?)?
    var rightAction: ((_ params:Any...) -> Any?)?

    var customCentralView: UIView?
    var customRightView: UIView?

    var containedViewController: UIViewController?
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var navigationBarHeight: NSLayoutConstraint!
    

    override func viewDidLoad() {
        checkNavigationBar()
        setupNavigationBar(barButtons: true)
        addContained()
      
        navigationBar.leftButton.addTargetClosure { (sender) in
            if let action = self.leftAction{
                _ = action()
            }
        }
        
        navigationBar.rightButton.addTargetClosure { (sender) in
            if let action = self.rightAction{
                _ = action()
            }
        }
        
        if customCentralView != nil{
            navigationBar.titleLabel.isHidden = true
            customCentralView?.center = navigationBar.center
            navigationBar.addSubview(customCentralView!)

            customCentralView?.translatesAutoresizingMaskIntoConstraints = false
            
            navigationBar.addConstraint(NSLayoutConstraint(item: customCentralView!, attribute: .height, relatedBy: .equal, toItem: navigationBar, attribute: .height, multiplier: 1, constant: 0))

            navigationBar.addConstraint(NSLayoutConstraint(item: customCentralView!, attribute: .centerX, relatedBy: .equal, toItem: navigationBar, attribute: .centerX, multiplier: 1, constant: 0))
            navigationBar.addConstraint(NSLayoutConstraint(item: customCentralView!, attribute: .centerY, relatedBy: .equal, toItem: navigationBar, attribute: .centerY, multiplier: 1, constant: 0))
            
            navigationBar.addConstraint(NSLayoutConstraint(item: customCentralView!, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: navigationBar.leftButton, attribute: .right, multiplier: 1, constant: 0))

         //   navigationBar.addConstraint(NSLayoutConstraint(item: customCentralView!, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: navigationBar.rightButton, attribute: .left, multiplier: 1, constant: 0))

        //   navigationBar.rightButton.backgroundColor = .green
        //    navigationBar.leftButton.backgroundColor = .green

        }

        if customRightView != nil{
            navigationBar.rightButton.isHidden = true
            navigationBar.addSubview(customRightView!)
            
            customRightView?.translatesAutoresizingMaskIntoConstraints = false
            
            navigationBar.addConstraint(NSLayoutConstraint(item: customRightView!, attribute: .height, relatedBy: .equal, toItem: navigationBar, attribute: .height, multiplier: 1, constant: 0))
            
            navigationBar.addConstraint(NSLayoutConstraint(item: customRightView!, attribute: .right, relatedBy: .equal, toItem: navigationBar, attribute: .right, multiplier: 1, constant: -30))
            navigationBar.addConstraint(NSLayoutConstraint(item: customRightView!, attribute: .centerY, relatedBy: .equal, toItem: navigationBar, attribute: .centerY, multiplier: 1, constant: 0))
            
            customRightView!.addConstraint(NSLayoutConstraint(item: customRightView!, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 190))
            
           
        }
        
        if customCentralView != nil && customRightView != nil{
            let constr = NSLayoutConstraint(item: customRightView!, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: customCentralView!, attribute: .right, multiplier: 1, constant: 0)
            constr.priority = UILayoutPriority(rawValue: 1000)
            navigationBar.addConstraint(constr)
            
        }
        
        
    }
    
    func checkNavigationBar(){
        if let nav = self.navigationController, nav.viewControllers.count > 1{
            navigationBar.isHidden = false
            if UIDevice.current.userInterfaceIdiom == .phone {
                navigationBarHeight.constant = 70.0
            }
        }
    }
    
    func addContained(){
        if let controller = containedViewController{
            addChild(controller)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(controller.view)
            
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
                controller.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                controller.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                controller.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
                ])
            
            controller.didMove(toParent: self)
        }
       
    }
    
    
    
}
