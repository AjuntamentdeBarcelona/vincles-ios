/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class MissatgesFeedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var messTypeLogo: UIImageView!
    @IBOutlet weak var titleDateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var timeFrom: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setCellContent(mess:Missatges) {
        let msgDate = mess.sendTime!
        let currDate = NSDate()
        
        setContentImages(mess)
        setContentDates(msgDate, currDate: currDate)
        
        if mess.watched! == 0 {
            self.backgroundColor = UIColor.whiteColor()
            self.timeFrom.textColor = UIColor(hexString: HEX_RED_BTN)
            self.titleDateLabel.textColor = UIColor.darkGrayColor()
            self.hourLabel.textColor = UIColor.lightGrayColor()
        }else{
            self.backgroundColor = UIColor(hexString: HEX_CELL_MSG_READ)
            self.timeFrom.textColor = UIColor.whiteColor()
            self.titleDateLabel.textColor = UIColor.whiteColor()
            self.hourLabel.textColor = UIColor.whiteColor()
        }
    }
    
    func setContentImages(msg:Missatges) {
        
        switch msg.metadataTipus! {
        case MESSAGE_TYPE_AUDIO:
            print("AUDIO")
            if msg.watched! == 0 {
                messTypeLogo.image = UIImage(named: "icon-audio-red")
            }else{
                messTypeLogo.image = UIImage(named: "icon-audio-white")
            }
        case MESSAGE_TYPE_VIDEO:
            print("VIDEO")
            if msg.watched! == 0 {
                messTypeLogo.image = UIImage(named: "icon-video-red")
            }else{
                messTypeLogo.image = UIImage(named: "icon-video-white")
            }
        case MESSAGE_TYPE_IMAGE:
            if msg.watched! == 0 {
                messTypeLogo.image = UIImage(named: "icon-image-red")
            }else{
                messTypeLogo.image = UIImage(named: "icon-image-white")
            }
            
        default:
            print("DEFAULT = \(msg.metadataTipus!)")
        }
    }
    
    func setContentDates(msgDate:NSDate,currDate:NSDate) {
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        let fromStr = langBundle.localizedStringForKey("CELL_TIME_FROM_SINCE", value: nil, table: nil)
        let minutStr = langBundle.localizedStringForKey("CELL_TIME_FROM_MINUTE", value: nil, table: nil)
        let minutsStr = langBundle.localizedStringForKey("CELL_TIME_FROM_MINUTES", value: nil, table: nil)
        let hourStr = langBundle.localizedStringForKey("CELL_TIME_FROM_HOUR", value: nil, table: nil)
        let hoursStr = langBundle.localizedStringForKey("CELL_TIME_FROM_HOURS", value: nil, table: nil)
        let dayStr = langBundle.localizedStringForKey("CELL_TIME_FROM_DAY", value: nil, table: nil)
        let daysStr = langBundle.localizedStringForKey("CELL_TIME_FROM_DAYS", value: nil, table: nil)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        
        hourLabel.text = hourFormatter.stringFromDate(msgDate)
        
        let elapsedTime = NSDate().timeIntervalSinceDate(msgDate)
        let days = Int(floor(elapsedTime/86400.0))
        let hour = Int(floor(elapsedTime/3600.0))
        let minuts = Int(floor(elapsedTime/60.0))
        
        if hour < 24 {
                titleDateLabel.text = langBundle.localizedStringForKey("CELL_TITLE_DATE",
                                                                       value: nil, table: nil)
            if minuts >= 60 {
                if minuts < 120 {
                    timeFrom.text = "\(fromStr) \(hour) \(hourStr)"
                }else{
                    timeFrom.text = "\(fromStr) \(hour) \(hoursStr)"
                }
            }else{
                if minuts >= 1 {
                    if minuts == 1 {
                        timeFrom.text = "\(fromStr) \(minuts) \(minutStr)"
                    }else{
                        timeFrom.text = "\(fromStr) \(minuts) \(minutsStr)"
                    }
                }else{
                    timeFrom.text = "\(fromStr) < 1 \(minutStr)"
                }
            }
        }else{
            titleDateLabel.text = dateFormatter.stringFromDate(msgDate)
            if days > 1 {
                timeFrom.text = "\(fromStr) \(days) \(daysStr)"
            }else{
                timeFrom.text = "\(fromStr) \(days) \(dayStr)"
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
