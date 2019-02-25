//
//  AlbumView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit


class AlbumView: UIView {

    var xibView: RoundedView?
    @IBOutlet weak var albumLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibView = Bundle.main.loadNibNamed("AlbumView", owner: self, options: nil)!.first as? RoundedView
        xibView!.options = [.topRight, .topLeft, .bottomLeft, .bottomRight]
       
        xibView!.frame = self.bounds
        if UIDevice.current.userInterfaceIdiom == .phone {
            albumLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 19.0)
        }
        self.addSubview(xibView!)
        
        albumLabel.text = L10n.homeFotos
       
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
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact && self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClass.compact) {
                xibView!.radius = 20.0
                albumLabel.textAlignment = .left
            }
            else{
                xibView!.radius = 0.0
                albumLabel.textAlignment = .center
            }
        }
        xibView?.layoutSubviews()

  
    }
    
}
