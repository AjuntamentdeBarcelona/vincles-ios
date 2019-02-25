//
//  HUDHelper.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import SVProgressHUD

class HUDHelper: NSObject {

    var message: String?
    var progress: Double?
    var visible = false
    
    static let sharedInstance: HUDHelper = {
        let instance = HUDHelper()

        return instance
    }()
    
    func manageRotation(){
        if visible{
            if let message = message{
                self.showHud(message: message)
            }
            if let progress = progress{
                self.showHud(progress: progress)
            }
        }
    }
    
    
    func showHud(message: String?){
        visible = true
        self.message = message
        self.progress = nil
        if let msg = message, msg.count > 0{
            DispatchQueue.main.async {
                SVProgressHUD.setDefaultMaskType(.gradient)
                
                SVProgressHUD.show(withStatus: message)
            }
        }
        else{
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
       
    }
    
    func showHud(progress: Double){
        visible = true
        self.message = nil
        self.progress = progress
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.showProgress(Float(progress))
        }
    }
    

    func hideHUD(){
        visible = false
        self.message = nil
        self.progress = nil
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
}
