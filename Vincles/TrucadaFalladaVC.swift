/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit


class TrucadaFalladaVC: VinclesVC {
    
    @IBOutlet weak var navBarBackBtn: UIBarButtonItem!
    @IBOutlet weak var xarxaUserImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var trucarBtn: UIButton!
    @IBOutlet weak var trucarBtnLbl: UILabel!
    @IBOutlet weak var enviarMsgBtn: UIButton!
    @IBOutlet weak var enviarMsgBtnLbl: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var backView: UIView!
    
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var vincle:UserVincle!
    
	
    func backToTrucant()
    {
		self.navigationController?.popToRootViewControllerAnimated(true)
		NSNotificationCenter.defaultCenter().postNotificationName(NOTI_TRUCANT_TRYAGAIN, object: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = TRUCADAFALLADA_VC
        if (userCercle.vincleSelected != nil) {
            vincle = UserVincle.loadUserVincleWithID(SingletonVars.sharedInstance.idUserCall)
                ?? UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)

        }
        
        getVinclePhoto()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if (userCercle.vincleSelected != nil && vincle == nil)
        {
            vincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        setUI()
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
            self.trucarBtn.tag = 0
            self.trucarBtnLbl.text = self.langBundle.localizedStringForKey("BTN_RE_CALL", value: nil, table: nil)
            
            self.enviarMsgBtn.layer.cornerRadius = 4.0
            self.enviarMsgBtn.backgroundColor = UIColor(hexString: HEX_GRAY_BTN)
            self.enviarMsgBtn.tag = 1
            self.enviarMsgBtnLbl.text = self.langBundle.localizedStringForKey("BTN_SEND_MESSAGE_VIDEOCALL", value: nil, table: nil)
            let infoTextBody = self.langBundle.localizedStringForKey("VIDEOCALL_FAIL_INFO_TEXT", value: nil, table: nil)
            self.infoLabel.text = "\(self.vincle.name!) \(infoTextBody)"
            
            self.footerView.backgroundColor = UIColor(hexString: HEX_DARK_BACK_FOOTER)
            self.backView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
            
            self.navigationItem.rightBarButtonItem!.enabled = false
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        })
    }
    
    @IBAction func btnPress(sender: UIButton) {
        
        if sender.tag == 0
        {
			self.backToTrucant()
        }
        else if sender.tag == 1
        {
            
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController
            {
                SingletonVars.sharedInstance.initMenuHasToChange = true
                SingletonVars.sharedInstance.initDestination = .CrearMensajes
                self.presentViewController(secondViewController, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func navBarBackBtnPress(sender: UIBarButtonItem)
    {
		dispatch_async(dispatch_get_main_queue(), {
			self.navigationController?.popToRootViewControllerAnimated(true)
		})
    }
    
    @IBAction func navBarCallBtnPress(sender: UIBarButtonItem)
    {
		self.backToTrucant()
    }
    
    func getVinclePhoto() {
        
        if let _ = vincle.photo {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let imgData = Utils().imageFromBase64ToData(self.vincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                self.xarxaUserImageView.image = xarxaImg
                print("IMAGE ADDED")
            })
        }
        else
        {
            Utils().retrieveUserVinclesProfilePhoto(vincle, completion: { (result, imgB64) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    self.xarxaUserImageView.image = xarxaImg
                })
            })
        }
    }
    
	
}
