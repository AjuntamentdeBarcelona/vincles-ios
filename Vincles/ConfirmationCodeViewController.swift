/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import CoreData

class ConfirmationCodeViewController: VinclesVC {

    @IBOutlet weak var introcodeLabel: UILabel!
    @IBOutlet weak var introcodeTextfield: UITextField!
    @IBOutlet weak var introcodeButton: UIButton!
    @IBOutlet weak var codeWarningImg: UIImageView!
    @IBOutlet weak var resendEmail: UIButton!
    @IBOutlet weak var introcodeInfo: UILabel!
    @IBOutlet weak var resendEmailButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let langBundle:NSBundle = {
        
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
    }()!
    
    var correu = ""
    var codiconfirmacio = ""
    
    var userConfirmed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = CONFIRMATIONCODE_VC
        introcodeLabel.text = langBundle.localizedStringForKey("CONFIRMATION_CODE_LABEL", value: nil, table: nil)
        
        introcodeInfo.text = langBundle.localizedStringForKey("CONFIRMATION_CODE_INFO", value: nil, table: nil)
        
        introcodeTextfield.keyboardType = .ASCIICapable
        addDoneButtonToKeyboard(introcodeTextfield)
        
        resendEmailButton.setTitle(langBundle.localizedStringForKey("CONFIRMATION_RESEND_BUTTON", value: nil, table: nil), forState: .Normal)
        introcodeButton.setTitle(langBundle.localizedStringForKey("CONFIRMATION_CODE_BUTTON", value: nil, table: nil), forState: .Normal)
        backButton.setTitle(langBundle.localizedStringForKey("CONFIRMATION_BACK_BUTTON", value: nil, table: nil), forState: .Normal)
        
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func resendEmailButtonPress(sender: AnyObject) {
    
        let parameters: [String : AnyObject]
        
        let imgData = Utils().imageFromImgtoBase64(userCercle.fotoPerfil!)
        let epochBirthday = userCercle.dataNeixament!.timeIntervalSince1970
        
        parameters = ["email":userCercle.mail!,
                      "password": Utils().getDecryptedPass(userCercle.password!, id: "your-key"),
                      "name":userCercle.nom!,
                      "lastname":userCercle.cognom!,
                      "alias":userCercle.nom!,
                      "birthdate":epochBirthday,
                      "phone":userCercle.telefon!,
                      "gender":userCercle.genere!,
                      "liveInBarcelona":userCercle.viusBcn!,
                      "photoMimeType":userCercle.photoMimeType!,
                      "photo": imgData]
        
        
        VinclesApiManager().registerNewUser(parameters, completion: { (result) in
            
            if result == "Registered" {
                print ("Email sended")
                
                let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("EMAIL_SENDED", value: nil, table: nil)))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            if result == "Error register" {
                print ("Error sending email")
                
                let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("ERROR_EMAIL_SENDED", value: nil, table: nil)))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        })
    
    }
    
    @IBAction func backButtonPress(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let alert = UIAlertController(title: "\(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))", message: "\(langBundle.localizedStringForKey("ALERT_BACK_TEXT", value: nil, table: nil))", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "\(langBundle.localizedStringForKey("ALERT_LOGOUT_CONFIRM", value: nil, table: nil))", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
            
            self.resetCoreData()
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TermsConditionsVC") as! TermsConditionsVC
            self.presentViewController(vc, animated: true, completion: nil)
            
            appDelegate.window!.rootViewController = vc
            appDelegate.window!.makeKeyAndVisible()
            
            
        }))
        alert.addAction(UIAlertAction(title: "\(langBundle.localizedStringForKey("ALERT_LOGOUT_CANCEL", value: nil, table: nil))", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    
    }
    
    func resetCoreData (){
        
        UserCercle.deleteUserData()
        
    }
    
    
    func addDoneButtonToKeyboard(txtField:UITextField) {
        
        let bundle =  UserPreferences().bundleForLanguageSelected()
        
        let doneToolBar = UIToolbar(frame: CGRectMake(0,0,320,50))
        doneToolBar.barStyle = .Default
        doneToolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                             UIBarButtonItem.init(title:langBundle.localizedStringForKey("KEYBOARD_DONE_BTN", value: nil, table: nil), style: .Done, target: self, action: #selector(doneButtonClickedDismissKeyboard))]
        doneToolBar.sizeToFit()
        txtField.inputAccessoryView = doneToolBar
    }
    
    func doneButtonClickedDismissKeyboard() {
        self.view.endEditing(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUI() {

        
    }
    
    
    @IBAction func aceptarButtonPress(sender: AnyObject) {
        
        if introcodeTextfield.text != "" {
            codeWarningImg.hidden = true
            codiconfirmacio = introcodeTextfield.text!
            correu = userCercle.mail!
            
            let codisenselletra = String(codiconfirmacio.characters.dropFirst())
            
            VinclesApiManager().validateNewUser(correu, code: codisenselletra, completion: { (result) in
                
                if result == "Correct verification" {
                    print ("Correct verification")
                    
                    // UPDATE TOKEN WITH NEW USER VALIDATED LOGIN
                    VinclesApiManager().loginSelfUserWithCompletion(self.userCercle.username!, pwd: self.userCercle.password!, usrId: self.userCercle.id!, completion: { (result) in
                        
                        if result == "Logged" {
                            self.finishUpdateUserAndEnterApp();
                        }
                        
                        if result == "Error login" {
                            print("LOGIN ERROR")
                            let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.langBundle.localizedStringForKey("ALERT_EMAIL_PASS_INCORRECT", value: nil, table: nil)))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                    
                }else{
                    print("NO PUSH TOKEN, NO NOTIFICATIONS")
                }

                if result == "Error verification" {
                    print ("Error verification")
                    let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.langBundle.localizedStringForKey("ALERT_VERIFICATION_CODE_INCORRECT", value: nil, table: nil)))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
            })
        }
        else {
            codeWarningImg.hidden = false
            let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.langBundle.localizedStringForKey("ALERT_VERIFICATION_CODE_NEEDED", value: nil, table: nil)))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func finishUpdateUserAndEnterApp() {
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as! String
        
        VinclesApiManager.sharedInstance.setMyProfilePhoto(self.userCercle.fotoPerfil!) { (result) in
            if result == SUCCESS {
                print("UPDATE PHOTO SUCCESS")
            }else{
                print("UPDATE PHOTO FAILURE")
            }
        }
        
        // GET VENDOR ID VALUE
        let vendorID = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        let params = ["idUser":self.userCercle.id!,
                      "so":"IOS",
                      "imei":vendorID,
                      "pushToken":token]
        
        VinclesApiManager().registerNewInstallation((params))
        print("REGISTRATION SUCCESSFUL USRNAME \(self.userCercle.username!) PASSWORD \(self.userCercle.password!) GMC TOKEN \(token)")
        
        //GO TO PAGEROOTVC
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PageRootVC") as! PageRootViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
}
