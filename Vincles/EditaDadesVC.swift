/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class EditaDadesVC: VinclesVC,UITextFieldDelegate {
    
    
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var btnGuardar: UIButton!
    @IBOutlet weak var btnTornar: UIButton!
    @IBOutlet weak var tornarLabel: UILabel!
    
    @IBOutlet weak var nomLabel: UILabel!
    @IBOutlet weak var nomTextField: UITextField!
    @IBOutlet weak var warningImgNom: UIImageView!
    
    @IBOutlet weak var cogNomLabel: UILabel!
    @IBOutlet weak var cognomTextField: UITextField!
    @IBOutlet weak var warningImgCognom: UIImageView!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var warningImgEmail: UIImageView!
    
    @IBOutlet weak var telfLabel: UILabel!
    @IBOutlet weak var telfTextField: UITextField!
    @IBOutlet weak var warningImgTelf: UIImageView!
    
    @IBOutlet weak var actualpassLabel: UILabel!
    @IBOutlet weak var actualpassTextField: UITextField!
    @IBOutlet weak var warningImgActualPass: UIImageView!
    
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var warningImgPass: UIImageView!
    
    @IBOutlet weak var repeatPassLabel: UILabel!
    @IBOutlet weak var repeatPassTextField: UITextField!
    @IBOutlet weak var warningImgRepeatPass: UIImageView!
    
    
    @IBOutlet weak var viusBcnLabel: UILabel!
    @IBOutlet weak var viusBcnSegmControl: UISegmentedControl!
    
    var validaCamposDict = ["nom":true,"cognom":true,"email":true,"telf":true,"actualpass":true,"pass":true,"repeatpass":true]
    
    var userCerc:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var usrInfoHasChanged = false
    
    
    let langBundle:NSBundle = {
        
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = EDITADADES_VC
        nomTextField.delegate = self
        nomTextField.keyboardType = .ASCIICapable
        nomTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        cognomTextField.delegate = self
        cognomTextField.keyboardType = .ASCIICapable
        cognomTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        emailTextField.delegate = self
        emailTextField.keyboardType = .EmailAddress
        emailTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        telfTextField.delegate = self
        telfTextField.keyboardType = .PhonePad
        telfTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        actualpassTextField.delegate = self
        actualpassTextField.keyboardType = .ASCIICapable
        actualpassTextField.secureTextEntry = true
        actualpassTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        passTextField.delegate = self
        passTextField.keyboardType = .ASCIICapable
        passTextField.secureTextEntry = true
        passTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        repeatPassTextField.delegate = self
        repeatPassTextField.keyboardType = .ASCIICapable
        repeatPassTextField.secureTextEntry = true
        repeatPassTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)

        
        setUI()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func indexChanged(sender : UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            usrInfoHasChanged = true
            break;
        case 1:
            usrInfoHasChanged = true
            break;
        default:
            break;
        }
    }
    
    func setUI() {
        
        self.baseView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)

        tornarLabel.text = langBundle.localizedStringForKey("BACK_BAR_LABEL", value: nil, table: nil)
        nomLabel.text = langBundle.localizedStringForKey("NAME", value: nil, table: nil)
        cogNomLabel.text = langBundle.localizedStringForKey("SURNAMES", value: nil, table: nil)
        emailLabel.text = langBundle.localizedStringForKey("EMAIL", value: nil, table: nil)
        telfLabel.text = langBundle.localizedStringForKey("TELF", value: nil, table: nil)
        actualpassLabel.text = langBundle.localizedStringForKey("ACTUAL_PASSWORD_LABEL", value: nil, table: nil)
        passLabel.text = langBundle.localizedStringForKey("NEW_PASSWORD_LABEL", value: nil, table: nil)
        repeatPassLabel.text = langBundle.localizedStringForKey("REPEAT_NEW_PASSWORD_LABEL", value: nil, table: nil)
        viusBcnLabel.text = langBundle.localizedStringForKey("FROM_BCN", value: nil, table: nil)
        viusBcnSegmControl.setTitle(langBundle.localizedStringForKey("SEGMENT_POS_YES", value: nil, table: nil), forSegmentAtIndex: 0)
        viusBcnSegmControl.setTitle(langBundle.localizedStringForKey("SEGMENT_POS_NO", value: nil, table: nil), forSegmentAtIndex: 1)
        
        nomTextField.text = userCerc.nom!
        cognomTextField.text = userCerc.cognom!
        emailTextField.text = userCerc.mail!
        emailTextField.userInteractionEnabled = false
        telfTextField.text = userCerc.telefon!
        
        if userCerc.viusBcn! == 0 {
            viusBcnSegmControl.selectedSegmentIndex = 0
        }else{
            viusBcnSegmControl.selectedSegmentIndex = 1
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    @IBAction func btnTornarPressed(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveEditedUserData() {
        
        if usrInfoHasChanged == false && actualpassTextField.text == ""{
            let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("ALERT_NO_DATA_UPDATED", value: nil, table: nil)))
            self.presentViewController(alert, animated: true, completion: nil)
        
        }
        
        if usrInfoHasChanged {
            
            userCerc.nom = nomTextField.text
            userCerc.cognom = cognomTextField.text
            userCerc.mail = emailTextField.text
            userCerc.telefon = telfTextField.text
            userCerc.viusBcn = viusBcnSegmControl.selectedSegmentIndex
            UserCercle.saveUserCercleEntity(userCerc)
            
            let epochBirthday = userCerc.dataNeixament!.timeIntervalSince1970
            
            let params:[String:AnyObject] =
                ["name":userCerc.nom!,
                 "lastname":userCerc.cognom!,
                 "alias":userCerc.nom!,
                 "birthdate":epochBirthday,
                 "email":userCerc.mail!,
                 "phone":userCerc.telefon!,
                 "gender":userCerc.genere!,
                 "liveInBarcelona":userCerc.viusBcn!]
            
            VinclesApiManager.sharedInstance.updateUserInfoData(params) { (result) in
                
                if result == SUCCESS {
                    print("New info Saved")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_CANT_UPDATE_INFO", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        
        
        if (actualpassTextField.text != "") {
           
            if(actualpassTextField.text == Utils().getDecryptedPass(userCerc.password!, id: userCerc.id!)
                && passTextField.text == repeatPassTextField.text) {

                VinclesApiManager.sharedInstance.changeUserPassword(userCerc.password!, newPass: passTextField.text!, usrId: userCerc.id!) { (result) in
                    
                    if result == SUCCESS {
                        print("Password changed")
                        let encriptedPass = Utils().getEncryptedPass(self.passTextField.text!, id: self.userCerc.id!)
                        self.userCerc.password = NSData(bytes: encriptedPass, length: encriptedPass.count)
                        UserCercle.saveUserCercleEntity(self.userCerc)
                        
                        self.dismissViewControllerAnimated(true, completion: nil)

                    } else {
                        let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_CANT_CHANGE_PASSWORD", value: nil, table: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                if (passTextField.text != repeatPassTextField.text) {
                    let alertPass = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_CANT_UPDATE_WRONG_PASS_LENGTH", value: nil, table: nil))
                    self.presentViewController(alertPass, animated: true, completion: nil)
                } else {
                    let alertPass = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_CANT_UPDATE_WRONG_PASS", value: nil, table: nil))
                    self.presentViewController(alertPass, animated: true, completion: nil)

                }
            }
        }
    }
    
    func textFieldDidChange(textField:UITextField) {
        checkValidData()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField.tag {
        case 0:
            if nomTextField.text != "" {
                warningImgNom.hidden = true
                if nomTextField.text != userCerc.nom! {
                    usrInfoHasChanged = true
                }
            }else{
                warningImgNom.hidden = false
            }
        case 1:
            if cognomTextField.text != "" {
                warningImgCognom.hidden = true
                if cognomTextField.text != userCerc.cognom! {
                    usrInfoHasChanged = true
                }
            }else{
                warningImgCognom.hidden = false
            }
        case 2:
            if emailTextField.text != "" {
                if Utils().isValidEmail(emailTextField.text!){
                    warningImgEmail.hidden = true
                    if emailTextField.text != userCerc.mail! {
                        usrInfoHasChanged = true
                    }
                }else{
                    warningImgEmail.hidden = false
                }
            }else{
                warningImgEmail.hidden = true
            }
        case 3:
            if telfTextField.text != ""  &&
                telfTextField.text?.characters.count == 9{
                warningImgTelf.hidden = true
                if telfTextField.text != userCerc.telefon! {
                    usrInfoHasChanged = true
                }
            }else{
                warningImgTelf.hidden = false
            }
        default:
            print("")
        }
    }
    
    func checkValidData() {
        if nomTextField.text != "" {
            validaCamposDict["nom"] = true
            warningImgNom.hidden = true
        }else{
            validaCamposDict["nom"] = false
            warningImgNom.hidden = false
        }
        if cognomTextField.text != "" {
            validaCamposDict["cognom"] = true
            warningImgCognom.hidden = true
        }else{
            validaCamposDict["cognom"] = false
            warningImgCognom.hidden = false
        }
        if emailTextField.text != "" {
            if Utils().isValidEmail(emailTextField.text!) {
                validaCamposDict["email"] = true
                warningImgEmail.hidden = true
            }else{
                validaCamposDict["email"] = false
                warningImgEmail.hidden = false
            }
        }else{
            validaCamposDict["email"] = true
            warningImgEmail.hidden = true
        }
        if telfTextField.text != "" &&
            telfTextField.text?.characters.count == 9 {
            validaCamposDict["telf"] = true
            warningImgTelf.hidden = true
        }else{
            validaCamposDict["telf"] = false
            warningImgTelf.hidden = false
        }
        
        if (actualpassTextField.text != ""){
            if ((actualpassTextField.text?.characters.count>=8 && actualpassTextField.text?.characters.count<=16) || actualpassTextField.text?.characters.count == 0) {
                validaCamposDict["actualpass"] = true
                warningImgActualPass.hidden = true
            } else {
                validaCamposDict["actualpass"] = false
                warningImgActualPass.hidden = false
                }
        }
        
        if (actualpassTextField.text != ""){
            if ((passTextField.text?.characters.count>=8 && passTextField.text?.characters.count<=16)) {
                validaCamposDict["pass"] = true
                warningImgPass.hidden = true
            } else {
                validaCamposDict["pass"] = false
                warningImgPass.hidden = false
            }
        }
        
        if (actualpassTextField.text != ""){
            if (passTextField.text?.characters.count>=8 && passTextField.text?.characters.count<=16 && passTextField.text == repeatPassTextField.text) {
                validaCamposDict["repeatpass"] = true
                warningImgRepeatPass.hidden = true
            } else {
                validaCamposDict["repeatpass"] = false
                warningImgRepeatPass.hidden = false
            }
        }
        
    }
    
    @IBAction func btnGuardarPressed(sender: UIButton) {
        
        var camposCorrectos = 0
        
        checkValidData()
        
        for (key,value) in validaCamposDict {
            switch key {
            case "nom":
                if value == true {
                    warningImgNom.hidden = true
                    camposCorrectos += 1
                }else{
                    warningImgNom.hidden = false
                }
            case "cognom":
                if value == true {
                    warningImgCognom.hidden = true
                    camposCorrectos += 1
                }else{
                    warningImgCognom.hidden = false
                }
            case "email":
                if value == true {
                    warningImgEmail.hidden = true
                    camposCorrectos += 1
                }else{
                    warningImgEmail.hidden = false
                }
            case "telf":
                if value == true {
                    warningImgTelf.hidden = true
                    camposCorrectos += 1
                }else{
                    warningImgTelf.hidden = false
                }
            case "actualpass":
                if value == true {
                    warningImgPass.hidden = true
                    camposCorrectos += 1
                }else{
                    warningImgPass.hidden = false
                }
            case "pass":
                if value == true {
                    warningImgPass.hidden = true
                    camposCorrectos += 1
                }else{
                    warningImgPass.hidden = false
                }
            case "repeatpass":
                if value == true {
                    warningImgRepeatPass.hidden = true
                    camposCorrectos += 1
                }else{
                    warningImgRepeatPass.hidden = false
                }
            default:
                if value == true {
                    camposCorrectos += 1
                }
                print(value)
            }
        }
        if camposCorrectos == 7 {
            saveEditedUserData()

        }
        else{
            if (actualpassTextField.text != "" && validaCamposDict["actualpass"] == false) {
                let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("ALERT_CANT_UPDATE_WRONG_PASS", value: nil, table: nil)))
                self.presentViewController(alert, animated: true, completion: nil)
            
            }
            
            if (passTextField.text != "" && validaCamposDict["pass"] == false || repeatPassTextField.text != "" && validaCamposDict["repeatpass"] == false || passTextField.text == "" && repeatPassTextField.text == "") {
                let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("ALERT_CANT_UPDATE_WRONG_PASS_LENGTH", value: nil, table: nil)))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
                
        }
    }
}
    
    
  



