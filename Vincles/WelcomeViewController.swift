/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import Firebase

import CoreData

enum goesToView {
    case TutorialVC
    case XarxesVC
    
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeUserLabel: UILabel!
    @IBOutlet weak var welcomeBisLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var continuarBtn: UIButton!
    
    var goesTo:goesToView!
    
    let userCerc:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    let vincles:[UserVincle] = {
        UserVincle.loadUserVincleCoreData()
    }()
    
    let bundle:NSBundle = {
        
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    override func viewWillAppear(animated: Bool) {
        loadData()
        setUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        let vincle = vincles.last
        
        if (vincle != nil){
            VinclesApiManager.sharedInstance.getUserFullInfo(vincle!.id!) { (result, info) in
                if result == SUCCESS {
                    vincle?.idContentPhoto = info["idContentPhoto"].stringValue
                    UserVincle.saveUserVincleContext()
                }else{
                }
            }
        }
    }
    
    func loadData() {
        let vincle = vincles.last
        
        if (vincles.last != nil){

            print("NOM = \(vincle!.name!) COGNOM = \(vincle!.lastname!) DATA = \(userCerc.dataNeixament!) TEL = \(userCerc.telefon!) MAIL = \(userCerc.mail!) GENERE = \(userCerc.genere!) VIUS BCN \(userCerc.viusBcn!) PASSWORD = \(userCerc.password!)  USERNAME = \(userCerc.username!) ID = \(userCerc.id!)")
            VinclesApiManager.sharedInstance.setMyProfilePhoto(userCerc.fotoPerfil!) { (result) in
                
                if result == SUCCESS {
                    print("SET PHOTO SUCCESS")
                }else{
                    print("SET PHOTO FAILURE")
                    // SET DEFAULT FOTO IF UPLOAD FAILS
                    let unknownPhoto = UIImage(named: "unknownProfileImage")
                    let photoData = UIImageJPEGRepresentation(unknownPhoto!, 0.1)
                    self.userCerc.fotoPerfil! = photoData!
                    UserCercle.saveUserCercleEntity(self.userCerc)
                }
            }
        }
        
    }
    
    
    
    func getUserPhoto(vincle:UserVincle,completion:((result:String,base64:String) -> ())) {
        
        VinclesApiManager.sharedInstance.getUserProfilePhoto(vincle.id!) { (result, binaryURL) in
            
            if result == SUCCESS {
                let data = NSData(contentsOfURL: binaryURL!)
                let bse64 = Utils().imageFromImgtoBase64(data!)
                completion(result: SUCCESS, base64: bse64)
            }else{
                print("GET USER FOTO FAILURE")
                completion(result: FAILURE, base64: "")
            }
        }
    }
    
    func setUI() {
        
        let vincle = vincles.last
        
        if (vincle != nil) {
            getUserPhoto(vincle!, completion: { (result,base64) in
                
                if result == SUCCESS {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        print("GET VINCLES PHOTO SUCCESS")
                        let imgFrom64 = Utils().imageFromBase64ToData(base64)
                        let img = UIImage(data: imgFrom64)
                        self.userImageView.image = img
                        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2
                        self.userImageView.layer.borderWidth = 2.0
                        self.userImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
                        self.userImageView.layer.masksToBounds = false
                        self.userImageView.clipsToBounds = true
                    })
                    vincle?.photo = base64
                    UserVincle.saveUserVincleContext()
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        print("GET VINCLES PHOTO FAILURE")
                        let unknownPhoto = UIImage(named: DEFAULT_PROFILE_IMAGE)
                        self.userImageView.image = unknownPhoto
                        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2
                        self.userImageView.layer.borderWidth = 2.0
                        self.userImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
                        self.userImageView.layer.masksToBounds = false
                        self.userImageView.clipsToBounds = true
                    })
                }
            })
            
        }
        
        var generStr = ""
        if userCerc.genere! == "MALE"{
            generStr = bundle.localizedStringForKey("WELCOME_LABEL_MALE", value: nil, table: nil)
        }else{
           generStr = bundle.localizedStringForKey("WELCOME_LABEL_FEMALE", value: nil, table: nil)
        }
        welcomeUserLabel.text = "\(generStr) \(userCerc.nom!)"
        welcomeBisLabel.text = bundle.localizedStringForKey("YOU_JOINED_LABEL", value: nil, table: nil)
        connectedLabel.text = bundle.localizedStringForKey("YOU_CONNECTED_LABEL", value: nil, table: nil)
        if (vincle != nil) {
            userNameLabel.text = vincle!.alias!
        }
        continuarBtn.setTitle(bundle.localizedStringForKey("BTN_WELCOME_CONTINUE", value: nil, table: nil), forState: .Normal)
        continuarBtn.layer.cornerRadius = 4.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromWelcome_Menu" {
            
        }
    }
    
    @IBAction func continueBtnPress(sender: UIButton) {
        if (userCerc.username != nil){
            VinclesApiManager.sharedInstance.loginSelfUser(userCerc.username!, pwd: userCerc.password!, usrId: userCerc.id!)
        }
        
        if (goesTo != nil){
            if goesTo == goesToView.TutorialVC {
                performSegueWithIdentifier("fromWelcome_tutorial", sender: nil)
            }else{
                SingletonVars.sharedInstance.initMenuHasToChange = false
                SingletonVars.sharedInstance.initDestination = .Inicio
                performSegueWithIdentifier("fromWelcome_Menu", sender: nil)
            }
        }else{
            performSegueWithIdentifier("fromWelcome_tutorial", sender: nil)
        }
    }
}

