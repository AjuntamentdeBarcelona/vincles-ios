/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class SobreVinclesVC: VinclesVC {

    @IBOutlet weak var menuBarBtn: UIBarButtonItem!
    @IBOutlet weak var sobreVinclesTextView: UITextView!
    
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


    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = SOBREVINCLES_VC
        if (userCercle.vincleSelected != nil) {
            vincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        getVinclePhoto()
        setNavBar()
        setUI()
    }
    
    
    func getVinclePhoto() {
        if (vincle != nil){
            if let _ = vincle.photo
            {
                let imgData = Utils().imageFromBase64ToData(self.vincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.xarxaImgView.image = xarxaImg
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
            menuBarBtn.target = self.revealViewController()
            menuBarBtn.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        let navBar = self.navigationController?.navigationBar
        
        let viewNameLbl = UILabel(frame:CGRectMake(0,0,180,70))
        viewNameLbl.text = "Sobre Vincles BCN"
        viewNameLbl.textColor = UIColor.whiteColor()
        viewNameLbl.font = UIFont(name: "Akkurat", size: 18)
        navBar?.addSubview(viewNameLbl)
        
        let pinLblLeft = NSLayoutConstraint(item: viewNameLbl, attribute: .Left,
                                            relatedBy: .Equal, toItem: navBar, attribute: .LeftMargin,
                                            multiplier: 1.0, constant: 53)
        let pinLblTop = NSLayoutConstraint(item: viewNameLbl, attribute: .Top,
                                           relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                           multiplier: 1.0, constant: -15)
        let heightLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Height,
                                                relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                                multiplier: 1, constant: 50)
        let widthLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Width,
                                               relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                               multiplier: 1, constant: 180)
        
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
        
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        sobreVinclesTextView.text = langBundle.localizedStringForKey("TEXT_BODY_SOBRE_VINCLES", value: nil, table: nil)
        
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            sobreVinclesTextView.text = sobreVinclesTextView.text + "\n" + langBundle.localizedStringForKey("VERSION_APP_SOBRE_VINCLES", value: nil, table: nil) + version
        }
        
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
