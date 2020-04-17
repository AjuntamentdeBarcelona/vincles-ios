//
//  CallContainerViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Reachability
import RealmSwift
import Firebase

class CallContainerViewController: UIViewController {

    @IBOutlet weak var navigationBar: NavigationBar!
    @IBOutlet weak var navigationBarHeight: NSLayoutConstraint!
    @IBOutlet weak var containerInCallView: UIView!
    @IBOutlet weak var containerPreCallView: UIView!

    var videoCall: ARDVideoCallViewController!
    var callingVC: CallingViewController!
    var incoming: IncomingViewController!
    var cancelTimer: Timer!
    let reachability = try! Reachability()

    var isCaller = false
    var roomId: String?
    var callerId: Int?
    var calleeId: Int?
    var notification: VincleNotification?
    var showBack = false
    var errorPer = false
    
    let errorPermission = 1006

    override func viewDidLoad() {
        super.viewDidLoad()

       
        if !isCaller{
           videoCall = ARDVideoCallViewController(roomId: roomId!, callerId: callerId!, notification: notification!, delegate: self)
        }
        else{
            videoCall = ARDVideoCallViewController(calleeId: calleeId!, delegate: self)
        }
         addCallViewController()

        
        setInitialAppereance()
        configNavigationBar()
        
        setupAnalytics()

       
        
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showingCallVC = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showingCallVC = nil
        let notificationNameCall = Notification.Name(CALL_FINISHED)
        NotificationCenter.default.post(name: notificationNameCall, object: nil)
        WebRTCCallManager.sharedInstance.calleeId = nil
        WebRTCCallManager.sharedInstance.callerId = nil
        WebRTCCallManager.sharedInstance.roomId = nil
        WebRTCCallManager.sharedInstance.notification = nil
        WebRTCCallManager.sharedInstance.isCaller = nil
        CallKitManager.endCall()

        WebRTCCallManager.sharedInstance.stopRingTone()
    }
    
    func checkForPermissions(){
        incoming.agafarButton.isHidden = true
        incoming.cancelarButton.isHidden = true

        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized && AVCaptureDevice.authorizationStatus(for: .audio) ==  .authorized {
            incoming.agafarButton.isHidden = false
            incoming.cancelarButton.isHidden = false
        } else {
            
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
                    if granted {
                        DispatchQueue.main.async {
                            self.incoming.agafarButton.isHidden = false
                            self.incoming.cancelarButton.isHidden = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorPopupMicrophone()
                            self.hangUpPermissions()

                        }
                        
                    }
                })
            }
            else if AVCaptureDevice.authorizationStatus(for: .audio) ==  .authorized {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        DispatchQueue.main.async {
                            self.incoming.agafarButton.isHidden = false
                            self.incoming.cancelarButton.isHidden = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorPopupVideo()
                            self.hangUpPermissions()

                        }
                        
                    }
                })
            }
            else{
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
                            if granted {
                                DispatchQueue.main.async {
                                    self.incoming.agafarButton.isHidden = false
                                    self.incoming.cancelarButton.isHidden = false
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.errorPopupMicrophone()
                                    self.hangUpPermissions()

                                }
                                
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.errorPopupVideo()
                            self.hangUpPermissions()
                        }
                        
                    }
                })
            }
            
        }
    }
    
    func hangUpPermissions(){
        errorPer = true
       
      
        if incoming.clientConn{
            rejectCall(dismiss: false)
        }
    }
    
    func errorPopupVideo(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.permisTrucada
        popupVC.button1Title = L10n.permisosAnarConfiguracio
        popupVC.button2Title = L10n.cancelar
        
        popupVC.view.tag = self.errorPermission
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func errorPopupMicrophone(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.permisTrucada
        popupVC.button1Title = L10n.permisosAnarConfiguracio
        popupVC.button2Title = L10n.cancelar
        
        popupVC.view.tag = self.errorPermission
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func setInitialAppereance(){
        guard let isCaller = WebRTCCallManager.sharedInstance.isCaller else{
            return
        }
        if isCaller{
            addCallingViewController()
            setupTimers()
        }
        else{
            addIncomingViewController()
        }

    }
    
    
    func addCallViewController(){
        DispatchQueue.main.async {

            self.addChild(self.videoCall)
        self.videoCall.view.translatesAutoresizingMaskIntoConstraints = false
        self.containerInCallView.addSubview(self.videoCall.view)
        
        NSLayoutConstraint.activate([
            self.videoCall.view.leadingAnchor.constraint(equalTo: self.containerInCallView.leadingAnchor),
            self.videoCall.view.trailingAnchor.constraint(equalTo: self.containerInCallView.trailingAnchor),
            self.videoCall.view.topAnchor.constraint(equalTo: self.containerInCallView.topAnchor),
            self.videoCall.view.bottomAnchor.constraint(equalTo: self.containerInCallView.bottomAnchor)
            ])
        
            self.videoCall.didMove(toParent: self)
        }
    }
    
    func addCallingViewController(){
        DispatchQueue.main.async {

        self.callingVC = StoryboardScene.Call.callingViewController.instantiate()
        self.callingVC.delegate = self
            self.addChild(self.callingVC)
        self.callingVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.containerPreCallView.addSubview(self.callingVC.view)
        
        NSLayoutConstraint.activate([
            self.callingVC.view.leadingAnchor.constraint(equalTo: self.containerPreCallView.leadingAnchor),
            self.callingVC.view.trailingAnchor.constraint(equalTo: self.containerPreCallView.trailingAnchor),
            self.callingVC.view.topAnchor.constraint(equalTo: self.containerPreCallView.topAnchor),
            self.callingVC.view.bottomAnchor.constraint(equalTo: self.containerPreCallView.bottomAnchor)
            ])
        
            self.callingVC.didMove(toParent: self)
        }
    }
    
    func addIncomingViewController(){
        DispatchQueue.main.async {

        self.incoming = StoryboardScene.Call.incomingViewController.instantiate()
        self.incoming.delegate = self
            self.addChild(self.incoming)
        self.incoming.view.translatesAutoresizingMaskIntoConstraints = false
        self.containerPreCallView.addSubview(self.incoming.view)
        
        NSLayoutConstraint.activate([
            self.incoming.view.leadingAnchor.constraint(equalTo: self.containerPreCallView.leadingAnchor),
            self.incoming.view.trailingAnchor.constraint(equalTo: self.containerPreCallView.trailingAnchor),
            self.incoming.view.topAnchor.constraint(equalTo: self.containerPreCallView.topAnchor),
            self.incoming.view.bottomAnchor.constraint(equalTo: self.containerPreCallView.bottomAnchor)
            ])
        
            self.incoming.didMove(toParent: self)
            
            
            if !self.isCaller{
                self.checkForPermissions()
            }
            
        }
    }
    
    
    func configNavigationBar(){
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationBarHeight.constant = 70.0
        }

        navigationBar.leftTitle = nil
        navigationBar.leftImage = UIImage(asset: Asset.Icons.Navigation.tornar)
        navigationBar.leftHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
        
        navigationBar.leftButton.isHidden = false
        
        navigationBar.navTitle = ""
        navigationBar.backgroundColor = .clear
        navigationBar.inputView?.backgroundColor = .clear
        navigationBar.xibView?.backgroundColor = .clear
        
        navigationBar.leftButton.addTarget(self, action: #selector(self.leftAction), for: .touchUpInside)
    }

    func setupAnalytics(){
        
        Analytics.setScreenName(ANALYTICS_CALL, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_CALL)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func changeBackground(color: UIColor){
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.view.backgroundColor = color
        }
    }
    @objc func leftAction(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        self.dismiss(animated: true, completion: {
        })
    }
    
  

    func setupTimers(){
        cancelTimer = Timer.scheduledTimer(timeInterval: 25, target: self, selector: #selector(cancelOutgoingCall), userInfo: nil, repeats: false)
    }
    
    @objc func cancelOutgoingCall(){
        // TIMER ESGOTAT
        if WebRTCCallManager.sharedInstance.isCaller == nil{
            return
        }
        
        if WebRTCCallManager.sharedInstance.isCaller!{
            callingVC.cancelOutgoingCall()
            videoCall.disconnect()
            CallKitManager.endCall()
            DispatchQueue.main.async {
                self.videoCall.willMove(toParent: nil)
                self.videoCall.view.removeFromSuperview()
                self.videoCall.removeFromParent()
                self.navigationBar.leftButton.isHidden = false
            }
      
        }
        else{
           viewControllerDidFinish()
        }
       
    }
    
    func invalidateTimer() {
        if cancelTimer != nil{
            cancelTimer.invalidate()
            
        }
    }
    
    func receivedErrorInCall(){
        invalidateTimer()
        DispatchQueue.main.async {
            self.videoCall.disconnect()
            CallKitManager.endCall()
            self.videoCall.willMove(toParent: nil)
            self.videoCall.view.removeFromSuperview()
            self.videoCall.removeFromParent()
            self.navigationBar.leftButton.isHidden = false
            if self.callingVC != nil{
                self.callingVC.receivedErrorInCall()
            }
        }
   

    }
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    
}

extension CallContainerViewController: ARDVideoCallViewControllerDelegate{
    func clientConnected() {
        if !WebRTCCallManager.sharedInstance.isCaller!{
          
            incoming.clientConnected()
            
            DispatchQueue.main.async {
                Timer.after(1.seconds) {
                    
                    if self.incoming.labelInfo.text !=  "\(L10n.callConnecting)"{
                        if WebRTCCallManager.sharedInstance.roomId != nil{
                            if !self.errorPer{
                                WebRTCCallManager.sharedInstance.startRingTone(play: true)
                            }
                            else{
                                self.rejectCall(dismiss: false)
                            }
                        }

                    }
                    
                }
            }
           
        }
    }
    
    func errorInCall() {
        containerPreCallView.isHidden = false
        changeBackground(color: .white)

        if WebRTCCallManager.sharedInstance.isCaller!{
            invalidateTimer()
            DispatchQueue.main.async {
                self.videoCall.disconnect()
                CallKitManager.endCall()
                self.videoCall.willMove(toParent: nil)
                self.videoCall.view.removeFromSuperview()
                self.videoCall.removeFromParent()
                self.navigationBar.leftButton.isHidden = false
                self.callingVC.receivedErrorDuringCall()
            }
            
        }
        else{
            invalidateTimer()
            DispatchQueue.main.async {
                self.videoCall.callRejected = true
                self.videoCall.mustShowError = true
                self.videoCall.disconnect()
                CallKitManager.endCall()
                self.videoCall.willMove(toParent: nil)
                self.videoCall.view.removeFromSuperview()
                self.videoCall.removeFromParent()
                self.navigationBar.leftButton.isHidden = false

                self.incoming.receivedErrorDuringCall()
            }
        }
    }
    

    func errorBeforeConnecting() {
        if WebRTCCallManager.sharedInstance.isCaller!{
            invalidateTimer()
            DispatchQueue.main.async {
                self.videoCall.disconnect()
                CallKitManager.endCall()
                self.videoCall.willMove(toParent: nil)
                self.videoCall.view.removeFromSuperview()
                self.videoCall.removeFromParent()
                self.navigationBar.leftButton.isHidden = false
                self.callingVC.receivedErrorInCall()
            }
         
        }
        else{
            invalidateTimer()
            DispatchQueue.main.async {
                self.videoCall.callRejected = true
                self.videoCall.mustShowError = true
                self.videoCall.disconnect()
                CallKitManager.endCall()
                self.videoCall.willMove(toParent: nil)
                self.videoCall.view.removeFromSuperview()
                self.videoCall.removeFromParent()
                self.navigationBar.leftButton.isHidden = false
                self.incoming.receivedErrorInCall()
            }
        }
    }
    
    func viewControllerDidFinish() {
        WebRTCCallManager.sharedInstance.stopRingTone()
        if !errorPer{
            if !self.isBeingDismissed{
                self.dismiss(animated: true, completion: {
                })
            }
        }
       
    }
    
    func receivedCompleted() {
        invalidateTimer()
        containerPreCallView.isHidden = true
        changeBackground(color: .black)
    }
    
    func weWereAlone() {
        DispatchQueue.main.async {
            self.invalidateTimer()
            self.rejectCall(dismiss: true)
        }
    }
    
    func calleeRejectedCall() {
        if WebRTCCallManager.sharedInstance.isCaller!{
            DispatchQueue.main.async {
                self.videoCall.willMove(toParent: nil)
                self.videoCall.view.removeFromSuperview()
                self.videoCall.removeFromParent()
                self.invalidateTimer()
                self.callingVC.calleeRejectedCal()
                self.navigationBar.leftButton.isHidden = false
                self.changeBackground(color: .white)
            }
       

        }
    }
    
    func automaticRetry() {
            DispatchQueue.main.async {
                if let userId = WebRTCCallManager.sharedInstance.calleeId{
                    self.invalidateTimer()
                    CallKitManager.endCall()

                    self.videoCall.client.disconnect()
                    self.videoCall.willMove(toParent: nil)
                    self.videoCall.view.removeFromSuperview()
                    self.videoCall.removeFromParent()
                    self.changeBackground(color: .white)
                    
                    Timer.after(0.4.second, {
                       
                        self.videoCall = ARDVideoCallViewController(calleeId: userId, delegate: self)
                        self.addCallViewController()
                        self.navigationBar.leftButton.isHidden = true
                        
                        self.setupTimers()
                        self.callingVC.retryCall()
                    })
                
                }
               
            }
    }
    
    func automaticRetryCallee() {
        DispatchQueue.main.async {
            self.invalidateTimer()
            CallKitManager.endCall()

            self.videoCall.client.disconnect()
            self.videoCall.willMove(toParent: nil)
            self.videoCall.view.removeFromSuperview()
            self.videoCall.removeFromParent()
            
        }
    }
}

extension CallContainerViewController: CallingViewControllerDelegate{
    func cancelCall() {
        videoCall.hangUp(dismiss: true)
        videoCall.willMove(toParent: nil)
        videoCall.view.removeFromSuperview()
        videoCall.removeFromParent()
        changeBackground(color: .white)

    }
    
    func retryCall() {
        if reachability.connection != .none{
            if let userId = WebRTCCallManager.sharedInstance.calleeId{
                videoCall = ARDVideoCallViewController(calleeId: userId, delegate: self)
                addCallViewController()
                navigationBar.leftButton.isHidden = true

                setupTimers()
                callingVC.retryCall()
            }
         
            
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
    
    func sendMessage() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        self.dismiss(animated: true, completion: {
        })
    }
    
   
}


extension CallContainerViewController: PopUpDelegate{
    
    func firstButtonClicked(popup: PopupViewController) {
        if popup.view.tag == errorPermission{
            popup.dismissPopup {
                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                self.dismiss(animated: true, completion: nil)

            }
            
            
        }
        else{
            popup.dismissPopup {
            }
        }
       
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        if popup.view.tag == errorPermission{
            popup.dismissPopup {
                self.dismiss(animated: true, completion: nil)

            }
            
            
        }
        else{
            popup.dismissPopup {
            }
        }
      
    }
    
    func closeButtonClicked(popup: PopupViewController) {
        if popup.view.tag == errorPermission{
            Timer.after(1.second) {
                self.dismiss(animated: true, completion: nil)

            }

        }
        
    }
}

extension CallContainerViewController: IncomingViewControllerDelegate{
    func acceptCall() {
       
        DispatchQueue.main.async {
            let realm = try! Realm()
            try! realm.write {
                WebRTCCallManager.sharedInstance.notification?.callStarted = true
            }
        }
      
        WebRTCCallManager.sharedInstance.stopRingTone()
        videoCall.calleeStartCall()
        addCallViewController()
    //    containerPreCallView.isHidden = true
      //  changeBackground(color: .black)
    }
    
    func rejectCall(dismiss: Bool) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            try! realm.write {
                WebRTCCallManager.sharedInstance.notification?.callStarted = true
            }
        }
       
        videoCall.rejectedCall()
        videoCall.hangUp(dismiss: dismiss)
        invalidateTimer()
        changeBackground(color: .white)

        WebRTCCallManager.sharedInstance.stopRingTone()

        if dismiss{
            self.dismiss(animated: true, completion: nil)
        }
      
    }
    

}
