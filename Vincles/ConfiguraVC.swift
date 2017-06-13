/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import CoreData

class ConfiguraVC: VinclesVC,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var menuNavBtn: UIBarButtonItem!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var canviaPhotoBtn: UIButton!
    @IBOutlet weak var nomLabel: UILabel!
    @IBOutlet weak var cognomLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var telefLabel: UILabel!
    @IBOutlet weak var residentBcnLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var baseView: UIView!
    
    var barTitleLbl:UILabel!
    
    var userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var usrVincle:UserVincle!
    
    var langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var xarxaImgView:UIImageView = {
        return UIImageView(frame: CGRectMake(0, 0, 40, 40))
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = CONFIGURA_VC
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        getVinclePhoto()
        getUserPhoto()
        setUI()
        setNavBar()

    }
    
    func getUserPhoto() {
    
        if userCercle.fotoPerfil != nil{
            
            userPhotoImageView.image = UIImage(data: userCercle.fotoPerfil!)
            userPhotoImageView.layer.borderWidth = 2.0
            userPhotoImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            userPhotoImageView.layer.masksToBounds = false
            userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.size.height/2
            userPhotoImageView.clipsToBounds = true
        }
        else {
            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            self.userPhotoImageView.image = xarxaImg
            userPhotoImageView.layer.borderWidth = 2.0
            userPhotoImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            userPhotoImageView.layer.masksToBounds = false
            userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.size.height/2
            userPhotoImageView.clipsToBounds = true
        }
    }
    
    
    func getVinclePhoto() {
        if (usrVincle != nil){
            if let _ = usrVincle.photo
            {
                let imgData = Utils().imageFromBase64ToData(self.usrVincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.xarxaImgView.image = xarxaImg
                    print("IMAGE ADDED")
                })
            }
            else
            {
                Utils().retrieveUserVinclesProfilePhoto(usrVincle, completion: { (result, imgB64) in
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.xarxaImgView.image = xarxaImg
                    })
                })
            }
        }
        else{
            
            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            self.xarxaImgView.image = xarxaImg
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
        
        barTitleLbl = UILabel(frame:CGRectMake(0,0,150,70))
        barTitleLbl.text = langBundle.localizedStringForKey("CONFIGURATION_NAVBAR_TITLE", value: nil, table: nil)
        barTitleLbl.textColor = UIColor.whiteColor()
        barTitleLbl.font = UIFont(name: "Akkurat", size: 20)
        navBar?.addSubview(barTitleLbl)
        
        let pinLblLeft = NSLayoutConstraint(item: barTitleLbl, attribute: .Left,
                                            relatedBy: .Equal, toItem: navBar, attribute: .LeftMargin,
                                            multiplier: 1.0, constant: 63)
        let pinLblTop = NSLayoutConstraint(item: barTitleLbl, attribute: .Top,
                                           relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                           multiplier: 1.0, constant: -15)
        let heightLblConst = NSLayoutConstraint(item: barTitleLbl, attribute: .Height,
                                                relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                                multiplier: 1, constant: 50)
        let widthLblConst = NSLayoutConstraint(item: barTitleLbl, attribute: .Width,
                                               relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                               multiplier: 1, constant: 150)
        
        barTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinLblLeft,pinLblTop,heightLblConst,widthLblConst])
        
        
        xarxaImgView.contentMode = .ScaleAspectFill
        navBar?.addSubview(xarxaImgView)
        
        xarxaImgView.layer.borderColor = UIColor.whiteColor().CGColor
        xarxaImgView.layer.borderWidth = 0.0
        xarxaImgView.layer.masksToBounds = false
        xarxaImgView.layer.cornerRadius = xarxaImgView.frame.size.height/2
        xarxaImgView.clipsToBounds = true
        
        let pinRight = NSLayoutConstraint(item: xarxaImgView, attribute: .Right,
                                          relatedBy: .Equal, toItem: navBar, attribute: .RightMargin,
                                          multiplier: 1.0, constant: -57)
        let pinTop = NSLayoutConstraint(item: xarxaImgView, attribute: .Top,
                                        relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                        multiplier: 1.0, constant: -9)
        let heightConst = NSLayoutConstraint(item: xarxaImgView, attribute: .Height,
                                             relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                             multiplier: 1, constant: 40)
        let widthConst = NSLayoutConstraint(item: xarxaImgView, attribute: .Width,
                                            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                            multiplier: 1, constant: 40)
        
        xarxaImgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinRight,pinTop,heightConst,widthConst])
 
    }
    
    func setUI() {
        
        baseView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        tableView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        canviaPhotoBtn.setTitle(langBundle.localizedStringForKey("BTN_CHANGE_PHOTO", value: nil, table: nil), forState: .Normal)
        nomLabel.text = userCercle.nom!
        cognomLabel.text = userCercle.cognom!
        mailLabel.text = userCercle.mail!
        telefLabel.text = userCercle.telefon!
        if userCercle.viusBcn! == 0 {
            residentBcnLabel.text = langBundle.localizedStringForKey("USER_FROM_BCN_YES", value: nil, table: nil)
        }else{
            residentBcnLabel.text = langBundle.localizedStringForKey("USER_FROM_BCN_NO", value: nil, table: nil)
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nsusrSettings = NSUserDefaults.standardUserDefaults()
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("confiSegmCell", forIndexPath: indexPath) as! ConfiguraSegmTableViewCell
            cell.delegate = self
            
            cell.titleLblSetting.text = langBundle.localizedStringForKey("CELL_TITLE_LANGUAGE", value: nil, table: nil)
            cell.segmentconfi.setTitle(langBundle.localizedStringForKey("SEGMENT_LANGUAGE_POS_0", value: nil, table: nil), forSegmentAtIndex: 0)
            cell.segmentconfi.setTitle(langBundle.localizedStringForKey("SEGMENT_LANGUAGE_POS_1", value: nil, table: nil), forSegmentAtIndex: 1)
            cell.segmentconfi.tag = indexPath.row
            
            let dict = nsusrSettings.valueForKey("language") as! [NSString:Int]
            cell.segmentconfi.selectedSegmentIndex = dict["CatCast"]! as Int
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("confiSegmCell", forIndexPath: indexPath) as! ConfiguraSegmTableViewCell

            cell.titleLblSetting.text = langBundle.localizedStringForKey("CELL_TITLE_ALLOW_DOWNLOADS", value: nil, table: nil)
            cell.segmentconfi.setTitle(langBundle.localizedStringForKey("SEGMENT_POS_YES", value: nil, table: nil), forSegmentAtIndex: 0)
            cell.segmentconfi.setTitle(langBundle.localizedStringForKey("SEGMENT_POS_NO", value: nil, table: nil), forSegmentAtIndex: 1)
            cell.segmentconfi.tag = indexPath.row
            
            let dict = nsusrSettings.valueForKey("download") as! [NSString:Int]
            cell.segmentconfi.selectedSegmentIndex = dict["downloadAttach"]! as Int

            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("confiSegmCell", forIndexPath: indexPath) as! ConfiguraSegmTableViewCell
            cell.delegate = self
            cell.titleLblSetting.text = langBundle.localizedStringForKey("CELL_TITLE_SINCRO_CALENDAR", value: nil, table: nil)
            cell.segmentconfi.setTitle(langBundle.localizedStringForKey("SEGMENT_POS_YES", value: nil, table: nil), forSegmentAtIndex: 0)
            cell.segmentconfi.setTitle(langBundle.localizedStringForKey("SEGMENT_POS_NO", value: nil, table: nil), forSegmentAtIndex: 1)
            cell.segmentconfi.tag = indexPath.row
            
            let dict = nsusrSettings.valueForKey("calendar") as! [NSString:Int]
            cell.segmentconfi.selectedSegmentIndex = dict["syncCalendar"]! as Int
    
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("confiSegmCell", forIndexPath: indexPath) as! ConfiguraSegmTableViewCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 81.0
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        userPhotoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        saveNewImg(userPhotoImageView.image!)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveNewImg(img:UIImage) {
        
        let photoData = UIImageJPEGRepresentation(img, 0.1)
        userCercle.fotoPerfil = photoData
        
        UserCercle.saveUserCercleEntity(userCercle)
        
        VinclesApiManager.sharedInstance.setMyProfilePhoto(userCercle.fotoPerfil!) { (result) in
            
            if result == SUCCESS {
                print("UPDATE PHOTO SUCCESS")
            }else{
                print("UPDATE PHOTO FAILURE")
            }
        }
    }
    
    @IBAction func canviPhotoPressed(sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func navCallBtnPress(sender: UIBarButtonItem) {
        
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
}

extension ConfiguraVC: ConfiguraVCDelegate {
    func changeLanguageOnTouch(sender:ConfiguraSegmTableViewCell) {
        
        langBundle = UserPreferences().bundleForLanguageSelected()
        canviaPhotoBtn.setTitle(langBundle.localizedStringForKey("BTN_CHANGE_PHOTO", value: nil, table: nil), forState: .Normal)
        barTitleLbl.text = langBundle.localizedStringForKey("CONFIGURATION_NAVBAR_TITLE", value: nil, table: nil)
        if userCercle.viusBcn! == 0 {
            residentBcnLabel.text = langBundle.localizedStringForKey("USER_FROM_BCN_YES", value: nil, table: nil)
        }else{
            residentBcnLabel.text = langBundle.localizedStringForKey("USER_FROM_BCN_NO", value: nil, table: nil)
        }
        self.tableView.reloadData()
    }
    
    func presentSettingsAlert(sender:ConfiguraSegmTableViewCell) {
        
        let alertController = UIAlertController (title: self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("CALENDAR_SETTINGS", value: nil, table: nil), preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().openURL(url)
                    })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (_) -> Void in
            self.tableView.reloadData()
        }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
            self.presentViewController(alertController, animated: true, completion: nil)

    }
}
