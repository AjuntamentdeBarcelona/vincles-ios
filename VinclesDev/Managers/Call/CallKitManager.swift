//
//  CallKitManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import CallKit
import Reachability
import AVFoundation
import RealmSwift


class CallKitManager:NSObject {
    
    private static let controller = CXCallController()
    private static var provider:CXProvider = {
        
        var config = CXProviderConfiguration(localizedName: "Vincles")
        config.iconTemplateImageData = UIImage(named: "logo-big")!.pngData()
        config.ringtoneSound = "ring.wav"

        let tempProvider = CXProvider(configuration: config)
        tempProvider.setDelegate(CallKitManager.callKitManagerDelegate, queue: nil)
        return tempProvider
    }()
    private static var callKitManagerDelegate = CallKitManagerDelegate()
    
    private static var callUUID:UUID?
    private static var caller:User!
    private static var isConnected = false
    private static var callVC:UIViewController!
    
    static func incomingCall(user:User){
        
        self.caller = user
        
       
        
        CallKitManager.incoming()

    }
    
    private static func incoming(){
        if CallKitManager.callUUID == nil {
            CallKitManager.callUUID = UUID()
        }
        
        let update = CXCallUpdate()
        update.hasVideo = true
        
        update.remoteHandle = CXHandle(type: .generic, value: CallKitManager.caller.name + " " + CallKitManager.caller.lastname)
        CallKitManager.provider.reportNewIncomingCall(with: CallKitManager.callUUID!, update: update, completion: { error in })
        
       
    }
    
    static func endCall(){
        
        if CallKitManager.callUUID != nil {
            
            let action = CXEndCallAction(call: CallKitManager.callUUID!)
            let transaction = CXTransaction(action: action)
            CallKitManager.controller.request(transaction,completion: { error in })
            CallKitManager.isConnected = false

            CallKitManager.callUUID = nil
        }
        
    }
    
    class CallKitManagerDelegate:NSObject, CXProviderDelegate {
        
        
        func providerDidReset(_ provider: CXProvider) {
            
        }
        
        func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
            action.fulfill()
            // TODO
            CallKitManager.isConnected = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let vc = appDelegate.showingCallVC{
                if let incoming = vc.incoming{
                    incoming.acceptCall(incoming.agafarButton)
                }
            }
        }
        
        func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
            action.fulfill()
           
            CallKitManager.endCall()
            CallKitManager.isConnected = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let vc = appDelegate.showingCallVC{
                if let incoming = vc.incoming{
                    incoming.rejectCall(incoming.agafarButton)
                }
            }
        }
        
    }
}
