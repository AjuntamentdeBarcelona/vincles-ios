/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD
import AVFoundation
import AVKit

class MsgVideoReadVC: VinclesVC,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var downContentBtn: UIButton!
    @IBOutlet weak var navBackBtn: UIBarButtonItem!
    @IBOutlet weak var msgDateTitle: UILabel!
    @IBOutlet weak var msgTimeTitle: UILabel!
    @IBOutlet weak var playVideoBtn: UIButton!
    
    var missatge:Missatges!
    var videoPath:NSURL?
    var contentID:String!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = MSGVIDEOREAD_VC
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
        }else{
            let nsusr = NSUserDefaults.standardUserDefaults()
            let downL = nsusr.valueForKey("download") as! [NSString:Int]
            
            if downL["downloadAttach"] == 0 {
                getMsgContent(contID)
            }else{
                downContentBtn.backgroundColor = UIColor.clearColor()
                downContentBtn.hidden = false
                playVideoBtn.hidden = true
            }
        }
    }
    
    func checkIfContentExists(contentID:String) -> (Bool,NSURL?) {
        
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
                                                                                       inDomain: .UserDomainMask,
                                                                                       appropriateForURL: nil,
                                                                                       create: true)
        let contentURL = documentDirectoryURL.URLByAppendingPathComponent("\(contentID).mp4")
        print("URL EXISTS? \(contentURL)")
        
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
                    print("GET URL FROM API \(binaryURL)")
                    self.showMsgContentWithURL(binaryURL!)
                    self.saveVideoToLocalDirectory(String(contentID), nsurl: binaryURL!)
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
        
        self.videoPath = nsurl
        self.playVideoBtn.hidden = false
            SVProgressHUD.dismiss()
        })
    }
    
    func saveVideoToLocalDirectory(contentID:String, nsurl:NSURL) {
        
        let data = NSData(contentsOfURL:nsurl)
        let filename = Utils().getDocumentsDirectory().stringByAppendingPathComponent("\(contentID).mp4")
        data!.writeToFile(filename, atomically: true)
    }
    
    @IBAction func navBarBackBtnPress(sender: UIBarButtonItem) {
        
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
    
    func setUI() {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        msgDateTitle.text = dateFormatter.stringFromDate(missatge.sendTime!)
        msgTimeTitle.text = hourFormatter.stringFromDate(missatge.sendTime!)
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
    }
    
    @IBAction func playBtnPress(sender: UIButton) {
        
        if videoPath != nil {
            let videoAsset = (AVAsset(URL: NSURL(fileURLWithPath: videoPath!.path!)))
            let playerItem = AVPlayerItem(asset: videoAsset)
            // Play video
            let player = AVPlayer(playerItem: playerItem)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            self.presentViewController(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    @IBAction func downContentBtnPress(sender: UIButton) {
        downContentBtn.hidden = true
        getMsgContent(Int(contentID)!)
        playVideoBtn.hidden = false
    }
    
    @IBAction func navCallBtnPress(sender: UIBarButtonItem) {
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Trucant
            SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
            self.presentViewController(secondViewController, animated: true, completion:nil)
        }
    }
    
}
