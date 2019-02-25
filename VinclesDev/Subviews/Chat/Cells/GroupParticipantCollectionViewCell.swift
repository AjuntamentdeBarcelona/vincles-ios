//
//  ContactItemCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class GroupParticipantCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var userContainer: CircularView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    @IBOutlet weak var invitarButton: UIButton!
    @IBOutlet weak var dinamitzadorButton: UIButton!

    
    override func awakeFromNib() {
    
        if UIDevice.current.userInterfaceIdiom == .phone {
            userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
            stack.spacing = 5.0
            invitarButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            dinamitzadorButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            

        }
        userImage.image = UIImage()
       // userContainer.backgroundColor = UIColor(named: .darkRed)
        
        invitarButton.setTitle(L10n.grupEnviarInvitacio, for: .normal)
        dinamitzadorButton.setTitle(L10n.grupEnviarDinamitzador, for: .normal)
        actInd.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubview(toFront: stack)
    }
    
    func configWithUser(user: User, isDinam: Bool){
        userImage.image = UIImage()
        actInd.startAnimating()

        userLabel.text = user.name
        let mediaManager = MediaManager()
        userImage.tag = user.id
        
        mediaManager.setProfilePicture(userId: user.id, imageView: userImage) {
            
        }
        
        if isDinam{
            dinamitzadorButton.isHidden = false
            invitarButton.isHidden = true
        }
        else{
            dinamitzadorButton.isHidden = true
            let circlesGroupsModelManager = CirclesGroupsModelManager()
            let profileModelManager = ProfileModelManager()

            let me = profileModelManager.getUserMe()
            if user.id == me?.id{
                invitarButton.isHidden = true
                userLabel.text = L10n.chatTu

            }
            else{
                if circlesGroupsModelManager.contactWithId(id: user.id) != nil{
                    invitarButton.isHidden = true
                }
                else{
                    invitarButton.isHidden = false
                }
            }
           
        }
    }
    
    
}
