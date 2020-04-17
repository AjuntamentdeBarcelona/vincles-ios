//
//  ContactCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AlamofireImage

class ContactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userContainer: CircularView!
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var bubbleView: CircularView!
    @IBOutlet weak var bubbleLabel: UILabel!
    @IBOutlet weak var actInd: UIActivityIndicatorView!

    var loadingImage = false
    
    lazy var chatModelManager = ChatModelManager()
    lazy var notificationsModelManager = NotificationsModelManager()

    var userId = -1
    var groupId = -1

    override func awakeFromNib() {
        userContainer.backgroundColor = UIColor(named: .darkRed)
        bubbleView.backgroundColor = UIColor(named: .darkRed)
        if UIDevice.current.userInterfaceIdiom == .phone {
            userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 19.0)
            bubbleLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 14.0)
        }
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
    
    func configWithUser(user: User){
        userId = user.id
        groupId = -1
        actInd.startAnimating()

        userContainer.isHidden = false
        userContainer.backgroundColor = .clear
        userImage.image = UIImage()
        
        userLabel.text = user.name
        
        setAvatar()
        
//        let circlesManager = CirclesManager()

//        if circlesManager.userIsDinamitzador(id: user.id){
//            if let group = circlesManager.groupForDinamitzador(id: user.id){
//
//                let number = chatModelManager.numberOfUnwatchedGroupMessages(idChat: group.idDynamizerChat)
//
//                bubbleView.isHidden = number == 0
//                number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
//                bubbleLabel.text = "\(number)"
//
//            }
//        }
//        else{
//            let number = chatModelManager.numberOfUnwatchedMessages(circleId: user.id) + notificationsModelManager.numberOfUnwatchedMissedCall(circleId: user.id)
//
//            bubbleView.isHidden = number == 0
//            number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
//            bubbleLabel.text = "\(number)"
//        }
        
        let number = chatModelManager.numberOfUnwatchedMessages(circleId: user.id) + notificationsModelManager.numberOfUnwatchedMissedCall(circleId: user.id)
        
        bubbleView.isHidden = number == 0
        number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
        bubbleLabel.text = "\(number)"
    }
    
    func configWithGroup(group: Group){
        userId = -1
        groupId = group.id
        
        userContainer.isHidden = false
        userContainer.backgroundColor = .clear
        userLabel.text = group.name
        userImage.image = UIImage()
        
        setAvatar()
        
        // DONE WATCHED
        let number = chatModelManager.numberOfUnwatchedGroupMessages(idChat: group.idChat)
        bubbleView.isHidden = number == 0
        number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
        bubbleLabel.text = "\(number)"
    }
    
    func configEmpty(){
        
        userContainer.isHidden = true
        userImage.image = UIImage()
        userLabel.text = ""
        bubbleView.isHidden = true
        bubbleLabel.text = ""
    }
}
