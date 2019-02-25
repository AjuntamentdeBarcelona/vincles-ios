//
//  GalleryDetailUserHeader.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class ChatDinamitzadorHeader: UIView {


    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userName: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    
    func initializeSubviews() {
        // below doesn't work as returned class name is normally in project module scope
        /*let viewName = NSStringFromClass(self.classForCoder)*/
        let viewName = "ChatDinamitzadorHeader"
        let view: UIView = Bundle.main.loadNibNamed(viewName,owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    
    }

    func configWithName(name: String){
        let bool = UIDevice.current.userInterfaceIdiom == .phone
        userName.text = bool ? "" : name
        
        userImage.image = UIImage()
    }
    
    func configWithUser(user: User){
        
        userName.text = user.name + " " + user.lastname
        
        if (UIDevice.current.userInterfaceIdiom == .phone){
            userName.text = ""
        }
        
        let mediaManager = MediaManager()
        userImage.tag = user.id
        mediaManager.setProfilePicture(userId: user.id, imageView: userImage) {
            
        }
        //   bubbleView.isHidden = user.notificationsNumber == 0
        //    user.notificationsNumber == 0 ? (userContainer.backgroundColor = .white) : (userContainer.backgroundColor = UIColor(named: .darkRed))
    }
    
    func configWithGroup(group: Group){
        userName.text = group.dynamizer?.name
        if (UIDevice.current.userInterfaceIdiom == .phone){
            userName.text = ""
        }
        
        let mediaManager = MediaManager()
        userImage.tag = (group.dynamizer?.id)!
        mediaManager.setProfilePicture(userId: (group.dynamizer?.id)!, imageView: userImage) {
            
        }
        //   bubbleView.isHidden = user.notificationsNumber == 0
        //    user.notificationsNumber == 0 ? (userContainer.backgroundColor = .white) : (userContainer.backgroundColor = UIColor(named: .darkRed))
    }
}
