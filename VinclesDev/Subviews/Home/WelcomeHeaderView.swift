//
//  WelcomeHeaderView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class WelcomeHeaderView: UIView {

    var xibView: UIView?
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerImage: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibView = Bundle.main.loadNibNamed("WelcomeHeaderView", owner: self, options: nil)!.first as? UIView
        
        xibView?.frame = self.bounds
        xibView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if UIDevice.current.userInterfaceIdiom == .phone {

        }
        self.addSubview(xibView!)
        headerImage.isUserInteractionEnabled = true

        headerLabel.text = ""
        headerImage.image = UIImage()
       
    }
    
    func configWithUser(){
        let profileModelManager = ProfileModelManager()
        if let user = profileModelManager.getUserMe(){
            headerLabel.text = "\(L10n.homeBienvenida) \(user.name)"
            if user.gender == "MALE"{
                headerLabel.text = "\(L10n.homeBienvenido) \(user.name)"

            }

            if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: user.id), let image = UIImage(contentsOfFile: url.path){
                headerImage.image = image
            }
       
        }
      
    }
    
    func configWithError(){
        headerImage.image = UIImage(named: "perfilplaceholder")

        
    }
    
    
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
    }
}
