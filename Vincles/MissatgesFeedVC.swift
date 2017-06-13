/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD
import SwiftyJSON
import CoreData

class MissatgesFeedVC: VinclesVC,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var msgTableView: UITableView!
    @IBOutlet weak var newMsgBtn: UIButton!
    @IBOutlet weak var newMsgTitle: UILabel!
    @IBOutlet weak var menuNavBtn: UIBarButtonItem!
    @IBOutlet weak var footerView: UIView!
    
    var refresh: UIRefreshControl!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    var usrVincle:UserVincle!
    
    var missatges:[Missatges] = []
    var fromTimeStamp:Int64 = 0
    var goToNewMessage = false
    var messageJustSent = false
    var messagesEmpty = false
    
    var vincleBarImgView:UIImageView = {
        
      return UIImageView(frame: CGRectMake(0, 0, 40, 40))
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = MISSATGESFEED_VC
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        getVinclePhoto()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(InicioTableViewController.refreshFromBackGround), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(InicioTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        msgTableView.addSubview(refresh)
        
        msgTableView.registerNib(UINib.init(nibName:"cellMissatgesFeed",
            bundle: nil), forCellReuseIdentifier: "cellMsgFeed")
        msgTableView.registerNib(UINib.init(nibName:"NoContentCell",
            bundle: nil), forCellReuseIdentifier: "noContentCell")
        
        checkGlobalVariables()
    }
    
    func refresh(sender: AnyObject) {
        reload()
        refresh.endRefreshing()
    }
    
    func checkGlobalVariables() {
        
        if SingletonVars.sharedInstance.initMenuHasToChange == true {
            setNavBar()
            setUI()
            checkLocalMessagesData()
            
            if goToNewMessage == true {
                performSegueWithIdentifier("fromMsgFeed_NouMissatge", sender: nil)
            }
            if messageJustSent == true {
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERTA_MESSAGE_SENT_TITLE", value: nil, table: nil),message:langBundle.localizedStringForKey("ALERTA_MESSAGE_SENT_BODY", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            SingletonVars.sharedInstance.initMenuHasToChange = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setNavBar()
        setUI()
        checkGlobalVariables()
        if usrVincle != nil{
                checkLocalMessagesData()
            }
        else{
            messagesEmpty = true
        }
        
    }
    
    func refreshFromBackGround() {
        performSelector(#selector(MissatgesFeedVC.reload), withObject: self, afterDelay: 1.0)
    }
    
    func reload() {
        missatges = []
        if usrVincle != nil{
            checkLocalMessagesData()
        }
        else{
            messagesEmpty = true
        }
        msgTableView.reloadData()
    }
    
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    func checkLocalMessagesData() {
        
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)!
        }
        if Missatges.entityMissatgesEmpty(usrVincle.id!) {
            messagesEmpty = true
        }else{
            missatges = Missatges.loadMissatgesFromCoreData(usrVincle.id!)
            fromTimeStamp = Utils().milliSecondsSince1970(missatges.first!.sendTime!)
            messagesEmpty = false
        }
    }
    
    func deleteContent(msg:Missatges) {
        
        let arryMess = NSKeyedUnarchiver.unarchiveObjectWithData(msg.idAdjuntContents!) as! [Int]
        
        for content in arryMess {
            print("ID INSIDE \(content)")
            VinclesApiManager.sharedInstance.deleteContent(content)
        }
    }
    
    func deleteMessage(msg:Missatges,idxPath:NSIndexPath) {
        
        VinclesApiManager.sharedInstance.deleteMessage(msg.id!) { (result) in
            
            if result == "SUCCESS" {
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                managedContext.deleteObject(msg)
                Missatges.saveMissatgesContext()
                
                self.missatges.removeAtIndex(idxPath.row)
                self.msgTableView.deleteRowsAtIndexPaths([idxPath], withRowAnimation: .Fade)
                self.msgTableView.reloadData()
            }
            
            if result == "FAILURE" {
                
                let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ERROR_MESSAGE_DELETE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if messagesEmpty == false {
            return missatges.count
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if messagesEmpty == false {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cellMsgFeed", forIndexPath: indexPath) as! MissatgesFeedTableViewCell
        cell.setCellContent(missatges[indexPath.row])
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("noContentCell", forIndexPath: indexPath) as! NoContentTableViewCell
            
            cell.noContentLbl.text = langBundle.localizedStringForKey("CELL_NO_MESSAGES", value: nil, table: nil)
            cell.userInteractionEnabled = false
 
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 81.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let msg = missatges[indexPath.row]
        
        if editingStyle == .Delete {
            deleteMessage(msg, idxPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        messageToShow(missatges[indexPath.row])
        
        if self.missatges[indexPath.row].watched! == 0 {
            
            VinclesApiManager.sharedInstance.markMessageAsRead(missatges[indexPath.row].id!,completion: { result in
                
                if result == "SUCCESS" {
                    
                }
                if result == "FAILURE" {
                    
                }
            })
            self.missatges[indexPath.row].watched! = 1
            Missatges.saveMissatgesContext()
            self.msgTableView.reloadData()
        }
        return false
    }
    
    func messageToShow(msg:Missatges) {
        
        switch msg.metadataTipus! {
        case MESSAGE_TYPE_IMAGE:
            performSegueWithIdentifier("msgFeed_msgFotoRead", sender: msg)
            
        case MESSAGE_TYPE_VIDEO:
            performSegueWithIdentifier("msgFeed_msgVideoRead", sender: msg)
            
        case MESSAGE_TYPE_AUDIO:
            performSegueWithIdentifier("msgFeed_msgAudioRead", sender: msg)
            
        default:
            print(msg.metadataTipus!)
        }
    }
    
    func getVinclePhoto() {
        if (usrVincle != nil){
            if let _ = usrVincle.photo
            {
                let imgData = Utils().imageFromBase64ToData(self.usrVincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.vincleBarImgView.image = xarxaImg
                    print("IMAGE ADDED")
                })
            }
            else
            {
                Utils().retrieveUserVinclesProfilePhoto(usrVincle, completion: { (result, imgB64) in
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.vincleBarImgView.image = xarxaImg
                    })
                })
            }
        }
        else{

            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            self.vincleBarImgView.image = xarxaImg
        }
        
    }
    
    
    
    func setNavBar() {
        
        if self.revealViewController() != nil {
            menuNavBtn.target = self.revealViewController()
            menuNavBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let navBar = self.navigationController?.navigationBar
        navBar?.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        navBar?.translucent = false
        
        let viewNameLbl = UILabel(frame:CGRectMake(0,0,120,70))
        viewNameLbl.text = langBundle.localizedStringForKey("MSG_NAVBAR_TITLE", value: nil, table: nil)
        viewNameLbl.textColor = UIColor.whiteColor()
        viewNameLbl.font = viewNameLbl.font.fontWithSize(22)
        navBar?.addSubview(viewNameLbl)
        
        let pinLblLeft = NSLayoutConstraint(item: viewNameLbl, attribute: .Left,
                                            relatedBy: .Equal, toItem: navBar, attribute: .LeftMargin,
                                            multiplier: 1.0, constant: 63)
        let pinLblTop = NSLayoutConstraint(item: viewNameLbl, attribute: .Top,
                                           relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                           multiplier: 1.0, constant: -15)
        let heightLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Height,
                                                relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                                multiplier: 1, constant: 50)
        let widthLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Width,
                                               relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                               multiplier: 1, constant: 120)
        
        viewNameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinLblLeft,pinLblTop,heightLblConst,widthLblConst])
        
        if (usrVincle == nil && userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        // NavBar
        vincleBarImgView.contentMode = .ScaleAspectFill
        navBar?.addSubview(vincleBarImgView)
        
        vincleBarImgView.layer.borderColor = UIColor.whiteColor().CGColor
        vincleBarImgView.layer.borderWidth = 0.0
        vincleBarImgView.layer.masksToBounds = false
        vincleBarImgView.layer.cornerRadius = vincleBarImgView.frame.size.height/2
        vincleBarImgView.clipsToBounds = true
        
        let pinRight = NSLayoutConstraint(item: vincleBarImgView, attribute: .Right,
                                          relatedBy: .Equal, toItem: navBar, attribute: .RightMargin,
                                          multiplier: 1.0, constant: -57)
        let pinTop = NSLayoutConstraint(item: vincleBarImgView, attribute: .Top,
                                        relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                        multiplier: 1.0, constant: -9)
        let heightConst = NSLayoutConstraint(item: vincleBarImgView, attribute: .Height,
                                             relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                             multiplier: 1, constant: 40)
        let widthConst = NSLayoutConstraint(item: vincleBarImgView, attribute: .Width,
                                            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                            multiplier: 1, constant: 40)
        
        vincleBarImgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinRight,pinTop,heightConst,widthConst])
        
        let img = UIImage(named: "arrow-back-subheader")
        
        self.navigationController?.navigationBar.backIndicatorImage =
            img?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                .imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, -5, 0))
        
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage =
            img?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                .imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, -5, 0))
        
        self.navigationItem.backBarButtonItem =
            UIBarButtonItem(title:"", style:.Plain, target: nil, action: nil)
    }
    
    func setUI() {
        
        // remove header space because navController
        self.automaticallyAdjustsScrollViewInsets = false
        // remove Grouped cell title header
        msgTableView.contentInset = UIEdgeInsetsMake(-35.0, 0.0, 0.0, 0.0)
        newMsgTitle.text = langBundle.localizedStringForKey("BTN_NEW_MESSAGE_TITLE",
                                                            value: nil, table: nil)
        newMsgBtn.layer.cornerRadius = 4.0
        newMsgBtn.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        msgTableView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        footerView.backgroundColor = UIColor(hexString: HEX_DARK_BACK_FOOTER)
    }
    
    @IBAction func newMsgPress(sender: UIButton) {
        
        if (userCercle.vincleSelected != nil){
            performSegueWithIdentifier("fromMsgFeed_NouMissatge", sender: nil)
        }
        else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_USERS_MESSAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func barCallBtnPress(sender: UIBarButtonItem) {
    
        if (userCercle.vincleSelected != nil){
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                SingletonVars.sharedInstance.initMenuHasToChange = true
                SingletonVars.sharedInstance.initDestination = .Trucant
                SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
                self.presentViewController(secondViewController, animated: true, completion:nil)
            }
        }
        else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_USERS_MESSAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "msgFeed_msgFotoRead" {
            let vc = segue.destinationViewController as! MsgFotoRead
            vc.missatge = sender as! Missatges
        }
        if segue.identifier == "msgFeed_msgVideoRead" {
            let vc = segue.destinationViewController as! MsgVideoReadVC
            vc.missatge = sender as! Missatges
        }
        if segue.identifier == "msgFeed_msgAudioRead" {
            let vc = segue.destinationViewController as! MsgAudioReadVC
            vc.missatge = sender as! Missatges
        }
        if segue.identifier == "fromMsgFeed_NouMissatge" {
            
        }
    }
    
    func clearMissatgesEntityTEST() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Missatges")
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Missatges]
            for i in 0 ..< results.count {
                managedContext.deleteObject(results[i])
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func firstLoadMessagesArryFromApi(json:JSON) {
        let count = json.count
        var idsArry:[String] = []
        
        for ids in missatges {
            idsArry.append(ids.id!)
        }
        for i in 0 ..< count {
            if idsArry.contains(json[i]["id"].stringValue) {
            }else{
                if json[i]["idUserFrom"].stringValue == usrVincle.id!   {
                    let newMissatge = Missatges.addNewMissatgeToEntity(json[i])
                    missatges.append(newMissatge)
                }
            }
        }
        
        let dateTransform = Double(json[0]["sendTime"].stringValue)
        let msgDate = Utils().nsDateFromMilliSeconds(dateTransform!)
        fromTimeStamp = Utils().milliSecondsSince1970(msgDate)
        let nowTimeStamp = Utils().milliSecondsSince1970(NSDate())
        APIgetAllMessages(fromTimeStamp+1, to:nowTimeStamp )
        msgTableView.reloadData()
    }
    
    func updateMissatgesDataWithIntegration(json:JSON) {
        let count = json.count
        var idsArry:[String] = []
        var firstID = 0
        
        if missatges.count > 0 {
            firstID = Int((missatges.first?.id)!)!
        }
        for ids in missatges {
            idsArry.append(ids.id!)
        }
        
        for i in (0...count-1).reverse() {
            if idsArry.contains(json[i]["id"].stringValue)  {
            }else{
                if json[i]["idUserFrom"].stringValue == usrVincle.id!   {
                    print("MSG ID ADDED \(json[i]["id"].stringValue)")
                    
                    let newMissatge = Missatges.addNewMissatgeToEntity(json[i])
                    let newMsgIdInt = Int(newMissatge.id!)
                    
                    if newMsgIdInt! > firstID {
                        missatges.insert(newMissatge, atIndex: 0)
                    }else{
                        missatges.append(newMissatge)
                    }
                }
            }
        }
        let dateTransform = Double(json[0]["sendTime"].stringValue)
        let msgDate = Utils().nsDateFromMilliSeconds(dateTransform!)
        fromTimeStamp = Utils().milliSecondsSince1970(msgDate)
        let nowTimeStamp = Utils().milliSecondsSince1970(NSDate())
        APIgetAllMessages(fromTimeStamp+1, to:nowTimeStamp )
        msgTableView.reloadData()
    }
    
    func APIgetAllMessages(from:Int64,to:Int64) {
        
        SVProgressHUD.show()
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let parameters = ["from":"\(from)",
                          "to":"\(to)",
                          "idUserSender":"\(usrVincle.id!)"]
        let header = ["Authorization":"Bearer \(token!)"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,URL_GET_MESSAGES,headers:header,parameters:parameters,encoding:.URL)
            
            .responseJSON { response in
                print(response.result)
                
                switch response.result {
                case .Success(let json):
                    switch response.response!.statusCode {
                    case 200..<400:
                        let myJson = JSON(json)
                        print("JSON DESCRITP \(myJson)")
                        if myJson.count != 0 {
                            if self.missatges.count > 0 {
                                self.updateMissatgesDataWithIntegration(myJson)
                            }else{
                                self.firstLoadMessagesArryFromApi(myJson)
                            }
                        }else{
                            
                        }
                        SVProgressHUD.dismiss()
                    case 400..<500:
                        print("CODE 400 . 499")
                        SVProgressHUD.dismiss()
                    case let stat where stat > 499:
                        SVProgressHUD.dismiss()
                        print("CODE 499 +")
                    default:
                        print("Default")
                    }
                    
                case .Failure(_):
                    if response.response?.statusCode != nil {
                        if response.response!.statusCode == 401 { // not logged
                            VinclesApiManager().loginSelfUser(self.userCercle.username!,
                                pwd: self.userCercle.password!, usrId: self.userCercle.id!)
                            self.APIgetAllMessages(from, to: to)
                        }
                    }else{
                        let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE",
                            value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE",
                                value: nil, table:nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    
    
}
