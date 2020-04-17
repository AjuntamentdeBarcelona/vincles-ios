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

    var userId = -1
    
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
        bringSubviewToFront(stack)
    }
    
    func setAvatar(){
        if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: userId), let image = UIImage(contentsOfFile: url.path){
            userImage.image = image
        }
        else{
            userImage.image = UIImage(named: "perfilplaceholder")
        }
    }
    
    func configWithUser(user: User, isDinam: Bool){
        userId = user.id
        userImage.image = UIImage()
        actInd.startAnimating()

        userLabel.text = user.name
       
        setAvatar()
        
        if isDinam{
            dinamitzadorButton.isHidden = false
            invitarButton.isHidden = true
        }
        else{
            dinamitzadorButton.isHidden = true
            let circlesGroupsModelManager = CirclesGroupsModelManager.shared
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
                    let defaults = UserDefaults.standard
                    
                    invitarButton.setTitle(L10n.grupEnviarInvitacio, for: .normal)
                    if let arrayInvited = defaults.array(forKey: "arrayInvited") as? [Int]{
                        if arrayInvited.contains(user.id){
                            invitarButton.setTitle(L10n.grupReenviarInvitacio, for: .normal)

                        }
                    }
                    invitarButton.isHidden = false
                }
            }
           
        }
    }
    
    
}
