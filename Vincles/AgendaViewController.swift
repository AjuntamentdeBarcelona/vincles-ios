/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD
import SwiftyJSON
import CoreData


class AgendaViewController: VinclesVC {
    
    
    @IBOutlet weak var pagesView: SwiftPages!
    @IBOutlet weak var menuNavButton: UIBarButtonItem!
    
    @IBOutlet weak var novaCitaBtn: UIButton!
    @IBOutlet weak var novaCitaBtnLabel: UILabel!
    
    var VCIDs = ["AvuiVC","DemaVC","MesVC"]
    var buttonTitles:[String] = []
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var usrVincle:UserVincle!
    
    var xarxaImgView:UIImageView = {
        
        return UIImageView(frame: CGRectMake(0, 0, 40, 40))
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = AGENDA_VC
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        getVinclePhoto()
        
        buttonTitles = [langBundle.localizedStringForKey("AGENDA_TODAY_LABEL", value: nil, table: nil),langBundle.localizedStringForKey("AGENDA_TOMORROW_LABEL", value: nil, table: nil),langBundle.localizedStringForKey("AGENDA_MONTH_LABEL", value: nil, table: nil)]
        
        if (userCercle.username != nil){
            VinclesApiManager().loginSelfUser(self.userCercle.username!, pwd: self.userCercle.password!, usrId: self.userCercle.id!)
        }
        
        setNavBar()
        setPages()
        setUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        novaCitaBtn.layer.cornerRadius = 4.0

        pagesView.scrollView.panGestureRecognizer.enabled = false
        
        // check if device calendar is sync
        EventStore.requestAccess() { (granted, error) in
            if !granted {
                UserPreferences().changeCalendarSyncPrefs(1)
                print("NOT GRANTED")
            }else{
                UserPreferences().changeCalendarSyncPrefs(0)
                print("GRANTED")
            }
        }
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        SVProgressHUD.dismiss()
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
            menuNavButton.target = self.revealViewController()
            menuNavButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        let navBar = self.navigationController?.navigationBar
        navBar?.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        navBar?.translucent = false
        
        let viewNameLbl = UILabel(frame:CGRectMake(0,0,150,70))
        viewNameLbl.text = langBundle.localizedStringForKey("AGENDA_NAVBAR_TITLE", value:nil, table:nil)
        viewNameLbl.textColor = UIColor.whiteColor()
        viewNameLbl.font = UIFont(name: "Akkurat", size: 20)
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
                                               multiplier: 1, constant: 150)
        
        viewNameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinLblLeft,pinLblTop,heightLblConst,widthLblConst])
        
        //  NavBar
 
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
    
    func setPages() {
        
        automaticallyAdjustsScrollViewInsets = false
        pagesView.setOriginY(0.0)
        pagesView.setOriginX(0.0)
        pagesView.setAnimatedBarColor(UIColor.redColor())
        pagesView.setContainerViewBackground(UIColor.whiteColor())
        pagesView.setButtonsTextColor(UIColor.whiteColor())
        pagesView.setTopBarBackground(UIColor.darkGrayColor())
        pagesView.setAnimatedBarHeight(7)
        
        pagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
        
    }
    
    func setUI() {
        
        novaCitaBtnLabel.text = langBundle.localizedStringForKey("BTN_NEW_APPOINTMENT_AGENDA", value: nil, table: nil)

    }
    
    @IBAction func novaCitaBtnPress(sender: UIButton) {
        
        performSegueWithIdentifier("fromAgenda_novaCita", sender: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (userCercle.vincleSelected != nil){
            if segue.identifier == "fromAgenda_novaCita" {
                let vc = segue.destinationViewController as! NovaCitaVC
                vc.isEditingCita = false
            }
        }
        else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_USERS_MESSAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
