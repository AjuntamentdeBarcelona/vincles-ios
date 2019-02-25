//
//  ContactesView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class ContactesView: UIView {

    
    var xibView: RoundedView?
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibView = Bundle.main.loadNibNamed("ContactesView", owner: self, options: nil)!.first as? RoundedView
        xibView!.options = [.topRight, .topLeft, .bottomLeft, .bottomRight]
        let profileModelManager = ProfileModelManager()

        xibView!.frame = self.bounds
        if UIDevice.current.userInterfaceIdiom == .phone {
            albumLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 19.0)
            if profileModelManager.userIsVincle{
                albumLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            }
        }
        self.addSubview(xibView!)
        xibView!.options = [.bottomLeft]

        
        albumLabel.text = L10n.homeContactos
        if profileModelManager.userIsVincle{
            albumLabel.text = L10n.homeVinclesFamilia
        }
        else{
            stackView.spacing = 25.0
        }
    }
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if xibView != nil{
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact) {
                xibView!.options = [ .bottomLeft, .bottomRight]
                
                let profileModelManager = ProfileModelManager()
                if profileModelManager.userIsVincle{
                    xibView!.options = [ .bottomLeft]
                }
                xibView!.radius = 20.0
                albumLabel.textAlignment = .left
            }
            else{
                xibView!.options = [.bottomLeft]
                
                xibView!.radius = 20.0

                
                albumLabel.textAlignment = .center
            }
        }
        xibView?.layoutSubviews()
        
        
    }
}
