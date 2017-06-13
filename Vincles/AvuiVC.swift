/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD
import SwiftyJSON
import CoreData


class AvuiVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avuiTitleLabel: UILabel!
    
    var refresh: UIRefreshControl!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var usrVincle:UserVincle!
    
    var cites:[Cita] = []
    var eventsEmpty = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AvuiVC.refreshFromBackGround), name:
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
        performSelector(#selector(AvuiVC.reload), withObject: self, afterDelay: 1.0)
    }
    
    func reload() {
        
        if (usrVincle != nil){
            retrieveCitasFromCoreData()
        }
    }
    
    func retrieveCitasFromCoreData() {
        
        let currDate = Utils().getCurrentLocalDate()
        let startDay = Utils().getStartOfDay(currDate)
        let endDay = Utils().getEndOfDay(currDate)
        
        cites = []
        cites = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!,from:startDay, to: endDay)
        
        if cites.count != 0 {
            
            eventsEmpty = false
            tableView.reloadData()
        }else{
            
            
            let fromTimeStamp = Utils().milliSecondsSince1970(startDay)
            let toTimeStamp = Utils().milliSecondsSince1970(endDay)
            
            getApiCitasTillEndDay(fromTimeStamp,to:toTimeStamp)
            
            
        }
    }
    
    func getApiCitasTillEndDay(from:Int64,to:Int64) {
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
                
                let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func saveCitesToCoreData(json:JSON) {
        
        var idsArry:[String] = []
        let currDate = Utils().getCurrentLocalDate()
        let currEpoch = Utils().milliSecondsSince1970(currDate)
        let startDay = Utils().getStartOfDay(currDate)
        let endDay = Utils().getEndOfDay(currDate)
        
        cites = []
        cites = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!,from:startDay,to:endDay)
        
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
        cites = []
        cites = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!,from:startDay,to:endDay)
        tableView.reloadData()
        
        let fromEpoch = Utils().milliSecondsSince1970(cites.first!.date!)
        getApiCitasTillEndDay(currEpoch, to:fromEpoch)
    }
    
    func setUI() {
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        self.tableView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        avuiTitleLabel.text = langBundle.localizedStringForKey("AGENDA_TODAY_LABEL", value:nil, table:nil)
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
                cell.from = .Avui
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
            
            performSegueWithIdentifier("fromAvui_EditaCitaVC", sender: citaTouched)
            
            return true
        }else{
            return false
        }
            
        }else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.0
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromAvui_EditaCitaVC" {
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
            print("COUNT COREDATA \(results.count)")
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // unused
    func firstGetAllApiEvents() {
        VinclesApiManager.sharedInstance.getListOfAllEvents(Int(usrVincle.idCalendar!)!) { (status, json) in
            
            if status == "SUCCESS" {
                if json!.count != 0 {
                    let last = json![json!.count-1]
                    print("LAST OF ALL \(last["id"].stringValue)")
                    let lastEpoch = Int64(last["date"].stringValue)!
                    self.moreGetAllApiEvents(lastEpoch-1)
                }
            }
            if status == "FAILURE" {
            }
        }
    }
    
    // unused
    func moreGetAllApiEvents(to:Int64) {
        VinclesApiManager.sharedInstance.getMoreListOfAllEvents(Int(usrVincle.idCalendar!)!,to:to) { (status, json) in
            
            if status == "SUCCESS" {
                if json!.count != 0 {
                    let last = json![json!.count-1]
                    print("LAST OF ALL \(last["id"].stringValue)")
                    let lastEpoch = Int64(last["date"].stringValue)!
                    self.moreGetAllApiEvents(lastEpoch-1)
                }
            }
            if status == "FAILURE" {
            }
        }
    }
}
