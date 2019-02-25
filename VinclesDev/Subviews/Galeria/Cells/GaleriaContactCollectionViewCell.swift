//
//  GaleriaContactCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import BEMCheckBox

class GaleriaContactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userContainer: CircularView!
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var actInd: UIActivityIndicatorView!

    var loadingImage = false
    
    override func awakeFromNib() {
        userContainer.isHidden = false
        userContainer.backgroundColor = .white
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
        }
        userImage.backgroundColor = .clear
        checkBox.onAnimationType = .stroke
        userImage.image = UIImage()
        actInd.startAnimating()

    }
    
    func configWithUser(user: User, selected: Bool, editMode: Bool){
        if !editMode{
            checkBox.isHidden = true
        }
        actInd.startAnimating()

        checkBox.on = selected

        userLabel.text = user.name
        let mediaManager = MediaManager()
        userImage.tag = user.id

        mediaManager.setProfilePicture(userId: user.id, imageView: userImage) {
            
        }
       
     
    }
  
    func configWithGroup(group: Group, selected: Bool, editMode: Bool){
        if !editMode{
            checkBox.isHidden = true
        }
        actInd.startAnimating()
        
        checkBox.on = selected
        
        userLabel.text = group.name
        let mediaManager = MediaManager()
        userImage.tag = group.id
        
        mediaManager.setGroupPicture(groupId: group.id, imageView: userImage) {
            
        }
        
        
    }
}

