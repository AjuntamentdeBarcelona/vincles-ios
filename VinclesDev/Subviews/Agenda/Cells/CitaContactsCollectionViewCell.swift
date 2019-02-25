//
//  CitaContactsCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class CitaContactsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var eliminarButton: UIButton!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var userContainer: CircularView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
            eliminarButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            stack.spacing = 5.0
            
        }
        userImage.image = UIImage()
        userContainer.backgroundColor = .clear
        eliminarButton.addTargetClosure { (sender) in
        }
        eliminarButton.setTitle(L10n.convidarCitaDeixar, for: .normal)

        actInd.startAnimating()
        eliminarButton.titleLabel?.numberOfLines = 2
    }
    
    func configWithUser(user: User){
        userImage.image = UIImage()
        actInd.startAnimating()
        
        userLabel.text = user.name
        let mediaManager = MediaManager()
        userImage.tag = user.id
        
        mediaManager.setProfilePicture(userId: user.id, imageView: userImage) {
            
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubview(toFront: stack)
    }
    
}
