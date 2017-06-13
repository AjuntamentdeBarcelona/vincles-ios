/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class VideoTrucadaVC: VinclesVC {
    
    @IBOutlet weak var xarxaUserImageView: UIImageView!
    @IBOutlet weak var usrNameLabel: UILabel!
    @IBOutlet weak var trucarBtn: UIButton!
    @IBOutlet weak var trucarBtnTitle: UILabel!
    @IBOutlet weak var navBarBtnCall: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var footerView: UIView!
    
    
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var vincle:UserVincle!
    var xarxaImgView:UIImageView = {
        return UIImageView(frame: CGRectMake(0, 0, 40, 40))
    }()
    
    func tryAgain()
    {
        self.trucataBtnPress(self.trucarBtn)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        screenName = VIDEOTRUCADA_VC
        if (userCercle.vincleSelected != nil) {
            vincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        loadUserVincle()
        setUI()
        setNavBar()
        
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoTrucadaVC.tryAgain), name: NOTI_TRUCANT_TRYAGAIN, object: nil)
    }
	
    func loadUserVincle() {
        if (userCercle.vincleSelected != nil) {
            vincle = UserVincle.loadUserVincleWithID(SingletonVars.sharedInstance.idUserCall)
                ?? UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
            
        }
        getVinclePhoto()
    }
    
    func getVinclePhoto() {
        if (vincle != nil){
            if let _ = vincle.photo
            {
                let imgData = Utils().imageFromBase64ToData(self.vincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.xarxaImgView.image = xarxaImg
                    self.xarxaUserImageView.image = xarxaImg
                    print("IMAGE ADDED")
                })
            }
            else
            {
                Utils().retrieveUserVinclesProfilePhoto(vincle, completion: { (result, imgB64) in
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)

                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.xarxaImgView.image = xarxaImg
                        self.xarxaUserImageView.image = xarxaImg
                    })
                })
            }
        }
        else{
            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            self.xarxaUserImageView.image = xarxaImg
            self.xarxaImgView.image = xarxaImg
        }
        
    }

    
    func setNavBar()
    {
        
        if self.revealViewController() != nil
        {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let navBar = self.navigationController?.navigationBar
        navBar?.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        
        let viewNameLbl = UILabel(frame:CGRectMake(0,0,150,70))
        viewNameLbl.text = langBundle.localizedStringForKey("VIDEOCALL_NAVBAR_TITLE", value: nil, table: nil)
        viewNameLbl.textColor = UIColor.whiteColor()
        viewNameLbl.font = UIFont(name: "Akkurat", size: 19)
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
        
        dispatch_async(dispatch_get_main_queue(), {
            self.xarxaUserImageView.layer.borderWidth = 10.0
            self.xarxaUserImageView.layer.borderColor = UIColor.whiteColor().CGColor
            self.xarxaUserImageView.layer.masksToBounds = false
            self.xarxaUserImageView.layer.cornerRadius = self.xarxaUserImageView.frame.size.height/2
            self.xarxaUserImageView.clipsToBounds = true
            
            self.trucarBtn.layer.cornerRadius = 4.0
            self.trucarBtn.backgroundColor = UIColor(hexString: HEX_RED_BTN)
            self.trucarBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -45)
            self.trucarBtnTitle.text = self.langBundle.localizedStringForKey("BTN_CALL", value: nil, table: nil)
            
            if(self.userCercle.vincleSelected != nil){
                self.usrNameLabel.text = "\(self.vincle.name!) \(self.vincle.lastname!)"
            }else{
                
                self.usrNameLabel.text = self.langBundle.localizedStringForKey("NO_USERS", value: nil, table: nil)
            }
            
            self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
            self.footerView.backgroundColor = UIColor(hexString: HEX_DARK_BACK_FOOTER)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "fromVideoTrucada_TrucantVC"
        {
            let destinaVC = segue.destinationViewController as! TrucantVC
            
            destinaVC.roomName = Utils().createRoomName(vincle.id!, callee: userCercle.id!)
            destinaVC.userName = userCercle.id!
        }
    }

    @IBAction func trucataBtnPress(sender: UIButton)
    {
        if (userCercle.vincleSelected != nil){
            self.performSegueWithIdentifier("fromVideoTrucada_TrucantVC", sender: nil)
        }
        else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_USERS_MESSAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func videoCallBarBtnPress(sender: UIBarButtonItem)
    {
        if (userCercle.vincleSelected != nil){
            self.performSegueWithIdentifier("fromVideoTrucada_TrucantVC", sender: nil)

        }
        else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_USERS_MESSAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
}
