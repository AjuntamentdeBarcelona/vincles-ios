/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import CoreData

enum comeFromView {
    case RegistraVC
    case XarxesVC
    case NoXarxes
    
}

class IntroCodeViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var dropParenButton: UIButton!
    @IBOutlet weak var dropTableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var codigoLabel: UILabel!
    @IBOutlet weak var codigoTextField: UITextField!
    @IBOutlet weak var noCodeButton: UIButton!
    @IBOutlet weak var unirmeButton: UIButton!
    
    var comesFrom:comeFromView!
    var relacionParent = ""
    var codigoRed = ""
    
    var parentescoData:[String] = []
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        
        unirmeButton.layer.cornerRadius = 4.0
        
    }
    
    func setUI() {
        
        dropTableView.delegate = self
        dropTableView.dataSource = self
        dropTableView.hidden = true
        codigoTextField.delegate = self
        codigoTextField.keyboardType = .ASCIICapable
        
        if comesFrom! == comeFromView.NoXarxes {
            infoLabel.text = langBundle.localizedStringForKey("NO_XARXES_TEXT", value: nil, table: nil)
        }else{
            infoLabel.text = langBundle.localizedStringForKey("INTRO_CODE_TEXT", value: nil, table: nil)
        }
        codigoLabel.text = langBundle.localizedStringForKey("NET_CODE", value: nil, table: nil)
        dropParenButton.setTitle(langBundle.localizedStringForKey("BTN_RELATIONSHIP_TITLE", value: nil, table: nil), forState: .Normal)

        dropParenButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        
        parentescoData = [langBundle.localizedStringForKey("BTN_TABLE_HUSBAND", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_SON",value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_GRANDSON", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_PRO", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_FRIEND", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_VOLUNTEER", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_BROTHER", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_NEPHEW", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_OTHER", value: nil, table: nil)]
        
        noCodeButton.setTitle(langBundle.localizedStringForKey("BTN_NOCODE", value: nil, table: nil), forState: .Normal)
        unirmeButton.setTitle(langBundle.localizedStringForKey("BTN_JOIN_NET", value: nil, table: nil), forState: .Normal)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return parentescoData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "cell")
        cell.textLabel?.text = parentescoData[indexPath.row]
        
        return cell
        
    }
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let cell = dropTableView.cellForRowAtIndexPath(indexPath)
        dropParenButton.setTitle(cell?.textLabel?.text,forState:.Normal)
        dropTableView.hidden = true
        
        
        switch indexPath.row {
        case 0:// PARTNER
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_PARTNER
        case 1://CHILD
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_CHILD
        case 2:// GRANDCHILD
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_GRANDCHILD
        case 3:// CAREGIVER
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_CAREGIVER
        case 4:// FRIEND
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_FRIEND
        case 5:// VOLUNTEER
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_VOLUNTEER
        case 6: // BROTHER
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_BROTHER
        case 7: // NEPHEW
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_NEPHEW
        case 8:// OTHER
            print(parentescoData[indexPath.row])
            relacionParent = RELATION_OTHER
        default:
            print(parentescoData[indexPath.row])
        }
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.text != "" {
            codigoTextField.resignFirstResponder()
            codigoRed = textField.text!
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        codigoTextField.resignFirstResponder()
        if codigoTextField.text != ""{
            codigoRed = codigoTextField.text!
        
        }
        
    }
    
    @IBAction func dropButtonPressed(sender: UIButton) {
        
        if dropTableView.hidden {
            dropTableView.hidden = false
        }else{
            dropTableView.hidden = true
        }
    }
    
    func APIacceptInvitationUsuarioAnonimo() {
        
        // convert birthdayDate to epoch 1970
        let epochBirthday = userCercle.dataNeixament?.timeIntervalSince1970
        
        SVProgressHUD.showWithStatus("Carregant")
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        // Add user
        manag.request(.POST, URL_CREATE_PUBLIC_USER,headers:JSON_HEADER_PUBLIC_REQUEST, parameters: ["name":userCercle.nom!,"lastname":userCercle.cognom!,"birthdate":epochBirthday!,"email":userCercle.mail!,"phone":userCercle.telefon!,"gender":userCercle.genere!,"liveInBarcelona":userCercle.viusBcn!,"registerCode":codigoRed,"relationship":relacionParent],encoding:.JSON)
            
            .responseJSON { response in
                
                switch response.result {
                case .Success(let json):
                    print("STATUS CODE \(response.response!.statusCode)")
                    switch response.response!.statusCode {
                    case 200..<400:
                        
                        let myJson = JSON(json)
                        
                        // First Registration
                        if self.userCercle.password == nil || self.userCercle.username == nil  {
                            self.userCercle.username = myJson["loginInfo"]["username"].stringValue
                            //server Id's
                            self.userCercle.id = myJson["me"]["id"].stringValue
                            self.userCercle.idCircle = myJson["me"]["idCircle"].stringValue
                            self.userCercle.idCalendar = myJson["me"]["idCalendar"].stringValue
                            self.userCercle.idInstallation = myJson["me"]["idInstallation"].stringValue
                            self.userCercle.idLibrary = myJson["me"]["idLibrary"].stringValue
                            
                        }
                        let userVincle = UserVincle.createBlankVinclesEntity()
                        // Add new User Vincles
                        let vinclesDict = myJson["userVincles"]
                        
                        userVincle.birthdate = NSDate(timeIntervalSince1970:vinclesDict["birthdate"].doubleValue)
                        userVincle.email = vinclesDict["email"].stringValue
                        userVincle.gender = vinclesDict["gender"].stringValue
                        userVincle.id = vinclesDict["id"].stringValue
                        userVincle.idCalendar = vinclesDict["idCalendar"].stringValue
                        userVincle.idCircle = vinclesDict["idCircle"].stringValue
                        userVincle.idInstallation = vinclesDict["idInstallation"].stringValue
                        userVincle.idLibrary = vinclesDict["idInstallation"].stringValue
                        userVincle.lastname = vinclesDict["lastname"].stringValue
                        userVincle.liveInBarcelona = vinclesDict["liveInBarcelona"].boolValue
                        userVincle.name = vinclesDict["name"].stringValue
                        userVincle.alias = vinclesDict["alias"].stringValue
                        userVincle.phone = vinclesDict["phone"].stringValue
                        userVincle.eventsFirstLoad = 0
                        userVincle.username = vinclesDict["username"].stringValue
                        
                        self.userCercle.vincleSelected = vinclesDict["id"].stringValue
                        
                        // create connected to InitFeed
                        let initFeedParams:[String:AnyObject] = [
                            "userFrom":userVincle.id!,
                            "date":Utils().getCurrentLocalDate(),
                                "type":INIT_CELL_CONNECTED_TO,
                                "vincleName":userVincle.alias!,
                                "vincleLastName":"",
                                "isRead":false]
                        
                        InitFeed.addNewFeedEntityOffline(initFeedParams)
                        
                        SVProgressHUD.dismiss()
                        
                        VinclesApiManager().loginSelfUserWithCompletion(self.userCercle.username!, pwd: self.userCercle.password!, usrId: self.userCercle.id!, completion: { (result) in
                            
                            if result == "Logged" {
                                
                                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                    
                                    if appDelegate.registrationToken != nil {
                                        
                                        // GET VENDOR ID VALUE
                                        let vendorID = UIDevice.currentDevice().identifierForVendor!.UUIDString
                                        
                                        let params = ["idUser":self.userCercle.id!,
                                            "so":"IOS",
                                            "imei":vendorID,
                                            "pushToken":appDelegate.registrationToken!]
                                        
                                        VinclesApiManager().registerNewInstallation((params))
                                        print("REGISTRATION SUCCESSFUL USRNAME \(self.userCercle.username) PASWORD \(self.userCercle.password!) GMC TOKEN \(appDelegate.registrationToken!)")
                                        
                                    }else{
                                        print("NO PUSH TOKEN, NO NOTIFICATIONS")
                                    }
                                    
                                self.performSegueWithIdentifier("goToWelcome", sender: nil)
                            }
                            else if result == "Error login" {
                            }
                        })
                        
                    case 400..<500:
                        print("JSON = \(json)")
                        
                        if response.response!.statusCode == 409 {
                            SVProgressHUD.dismiss()
                            
                            let errorJson = JSON(json)
                            let dict = errorJson["errors"][0]
                            let errorCode = dict["code"].stringValue
                            
                            if errorCode  == "1301" { // incorrect code
                                self.infoLabel.text = self.langBundle.localizedStringForKey("ALERT_INTROCODE_INCORRECT_CODE_MESSAGE",value: nil, table: nil)
                                
                                self.codigoTextField.text = ""
                            }
                            else if errorCode == "1110" {   // incorrect email
                                let alert = Utils().postAlertWithCompletion(
                                    (self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!,
                                    message: (self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_DUPLICATED_EMAIL", value: nil, table: nil))!,
                                    pHandler: {_ in 
                                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RegistrationVC") as! RegistrationVC
                                        self.presentViewController(vc, animated: true, completion: nil)
                                })
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                        
                    case let stat where stat > 500:
                        print("EXPLOSION STATUS CODE = \(response.response!.statusCode)")
                        
                    default:
                        print("OTHER STATUS CODE = \(response.response!.statusCode)")
                        print("JSON\(json)")
                    }
                    
                case .Failure(let json):
                    if response.response?.statusCode != nil {
                        // CERTIFICATE PROBLEM / OTHER PROBLEMS
                        print("STATUS CODE = \(response.response!.statusCode) RESULT = \(json)")
                        
                    }else{ // NO WIFI
                        SVProgressHUD.dismiss()
                        print("FAILURE RESPONSE RESULT \(response.result)")
                        self.showAlertController(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil),
                            msg:self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table:nil), act:self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil))
                    }
                }
        }
        saveLocalUsersData()
    }
    
    func saveLocalUsersData() {
        
        UserCercle.saveUserCercleEntity(self.userCercle)
        UserVincle.saveUserVincleContext()
    }
    
    func APIacceptExistentUserInvitation() {
        var token = ""
        
        if let aToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") {
            token = aToken as! String
            print("ATOKEN \(aToken)")
        }else{
            VinclesApiManager().loginSelfUser(userCercle.username!, pwd: userCercle.password!, usrId: userCercle.id!)
            token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as! String
            
        }
        
        let parameters = ["registerCode":codigoRed,
                          "relationship":relacionParent]
        
        let header_AuthRequest = ["Authorization":"Bearer \(token)",
                                  "Content-Type":"application/json"]
        
        SVProgressHUD.show()
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST,URL_CREATE_EXIST_USER,headers:header_AuthRequest,parameters:parameters,encoding:.JSON)
            
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    
                    print("STATUS CODE \(response.response!.statusCode) RESULT = \(response.result)")
                    
                    switch response.response!.statusCode {
                    case 200..<400:
                        print("STATUS CODE \(response.response!.statusCode)")
                        
                        let myJson = JSON(json)
                        
                        // Add new User Vincles
                        let userVincle = UserVincle.createBlankVinclesEntity()
                        let vinclesDict = myJson["userVincles"]
                        
                        userVincle.birthdate = NSDate(timeIntervalSince1970:vinclesDict["birthdate"].doubleValue)
                        userVincle.email = vinclesDict["email"].stringValue
                        userVincle.gender = vinclesDict["gender"].stringValue
                        userVincle.id = vinclesDict["id"].stringValue
                        userVincle.idCalendar = vinclesDict["idCalendar"].stringValue
                        userVincle.idCircle = vinclesDict["idCircle"].stringValue
                        userVincle.idInstallation = vinclesDict["idInstallation"].stringValue
                        userVincle.idLibrary = vinclesDict["idInstallation"].stringValue
                        userVincle.lastname = vinclesDict["lastname"].stringValue
                        userVincle.liveInBarcelona = vinclesDict["liveInBarcelona"].boolValue
                        userVincle.name = vinclesDict["name"].stringValue
                        userVincle.alias = vinclesDict["alias"].stringValue
                        userVincle.phone = vinclesDict["phone"].stringValue
                        userVincle.username = vinclesDict["username"].stringValue
                        userVincle.eventsFirstLoad = 0
                        
                        // create connected to InitFeed
                        let initFeedParams:[String:AnyObject] = [
                            "userFrom":userVincle.id!,
                            "date":Utils().getCurrentLocalDate(),
                                "type":INIT_CELL_CONNECTED_TO,
                                "vincleName":userVincle.alias!,
                                "vincleLastName":"",
                                "isRead":false]
                        
                        InitFeed.addNewFeedEntityOffline(initFeedParams)
                        
                        SVProgressHUD.dismiss()
                        
                        UserVincle.saveUserVincleContext()
                        
                        self.userCercle.vincleSelected = userVincle.id
                        
                        UserCercle.saveUserCercleEntity(self.userCercle)
                        
                        self.performSegueWithIdentifier  ("goToWelcome", sender: nil)
                        
                    case 400..<500:
                        print("JSON = \(json)")
                        
                        if response.response!.statusCode == 409 {
                            let errorJson = JSON(json)
                            let dict = errorJson["errors"][0]
                            let errorCode = dict["code"].stringValue
                            
                            if errorCode  == "1301" { // incorrect code
                                SVProgressHUD.dismiss()
                                
                                self.infoLabel.text = self.langBundle.localizedStringForKey("ALERT_INTROCODE_INCORRECT_CODE_MESSAGE",value: nil, table: nil)
                                
                                self.codigoTextField.text = ""
                            }
                            if errorCode  == "1321" { // already added
                                SVProgressHUD.dismiss()
                                
                                self.infoLabel.text = self.langBundle.localizedStringForKey("ALERT_ALREADY_IN_CIRCLE_MESSAGE",value: nil, table: nil)
                            }
                            else if errorCode == "1110" {   // incorrect email
                                let alert = Utils().postAlert(
                                    (self.nibBundle?.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))!,
                                    message: (self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_DUPLICATED_EMAIL",
                                        value: nil, table: nil))!)
                                self.navigationController?.visibleViewController!.presentViewController(alert, animated: true, completion: {
                                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RegistrationVC") as! RegistrationVC
                                    self.presentViewController(vc, animated: true, completion: nil)
                                })
                            }
                        }
                        
                    case let stat where stat > 499:
                        SVProgressHUD.dismiss()
                        
                        print("EXPLOSION STATUS CODE = \(response.response!.statusCode)")
                    default:
                        print("OTHER STATUS CODE = \(response.response!.statusCode)")
                        
                    }
                    
                case .Failure(let json):
                    if response.response?.statusCode != nil {
                        // CERTIFICATE PROBLEM / OTHER PROBLEMS
                        print("STATUS CODE = \(response.response!.statusCode) RESULT = \(json)")
                        
                        if response.response!.statusCode == 401 { // not logged
                            SVProgressHUD.dismiss()
                            VinclesApiManager().loginSelfUser(self.userCercle.username!, pwd: self.userCercle.password!, usrId: self.userCercle.id!)
                            self.APIacceptExistentUserInvitation()
                        }
                        
                    }else{ // NO WIFI
                        SVProgressHUD.dismiss()
                        print("FAILURE RESPONSE RESULT \(response.result)")
                        self.showAlertController(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil),
                            msg:self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table:nil), act:self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil))
                    }
                }
        }
        
    }

    
    func getUserProfilePhoto(usrID:String) -> String {
        var strReturn = ""
        VinclesApiManager.sharedInstance.getUserProfilePhoto(usrID) { (result, binaryURL) in
            
            if result == SUCCESS {
                let data = NSData(contentsOfURL: binaryURL!)
                let bse64 = Utils().imageFromImgtoBase64(data!)
                strReturn = bse64
            }else{
                
            }
        }
        return strReturn
    }
    
    private func showAlertController(title:String,msg:String,act:String) {
        
        let alert = UIAlertController(title: title, message:msg, preferredStyle: .Alert)
        let action = UIAlertAction(title:act, style: .Default) { _ in
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true){}
    }
    
    @IBAction func unirmeBtnPressed(sender: UIButton) {
        codigoRed = codigoTextField.text!
        
        if codigoRed != "" && relacionParent != "" {
            
            let installPref = NSUserDefaults.standardUserDefaults().valueForKey("install") as! [NSString:Int]
            
            if installPref["firstInstallation"] == 0 {
                APIacceptInvitationUsuarioAnonimo()
            }else{
                APIacceptExistentUserInvitation()
            }
        }else{
            showAlertController(langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), msg:langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_MESSAGE", value: nil, table: nil),act:langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil))
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "goToWelcome" {
            
            let vc = segue.destinationViewController as! WelcomeViewController
            
            if comesFrom == comeFromView.RegistraVC {
                vc.goesTo = goesToView.TutorialVC
            }else{
                if comesFrom == comeFromView.NoXarxes {
                    vc.goesTo = goesToView.XarxesVC
                }
            }
            
        }
        if segue.identifier == "goTo_NoCode" {
            let vc = segue.destinationViewController as! NoCodeVC
            vc.comesFrom = comesFrom
            
        }
    }
}
