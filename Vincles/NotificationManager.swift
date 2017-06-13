/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import SwiftyJSON
import EventKit
import CoreData

class NotificationManager {
    class func loadLastProcessNotiEpoch() {
        
        let nsurDef = NSUserDefaults.standardUserDefaults()
        let dict = nsurDef.valueForKey("lastNoti") as! [NSString:Double]
        SingletonVars.sharedInstance.lastNotiProcess = dict["lastNotification"]! as Double
    }
    
    class func saveLastProcessNotiEpoch() {
        
        let nsuserD = NSUserDefaults.standardUserDefaults()
        var lastNoti = nsuserD.dictionaryForKey("lastNoti")
        lastNoti!["lastNotification"] = SingletonVars.sharedInstance.lastNotiProcess
        nsuserD.setValue(lastNoti, forKey:"lastNoti")
        nsuserD.synchronize()
    }
    
    class func checkNewNotifications(completion:((result:String) ->())) {

        if (SingletonVars.sharedInstance.lastNotiProcess == 0) {
            SingletonVars.sharedInstance.lastNotiProcess = NSDate().timeIntervalSince1970*1000
        }
        
        self.getNotifications(round(SingletonVars.sharedInstance.lastNotiProcess)+1, to:0,firstItera: true) { result,to in
            if result == "COMPLETED" {
                completion(result: "TASK END")
            }
        }
    }
    
    class func getNotifications(from:Double,to:Double,firstItera:Bool,completion:((result:String,to:Double) ->())) {
        
        let dateFrom = Utils().nsDateFromMilliSeconds(from)
        let dateTo = Utils().nsDateFromMilliSeconds(to)
        let lastNoti = Utils().nsDateFromMilliSeconds(SingletonVars.sharedInstance.lastNotiProcess)
        
        print("getNOTIS FROM = \(dateFrom) , TO = \(dateTo) , LAST NOTI = \(lastNoti)")
        
        var params:[String:AnyObject]!
        
        if firstItera {
            params = ["from":from]
            
        }else{
            params = ["from":from,
                      "to":to]
        }
        
        VinclesApiManager.sharedInstance.getAllNotificationFromApi(params) { (result, json) in
            if result == SUCCESS {
                if json!.count != 0 {
                    print("NOTIS ALGORITM \(json!)")
                    let lastNoti =  json![json!.count-1]["creationTime"].doubleValue
                    
                    for i in 0 ..< json!.count {
                        SingletonVars.sharedInstance.notisAry.insert(json![i], atIndex: 0)
                        print("NOTI ARRY IDX \(i)")
                    }
                    
                    getNotifications(round(SingletonVars.sharedInstance.lastNotiProcess)+1, to: round(lastNoti)-1, firstItera: false) { result,to in
                        if result == "COMPLETED" {
                            completion(result: result, to: to)
                        }
                    }
                }else{
                    print("EMPTY")
                    if let lastNot = SingletonVars.sharedInstance.notisAry.last?["creationTime"].doubleValue {
                        for noti in SingletonVars.sharedInstance.notisAry {
                            self.processNotification(noti)
                        }
                        SingletonVars.sharedInstance.lastNotiProcess = lastNot
                        self.saveLastProcessNotiEpoch()
                    }
                    SingletonVars.sharedInstance.notisAry = []
                    completion(result: "COMPLETED",to: 0.2)
                }
            }else{
                print("FAILURE")
            }
        }
    }
    
    
    class func processNotification(notiJson:JSON) {
        print("VALOR NOTI JSON \(notiJson)")
        let lastNoti = Utils().nsDateFromMilliSeconds(notiJson["creationTime"].doubleValue)
        print("NOTIFICATION PROCESSED TYPE == \(notiJson["type"].stringValue) ID \(notiJson["id"].stringValue) TIME = \(lastNoti)")
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        
        switch notiJson["type"].stringValue {
            
        case NOTI_NEW_MESSAGE:
            VinclesApiManager.sharedInstance.getMessage(notiJson["info"]["idMessage"].stringValue,completion: { (result, json) in
                
                if result == SUCCESS {
                    _ = Missatges.addNewMissatgeToEntity(json!)
                    _ = InitFeed.addNewInitFeedFromNotification(json, notiJSON: notiJson)
                    
                    let notification = UILocalNotification()
                    notification.alertAction = "Go back to App"
                    notification.alertBody = langBundle.localizedStringForKey("NOTI_TITLE_NEW_MESSAGE", value: nil, table: nil)
                    notification.fireDate = NSDate(timeIntervalSinceNow: 1)
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                    
                }else{
                }
            })
            
        case NOTI_NEW_EVENT:
            VinclesApiManager.sharedInstance.getEvent(notiJson["info"]["idCalendar"].stringValue, idEvent: notiJson["info"]["idEvent"].stringValue, completion: { (result, json) in
                
                if result == SUCCESS {
                    _ = Cita.addNewCitaToEntity(json)
                }else{
                }
            })
            
        case NOTI_EVENT_ACCEPTED:
            VinclesApiManager.sharedInstance.getEvent(notiJson["info"]["idCalendar"].stringValue, idEvent: notiJson["info"]["idEvent"].stringValue, completion: { (result, json) in
                
                if result == SUCCESS {
                    if let citaAccepted = Cita.getOptionalCitaWithID(notiJson["info"]["idEvent"].stringValue) {
                        citaAccepted.state = EVENT_STATE_ACCEPTED
                        Cita.saveCitesContext()
                        
                        // create initFeed
                        let params:[String:AnyObject] = [
                            "date":Utils().getCurrentLocalDate(),
                            "objectDate":citaAccepted.date!,
                            "id":notiJson["info"]["idEvent"].stringValue,
                            "idUsrVincles":notiJson["info"]["idCalendar"].stringValue,
                            "type":INIT_CELL_EVENT_ACCEPTED,
                            "textBody":json["description"].stringValue,
                            "isRead":false]
                        
                        InitFeed.addNewFeedEntityOffline(params)
                        
                        
                        if json["description"].stringValue != "" {
                            let notification = UILocalNotification()
                            notification.alertAction = "Go back to App"
                            notification.alertBody = langBundle.localizedStringForKey("NOTI_TITLE_EVENT_ACCEPTED", value: nil, table: nil)
                            notification.fireDate = NSDate(timeIntervalSinceNow: 1)
                            UIApplication.sharedApplication().scheduleLocalNotification(notification)
                            
                            // SAVE TO CALENDAR
                            let dict = NSUserDefaults.standardUserDefaults().valueForKey("calendar") as! [NSString:Int]
                            
                            if dict["syncCalendar"]! as Int == 0 { //sync calendar yes
                                if let usrVinc = UserVincle.loadUserVincleWithCalendarID(notiJson["info"]["idCalendar"].stringValue) {
                                    
                                    // get endDate
                                    let calendar = NSCalendar.currentCalendar()
                                    calendar.timeZone = NSTimeZone.localTimeZone()
                                    
                                    let toDate = calendar.dateByAddingUnit(.Minute, value: Int(citaAccepted.duration!)!, toDate:  citaAccepted.date!, options: [])
                                    
                                    let event = EventStore.create()
                                    event.title = "Vincles BCN: " + citaAccepted.descript!
                                    event.startDate = citaAccepted.date!
                                    event.endDate = toDate!
                                    event.notes = "\(usrVinc.name!) \(usrVinc.lastname!) (Vincles BCN)"
                                    
                                    EventStore.addEvent(event)
                                }
                            }
                        }
                    }
                }else{
                }
            })
            
        case NOTI_EVENT_REJECTED:
            
            VinclesApiManager.sharedInstance.getEvent(notiJson["info"]["idCalendar"].stringValue, idEvent: notiJson["info"]["idEvent"].stringValue, completion: { (result, json) in
                
                if result == SUCCESS {
                    if let citaRejected = Cita.getOptionalCitaWithID(notiJson["info"]["idEvent"].stringValue) {
                        citaRejected.state = EVENT_STATE_REJECTED
                        Cita.saveCitesContext()
                        
                        // crear initFeed
                        let params:[String:AnyObject] = [
                            "date":Utils().getCurrentLocalDate(),
                            "objectDate":citaRejected.date!,
                            "id":notiJson["info"]["idEvent"].stringValue,
                            "idUsrVincles":notiJson["info"]["idCalendar"].stringValue,
                            "type":INIT_CELL_EVENT_REJECTED,
                            "textBody":json["description"].stringValue,
                            "isRead":false]
                        
                        InitFeed.addNewFeedEntityOffline(params)
                        
                        if json["description"].stringValue != "" {
                            let notification = UILocalNotification()
                            notification.alertAction = "Go back to App"
                            notification.alertBody = langBundle.localizedStringForKey("NOTI_TITLE_EVENT_REJECTED", value: nil, table: nil)
                            notification.fireDate = NSDate(timeIntervalSinceNow: 1)
                            UIApplication.sharedApplication().scheduleLocalNotification(notification)
                        }
                    }
                }else{
                }
            })
            
        case NOTI_EVENT_UPDATED:
            
            VinclesApiManager.sharedInstance.getEvent(notiJson["info"]["idCalendar"].stringValue, idEvent: notiJson["info"]["idEvent"].stringValue, completion: { (result, json) in
                
                if result == SUCCESS {
                    if let citaUpdated = Cita.getOptionalCitaWithID(notiJson["info"]["idEvent"].stringValue) {
                        let dateDouble = Double(json["date"].stringValue)
                        citaUpdated.date = Utils().nsDateFromMilliSeconds(dateDouble!)
                        citaUpdated.duration = json["duration"].stringValue
                        Cita.saveCitesContext()
                    }
                }else{
                }
            })
            
        case NOTI_EVENT_DELETED:
            
            if let citaDel = Cita.getOptionalCitaWithID(notiJson["info"]["idEvent"].stringValue) {
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                managedContext.deleteObject(citaDel)
                
                Cita.saveCitesContext()
            }
            
        case NOTI_USER_UPDATED:
            
            let usrVincles = UserVincle.loadUserVincleWithID(notiJson["info"]["idUser"].stringValue)!
            VinclesApiManager.sharedInstance.getUserFullInfo(usrVincles.id!) { (result, info) in
                
                if result == SUCCESS {
                    
                    if usrVincles.idContentPhoto! != info["idContentPhoto"].stringValue {
                        // Photo has changed
                        VinclesApiManager.sharedInstance.getUserProfilePhoto(usrVincles.id!) { (result, binaryURL) in
                            
                            if result == SUCCESS {
                                let data = NSData(contentsOfURL: binaryURL!)
                                let bse64 = Utils().imageFromImgtoBase64(data!)
                                usrVincles.photo! = bse64
                                UserVincle.saveUserVincleContext()
                            }else{
                            }
                        }
                    }
                    UserVincle.updateUserVincles(usrVincles, params: info)
                }else{
                }
            }
            
        case NOTI_USER_UNLINKED:
            
            let vincleID = notiJson["info"]["idUser"].stringValue
            
            print("vincleID = \(vincleID)")
            
            let usrVincles = UserVincle.loadUserVincleWithID(vincleID)!
            
            
            let vincleName = "\(usrVincles.name!) \(usrVincles.lastname!)"
            
            // create initFeed
            let params:[String:AnyObject] = ["date":Utils().getCurrentLocalDate(),
                                             "type":INIT_CELL_DISCONNECTED_OF,
                                             "vincleName":usrVincles.alias!,
                                             "vincleLastName":"",
                                             "isRead":false]
            InitFeed.addNewFeedEntityOffline(params)
            
            Missatges.deleteAllMessagesFromUser(usrVincles.id!)
            Cita.deleteAllCitesFromUser(usrVincles.idCalendar!)
            
            // DELETE ALL CITAS FROM CALENDAR
            let startDate = NSDate()
            let endDate = NSDate()
            let events = EventStore.getEvents(startDate, endDate: endDate.addDays(90))
            for event in events {
                if (event.notes?.containsString(vincleName)) == true {
                    EventStore.removeEvent(event)
                }
            }
            
            let notification = UILocalNotification()
            notification.alertAction = "Go back to App"
            notification.alertBody = langBundle.localizedStringForKey("NOTI_TITLE_USER_UNLINKED", value: nil, table: nil)
            notification.fireDate = NSDate(timeIntervalSinceNow: 1)
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.deleteObject(usrVincles)
            
            UserVincle.saveUserVincleContext()
            
            let usrCercle = UserCercle.loadUserCercleCoreData()
            
            if usrCercle?.vincleSelected! == vincleID {
                
                let isEmpty = UserVincle.entityUserVinclesEmpty()
                
                if isEmpty == true {
                    // LAST VINCLES USER REMOVED
                    usrCercle!.vincleSelected = nil
                    UserCercle.saveUserCercleEntity(usrCercle!)
                } else {
                    let langBundle = UserPreferences().bundleForLanguageSelected()
                    
                    let newVincSelected = UserVincle.loadUserVinclesAtIndex(0)
                    usrCercle!.vincleSelected! = newVincSelected.id!
                    UserCercle.saveUserCercleEntity(usrCercle!)
                }
                
                appDelegate.showAlertAppDelegate(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil),message: "\(vincleName) \(langBundle.localizedStringForKey("ALERTA_USER_HAS_UNLINKED_YOU", value: nil, table: nil))",buttonTitle: UserPreferences().bundleForLanguageSelected().localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil),window: appDelegate.window!)
            }
            
        default:
            print("DEFAULT")
        }
    }
    
    
}
