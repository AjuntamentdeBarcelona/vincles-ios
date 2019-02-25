//
//  ContactesGridView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class ContactesGridView: UIView {

    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var noContactsView: UIView!
    @IBOutlet weak var noContactsLabel: UILabel!

    var xibView: RoundedView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibView = Bundle.main.loadNibNamed("ContactesGridView", owner: self, options: nil)!.first as? RoundedView
        xibView!.options = [.topRight, .topLeft, .bottomLeft, .bottomRight]
        
        xibView!.frame = self.bounds
        self.addSubview(xibView!)
        noContactsView.isHidden = true
        noContactsLabel.text = L10n.homeNoContacts
        contactsCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contactCell")

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
                xibView!.options = [ .topLeft, .topRight]
                xibView!.radius = 20.0
            }
            else{
                xibView!.options = [.topLeft]
                xibView!.radius = 20.0
            }
        }
        xibView?.layoutSubviews()

    }
    
    
}

