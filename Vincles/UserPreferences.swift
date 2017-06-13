/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation


class UserPreferences {
    
    func createPrefDictsWithDefault() {
        
        let dictLang = ["CatCast":0]
        let dictNoti = ["notifications":0]
        let dictDescarrega = ["downloadAttach":0]
        let dictSyncCalendar = ["syncCalendar":0]
        let dictInstallation = ["firstInstallation":0]
        let dictLastNotiTime = ["lastNotification":0]
        
        let nsusr = NSUserDefaults.standardUserDefaults()
        nsusr.setValue(dictLang, forKey: "language")
        nsusr.setValue(dictNoti, forKey: "notif")
        nsusr.setValue(dictDescarrega, forKey: "download")
        nsusr.setValue(dictSyncCalendar, forKey: "calendar")
        nsusr.setBool(false, forKey: "calendarCreated")
        nsusr.setValue(dictInstallation, forKey: "install")
        nsusr.setValue(dictLastNotiTime, forKey: "lastNoti")
        
        nsusr.synchronize()
    }
    
    func saveAccessToken(token:String) {
        let nsusr = NSUserDefaults.standardUserDefaults()
        nsusr.setValue(token, forKey: "accessToken")
        
        nsusr.synchronize()
    }

    
    func savePushToken(token:String) {
        let nsusr = NSUserDefaults.standardUserDefaults()
        nsusr.setValue(token, forKey: "pushToken")
        
        nsusr.synchronize()
    }

    
    func bundleForLanguageSelected() -> NSBundle {
        var langu = ""
        if NSUserDefaults.standardUserDefaults().valueForKey("language") != nil {
            let nsusr = NSUserDefaults.standardUserDefaults()
            let lang = nsusr.valueForKey("language") as! [NSString:Int]
            
            if lang["CatCast"] == 0 {
                langu = "ca-ES"
            }else{
                langu = "es"
            }
        }else{
            langu = "es"
        }
        
        let path = NSBundle.mainBundle().pathForResource(langu, ofType: "lproj")
        let bundl = NSBundle(path: path!)
        
        return bundl!
    }
    
    func changeCalendarSyncPrefs(sync:Int) {
        
        var newDic = NSUserDefaults.standardUserDefaults().dictionaryForKey("calendar")
        newDic!["syncCalendar"] = sync
        NSUserDefaults.standardUserDefaults().setValue(newDic, forKey: "calendar")
        NSUserDefaults.standardUserDefaults().synchronize()

        
    }

}
