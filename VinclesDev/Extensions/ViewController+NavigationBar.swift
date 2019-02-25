//
//  ViewController+NavigationBar.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

extension UIViewController {

    func setupNavigationBar(barButtons: Bool = false, tapLogoEnabled: Bool = true) {
        self.navigationItem.titleView = UIImageView(image: UIImage(asset: Asset.Logos.navBarLogo))
        self.navigationController?.navigationBar.barTintColor = UIColor(named: .darkRed)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        self.navigationItem.titleView?.isUserInteractionEnabled = true
        if tapLogoEnabled{
            self.navigationItem.titleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapLogo)))
        }

        if barButtons{
            
            let menuButton = UIButton()
            
            menuButton.frame = (UIDevice.current.userInterfaceIdiom == .pad) ? CGRect(x:0, y:0, width:160, height:30) : CGRect(x:0, y:0, width:30, height:30)
            
            (UIDevice.current.userInterfaceIdiom == .pad) ? menuButton.setTitle(L10n.menu, for: .normal) : menuButton.setTitle("", for: .normal)
            menuButton.setImage(UIImage(asset: Asset.Icons.menu), for: .normal)
            menuButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 23.0)
            menuButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
            
          
        }
    }
    
    @objc func tapLogo(){
        let mainViewController = StoryboardScene.Main.homeViewController.instantiate()

        if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
            if (nav.viewControllers.last as? HomeViewController) == nil{
                nav.setViewControllers([mainViewController], animated: true)
            }
        }
        
        
    }
    
    @objc func showMenu(){
        self.slideMenuController()?.openLeft()
    }


}
