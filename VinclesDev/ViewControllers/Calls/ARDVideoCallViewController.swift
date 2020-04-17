//
//  ARDVideoCallViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift

protocol ARDVideoCallViewControllerDelegate: AnyObject {
    func viewControllerDidFinish()
    func receivedCompleted()
    func weWereAlone()
    func calleeRejectedCall()
    func errorBeforeConnecting()
    func errorInCall()
    func automaticRetry()
    func automaticRetryCallee()
    func clientConnected()

}

class ARDVideoCallViewController: UIViewController {
    
    weak var delegate:ARDVideoCallViewControllerDelegate?
    var client: ARDAppClient!
    var videoCallView: ARDVideoCallView!
    var captureController: ARDCaptureController!
    var remoteVideoTrack: RTCVideoTrack!
    var portOverride: AVAudioSession.PortOverride!

    var callInitiated = false
    var managingAutomaticReconnect = false
    var disconectedManaged = false
    var callRejected = false
    var mustShowError = false

    var totalBytesReceived = 0
    var totalBytesSent = 0
    
    convenience init(calleeId: Int, delegate: ARDVideoCallViewControllerDelegate ) {
        self.init()
        
        self.delegate = delegate
        
        WebRTCCallManager.sharedInstance.createRoomId(idUser: calleeId)
        WebRTCCallManager.sharedInstance.isCaller = true
        WebRTCCallManager.sharedInstance.calleeId = calleeId
        
        client = ARDAppClient(delegate: self, serverURL: "\(SERVER_HOST_URL)")
        client.isCaller = true
        client.shouldGetStats = true
        
       initClient()
        
      
    }
    
    convenience init(roomId: String, callerId: Int, notification: VincleNotification, delegate: ARDVideoCallViewControllerDelegate ) {
        self.init()
        
        totalBytesReceived = 0
        totalBytesSent = 0
        
        self.delegate = delegate

       WebRTCCallManager.sharedInstance.isCaller = false
       WebRTCCallManager.sharedInstance.callerId = callerId
       WebRTCCallManager.sharedInstance.roomId = roomId
       WebRTCCallManager.sharedInstance.notification = notification

        client = ARDAppClient(delegate: self, serverURL: "\(SERVER_HOST_URL)")
        client.isCaller = false
       initClient()
        
      
    }
    
    func connect(){
        let settingsModel = ARDSettingsModel()

        guard let room = WebRTCCallManager.sharedInstance.roomId else{
            return
        }
        client.connectToRoom(withId: room, settings: settingsModel, isLoopback: false)
    }
    
    func initClient(){
        client.setSTUNServer("stun:stun.l.google.com:19302")
        client.addRTCICEServer(TURN_SERVER_UDP, username: TURN_SERVER_UDP_USERNAME, password: TURN_SERVER_UDP_PASSWORD)
        client.addRTCICEServer(TURN_SERVER_TCP, username: TURN_SERVER_TCP_USERNAME, password: TURN_SERVER_TCP_PASSWORD)
    }
    
    override func loadView() {
        self.videoCallView = ARDVideoCallView(frame: CGRect.zero)
        self.videoCallView.backgroundColor = .black
        self.videoCallView.delegate = self
        self.videoCallView.statusLabel.text = self.statusTextFor(state: RTCIceConnectionState.new)
        self.view = self.videoCallView
        let session = RTCAudioSession.sharedInstance()
        session.add(self)
        UIApplication.shared.isIdleTimerDisabled = true
        self.connect()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: "VideoCall", size: totalBytesReceived)
        DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: "VideoCall", size: totalBytesSent)
        
        let notificationNameCallFinish = Notification.Name(NOTI_FINISH_CALL)
        NotificationCenter.default.post(name: notificationNameCallFinish, object: nil)
    }
    
    func statusTextFor(state: RTCIceConnectionState) -> String{
        switch (state) {
        case RTCIceConnectionState.new:
            break
        case RTCIceConnectionState.checking:
            return "Connecting..."
        case RTCIceConnectionState.connected:
            break
        case RTCIceConnectionState.completed:
            break
        case RTCIceConnectionState.failed:
            break
        case RTCIceConnectionState.disconnected:
            break
        case RTCIceConnectionState.closed:
            break
        case RTCIceConnectionState.count:
            break
        }
        
        return ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
     //   WebRTCCallManager.sharedInstance.calleeId = nil
     //    WebRTCCallManager.sharedInstance.callerId = nil
        WebRTCCallManager.sharedInstance.roomId = nil
    //     WebRTCCallManager.sharedInstance.notification = nil
    //     WebRTCCallManager.sharedInstance.isCaller = nil
        UIApplication.shared.isIdleTimerDisabled = false
        client = nil
        videoCallView = nil
        captureController = nil
        remoteVideoTrack = nil
        
    }
    
    func rejectedCall(){
        callRejected = true
    }
    
    func hangUp(dismiss: Bool){
        self.remoteVideoTrack = nil
        
        if videoCallView != nil{
            videoCallView.localVideoView.captureSession = nil
        }
        
        if captureController != nil{
            captureController.stopCapture()
            captureController = nil
        }
        
        if dismiss{
            delegate?.viewControllerDidFinish()
        }

        if client != nil{
            client.disconnect()
            self.client = nil
        }
     

        let session = RTCAudioSession.sharedInstance()
        session.isAudioEnabled = false
        
    }
    
    func disconnect(){
        self.remoteVideoTrack = nil
        
        if videoCallView != nil{
            videoCallView.localVideoView.captureSession = nil
        }
        
        if captureController != nil{
            captureController.stopCapture()
            captureController = nil
        }
        
        if client != nil{
            client.disconnect()

        }
        
        
        let session = RTCAudioSession.sharedInstance()
        session.isAudioEnabled = false
        
        self.client = nil
    }
    
    func initApiCall(){
        ApiClient.cancelAll()
        
        guard let id = WebRTCCallManager.sharedInstance.calleeId , let idRoom = WebRTCCallManager.sharedInstance.roomId else{
            return
        }

        WebRTCCallManager.sharedInstance.startCallApi(idUser: id, idRoom: idRoom, onSuccess: { (success) in
            
        }) { (error) in
            
        }
        
        /*
        ApiClient.startVideoConference(params: params, onSuccess: {

        }) { (error) in

            
        }
 */
    }
    
    func sendError() {
        DispatchQueue.main.async {

                if let room = WebRTCCallManager.sharedInstance.roomId, let caller = WebRTCCallManager.sharedInstance.callerId{
                    WebRTCCallManager.sharedInstance.errorCallApi(idUser: caller, idRoom: room, onSuccess: { (success) in
                    }) { (error) in
                        print(error)
                        
                    }
                }
            }

    }
    
    
    func calleeStartCall(){
        if client != nil{
            client.calleAcceptCall()
        }
        
    }
    
    func manageDisconnected(){
      
        
        if disconectedManaged{
            return
        }
        
        disconectedManaged = true
        
        if self.managingAutomaticReconnect{
            
            self.managingAutomaticReconnect = false
            return
        }
        
        if self.callInitiated{
            
            self.hangUp(dismiss: !mustShowError)
        }
        else{
            if WebRTCCallManager.sharedInstance.isCaller != nil{
                if WebRTCCallManager.sharedInstance.isCaller! && !mustShowError{
                    self.delegate?.calleeRejectedCall()
                }
                else if !WebRTCCallManager.sharedInstance.isCaller!{
                    // Caller fired timer
                    if !callRejected{
                        let notificationManager = NotificationManager()
                        
                        notificationManager.showLocalNotificationForMissedCall(user: (WebRTCCallManager.sharedInstance.callerId)!, room: (WebRTCCallManager.sharedInstance.roomId)!)
                    }
                    
                    hangUp(dismiss: !mustShowError)
                }
            }
           
        }
    }
}

extension ARDVideoCallViewController: ARDVideoCallViewDelegate{
    func videoCallViewDidSwitchCamera(_ view: ARDVideoCallView!) {
        captureController.switchCamera()
    }
    
    
    func videoCallViewDidHangup(_ view: ARDVideoCallView!) {

        self.hangUp(dismiss: true)
    }
    
    
}

extension ARDVideoCallViewController: RTCAudioSessionDelegate{

}

extension ARDVideoCallViewController: ARDAppClientDelegate{
    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        
        for stat in stats{
            if let report = stat as? RTCLegacyStatsReport{
                for (key,value) in report.values{
                    if key == "bytesReceived"{
                        totalBytesReceived += Int(value) ?? 0
                    }
                    else if key == "bytesSent"{
                        totalBytesSent += Int(value) ?? 0
                    }
                }
            }
        }
       
    }
    
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch (state) {
        case .connected:
            if let isCaller =  WebRTCCallManager.sharedInstance.isCaller{
                if isCaller{
                    self.initApiCall()
                }
                else{
                    delegate?.clientConnected()
                }
            }
         
            break
        case .connecting:
            break
        case .disconnected:
            manageDisconnected()
            break
        }
    }
    
    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        /*
 RTCIceConnectionStateNew,
 RTCIceConnectionStateChecking,
 RTCIceConnectionStateConnected,
 RTCIceConnectionStateCompleted,
 RTCIceConnectionStateFailed,
 RTCIceConnectionStateDisconnected,
 RTCIceConnectionStateClosed,
 RTCIceConnectionStateCount,
 */
        

        if state.rawValue == 1{
            
            Timer.after(3.seconds) {
                if !self.callInitiated{
                    if WebRTCCallManager.sharedInstance.isCaller != nil{
                        if WebRTCCallManager.sharedInstance.isCaller!{
                         
                        }
                    }
                   
                    
                }
            }
        }
        else if state.rawValue == 2{
            if !WebRTCCallManager.sharedInstance.isCaller!{
                self.callInitiated = true
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    try! realm.write {
                        WebRTCCallManager.sharedInstance.notification?.callStarted = true
                        let notificationNameCall = Notification.Name(CALL_FINISHED)
                        NotificationCenter.default.post(name: notificationNameCall, object: nil)
                    }
                }
                
                let profileModelManager = ProfileModelManager()
                
                if let me = profileModelManager.getUserMe(){
                    if !SERVER_HOST_URL.contains("appr"){
                        client!.sendConnected(toBackendUsername: me.username) { (error) in
                            
                        }
                    }
                   
 
                }
                
            
            }
            else{
                if WebRTCCallManager.sharedInstance.isCaller!{
                    self.callInitiated = true
                }
            }
            delegate?.receivedCompleted()

        }
        else if state.rawValue == 5{
            /*
            if callInitiated{
                mustShowError = true
                delegate?.errorInCall()
            }
 */
            manageDisconnected()
        }
        else if state.rawValue == 6{
         
            manageDisconnected()
        }
        
    }
    
    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        if videoCallView != nil{
            videoCallView.localVideoView.captureSession = localCapturer.captureSession
        }
        let settingsModel = ARDSettingsModel()
        captureController = ARDCaptureController(capturer: localCapturer, settings: settingsModel)
        captureController.startCapture()
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {

        if (self.remoteVideoTrack == remoteVideoTrack) {
            return
        }
      
        if self.remoteVideoTrack != nil{
            self.remoteVideoTrack.remove(videoCallView.remoteVideoView)
            self.remoteVideoTrack = nil
        }
       
        
        videoCallView.remoteVideoView.renderFrame(nil)
        self.remoteVideoTrack = remoteVideoTrack
        remoteVideoTrack.add(videoCallView.remoteVideoView)
        
        
        if client.checkIfWeAreAlone(){
            self.delegate?.weWereAlone()

        }
    }
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {

       if !callInitiated{
            if !WebRTCCallManager.sharedInstance.isCaller!{
                self.sendError()
            }
            mustShowError = true
            delegate?.errorBeforeConnecting()
        }
       else{
            mustShowError = true
            delegate?.errorInCall()
        }
       
    
    }
    
    func appClient(_ client: ARDAppClient!, didCreateLocalFileCapturer fileCapturer: RTCFileVideoCapturer!) {
        
    }
   
    
}

