//
//  ApiClient.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import Alamofire
import SwiftyJSON

class ApiClient: ApiClientProtocol {
    static var manager: Alamofire.SessionManager = {
        
        // Create the server trust policies
        
        let serverTrustPolicies: [String: ServerTrustPolicy]
        if ProcessInfo.processInfo.environment.keys.contains("EnableSecurityProtocol"){
            
            serverTrustPolicies = [IP: ServerTrustPolicy.performDefaultEvaluation(validateHost: true)]
            
        }else {
            serverTrustPolicies = [IP: .disableEvaluation]
        }
        
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
   

        // configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        let oauth = OAuth2Handler()
        manager.retrier = oauth
        manager.adapter = oauth
        
        return manager
    }()
    
    
    
    static func loginWith(username: String, password: String, onSuccess: @escaping ApiClientProtocol.DictResponseCallback, onError: @escaping ApiClientProtocol.ErrorCallback) {
        let parameters = ["username": username, "password": password, "grant_type": "password" ]
        
        manager.request(ApiRouter.Login(params: parameters))
            .responseJSON { response in
                
                if let size = response.data?.count{
                   
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_LOGIN, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_LOGIN, size: sizeUp)
                }
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200, let data = response.result.value as? [String: AnyObject], let _ = data["access_token"] as? String, let _ = data["refresh_token"] as? String, let _ = data["expires_in"] as? Int {
                       onSuccess(data)
                    }
                    else if let status = response.response?.statusCode, status == 400{
                        onError(L10n.loginErrorData)
                    }
                    else{
                        onError(L10n.loginErrorServer)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func sendMigrationStatus(onSuccess: @escaping ApiClientProtocol.VoidCallback, onError: @escaping ApiClientProtocol.ErrorCallback) {
        
        
        manager.request(ApiRouter.SendMigrationStatus)
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_MIGRATION, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_MIGRATION, size: sizeUp)
                }
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    
    static func recoverPassword(username: String, onSuccess: @escaping VoidCallback, onError: @escaping ApiClientProtocol.ErrorCallback) {
        let parameters = ["username": username]
        
        manager.request(ApiRouter.RecoverPassword(params: parameters))
            .responseString { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_RECOVER_PASSWORD, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_RECOVER_PASSWORD, size: sizeUp)
                }
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                    
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    
    static func registerVinculat(email: String, password: String, name: String, lastname: String, birthdate: Int, phone: String, gender: String, liveInBarcelona: Bool, photoMimeType: String?, onSuccess: @escaping DictResponseCallback, onError: @escaping ErrorCallback) {
        
        let parameters = ["email": email, "password": password, "name": name, "lastname": lastname, "birthdate": birthdate, "phone": phone, "gender": gender, "liveInBarcelona": liveInBarcelona, "photo": "", "photoMimeType": photoMimeType ?? ""] as [String : Any]
        
        manager.request(ApiRouter.RegisterVinculat(params: parameters))
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_REGISTER, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_REGISTER, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func validateRegister(username: String, code: String, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        
        let parameters = ["email": username, "code": code ]
        manager.request(ApiRouter.ValidateVinculat(params: parameters))
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_VALIDATE_REGISTER, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_VALIDATE_REGISTER, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func cancelTasks(){
        manager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
            
            
            ContentManager.sharedInstance.downloadingIds.removeAll()
            ContentManager.sharedInstance.errorIds.removeAll()
            ContentManager.sharedInstance.corruptedIds.removeAll()
            ProfileImageManager.sharedInstance.downloadingIds.removeAll()
            ProfileImageManager.sharedInstance.errorIds.removeAll()
        }
        
    }
    static func logoutWith(token: String, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){
        let parameters = ["token": token, "token_type_hint": "access_token" ]

        manager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }

        
        manager.request(ApiRouter.Logout(params: parameters))
            .responseString { response in
                
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_LOGOUT, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_LOGOUT, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    
    static func getUserSelfInfo(onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        manager.request(ApiRouter.GetSelfUserInfo).validate()
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_USER_SELF_INFO, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_USER_SELF_INFO, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func getUserSelfInfoNoValidation(onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        manager.request(ApiRouter.GetSelfUserInfo).validate()
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_USER_SELF_INFO_NO_VALIDATION, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_USER_SELF_INFO_NO_VALIDATION, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }else if json["error"].stringValue == "invalid_token"{
                                let notification = VincleNotification()
                                notification.type = NOTI_TOKEN_EXPIRED
                                NotificationsModelManager().manageUnwatchedNotification(notification: notification, onProcessed: {_ in })
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
   
    static func getCirclesUser(onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){

        manager.request(ApiRouter.GetCirclesUser).validate()
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_CIRCLES, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_CIRCLES, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]]{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func getCirclesUserVinculat(onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){
        print("getCirclesUserVinculat")

        manager.request(ApiRouter.GetCirclesUserVinculat).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_CIRCLES_USER_VINCULAT, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_CIRCLES_USER_VINCULAT, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]]{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
   
    
    static func addContentToLibrary(contentId: Int, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        let parameters = ["idContent": contentId] as [String : Any]
        
        manager.request(ApiRouter.AddContentToLibrary(params: parameters)).validate()
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_ADD_CONTENT_TO_LIBRARY, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_ADD_CONTENT_TO_LIBRARY, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 201, let data = response.result.value as? [String: AnyObject]{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                    
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func removeContentFromLibrary(contentId: Int, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let parameters = ["contentId": contentId] as [String : Any]
        
        manager.request(ApiRouter.RemoveContentFromLibrary(params: parameters)).validate()
            .responseString { response in
            
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_REMOVE_CONTENT_FROM_LIBRARY, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_REMOVE_CONTENT_FROM_LIBRARY, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                    
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func getGroupsUser(onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){

        manager.request(ApiRouter.GetGroupsUser).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_GROUPS_USER, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_GROUPS_USER, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]]{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func generateCode(onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        manager.request(ApiRouter.GenerateCode).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GENERATE_CODE, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GENERATE_CODE, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject]{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    
    static func addCode(code: String, relationShip: String, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        let parameters = ["registerCode": code, "relationship": relationShip] as [String : Any]
        
        manager.request(ApiRouter.AddCode(params: parameters)).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_ADD_CODE, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_ADD_CODE, size: sizeUp)
                }
                
                switch response.result {
                case .success:

                    if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else if let data = response.result.value as? [String: AnyObject]{
                        onSuccess(data)
                        
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func removeContact(contactId: Int, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let parameters = ["contactId": contactId] as [String : Any]
        
        manager.request(ApiRouter.RemoveContact(params: parameters)).validate()
            .responseString { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_REMOVE_CONTACT, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_REMOVE_CONTACT, size: sizeUp)
                }
                
                
                switch response.result {
                case .success:
                    
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                    
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }else{
                                onError(L10n.errorGenerico)
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    
    static func removeContactFromVinculat(idCircle: Int, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let parameters = ["idCircle": idCircle] as [String : Any]
        
        manager.request(ApiRouter.RemoveContactFromVinculat(params: parameters)).validate()
            .responseString { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_REMOVE_CONTACT_FROM_VINCULAT, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_REMOVE_CONTACT_FROM_VINCULAT, size: sizeUp)
                }
                
                
                switch response.result {
                case .success:
                    
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                    
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func changeUserPhoto(imageData: Data, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        
        manager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
        }, with: ApiRouter.ChangeUserPhoto, encodingCompletion: {
            encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    
                    
                })
                upload.responseJSON { response in
                   
                    
                    if let data = response.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(response.value as! [String : AnyObject])
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }                }
            case .failure(let error):
                
                print(error.localizedDescription)
                onError(L10n.errorGenerico)
                
            }
        })
        
    }
    
    static func downloadProfilePicture(id: Int, size: CGFloat, onSuccess:  @escaping DataResponseCallback, onError:  @escaping ErrorCallback){

        if let url =  URL(string: URL_BASE + "/" + String(format: GET_USER_PROFILE_PHOTO_ENDPOINT, id)){
            
            var urlRequest = URLRequest(url: url)
            
            let authModelManager = AuthModelManager()
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
            
            self.manager.request(urlRequest).validate().responseData(queue: queue) { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_PROFILE_PICTURE, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_PROFILE_PICTURE, size: sizeUp)
                }
                
                if let imageData = response.result.value {
                    onSuccess(imageData)
                }
                else{
                    onError("error")
                    
                    print("error")
                }
                
                
            }
            
            
        }
        
        
    }
    
    static func downloadProfilePictureEvent(meetingId: Int, id: Int, size: CGFloat, onSuccess:  @escaping DataResponseCallback, onError:  @escaping ErrorCallback){

        if let url =  URL(string: URL_BASE + "/" + String(format: GET_USER_EVENT_PROFILE_PHOTO, meetingId, id)){
            
            var urlRequest = URLRequest(url: url)
            
            let authModelManager = AuthModelManager()
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
            
            self.manager.request(urlRequest).validate().responseData(queue: queue) { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_PROFILE_PICTURE_EVENT, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_PROFILE_PICTURE_EVENT, size: sizeUp)
                }
                
                
                if let imageData = response.result.value {
                    
                    DispatchQueue.global(qos:.userInteractive).async {
                        let image = UIImage(data: imageData)
                        
                        if let newImage = image?.resizeImage(newWidth: size){
                            DispatchQueue.main.async {
                                onSuccess(newImage.jpegData(compressionQuality: 0.6)!)
                            }
                        }
                        
                    }
                }
                
                
            }
            
            
        }
        
        
    }
    
    
    static func downloadGroupPicture(id: Int, size: CGFloat, onSuccess:  @escaping DataResponseCallback, onError:  @escaping ErrorCallback){

        if let url =  URL(string: URL_BASE + "/" + String(format: GET_GROUP_PHOTO_ENDPOINT, id)){
            
            var urlRequest = URLRequest(url: url)
            
            let authModelManager = AuthModelManager()
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
            
            self.manager.request(urlRequest).validate().responseData(queue: queue) { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GROUP_PICTURE, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GROUP_PICTURE, size: sizeUp)
                }
                
                
                if let imageData = response.result.value {
                    
                    DispatchQueue.global(qos:.userInteractive).async {
                        let image = UIImage(data: imageData)
                        
                        if let newImage = image?.resizeImage(newWidth: size){
                            DispatchQueue.main.async {
                                onSuccess(newImage.jpegData(compressionQuality: 0.6)!)
                            }
                        }
                    }
                    
                }
                
                
            }
            
        }
        
        
    }
    
    static func downloadGalleryPicture(id: Int, onSuccess:  @escaping MessageTypeResponseCallback, onError:  @escaping ErrorCallback){

        if let url =  URL(string: URL_BASE + "/" + String(format: GET_GALLERY_PHOTO_ENDPOINT, id)){
            
            var urlRequest = URLRequest(url: url)
            
            let authModelManager = AuthModelManager()
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
            self.manager.request(urlRequest).validate().responseData(queue: queue) { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GALLERY_PICTURE, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GALLERY_PICTURE, size: sizeUp)
                }
                
                
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    onError(error.localizedDescription)
                }
                
                if let mediaData = response.result.value {
                    if let contentType = response.response?.allHeaderFields["Content-Type"] as? String {
                        if contentType.contains("audio"){
                            onSuccess(mediaData, .audio)
                        }
                        else  if contentType.contains("video"){

                            onSuccess(mediaData, .video)
                        }
                        else  if contentType.contains("image"){
                            onSuccess(mediaData, .image)
                        }
                    }
                }
                
                
            }
        }
        
        
    }
    
    static func downloadGalleryVideo(id: Int, onSuccess:  @escaping DataResponseCallback, onError:  @escaping ErrorCallback){

        if let url =  URL(string: URL_BASE + "/" + String(format: GET_GALLERY_PHOTO_ENDPOINT, id)){
            
            var urlRequest = URLRequest(url: url)
            
            let authModelManager = AuthModelManager()
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
            
            self.manager.request(urlRequest).validate().responseData(queue: queue) { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GALLERY_VIDEO, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GALLERY_VIDEO, size: sizeUp)
                }
                
                
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    print("error downloadGalleryVideo \(id)")
                    onError(error.localizedDescription)
                }
                
                if let videoData = response.result.value {
                    onSuccess(videoData)
                }
                
                
            }
        }
        
    }
    
    static func downloadChatMediaItem(id: Int, onSuccess:  @escaping (MessageTypeResponseCallback), onError:  @escaping ErrorCallback){

        if let url =  URL(string: URL_BASE + "/" + String(format: GET_GALLERY_PHOTO_ENDPOINT, id)){
            
            var urlRequest = URLRequest(url: url)
            
            let authModelManager = AuthModelManager()
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
            
            self.manager.request(urlRequest).validate().responseData(queue: queue) { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_CHAT_MEDIA_ITEM, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_CHAT_MEDIA_ITEM, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    onError(error.localizedDescription)
                }
                
                if let mediaData = response.result.value {
                    
                    if let contentType = response.response?.allHeaderFields["Content-Type"] as? String {
                        if contentType.contains("audio"){
                            onSuccess(mediaData, .audio)
                        }
                        else  if contentType.contains("video"){
                            onSuccess(mediaData, .video)
                        }
                        else  if contentType.contains("image"){
                            onSuccess(mediaData, .image)
                        }
                    }
                    
                    
                }
                
                
            }
        }
        
    }
  
    
    static func shareContent(contentId: [Int], usersIds: [Int], chatIds: [Int], metadataTipus: [String], onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let metadataTipusString = metadataTipus.joined(separator: ",")
        let profileModelManager = ProfileModelManager()
        guard let id = profileModelManager.getUserMe()?.id else{
            onError(L10n.errorGenerico)
            return
        }
        
        let parameters = ["idUserFrom": id, "idUserToList": usersIds,  "idChatToList": chatIds, "idAdjuntContents": contentId, "metadataTipus": metadataTipusString,] as [String : Any]
     
        
        manager.request(ApiRouter.ShareContent(params: parameters)).validate()
            .responseJSON { response in

                if let size = response.data?.count{
                   DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_SHARE_CONTENT, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_SHARE_CONTENT, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if (response.result.value as? [String: AnyObject]) != nil{
                        onSuccess()
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func sendInstallation(so: String, pushToken: String, imei: String, idUser: Int, pushkitToken: String, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        let parameters = ["so": so, "pushToken": pushToken,  "pushkitToken": pushkitToken, "installationId": imei, "appVersion": version, "platformVersion": 2] as [String : Any]
        
        manager.request(ApiRouter.SendInstallation(params: parameters)).validate().responseJSON { response in
             
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 201, let dict = response.result.value as? [String:AnyObject], let id = dict["id"] as? Int{
                        UserDefaults.standard.set(id, forKey: "idInst")
                        onSuccess()
                    }
                    
                case .failure:

                    if let user = profileModelManager.getUserMe(){
                        let installationId = "\(UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: ""))\(user.id)"
                        ApiClient.getInstallations(params: ["installationId": installationId as AnyObject], onSuccess: {
                            self.updateInstallation(params: parameters as [String : AnyObject], onSuccess: {
                                
                            }, onError: { (error) in
                                
                            })
                        }) { (error) in
                            
                        }
                    }
                    
                    
                }
        }
        
    }
    
    static func getInstallations(params: [String:AnyObject], onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.GetInstallations(params: params)).validate()
            .responseJSON { response in
                
                
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200, let array = response.result.value as? [[String:AnyObject]]{
                        if array.count > 0{
                            let id = array[0]["id"] as? Int
                            UserDefaults.standard.set(id, forKey: "idInst")
                            
                            onSuccess()
                        }
                        else{
                            onError(L10n.errorGenerico)

                        }
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    
    static func updateInstallation(params: [String:AnyObject], onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.UpdateInstallation(params: params)).validate()
            .responseString { response in
                
              
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
  
   
    static func getChatUserMessages(params: [String:Any], onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.ChatUserGetMessages(params: params)).validate()
            .responseJSON { response in

                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_CHAT_USER_MESSAGES, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_CHAT_USER_MESSAGES, size: sizeUp)
                }
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]], let status = response.response?.statusCode, status == 200{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func getChatGroupMessages(params: [String:Any], onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.ChatGroupGetMessages(params: params)).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_CHAT_GROUP_MESSAGES, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_CHAT_GROUP_MESSAGES, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]], let status = response.response?.statusCode, status == 200{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    
    static func sendBadToken(onSuccess: @escaping VoidCallback, onError: @escaping ApiClientProtocol.ErrorCallback) {

        manager.request(ApiRouter.SendBadToken).validate()
            .responseJSON { response in
                
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]], let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure:
                    onError(L10n.errorGenerico)
                }
        }
    }
    
    static func getNotifications(from: Int64?, to: Int64? = nil, onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        var parameters = [String: AnyObject]()
        if let from = from{
            parameters["from"] = from as AnyObject
        }
        if let to = to{
            parameters["to"] = to as AnyObject
        }
        
        parameters["platform_version"] = 2 as AnyObject

        manager.request(ApiRouter.GetNotifications(params: parameters)).validate()
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_NOTIFICATIONS, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_NOTIFICATIONS, size: sizeUp)
                }
                
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]], let status = response.response?.statusCode, status == 200{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func getNotificationById(params: [String:Any], onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.GetNotificationById(params: params)).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_NOTIFICATION, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_NOTIFICATION, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let status = response.response?.statusCode, status == 200{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    
    static func markMessageWatched(params: [String:Any], onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.MarkMessageWatched(params: params)).validate()
            .responseString{ response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_MARK_MESSAGE_WATCHED, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_MARK_MESSAGE_WATCHED, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess([String:AnyObject]())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
  
 
    static func downloadGroupChatMediaItem(idMessage: Int, idChat: Int, onSuccess:  @escaping (MessageTypeResponseCallback), onError:  @escaping ErrorCallback){

        if let url =  URL(string: URL_BASE + "/" + String(format: GET_GROUP_CHAT_CONTENT, idChat, idMessage)){
            
            var urlRequest = URLRequest(url: url)
            
            let authModelManager = AuthModelManager()
            if let accessToken = authModelManager.getAccessToken(){
                urlRequest.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            let queue = DispatchQueue(label: "com.test.api", qos: .background, attributes: .concurrent)
            
            self.manager.request(urlRequest).validate().responseData(queue: queue) { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GROUP_CHAT_MEDIA_ITEM, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DOWNLOAD_GROUP_CHAT_MEDIA_ITEM, size: sizeUp)
                }
                
                switch response.result {
                case .success:
//                    print("success downloadGroupChatMediaItem \(url)")
                    break
                case .failure(let error):
//                    print("error downloadGroupChatMediaItem \(url)")

                    onError(error.localizedDescription)
                }
                
                if let mediaData = response.result.value {
                   
                    if let contentType = response.response?.allHeaderFields["Content-Type"] as? String {
                       
                        if contentType.contains("audio"){
                            onSuccess(mediaData, .audio)
                        }
                        else  if contentType.contains("video"){
                            onSuccess(mediaData, .video)
                        }
                        else  if contentType.contains("image"){
                            onSuccess(mediaData, .image)
                        }
                    }
                    
                    
                }
                
                
            }
        }
        
    }
    
    static func getUserBasicInfo(id: Int, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallbackExtended){

        let parameters = ["id": id] as [String : Any]
        
        manager.request(ApiRouter.GetUserBasicInfo(params: parameters)).validate()
            .responseJSON { response in
              
                
                switch response.result {
                case .success:
                    
                    if let status = response.response?.statusCode, status == 200, let data = response.result.value as? [String: AnyObject]{
                        onSuccess(data)
                    }
                        
                    else{
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError(), response.response?.statusCode ?? 0)
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                }
        }
    }
    
    static func getUserFullInfo(id: Int, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallbackExtended){

        let parameters = ["id": id] as [String : Any]
        
        manager.request(ApiRouter.GetUserFullInfo(params: parameters)).validate()
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_USER_FULL_INFO, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_USER_FULL_INFO, size: sizeUp)
                }
                
                
                switch response.result {
                case .success:
                    
                    if let status = response.response?.statusCode, status == 200, let data = response.result.value as? [String: AnyObject]{
                        onSuccess(data)
                    }
                        
                    else{
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError(), response.response?.statusCode ?? 0)
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                }
        }
    }
    
    
   
    static func getGroupParticipants(id: Int, onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallbackExtended){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico, 0)
            return
        }
        var parameters = [String: AnyObject]()
        parameters["id"] = id as AnyObject
        
        manager.request(ApiRouter.GetGroupParticipants(params: parameters)).validate()
            .responseJSON { response in
              
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_GROUP_PARTICIPANTS, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_GROUP_PARTICIPANTS, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]], let status = response.response?.statusCode, status == 200{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError(), response.response?.statusCode ?? 0)
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                }
        }
        
    }
    
    static func getMeetings(to: Int64?, onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        var parameters = [String: AnyObject]()
        if let to = to{
            parameters["to"] = to as AnyObject
        }
        parameters["send_rejected"] = false as AnyObject
        
        manager.request(ApiRouter.GetMeetings(params: parameters)).validate()
            .responseJSON { response in

                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_MEETINGS, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_MEETINGS, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [[String: AnyObject]], let status = response.response?.statusCode, status == 200{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    
    static func getMeeting(id: Int, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallbackExtended){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico, 0)
            return
        }
        var parameters = [String: AnyObject]()
        parameters["id"] = id as AnyObject
        
        manager.request(ApiRouter.GetMeeting(params: parameters)).validate()
            .responseJSON { response in
                
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_MEETING, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_MEETING, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let status = response.response?.statusCode, status == 200{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError(), response.response?.statusCode ?? 0)
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                }
        }
        
    }
    
    static func createMeeting(params: [String:Any] , onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        
        manager.request(ApiRouter.CreateMeeting(params: params)).validate()
            .responseJSON { response in
              
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_CREATE_MEETING, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_CREATE_MEETING, size: sizeUp)
                }
                
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let status = response.response?.statusCode, status == 201{
                        
                        
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func editMeeting(params: [String:Any] , onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        
        manager.request(ApiRouter.EditMeeting(params: params)).validate()
            .responseJSON { response in
               
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_EDIT_MEETING, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_EDIT_MEETING, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let status = response.response?.statusCode, status == 201{
                        
                        
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    
    static func updateUser(name: String, lastname: String, phone: String, liveInBarcelona: Bool, onSuccess: @escaping DictResponseCallback, onError: @escaping ErrorCallback) {

        let profileModelManager = ProfileModelManager()
        guard let user = profileModelManager.getUserMe() else{
            onError(L10n.errorGenerico)
            return
        }
        
        let parameters = ["email": user.email, "name": name, "lastname": lastname, "birthdate": Int64((user.birthdate.timeIntervalSince1970).rounded()) , "phone": phone, "gender": user.gender, "liveInBarcelona": liveInBarcelona, "alias": user.alias] as [String : Any]
        
        manager.request(ApiRouter.UpdateUser(params: parameters))
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_UPDATE_USER, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_UPDATE_USER, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    
    static func acceptEventInvitation(meetingId: Int, onSuccess: @escaping DictResponseCallback, onError: @escaping ErrorCallback) {
        
        let profileModelManager = ProfileModelManager()
        guard let user = profileModelManager.getUserMe() else{
            onError(L10n.errorGenerico)
            return
        }
        
        let parameters = ["id": meetingId] as [String : Any]
        
        manager.request(ApiRouter.AcceptMeeting(params: parameters))
            .responseJSON { response in

                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_ACCEPT_EVENT_INVITATION, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_ACCEPT_EVENT_INVITATION, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func declineEventInvitation(meetingId: Int, onSuccess: @escaping DictResponseCallback, onError: @escaping ErrorCallback) {
        
        let profileModelManager = ProfileModelManager()
        guard let user = profileModelManager.getUserMe() else{
            onError(L10n.errorGenerico)
            return
        }
        
        let parameters = ["id": meetingId] as [String : Any]
        
        manager.request(ApiRouter.DeclineMeeting(params: parameters))
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DECLINE_EVENT_INVITATION, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DECLINE_EVENT_INVITATION, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func deleteMeeting(meetingId: Int, onSuccess: @escaping DictResponseCallback, onError: @escaping ErrorCallback) {
        
        let profileModelManager = ProfileModelManager()
        guard let user = profileModelManager.getUserMe() else{
            onError(L10n.errorGenerico)
            return
        }
        
        let parameters = ["id": meetingId] as [String : Any]
        
        manager.request(ApiRouter.DeleteMeeting(params: parameters))
            .responseJSON { response in
                
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_DELETE_MEETING, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_DELETE_MEETING, size: sizeUp)
                }
                
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let _ = data["id"] as? Int{
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func getSpecificContent(params: [String:Any] , onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallbackExtended){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico, 0)
            return
        }
        
        
        manager.request(ApiRouter.GetSpecificContent(params: params)).validate()
            .responseJSON { response in
              
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_SPECIFIC_CONTENT, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_SPECIFIC_CONTENT, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let status = response.response?.statusCode, status == 200{
                        
                        
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError(), response.response?.statusCode ?? 0)
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico, response.response?.statusCode ?? 0)
                    }
                }
        }
        
    }
    
    static func cancelAll(){
        manager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
    
    static func startVideoConference(params: [String:Any] , onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
    manager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
        
        
        manager.request(ApiRouter.StartVideoConference(params: params)).validate()
            .responseString { response in
             
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_START_VIDEOCONFERENCE, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_START_VIDEOCONFERENCE, size: sizeUp)
                }
                print(response.response?.statusCode)
                
                switch response.result {
                    
                case .success:
                    if let status = response.response?.statusCode, status == 200{

                        
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    onError(L10n.errorGenerico)

                }
        }
        
    }
    
    static func errorVideoConference(params: [String:Any] , onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        
        manager.request(ApiRouter.ErrorVideoConference(params: params)).validate()
            .responseString { response in
               
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_ERROR_VIDEOCONFERENCE, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_ERROR_VIDEOCONFERENCE, size: sizeUp)
                }
                switch response.result {
                    
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        
                        
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    
    static func inviteUserFromGroup(groupId: Int, userId: Int, onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard let id = profileModelManager.getUserMe()?.id else{
            onError(L10n.errorGenerico)
            return
        }
        
        let parameters = ["idGroup": groupId, "idUser": userId] as [String : Any]

        manager.request(ApiRouter.InviteUserFromGroup(params: parameters)).validate()
            .responseJSON { response in

                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_INVITE_USER_FROM_GROUP, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_INVITE_USER_FROM_GROUP, size: sizeUp)
                }
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func getChatLastAccess(params: [String:Any], onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.GetChatLastAccess(params: params)).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_CHAT_LAST_ACCESS, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_CHAT_LAST_ACCESS, size: sizeUp)
                }
                switch response.result {
                    
                case .success:
                    if let status = response.response?.statusCode, status == 200, let data = response.value as? [String: AnyObject]{
                        onSuccess(data)
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func putChatLastAccess(params: [String:Any], onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){

        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.PutChatLastAccess(params: params)).validate()
            .responseJSON { response in
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_PUT_CHAT_LAST_ACCESS, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_PUT_CHAT_LAST_ACCESS, size: sizeUp)
                }
                
                switch response.result {
                    
                case .success:
                    if let status = response.response?.statusCode, status == 200{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                            }else if json["error"].stringValue == "invalid_token"{
                                let notification = VincleNotification()
                                notification.type = NOTI_TOKEN_EXPIRED
                                NotificationsModelManager().manageUnwatchedNotification(notification: notification, onProcessed: {_ in })
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
    static func changePassword(newPassword: String, currentPassword: String, onSuccess: @escaping DictResponseCallback, onError: @escaping ErrorCallback) {
        
        let parameters = ["currentPassword": currentPassword, "newPassword": newPassword] as [String : Any]
        
        manager.request(ApiRouter.ChangePassword(params: parameters))
            .responseJSON { response in
                
              
                if let size = response.data?.count{
                    DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_CHANGE_PASSWORD, size: size)
                }
                if let sizeUp = response.request?.httpBody?.count{
                    
                    DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_CHANGE_PASSWORD, size: sizeUp)
                }
                switch response.result {
                case .success:
                    if let data = response.result.value as? [String: AnyObject], let status = response.response?.statusCode, status == 201{
                        
                        onSuccess(data)
                    }
                    else if let data = response.result.value as? [String: AnyObject], let arrayErrors = data["errors"] as? [[String: AnyObject]], let firstErrorCode = arrayErrors[0]["code"] as? Int{
                        onError(firstErrorCode.localizedError())
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
    }
    
    static func postDataUsage(params: [String:AnyObject], onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){
        
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        manager.request(ApiRouter.PostDataUsage(params: params)).validate()
            .responseString { response in
                
                
                switch response.result {
                case .success:
                    if let status = response.response?.statusCode, status == 201{
                        onSuccess()
                    }
                    else{
                        onError(L10n.errorGenerico)
                    }
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            print("Failure Response: \(json)")
                            let errors = json["errors"].arrayValue
                            if errors.count > 0{
                                let firstError = errors[0]["code"].intValue
                                onError(firstError.localizedError())
                                
                            }
                        } catch {
                            print(error.localizedDescription)
                            onError(L10n.errorGenerico)
                        }
                    }
                        
                    else{
                        print(error.localizedDescription)
                        onError(L10n.errorGenerico)
                    }
                }
        }
        
    }
    
}

