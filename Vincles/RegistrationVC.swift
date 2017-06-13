/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import CoreData
import SVProgressHUD
import AVFoundation


class RegistrationVC: VinclesVC, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {
    
    var canRegister = false
    var camposCorrectos = 0
    
    @IBOutlet var bckgrndView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var idiomaAppLabel: UILabel!
    @IBOutlet weak var idiomaAppSegControl: UISegmentedControl!
    @IBOutlet weak var idiomaAppWarningImg: UIImageView!
    
    @IBOutlet weak var pickPhotoImageView: UIImageView!
    @IBOutlet weak var miFotoLabel: UILabel!
    @IBOutlet weak var miFotoWarningImg: UIImageView!
    
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var nombreLblWarningImg: UIImageView!
    
    @IBOutlet weak var apellidosLabel: UILabel!
    @IBOutlet weak var apellidosTextField: UITextField!
    @IBOutlet weak var apellLblWarningImg: UIImageView!
    
    @IBOutlet weak var fechaNacimientoLabel: UILabel!
    @IBOutlet weak var nacimientoDatePicker: UIDatePicker!
    @IBOutlet weak var fechaNacimientoWarnImg: UIImageView!
    
    @IBOutlet weak var correoElecLabel: UILabel!
    @IBOutlet weak var correoElecTextfield: UITextField!
    @IBOutlet weak var correoWarningImg: UIImageView!
    
    
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var passTextfield: UITextField!
    @IBOutlet weak var passWarningImg: UIImageView!
    
   
    @IBOutlet weak var repeatpassLabel: UILabel!
    @IBOutlet weak var repeatpassTextfield: UITextField!
    @IBOutlet weak var repeatpassWarningImg: UIImageView!
    
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var telefonoTextField: UITextField!
    @IBOutlet weak var telefonWarningImg: UIImageView!
    
    @IBOutlet weak var generoLabel: UILabel!
    @IBOutlet weak var generoSegControl: UISegmentedControl!
    @IBOutlet weak var generoWarningImg: UIImageView!
    
    @IBOutlet weak var vivesBcnLabel: UILabel!
    @IBOutlet weak var vivesBcnSegControl: UISegmentedControl!
    @IBOutlet weak var viusBcnWarningImg: UIImageView!
    
    @IBOutlet weak var registrarButton: UIButton!
    
    var camposDict = ["idioma":false,"foto":false,"nombre":false,"apellidos":false,
                      "fecha":false,"correo":false,"pass":false,"repeatpass":false,"teléfono":false,"género":false,"viveBCN":false]
    
    var managedObjectContext: NSManagedObjectContext!
    var minimumBirthDate:NSDate!
    
    
    var userCercle:UserCercle? = {
        UserCercle.loadUserCercleCoreData()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = REGISTRATION_VC
        scrollView.delegate = self
        
        
        self.setUIelements()
        self.fillDefaultsUIElements()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegistrationVC.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegistrationVC.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        nombreTextField.endEditing(true)
        apellidosTextField.endEditing(true)
        correoElecTextfield.endEditing(true)
        passTextfield.endEditing(true)
        repeatpassTextfield.endEditing(true)
        passTextfield.endEditing(true)
        repeatpassTextfield.endEditing(true)
        telefonoTextField.endEditing(true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        registrarButton.layer.cornerRadius = 4.0
    }
    
    func addDoneButtonToKeyboard(txtField:UITextField) {
        
        let bundle =  UserPreferences().bundleForLanguageSelected()
        
        let doneToolBar = UIToolbar(frame: CGRectMake(0,0,320,50))
        doneToolBar.barStyle = .Default
        doneToolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                             UIBarButtonItem.init(title:bundle.localizedStringForKey("KEYBOARD_DONE_BTN", value: nil, table: nil), style: .Done, target: self, action: #selector(doneButtonClickedDismissKeyboard))]
        doneToolBar.sizeToFit()
        txtField.inputAccessoryView = doneToolBar
    }
    
    func doneButtonClickedDismissKeyboard() {
        self.view.endEditing(true)
        
    }
    
    func setUIelements() {
        
        idiomaAppLabel.text = (self.nibBundle?.localizedStringForKey("APP_LANGUAGE", value: nil, table: nil))!
        miFotoLabel.text = (self.nibBundle?.localizedStringForKey("MY_PHOTO", value: nil, table: nil))!
        nombreLabel.text = (self.nibBundle?.localizedStringForKey("NAME", value: nil, table: nil))!
        apellidosLabel.text = (self.nibBundle?.localizedStringForKey("SURNAMES", value: nil, table: nil))!
        fechaNacimientoLabel.text = (self.nibBundle?.localizedStringForKey("BIRTH_DATE", value: nil, table: nil))!
        correoElecLabel.text = (self.nibBundle?.localizedStringForKey("EMAIL", value: nil, table: nil))!
        passLabel.text = (self.nibBundle?.localizedStringForKey("PASSWORD", value: nil, table: nil))!
        repeatpassLabel.text = (self.nibBundle?.localizedStringForKey("REPEAT_PASSWORD", value: nil, table: nil))!
        telefonoLabel.text = (self.nibBundle?.localizedStringForKey("TELF", value: nil, table: nil))!
        generoLabel.text = (self.nibBundle?.localizedStringForKey("GENDER", value: nil, table: nil))!
        vivesBcnLabel.text = (self.nibBundle?.localizedStringForKey("FROM_BCN", value: nil, table: nil))!
        
        generoSegControl.setTitle(self.nibBundle?.localizedStringForKey("GENDER_MAN", value: nil, table: nil), forSegmentAtIndex: 0)
        generoSegControl.setTitle(self.nibBundle?.localizedStringForKey("GENDER_WOMAN", value: nil, table: nil), forSegmentAtIndex: 1)
        
        if ((self.nibBundle?.resourcePath?.rangeOfString("ca-ES.lproj")) == nil) {
                        nacimientoDatePicker.locale = NSLocale(localeIdentifier: "es_ES")
                    } else {
                        nacimientoDatePicker.locale = NSLocale(localeIdentifier: "ca_ES")
                    }

        
        bckgrndView.backgroundColor = UIColor(hexString:HEX_WHITE_BACKGROUND)
        nombreTextField.delegate = self
        nombreTextField.keyboardType = .ASCIICapable
        addDoneButtonToKeyboard(nombreTextField)
        nombreTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        apellidosTextField.delegate = self
        apellidosTextField.keyboardType = .ASCIICapable
        addDoneButtonToKeyboard(apellidosTextField)
        apellidosTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        correoElecTextfield.delegate = self
        correoElecTextfield.keyboardType = .EmailAddress
        addDoneButtonToKeyboard(correoElecTextfield)
        correoElecTextfield.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        passTextfield.delegate = self
        passTextfield.keyboardType = .ASCIICapable
        addDoneButtonToKeyboard(passTextfield)
        passTextfield.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        repeatpassTextfield.delegate = self
        repeatpassTextfield.keyboardType = .ASCIICapable
        addDoneButtonToKeyboard(repeatpassTextfield)
        repeatpassTextfield.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        telefonoTextField.delegate = self
        telefonoTextField.keyboardType = .NumberPad
        addDoneButtonToKeyboard(telefonoTextField)
        telefonoTextField.addTarget(self, action: #selector(RegistrationVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        // date picker
        let currentDate = NSDate()
        let comps = NSDateComponents.init()
        comps.year = -14
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        minimumBirthDate = calendar?.dateByAddingComponents(comps, toDate: currentDate, options:[])
        nacimientoDatePicker.date = NSDate()

        idiomaAppSegControl.selectedSegmentIndex = UISegmentedControlNoSegment
        generoSegControl.selectedSegmentIndex = UISegmentedControlNoSegment
        vivesBcnSegControl.selectedSegmentIndex = UISegmentedControlNoSegment
        
        miFotoLabel.backgroundColor = UIColor(hexString: HEX_DARK_GREY_MY_PHOTO_BTN)
        registrarButton.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        
        

    }
    
    func fillDefaultsUIElements() {
        if (userCercle != nil) {
            nombreTextField.text = userCercle!.nom
            apellidosTextField.text = userCercle!.cognom
            correoElecTextfield.text = userCercle!.mail
            telefonoTextField.text = userCercle!.telefon
            checkTextFieldsData(0)
            checkTextFieldsData(1)
            checkTextFieldsData(2)
            checkTextFieldsData(3)
            checkTextFieldsData(4)
            checkTextFieldsData(5)
            
            nacimientoDatePicker.date = userCercle!.dataNeixament!
            camposDict["fecha"] = true
            
            setUserImage(UIImage(data: userCercle!.fotoPerfil!)!)
            camposDict["foto"] = true
            
            if userCercle!.genere == "MALE" {
                generoSegControl.selectedSegmentIndex = 0
            } else {
                generoSegControl.selectedSegmentIndex = 1
            }
            camposDict["género"] = true
            
            if userCercle!.viusBcn == false {
                vivesBcnSegControl.selectedSegmentIndex = 0
            } else {
                vivesBcnSegControl.selectedSegmentIndex = 1
            }
            camposDict["viveBCN"] = true
            
            if NSUserDefaults.standardUserDefaults().valueForKey("language") != nil {
                let nsusr = NSUserDefaults.standardUserDefaults()
                let lang = nsusr.valueForKey("language") as! [NSString:Int]
                
                if lang["CatCast"] == 0 {
                    idiomaAppSegControl.selectedSegmentIndex = 0
                } else {
                    idiomaAppSegControl.selectedSegmentIndex = 1
                }
            } else {
                idiomaAppSegControl.selectedSegmentIndex = 1
            }
            camposDict["idioma"] = true
            
            correoWarningImg.hidden = false;
        }
    }
    
    func saveUserCercleToCoreData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        if (userCercle == nil) {
            let entity = NSEntityDescription.entityForName("UserCercle", inManagedObjectContext: managedObjectContext)
            userCercle = UserCercle(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        }

        let encriptedPass = Utils().getEncryptedPass(passTextfield.text!, id: "your-key")
        userCercle!.password = NSData(bytes: encriptedPass, length: encriptedPass.count)
        
        userCercle!.nom = nombreTextField.text
        userCercle!.cognom = apellidosTextField.text
        userCercle!.mail = correoElecTextfield.text
        userCercle!.username = correoElecTextfield.text
        userCercle!.telefon = telefonoTextField.text
        userCercle!.dataNeixament = nacimientoDatePicker.date
        userCercle!.active = false
        
        let photoData = UIImageJPEGRepresentation(pickPhotoImageView.image!, 0.1)
        
        userCercle!.fotoPerfil = photoData
        userCercle!.photoMimeType = PHOTO_MIME_JPG
        
        if generoSegControl.selectedSegmentIndex == 0 {
            userCercle!.genere = "MALE"
        }else{
            userCercle!.genere = "FEMALE"
        }
        if vivesBcnSegControl.selectedSegmentIndex == 0 {
            userCercle!.viusBcn = false
        }else{
            userCercle!.viusBcn = true
        }
        do {  // save to CoreData
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    

    func resetUserCercleForm() {
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let requestU = NSFetchRequest(entityName:"UserCercle")
        do{
            let resultsU = try managedContext.executeFetchRequest(requestU) as?[UserCercle]

            for i in 0 ..< resultsU!.count {
                managedContext.deleteObject(resultsU![i])
            }
            try managedContext.save()
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isValidPass1() -> Bool {
        
        var isValid=false
        let pass1 = self.passTextfield.text
        
        if pass1?.characters.count>=8 && pass1?.characters.count<=16{
            isValid = true
            //print("PASSWORD CORRECT")
        }
        else{
            isValid = false
            //print("PASSWORD INCORRECT")
        }
        return isValid
    }

    func isValidPass2() -> Bool {
        
        var isValid=false
        let pass1 = passTextfield.text
        let pass2 = repeatpassTextfield.text
        
        if pass1?.characters.count>=8 && pass1?.characters.count<=16 && pass1 == pass2{
            isValid = true
            //print("PASSWORD CORRECT")
        }
        else{
            isValid = false
            //print("PASSWORD INCORRECT")
        }
        return isValid
    }
    
    func changeLanguageOnTheFly() {
      let bundle =  UserPreferences().bundleForLanguageSelected()
        
        idiomaAppLabel.text = bundle.localizedStringForKey("APP_LANGUAGE", value: nil, table: nil)
        miFotoLabel.text = bundle.localizedStringForKey("MY_PHOTO", value: nil, table: nil)
        nombreLabel.text = bundle.localizedStringForKey("NAME", value: nil, table: nil)
        apellidosLabel.text = bundle.localizedStringForKey("SURNAMES", value: nil, table: nil)
        fechaNacimientoLabel.text = bundle.localizedStringForKey("BIRTH_DATE", value: nil, table: nil)
        correoElecLabel.text = bundle.localizedStringForKey("EMAIL", value: nil, table: nil)
        passLabel.text = bundle.localizedStringForKey("PASSWORD", value: nil, table: nil)
        repeatpassLabel.text = bundle.localizedStringForKey("REPEAT_PASSWORD", value: nil, table: nil)
        telefonoLabel.text = bundle.localizedStringForKey("TELF", value: nil, table: nil)
        generoLabel.text = bundle.localizedStringForKey("GENDER", value: nil, table: nil)
        generoSegControl.setTitle(bundle.localizedStringForKey("GENDER_MAN", value: nil, table: nil), forSegmentAtIndex: 0)
        generoSegControl.setTitle(bundle.localizedStringForKey("GENDER_WOMAN", value: nil, table: nil), forSegmentAtIndex: 1)
        vivesBcnLabel.text = bundle.localizedStringForKey("FROM_BCN", value: nil, table: nil)
        
        if ((bundle.resourcePath?.rangeOfString("ca-ES.lproj")) == nil) {
            nacimientoDatePicker.locale = NSLocale(localeIdentifier: "es_ES")
        } else {
            nacimientoDatePicker.locale = NSLocale(localeIdentifier: "ca_ES")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        setUserImage((info[UIImagePickerControllerOriginalImage] as? UIImage)!)
        dismissViewControllerAnimated(true, completion: nil)
        
        if camposDict["foto"] == false {
            camposDict["foto"] = true
            miFotoWarningImg.hidden = true
        }
    }
    
    func setUserImage(userImage: UIImage) {
        pickPhotoImageView.image = userImage
        
        // set user image view
        pickPhotoImageView.layer.borderWidth = 1.0
        pickPhotoImageView.layer.masksToBounds = false
        pickPhotoImageView.layer.borderColor = UIColor.clearColor().CGColor
        pickPhotoImageView.layer.cornerRadius = pickPhotoImageView.frame.size.height / 2
        pickPhotoImageView.clipsToBounds = true
        
        
    }
    
    // TEXTFIELD
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.checkTextFieldsData(textField.tag)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.checkTextFieldsData(textField.tag)
        
        return true
    }
    
    func textFieldDidChange(textField:UITextField) {
        
        self.checkTextFieldsData(textField.tag)
    }
    
    func checkTextFieldsData(tag:Int) {
        
        switch tag {
        case 0: // name
            if nombreTextField.text != "" {
                camposDict["nombre"] = true
                nombreLblWarningImg.hidden = true
            }else{
                nombreLblWarningImg.hidden = false
                camposDict["nombre"] = false
            }
        case 1: // surname
            if apellidosTextField.text != "" {
                camposDict["apellidos"] = true
                apellLblWarningImg.hidden = true
            }else{
                camposDict["apellidos"] = false
                apellLblWarningImg.hidden = false
            }
        case 2: // email
            if correoElecTextfield.text != "" {
                if Utils().isValidEmail(correoElecTextfield.text!) {
                    camposDict["correo"] = true
                    correoWarningImg.hidden = true
                }else{
                    camposDict["correo"] = false
                }
            }else{
                camposDict["correo"] = false
                correoWarningImg.hidden = false
            }
        case 3: // pass
            if passTextfield.text != "" {
                if isValidPass1() {
                    camposDict["pass"] = true
                    passWarningImg.hidden = true
                }else{
                    camposDict["pass"] = false
                    passWarningImg.hidden = false
                }
            }else{
                camposDict["pass"] = false
                repeatpassWarningImg.hidden = false
            }
        case 4: // repeatpass
            if repeatpassTextfield.text != "" {
                if isValidPass2() {
                    camposDict["repeatpass"] = true
                    repeatpassWarningImg.hidden = true
                }else{
                    camposDict["repeatpass"] = false
                    repeatpassWarningImg.hidden = false
                }
            }else{
                camposDict["repeatpass"] = false
                repeatpassWarningImg.hidden = false
            }
        case 5: // phone
            if telefonoTextField.text != "" {
                if telefonoTextField.text?.characters.count > 9 {
                    telefonWarningImg.hidden = false
                    
                }else{
                    if telefonoTextField.text?.characters.count == 9 {
                        camposDict["teléfono"] = true
                        telefonWarningImg.hidden = true
                    }
                }
            }else{
                camposDict["teléfono"] = false
                telefonWarningImg.hidden = false
            }
        default:
            print(tag)
        }
    }
    
    @IBAction func registrarButtonPressed(sender: UIButton) {
        
        camposCorrectos = 0
    
        for (key, value) in camposDict {
            switch key {
            case "idioma":
                if value == true {
                    idiomaAppWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    idiomaAppWarningImg.hidden = false
                }
            case "foto":
                if value == true {
                    miFotoWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    miFotoWarningImg.hidden = false
                }
            case "nombre":
                checkTextFieldsData(0)
                if value == true && nombreTextField.text != "" {
                    nombreLblWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    nombreLblWarningImg.hidden = false
                    camposDict["nombre"] = false
                }
            case "apellidos":
                checkTextFieldsData(1)
                if value == true && apellidosTextField.text != "" {
                    apellLblWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    apellLblWarningImg.hidden = false
                    camposDict["apellidos"] = false
                }
            case "fecha":
                if value == true {
                    fechaNacimientoWarnImg.hidden = true
                    camposCorrectos += 1
                } else {
                    fechaNacimientoWarnImg.hidden = false
                    
                    let alert = UIAlertController(title: self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), message: self.nibBundle?.localizedStringForKey("ALERT_REGISTER_AGE", value: nil, table: nil), preferredStyle: .Alert)
                    let action = UIAlertAction(title: self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil), style: .Default) { _ in
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true){}
                }
            case "correo":
                checkTextFieldsData(2)
                if value == true {
                    correoWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    correoWarningImg.hidden = false
                }
            case "pass":
                checkTextFieldsData(3)
                if value == true {
                    passWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    passWarningImg.hidden = false
                    
                    let alert = UIAlertController(title: self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), message: self.nibBundle?.localizedStringForKey("ALERT_INVALID_PASSWORD", value: nil, table: nil), preferredStyle: .Alert)
                    let action = UIAlertAction(title: self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil), style: .Default) { _ in
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true){}
                    
                }
            case "repeatpass":
                checkTextFieldsData(4)
                if value == true {
                    repeatpassWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    repeatpassWarningImg.hidden = false
                }
            case "teléfono":
                checkTextFieldsData(5)
                if value == true  && telefonoTextField.text != ""
                    && telefonoTextField.text?.characters.count == 9 {
                    telefonWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    telefonWarningImg.hidden = false
                    camposDict["teléfono"] = false
                }
            case "género":
                if value == true {
                    generoWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    generoWarningImg.hidden = false
                }
            case "viveBCN":
                if value == true {
                    viusBcnWarningImg.hidden = true
                    camposCorrectos += 1
                } else {
                    viusBcnWarningImg.hidden = false
                }
            default:
                print(value)
            }
        }
        if camposCorrectos == 11 {
            print("IS REGISTRABLE")
            
         
            let dataNeixament = nacimientoDatePicker.date
            let photoData = UIImageJPEGRepresentation(pickPhotoImageView.image!, 0.1)
            var genere=""
            if generoSegControl.selectedSegmentIndex == 0 {
                genere = "MALE"
            }else{
                genere = "FEMALE"
            }
            var viusBcn = false
            if vivesBcnSegControl.selectedSegmentIndex == 0 {
                viusBcn = false
            }else{
                viusBcn = true
            }
            
            let epochBirthday = dataNeixament.timeIntervalSince1970
            
            let parameters: [String : AnyObject]
            
            parameters = ["username":correoElecTextfield.text!,
                          "email":correoElecTextfield.text!,
                          "password":passTextfield.text!,
                          "name":nombreTextField.text!,
                          "lastname":apellidosTextField.text!,
                          "alias":nombreTextField.text!,
                          "birthdate":epochBirthday,
                          "phone":telefonoTextField.text!,
                          "gender":genere,
                          "liveInBarcelona":viusBcn,
                         ]


            
            VinclesApiManager().registerNewUser(parameters, completion: { (result) in
                
                if result == "Registered" {
                    print ("Registered")
                    
                    self.saveUserCercleToCoreData()
                    
                    //GO TO CONFIRM
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ConfirmationCodeVC") as! ConfirmationCodeViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                    
                }
                
                if result == "Error register" {
                    print ("Error register")
                    let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.nibBundle?.localizedStringForKey("ERROR_REGISTER", value: nil, table: nil))!)
                    self.presentViewController(alert, animated: true, completion: nil)
    
                }
                
                if result == "AlreadyInUse" {
                    print ("Error register_Email already in use")
                    let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.nibBundle?.localizedStringForKey("ERROR_ALREADYINUSE", value: nil, table: nil))!)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })


        } else {
            let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.nibBundle?.localizedStringForKey("ALERT_ALL_FIELDS_NEEDED", value: nil, table: nil))!)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func openPhotoLibrary(sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func datePickerUsed(sender: UIDatePicker) {
        if (sender.date.isLessThanDate(minimumBirthDate!)) {
            camposDict["fecha"] = true
            fechaNacimientoWarnImg.hidden = true
            print("LESS")
        }else{
            camposDict["fecha"] = false
            fechaNacimientoWarnImg.hidden = false
            print("MORE")
        }
    }
    
    @IBAction func segmentSelected(sender: UISegmentedControl) {
        switch sender.tag {
        case 0: // lenguage
            camposDict["idioma"] = true
            idiomaAppWarningImg.hidden = true
            
            let nsusr = NSUserDefaults.standardUserDefaults()
            var idiomaDic = nsusr.dictionaryForKey("language")
            idiomaDic!["CatCast"] = idiomaAppSegControl.selectedSegmentIndex
            nsusr.setValue(idiomaDic, forKey: "language")
            nsusr.synchronize()
            
            changeLanguageOnTheFly()
            
        case 1: // gender
            camposDict["género"] = true
            generoWarningImg.hidden = true
        case 2: // BCN
            camposDict["viveBCN"] = true
            viusBcnWarningImg.hidden = true
        default:
            print(sender.tag)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
    
    // Keyboard + move view on presenting keyboard
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size

        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 64 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
            
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        print ("SELFFRAMEORIGIN", view.frame.origin.y)
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if view.frame.origin.y != 0 {
            self.view.frame.origin.y += keyboardSize.height
            }
        }

        
    }

}
