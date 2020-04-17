//
//  EventGuestCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class EventGuestCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var userContainer: CircularView!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!

    var userId = -1
    var meetingId = -1
    
    override func awakeFromNib() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
            statusLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            stack.spacing = 5.0
            
        }
        
        
        if let tamanyLletra = UserDefaults.standard.value(forKey: "tamanyLletra") as? String{
            switch tamanyLletra{
            case "PETIT":
                userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)
                statusLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)

                if UIDevice.current.userInterfaceIdiom == .phone {
                    userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
                    statusLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 12.0)
                    
                }
                
                
            case "MITJA":
                
                userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 18.0)
                statusLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 18.0)
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
                    statusLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
                    
                }
                
                
                
            case "GRAN":
                
                userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 20.0)
                statusLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 20.0)
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    userLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)
                    statusLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)
                    
                }
                
                
            default:
                break
            }
        }
        
        
        userImage.image = UIImage()
        userContainer.backgroundColor = .clear
      
        
        statusLabel.text = "Estado"
        
        actInd.startAnimating()
        statusLabel.numberOfLines = 2
    }
    
    func setAvatar(){
        if let url = ProfileEventImageManager.sharedInstance.getProfilePicture(userId: userId, meetingId: meetingId), let image = UIImage(contentsOfFile: url.path){
            userImage.image = image
        }
        else{
            userImage.image = UIImage(named: "perfilplaceholder")
        }
    }
    
    func configWithGuest(guest: MeetingGuest, meetingId: Int){
       
        userImage.image = UIImage()
        actInd.startAnimating()
        
        if let userInfo = guest.userInfo{
            userLabel.text = userInfo.name
           
            
            self.meetingId = meetingId
            self.userId = userInfo.id
            
            setAvatar()
        }
        
            switch guest.state{
            case "PENDING":
                statusLabel.text = L10n.citaDescConvidat
            case "ACCEPTED":
                statusLabel.text = L10n.citaDescAssistira
            case "REJECTED":
                statusLabel.text = L10n.citaDescNoAssistira
            default:
                break
                
            }
        
     
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(stack)
    }
}
