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

    var userId = -1
    
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
    
   
    func configWithGroup(group: Group){
        if let user = group.dynamizer?.id{
            userId = user
        }
        
        if userId == -1{
            return
        }
        
        userName.text = group.dynamizer?.name
        if (UIDevice.current.userInterfaceIdiom == .phone){
            userName.text = ""
        }
        
        setAvatar()

        //   bubbleView.isHidden = user.notificationsNumber == 0
        //    user.notificationsNumber == 0 ? (userContainer.backgroundColor = .white) : (userContainer.backgroundColor = UIColor(named: .darkRed))
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
