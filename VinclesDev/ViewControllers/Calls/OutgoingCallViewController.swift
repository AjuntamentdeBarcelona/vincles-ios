//
//  OutgoingCallViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import webrtcat4
import RealmSwift
import Reachability

class OutgoingCallViewController: UIViewController {
    
    @IBOutlet weak var penjarButton: HoverButton!
    @IBOutlet weak var receptorImageView: UIImageView!
    @IBOutlet weak var emisorImageView: UIImageView!
    @IBOutlet weak var outgoingView: UIView!
    @IBOutlet weak var incomingView: UIView!
    @IBOutlet weak var cannotCallView: UIView!
    @IBOutlet weak var cancelarButton: HoverButton!
    @IBOutlet weak var agafarButton: HoverButton!
    @IBOutlet weak var missatgeButton: HoverButton!
    @IBOutlet weak var retryButton: HoverButton!
    @IBOutlet weak var emisorIncomingImageView: UIImageView!
    @IBOutlet weak var viewFotosOutgoing: UIView!
    
    @IBOutlet weak var remoteViewBackground: UIView!
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    
    @IBOutlet weak var remoteViewWidth: NSLayoutConstraint!
    @IBOutlet weak var remoteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var localViewWidth: NSLayoutConstraint!
    @IBOutlet weak var localViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dotsView: UIView!
    
    @IBOutlet weak var firstDotCircle: UIView!
    @IBOutlet weak var secondDotCircle: UIView!
    @IBOutlet weak var thirdDotCircle: UIView!
    @IBOutlet weak var fourthDotCircle: UIView!
    @IBOutlet weak var fifthDotCircle: UIView!
    
    @IBOutlet weak var fourthDot: UIView!
    @IBOutlet weak var fifthDot: UIView!
    @IBOutlet weak var labelInfo: UILabel!
    
    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var navigationBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var endButton: CircularView!
    
    var arrayOfPlayers = [AVAudioPlayer]()
    
    var localViewSize: CGSize?
    var remoteViewSize: CGSize?
    
    var user: User?
    var showBackButton = true
    var incoming = false
    var cancelTimer: Timer!
    var dotsTimer: Timer!
    var dotSequenceIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            labelInfo.font =  UIFont(font: FontFamily.Akkurat.regular, size: 28.0)
        }
        CallManager.sharedInstance.interactionDelegate = self
        
        localView.delegate = self
        remoteView.delegate = self
        
        configNavigationBar()
        setUI()
        
        CallManager.sharedInstance.initClient()
        
        setupCallManager()
        
        self.setupOutgoingCall()
        
        
        if incoming{
            receptorImageView.isHidden = true
            dotsView.isHidden = true
            
        }
        else{
            cancelTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(cancelOutgoingCall), userInfo: nil, repeats: false)
            dotsTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(animateDots), userInfo: nil, repeats: true)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        
        CallManager.sharedInstance.showingErrorScreen = false
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_CALL)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        stopRingTone()
    }
    
    func startRingTone(play: Bool) {
        print("VCVC Start Ringtone");
        do {
            if let bundle = Bundle.main.path(forResource: "ring", ofType: "wav") {
                let alertSound = NSURL(fileURLWithPath: bundle)
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
                try AVAudioSession.sharedInstance().setActive(true, with: [])
                
                let audioPlayer = try AVAudioPlayer(contentsOf: alertSound as URL)
                audioPlayer.numberOfLoops = 10
                arrayOfPlayers.append(audioPlayer)
                arrayOfPlayers.last?.prepareToPlay()
                arrayOfPlayers.last?.play()
                
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
            
            var options = AVAudioSessionCategoryOptions()
            options.insert(.mixWithOthers)
            options.insert(.defaultToSpeaker)
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: options)
            try AVAudioSession.sharedInstance().setActive(true, with: [])
        } catch {
            print (error)
        }
    }
    
    override public var traitCollection: UITraitCollection {
        
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    func setUI(){
        initDots()
        
        penjarButton.setTitle(L10n.callEnd, for: .normal)
        cancelarButton.setTitle(L10n.callCancel, for: .normal)
        agafarButton.setTitle(L10n.callGet, for: .normal)
        agafarButton.greenMode = true
        
        missatgeButton.setTitle(L10n.callMessage, for: .normal)
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            missatgeButton.setTitle(L10n.callMessagePhone, for: .normal)
            
        }
        missatgeButton.titleLabel?.numberOfLines = 2
        retryButton.setTitle(L10n.callRetry, for: .normal)
        
        if incoming{
            outgoingView.isHidden = true
            incomingView.isHidden = false
            cannotCallView.isHidden = true
        }
        else{
            outgoingView.isHidden = false
            incomingView.isHidden = true
            cannotCallView.isHidden = true
        }
        
        
        let profileModelManager = ProfileModelManager()
        
        if incoming{
            viewFotosOutgoing.isHidden = true
            
            if let user = user{
                labelInfo.text = "\(L10n.callFrom) \(user.name)"
                let mediaManager = MediaManager()
                emisorIncomingImageView.tag = user.id
                
                mediaManager.setProfilePicture(userId: user.id, imageView: emisorIncomingImageView) {
                    
                }
                
                
                
            }
            
        }
        else{
            emisorIncomingImageView.isHidden = true
            if let me = profileModelManager.getUserMe(){
                let mediaManager = MediaManager()
                emisorImageView.tag = me.id
                
                mediaManager.setProfilePicture(userId: me.id, imageView: emisorImageView) {
                    
                }
            }
            
            if let user = user{
                labelInfo.text =  "\(L10n.calling) \(user.name)"
                
                let mediaManager = MediaManager()
                receptorImageView.tag = user.id
                
                mediaManager.setProfilePicture(userId: user.id, imageView: receptorImageView) {
                    
                }
                
                emisorIncomingImageView.tag = user.id
                
                mediaManager.setProfilePicture(userId: user.id, imageView: emisorIncomingImageView) {
                    
                }
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            fourthDot.isHidden = true
            fifthDot.isHidden = true
        }
        
    }
    
    func initDots(){
        dotSequenceIndex = 0
        firstDotCircle.backgroundColor = UIColor(named: .clearGray)
        secondDotCircle.backgroundColor = UIColor(named: .clearGray)
        thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
        fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
        fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
    }
    func configNavigationBar(){
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationBarHeight.constant = 70.0
        }
        
        
        navigationBar.leftTitle = nil
        navigationBar.leftImage = UIImage(asset: Asset.Icons.Navigation.tornar)
        navigationBar.leftHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
        
        navigationBar.leftButton.isHidden = true
        
        navigationBar.navTitle = ""
        navigationBar.backgroundColor = .clear
        navigationBar.inputView?.backgroundColor = .clear
        navigationBar.xibView?.backgroundColor = .clear
        
        navigationBar.leftButton.addTarget(self, action: #selector(self.leftAction), for: .touchUpInside)
        
    }
    
    @objc func leftAction(){
        invalidateTimer()
        CallManager.sharedInstance.disconnect()
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: {
            CallManager.sharedInstance.roomName = nil
            appDelegate.showingCallVC = nil
        })
    }
    
    func setupCallManager(){
        CallManager.sharedInstance.remoteView = remoteView
        CallManager.sharedInstance.localView = localView
        CallManager.sharedInstance.remoteViewBackground = remoteViewBackground
        CallManager.sharedInstance.endButton = endButton
        
        
    }
    func setupOutgoingCall(){
        CallManager.sharedInstance.incoming = incoming
        if !incoming{
            if let user = user{
                CallManager.sharedInstance.callee = user
                CallManager.sharedInstance.createRoomId(idUser: user.id)
            }
        }
        else{
            
        }
        if CallManager.sharedInstance.roomName != nil{
            CallManager.sharedInstance.joinRoom()
        }
    }
    
    @objc func animateDots(){
        switch dotSequenceIndex{
        case 0:
            firstDotCircle.backgroundColor = UIColor(named: .clearGray)
            secondDotCircle.backgroundColor = UIColor(named: .clearGray)
            thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 1:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .clearGray)
            thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 2:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 3:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .darkRed)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 4:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .darkRed)
            fourthDotCircle.backgroundColor = UIColor(named: .darkRed)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 5:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .darkRed)
            fourthDotCircle.backgroundColor = UIColor(named: .darkRed)
            fifthDotCircle.backgroundColor = UIColor(named: .darkRed)
        default:
            break
        }
        
        dotSequenceIndex += 1
        if UIDevice.current.userInterfaceIdiom == .phone{
            if dotSequenceIndex == 4{
                dotSequenceIndex = 0
            }
        }
        else{
            if dotSequenceIndex == 6{
                dotSequenceIndex = 0
            }
        }
    }
    
    func disconnectClient(){
        CallManager.sharedInstance.disconnect()
        CallManager.sharedInstance.roomName = nil
    }
    
    @objc func cancelOutgoingCall(){
        // TIMER ESGOTAT
        disconnectClient()
        
        CallManager.sharedInstance.showingErrorScreen = true
        
        dotsTimer.invalidate()
        invalidateTimer()
        initDots()
        
        emisorIncomingImageView.isHidden = false
        viewFotosOutgoing.isHidden = true
        
        if let user = user{
            labelInfo.text =  "\(user.name) \(L10n.callNoContesta)"
        }
        
        cannotCallView.isHidden = false
        incomingView.isHidden = true
        outgoingView.isHidden = true
        
        navigationBar.leftTitle = L10n.volver
        navigationBar.leftImage = UIImage(asset: Asset.Icons.Navigation.tornar)
        navigationBar.leftHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
        
    }
    
    
    func errorScreen(){
        DispatchQueue.main.async {
            
            self.localView!.isHidden = true
            self.remoteView!.isHidden = true
            self.remoteViewBackground!.isHidden = true
            self.endButton!.isHidden = true
            
            CallManager.sharedInstance.showingErrorScreen = true
            
            self.invalidateTimer()
            
            if self.dotsTimer != nil{
                self.dotsTimer.invalidate()
            }
            self.invalidateTimer()
            self.initDots()
            
            self.emisorIncomingImageView.isHidden = false
            self.viewFotosOutgoing.isHidden = true
            
            print("disconnectReason \(CallManager.sharedInstance.disconnectReason)")
            
            if let user = self.user{
                switch CallManager.sharedInstance.disconnectReason{
                case .EurecatApiError, .SpdCorruption, .PreCallLibraryError, .InCallLibraryError:
                    self.labelInfo.text = "\(L10n.callConnection)"
                case .RejectedByCalle:
                    self.labelInfo.text =  "\(user.name) \(L10n.callNoContesta)"
                default:
                    self.labelInfo.text = "Error"
                    
                }
            }
            
            self.cannotCallView.isHidden = false
            self.incomingView.isHidden = true
            self.outgoingView.isHidden = true
            
            if self.incoming{
                self.missatgeButton.isHidden = true
                self.retryButton.isHidden = true
            }
            
            self.navigationBar.leftTitle = L10n.volver
            self.navigationBar.leftImage = UIImage(asset: Asset.Icons.Navigation.tornar)
            self.navigationBar.leftHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            // Your code here
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func acceptCall(_ sender: Any) {
        
        CallManager.sharedInstance.client?.startCalling()
        stopRingTone()
    
    }
    
    @IBAction func rejectCall(_ sender: Any) {
        let realm = try! Realm()
        try! realm.write {
            CallManager.sharedInstance.vincleNotification?.callStarted = true
        }
        
        invalidateTimer()
        disconnectClient()
        
        stopRingTone()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: {
            appDelegate.showingCallVC = nil
        })
    }
    
    @IBAction func cancelCall(_ sender: Any) {
        invalidateTimer()
        disconnectClient()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: {
            appDelegate.showingCallVC = nil
        })
    }
    
    let reachability = Reachability()!
    
    @IBAction func retryCall(_ sender: Any) {
        
        if reachability.connection != .none{
            CallManager.sharedInstance.showingErrorScreen = false
            
            CallManager.sharedInstance.initClient()
            
            cancelTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(cancelOutgoingCall), userInfo: nil, repeats: false)
            dotsTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(animateDots), userInfo: nil, repeats: true)
            
            self.setupOutgoingCall()
            
            emisorIncomingImageView.isHidden = true
            viewFotosOutgoing.isHidden = false
            
            if let user = user{
                labelInfo.text =  "\(L10n.calling) \(user.name)"
            }
            
            cannotCallView.isHidden = true
            incomingView.isHidden = true
            outgoingView.isHidden = false
            
            navigationBar.leftTitle = nil
            
        }
        else{
            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = L10n.appName
            popupVC.popupDescription = L10n.callConnection
            popupVC.button1Title = L10n.ok
            
            UIApplication.shared.keyWindow?.rootViewController?.present(popupVC, animated: true, completion: nil)
        }
        
        
        
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        invalidateTimer()
        disconnectClient()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.dismiss(animated: true, completion: {
            
            appDelegate.showingCallVC = nil
        })
    }
    
    func adjustSizes(){
        
        if let localViewSize = localViewSize{
            if localViewSize.width >= localViewSize.height{
                localViewWidth.constant = 0.2 * UIScreen.main.bounds.size.width
                localViewHeight.constant = 0.2 * UIScreen.main.bounds.size.width * localViewSize.height / localViewSize.width
            }
            else{
                localViewHeight.constant = 0.2 * UIScreen.main.bounds.size.height
                localViewWidth.constant = 0.2 * UIScreen.main.bounds.size.height * localViewSize.width / localViewSize.height
            }
        }
        if let remoteViewSize = remoteViewSize{
            let currentScreenAspectRatio = UIScreen.main.bounds.size.width / UIScreen.main.bounds.size.height
            let videoAspectRatio = remoteViewSize.width / remoteViewSize.height
            
            if currentScreenAspectRatio >= videoAspectRatio{
                remoteViewHeight.constant = UIScreen.main.bounds.size.height
                remoteViewWidth.constant = UIScreen.main.bounds.size.height * remoteViewSize.width / remoteViewSize.height
                
            }
            else{
                remoteViewWidth.constant = UIScreen.main.bounds.size.width
                remoteViewHeight.constant = UIScreen.main.bounds.size.width * remoteViewSize.height / remoteViewSize.width
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension OutgoingCallViewController: RTCEAGLVideoViewDelegate{
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        if videoView.isEqual(localView){
            localViewSize = size
            adjustSizes()
            print("localView size \(size)")
            
        }
        else if videoView.isEqual(remoteView){
            print("remoteView size \(size)")
            remoteViewSize = size
            adjustSizes()
        }
        
    }
    
    
}

extension OutgoingCallViewController: CallManagerDelegate{
    func sendError() {
        DispatchQueue.main.async {
            if let user = self.user, let room = CallManager.sharedInstance.roomName{
                CallManager.sharedInstance.errorCallApi(idUser: user.id, idRoom: room, onSuccess: { (success) in
                    
                }) { (error) in
                    
                }
            }
        }
        
        
    }
    
    func invalidateTimer() {
        if cancelTimer != nil{
            cancelTimer.invalidate()
            
        }
    }
    
    func canStartRingtone() {
        startRingTone(play: true)
    }
    
    func dismissVC() {
        if !CallManager.sharedInstance.showingErrorScreen{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            print("DISMISS VC %@", UIDevice.current.model)
            self.dismiss(animated: true, completion: {
                CallManager.sharedInstance.roomName = nil
                appDelegate.showingCallVC = nil
            })
        }
    }
    
    func showErrorScreen() {
        CallManager.sharedInstance.showingErrorScreen = true
        errorScreen()
    }
    
}


extension OutgoingCallViewController: PopUpDelegate{
    
    
    
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
    }
    
}

