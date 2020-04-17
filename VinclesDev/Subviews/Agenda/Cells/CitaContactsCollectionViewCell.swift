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
    
    var userId = -1
    
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
    
    func setAvatar(){
        if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: userId), let image = UIImage(contentsOfFile: url.path){
            userImage.image = image
            actInd.stopAnimating()
            actInd.isHidden = true
        }
        else{
            userImage.image = UIImage(named: "perfilplaceholder")
            actInd.stopAnimating()
            actInd.isHidden = true
        }
    }
    
    func configWithUser(user: User){
        userId = user.id
        
        userImage.image = UIImage()
        actInd.startAnimating()
        
        userLabel.text = user.name
       
        setAvatar()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(stack)
    }
    
}
