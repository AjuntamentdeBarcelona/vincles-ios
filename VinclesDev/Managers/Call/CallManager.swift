//
//  CallManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import webrtcat4
import AVFoundation
import RealmSwift
import Reachability

protocol CallManagerDelegate{
    func dismissVC()
    func canStartRingtone()
    func invalidateTimer()
    func sendError()
    func showErrorScreen()

}

class CallManager: NSObject {
    
    enum DisconnectReason :Int{
        case InCall = 0
        case RejectedByCalle = 1
        case EurecatApiError = 2
        case SpdCorruption = 3
        case PreCallLibraryError = 4
        case InCallLibraryError = 5
        case InCheckingError
        case Unknown = 500
    }
    
    var callStarted = false
    var disconnectReason: DisconnectReason = .Unknown
    var completed = false
    var connected = false
    var checking = false
    var joinedRoom = false
    
    var showingErrorScreen = false
    var receivedError: WebRtcCatErrorCode = WebRtcCatErrorCode.NO_ERROR

    static let sharedInstance = CallManager()
    var roomName: String?
    var client: ARDAppClient?
    var incoming = false
    var callee: User?
    var callMusic : AVAudioPlayer?
    var interactionDelegate: CallManagerDelegate?

    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    var localCapturer: RTCCameraVideoCapturer?
    var captureController:ARDCaptureController?
    
    var remoteView: RTCEAGLVideoView?
    var localView: RTCEAGLVideoView?
    var remoteViewBackground: UIView?
    var endButton: CircularView?

    var vincleNotification: VincleNotification?
    
    
    func initClient(){
        joinedRoom = false
        print("init call")

        
        client = ARDAppClient.init(delegate: self, urlBase: SERVER_HOST_URL)
        let reachability = Reachability()!
        
        reachability.whenUnreachable = { _ in
            self.receivedError = WebRtcCatErrorCode.NETWORK_ERROR
            self.disconnectReason = .InCheckingError
            self.disconnect()
            self.roomName = nil
        }
    }
    
    private override init() {
        super.init()
       
        client = ARDAppClient.init(delegate: self, urlBase: SERVER_HOST_URL)
        
    
    }

    func joinRoom(){
        
        callStarted = false
        disconnectReason = .Unknown
        receivedError = .NO_ERROR
        checking = false
        
        let profileModelManager = ProfileModelManager()

        client?.serverHostUrl = SERVER_HOST_URL
        client?.setSTUNServer(STUN_SERVER_URL)
        client?.addRTCICEServer(TURN_SERVER_UDP, username: TURN_SERVER_UDP_USERNAME, password: TURN_SERVER_UDP_PASSWORD)
        client?.addRTCICEServer(TURN_SERVER_TCP, username: TURN_SERVER_TCP_USERNAME, password: TURN_SERVER_TCP_PASSWORD)
            
            if let roomName = roomName{
                print("joinedRoom")

                joinedRoom = true

                print("Connection to CHAT room " + roomName)
                print("Connection to room "+roomName)
                print("Connection to room "+(profileModelManager.getUserMe()?.username)!)

                client?.connectToRoom(withId: roomName, settings: nil, isLoopback: false, username: (profileModelManager.getUserMe()?.username)!)
        }
    }
    
    func createRoomId(idUser: Int){
        let profileModelManager = ProfileModelManager()
        let circlesGroupsModelManager = CirclesGroupsModelManager()

        if let user = profileModelManager.getUserMe(), let receptor = circlesGroupsModelManager.contactWithId(id: idUser){
            
            var me = "xp"
            if profileModelManager.userIsVincle{
                me = "vin"
            }
            
            var recp = "xp"
            
            if receptor.idCircle != -1{
                recp = "vin"
            }
            
            roomName = "iOS-\(me)-\(user.id)-\(recp)-\(receptor.id)-\(Int64(Date().timeIntervalSince1970 * 1000))"
            print(roomName)
        }
        
    }
    
    func startCallApi(idUser: Int, idRoom: String, onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        
        let params = ["idUser": idUser, "idRoom": idRoom] as [String : Any]
        print("post call")
        ApiClient.startVideoConference(params: params, onSuccess: {
            onSuccess(true)
        }) { (error) in
            onError(error)
          
        }
        
    }
    
    func errorCallApi(idUser: Int, idRoom: String, onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        
        let params = ["idUser": idUser, "idRoom": idRoom] as [String : Any]
        
        ApiClient.errorVideoConference(params: params, onSuccess: {
            onSuccess(true)

        }) { (error) in
            onError(error)

        }
        
    }
    
    func sendApiRequest(){
        if let callee = callee, let roomName = roomName{
            self.startCallApi(idUser: callee.id, idRoom: roomName, onSuccess: { (success) in
                
            }) { (error) in
                print("error sendApiRequest")
                self.disconnectReason = .EurecatApiError
                if !CallManager.sharedInstance.showingErrorScreen{
                    self.interactionDelegate?.showErrorScreen()
                }
            }
        }
    
    }
    
    func disconnect(){
        if(client != nil){
            if(localVideoTrack != nil && localView != nil){
                localVideoTrack!.remove(localView!)
            }
            if(remoteVideoTrack != nil && remoteView != nil){
                remoteVideoTrack!.remove(remoteView!)
            }
            localVideoTrack = nil
            remoteVideoTrack = nil
            interactionDelegate?.invalidateTimer()
            client = nil
            roomName = nil
            
            do{
                try AVAudioSession.sharedInstance().setActive(false)
            }catch {
                
            }
        }
    }
    
    func receivedErrorInCall(){
        self.receivedError = WebRtcCatErrorCode.INVALID_CLIENT
        self.disconnectReason = .PreCallLibraryError
        self.disconnect()
        self.roomName = nil
    }
}

extension CallManager: ARDAppClientDelegate{
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch state {
        case .connected:
            print("ARDAppClientState: Client Connected")
            
            if !incoming{
                DispatchQueue.main.async {
                    self.sendApiRequest()
                }
            }
            DispatchQueue.main.async {
                if self.incoming{
                    Timer.after(1.5.second) {
                        if !self.checking{
                            self.receivedError = WebRtcCatErrorCode.CHECKING_ERROR
                            self.disconnectReason = .InCheckingError
                            self.disconnect()
                            self.roomName = nil
                            self.interactionDelegate?.dismissVC()
                            print("PENJA RAPID %@", UIDevice.current.model)
                            
                            if self.incoming{
                                DispatchQueue.main.async {
                                    let realm = try! Realm()
                                    try! realm.write {
                                        self.vincleNotification?.callStarted = true
                                    }
                                }
                                let notificationManager = NotificationManager()
                                notificationManager.showLocalNotificationForMissedCall(user: (self.vincleNotification?.idUser)!, room: (self.vincleNotification?.idRoom)!)
                                
                                
                            }
                        }
                    }
                }
            }
          
            break
        case .connecting:
            

            print("ARDAppClientState: Client Connecting")
            break
        case .disconnected:
            print("ARDAppClientState: Client Disconnected")
            if joinedRoom{
                print("room joined so error")

                disconnectedManagement()
                completed = false
                connected = false
            }

        }
    }
    
    func sendError(){
        
        DispatchQueue.main.async {

            print(self.vincleNotification?.idUser)
            print(self.vincleNotification?.idRoom)

            if let user =  (self.vincleNotification?.idUser), let room = self.vincleNotification?.idRoom{
            CallManager.sharedInstance.errorCallApi(idUser: user, idRoom: room, onSuccess: { (success) in
                
            }) { (error) in
                
            }
        }
        }
    }
    func disconnectedManagement(){
        roomName = nil
        if !callStarted{
            if receivedError != WebRtcCatErrorCode.NO_ERROR && receivedError != WebRtcCatErrorCode.ICE_CONNECTION_FAILED && receivedError != WebRtcCatErrorCode.CHECKING_ERROR && !CallManager.sharedInstance.showingErrorScreen{
                print(receivedError)
                
                if incoming{
                    self.sendError()
                }
                
                self.disconnectReason = .PreCallLibraryError
                interactionDelegate?.showErrorScreen()
                
            }
            else if !incoming && !completed && !CallManager.sharedInstance.showingErrorScreen{
                self.disconnectReason = .RejectedByCalle
                interactionDelegate?.showErrorScreen()
            }
            else{
                print("DISMISS VC CALL MANAGER 0 %@", UIDevice.current.model)
                interactionDelegate?.dismissVC()
                interactionDelegate?.invalidateTimer()
            }
        }
        else{
            if receivedError != WebRtcCatErrorCode.NO_ERROR && !CallManager.sharedInstance.showingErrorScreen{
                self.disconnectReason = .InCallLibraryError
                interactionDelegate?.showErrorScreen()
            }
            else if !connected && !CallManager.sharedInstance.showingErrorScreen{
                self.disconnectReason = .SpdCorruption
                interactionDelegate?.showErrorScreen()
            }
            else{
                print(receivedError.rawValue)
                print("DISMISS VC CALL MANAGER 1 %@", UIDevice.current.model)
                interactionDelegate?.dismissVC()
                interactionDelegate?.invalidateTimer()
            }
           
          
        }
       
       
       
       
    }
    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        switch state {
        case .checking:
            checking = true
            connected = false
            print("RTCIceConnectionState: CHECKING")
            if incoming{
                interactionDelegate?.canStartRingtone()
            }
            if !incoming{
                
                do{
                    var options = AVAudioSessionCategoryOptions()
                    options.insert(.mixWithOthers)
                    options.insert(.defaultToSpeaker)
                    
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: options)
                }catch {
                    
                }
                
                Timer.after(10.5.second) {
                    if !self.connected{
                        self.receivedError = WebRtcCatErrorCode.CREATE_SPD_ERROR
                        self.disconnectReason = .SpdCorruption
                        
                        if !CallManager.sharedInstance.showingErrorScreen{
                            self.interactionDelegate?.showErrorScreen()
                        }
                        self.disconnect()
                        self.roomName = nil
                        print("MEGAERROR OUTGOING")
                    
                    }
                }
            }
            
          
            break
        case .closed:
            
            print("RTCIceConnectionState: CLOSED")
          //  interactionDelegate?.dismissVC()

            if incoming{
                if !(vincleNotification?.callStarted)!{
                    let notificationManager = NotificationManager()
                    notificationManager.showLocalNotificationForMissedCall(user: (vincleNotification?.idUser)!, room: (vincleNotification?.idRoom)!)
                }
            }
           
            break
        case .completed:
            print("RTCIceConnectionState: COMPLETED")

            completed = true
           
        
            
            break
        case .connected:
            connected = true

            print("RTCIceConnectionState: CONNECTED")

            if incoming{
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    try! realm.write {
                        self.vincleNotification?.callStarted = true
                    }
                }
               
            }
            
            self.interactionDelegate?.invalidateTimer()
            self.localView!.isHidden = false
            self.remoteView!.isHidden = false
            self.remoteViewBackground!.isHidden = false
            self.endButton!.isHidden = false
            
            
            break
        case .count:
            print("RTCIceConnectionState: COUNT")
            break
        case .disconnected:
            print("RTCIceConnectionState: disconnected")

            disconnectedManagement()
            completed = false
            connected = false
            
            break
        case .failed:
            print("RTCIceConnectionState: FAILED")
            break
        case .new:
            print("RTCIceConnectionState: NEW")
        }

    }
    
    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        print("didCreateLocalCapturer")
        self.localCapturer = localCapturer
        let settingsModel = ARDSettingsModel()
        captureController = ARDCaptureController(capturer: localCapturer, settings: settingsModel)
        captureController?.startCapture()
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        print("didReceiveLocalVideoTrack")

        self.localVideoTrack = localVideoTrack
        if let localView = localView{
            self.localVideoTrack?.add(localView)

        }
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        print("didReceiveRemoteVideoTrack")

        self.remoteVideoTrack = remoteVideoTrack
        if let remoteView = remoteView{
            self.remoteVideoTrack?.add(remoteView)
        }
    }
    
    func appClient(_ client: ARDAppClient!, didError error: WebRtcCatErrorCode) {
       
        receivedError = error

       
       
    }
    
    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        print("didGetStats")

    }
    
    
    func appClient(_ client: ARDAppClient!, callStart message: String!) {
        print("callStart")
        callStarted = true
        
        if incoming{
            Timer.after(10.5.second) {
                if !self.connected{
                    self.receivedError = WebRtcCatErrorCode.CREATE_SPD_ERROR
                    self.disconnectReason = .SpdCorruption
                    if !CallManager.sharedInstance.showingErrorScreen{
                        self.interactionDelegate?.showErrorScreen()
                    }
                    self.disconnect()
                    self.roomName = nil
                   
                }
            }
        }
       

    }
    
    func appClient(_ client: ARDAppClient!, didCreateLocalFileCapturer fileCapturer: RTCFileVideoCapturer!) {
        print("didCreateLocalFileCapturer")

    }
}
