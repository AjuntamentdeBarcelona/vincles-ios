//
//  ApiClientURLSession.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit


class ApiClientURLSession: NSObject, URLSessionDelegate {
    
    static let sharedInstance = ApiClientURLSession()
    typealias ErrorCallbackExtended = (String, Int) -> Void
    typealias ErrorCallback = (String) -> Void
    typealias DictResponseCallback = ([String:Any]) -> Void
    typealias ArrayResponseCallback = ([[String:Any]]) -> Void
    typealias VoidCallback = () -> ()
    typealias DataResponseCallback = (Data) -> Void
    typealias MessageTypeResponseCallback = (Data, MessageType) -> Void
    typealias BoolResponseCallback = (Bool) -> Void
    
    var pendingURLRequest = [URLRequest]()
    
    func startCallApi(idUser: Int, idRoom: String, onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        let params = ["idUser": idUser, "idRoom": idRoom] as [String : Any]
        
        let URLString = "\(URL_BASE)/\(START_VIDEOCONFERENCE)"
        let url = URL(string: URLString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_START_API_CALL, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_START_API_CALL, size: sizeUp)
            }
            
           
            
            if data != nil {
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    onSuccess(true)
                    
                }
                else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                    onError(TOKEN_FAIL)
                    
                }else {
                    onError("")
                }
            }
            else{
                if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                    onError(TOKEN_FAIL)
                    
                }
                else{
                    onError("")
                }
                
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
        
        
        
    }
    
    func getServerTime(onSuccess: @escaping () -> (), onError: @escaping () -> ()) {
        let URLString = "\(URL_BASE)/\(GET_SERVER_TIME)/"
        let url = URL(string: URLString)
        let request = URLRequest(url: url!)
        
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_SERVER_TIME, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_SERVER_TIME, size: sizeUp)
            }
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                        if let currentTime = json["currentTime"] as? Int64{
                            //       UserDefaults.standard.set(0, forKey: "loginTime")
                            UserDefaults.standard.set(currentTime, forKey: "loginTime")
                            
                            onSuccess()
                        }
                        else{
                            
                            onError()
                        }
                        
                    } else {
                        onError()
                        
                    }
                }
                
            }
            else{
                onError()
                
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
        
    }
    
    func sendUserMessage(params: [String: Any], onSuccess: @escaping ([String: AnyObject]) -> (), onError: @escaping (String) -> ()) {
        
        let URLString = "\(URL_BASE)/\(SEND_USER_TEXT_MESSAGE)"
        let url = URL(string: URLString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_SEND_USER_MESSAGE, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_SEND_USER_MESSAGE, size: sizeUp)
            }
            
            
            
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if let _ = jsonUn["id"] as? Int, let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                        DispatchQueue.main.async {
                            onSuccess(jsonUn)
                        }
                        
                    }else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                        onError(TOKEN_FAIL)
                    
                    }else if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError())
                            }
                        }
                        else{
                            onError(L10n.errorGenerico)
                        }
                    }
                    else {
                        onError(L10n.errorGenerico)
                    }
                }
                else{
                    onError(L10n.errorGenerico)
                }
                
            }
            else{
                onError("")
                
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
    }
    
    func sendGroupMessage(params: [String:Any], onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        let URLString = "\(URL_BASE)/\(String(format: SEND_GROUP_TEXT_MESSAGE, params["idChat"] as! Int))"
        let url = URL(string: URLString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_SEND_GROUP_MESSAGE, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_SEND_GROUP_MESSAGE, size: sizeUp)
            }
            
           
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if let _ = jsonUn["id"] as? Int, let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                        DispatchQueue.main.async {
                            onSuccess(jsonUn)
                        }
                    }else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                        onError(TOKEN_FAIL)
                        
                    }else if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError())
                            }
                        }
                        else{
                            onError(L10n.errorGenerico)
                        }
                    }
                    else {
                        onError(L10n.errorGenerico)
                    }
                }
                else{
                    onError(L10n.errorGenerico)
                }
                
            }
            else{
                onError("")
                
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
    }
    
    func getMessageById(params: [String:Any], onSuccess: @escaping ([String: AnyObject]) -> (), onError: @escaping ErrorCallbackExtended) {
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico, 0)
            return
        }
        
        let URLString = "\(URL_BASE)/\(String(format: CHAT_USER_GET_MESSAGE_ID, params["idMessage"] as! Int))"
        let url = URL(string: URLString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_MESSAGE, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_MESSAGE, size: sizeUp)
            }
            
            
            
            guard let response = response as? HTTPURLResponse else {
                onError(L10n.errorGenerico, 0)
                return
            }
            
            if let data = data {
                
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if 200...299 ~= response.statusCode {
                        DispatchQueue.main.async {
                            onSuccess(jsonUn)
                        }
                    }else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                        onError(TOKEN_FAIL, response.statusCode)
                        
                    }else if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError(), response.statusCode)
                            }
                        }
                        else{
                            onError(L10n.errorGenerico, response.statusCode)
                        }
                    }else {
                        onError(L10n.errorGenerico, response.statusCode)
                    }
                }
                else{
                    onError(L10n.errorGenerico, response.statusCode)
                }
                
            }
            else{
                onError(L10n.errorGenerico, response.statusCode)
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
        
    }
    
    func getGroupMessageById(params: [String:Any], onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallbackExtended){
        
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico, 0)
            return
        }
        
        let URLString = "\(URL_BASE)/\(String(format: CHAT_GROUP_GET_MESSAGE_ID, params["idChat"] as! Int, params["idMessage"] as! Int))"
        let url = URL(string: URLString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_GROUP_MESSAGE, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_GROUP_MESSAGE, size: sizeUp)
            }
            
            
            
            guard let response = response as? HTTPURLResponse else {
                onError(L10n.errorGenerico, 0)
                return
            }
           
            if let data = data {
                
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if 200...299 ~= response.statusCode {
                        onSuccess(jsonUn)
                    }else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                        onError(TOKEN_FAIL, response.statusCode)
                        
                    }else if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError(), response.statusCode)
                            }
                        }else{
                            onError(L10n.errorGenerico, response.statusCode)
                        }
                    }else {
                        onError(L10n.errorGenerico, response.statusCode)
                    }
                }
                else{
                    onError(L10n.errorGenerico, response.statusCode)
                }
                
            }
            else{
                onError(L10n.errorGenerico, response.statusCode)
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
        
    }
    
    func uploadAudio(audioData: Data, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        let stringUrl = "\(URL_BASE)/\(UPLOAD_CONTENT)"
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        let name = "file"
        let filename = "file.aac"
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/aac\r\n\r\n".data(using: .utf8)!)
        data.append(audioData)
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        // Send a POST request to the URL, with the data we created earlier
        let task = session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                onError(L10n.errorGenerico)
                return
            }
           
            if let data = data {
                
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_UPLOAD_AUDIO, size: data.count)
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_UPLOAD_AUDIO, size: audioData.count)

                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if 200...299 ~= response.statusCode {
                        onSuccess(jsonUn)
                    }else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                        onError(TOKEN_FAIL)
                        
                    }else if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError())
                            }
                        }else{
                            onError(L10n.errorGenerico)
                        }
                    }else {
                        onError(L10n.errorGenerico)
                    }
                }else{
                    onError(L10n.errorGenerico)
                }
                
            }else{
                onError(L10n.errorGenerico)
            }
            
        })
        
        task.priority = URLSessionTask.highPriority
        
        task.resume()
    }
    
    func uploadImage(imageData: Data, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        let stringUrl = "\(URL_BASE)/\(UPLOAD_CONTENT)"
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        let name = "file"
        let filename = "file.jpg"
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        // Send a POST request to the URL, with the data we created earlier
        let task = session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                onError(L10n.errorGenerico)
                return
            }
            
            if let data = data {
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_UPLOAD_IMAGE, size: data.count)
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_UPLOAD_IMAGE, size: imageData.count)

                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if 200...299 ~= response.statusCode {
                        onSuccess(jsonUn)
                    }else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                        onError(TOKEN_FAIL)
                        
                    }else if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError())
                            }
                        }else{
                            onError(L10n.errorGenerico)
                        }
                    }else {
                        onError(L10n.errorGenerico)
                    }
                }else{
                    onError(L10n.errorGenerico)
                }
                
            }else{
                onError(L10n.errorGenerico)
            }
            
        })
        
        task.priority = URLSessionTask.highPriority
        
        task.resume()
    }
    
    func uploadVideo(videoData: Data, onSuccess:  @escaping DictResponseCallback, onError:  @escaping ErrorCallback){
        let stringUrl = "\(URL_BASE)/\(UPLOAD_CONTENT)"
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        let name = "file"
        let filename = "file.mp4"
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        data.append(videoData)
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        // Send a POST request to the URL, with the data we created earlier
        let task = session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                onError(L10n.errorGenerico)
                return
            }
           
            if let data = data {
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_UPLOAD_VIDEO, size: data.count)
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_UPLOAD_VIDEO, size: videoData.count)

                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if 200...299 ~= response.statusCode {
                        onSuccess(jsonUn)
                    }else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                        onError(TOKEN_FAIL)
                        
                    }else if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError())
                            }
                        }else{
                            onError(L10n.errorGenerico)
                        }
                    }else {
                        onError(L10n.errorGenerico)
                    }
                }else{
                    onError(L10n.errorGenerico)
                }
                
            }else{
                onError(L10n.errorGenerico)
            }
            
        })
        
        task.priority = URLSessionTask.highPriority
        
        task.resume()
    }
    
    func refreshToken(onSuccess:  @escaping VoidCallback, onError:  @escaping ErrorCallback){
        let authModelManager = AuthModelManager()
        
        guard let refreshToken = authModelManager.getRefreshToken() else{
            onError(L10n.errorGenerico)
            return
        }
        
        let URLString = "\(URL_BASE)/\(LOGIN_ENDPOINT)?refresh_token=\(refreshToken)&grant_type=refresh_token"
        let url = URL(string: URLString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue( "Basic \(BASIC_AUTH_STR)", forHTTPHeaderField: "Authorization")
        
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_REFRESH_TOKEN, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_REFRESH_TOKEN, size: sizeUp)
            }
            
            guard let response = response as? HTTPURLResponse else {
                onError(L10n.errorGenerico)
                return
            }
          
            
            if let data = data {
                
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject], let accessToken = json["access_token"] as? String, let refreshToken = json["refresh_token"] as? String, let expiresIn = json["expires_in"] as? Int{
                    
                    if 200...299 ~= response.statusCode {
                        DispatchQueue.main.async {
                            authModelManager.updateAuthResponse(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn)
                            onSuccess()
                        }
                    }else {
                        onError(L10n.errorGenerico)
                    }
                }else{
                    onError(L10n.errorGenerico)
                }
            }else{
                onError(L10n.errorGenerico)
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
        
    }
    
    func getContentsLibrary(to: Int64, onSuccess:  @escaping ArrayResponseCallback, onError:  @escaping ErrorCallback){
        
        let types = ["image/png", "image/jpg", "image/jpeg", "video/mp4"]
        
        let parameters = ["to": "\(to)", "types": types.joined(separator: ",")] as! [String : String]
        
        print("getContentsLibrary \(parameters)")
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        let URLString = "\(URL_BASE)/\(GET_CONTENTS_LIBRARY_ENDPOINT)" + buildQueryString(fromDictionary: parameters)
        var url = URL(string: URLString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let authModelManager = AuthModelManager()
        
        if let accessToken = authModelManager.getAccessToken(){
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            if let size = data?.count{
                DataConsumptionManager.sharedInstance.addDownSizeToRequest(request: DATA_CONSUMPTION_GET_CONTENTS_LIBRARY, size: size)
            }
            if let sizeUp = request.httpBody?.count{
                
                DataConsumptionManager.sharedInstance.addUpSizeToRequest(request: DATA_CONSUMPTION_GET_CONTENTS_LIBRARY, size: sizeUp)
            }
            
            guard let response = response as? HTTPURLResponse else {
                onError(L10n.errorGenerico)
                return
            }
          
            if let data = data {
                
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]]{
                    let jsonUn = json
                    if 200...299 ~= response.statusCode {
                        print("getContentsLibrary response \(jsonUn)")
                        onSuccess(jsonUn)
                    }
                } else if let response = response as? HTTPURLResponse , 401 ~= response.statusCode {
                    onError(TOKEN_FAIL)
                    
                } else if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]{
                    let jsonUn = json
                    if let errors = jsonUn["errors"] as? [[String: AnyObject]]{
                        if errors.count > 0{
                            if let firstError = errors[0]["code"] as? Int{
                                onError(firstError.localizedError())
                            }
                        }
                        else{
                            onError(L10n.errorGenerico)
                        }
                    }
                    else {
                        onError(L10n.errorGenerico)
                    }
                }
                else{
                    onError(L10n.errorGenerico)
                }
                
            }
            else{
                onError(L10n.errorGenerico)
            }
        })
        task.priority = URLSessionTask.highPriority
        
        task.resume()
        
    }
    
    func buildQueryString(fromDictionary parameters: [String:String]) -> String {
        var urlVars:[String] = []
        
        for (k,value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        
        return urlVars.isEmpty ? "" : "?" + urlVars.joined(separator: "&")
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.previousFailureCount == 0 else {
            challenge.sender?.cancel(challenge)
            // Inform the user that the user name and password are incorrect
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Within your authentication handler delegate method, you should check to see if the challenge protection space has an authentication type of NSURLAuthenticationMethodServerTrust
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
            // and if so, obtain the serverTrust information from that protection space.
            && challenge.protectionSpace.serverTrust != nil
            && challenge.protectionSpace.host == IP {
            let proposedCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, proposedCredential)
        }
    }
}


extension Data {
    
    /// Append string to Data
    ///
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
