/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD
import CoreData
import SwiftyJSON

class XarxesVC: VinclesVC,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var selecXarxaLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newXarxaBtn: UIButton!
    @IBOutlet weak var newXarxaBtnTitle: UILabel!
    @IBOutlet weak var navBarCallBtn: UIBarButtonItem!
    
    @IBOutlet weak var viewFoot: UIView!
    @IBOutlet weak var menuBarBtn: UIBarButtonItem!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var vincles:[UserVincle] = {
        UserVincle.loadUserVincleCoreData()
    }()
    
    var userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var vincleSelected:Int!
    var currVincleImgView:UIImageView!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = XARXES_VC
        
        if (userCercle.vincleSelected != nil) {
            vincleSelected = getVincleIdxWithID(userCercle.vincleSelected!)
        }
        setNavBar()
        setUI()
        
        tableView.registerNib(UINib.init(nibName:"cellXarxa",bundle: nil),forCellReuseIdentifier: "cellXarxa")
        tableView.registerNib(UINib.init(nibName:"CustomTitleHeaderCell",bundle: nil),forCellReuseIdentifier: "customTitleHeaderCell")
        tableView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        viewFoot.backgroundColor = UIColor(hexString: HEX_DARK_BACK_FOOTER)

        if (userCercle.vincleSelected != nil){

            if SingletonVars.sharedInstance.initMenuHasToChange == true {
                APIgetUserCercles()
                SingletonVars.sharedInstance.initMenuHasToChange = false
            }
        }        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(XarxesVC.refreshFromBackGround), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        
        SVProgressHUD.dismiss()
    }
    
    func getVincleIdxWithID(id:String) -> Int {
        
        var idx = -1
        for i in 0 ..< vincles.count {
            if vincles[i].id! == userCercle.vincleSelected! {
                idx = i
            }
        }
        return idx
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (userCercle.vincleSelected != nil){
            APIgetUserCercles()
            changeVinclesUserPhotoInNavBar()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    func refreshFromBackGround() {
        performSelector(#selector(XarxesVC.reload), withObject: self, afterDelay: 1.5)
    }
    
    func reload() {
        if (userCercle.vincleSelected != nil){
            APIgetUserCercles()
            changeVinclesUserPhotoInNavBar()
        }
        tableView.reloadData()
    }
    
    func getVinclePhoto(idx:Int) -> String {
        
        if let _ = vincles[idx].photo {
            
            return vincles[idx].photo!
        }else{
            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            let photoData = UIImageJPEGRepresentation(xarxaImg!, 0.1)
            let bse64 = Utils().imageFromImgtoBase64(photoData!)

            return bse64
        }
    }
    
    func getDefaultPhoto() -> String {
        
        let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
        let photoData = UIImageJPEGRepresentation(xarxaImg!, 0.1)
        let bse64 = Utils().imageFromImgtoBase64(photoData!)
            
        return bse64
    }

    
    func setNavBar() {
        
        if self.revealViewController() != nil {
            menuBarBtn.target = self.revealViewController()
            menuBarBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let navBar = self.navigationController?.navigationBar
        navBar?.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        navBar?.translucent = false
        
        let viewNameLbl = UILabel(frame:CGRectMake(0,0,120,70))
        viewNameLbl.text = langBundle.localizedStringForKey("NET_NAVBAR_TITLE", value: nil, table: nil)
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
        
        var b64Photo = self.getDefaultPhoto()
        var imgData = Utils().imageFromBase64ToData(b64Photo)
        
        if (userCercle.vincleSelected != nil && vincleSelected >= 0){
            b64Photo = self.getVinclePhoto(vincleSelected)
            imgData = Utils().imageFromBase64ToData(b64Photo)
        }
        let xarxaImg = UIImage(data: imgData)
        currVincleImgView = UIImageView(frame: CGRectMake(0, 0, 40, 40))

        currVincleImgView.contentMode = .ScaleAspectFill
        currVincleImgView.image = xarxaImg
        navBar?.addSubview(currVincleImgView)
        
        currVincleImgView.layer.borderColor = UIColor.whiteColor().CGColor
        currVincleImgView.layer.borderWidth = 0.0
        currVincleImgView.layer.masksToBounds = false
        currVincleImgView.layer.cornerRadius = currVincleImgView.frame.size.height/2
        currVincleImgView.clipsToBounds = true
        
        let pinRight = NSLayoutConstraint(item: currVincleImgView, attribute: .Right,
                                          relatedBy: .Equal, toItem: navBar, attribute: .RightMargin,
                                          multiplier: 1.0, constant: -57)
        let pinTop = NSLayoutConstraint(item: currVincleImgView, attribute: .Top,
                                        relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                        multiplier: 1.0, constant: -9)
        let heightConst = NSLayoutConstraint(item: currVincleImgView, attribute: .Height,
                                             relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                             multiplier: 1, constant: 40)
        let widthConst = NSLayoutConstraint(item: currVincleImgView, attribute: .Width,
                                            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                            multiplier: 1, constant: 40)
        
        currVincleImgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinRight,pinTop,heightConst,widthConst])
    }
    
    func setUI() {

        newXarxaBtnTitle.text = langBundle.localizedStringForKey("BTN_NEW_NET", value: nil, table: nil)
        newXarxaBtn.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        newXarxaBtn.layer.cornerRadius = 4.0
        
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vincles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cellXarxa", forIndexPath: indexPath) as! XarxaTableViewCell
        cell.userXarxaName.text = "\(vincles[indexPath.row].alias!)"
        let b64Photo = self.getVinclePhoto(indexPath.row)
        let imgData = Utils().imageFromBase64ToData(b64Photo)
        let xarxaImg = UIImage(data: imgData)
        cell.userXarxaImg.image = xarxaImg
        cell.userXarxaImg.contentMode = .ScaleAspectFill
        cell.userXarxaImg.layer.borderColor = UIColor.clearColor().CGColor
        cell.userXarxaImg.layer.borderWidth = 0.0
        cell.userXarxaImg.layer.cornerRadius = cell.userXarxaImg.frame.size.height/2
        cell.userXarxaImg.clipsToBounds = true
        
        if vincleSelected == indexPath.row {
            cell.imgViewXarxaSelected.hidden = false
        } else {
            cell.imgViewXarxaSelected.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 85.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 60.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let customHeader = tableView.dequeueReusableCellWithIdentifier("customTitleHeaderCell") as! CustomTitleHeaderCell
        customHeader.headerTitleLbl.text = langBundle.localizedStringForKey("SELECT_NET_LABEL", value: nil, table: nil)
        customHeader.backgroundColor = UIColor(hexString: HEX_DARK_GRAY_HEADER)
        return customHeader
        
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if vincleSelected != indexPath.row {
            vincleSelected = indexPath.row
            let vincSelected = UserVincle.loadUserVinclesAtIndex(vincleSelected)
            
            userCercle.vincleSelected = vincSelected.id!
            UserCercle.saveUserCercleEntity(userCercle)
            changeVinclesUserPhotoInNavBar()
            
            tableView.reloadData()
        }
        return false
    }
    
    func APIgetUserCercles() {
        
        SVProgressHUD.show()
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let header = ["Authorization":"Bearer \(token!)"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,URL_CIRCLES_BELONG,headers:header, encoding:.JSON)
            
            .responseJSON { response in
                
                switch response.result {
                case .Success(let json):
                    print(response.response!.statusCode)
                    let vinclesApiCount = json.count!
                    
                    if vinclesApiCount == self.vincles.count {
                    }else{
                        if json.count! > 0 {
                            self.compareLocalModelWithBackend(json)
                            print("CAMBIOS USER ID = \(self.userCercle.id!)")
                        }else{
                            SVProgressHUD.dismiss()
                            self.vincles = []
                            UserVincle.deleteVincleEntity(0)
                            self.userCercle.vincleSelected = ""
                            UserCercle.saveUserCercleEntity(self.userCercle)
                            self.goToIntroCode()
                        }
                    }
                case .Failure(let error):
                    print(error)
                    if response.response?.statusCode != nil {
                        print("STATUS CODE = \(response.response!.statusCode) RESULT = \(error)")
                        
                        if response.response!.statusCode == 401 { // not logged
                            SVProgressHUD.dismiss()
                            VinclesApiManager().loginSelfUser(self.userCercle.username!, pwd: self.userCercle.password!, usrId: self.userCercle.id!)
                        }
                    }else{ // NO WIFI
                        SVProgressHUD.dismiss()
                        print("FAILURE RESPONSE RESULT \(response.result)")
                        self.showAlertController(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil),
                            msg:self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table:nil), act:self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil))
                    }
                }
                SVProgressHUD.dismiss()
        }
    }
    
    private func compareLocalModelWithBackend(json:AnyObject) {
        
        let vinclJson = JSON(json)
        var arryJSONUsername:[String] = []
        
        for r in 0 ..< vinclJson.count{
            arryJSONUsername.append(vinclJson[r]["circle"]["userVincles"]["username"].stringValue)
        }
        for i in 0 ..< vincles.count {
            if arryJSONUsername.contains(vincles[i].username!) {
            }else{
                print(" INDEX \(i) not present")
                deleteVincleFromList(i)
            }
        }
        vincles = []
        vincles = UserVincle.loadUserVincleCoreData()
        tableView.reloadData()
    }
    
    private func deleteVincleFromList(idx:Int) {
        
        switch idx {
        case vincleSelected:
            print("same as selected")
            if vincleSelected == 0 {
                UserVincle.deleteVincleEntity(idx)
                let idxVinc = UserVincle.loadUserVinclesAtIndex(vincleSelected)
                userCercle.vincleSelected = idxVinc.id!
                UserCercle.saveUserCercleEntity(userCercle)
                changeVinclesUserPhotoInNavBar()
            }else{
                vincleSelected = 0
                UserVincle.deleteVincleEntity(idx)
                let idxVinc = UserVincle.loadUserVinclesAtIndex(vincleSelected)
                userCercle.vincleSelected = idxVinc.id!
                UserCercle.saveUserCercleEntity(userCercle)
                changeVinclesUserPhotoInNavBar()
            }
        case let idx where idx < vincleSelected:
            print("idx less")
            UserVincle.deleteVincleEntity(idx)
            
            vincleSelected = vincleSelected - 1
        case let idx where idx > vincleSelected:
            print("idx more")
            UserVincle.deleteVincleEntity(idx)
        default:
            print("default")
        }
    }
    
    private func changeVinclesUserPhotoInNavBar() {
        if vincleSelected == 0 {
            let vincPhoto = self.getVinclePhoto(vincleSelected)
            let imgData = Utils().imageFromBase64ToData(vincPhoto)
            let xarxaImg = UIImage(data: imgData)
            currVincleImgView.image = xarxaImg
        } else if vincleSelected > 0 {
            let vincPhoto = self.getVinclePhoto(vincleSelected)
            let imgData = Utils().imageFromBase64ToData(vincPhoto)
            let xarxaImg = UIImage(data: imgData)
            currVincleImgView.image = xarxaImg
         }
    }
    
    private func showAlertController(title:String,msg:String,act:String) {
        
        let alert = UIAlertController(title: title, message:msg, preferredStyle: .Alert)
        let action = UIAlertAction(title:act, style: .Default) { _ in
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true){}
    }
    
    func goToIntroCode() {
        
        let introCode = storyboard?.instantiateViewControllerWithIdentifier("IntroCodeVC") as! IntroCodeViewController
        introCode.comesFrom = comeFromView.XarxesVC
        self.presentViewController(introCode, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromXarxes_IntroCode" {
            let vc = segue.destinationViewController as! IntroCodeViewController
            vc.comesFrom = comeFromView.XarxesVC
        }
        
        if segue.identifier == "fromXarxes_IntroSecondCode" {
            let vc = segue.destinationViewController as! IntroSecondCodeVC
            
        }
    }

    @IBAction func newXarxaBtnPressed(sender: UIButton) {
    
        performSegueWithIdentifier("fromXarxes_IntroSecondCode", sender: nil)
        
    }
    
    @IBAction func barCallBtnPress(sender: UIBarButtonItem) {
         if (userCercle.vincleSelected != nil && vincleSelected >= 0){
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
}
