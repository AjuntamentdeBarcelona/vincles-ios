/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import AVFoundation
import SVProgressHUD

class MsgAudioReadVC: VinclesVC {
    
    @IBOutlet weak var msgDateLabel: UILabel!
    @IBOutlet weak var msgTimeLabel: UILabel!
    @IBOutlet weak var backNavBarBtn: UIBarButtonItem!
    @IBOutlet weak var playPauseAudioBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var playedTime: UILabel!
    @IBOutlet weak var audioTrackProgressView: UIProgressView!
    @IBOutlet weak var downContentBtn: UIButton!
    
    var missatge:Missatges!
    var audioPlayer = AVAudioPlayer()
    var isPlaying = false
    var timer:NSTimer!
    var audioFilePath:NSURL?
    var contentID:String!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()

    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = MSGAUDIOREAD_VC
        setUI()
        getContentID()
    }
    
    override func viewWillDisappear(animated: Bool) {
    
        if checkIfContentExists(contentID).0 == true {
            if audioPlayer.playing {
                audioPlayer.stop()
            }
        }
        SVProgressHUD.dismiss()
    }

    func setAudio() {
        
        let path = NSURL(fileURLWithPath:audioFilePath!.path!)
        do{
            audioPlayer = try AVAudioPlayer(contentsOfURL:path)
            audioPlayer.prepareToPlay()
        }catch {
            print("Error getting the audio file")
        }
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
            }
        }
    }
    
    func checkIfContentExists(contentID:String) -> (Bool,NSURL?) {
        
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
                                                                                       inDomain: .UserDomainMask,
                                                                                       appropriateForURL: nil,
                                                                                       create: true)
        let contentURL = documentDirectoryURL.URLByAppendingPathComponent("\(contentID).ac3")
        
        var error : NSError?
        let fileExists = contentURL!.checkResourceIsReachableAndReturnError(&error)
        
        if !fileExists {
            return (false,nil)
        }else{
            return (true,contentURL)
        }
    }

    
    func getMsgContent(contentID:Int) {
        
        VinclesApiManager.sharedInstance.getContent(
            contentID, completion: { binaryURL, result in
                
                if result == "SUCCESS" {
                    self.showMsgContentWithURL(binaryURL!)
                    self.saveAudioToLocalDirectory(String(contentID), nsurl: binaryURL!)
                }
                if result == "FAILURE" {
                    SVProgressHUD.dismiss()
                    self.downContentBtn.hidden = false
                    Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ERROR_PHOTO_DOWNLOAD", value: nil, table: nil))
                }
        })
    }
    
    func showMsgContentWithURL(nsurl:NSURL) {
        
        self.audioFilePath = nsurl
        self.setAudio()
    }
    
    func saveAudioToLocalDirectory(contentID:String, nsurl:NSURL) {
        
        let data = NSData(contentsOfURL:nsurl)
        let filename = Utils().getDocumentsDirectory().stringByAppendingPathComponent("\(contentID).ac3")
        data!.writeToFile(filename, atomically: true)
        
        SVProgressHUD.dismiss()
    }

    @IBAction func backNavBarBtnPress(sender: UIBarButtonItem) {
        
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
    
    @IBAction func playPauseBtnPress(sender: UIButton) {
        
        if audioFilePath != nil {
            audioPlayer.play()
            isPlaying = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(MsgAudioReadVC.updateTime), userInfo: nil, repeats: true)
            
            pauseBtn.hidden = false
            playPauseAudioBtn.hidden = true
        }
    }
    
    @IBAction func pauseButtonPress(sender: UIButton) {
        
        audioPlayer.pause()
        isPlaying = false
        
        pauseBtn.hidden = true
        playPauseAudioBtn.hidden = false
    }
    
    @IBAction func downContentBtn(sender: UIButton) {
        downContentBtn.hidden = true
        getMsgContent(Int(contentID)!)
    }
    
    @IBAction func navCallBtnPress(sender: UIBarButtonItem) {
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Trucant
            SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
            self.presentViewController(secondViewController, animated: true, completion:nil)
        }
    }
    
    func updateTime() {
        
        let currentTime = Int(audioPlayer.currentTime)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        
        if audioPlayer.playing
        {
            // Update progress
            audioTrackProgressView.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: false)
            
            playedTime.text = NSString(format: "%02d:%02d", minutes,seconds) as String
        } else {
            
            if minutes == 0 && seconds == 0 {
                audioTrackProgressView.setProgress(0.0, animated: false)
            }
            
            isPlaying = false
            
            playPauseAudioBtn.hidden = false
            pauseBtn.hidden = true
        }
    }
    
    func setUI() {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        msgDateLabel.text = dateFormatter.stringFromDate(missatge.sendTime!)
        msgTimeLabel.text = hourFormatter.stringFromDate(missatge.sendTime!)
        
        pauseBtn.hidden = true
    }
}
