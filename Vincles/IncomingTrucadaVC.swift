/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import AVFoundation

class IncomingTrucadaVC: VinclesVC {

    
    @IBOutlet weak var xarxaUserImageView: UIImageView!
    @IBOutlet weak var usrNameCallLabel: UILabel!
    
    var ringTone : AVAudioPlayer?
    
    let langBundle:NSBundle = {
        
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var vincle:UserVincle!
    var callee:String!
    var room:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = INCOMINTRUCADA_VC
        SingletonVars.sharedInstance.idRoomCall = room
        SingletonVars.sharedInstance.idUserCall = userCercle.id!
        
        vincle = UserVincle.loadUserVincleWithID(callee)
        NSTimer.scheduledTimerWithTimeInterval(CALL_WAIT_LIMIT, target: self, selector: #selector(waitTimeLimitReached), userInfo: nil, repeats: false)
        SingletonVars.sharedInstance.callInProgress = true
        
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {

        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)

        var audioPlayer:AVAudioPlayer?

        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    func createLostCallInitFeed() {
        
        let params:[String:AnyObject] = ["date":Utils().getCurrentLocalDate(),
                                         "type":INIT_CELL_LOST_CALL,
                                         "idUsrVincles":callee,
                                         "isRead":false]
        InitFeed.addNewFeedEntityOffline(params)
    }

    func waitTimeLimitReached() {
        
            // lost call Init Feed
            if self.view.window != nil {
                createLostCallInitFeed()
                SingletonVars.sharedInstance.callInProgress = false
               self.dismissViewControllerAnimated(true, completion: nil)
                
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        setUI()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    func setUI() {
        
        dispatch_async(dispatch_get_main_queue(), {

            let imgData = Utils().imageFromBase64ToData(self.vincle.photo!)
            let userImg = UIImage(data:imgData)
            self.xarxaUserImageView.image = userImg!
            self.xarxaUserImageView.layer.borderWidth = 1.0
            self.xarxaUserImageView.layer.borderColor = UIColor.whiteColor().CGColor
            self.xarxaUserImageView.layer.masksToBounds = false
            self.xarxaUserImageView.layer.cornerRadius = self.xarxaUserImageView.frame.size.height/2
            self.xarxaUserImageView.clipsToBounds = true
            
            self.usrNameCallLabel.text = "\(self.vincle.name!) \(self.langBundle.localizedStringForKey("TEXT_IS_CALLING", value: nil, table: nil))"
            
            UIView.animateWithDuration(1.5, delay: 0.2,options:[.Repeat, .Autoreverse], animations: { () -> Void in
                let scaleTransform = CGAffineTransformMakeScale(1.3, 1.3)
                
                self.xarxaUserImageView.transform = scaleTransform
            },completion: nil)
            
            // ring tone
            if let backgroundMusic = self.setupAudioPlayerWithFile("HallOfTheMountainKing", type:"mp3") {
                self.ringTone = backgroundMusic
                self.ringTone?.volume = 0.3
                self.ringTone?.play()
            }
        })
    }
    

    @IBAction func btnPress(sender: UIButton) {
        self.ringTone?.stop()
        
        if sender.tag == 0 {
            // DISMISS CALL
            SingletonVars.sharedInstance.callInProgress = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            // TAKE CALL
            if let roomNameValue: String = usrNameCallLabel.text!{
                if !roomNameValue.isEmpty{
                    if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                        SingletonVars.sharedInstance.initMenuHasToChange = true
                        SingletonVars.sharedInstance.initDestination = .Trucant
                        SingletonVars.sharedInstance.isCaller = false;
                        self.presentViewController(secondViewController, animated: true, completion: {
                    
                        })
                    }
                }
            }
        }
    }
}
