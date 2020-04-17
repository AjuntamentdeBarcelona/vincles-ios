//
//  ChatCallTableViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class ChatCallTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contView: UIView!
    @IBOutlet weak var userImage: CircularImageView!

    var userId = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contView.layer.borderColor = UIColor(named: .darkRed).cgColor
        contView.layer.borderWidth = 1.0
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configWithNotification(notification: VincleNotification){
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateStyle = .medium
        dateFormatterGet.timeStyle = .none
        dateFormatterGet.locale = Locale.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")

        dateFormatter.locale = Locale(identifier: lang!)
        
        if(lang == "es"){
            dateFormatterGet.locale = Locale(identifier: "es")
        }
        else{
            dateFormatterGet.locale = Locale(identifier: "ca")
        }
        
        userId = notification.idUser
        
        setAvatar()
        
        var gender = ""
        
        if let lang = UserDefaults.standard.string(forKey: "i18n_language"){
            if(lang == "ca"){
                let circlesModelManager = CirclesGroupsModelManager.shared
                if let user = circlesModelManager.contactWithId(id: notification.idUser){
                    if user.gender == "MALE"{
                        gender = "El"
                    }
                    else{
                        gender = "La"
                    }
                    
                    dateLabel.text = L10n.chatNotification(gender, user.name, dateFormatterGet.string(from: Date(timeIntervalSince1970: TimeInterval(notification.creationTimeInt / 1000))), dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(notification.creationTimeInt / 1000))))

                }
            }
            else if(lang == "es"){
                let circlesModelManager = CirclesGroupsModelManager.shared
                if let user = circlesModelManager.contactWithId(id: notification.idUser){
                    if user.gender == "MALE"{
                        gender = ""
                    }
                    else{
                        gender = ""
                    }
                    
                    dateLabel.text = L10n.chatNotification(gender, user.name, dateFormatterGet.string(from: Date(timeIntervalSince1970: TimeInterval(notification.creationTimeInt / 1000))), dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(notification.creationTimeInt / 1000))))
                    
                }
            }
            
        }
        
        
    }
    
    func setAvatar(){
        if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: userId), let image = UIImage(contentsOfFile: url.path){
            userImage.image = image
        }
        else{
            userImage.image = UIImage(named: "perfilplaceholder")
        }
    }
}
