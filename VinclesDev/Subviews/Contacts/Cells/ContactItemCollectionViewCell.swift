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
        bringSubview(toFront: stack)
    }
    
    func configWithUser(user: User){
        isUser = true
        userImage.image = UIImage()
        actInd.startAnimating()

        userLabel.text = user.name
        let mediaManager = MediaManager()
        userImage.tag = user.id
        
        mediaManager.setProfilePicture(userId: user.id, imageView: userImage) {
            
        }
        
       
        
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
        isUser = false
        bubbleView.isHidden = true
        userContainer.backgroundColor = UIColor.clear
        userLabel.text = group.name
        userImage.image = UIImage()
        
        let mediaManager = MediaManager()
        userImage.tag = group.id
        
        mediaManager.setGroupPicture(groupId: group.id, imageView: userImage) {
            
        }
        
        // DONE WATCHED
        let number = chatModelManager.numberOfUnwatchedGroupMessages(idChat: group.idChat)
        bubbleView.isHidden = number == 0
        number == 0 ? (userContainer.backgroundColor = .clear) : (userContainer.backgroundColor = UIColor(named: .darkRed))
        bubbleLabel.text = "\(number)"
    }
}
