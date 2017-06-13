/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import AVFoundation



class TrucantVC: VinclesVC, ARDAppClientDelegate, RTCEAGLVideoViewDelegate
{
    
    enum CallState {
        case INCOMING,CALLING,CONNECTED,VIDEOCONFERENCE,UNACTIVE,FINISHED;
    }

    @IBOutlet weak var localViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var localViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navBackBtn: UIBarButtonItem!
    @IBOutlet weak var vincleCalledImageView: UIImageView!
    @IBOutlet weak var wizardStepImageView: UIImageView!
    @IBOutlet weak var penjarBtn: UIButton!
    @IBOutlet weak var penjarBtnTitle: UILabel!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var RTCView: UIView!
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    
    var userName:String!
    var roomName:String!
    var isCaller = SingletonVars.sharedInstance.isCaller
    
    var client: ARDAppClient?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    
    var status:CallState! = .UNACTIVE
    var myTimer : NSTimer? = NSTimer()
    var wasLostCall:Bool! = false
    
    // INCOMING CALL VARS
    @IBOutlet weak var xarxaUserImageView: UIImageView!
    @IBOutlet weak var usrNameCallLabel: UILabel!
    @IBOutlet weak var IncomingCallView: UIView!
    
    var arrayOfPlayers = [AVAudioPlayer]()
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()

    var usrVincle:UserVincle!
    
    var userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    let stepsImgs = ["wizard-step1","wizard-step2","wizard-step3"]
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
        screenName = TRUCANT_VC
        SingletonVars.sharedInstance.callInProgress = true
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.discardCallNotifications()
        
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(SingletonVars.sharedInstance.idUserCall)
                ?? UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
            
            print("VCVC ID USER CALL DESPUES:\(usrVincle)")
        }
        
        roomName = Utils().createRoomName(usrVincle.id!, callee: userCercle.id!)
        getVinclePhoto()
        setUI()
        startAnimation()
        initialize()
        connectToChatRoom()
                
        userName = userCercle.id
        print("VCVC la room es:\(usrVincle.id)")
        self.navigationItem.rightBarButtonItem!.enabled = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        status = .UNACTIVE
        
        myTimer = NSTimer.scheduledTimerWithTimeInterval(
            CALL_WAIT_LIMIT-4, target: self, selector: #selector(timerCheckAreInCalling),
            userInfo: nil, repeats: false)
    }
    
    func checkState()
    {
        print("VCVC Check State: " + (self.status != .VIDEOCONFERENCE ? "FALSE" : "TRUE"))
        if status == .VIDEOCONFERENCE
        {
            dispatch_async(dispatch_get_main_queue(),{
                self.RTCView.hidden = false
            })
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),{
                self.RTCView.hidden = true
            })
        }
    }
    
    
    func timerCheckAreInCalling()
    {
        print("VCVC Check are in calling: " + (self.status != .VIDEOCONFERENCE ? "FALSE" : "TRUE"))
        if(self.status != .VIDEOCONFERENCE)
        {
            if (!isCaller) {
                createLostCallInitFeed()
            }
            disconnect()
            if self.navigationController?.visibleViewController == self {
                performSegueWithIdentifier("fromTrucant_TrucadaFallada", sender: nil)
            }
        }
    }
    
	
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        stopRingTone()
        arrayOfPlayers = arrayOfPlayers.filter(){$0.playing}
        SingletonVars.sharedInstance.isCaller = true
        SingletonVars.sharedInstance.callInProgress = false
        if (!wasLostCall) {
            createPreformedCallInitFeed()
        }
    }
    
    @IBAction func btnAcceptCallPress(sender: UIButton) {
        IncomingCallView.hidden = true;
        stopRingTone()
        client?.finishConnectRoom()
    }

    
    func startAnimation()
    {
        var animaImgs:[UIImage] = []
        for str in stepsImgs {
            let img = UIImage(named: str)
            animaImgs.append(img!)
        }
        wizardStepImageView.animationImages = animaImgs
        wizardStepImageView.animationDuration = 2.0
        wizardStepImageView.animationRepeatCount = -1
        wizardStepImageView.startAnimating()
    }
    
    func createLostCallInitFeed()
    {
        print ("VCVC Create Lost Call Feed")
        wasLostCall = true
        let params:[String:AnyObject] = ["date":Utils().getCurrentLocalDate(),
                                         "type":INIT_CELL_LOST_CALL,
                                         "idUsrVincles":usrVincle.id!,
                                         "isRead":false]
        InitFeed.addNewFeedEntityOffline(params)
    }
    
    func createPreformedCallInitFeed()
    {
        print ("VCVC Create Lost Call Feed")
        let params:[String:AnyObject] = ["date":Utils().getCurrentLocalDate(),
                                         "type":INIT_CELL_CALL_REALIZED,
                                         "idUsrVincles":usrVincle.id!,
                                         "isRead":false]
        InitFeed.addNewFeedEntityOffline(params)
    }

    func setUI()
    {
        if !isCaller {
            IncomingCallView.hidden = false
            prepareCallNotificationUI()
        }
        dispatch_async(dispatch_get_main_queue(), {
            
            self.vincleCalledImageView.layer.borderColor = UIColor.whiteColor().CGColor
            self.vincleCalledImageView.layer.borderWidth = 1.0
            self.vincleCalledImageView.layer.masksToBounds = false
            self.vincleCalledImageView.layer.cornerRadius = self.vincleCalledImageView.frame.size.height/2
            self.vincleCalledImageView.clipsToBounds = true
            
        })
        penjarBtn.layer.cornerRadius = 4.0
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        footerView.backgroundColor = UIColor(hexString: HEX_DARK_BACK_FOOTER)
    }
    
    func getVinclePhoto() {
        
        if let _ = usrVincle.photo
        {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let imgData = Utils().imageFromBase64ToData(self.usrVincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                self.vincleCalledImageView.image = xarxaImg
                print("IMAGE ADDED")
            })
        }
        else
        {
            Utils().retrieveUserVinclesProfilePhoto(usrVincle, completion: { (result, imgB64) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    self.vincleCalledImageView.image = xarxaImg
                })
            })
        }
    }

    //  MARK: Private
    func initialize()
    {
        disconnect()
        
        print("VCVC ID ROOM \(self.userName)")
        self.client = ARDAppClient.init(delegate: self)
        
        remoteView.delegate = self
        localView.delegate = self
        SingletonVars.sharedInstance.callInProgress = true
    }
    
    @IBAction func penjarBtnPress(sender: UIButton)
    {
        print("VCVC Hang out pressed")
        disconnect()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func navBackBtnPress(sender: UIBarButtonItem)
    {
        print("VCVC Back Pressed")
        disconnect()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func appClient(client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        print("VCVC Receive local videotrack")
        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.addRenderer(localView)
    }
    
    func appClient(client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        print("VCVC Receive remote videotrack")
        self.remoteVideoTrack = remoteVideoTrack
        self.remoteVideoTrack?.addRenderer(remoteView)
        
        UIView .animateWithDuration(0.4) {
            
            let videoRect = CGRectMake(0.0, 0.0, self.view.frame.size.width/4.0, self.view.frame.size.height/4.0)
            let videoFrame = AVMakeRectWithAspectRatioInsideRect(self.localView.frame.size, videoRect)
            self.localViewWidthConstraint.constant = videoFrame.size.width
            self.localViewHeightConstraint.constant = videoFrame.size.height
            
            self.view.layoutIfNeeded()
        }
    }
    
    func appClient(client: ARDAppClient!, didError error: NSError!)
    {
        print ("VCVC didError: \(error)")
        print ("VCVC ERROR STATUS: \(self.status)")
        if self.status == .CONNECTED || self.status == .VIDEOCONFERENCE {
            reportError(WebRTCatErrorCode.CantMessageRoom)
        }
        else {
            reportError(WebRTCatErrorCode.CantJoinRoom)
        }
    }
    
    func appClient(client: ARDAppClient!, callEnd missatge: String!) {
        print ("VCVC callEnd: \(missatge)")
        disconnect()
    }
    
    func appClient(client: ARDAppClient!, callStart missatge: String!) {
        print ("VCVC callStart (\(missatge): " + (self.remoteVideoTrack == nil ? "Videotrack" : "NO Videtrack")  + " : " + missatge)
        if self.status != .FINISHED {
            self.status = .VIDEOCONFERENCE
            checkState()
        }
    }
    
    //  MARK: RTCEAGLVideoViewDelegate
    func videoView(videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {

    }
    
    func connectToChatRoom()
    {
        
        print("VCVC Connecting to roomName:\(roomName)");
        client?.connectToRoomWithId(roomName, isLoopback: false, isAudioOnly: false, shouldMakeAecDump: false, shouldUseLevelControl: true)
    }
    
    func disconnect()
    {
        print("VCVC Try disconnecting client")
        SingletonVars.sharedInstance.idRoomCall=""
        myTimer?.invalidate()
        myTimer = nil
        
        if(status != .FINISHED)
        {
            print("VCVC Disconnecting client")
            status = .FINISHED
            
            if(localVideoTrack != nil){
                localVideoTrack?.removeRenderer(localView)
            }
            
            if(remoteVideoTrack != nil){
                remoteVideoTrack?.removeRenderer(remoteView)
            }
            
            localVideoTrack = nil
            remoteVideoTrack = nil
            client?.disconnect()
            
            SingletonVars.sharedInstance.callInProgress = false

        }
        else {
            print("VCVC Another finish in process")
        }
    }
    
    override func shouldAutorotate() -> Bool
    {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    //  MARK: ARDAppClientDelegate <NSObject>
    func appClient(client: ARDAppClient!, didGetStats stats: [AnyObject]!)
    {
        print("VCVC Did Get Stats")
    }
    
    
    // CONTROL: WebSocketStatus
    func appClient(client: ARDAppClient!, didChangeState state: ARDAppClientState)
    {
        if self.status != .FINISHED {
            switch state
            {
            case ARDAppClientState.Connected:
                print("VCVC Client Connected (As initiator: \(self.client?.isInitiator))")
                self.status = .CONNECTED
                if isCaller {
                    VinclesApiManager.sharedInstance.initializeVideoCall(usrVincle.id!, idRoom: roomName, completion: { (status) in
                        if status == SUCCESS
                        {
                            print("VCVC PUSH SENT AND WAIT \(self.userName)")
                        }
                        else
                        {
                            self.reportError(WebRTCatErrorCode.NotWebRTCError)
                        }
                    })
                }
                else {
                    print ("VCVC Receiving call (As initiator: \(self.client?.isInitiator))")
                    if client.isInitiator {
                        print("VCVC Error: I'm connected as a callee but I'm the first in this room")
                        reportError(WebRTCatErrorCode.NotWebRTCError)
                    }
                }
                break
            case ARDAppClientState.Connecting:
                print("VCVC Client Connecting: \(self.status)")
                break
            case ARDAppClientState.Disconnected:
                print("VCVC Client Disconnected: \(self.status)")
                if self.status == .CONNECTED || self.status == .VIDEOCONFERENCE || !isCaller {
                    if (!isCaller && self.status != .VIDEOCONFERENCE) {
                        createLostCallInitFeed()
                    }
                    disconnect()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    reportError(WebRTCatErrorCode.CantConnectToSignallingServer)
                }
                self.status = .UNACTIVE
            case ARDAppClientState.Error:
                reportError(WebRTCatErrorCode.SignalingServerConnectionClosed)
            }
        }
    }
    
    // CONTROL: PeerConnectionStatus
    func appClient(client: ARDAppClient!, didChangeConnectionState state: RTCIceConnectionState)
    {
        print("VCVC Change connection state to: \(state.rawValue) / App value = \(self.status!)")
        
        switch state {
        case .Checking:
            self.status = .CALLING
            if (!isCaller) {
                self.startRingTone(true)
            }
        case .Connected:
            fallthrough
        case .Completed:
            self.status = .VIDEOCONFERENCE
            self.client?.enableSpeaker()
        case .Disconnected:
            disconnect()
            self.navigationController?.popToRootViewControllerAnimated(true)
        case .Closed:
            fallthrough
        case .Failed:
            reportError(WebRTCatErrorCode.IceConnectionFailed)
        default: break
        }
    }
    
    func reportError (errorCode: WebRTCatErrorCode) {
        print("VCVC Error Reported: \(errorCode)")
        wasLostCall = true
        
        if self.status != .FINISHED {
            self.status = .FINISHED
            let completionHandler: ((UIAlertAction) -> Void) = {_ in
                CATransaction.setCompletionBlock({
                    self.status = .UNACTIVE
                    self.disconnect()
                    if self.navigationController?.visibleViewController == self {
                        self.performSegueWithIdentifier("fromTrucant_TrucadaFallada", sender: nil)
                    }
                })
            }
            
            switch errorCode {
            case .NotWebRTCError:
                let alert = Utils().postAlertWithCompletion(
                    langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil),
                    message: langBundle.localizedStringForKey("ALERTA_NOT_CONNECTED_CIRCLE", value: nil, table: nil)
                        + "\n(\(errorCode.rawValue))",
                    pHandler: completionHandler)
                self.presentViewController(alert, animated: true, completion: nil)
            default:
                let alert = Utils().postAlertWithCompletion(
                    self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil),
                    message: self.langBundle.localizedStringForKey("ERROR_CALL_UNAVAILABLE", value: nil, table: nil)
                        + "\n(\(errorCode.rawValue))",
                    pHandler: completionHandler)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            print("VCVC Previous error was fired, new error: \(errorCode)")
        }
    }
    

    // INCOMING CALL
    func prepareCallNotificationUI() {
        dispatch_async(dispatch_get_main_queue(), {
            
            let imgData = Utils().imageFromBase64ToData(self.usrVincle.photo!)
            let userImg = UIImage(data:imgData)
            self.xarxaUserImageView.image = userImg!
            self.xarxaUserImageView.layer.borderWidth = 1.0
            self.xarxaUserImageView.layer.borderColor = UIColor.whiteColor().CGColor
            self.xarxaUserImageView.layer.masksToBounds = false
            self.xarxaUserImageView.layer.cornerRadius = self.xarxaUserImageView.frame.size.height/2
            self.xarxaUserImageView.clipsToBounds = true
            
            self.usrNameCallLabel.text = "\(self.usrVincle.name!) \(self.langBundle.localizedStringForKey("TEXT_IS_CALLING", value: nil, table: nil))"
            
            UIView.animateWithDuration(1.5, delay: 0.2,options:[.Repeat, .Autoreverse], animations: { () -> Void in
                let scaleTransform = CGAffineTransformMakeScale(1.3, 1.3)
                
                self.xarxaUserImageView.transform = scaleTransform
                },completion: nil)
        })
    }
    
    func startRingTone(play: Bool) {
        print("VCVC Start Ringtone");
        do {
            if let bundle = NSBundle.mainBundle().pathForResource("ring", ofType: "wav") {
                let alertSound = NSURL(fileURLWithPath: bundle)
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, withOptions: .MixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true, withOptions: [])
                
                let audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
                audioPlayer.numberOfLoops = 10
                arrayOfPlayers.append(audioPlayer)
                arrayOfPlayers.last?.prepareToPlay()
                if (play) {
                    arrayOfPlayers.last?.play()
                }
            }
        } catch {
            print(error)
        }
    }

    func stopRingTone() {
        print("VCVC Stop Ringtone");
        do {
            for player in arrayOfPlayers {
                player.stop()
            }
            arrayOfPlayers.removeAll()
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .MixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true, withOptions: [])
        } catch {
            print (error)
        }
    }
}
