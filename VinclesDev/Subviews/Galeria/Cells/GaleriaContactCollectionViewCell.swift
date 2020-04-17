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
    
    var userId = -1
    var groupId = -1

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
    
    func setAvatar(){
        if userId != -1{
            if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: userId), let image = UIImage(contentsOfFile: url.path){
                userImage.image = image
            }
            else{
                userImage.image = UIImage(named: "perfilplaceholder")
            }
        }
        else if groupId != -1{
            if let url = GroupImageManager.sharedInstance.getGroupPicture(groupId: groupId), let image = UIImage(contentsOfFile: url.path){
                userImage.image = image
            }
            else{
                userImage.image = UIImage(named: "perfilplaceholder")
            }
        }
    }
    
    func configWithUser(user: User, selected: Bool, editMode: Bool){
        userId = user.id
        groupId = -1
        
        if !editMode{
            checkBox.isHidden = true
        }
      
        actInd.startAnimating()

        checkBox.on = selected

        userLabel.text = user.name
        setAvatar()
     
    }
  
    func configWithGroup(group: Group, selected: Bool, editMode: Bool){
        groupId = group.id
        userId = -1
        if !editMode{
            checkBox.isHidden = true
        }
        actInd.startAnimating()
        
        checkBox.on = selected
        
        userLabel.text = group.name
        
        setAvatar()
        
        
    }
}

