/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SwiftyJSON
import SVProgressHUD


class IntroSecondCodeVC: VinclesVC, UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    
    @IBOutlet weak var navBarCallBtn: UIBarButtonItem!
    @IBOutlet weak var navBackBtn: UIBarButtonItem!
    @IBOutlet weak var novaXarxaTitle: UILabel!
    @IBOutlet weak var introCodiText: UILabel!
    @IBOutlet weak var introCodeTitle: UILabel!
    @IBOutlet weak var codeTextfield: UITextField!
    @IBOutlet weak var relacioParentBtn: UIButton!
    @IBOutlet weak var relacioDropTableView: UITableView!
    @IBOutlet weak var unirmeXarxaBtn: UIButton!
    @IBOutlet weak var footerView: UIView!
    
    
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
        screenName = INTROSECONDCODE_VC
        setUI()
        self.hideKeyboardWhenTappedAround()
    }
    
    func setUI() {
        
        relacioDropTableView.delegate = self
        relacioDropTableView.dataSource = self
        relacioDropTableView.hidden = true
        codeTextfield.delegate = self
        codeTextfield.keyboardType = .ASCIICapable
        
        introCodiText.text = langBundle.localizedStringForKey("INTRO_CODE_TEXT", value: nil, table: nil)
        introCodeTitle.text = langBundle.localizedStringForKey("NET_CODE", value: nil, table: nil)
        relacioParentBtn.setTitle(langBundle.localizedStringForKey("BTN_RELATIONSHIP_TITLE", value: nil, table: nil), forState: .Normal)
        novaXarxaTitle.text = langBundle.localizedStringForKey("BTN_NEW_NET", value: nil, table: nil)

        relacioParentBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)
        
        parentescoData = [langBundle.localizedStringForKey("BTN_TABLE_HUSBAND", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_SON",value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_GRANDSON", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_PRO", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_FRIEND", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_VOLUNTEER", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_BROTHER", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_NEPHEW", value: nil, table: nil),
                          langBundle.localizedStringForKey("BTN_TABLE_OTHER", value: nil, table: nil)]
        
        unirmeXarxaBtn.setTitle(langBundle.localizedStringForKey("BTN_JOIN_NET", value: nil, table: nil), forState: .Normal)
        unirmeXarxaBtn.layer.cornerRadius = 4.0
        relacioParentBtn.layer.cornerRadius = 4.0
        introCodiText.layer.cornerRadius = 4.0
        footerView.backgroundColor = UIColor(hexString: HEX_DARK_BACK_FOOTER)
        
        
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
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
        
        let cell = relacioDropTableView.cellForRowAtIndexPath(indexPath)
        relacioParentBtn.setTitle(cell?.textLabel?.text,forState:.Normal)
        relacioDropTableView.hidden = true
        
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
            codeTextfield.resignFirstResponder()
            codigoRed = textField.text!
        }
        return true
    }
    
    @IBAction func navBackBtnPress(sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    @IBAction func unirmeXarxaBtnPress(sender: UIButton) {
        print("CODIGO \(codigoRed) RELACIÓ PARENT \(relacionParent)")
        
        codigoRed = codeTextfield.text!
        
        if codigoRed != "" && relacionParent != "" {
            APIacceptExistentUserInvitation()
        }else{
            showAlertController(langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), msg:langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_MESSAGE", value: nil, table: nil),act:langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil))
        }
    }
    
    @IBAction func relacioParentBtnPress(sender: UIButton) {
        
        if relacioDropTableView.hidden {
            relacioDropTableView.hidden = false
        }else{
            relacioDropTableView.hidden = true
        }
    }
    
    private func showAlertController(title:String,msg:String,act:String) {
        
        let alert = UIAlertController(title: title, message:msg, preferredStyle: .Alert)
        let action = UIAlertAction(title:act, style: .Default) { _ in
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true){}
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
                        
                        self.performSegueWithIdentifier("fromIntroSecond_WelcomeExtra", sender: nil)
                        
                    case 400..<500:
                        print("JSON = \(json)")
                        
                        if response.response!.statusCode == 409 {
                            let errorJson = JSON(json)
                            let dict = errorJson["errors"][0]
                            let errorCode = dict["code"].stringValue
                            
                            if errorCode  == "1301" { // incorrect code
                                SVProgressHUD.dismiss()
                                
                                self.introCodiText.text = self.langBundle.localizedStringForKey("ALERT_INTROCODE_INCORRECT_CODE_MESSAGE",value: nil, table: nil)
                                
                                self.codeTextfield.text = ""
                            }
                            if errorCode  == "1321" { // already added
                                SVProgressHUD.dismiss()
                                
                                self.introCodiText.text = self.langBundle.localizedStringForKey("ALERT_ALREADY_IN_CIRCLE_MESSAGE",value: nil, table: nil)
                            }
                            else {
                                SVProgressHUD.dismiss()
                                self.introCodiText.text = self.langBundle.localizedStringForKey("ALERT_INTROCODE_INCORRECT_CODE_MESSAGE",value: nil, table: nil)
                                
                                self.codeTextfield.text = ""                            }
                        }
                        
                    case let stat where stat > 499:
                        SVProgressHUD.dismiss()
                        
                        print("EXPLOSION STATUS CODE = \(response.response!.statusCode)")
                    default:
                        print("OTHER STATUS CODE = \(response.response!.statusCode)")
                        
                    }
                    
                case .Failure(let json):
                    if response.response?.statusCode != nil {

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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "fromIntroSecond_WelcomeExtra" {
            
        }
    }
    
    @IBAction func barCallBtnPress(sender: UIBarButtonItem) {
        if (userCercle.vincleSelected != nil){
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                SingletonVars.sharedInstance.initMenuHasToChange = true
                SingletonVars.sharedInstance.initDestination = .Trucant
                SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
                self.presentViewController(secondViewController, animated: true, completion:nil)
            }
        }
        else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_USERS_MESSAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
