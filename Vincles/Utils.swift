/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CryptoSwift

class Utils {
    let iv: [UInt8] = [0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01]
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(testStr)
    }
    
    func imageFromBase64ToData(base64:String) -> NSData {
        
        return NSData(base64EncodedString:base64, options:.IgnoreUnknownCharacters)!
    }
    
    func imageFromImgtoBase64(img:NSData) -> String {

        let base64 = img.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return base64
    }
    
    func retrieveUserVinclesProfilePhoto(usr:UserVincle,completion:((result:String,imgB64:String) -> ())) {
        if (usr.id == nil) {
            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            let photoData = UIImageJPEGRepresentation(xarxaImg!, 0.1)
            let bse64 = Utils().imageFromImgtoBase64(photoData!)
            completion(result: FAILURE, imgB64: bse64)
            return
        }
        
        VinclesApiManager.sharedInstance.getUserProfilePhoto(usr.id!) { (result, binaryURL) in
            
            if result == SUCCESS {
                let data = NSData(contentsOfURL: binaryURL!)
                let bse64 = Utils().imageFromImgtoBase64(data!)
                usr.photo = bse64
                UserVincle.saveUserVincleContext()
                completion(result: SUCCESS, imgB64: bse64)
            }else{
                let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
                let photoData = UIImageJPEGRepresentation(xarxaImg!, 0.1)
                let bse64 = Utils().imageFromImgtoBase64(photoData!)
                completion(result: FAILURE, imgB64: bse64)
            }
        }
    }
    
    func milliSecondsSince1970(nsDate: NSDate) -> Int64 {
        
        return Int64(nsDate.timeIntervalSince1970*1000)
    }
    
    func nsDateFromMilliSeconds(timeStamp:Double) -> NSDate {
        return NSDate(timeIntervalSince1970: timeStamp/1000)
    }
    
    func combineDateWithTime(date: NSDate, time: NSDate) -> NSDate? {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        let dateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        let timeComponents = calendar.components([.Hour, .Minute], fromDate: time)
        
        let mergedComponments = NSDateComponents()
        mergedComponments.year = dateComponents.year
        mergedComponments.month = dateComponents.month
        mergedComponments.day = dateComponents.day
        mergedComponments.hour = timeComponents.hour
        mergedComponments.minute = timeComponents.minute
        
        return calendar.dateFromComponents(mergedComponments)
    }
    
    func getCurrentLocalDate()-> NSDate {
        var now = NSDate()
        let nowComponents = NSDateComponents()
        let calendar = NSCalendar.currentCalendar()
        nowComponents.year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: now)
        nowComponents.month = NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: now)
        nowComponents.day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: now)
        nowComponents.hour = NSCalendar.currentCalendar().component(NSCalendarUnit.Hour, fromDate: now)
        nowComponents.minute = NSCalendar.currentCalendar().component(NSCalendarUnit.Minute, fromDate: now)
        nowComponents.second = NSCalendar.currentCalendar().component(NSCalendarUnit.Second, fromDate: now)
        nowComponents.timeZone = NSTimeZone.localTimeZone()
        now = calendar.dateFromComponents(nowComponents)!
        
        return now
    }
    
    func getTodayMillisecondsInterval() -> [Double] {
        
        var fromTo:[Double] = []
        let now = NSDate()
        let from = self.milliSecondsSince1970(now)
        let hoursLeft = hoursLeftUntilEndDay()
        let to = self.milliSecondsSince1970(now.addHours(hoursLeft))
        
        fromTo.append(Double(from))
        fromTo.append(Double(to))
        
        return fromTo
    }
    
    func getStartOfDay(date:NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        
        return calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions.MatchFirst)!
    }
    
    func getEndOfDay(date:NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        
        return calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: date, options: NSCalendarOptions.MatchFirst)!
    }
    
    func get24hoursTimeInterval(date:NSDate) -> [NSDate] {
        var dates:[NSDate] = []
        let currDate = Utils().getCurrentLocalDate()
        let components = self.getCalendarComponentsFromDate(date)
        
        let startDay = currDate.addHours(-components.hour)
        let endDay = currDate.addHours(self.hoursLeftUntilEndDay())
        
        dates.append(startDay)
        dates.append(endDay)
        
        return dates
    }
    
    func getDayMillisecondsInterval(day:NSDate) -> [Int64] {
        var dayEpochInterval:[Int64] = []
        
        let from = milliSecondsSince1970(day)
        let to = milliSecondsSince1970(day.addHours(hoursLeftUntilEndDay()))
        
        dayEpochInterval.append(from)
        dayEpochInterval.append(to)
        
        return dayEpochInterval
    }
    
    func getTodayTimeInterval() -> [NSDate] {
        
        var fromTo:[NSDate] = []
        let fromDate = NSDate()
        let hoursLeft = hoursLeftUntilEndDay()
        let toDate = fromDate.addHours(hoursLeft)
        
        fromTo.append(fromDate)
        fromTo.append(toDate)
        
        return fromTo
    }
    
    func getTomorrowTimeInterval() -> [NSDate] {
        
        var fromTo:[NSDate] = []
        let tempDateDate = NSDate()
        let hoursLeft = hoursLeftUntilEndDay()
        let fromDate = tempDateDate.addHours(hoursLeft)
        let toDate = fromDate.addHours(24)
        
        fromTo.append(fromDate)
        fromTo.append(toDate)
        
        return fromTo
    }
    
    func hoursLeftUntilEndDay() -> Int {
        
        let calendar = NSCalendar.currentCalendar()
        let timeComponents = calendar.components([.Hour, .Minute], fromDate: NSDate())
        
        let hoursLeft = 24 - timeComponents.hour
        
        return hoursLeft
    }
    
    func getCalendarComponentsFromDate(date:NSDate) -> NSDateComponents {
        
        let currCalendar = NSCalendar.currentCalendar()
        let components = currCalendar.components([.Day , .Month , .Year], fromDate: date)
        
        return components
    }
    
    func getTimeCalendarComponentsFromDate(date:NSDate) -> NSDateComponents {
        
        let currCalendar = NSCalendar.currentCalendar()
        let components = currCalendar.components([.Hour , .Minute], fromDate: date)
        
        return components
    }
    
    func calendarDatesAreTheSame(dateSelected:NSDate,eventDate:NSDate) -> Bool {
        let selectDateComponents = getCalendarComponentsFromDate(dateSelected)
        let eventDateComponents = getCalendarComponentsFromDate(eventDate)
        
        if selectDateComponents.year == eventDateComponents.year &&
            selectDateComponents.month == eventDateComponents.month &&
            selectDateComponents.day == eventDateComponents.day {
            
            return true
        }else{
            return false
        }
    }
    
    func postAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        return alert
    }
    
    func postAlertWithCompletion(title: String, message: String, pHandler: ((UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: pHandler))
        
        return alert
    }
    
    // CALENDAR EVENTS
    func deleteEventInCalendar(cit:Cita) {
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        
        let toDate = calendar.dateByAddingUnit(.Minute, value: Int(cit.duration!)!, toDate:  cit.date!, options: [])
        
        let calEvent = EventStore.getEvents(cit.date!, endDate: toDate!)
        
        if calEvent.count > 0 {
            for evnt in calEvent {
                if evnt.title == cit.descript! {
                    EventStore.removeEvent(evnt)
                }
            }
        }
    }
    
    func createRoomName(caller: String, callee: String)->String
    {
        if(SingletonVars.sharedInstance.idRoomCall == "")
        {
            let miliseconds:Int = Int(NSDate().timeIntervalSince1970)
            let roomName:String = caller + callee + String(miliseconds)
            print("Creating room name: " + roomName)
            SingletonVars.sharedInstance.idRoomCall = roomName
            
            return roomName
        }
        print("Existing room name: " + SingletonVars.sharedInstance.idRoomCall)
        return SingletonVars.sharedInstance.idRoomCall
    }
    
    func testDeleteAllCitesFromCalendar(calID:String) {
        
        var citesFilter:[Cita] = []
        let cites = Cita.getAllCitesFromVincle(calID)
        
        for cita in cites {
            if cita.date!.isGreaterThanDate(self.getCurrentLocalDate()) {
                if cita.state! == EVENT_STATE_ACCEPTED {
                    citesFilter.append(cita)
                }
            }
        }
        
        let events =  EventStore.getEvents(self.getCurrentLocalDate(), endDate: citesFilter.last!.date!)
        
        for i in 0 ..< events.count {
            
            
        }
        
        for event in events {
            
            
        }
    }
    
    func getEncryptedPass(pass: String, id: String) -> [UInt8] {
        
        var result: [UInt8] = []
        
        let password = pass
        let passBytes = Array(password.utf8)
        let idBytes = Array(id.utf8)
        let idBytesHash = idBytes.sha256()
        
        do {
            let encrypted = try AES(key: idBytesHash, iv: iv, blockMode: .CBC, padding: PKCS7()).encrypt(passBytes)
            result = encrypted
        } catch {
            print(error)
        }
        return result
    }
    
    func getDecryptedPass(pass: NSData, id: String) -> String {
        let count = pass.length / sizeof(UInt8)
        var binaryPass = [UInt8](count: count, repeatedValue: 0)
        pass.getBytes(&binaryPass, length: count * sizeof(UInt8))
        
        return getDecryptedPass(binaryPass, id: id)
    }
    
    func getDecryptedPass(pass: [UInt8], id: String) -> String {
        
        var decryptedStr = ""
        let idBytes = Array(id.utf8)
        let idBytesHash = idBytes.sha256()
        
        do {
            let decrypted = try AES(key: idBytesHash, iv: iv, blockMode: .CBC, padding: PKCS7()).decrypt(pass)
            let str = String(bytes: decrypted, encoding: NSUTF8StringEncoding)
            decryptedStr = str!
        } catch {
            print(error)
        }
        return decryptedStr
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {

        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {

        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {

        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
}

extension UIColor {
    convenience init(hexString:String) {
        let hexString:NSString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let scanner = NSScanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
    
    
}
