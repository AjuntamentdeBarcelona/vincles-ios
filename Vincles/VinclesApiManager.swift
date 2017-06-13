/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD


class VinclesApiManager {
    var installationDone = false;
    static let sharedInstance = VinclesApiManager()

    func loginSelfUser(usrName:String, pwd:NSData, usrId: String) {
        let parameters = ["grant_type":"password",
                          "username":"\(usrName)\(USERNAME_SUFFIX)",
                          "password":"\(Utils().getDecryptedPass(pwd, id: usrId))"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST,URL_LOGIN,headers:LOGIN_HEADER_REQUEST,parameters:parameters, encoding:.URLEncodedInURL)
            .responseJSON { response in
                print(response.result)
                
                switch response.result {
                case .Success(let json):
                    print(response.response?.statusCode)
                    let resJSON = JSON(json)
                    
                    print("TOKEN = \(resJSON["access_token"].stringValue)")
                    
                    UserPreferences().saveAccessToken(resJSON["access_token"].stringValue)
                    
                case .Failure(let json):
                    
                    print(json)
                }
        }
    }
    
    func loginSelfUserWithCompletion(usrName:String, pwd:NSData, usrId: String, completion:((result:String) -> ())) {
        loginWithCompletion(usrName, pwd: Utils().getDecryptedPass(pwd, id: usrId), completion: completion)
    }
    
    func loginWithCompletion(usrName:String, pwd:String, completion:((result:String) -> ())) {
        let parameters = ["grant_type":"password",
                          "username":"\(usrName)\(USERNAME_SUFFIX)",
                          "password":"\(pwd)"]
        
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST,URL_LOGIN,headers:LOGIN_HEADER_REQUEST,parameters:parameters, encoding:.URLEncodedInURL)
            .responseJSON { response in
                print(response.result)
                
                switch response.result {
                case .Success(let json):
                    
                    switch response.response!.statusCode {
                    case 200..<400:
                        let resJSON = JSON(json)
                        print(response.response?.statusCode)
                        
                        UserPreferences().saveAccessToken(resJSON["access_token"].stringValue)
                        var tokenparaimprimir = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as! String
                        completion(result:"Logged")
                        
                    case 400..<500:
                        completion(result:"Error login")
                        print(json)
                        
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
                        print("FAILURE RESPONSE RESULT \(response.result)")
                    
                    }
                }
        }
    }
    
    func getUserInfoData(token:String,completion:((result:String,info:JSON) ->())) {
        
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        
        let headers = ["Authorization":"Bearer \(token!)"]
        let manag = NetworkManager.sharedInstance.defaultManager
        
        
        manag.request(.GET,URL_GET_USER_INFO,headers:headers,encoding:.JSON)
            
            .responseJSON { response in
        
                switch response.result {
                case .Success(let json):
                    
                    switch response.response!.statusCode {
                    case 200..<400:

                        print("ACCESS_TOKEN ENVIADO =", token)
                        
                        let resJSON = JSON(json)
                        
                        print(resJSON)

                        completion(result:"SUCCESS", info:resJSON)
                    case 400..<500:
                        completion(result:"ERROR", info: nil)
                        print(json)
                        
                    case let stat where stat > 500:
                        completion(result:"ERROR", info: nil)
                        print("EXPLOSION STATUS CODE = \(response.response!.statusCode)")
                        
                    default:
                        completion(result:"ERROR", info: nil)
                        print("OTHER STATUS CODE = \(response.response!.statusCode)")
                        print("JSON\(json)")
                    }
                    
                case .Failure(let json):
                    if response.response?.statusCode != nil {
                        // CERTIFICATE PROBLEM / OTHER PROBLEMS
                        print("STATUS CODE = \(response.response!.statusCode) RESULT = \(json)")
                        
                    }else{ // NO WIFI
                        print("FAILURE RESPONSE RESULT \(response.result)")
                        
                    }
                }
                
        }
    }

    
    func registerNewUser(parameters:[String: AnyObject],completion:((result:String) -> ())) {

        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST, URL_REGISTER_USER_VINCULAT,headers:JSON_HEADER_PUBLIC_REQUEST, parameters:parameters,encoding:.JSON)
        
        .responseJSON { response in
        
            switch response.result {
                case .Success(let json):
                print("STATUS CODE \(response.response!.statusCode)")
                switch response.response!.statusCode {
                case 200..<400:
                    let resJSON = JSON(json)
                    print(response.response?.statusCode)
                    print("TOKEN = \(resJSON["id"].stringValue)")
                    completion(result:"Registered")
                
                case 400..<500:
                    print(json)
                    completion(result:"AlreadyInUse")
                    
                case let stat where stat > 500:
                    print("EXPLOSION STATUS CODE = \(response.response!.statusCode)")
                    completion(result:"Error register")
                    
                default:
                    print("OTHER STATUS CODE = \(response.response!.statusCode)")
                    print("JSON\(json)")
                    completion(result:"Error register")
                }
                
            case .Failure(let json):
                if response.response?.statusCode != nil {
                    // CERTIFICATE PROBLEM / OTHER PROBLEMS
                    print("STATUS CODE = \(response.response!.statusCode) RESULT = \(json)")
                    completion(result:"Error register")
                    
                }else{ // NO WIFI
                    print("FAILURE RESPONSE RESULT \(response.result)")
                    completion(result:"Error register")
                    
                }
                

            }
        }
    }
    
    func validateNewUser(email:String,code:String,completion:((result:String) -> ())) {
        
                let parameters = ["email":"\(email)",
                                  "code":"\(code)"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST, URL_VALIDATE_USER_VINCULAT,headers:JSON_HEADER_PUBLIC_REQUEST, parameters:parameters,encoding:.JSON)
            
            .responseJSON { response in
                
                switch response.result {
                case .Success(let json):
                    print("STATUS CODE \(response.response!.statusCode)")
                    switch response.response!.statusCode {
                    case 200..<400:
                        let resJSON = JSON(json)
                        let userCercle:UserCercle = {
                            UserCercle.loadUserCercleCoreData()
                            }()!
                        
                        print("ASSIGN NEW UserCercleID = \(resJSON["id"].stringValue)")
                        userCercle.id = resJSON["id"].stringValue
                        userCercle.active = true
                        
                        // RE-ADD PASSWORD CIPHERED
                        let encriptedPass = Utils().getEncryptedPass(
                            Utils().getDecryptedPass(userCercle.password!, id: "your-key"),
                            id: userCercle.id!)
                        userCercle.password = NSData(bytes: encriptedPass, length: encriptedPass.count)
                        
                        UserCercle.saveUserCercleEntity(userCercle)

                        completion(result:"Correct verification")
                        
                    case 400..<500:
                        completion(result:"Error verification")
                        print(json)
                        
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
                        print("FAILURE RESPONSE RESULT \(response.result)")
                        
                    }
                    
                }
        }
    }


    
    
    func sendMessageWithBinary(binary:NSData,usrFrom:String,usrTo:String,
                               mime:String,msgType:String,text:String,completion:((result:String) -> ())) {
        
        uploadContent(binary, usrFrom: usrFrom, usrTo: usrTo, mime: mime, msgType: msgType,text: text,completion: { response,contentID in
            
            if response == "Upload completed" {
                let idContentArry = [contentID]
                let parameters:[String: AnyObject] =
                    ["idUserFrom":usrFrom,
                        "idUserTo":usrTo,
                        "text":text,
                        "idAdjuntContents":idContentArry,
                        "metadataTipus":msgType]
                
                print("UPLOAD CONTENT \(response) CONTENTid \(contentID)")
                completion(result: "UPLOAD OK")
                
                self.sendMessage(parameters,completion: { sendResponse,msgID in
                    
                    if sendResponse == "Message Send" {
                        completion(result: "Message Sent")
                    }
                    if sendResponse == "Error sending Message" {
                        completion(result: "Error sending message")
                    }
                })
            }else{
                if response == "Upload failed" {
                    completion(result: "UPLOAD FAILED")
                }
                if response == "Upload failed/No Wifi" {
                    completion(result: "Upload failed/No Wifi")
                }
            }
        })
    }
    
    func uploadContent(binary:NSData,usrFrom:String,usrTo:String,
                       mime:String,msgType:String,text:String,completion:((uploadResult:String,contentID:String) -> ())) {
        
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        
        let fileName = "user\(usrFrom)binary"
        
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.upload(.POST,URL_UPLOAD_CONTENT,headers:headers, multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data:binary,name:"file",fileName:fileName,mimeType:mime)
            },
                     encodingCompletion: { encodingResult in
                        print(encodingResult)
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                                    
                                    SVProgressHUD.showProgress(percent, status:"Enviant missatge")
                                }
                            }
                            upload.responseJSON { response in
                                switch response.result {
                                case .Success(let json):
                                    print("JSON CONTENT UPLOADED \(json)")
                                    
                                  
                                    let resJson = JSON(json)
                                    
                                    
                                    completion(uploadResult: "Upload completed",contentID: resJson["id"].stringValue)
                                    
                                case .Failure(let json):
                                    print("FAIL \(json)")
                                    SVProgressHUD.dismiss()
                                    completion(uploadResult: "Upload failed/No Wifi",contentID: "XX")
                                    if response.response?.statusCode != nil { // CERTIFICATE PROBLEM / OTHER PROBLEMS
                                        if response.response!.statusCode == 401 { // not logged
                                            SVProgressHUD.dismiss()
                                            completion(uploadResult: "Upload failed/Not Logged",contentID: "XX")
                                            
                                        }else{ // NO WIFI
                                            SVProgressHUD.dismiss()
                                            completion(uploadResult: "Upload failed/No Wifi",contentID: "XX")
                                        }
                                    }
                                }
                            }
                        case .Failure(let encodingError):
                            print(encodingError)
                            
                            completion(uploadResult: "Upload failed",contentID: "XX")
                        }
            }
        )
    }
    
    func getContent(idContent:Int,completion:((binaryURL:NSURL?,result:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let idStr = String(idContent)
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)contents/\(idStr)"
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        var fileName: String?
        var finalPath: NSURL?
        
        manag.download(.GET, url,headers:headers) { (temporaryURL, response) in
            if response.statusCode != 0 {
                print(response.statusCode)
                if response.statusCode <= 201 {
                    if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                        fileName = response.suggestedFilename!
                        finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                        
                        let data = NSData(contentsOfURL:temporaryURL)
                        data?.writeToFile(finalPath!.path!, atomically: true)
                        completion(binaryURL:finalPath!, result: "SUCCESS")
                        return finalPath!
                    }
                }else{
                    completion(binaryURL:finalPath!, result: "FAILURE")
                }
            }else{
                
                completion(binaryURL:finalPath!, result: "FAILURE")
                
            }
            return temporaryURL
        }
    }
    
    func deleteContent(idContent:Int) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let manag = NetworkManager.sharedInstance.defaultManager
        let url = "\(URL_BODY)contents/\(idContent)"
        
        manag.request(.DELETE,url,headers:headers,encoding:.JSON)
            .response { response in
                
                if response.1?.statusCode != nil {
                    print("DELETE CONTENT \(response.1!.description)")
                    if response.1!.statusCode <= 201 {
                        
                    }else{
                        
                    }
                }else{
                    
                }
        }
    }
    
    func sendMessage(parameters:[String: AnyObject],completion:((sendResult:String,messageID:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST,URL_SEND_MESSAGE,headers:headers,parameters:parameters, encoding:.JSON)
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    print("MESSAGE SENT \(json)")
                    let resJson = JSON(json)
                    
                    completion(sendResult:"Message Send",messageID:resJson["id"].stringValue)
                    
                case .Failure(let json):
                    print(json)
                    completion(sendResult: "Error sending Message",messageID:"")
                }
        }
    }
    
    func deleteMessage(msgID:String,completion:((result:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let deleteUrl = "\(URL_BODY)messages/\(msgID)"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.DELETE,deleteUrl,headers:headers,encoding:.JSON)
            
            .response { response in
                if response.1?.statusCode != nil {
                    print("DELETE MESSAGE RESPONSE \(response.1!.description)")
                    if response.1!.statusCode == 200 {
                        completion(result: "SUCCESS")
                    }else{
                        completion(result: "FAILURE")
                    }
                }else{
                    completion(result: "FAILURE")
                }
        }
    }
    
    func markMessageAsRead(msgID:String,completion:((result:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let manag = NetworkManager.sharedInstance.defaultManager
        let readUrl = "\(URL_BODY)messages/\(msgID)/watched"
        
        manag.request(.PUT,readUrl,headers:headers,encoding:.URLEncodedInURL )
            .response { response in
                if response.1?.statusCode != nil {
                    print("MARK AS READ 2 \(response.1!.statusCode)")
                    if response.1!.statusCode <= 201 {
                        
                        completion(result: "SUCCESS")
                        
                    }else{
                        completion(result: "FAILURE")
                    }
                }else{
                    completion(result: "FAILURE")
                }
        }
    }
    
    func addEventToAgenda(parms:[String:AnyObject],idCalendar:Int,completion:((result:String,eventID:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        let url = "\(URL_BODY)calendars/\(idCalendar)/events"
        let manag = NetworkManager.sharedInstance.defaultManager
        manag.request(.POST,url,headers:headers,parameters:parms,encoding:.JSON)
            .responseJSON { response in
                print("ADD EVENT \(response.description)")
                switch response.result {
                case .Success(let json):
                    if response.response!.statusCode <= 201 {
                        print("EVENT JSON \(json)")
                        let eventJSON = JSON(json)
                        completion(result: "SUCCESS",eventID:eventJSON["id"].stringValue)
                    }else{
                        completion(result: "FAILURE",eventID:"0")
                    }
                case .Failure(_):
                    completion(result: "FAILURE",eventID:"0")
                }
        }
    }
    
    func updateAgendaEvent(params:[String:AnyObject],idCalendar:Int,idEvent:Int,completion:((status:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        let url = "\(URL_BODY)calendars/\(idCalendar)/events/\(idEvent)"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.PUT,url,headers:headers,parameters:params,encoding:.JSON)
            
            .response { response in
                if response.1?.statusCode != nil {
                    print("UPDATE RESPONSE DESC \(response.1!.description)")
                    if response.1!.statusCode <= 299 {
                        
                        completion(status: SUCCESS)
                    }else{
                        completion(status: FAILURE)
                    }
                }
        }
    }
    
    func rememberCita(idCalendar:String,eventId:String,completion:((result:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)calendars/\(idCalendar)/events/\(eventId)/remember"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,url,headers:headers,encoding:.URL)
            
            .responseJSON { response in
                print("JSON REMEMBER \(response.response.debugDescription)")
            }
            .responseString(completionHandler: { str in
                print("response STR \(str.response.debugDescription)")
            })
    }
    
    func deleteCita(idCalendar:Int,idEvent:Int,completion:((status:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)calendars/\(idCalendar)/events/\(idEvent)"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.DELETE,url,headers:headers,encoding:.JSON)
            
            .response { response in
                
                if response.1?.statusCode != nil {
                    if response.1!.statusCode <= 201 {
                        completion(status: "SUCCESS")
                    }else{
                        completion(status: "FAILURE")
                    }
                }else{
                    completion(status: "FAILURE")
                }
        }
    }
    
    func getListOfEvents(idCalendar:Int,from:Int64,to:Int64,
                         completion:((status:String,json:JSON?) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let parameters = ["from":"\(from)",
                          "to":"\(to)"]
        let readUrl = "\(URL_BODY)calendars/\(idCalendar)/events"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,readUrl,headers:headers,parameters:parameters,encoding:.URL)
            
            .responseJSON { response in
                print(response.result)
                
                switch response.result {
                case .Success(let json):
                    
                    let resJson = JSON(json)
                    completion(status: "SUCCESS", json:resJson)
                    
                case .Failure(_):
                    
                    completion(status: "FAILURE", json:nil)
                }
        }
    }
    
    func registerNewInstallation(parameters:[String:String]) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        let manag = NetworkManager.sharedInstance.defaultManager
        manag.request(.POST,URL_ADD_DEVICE_INFO,headers:headers,parameters:parameters,encoding:.JSON)
            .responseString { response in
                switch response.result {
                case .Success(let str):
                    if response.response?.statusCode <= 299 {
                        self.installationDone = true
                        
                        print("DEVICE INFO ADDED \(str)")
                        let nsuserD = NSUserDefaults.standardUserDefaults()
                        var usrD = nsuserD.dictionaryForKey("install")
                        usrD!["firstInstallation"] = 1
                        nsuserD.setValue(usrD, forKey:"install")
                        
                        nsuserD.synchronize()
                        
                    }else{
                        print("Hi ha hagut un error amb l'intslació (POST) \(response.result.debugDescription)")
                    }
                case .Failure(let str):
                    print("FAILURE \(str)")
                    
                }
        }
    }
    
    func updateInstallation(parameters:[String:String]) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.PUT,URL_UPDATE_DEVICE_INFO,headers:headers,parameters:parameters,encoding:.JSON)
            
            .responseString { response in
                switch response.result {
                case .Success(let str):
                    if response.response?.statusCode <= 299 {
                        self.installationDone = true
                        print("DEVICE INFO UPDATED ADDED \(str) STATUS \(response.response?.statusCode)")
                    } else {
                        self.registerNewInstallation(parameters)
                    }
                    
                case .Failure(let str):
                    print("FAILURE UPDATED \(str)")
                }
        }
    }
    
    // unused
    func getListOfAllEvents(idCalendar:Int,completion:((status:String,json:JSON?) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let readUrl = "\(URL_BODY)calendars/\(idCalendar)/events"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,readUrl,headers:headers,encoding:.URL)
            
            .responseJSON { response in
                print("ALL EVENTS \(response.result)")
                
                switch response.result {
                case .Success(let json):
                    
                    let resJson = JSON(json)
                    completion(status: "SUCCESS", json:resJson)
                    
                case .Failure(let json):
                    print(json)
                    completion(status: "FAILURE", json:nil)
                }
        }
    }
    
    // unused
    func getMoreListOfAllEvents(idCalendar:Int,to:Int64,completion:((status:String,json:JSON?) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let paramaters = ["to":"\(to)"]
        let readUrl = "\(URL_BODY)calendars/\(idCalendar)/events"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,readUrl,headers:headers,parameters:paramaters, encoding:.URL)
            
            .responseJSON { response in
                
                switch response.result {
                case .Success(let json):
                    
                    let resJson = JSON(json)
                    completion(status: SUCCESS, json:resJson)
                    
                case .Failure(let json):
                    print(json)
                    completion(status: FAILURE, json:nil)
                }
        }
    }
    
    func getNotificationInfo(notiId:String,completion:((result:String,json:JSON?) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)notifications/\(notiId)"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,url,headers:headers)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let json):
                    if response.response!.statusCode <= 201 {
                        let dataJson = JSON(json)
                        completion(result: "SUCCESS",json:dataJson)
                        
                    }else{
                        completion(result: "FAILURE",json:nil)
                    }
                case .Failure(_):
                    completion(result: "FAILURE",json:nil)
                }
        }
    }
    
    func getAllNotificationFromApi(params:[String:AnyObject],completion:((result:String,json:JSON?) -> ())) {
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        
        manag.request(.GET,URL_GET_ALL_NOTIFICATIONS,headers:headers,parameters:params,encoding:.URL)
            
            .responseJSON { response in

                switch response.result {
                case .Success(let json):
                    switch response.response!.statusCode {
                    case 200..<400: //OK!
                        let myJson = JSON(json)
                        completion(result: SUCCESS, json: myJson)
                        
                    case 400..<500:
                        print("CODE 400 . 499")
                        SVProgressHUD.dismiss()
                    case let stat where stat > 499:
                        SVProgressHUD.dismiss()
                        print("CODE 499 +")
                    default:
                        print("Default")
                    }
                    
                case .Failure(_):
                    
                    completion(result: FAILURE, json: nil)
                    
                    if response.response?.statusCode != nil {
                        if response.response!.statusCode == 401 { // not logged
                        }
                    }else{
                        let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE",
                            value: nil, table: nil), message: langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE",
                                value: nil, table:nil))
                        
                    }
                    SVProgressHUD.dismiss()
                }
        }
        
        
    }
    
    func getMessage(id:String,completion:
        ((result:String,json:JSON?) ->  ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)messages/\(id)"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,url,headers:headers)
            
            .responseJSON { response in
                
                switch response.result {
                case .Success(let json):
                    if response.response!.statusCode <= 201 {
                        let dataJson = JSON(json)
                        completion(result: "SUCCESS",json:dataJson)
                        
                    }else{
                        completion(result: "FAILURE",json:nil)
                    }
                case .Failure(_):
                    completion(result: "FAILURE",json:nil)
                }
        }
    }
    
    func getEvent(idCalendar:String,idEvent:String,completion:
        ((result:String,json:JSON) ->  ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)calendars/\(idCalendar)/events/\(idEvent)"
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,url,headers:headers)
            
            .responseJSON { response in
                
                switch response.result {
                case .Success(let json):
                    if response.response!.statusCode <= 201 {
                        let dataJson = JSON(json)
                        completion(result: "SUCCESS",json:dataJson)
                        
                    }else{
                        completion(result: "FAILURE",json:nil)
                    }
                case .Failure(_):
                    completion(result: "FAILURE",json:nil)
                }
        }
    }
    
    
    func updateUserInfoData(params:[String:AnyObject],completion:((result:String) ->())) {
        
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        let manag = NetworkManager.sharedInstance.defaultManager
        
       
        manag.request(.PUT,URL_UPDATE_USER_INFO,headers:headers,parameters:params,encoding:.JSON)
            
            .responseString { response in
                switch response.result {
                case .Success(let str):
                    print("VIDEOTRUCADA \(str)")
                    completion(result: SUCCESS)
                case .Failure(let str):
                    print("VIDEOTRUCADA \(str)")
                    completion(result: FAILURE)
                }
        }
    }
    
    func getUserFullInfo(usrID:String,completion:((result:String,info:JSON) ->())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)users/\(usrID)/full"
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,url,headers:headers)
            
            .responseJSON { response in
                print("USR FULL INFO RESPONSE \(response.description)")
                switch response.result {
                case .Success(let json):
                    if response.response!.statusCode <= 201 {
                        let dataJson = JSON(json)
                        completion(result: SUCCESS,info:dataJson)
                        
                        print("USER FULL INFO \(dataJson)")
                        
                    }else{
                        completion(result: FAILURE,info:nil)
                    }
                case .Failure(_):
                    completion(result: FAILURE,info:nil)
                }
        }
    }
    
    func getUserProfilePhoto(idUser:String,completion:((result:String,binaryURL:NSURL?) ->())) {
        
        var fileName: String?
        var finalPath: NSURL?
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)"]
        let url = "\(URL_BODY)users/\(idUser)/photo" // test
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.download(.GET, url,headers:headers) { (temporaryURL, response) in
            
            if response.statusCode != 0 {
                print(response.debugDescription)
                if response.statusCode <= 201 {
                    if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                        fileName = response.suggestedFilename!
                        finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                        
                        let data = NSData(contentsOfURL:temporaryURL)
                        data?.writeToFile(finalPath!.path!, atomically: true)
                        completion(result: SUCCESS,binaryURL:finalPath!)
                        
                        return finalPath!
                    }
                }else{
                    completion(result:FAILURE,binaryURL:finalPath)
                }
            }else{
                completion(result:FAILURE,binaryURL:finalPath)
            }
            return temporaryURL
        }
    }
    
    func setMyProfilePhoto(binary:NSData,completion:((result:String) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")

        let headers = ["Authorization":"Bearer \(token!)"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.upload(.POST,URL_SET_PROFILE_PHOTO,headers:headers, multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(data:binary,name:"file",fileName:"profilePhoto",mimeType:PHOTO_MIME_JPG)
            },
                     encodingCompletion: { encodingResult in
                        print(encodingResult)
                        
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                                }
                            }
                            upload.responseJSON { response in
                                switch response.result {
                                case .Success(let json):
                                    print("JSON CONTENT UPLOADED \(json)")
                                    
                                    completion(result:SUCCESS)
                                    
                                case .Failure(let json):
                                    print("FAIL \(json)")
                                    completion(result:FAILURE)
                                }
                            }
                        case .Failure(let encodingError):
                            print(encodingError)
                            
                            completion(result:FAILURE)
                        }
            }
        )
    }
    
    func initializeVideoCall(idUser:String,idRoom:String,completion:((status:String) -> ()))
    {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        let params:[String:AnyObject] = ["idUser":idUser,
                                         "idRoom":idRoom]
        let url = "\(URL_BODY)videoconference/start"
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST,url,headers:headers,parameters:params,encoding:.JSON)
            
            .responseString { response in
                switch response.result {
                case .Success(let str):
                    print("VIDEOTRUCADA \(str)")
                    completion(status: SUCCESS)
                case .Failure(let str):
                    print("VIDEOTRUCADA \(str)")
                    completion(status: FAILURE)
                }
        }
    }
    
    func getMyVincles(completion:((status:String,json:JSON) -> ())) {
        
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        let header = ["Authorization":"Bearer \(token!)"]
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.GET,URL_CIRCLES_BELONG,headers:header, encoding:.JSON)
        
        
    }
    
    
    func cancelAllRequest() {
        
        SVProgressHUD.dismiss()
        
    }

    func changeUserPassword(currentPass:NSData, newPass:String, usrId: String, completion:((result:String) ->())) {
        let token = NSUserDefaults.standardUserDefaults().objectForKey("accessToken")
        
        let headers = ["Authorization":"Bearer \(token!)",
                       "Content-Type": "application/json"]
        let manag = NetworkManager.sharedInstance.defaultManager
        
        let params:[String:AnyObject] =
            ["currentPassword":Utils().getDecryptedPass(currentPass, id: usrId),
             "newPassword":newPass]
        
        
        manag.request(.POST,URL_CHANGE_USER_PASSWORD,headers:headers, parameters:params,encoding:.JSON)
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    if response.response!.statusCode <= 201 {
                        UserPreferences().saveAccessToken(json["signInInfo"]!!["access_token"]!! as! String)
                        completion(result: 	SUCCESS)
                        
                    }else{
                        print("CHANGEPASSWORD FAILURE \(json)")
                        completion(result: FAILURE)
                    }
                case .Failure(let json):
                    print("CHANGEPASSWORD FAILURE \(json)")
                    completion(result: FAILURE)
                }
        }
    }
    
    
    func logoutWithCompletion(token:String,completion:((result:String) -> ())) {
        
        let parameters = ["token_type_hint":"access_token",
                          "token":"\(token)"]
        
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST,URL_LOGOUT,headers:LOGOUT_HEADER_REQUEST,parameters:parameters, encoding:.URLEncodedInURL)
            .responseJSON { response in
                print(response.result)
                
                switch response.result {
                case .Success(let json):
                    
                    switch response.response!.statusCode {
                    case 200..<400:
                        let resJSON = JSON(json)
                        print(response.response?.statusCode)
                        
                        UserPreferences().saveAccessToken(resJSON["access_token"].stringValue)
                        completion(result:"Logout correct")
                        
                    case 400..<500:
                        completion(result:"Logout error")
                        print(json)
                        
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
                        print("FAILURE RESPONSE RESULT \(response.result)")
                        
                    }
                }
        }
    }
    
    func recoveryPass(email:String,completion:((result:String) -> ())) {
        
        let params:[String:AnyObject] =
            ["username":"\(email)"]
        
        print ("username = \(email)")
        
        let manag = NetworkManager.sharedInstance.defaultManager
        
        manag.request(.POST,URL_RECOVERY,headers:RECOVERY_HEADER_REQUEST,parameters:params,encoding:.JSON)
            .responseString { response in
                print(response.result)
    
                
                switch response.result {
                case .Success(let json):
                    
                    switch response.response!.statusCode {
                    case 200..<400:
                        print(response.response?.statusCode)
                        completion(result:"Recovery correct")
                        
                    case 400..<500:
                        print(response.response?.statusCode)
                        completion(result:"Recovery error")
                        print(json)
                        
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
                        print("FAILURE RESPONSE RESULT \(response.result)")
                        
                    }
                    completion(result:"Recovery error")
                }
        }
    }

}
