/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD

class MsgFotoRead: VinclesVC {
    
    @IBOutlet weak var navBackBtn: UIBarButtonItem!
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet weak var msgDateLabel: UILabel!
    @IBOutlet weak var msgTimeLabel: UILabel!
    @IBOutlet weak var downContentBtn: UIButton!
    
    var missatge:Missatges!
    var contentID:String!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()

    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = MSGFOTOREAD_VC
        getContentID()
        setUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        SVProgressHUD.dismiss()
    }
    
    func getContentID() {
        
        let arryMess = NSKeyedUnarchiver.unarchiveObjectWithData(missatge.idAdjuntContents!)
        let contID = arryMess!.objectAtIndex(0) as! Int
        contentID = String(contID)
        
        if checkIfContentExists(String(contID)).0 == true {
            let nsurl = checkIfContentExists(String(contID)).1
            showMsgContentWithURL(nsurl!)
        } else {
            let nsusr = NSUserDefaults.standardUserDefaults()
            let downL = nsusr.valueForKey("download") as! [NSString:Int]
            
            if downL["downloadAttach"] == 0 {
                getMsgContent(contID)
            } else {
                downContentBtn.backgroundColor = UIColor.clearColor()
                downContentBtn.hidden = false
            }
        }
    }
    
    func checkIfContentExists(contentID:String) -> (Bool,NSURL?) {
        
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
                                                                                       inDomain: .UserDomainMask,
                                                                                       appropriateForURL: nil,
                                                                                       create: true)
        let contentURL = documentDirectoryURL.URLByAppendingPathComponent("\(contentID).jpeg")
        
        var error : NSError?
        let fileExists = contentURL!.checkResourceIsReachableAndReturnError(&error)
        
        if !fileExists {
            return (false,nil)
        }else{
            return (true,contentURL)
        }
    }
    
    func getMsgContent(contentID:Int) {
        
        SVProgressHUD.show()
        
        VinclesApiManager.sharedInstance.getContent(
            contentID, completion: { binaryURL, result in
                
                if result == "SUCCESS" {
                    self.showMsgContentWithURL(binaryURL!)
                    self.savePhotoToLocalDirectory(String(contentID), nsurl: binaryURL!)
                }
                if result == "FAILURE" {
                    SVProgressHUD.dismiss()
                    self.downContentBtn.hidden = false
                    Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ERROR_PHOTO_DOWNLOAD", value: nil, table: nil))
                }
        })
    }
    
    func showMsgContentWithURL(nsurl:NSURL) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let data = NSData(contentsOfURL: nsurl)
            let img = UIImage(data: data! as NSData)
            self.msgImageView.image = img!
            SVProgressHUD.dismiss()
        })
    }
    
    func savePhotoToLocalDirectory(contentID:String, nsurl:NSURL) {
        
        let data = NSData(contentsOfURL:nsurl)
        let filename = Utils().getDocumentsDirectory().stringByAppendingPathComponent("\(contentID).jpeg")
        data!.writeToFile(filename, atomically: true)
    }
    
    func setUI() {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        
        msgDateLabel.text = dateFormatter.stringFromDate(missatge.sendTime!)
        msgTimeLabel.text = hourFormatter.stringFromDate(missatge.sendTime!)
        msgImageView.clipsToBounds = true
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
    }
    
    @IBAction func navBackPress(sender: UIBarButtonItem) {
        
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKindOfClass(InicioTableViewController) {
                    let initVC = viewController as! InicioTableViewController
                    initVC.viewNameLbl.text = initVC.langBundle.localizedStringForKey("INIT_NAVBAR_TITLE", value: nil, table: nil)
                }
            }
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func downBtnPress(sender: UIButton) {
        downContentBtn.hidden = true
        getMsgContent(Int(contentID)!)
    }
    
    @IBAction func phoneBarBtnPress(sender: UIBarButtonItem) {
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Trucant
            SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
            self.presentViewController(secondViewController, animated: true, completion:nil)
        }
    }
}
