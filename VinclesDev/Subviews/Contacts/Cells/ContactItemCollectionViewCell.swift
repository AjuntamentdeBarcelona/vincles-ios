//
//  ContactItemCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class ContactItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var eliminarButton: UIButton!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var bubbleView: CircularView!
    @IBOutlet weak var bubbleLabel: UILabel!
    @IBOutlet weak var userContainer: CircularView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    lazy var notificationsModelManager = NotificationsModelManager()

    lazy var chatModelManager = ChatModelManager()
    var isUser = false
    
    var userId = -1
    var groupId = -1

    override func awakeFromNib() {
    
        if UIDevice.current.userInterfaceIdiom == .phone {
            userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
            eliminarButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            stack.spacing = 5.0
            bubbleLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 14.0)

        }
        userImage.image = UIImage()
        userContainer.backgroundColor = UIColor.clear
        bubbleView.backgroundColor = UIColor(named: .darkRed)
        eliminarButton.addTargetClosure { (sender) in
        }
        
        actInd.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(stack)
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
    
    func configWithUser(user: User){
        userId = user.id
        groupId = -1
        isUser = true
        userImage.image = UIImage()
        actInd.startAnimating()

        userLabel.text = user.name
       
        setAvatar()
       
        
        let circlesManager = CirclesManager()
        
        if circlesManager.userIsDinamitzador(id: user.id){
            if let group = circlesManager.groupForDinamitzador(id: user.id){
                
                let number = chatModelManager.numberOfUnwatchedGroupMessages(idChat: group.idDynamizerChat)
                
                bubbleView.isHidden = number == 0
                number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
                bubbleLabel.text = "\(number)"
                
            }
        }
        else{
            let number = chatModelManager.numberOfUnwatchedMessages(circleId: user.id) + notificationsModelManager.numberOfUnwatchedMissedCall(circleId: user.id)
            
            bubbleView.isHidden = number == 0
            number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
            bubbleLabel.text = "\(number)"
        }
    }
    
    func configWithGroup(group: Group){
        userId = -1
        groupId = group.id
        
        isUser = false
        bubbleView.isHidden = true
        userContainer.backgroundColor = UIColor.clear
        userLabel.text = group.name
        userImage.image = UIImage()
        
        setAvatar()
        
        // DONE WATCHED
        let number = chatModelManager.numberOfUnwatchedGroupMessages(idChat: group.idChat)
        bubbleView.isHidden = number == 0
        number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
        bubbleLabel.text = "\(number)"
    }
}
