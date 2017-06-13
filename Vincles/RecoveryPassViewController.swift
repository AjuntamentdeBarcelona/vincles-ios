/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class RecoveryPassViewController: VinclesVC, UITextFieldDelegate {
    
    @IBOutlet weak var correuLabel: UILabel!
    @IBOutlet weak var correu: UITextField!
    @IBOutlet weak var recuperarBtn: UIButton!
    @IBOutlet weak var correuWarning: UIImageView!
    
    var camposDict = ["correo":false]

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = RECOVERYPASS_VC
        setUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setUI() {
        
    correuLabel.text=(self.nibBundle?.localizedStringForKey("LOGIN_LABEL", value: nil, table: nil))!
        
    correu.delegate = self
    correu.keyboardType = .ASCIICapable
    addDoneButtonToKeyboard(correu)
    correu.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
    correuWarning.hidden = true
        
    recuperarBtn.setTitle(self.nibBundle?.localizedStringForKey("RECOVERY_PASS", value: nil, table: nil), forState: .Normal)

    }

    override func viewWillDisappear(animated: Bool) {
        correu.endEditing(true)
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkTextFieldsData()
        
    }
    
    func textFieldDidChange(textField:UITextField) {
        self.checkTextFieldsData()
        
    }
    
    func checkTextFieldsData() {

        if correu.text != "" {
            if Utils().isValidEmail(correu.text!) {
                camposDict["correo"] = true
                correuWarning.hidden = true
            }else{
                camposDict["correo"] = false
                correuWarning.hidden = false
            }
        }else{
            camposDict["correo"] = false
            correuWarning.hidden = false
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func recoveryButton(sender: AnyObject) {
        
        if (camposDict["correo"] == true){
            
            VinclesApiManager.sharedInstance.recoveryPass(correu.text!) { (result) in
                if result == "Recovery correct" {
                    print ("Recovery email sended")
                    
                    let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.nibBundle?.localizedStringForKey("ALERT_EMAIL_SENDED", value: nil, table: nil))!)
                    self.presentViewController(alert, animated: true, completion: nil)

                }
                if result == "Recovery error" {
                    print ("Recovery email error")
                    let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.nibBundle?.localizedStringForKey("ALERT_EMAIL_ERROR", value: nil, table: nil))!)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }

            
        }
        else{
            let alert = Utils().postAlert((self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!, message: (self.nibBundle?.localizedStringForKey("ALERT_EMAIL_INCORRECT", value: nil, table: nil))!)
            self.presentViewController(alert, animated: true, completion: nil)
        
        }
    }
    
}
