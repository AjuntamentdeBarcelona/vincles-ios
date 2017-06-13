/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD
import SwiftyJSON

class MesDetailVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var novaCitaBtn: UIButton!
    @IBOutlet weak var citesTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var usrVincle:UserVincle!
    var currenDate:NSDate!
    var cites:[Cita] = []
    var comesFromInit = false
    
    var vincleImgView:UIImageView = {
        
        return UIImageView(frame: CGRectMake(0, 0, 40, 40))
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MesDetailVC.refreshFromBackGround), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }

        
        getVinclePhoto()
        
        citesTableView.registerNib(UINib.init(nibName:"CitaCellA",bundle: nil),forCellReuseIdentifier: "citaCellA")
        citesTableView.registerNib(UINib.init(nibName:"CitaCellB",bundle: nil),forCellReuseIdentifier: "citaCellB")
        citesTableView.registerNib(UINib.init(nibName:"CustomTitleHeaderCell",bundle: nil),forCellReuseIdentifier: "customTitleHeaderCell")
        citesTableView.registerNib(UINib.init(nibName:"NoContentCell",
            bundle: nil), forCellReuseIdentifier: "noContentCell")
        
        
        citesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        if comesFromInit == false {
            
            setNavBar()
            
        }
    }
    override func viewWillAppear(animated: Bool) {
        
        novaCitaBtn.layer.cornerRadius = 4.0
        
        retrieveCitasFromCoreData()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        SVProgressHUD.dismiss()
    }
    
    func refreshFromBackGround() {
        performSelector(#selector(MesDetailVC.reload), withObject: self, afterDelay: 1.0)
    }
    
    func reload() {
        
        retrieveCitasFromCoreData()
    }
    
    func retrieveCitasFromCoreData() {
        
        let startDay = Utils().getStartOfDay(currenDate)
        let endDay = Utils().getEndOfDay(currenDate)
        
        cites = []
        cites = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!,from:startDay, to: endDay)
        
        if cites.count != 0 {
            
            citesTableView.reloadData()
        }else{
            
            
            let fromTimeStamp = Utils().milliSecondsSince1970(startDay)
            let toTimeStamp = Utils().milliSecondsSince1970(endDay)
            
            getApiCitasTillEndDay(fromTimeStamp,to:toTimeStamp)
        }
        
    }
    
    func getApiCitasTillEndDay(from:Int64,to:Int64) {
        
        
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
                self.retrieveCitasFromCoreData()
            }
        }
    }
    
    func saveCitesToCoreData(json:JSON) {
        
        var idsArry:[String] = []
        let startDay = Utils().getStartOfDay(currenDate)
        let endDay = Utils().getEndOfDay(currenDate)
        let currEpoch = Utils().milliSecondsSince1970(startDay)
        
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
        citesTableView.reloadData()
        let fromEpoch = Utils().milliSecondsSince1970(cites.first!.date!)
        getApiCitasTillEndDay(currEpoch, to:fromEpoch)
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
                    self.citesTableView.deleteRowsAtIndexPaths([row], withRowAnimation: .Fade)
                }
                self.citesTableView.reloadData()
                
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
                cell.from = .Other
                cell.parentController = self
                cell.isRow = indexPath
                cell.setupCell()
                
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("noContentCell", forIndexPath: indexPath) as! NoContentTableViewCell
            cell.noContentLbl.text = langBundle.localizedStringForKey("CELL_NO_MESSAGES", value: nil, table: nil)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if cites.count != 0 {
            
            let citaTouched = cites[indexPath.row]
            
            if citaTouched.descript != "" {
                performSegueWithIdentifier("fromMesDetail_editaCita", sender: citaTouched)
                return false
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        
        let customHeader = tableView.dequeueReusableCellWithIdentifier("customTitleHeaderCell") as! CustomTitleHeaderCell
        customHeader.headerTitleLbl.text = formatter.stringFromDate(currenDate)
        return customHeader
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    @IBAction func novaCitaBtnPress(sender: UIButton) {
        
        
    }
    
    
    @IBAction func navBarCallBtnPress(sender: UIBarButtonItem) {
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Trucant
            SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
            self.presentViewController(secondViewController, animated: true, completion:nil)
        }
    }
    
    @IBAction func navBackBtnPress(sender: UIBarButtonItem) {
        
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKindOfClass(InicioTableViewController) {
                    let initVC = viewController as! InicioTableViewController
                    initVC.viewNameLbl.text = initVC.langBundle.localizedStringForKey("INIT_NAVBAR_TITLE", value: nil, table: nil)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                    
                }else{
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromMesDetail_editaCita" {
            let navVC = segue.destinationViewController as! UINavigationController
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("editaVC") as! EditaCitaVC
            
            let cit = sender as! Cita
            vc.isEditingCita = true
            vc.currentCita = cit
            navVC.setViewControllers([vc], animated: true)
        }
    }
    
    func getVinclePhoto() {
        
        if let _ = usrVincle.photo {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let imgData = Utils().imageFromBase64ToData(self.usrVincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                self.vincleImgView.image = xarxaImg
                print("IMAGE ADDED")
            })
        }else{
            Utils().retrieveUserVinclesProfilePhoto(usrVincle, completion: { (result, imgB64) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    self.vincleImgView.image = xarxaImg
                })
            })
        }
    }
    
    
    func setNavBar() {
        
        let navBar = self.navigationController?.navigationBar
        
        navBar?.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        navBar?.translucent = false
        
        let viewNameLbl = UILabel(frame:CGRectMake(0,0,150,70))
        viewNameLbl.text = langBundle.localizedStringForKey("AGENDA_NAVBAR_TITLE", value: nil, table: nil)
        
        viewNameLbl.textColor = UIColor.whiteColor()
        viewNameLbl.font = viewNameLbl.font.fontWithSize(20)
        navBar?.addSubview(viewNameLbl)
        
        let pinLblLeft = NSLayoutConstraint(item: viewNameLbl, attribute: .Left,
                                            relatedBy: .Equal, toItem: navBar, attribute: .LeftMargin,
                                            multiplier: 1.0, constant: 63)
        let pinLblTop = NSLayoutConstraint(item: viewNameLbl, attribute: .Top,
                                           relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                           multiplier: 1.0, constant: -14)
        let heightLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Height,
                                                relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                                multiplier: 1, constant: 50)
        let widthLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Width,
                                               relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                               multiplier: 1, constant: 150)
        
        viewNameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinLblLeft,pinLblTop,heightLblConst,widthLblConst])
        
        vincleImgView.contentMode = .ScaleAspectFill
        navBar?.addSubview(vincleImgView)
        
        vincleImgView.layer.borderColor = UIColor.whiteColor().CGColor
        vincleImgView.layer.borderWidth = 0.0
        vincleImgView.layer.masksToBounds = false
        vincleImgView.layer.cornerRadius = vincleImgView.frame.size.height/2
        vincleImgView.clipsToBounds = true
        
        let pinRight = NSLayoutConstraint(item: vincleImgView, attribute: .Right,
                                          relatedBy: .Equal, toItem: navBar, attribute: .RightMargin,
                                          multiplier: 1.0, constant: -57)
        let pinTop = NSLayoutConstraint(item: vincleImgView, attribute: .Top,
                                        relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                        multiplier: 1.0, constant: -9)
        let heightConst = NSLayoutConstraint(item: vincleImgView, attribute: .Height,
                                             relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                             multiplier: 1, constant: 40)
        let widthConst = NSLayoutConstraint(item: vincleImgView, attribute: .Width,
                                            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                            multiplier: 1, constant: 40)
        
        vincleImgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinRight,pinTop,heightConst,widthConst])
        
    }
}
