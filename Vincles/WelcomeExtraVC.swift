/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class WelcomeExtraVC: VinclesVC {
    
    
    @IBOutlet weak var welcomeUserLabel: UILabel!
    @IBOutlet weak var welcomeBisLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var continuarBtn: UIButton!
    @IBOutlet weak var continuarBtnTitle: UILabel!
    
    let userCerc:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    let vincles:[UserVincle] = {
        UserVincle.loadUserVincleCoreData()
    }()
    
    let bundle:NSBundle = {
        
        return UserPreferences().bundleForLanguageSelected()
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = WELCOMEEXTRA_VC

    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
        setUI()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let vincle = vincles.last
        VinclesApiManager.sharedInstance.getUserFullInfo(vincle!.id!) { (result, info) in
            if result == SUCCESS {
                vincle?.idContentPhoto = info["idContentPhoto"].stringValue
                UserVincle.saveUserVincleContext()
            } else {

            }
        }
    }

    

    
    func loadData() {
        let vincle = vincles.last

        print("NOM = \(vincle!.name!) COGNOM = \(vincle!.lastname!) DATA = \(userCerc.dataNeixament!) TEL = \(userCerc.telefon!) MAIL = \(userCerc.mail!) GENERE = \(userCerc.genere!) VIUS BCN \(userCerc.viusBcn!) PASSWORD = \(userCerc.password!)  USERNAME = \(userCerc.username!) ID = \(userCerc.id!)")
        
        VinclesApiManager.sharedInstance.setMyProfilePhoto(userCerc.fotoPerfil!) { (result) in
            
            if result == SUCCESS {
                print("SET PHOTO SUCCESS")
            } else {
                print("SET PHOTO FAILURE")
                // SET DEFAULT FOTO IF UPLOAD FAILS
                let unknownPhoto = UIImage(named: "unknownProfileImage")
                let photoData = UIImageJPEGRepresentation(unknownPhoto!, 0.1)
                self.userCerc.fotoPerfil! = photoData!
                UserCercle.saveUserCercleEntity(self.userCerc)

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
                completion(result: FAILURE, base64: "")
            }
        }
    }

    func setUI() {
        
        let vincle = vincles.last
        
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
        
        welcomeUserLabel.text = "\(bundle.localizedStringForKey("WELCOME_LABEL_MALE", value: nil, table: nil)) \(userCerc.nom!)"
        welcomeBisLabel.text = bundle.localizedStringForKey("YOU_JOINED_LABEL", value: nil, table: nil)
        connectedLabel.text = bundle.localizedStringForKey("YOU_CONNECTED_LABEL", value: nil, table: nil)
        userNameLabel.text = vincle!.alias!
        continuarBtnTitle.text = bundle.localizedStringForKey("BTN_BACK_XARXES", value: nil, table: nil)
        continuarBtn.layer.cornerRadius = 4.0
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        self.footerView.backgroundColor = UIColor(hexString: HEX_DARK_BACK_FOOTER)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromWelcomeExtra_Xarxes" {
            
            
        }
    }

    @IBAction func continuarBtnPress(sender: UIButton) {
        
        SingletonVars.sharedInstance.initMenuHasToChange = true
        SingletonVars.sharedInstance.initDestination = .Redes
        
        performSegueWithIdentifier("fromWelcomeExtra_Xarxes", sender: nil)

        
    }

}
