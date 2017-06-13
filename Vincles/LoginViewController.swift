/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import Foundation
import CoreData


class LoginViewController: VinclesVC, UITextFieldDelegate {

    @IBOutlet weak var correuLabel: UILabel!
    @IBOutlet weak var correu: UITextField!
    @IBOutlet weak var contrasenyaLabel: UILabel!
    @IBOutlet weak var contrasenya: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var registrar: UIButton!
    @IBOutlet weak var recordarPass: UIButton!
    @IBOutlet weak var correoWarningImg: UIImageView!
    @IBOutlet weak var passwordWarningImg: UIImageView!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var managedObjectContext: NSManagedObjectContext!
    
    var userCercle:UserCercle? = {
        UserCercle.loadUserCercleCoreData()
    }()
    
    var camposDict = ["correo":false,"password":false]
    var camposCorrectos = 0
    var keyboardON = false
    var textViewHeight = CGFloat(0.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = LOGIN_VC
        setUI()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyBoardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUI() {
        
        self.navigationItem.title = (self.langBundle.localizedStringForKey("BTN_LOGIN_LABEL", value: nil, table: nil))
        
        correuLabel.text = (self.langBundle.localizedStringForKey("LOGIN_LABEL", value: nil, table: nil))
        
        correu.delegate = self
        correu.keyboardType = .ASCIICapable
        addDoneButtonToKeyboard(correu)
        correu.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        contrasenyaLabel.text = (self.langBundle.localizedStringForKey("PASSWORD_LABEL", value: nil, table: nil))
        
        contrasenya.delegate = self
        contrasenya.keyboardType = .ASCIICapable
        addDoneButtonToKeyboard(contrasenya)
        contrasenya.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        recordarPass.setTitle(self.langBundle.localizedStringForKey("RECOVERY_PASS", value: nil, table: nil), forState: .Normal)
        
        login.setTitle(self.langBundle.localizedStringForKey("BTN_LOGIN_LABEL", value: nil, table: nil), forState: .Normal)
        registrar.setTitle(self.langBundle.localizedStringForKey("BTN_LOGIN_NEW_USER", value: nil, table: nil), forState: .Normal)
        
        self.hideKeyboardWhenTappedAround()
        checkTextFieldsData(0)
        checkTextFieldsData(1)
        
    }
    
    //Textfield change
    func textFieldDidChange(textField:UITextField) {
        self.checkTextFieldsData(textField.tag)
        
    }
    //When user click Intro in keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //Textfield resigns
    func textFieldDidEndEditing(textField: UITextField) {
        checkTextFieldsData(0)
        checkTextFieldsData(1)
        textField.endEditing(true)
        
    }
    
    func doneButtonClickedDismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func checkTextFieldsData(tag:Int) {
        switch tag {
        case 0: // email
            if correu.text != "" {
                if Utils().isValidEmail(correu.text!) {
                    camposDict["correo"] = true
                }else{
                    camposDict["correo"] = false
                }
            }else{
                camposDict["correo"] = false
            }
            
        case 1: // password
            if contrasenya.text != "" {
                camposDict["password"] = true
                
            }else{
                camposDict["password"] = false
            }
        default:
            print(tag)
        }
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(testStr)
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
    
    @IBAction func recoveryPassButton(sender: AnyObject) {
        correu.endEditing(true)
        contrasenya.endEditing(true)
        
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        
        correu.endEditing(true)
        contrasenya.endEditing(true)
        var camposCorrectos = 0
        
        for (key, value) in camposDict {
            switch key {
            case "correo":
                checkTextFieldsData(0)
                if value == true {
                    correoWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    correoWarningImg.hidden = false
                }
            case "password":
                checkTextFieldsData(1)
                if value == true {
                    passwordWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    passwordWarningImg.hidden = false
                }
                default:
                print(value)
            }
        }
        
        if camposCorrectos == 2 {
            
            print("User can try login")
            
            //Login
            VinclesApiManager().loginWithCompletion(correu.text!, pwd: contrasenya.text!, completion: { (result) in
                    
                    if result == "Logged" {
                        print ("User loged")
                        
                        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as! String
                        
                        //Load data user
                        VinclesApiManager.sharedInstance.getUserInfoData(token) { (result, info) in
                            if result == SUCCESS {
                            print ("User data loaded")

                                
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                let managedObjectContext = appDelegate.managedObjectContext
                                
                                if (self.userCercle == nil) {
                                    let entity = NSEntityDescription.entityForName("UserCercle", inManagedObjectContext: managedObjectContext)
                                    self.userCercle = UserCercle(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
                                }
                                
                                
                                print ("NAME =", info["name"].stringValue)
                                
                                self.userCercle!.nom = "\(info["name"].stringValue)"
                                
                                
                                print ("ID = \(info["id"].stringValue)")
                                self.userCercle!.id = info["id"].stringValue
                                
                                if (self.userCercle!.id == nil || self.userCercle!.id == "") {
                                    print ("ERROR, API user info corrupted: \(info)")
                                    let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("ALERT_EMAIL_RETRIEVE_USER_FAIL", value: nil, table: nil)))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    return
                                }
                                
                                self.userCercle!.cognom = "\(info["lastname"].stringValue)"
                                self.userCercle!.genere = "\(info["gender"].stringValue)"
                                self.userCercle!.idInstallation = "\(info["idInstallation"].stringValue)"
                                self.userCercle!.idCircle = "\(info["idCircle"].stringValue)"
                                self.userCercle!.idLibrary = "\(info["idLibrary"].stringValue)"
                                self.userCercle!.idCalendar = "\(info["idCalendar"].stringValue)"
                                self.userCercle!.username = "\(info["username"].stringValue)"
                                self.userCercle!.dataNeixament = NSDate(timeIntervalSince1970:info["birthdate"].doubleValue)
                                self.userCercle!.mail = "\(info["email"].stringValue)"
                                self.userCercle!.telefon = "\(info["phone"].stringValue)"
                                self.userCercle!.viusBcn = (info["liveInBarcelona"].boolValue)
                                self.userCercle!.active = (info["active"].boolValue)
                                
                                let encriptedPass = Utils().getEncryptedPass(self.contrasenya.text!, id: info["id"].stringValue)
                                self.userCercle!.password = NSData(bytes: encriptedPass, length: encriptedPass.count)
                                
                                do {  // save to CoreData
                                    try managedObjectContext.save()
                                    
                                } catch let error as NSError {
                                    print("Could not save \(error), \(error.userInfo)")
                                }
                                
                                // ADD PICTURE TO USER PROFILE
                                self.getAPIUserPhoto(self.userCercle!)
                                
                                //GO TO PAGEROOTVC
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PageRootVC") as! PageRootViewController
                                self.presentViewController(vc, animated: true, completion: nil)

                            }else{
                                print ("User data loaded error")
                            }
                        }
                        
                    }
                    if result == "Error login" {
                        print ("User not loged")
                        let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("ALERT_EMAIL_PASS_INCORRECT", value: nil, table: nil)))
                        self.presentViewController(alert, animated: true, completion: nil)

                    }
                })

        } else {
            let alert = Utils().postAlert((self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil)), message: (self.langBundle.localizedStringForKey("ALERT_LOGIN_PASS_NEEDED", value: nil, table: nil)))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
   func keyBoardWillShow(notification: NSNotification) {
    
    if (self.keyboardON==false){
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        

        if  (self.keyboardON == false){
            
            self.keyboardON = true
    
            if(contrasenya.isFirstResponder() == true){
                self.textViewHeight = contrasenya.frame.origin.y
            }
            if (correu.isFirstResponder() == true){
                self.textViewHeight = contrasenya.frame.origin.y
            }

        }
        
        }
    }
        
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.keyboardON = false
        }

    }
    
    func getAPIUserPhoto(vincle:UserCercle) {
        
        VinclesApiManager.sharedInstance.getUserProfilePhoto(vincle.id!) { (result, binaryURL) in
            
            if result == SUCCESS {
                print("GET VINCLES PHOTO SUCCESS")
                let data = NSData(contentsOfURL: binaryURL!)
                let photoData = UIImageJPEGRepresentation(UIImage(data: data!)!, 0.1)
                vincle.fotoPerfil = photoData
                UserCercle.saveUserCercleEntity(vincle)
                
            }else{
                print("GET VINCLES PHOTO FAILURE")
            }
        }
    }
}


