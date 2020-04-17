//
//  WebRTCCallManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import Foundation

class WebRTCCallManager: NSObject, URLSessionDelegate{
    
    static let sharedInstance = WebRTCCallManager()

    var roomId: String?
    var callerId: Int?
    var calleeId: Int?
    var isCaller: Bool?
    var notification: VincleNotification?
    var arrayOfPlayers = [AVAudioPlayer]()

    func createRoomId(idUser: Int){
        let profileModelManager = ProfileModelManager()
        let circlesGroupsModelManager = CirclesGroupsModelManager.shared
        
        if let user = profileModelManager.getUserMe(), let receptor = circlesGroupsModelManager.contactWithId(id: idUser){
            
            var me = "xp"
            if profileModelManager.userIsVincle{
                me = "vin"
            }
            
            var recp = "xp"
            
            if receptor.idCircle != -1{
                recp = "vin"
            }
            
            let roomName = "iOS-\(me)-\(user.id)-\(recp)-\(receptor.id)-\(Int64(Date().timeIntervalSince1970 * 1000))"
            self.roomId = roomName
        }
    }
    
 
    func startRingTone(play: Bool) {
        DispatchQueue.main.async {
            do {
                if let bundle = Bundle.main.path(forResource: "ring", ofType: "wav") {
                    let alertSound = NSURL(fileURLWithPath: bundle)
                    
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [AVAudioSession.CategoryOptions.duckOthers])
                    try AVAudioSession.sharedInstance().setActive(true, options: [])
                    
                    let audioPlayer = try AVAudioPlayer(contentsOf: alertSound as URL)
                    audioPlayer.numberOfLoops = 10
                    self.arrayOfPlayers.append(audioPlayer)
                    self.arrayOfPlayers.last?.prepareToPlay()
                    self.arrayOfPlayers.last?.play()
                    
                }
            } catch {
                print(error)
            }
        }
        
    }
    
    func stopRingTone() {
        do {
            for player in arrayOfPlayers {
                player.stop()
            }
            arrayOfPlayers.removeAll()
            
            var options = AVAudioSession.CategoryOptions()
            options.insert(.mixWithOthers)
            options.insert(.defaultToSpeaker)
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: options)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print (error)
        }
    }
    
    func startCallApi(idUser: Int, idRoom: String, onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        
        ApiClientURLSession.sharedInstance.startCallApi(idUser: idUser, idRoom: idRoom, onSuccess: { (success) in
            
        }) { (error) in
            if error == TOKEN_FAIL{
                ApiClientURLSession.sharedInstance.refreshToken(onSuccess: {
                    ApiClientURLSession.sharedInstance.startCallApi(idUser: idUser, idRoom: idRoom, onSuccess: { (success) in
                    }) { (error) in
                    }
                }) { (error) in
                    let navigationManager = NavigationManager()
                    navigationManager.showUnauthorizedLogin()
                }
            }
        }

    }
    
    
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.previousFailureCount == 0 else {
            challenge.sender?.cancel(challenge)
            // Inform the user that the user name and password are incorrect
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Within your authentication handler delegate method, you should check to see if the challenge protection space has an authentication type of NSURLAuthenticationMethodServerTrust
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
            // and if so, obtain the serverTrust information from that protection space.
            && challenge.protectionSpace.serverTrust != nil
            && challenge.protectionSpace.host == IP {
            let proposedCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, proposedCredential)
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
    
}

