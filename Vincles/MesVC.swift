/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SwiftyJSON


class MesVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()

    
    var fakeDates:[NSDate] = []
    var datesArry:[NSDate] = []
    
    var usrVincle:UserVincle!
    
    var allCitas:[Cita] = []
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MesVC.refreshFromBackGround), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        setCalendarView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if (usrVincle != nil){
            if usrVincle.eventsFirstLoad == 0 {
            firstGetAllApiEvents()
                usrVincle.eventsFirstLoad = 1
                UserVincle.saveUserVincleContext()
            }else{
                loadDates()
                
            }
        }
    }
    
    func refreshFromBackGround() {
        performSelector(#selector(MesVC.reload), withObject: self, afterDelay: 1.0)
    }
    
    func reload() {
        allCitas = []
        datesArry = []
        loadDates()
    }
    
    func loadDates() {
        
        allCitas = Cita.loadAllCitesDataFromCoreDataWithDate(usrVincle.idCalendar!, from: NSDate())
        
        for cit in allCitas {
            datesArry.append(cit.date!)
        }
        
        for dates in datesArry {
            let components = Utils().getCalendarComponentsFromDate(dates)
            calendar.selectDate(calendar.dateWithYear(components.year, month: components.month, day: components.day))
        }
        calendar.setCurrentPage(NSDate(), animated: true)
    }

    
    func firstGetAllApiEvents() {
        
        VinclesApiManager.sharedInstance.getListOfAllEvents(Int(usrVincle.idCalendar!)!) {
            (status, json) in
            
            if status == "SUCCESS" {
                if json!.count != 0 {
                    let last = json![json!.count-1]
                    print("LAST OF ALL \(last["id"].stringValue)")
                    let lastEpoch = Int64(last["date"].stringValue)!
                    self.saveCitesToCoreData(json!)
                    self.moreGetAllApiEvents(lastEpoch-1)
                    
                }else{
                    self.loadDates()
                }
            }
            if status == "FAILURE" {
                let alert = Utils().postAlert("Atenció", message:self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.loadDates()
            }
        }
    }
    
    func moreGetAllApiEvents(to:Int64) {
        VinclesApiManager.sharedInstance.getMoreListOfAllEvents(Int(usrVincle.idCalendar!)!,to:to) {
            (status, json) in
            
            if status == "SUCCESS" {
                if json!.count != 0 {
                    let last = json![json!.count-1]
                    print("LAST OF ALL \(last["id"].stringValue)")
                    let lastEpoch = Int64(last["date"].stringValue)!
                    self.saveCitesToCoreData(json!)
                    self.moreGetAllApiEvents(lastEpoch-1)
                }else{
                    self.loadDates()
                }
            }
            if status == "FAILURE" {
                let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ERROR_BODY", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.loadDates()
            }
        }
    }
    
    func saveCitesToCoreData(json:JSON) {
        
        var idsArry:[String] = []	
        let allLocalCitas = Cita.loadAllCitesDataFromCoreData(usrVincle.idCalendar!)
        
        for ids in allLocalCitas {
            idsArry.append(ids.id!)
        }
        
        for i in 0 ..< json.count {
            
            if idsArry.contains(json[i]["id"].stringValue) {
            }else{
                let newCita = Cita.createBlankCitaEntity()
                newCita.id = json[i]["id"].stringValue
                
                let dateTransform = Double(json[i]["date"].stringValue)
                let citaDate = Utils().nsDateFromMilliSeconds(dateTransform!)
                newCita.date = citaDate
                
                newCita.descript = json[i]["description"].stringValue
                newCita.state = json[i]["state"].stringValue
                newCita.calendarId = json[i]["calendarId"].stringValue
                newCita.duration = json[i]["duration"].stringValue
                
                Cita.saveCitesContext()
            }
        }
    }

    
    func setCalendarView() {
        
        calendar.scrollDirection = .Horizontal
        calendar.appearance.caseOptions = [.HeaderUsesUpperCase,.WeekdayUsesDefaultCase]
        calendar.clipsToBounds = true
        calendar.allowsMultipleSelection = true
        calendar.firstWeekday = 2;
        calendar.appearance.todaySelectionColor = UIColor.orangeColor()
        calendar.appearance.selectionColor = UIColor.redColor()
        calendar.appearance.todayColor = UIColor.darkGrayColor()
        calendar.appearance.headerTitleColor = UIColor.blackColor()
        calendar.appearance.titleWeekendColor = UIColor.blackColor()
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        calendar.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
    }
    
    
    func calendar(calendar: FSCalendar, shouldSelectDate date: NSDate) -> Bool {
        var shouldReturn = false
        
        for eventDate in fakeDates{
            if Utils().calendarDatesAreTheSame(date, eventDate: eventDate){
                shouldReturn = true
            }else{
                shouldReturn = false
            }
        }
        return shouldReturn
    }
    
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        
        return 0
    }
    
    func calendarCurrentPageDidChange(calendar: FSCalendar) {
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        NSLog("calendar did select date \(date)")
    }
    
    func calendar(calendar: FSCalendar, shouldDeselectDate date: NSDate) -> Bool {
        
        for eventDate in datesArry {
            if Utils().calendarDatesAreTheSame(date, eventDate: eventDate) {
                

                let rootVC = self.storyboard?.instantiateViewControllerWithIdentifier("AgendaVC") as? AgendaViewController
                
                let secondVC = self.storyboard?.instantiateViewControllerWithIdentifier("mesDetailVC") as! MesDetailVC
                secondVC.currenDate = date
                secondVC.comesFromInit = false
                
                let navController = UINavigationController(rootViewController: rootVC!)
                navController.navigationBar.barTintColor = UIColor(hexString: HEX_RED_BTN)
                navController.setViewControllers([rootVC!,secondVC], animated:true)
                
                self.presentViewController(navController, animated: true, completion: nil)

            }
        }
        print("deselect")
        return false
    }
    
    func calendar(calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        view.layoutIfNeeded()
    }
    
    func calendar(calendar: FSCalendar, imageForDate date: NSDate) -> UIImage? {
        return  nil
    }
    
    func calendarCurrentMonthDidChange(calendar: FSCalendar) {

    }
    
    func minimumDateForCalendar(calendar: FSCalendar) -> NSDate {
        let date = NSDate()
        let components = Utils().getCalendarComponentsFromDate(date)
        
        return calendar.dateWithYear(components.year-3, month: components.month, day: components.day)
    }
    
    func maximumDateForCalendar(calendar: FSCalendar) -> NSDate {
        let date = NSDate()
        let components = Utils().getCalendarComponentsFromDate(date)
        
        return calendar.dateWithYear(components.year+3, month: components.month, day: components.day)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromMes_mesDetail" {
            let vc = segue.destinationViewController as! MesDetailVC
            
            let cit = sender as! NSDate
            vc.currenDate  = cit
        }
    }
    
    
    @IBAction func prevMonthBtnPress(sender: UIButton) {
        
        let currentMonth = calendar.currentPage
        let previousMonth = calendar.dateBySubstractingMonths(1, fromDate: currentMonth)
        calendar.setCurrentPage(previousMonth, animated: true)
    }
    
    @IBAction func nextMonthBtnPress(sender: UIButton) {
        
        let currentMonth = calendar.currentPage
        let nextMonth = calendar.dateByAddingMonths(1, toDate: currentMonth)
        
        calendar.setCurrentPage(nextMonth, animated: true)
    }
}
