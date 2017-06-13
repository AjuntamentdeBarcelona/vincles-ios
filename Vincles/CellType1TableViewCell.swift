/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class CellType1TableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var hourLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setCellContent(feed:InitFeed) {
        
        let feedDate = feed.date!
        let currDate = Utils().getCurrentLocalDate()
        
        setContentImages(feed)
        setContentDates(feedDate, currDate: currDate)
        
        if feed.isRead! == 0 {
            self.backgroundColor = UIColor.whiteColor()
            self.fromLbl.textColor = UIColor(hexString: HEX_RED_BTN)
            self.mainTitle.textColor = UIColor.darkGrayColor()
            self.hourLbl.textColor = UIColor.lightGrayColor()
            self.dateLbl.textColor = UIColor.lightGrayColor()
        }else{
            self.backgroundColor = UIColor(hexString: HEX_CELL_MSG_READ)
            self.fromLbl.textColor = UIColor.whiteColor()
            self.mainTitle.textColor = UIColor.whiteColor()
        }
        hourLbl.font = UIFont(name: "Akkurat-Light", size: 14)
        dateLbl.font = UIFont(name: "Akkurat-Light", size: 14)
        fromLbl.font = UIFont(name: "Akkurat-Bold", size: 12)
        
        self.userPhoto.contentMode = .ScaleAspectFill
        self.userPhoto.layer.borderColor = UIColor.clearColor().CGColor
        self.userPhoto.layer.borderWidth = 0.0
        self.userPhoto.layer.cornerRadius = self.userPhoto.frame.size.height/2
        self.userPhoto.clipsToBounds = true
    }
    
    func setContentImages(feed:InitFeed)  {
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        
        switch feed.type! {
        case INIT_CELL_AUDIO_MSG:
            
            if let vincleConnected = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)  {
                if let _ = vincleConnected.photo {
                    
                    let imgData = Utils().imageFromBase64ToData(vincleConnected.photo!)

                    dispatch_async(dispatch_get_main_queue()) {
                        let vincImg = UIImage(data: imgData)
                        self.userPhoto.image = vincImg
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                        self.userPhoto.image = vincImg
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                    self.userPhoto.image = vincImg
                }
            }
            mainTitle.font = UIFont(name: "Akkurat", size: 22)
            mainTitle.text = langBundle.localizedStringForKey("INIT_CELL_AUDIO_MSG", value: nil, table: nil)
            
        case INIT_CELL_VIDEO_MSG:
            
            if let vincleConnected = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)  {
                if let _ = vincleConnected.photo {
                    let imgData = Utils().imageFromBase64ToData(vincleConnected.photo!)

                    dispatch_async(dispatch_get_main_queue()) {
                        let vincImg = UIImage(data: imgData)
                        self.userPhoto.image = vincImg
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                        self.userPhoto.image = vincImg
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                    self.userPhoto.image = vincImg
                }
            }
            mainTitle.font = UIFont(name: "Akkurat", size: 22)
            mainTitle.text = langBundle.localizedStringForKey("INIT_CELL_VIDEO_MSG", value: nil, table: nil)
            
        case INIT_CELL_IMAGE_MSG:
            
            if let vincleConnected = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)  {
                if let _ = vincleConnected.photo {
                    let imgData = Utils().imageFromBase64ToData(vincleConnected.photo!)

                    dispatch_async(dispatch_get_main_queue(), {
                        let vincImg = UIImage(data: imgData)
                        self.userPhoto.image = vincImg
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                        self.userPhoto.image = vincImg
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                    self.userPhoto.image = vincImg
                })
            }
            mainTitle.font = UIFont(name: "Akkurat", size: 22)
            mainTitle.text = langBundle.localizedStringForKey("INIT_CELL_IMAGE_MSG", value: nil, table: nil)
            
        case INIT_CELL_CONNECTED_TO:
            
            if let vincleConnected = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)  {
                if let _ = vincleConnected.photo {
                    let imgData = Utils().imageFromBase64ToData(vincleConnected.photo!)

                    dispatch_async(dispatch_get_main_queue(), {
                        let vincImg = UIImage(data: imgData)
                        self.userPhoto.image = vincImg
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                        self.userPhoto.image = vincImg
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                    self.userPhoto.image = vincImg
                })
            }
            mainTitle.font = UIFont(name: "Akkurat", size: 19)
            mainTitle.text = "\(langBundle.localizedStringForKey("INIT_CELL_CONNECTED", value: nil, table: nil)) \(feed.vincleName!) \(feed.vincleLastName!)"
            
        case INIT_CELL_DISCONNECTED_OF:
            
            dispatch_async(dispatch_get_main_queue(), {
                let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                self.userPhoto.image = vincImg
            })
            mainTitle.font = UIFont(name: "Akkurat", size: 18)
            mainTitle.text = "\(langBundle.localizedStringForKey("INIT_CELL_DISCONNECTED", value: nil, table: nil)) \(feed.vincleName!) \(feed.vincleLastName!)"
            
        case INIT_CELL_EVENT_SENT:
            
            if let vincleTo = UserVincle.loadUserVincleWithCalendarID(feed.idUsrVincles!) {
                if vincleTo.photo != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        let imgData = Utils().imageFromBase64ToData(vincleTo.photo!)
                        let vincImg = UIImage(data: imgData)
                        self.userPhoto.image = vincImg
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                        self.userPhoto.image = vincImg
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                    self.userPhoto.image = vincImg
                })
            }
            mainTitle.font = UIFont(name: "Akkurat", size: 22)
            mainTitle.text = langBundle.localizedStringForKey("INIT_CELL_EVENT_SENT", value: nil, table: nil)
            
        case INIT_CELL_LOST_CALL:
            
            if let vincleConnected = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)  {
                if let _ = vincleConnected.photo {
                    dispatch_async(dispatch_get_main_queue(), {
                        let imgData = Utils().imageFromBase64ToData(vincleConnected.photo!)
                        let vincImg = UIImage(data: imgData)
                        self.userPhoto.image = vincImg
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                        self.userPhoto.image = vincImg
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                    self.userPhoto.image = vincImg
                })
            }
            mainTitle.font = UIFont(name: "Akkurat", size: 22)
            mainTitle.text = langBundle.localizedStringForKey("INIT_CELL_LOST_CALL", value: nil, table: nil)
            
        case INIT_CELL_CALL_REALIZED:
            
            if let vincleConnected = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)  {
                if let _ = vincleConnected.photo {
                    dispatch_async(dispatch_get_main_queue(), {
                        let imgData = Utils().imageFromBase64ToData(vincleConnected.photo!)
                        let vincImg = UIImage(data: imgData)
                        self.userPhoto.image = vincImg
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                        self.userPhoto.image = vincImg
                    })
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    let vincImg = UIImage(named:DEFAULT_PROFILE_IMAGE)
                    self.userPhoto.image = vincImg
                })
            }
            mainTitle.font = UIFont(name: "Akkurat", size: 22)
            mainTitle.text = langBundle.localizedStringForKey("INIT_CELL_CALL", value: nil, table: nil)
        default:
            print("default")
        }
    }
    
    func setContentDates(feedDate:NSDate,currDate:NSDate) {
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        
        let fromStr = langBundle.localizedStringForKey("CELL_TIME_FROM_SINCE", value: nil, table: nil)
        let minutStr = langBundle.localizedStringForKey("CELL_TIME_FROM_MINUTE", value: nil, table: nil)
        let minutsStr = langBundle.localizedStringForKey("CELL_TIME_FROM_MINUTES", value: nil, table: nil)
        let hourStr = langBundle.localizedStringForKey("CELL_TIME_FROM_HOUR", value: nil, table: nil)
        let hoursStr = langBundle.localizedStringForKey("CELL_TIME_FROM_HOURS", value: nil, table: nil)
        let dayStr = langBundle.localizedStringForKey("CELL_TIME_FROM_DAY", value: nil, table: nil)
        let daysStr = langBundle.localizedStringForKey("CELL_TIME_FROM_DAYS", value: nil, table: nil)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        
        hourLbl.text = hourFormatter.stringFromDate(feedDate)
        dateLbl.text = dateFormatter.stringFromDate(feedDate)
        
        let elapsedTime = NSDate().timeIntervalSinceDate(feedDate)
        let days = Int(floor(elapsedTime/86400.0))
        let hour = Int(floor(elapsedTime/3600.0))
        let minuts = Int(floor(elapsedTime/60.0))
        
        if hour < 24 {
            if minuts >= 60 {
                if minuts < 120 {
                    fromLbl.text = "\(fromStr) \(hour) \(hourStr)"
                }else{
                    fromLbl.text = "\(fromStr) \(hour) \(hoursStr)"
                }
            }else{
                if minuts >= 1 {
                    if minuts == 1 {
                        fromLbl.text = "\(fromStr) \(minuts) \(minutStr)"
                    }else{
                        fromLbl.text = "\(fromStr) \(minuts) \(minutsStr)"
                    }
                }else{
                    fromLbl.text = "\(fromStr) < 1 \(minutStr)"
                }
            }
        }else{
            if days > 1 {
                fromLbl.text = "\(fromStr) \(days) \(daysStr)"
            }else{
                fromLbl.text = "\(fromStr) \(days) \(dayStr)"
            }
        }
    }
}
