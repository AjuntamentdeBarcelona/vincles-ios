/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SwiftyJSON
import CoreData
import SVProgressHUD



class DemaVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateTitleLabel: UILabel!
    
    var refresh: UIRefreshControl!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var usrVincle:UserVincle!
    
    var cites:[Cita] = []
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(DemaVC.refreshFromBackGround), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        tableView.registerNib(UINib.init(nibName:"CitaCellA",bundle: nil),forCellReuseIdentifier: "citaCellA")
        tableView.registerNib(UINib.init(nibName:"CitaCellB",bundle: nil),forCellReuseIdentifier: "citaCellB")
        tableView.registerNib(UINib.init(nibName:"NoContentCell",
            bundle: nil), forCellReuseIdentifier: "noContentCell")

        
        tableView.contentInset = UIEdgeInsetsMake(-35.5, 0.0, 0.0, 0.0)
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(InicioTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresh)
    }
    
    func refresh(sender: AnyObject) {
        reload()
        refresh.endRefreshing()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if (usrVincle != nil){
            retrieveCitasFromCoreData()
        }
        setUI()
        tableView.reloadData()
        
    }
    
    func refreshFromBackGround() {
        performSelector(#selector(DemaVC.reload), withObject: self, afterDelay: 1.0)
    }
    
    func reload() {
        if (usrVincle != nil){
            retrieveCitasFromCoreData()
        }
    }
    
    
    func retrieveCitasFromCoreData() {
        
        let dates = Utils().getTomorrowTimeInterval()
        
        cites = []
        cites = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!,from:dates[0], to: dates[1])
        
        if cites.count != 0 {
            
            tableView.reloadData()
        }else{
            
            
            let fromTimeStamp = Utils().milliSecondsSince1970(dates[0])
            let toTimeStamp = Utils().milliSecondsSince1970(dates[1])
            
            getApiCitasNextDay(fromTimeStamp,to:toTimeStamp)
        }

        
        tableView.reloadData()
    }
    
    func getApiCitasNextDay(from:Int64,to:Int64) {
        print("GET API FROM \(from) TO \(to)")
        
        SVProgressHUD.show()
        
        VinclesApiManager.sharedInstance.getListOfEvents(Int(usrVincle.idCalendar!)!, from: from, to: to) { (status, json) in
            
            if status == "SUCCESS" {
                SVProgressHUD.dismiss()
                
                if json!.count != 0 {
                    self.saveCitesToCoreData(json!)
                    
                }else {
                   print("EMPTY JSON")
                }
            }
            if status == "FAILURE" {
                SVProgressHUD.dismiss()

            }
        }
    }
    
    func saveCitesToCoreData(json:JSON) {
        
        var idsArry:[String] = []
        
        let datesArry = Utils().getTomorrowTimeInterval()
        cites = []
        cites = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!,from:datesArry[0],to:datesArry[1])
        
        for ids in cites {
            idsArry.append(ids.id!)
        }
        
        for i in 0 ..< json.count {
            if idsArry.contains(json[i]["id"].stringValue) {
            }else{
                let newCita = Cita.addNewCitaToEntity(json[i])
                cites.insert(newCita, atIndex: 0)
            }
        }
        
        let tomorrHours = Utils().getTomorrowTimeInterval()
        cites = []
        cites = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!,from:tomorrHours[0], to: tomorrHours[1])
        tableView.reloadData()
        
        let toEpoch = Int64(json[0]["date"].stringValue)
        let tomorrEpoch = Utils().milliSecondsSince1970(tomorrHours[0])
        getApiCitasNextDay(tomorrEpoch, to: toEpoch!-1)
    }
    
    func setUI() {
        
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        self.tableView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        let hoursLeft = Utils().hoursLeftUntilEndDay()
        let date = NSDate().addHours(hoursLeft)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        
        dateTitleLabel.text = formatter.stringFromDate(date)
    }
    
    func deleteCita(cita:Cita,row:NSIndexPath) {
        
        VinclesApiManager.sharedInstance.deleteCita(Int(cita.calendarId!)!, idEvent: Int(cita.id!)!) { (status) in
            
            if status == "SUCCESS" {
                // create initFeed
                let params:[String:AnyObject] = [
                    "date":Utils().getCurrentLocalDate(),
                    "objectDate":cita.date!,
                    "id":cita.id!,
                    "idUsrVincles":cita.calendarId!,
                    "type":INIT_CELL_EVENT_DELETED,
                    "textBody":cita.descript!,
                    "isRead":false]
                
                InitFeed.addNewFeedEntityOffline(params)
                
                if cita.state! == EVENT_STATE_ACCEPTED {
                    Utils().deleteEventInCalendar(cita)
                }

                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                managedContext.deleteObject(cita)
                Cita.saveCitesContext()
                
                self.cites.removeAtIndex(row.row)
                
                if self.cites.count > 0 {
                    self.tableView.deleteRowsAtIndexPaths([row], withRowAnimation: .Fade)
                }
                self.tableView.reloadData()
                
                let alert = Utils().postAlert(self.langBundle.localizedStringForKey("AGENDA_NAVBAR_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("DELETED_TEXT", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            if status == "FAILURE" {
                let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ERROR_CITA_DELETE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if cites.count != 0 {
            
            return cites.count
        }else{
            return 1
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if cites.count != 0 {
        
        let citaCell = cites[indexPath.row]
        
        if citaCell.descript == "" {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("citaCellB", forIndexPath: indexPath) as! CitaBTableViewCell
            cell.cellCita = cites[indexPath.row]
            cell.setupCell()
            
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("citaCellA", forIndexPath: indexPath) as! CitaATableViewCell
            cell.cellCita = cites[indexPath.row]
            cell.from = .Dema
            cell.parentController = self
            cell.isRow = indexPath
            cell.setupCell()

            return cell
        }
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("noContentCell", forIndexPath: indexPath) as! NoContentTableViewCell
            cell.noContentLbl.text = langBundle.localizedStringForKey("CELL_NO_DATES", value: nil, table: nil)

            return cell
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if cites.count != 0 {
        
        let citaTouched = cites[indexPath.row]
        
        if citaTouched.descript != "" {
            performSegueWithIdentifier("fromAgendaDema_novaCita", sender: citaTouched)
            return true
        }else{
            return false
        }
        }else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if cites.count != 0 {
        
        let citaCell = cites[indexPath.row]
        
        if citaCell.descript == "" {
            return 85.0
        }else{
            if citaCell.state == EVENT_STATE_ACCEPTED 
            {
                return 85.0
            }else{
                return 128.0
            }
        }
        }else{
            return 65.0
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cites.count != 0 {
        
        let citaCell = cites[indexPath.row]
        
        if editingStyle == .Delete {
            deleteCita(citaCell,row:indexPath)
        }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if cites.count != 0 {
        
        let citaCell = cites[indexPath.row]
        
        if citaCell.descript == "" {
            return false
        }else{
            return true
        }
        }else{
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromAgendaDema_novaCita" {
            
            let navVC = segue.destinationViewController as! UINavigationController
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("editaVC") as! EditaCitaVC
            
            let cit = sender as! Cita
            vc.isEditingCita = true
            vc.currentCita = cit
            navVC.setViewControllers([vc], animated: true)
        }
    }
    
    func clearCitesEntityTEST() { // TEST
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            for i in 0 ..< results.count {
                managedContext.deleteObject(results[i])
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
