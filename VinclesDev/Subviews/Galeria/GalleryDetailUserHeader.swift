//
//  GalleryDetailUserHeader.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class GalleryDetailUserHeader: UIView {


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
        let viewName = "GalleryDetailUserHeader"
        let view: UIView = Bundle.main.loadNibNamed(viewName,owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        
        userName.numberOfLines = 3
        
        if UIDevice.current.userInterfaceIdiom == .phone{
          //  userImage.isHidden = true
        }
    }

    func configWithName(name: String){
        userName.text = name
        userImage.image = UIImage()
    }
    
    func configWithUser(user: User){
        
        userName.text = user.name + " " + user.lastname

        if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: user.id), let image = UIImage(contentsOfFile: url.path){
            userImage.image = image
        }
        else{
            userImage.image = UIImage(named: "perfilplaceholder")
        }
        
      
        //   bubbleView.isHidden = user.notificationsNumber == 0
        //    user.notificationsNumber == 0 ? (userContainer.backgroundColor = .white) : (userContainer.backgroundColor = UIColor(named: .darkRed))
    }
    
    func configWithGroup(group: Group){

        userName.text = group.name
        print(group.id)
        if let url = GroupImageManager.sharedInstance.getGroupPicture(groupId: group.id), let image = UIImage(contentsOfFile: url.path){
            userImage.image = image
        }
        else{
            userImage.image = UIImage(named: "perfilplaceholder")
        }
        
    }
}
