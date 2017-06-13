/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import SVProgressHUD
import CoreData
import SwiftyJSON
import UIKit

class HowToVC: VinclesVC {
    
    @IBOutlet weak var labelPressHome: UILabel!
    @IBOutlet weak var labelPressCall: UILabel!
    @IBOutlet weak var tancarBtnLabel: UILabel!
    
    var steps = 1
    
    var vincles:[UserVincle] = {
        UserVincle.loadUserVincleCoreData()
    }()
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = HOWTO_VC
        labelPressHome.text = langBundle.localizedStringForKey("HOW_TO_HOME", value: nil, table: nil)
        labelPressCall.text = langBundle.localizedStringForKey("HOW_TO_CALL", value: nil, table: nil)
        tancarBtnLabel.text = langBundle.localizedStringForKey("CLOSE_BTN_LABEL", value: nil, table: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        SingletonVars.sharedInstance.lastNotiProcess = 0
        preloadAPIUserCercles()
    }
    
    func preloadAPIUserCercles() {
        SVProgressHUD.showWithStatus(langBundle.localizedStringForKey("LOADING_USER_DATA", value: nil, table: nil));
        
        var token = ""
        if let aToken = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") {
            token = aToken as! String
        } else {
            VinclesApiManager().loginSelfUser(userCercle.username!, pwd: userCercle.password!, usrId: userCercle.id!)
            token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as! String
            
        }
        
        let header = ["Authorization":"Bearer \(token)"]

        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,URL_CIRCLES_BELONG,headers:header, encoding:.JSON)
            
            .responseJSON { response in
                
                print("STATUS CODE \(response.response!.statusCode)")
                switch response.result {
                    case .Success(let json):

                        if json.count! > 0 {
                            self.addAllUsersInJSON(json)
                            self.steps += self.vincles.count
                            
                            self.preloadAPIMessages("0")
                            for i in 0 ..< self.vincles.count{
                                self.preloadAPIAgenda(self.vincles[i])
                            }
                            
                        }else{
                            SVProgressHUD.dismiss()
                            return
                        }
                        
                    case .Failure(let error):
                        print(error)
                        if response.response?.statusCode != nil {
                            // CERTIFICATE PROBLEM / OTHER PROBLEMS
                            print("STATUS CODE = \(response.response!.statusCode) RESULT = \(error)")
                            
                        } else { // NO WIFI
                            SVProgressHUD.dismiss()
                            print("FAILURE RESPONSE RESULT \(response.result)")
                            self.showAlertController(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil),
                                msg:self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table:nil), act:self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil))
                        }
                }
            }
    }
    
    func finishStep() {
        steps -= 1
        if (steps == 0) {
            SVProgressHUD.dismiss()
        }
    }
    
    func preloadAPIMessages(datefrom:String) {
        let to = Utils().milliSecondsSince1970(NSDate())
        preloadAPIMessagesRecursive(datefrom, dateto: String(to))
    }
    
    func preloadAPIMessagesRecursive(datefrom:String, dateto:String) {
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let parameters = ["from":"\(datefrom)",
                          "to":"\(dateto)"
        ]
        let header = ["Authorization":"Bearer \(token!)"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,URL_GET_MESSAGES,headers:header,parameters:parameters,encoding:.URL)
            
            .responseJSON { response in
                print(response.result)
                
                switch response.result {
                case .Success(let json):
                    switch response.response!.statusCode {
                    case 200..<400:
                        let myJson = JSON(json)
                        print("JSON DESCRITP \(myJson)")
                        if myJson.count == 10 {
                            self.addAllMessagesInJson(myJson)
                            self.preloadAPIMessagesRecursive(datefrom, dateto: String(myJson[9]["sendTime"]))
                        } else {
                            self.addAllMessagesInJson(myJson)
                            self.finishStep()
                        }
                    case 400..<500:
                        print("CODE 400 . 499")
                        SVProgressHUD.dismiss()
                    case let stat where stat > 499:
                        print("CODE 499 +")
                        SVProgressHUD.dismiss()
                    default:
                        print("Default")
                        SVProgressHUD.dismiss()
                    }
                    
                case .Failure(_):
                    let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE",
                        value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE",
                            value: nil, table:nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    func preloadAPIAgenda(userVincle:UserVincle) {
        let from = Utils().milliSecondsSince1970(NSDate())
        print ("FIRST CALL TO GET AGENDA: \(userVincle.idCalendar!) / from: \(from) / to 9999999999999")
        preloadAPIAgendaRecursive(userVincle, datefrom: from, dateto: 9999999999999)
    }
    
    func preloadAPIAgendaRecursive(userVincle:UserVincle, datefrom:Int64, dateto:Int64) {
        print ("USER: \(userVincle.idCalendar!) / from: \(datefrom) / to \(dateto)")
        VinclesApiManager.sharedInstance.getListOfEvents(Int(userVincle.idCalendar!)!, from: datefrom, to: dateto) { (status, json) in
            
            if status == "SUCCESS" {
                if json!.count == 10 {
                    self.addAllAgendaInJson(json!)
                    self.preloadAPIAgendaRecursive(userVincle, datefrom: datefrom,
                                                   dateto: json![9]["date"].int64Value)
                } else
                if json!.count != 0 {
                    self.addAllAgendaInJson(json!)
                    
                    sleep(1)
                    self.finishStep()
                } else {
                    print("EMPTY JSON")
                    self.finishStep()
                }
            }
            if status == "FAILURE" {
                let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func showAlertController(title:String,msg:String,act:String) {
        
        let alert = UIAlertController(title: title, message:msg, preferredStyle: .Alert)
        let action = UIAlertAction(title:act, style: .Default) { _ in
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true){}
    }
    
    func addAllAgendaInJson(json:JSON) {
        for i in 0 ..< json.count {
            Cita.addNewCitaToEntity(json[i])
        }
    }
    
    func addAllMessagesInJson(json:JSON) {
        for i in 0 ..< json.count {
            Missatges.addNewMissatgeToEntity(json[i])
        }
    }
    
    private func addAllUsersInJSON(json:AnyObject) {
        
        let vinclJson = JSON(json)
        
        for (index, object) in vinclJson {
            let name = object["circle"]
            print(name)
            addVinclesUser(name)
        }
        
        vincles = {
            UserVincle.loadUserVincleCoreData()
        }()
        
        if (vincles.count > 0) {
            self.userCercle.vincleSelected = vincles[0].id
            UserCercle.saveUserCercleEntity(self.userCercle)
        }
    }
    
    private func addVinclesUser(myJson: JSON) {
        
        // Add new User Vincles
        let userVincle = UserVincle.createBlankVinclesEntity()
        let vinclesDict = myJson["userVincles"]
        
        userVincle.id = vinclesDict["id"].stringValue
        userVincle.birthdate = NSDate(timeIntervalSince1970:vinclesDict["birthdate"].doubleValue)
        userVincle.email = vinclesDict["email"].stringValue
        userVincle.gender = vinclesDict["gender"].stringValue
        userVincle.idCalendar = vinclesDict["idCalendar"].stringValue
        userVincle.idCircle = vinclesDict["idCircle"].stringValue
        userVincle.idInstallation = vinclesDict["idInstallation"].stringValue
        userVincle.idLibrary = vinclesDict["idInstallation"].stringValue
        userVincle.lastname = vinclesDict["lastname"].stringValue
        userVincle.liveInBarcelona = vinclesDict["liveInBarcelona"].boolValue
        userVincle.name = vinclesDict["name"].stringValue
        userVincle.phone = vinclesDict["phone"].stringValue
        userVincle.username = vinclesDict["username"].stringValue
        userVincle.alias = vinclesDict["alias"].stringValue
        userVincle.eventsFirstLoad = 0
        
        
        // create connected to InitFeed
        let initFeedParams:[String:AnyObject] = [
            "userFrom":userVincle.id!,
            "date":Utils().getCurrentLocalDate(),
            "type":INIT_CELL_CONNECTED_TO,
            "vincleName":userVincle.name!,
            "vincleLastName":userVincle.lastname!,
            "isRead":false]
        
        InitFeed.addNewFeedEntityOffline(initFeedParams)
        UserVincle.saveUserVincleContext()
        
        getUserPhoto(userVincle)
    }
    
    func getUserPhoto(vincle:UserVincle) {
        
        VinclesApiManager.sharedInstance.getUserProfilePhoto(vincle.id!) { (result, binaryURL) in
            
            if result == SUCCESS {
                print("GET VINCLES PHOTO SUCCESS")
                let data = NSData(contentsOfURL: binaryURL!)
                let base64 = Utils().imageFromImgtoBase64(data!)
                vincle.photo = base64
                UserVincle.saveUserVincleContext()
                
            }else{
                print("GET VINCLES PHOTO FAILURE")
            }
        }
    }
}
