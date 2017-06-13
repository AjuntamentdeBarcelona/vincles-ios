/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class CellType2TableViewCell: UITableViewCell {
    
    @IBOutlet weak var usrVincPhoto: UIImageView!
    @IBOutlet weak var timeLogo: UIImageView!
    @IBOutlet weak var eventStartHourLbl: UILabel!
    @IBOutlet weak var eventDescrLbl: UILabel!
    
    var usrVinclesExists = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setCellContent(feed:InitFeed) {
        
        let usrVincles = UserVincle.loadUserVincleWithCalendarID(feed.idUsrVincles!)
        
        if usrVincles != nil {
            usrVinclesExists = true
        }else{
            usrVinclesExists = false
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            if self.usrVinclesExists {
                let imgData = Utils().imageFromBase64ToData(usrVincles!.photo!)
                let vincImg = UIImage(data: imgData)
                self.usrVincPhoto.image = vincImg
            }else{
                let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                self.usrVincPhoto.image = vincImg
            }
            self.usrVincPhoto.contentMode = .ScaleAspectFill
            self.usrVincPhoto.layer.borderColor = UIColor.clearColor().CGColor
            self.usrVincPhoto.layer.borderWidth = 0.0
            self.usrVincPhoto.layer.cornerRadius = self.usrVincPhoto.frame.size.height/2
            self.usrVincPhoto.clipsToBounds = true
        })
        
        if feed.isRead! == 0 {
            self.backgroundColor = UIColor.whiteColor()
            self.eventDescrLbl.textColor = UIColor.darkGrayColor()
            self.eventStartHourLbl.textColor = UIColor.darkGrayColor()
            self.timeLogo.image = UIImage(named: "icon-time")
        }else{
            self.backgroundColor = UIColor(hexString: HEX_CELL_MSG_READ)
            self.eventDescrLbl.textColor = UIColor.whiteColor()
            self.eventStartHourLbl.textColor = UIColor.whiteColor()
            self.timeLogo.image = UIImage(named: "icon-time")
        }
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        eventStartHourLbl.font = UIFont(name: "Akkurat", size: 20)
        eventDescrLbl.font = UIFont(name: "Akkurat", size: 19)
        self.eventStartHourLbl.text = hourFormatter.stringFromDate(feed.objectDate!)
        self.eventDescrLbl.text = feed.textBody!
        
    }
    
}
