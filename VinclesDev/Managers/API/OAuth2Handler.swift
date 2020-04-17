//
//  OAuth2Handler.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import Alamofire

class OAuth2Handler: RequestRetrier, RequestAdapter {
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    private let lock = NSLock()
    
    lazy var authModelManager = AuthModelManager()
    var badToken = true
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        
        let serverTrustPolicies: [String: ServerTrustPolicy]
        if ProcessInfo.processInfo.environment.keys.contains("EnableSecurityProtocol"){
            serverTrustPolicies = [IP: ServerTrustPolicy.performDefaultEvaluation(validateHost: true)]
        }else {
            serverTrustPolicies = [IP: .disableEvaluation]
        }
        
        return SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    func adapt(_ urlRequest: URLRequest) -> URLRequest {
        guard let accessToken = authModelManager.getAccessToken() else {

            return urlRequest
        }

        if let url =  urlRequest.url?.absoluteString, url.contains(LOGOUT_ENDPOINT) {
            return urlRequest
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")

        
        return urlRequest
    }

    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
      
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
         
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded in
 
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 1.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 1.0)
        }
    }
    
    
    private typealias RefreshCompletion = (_ succeeded: Bool) -> Void
    
    private func refreshTokens(redirect: Bool = true, completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        if let refreshToken = authModelManager.getRefreshToken(){
            let parameters: [String: Any] = [
                "refresh_token": refreshToken,
                "grant_type": "refresh_token"
            ]
            

            sessionManager.request(ApiRouter.RenewToken(params: parameters))
                .responseJSON { response in
                  
                    let strongSelf = self
                    if let json = response.result.value as? [String: Any], let accessToken = json["access_token"] as? String, let refreshToken = json["refresh_token"] as? String, let expiresIn = json["expires_in"] as? Int
                    {
                        
                        self.authModelManager.updateAuthResponse(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn)

                        completion(true)
                        strongSelf.isRefreshing = false
                        
                    } else {
                        HUDHelper.sharedInstance.hideHUD()

                        completion(false)
                        strongSelf.isRefreshing = false
                        
                        let navManager = NavigationManager()
                        if redirect{
                            navManager.showUnauthorizedLogin()
                        }
                        
                    }
                    
                    strongSelf.isRefreshing = false
                    
            }
            
            
            
        }
        
        
     
    }
    
}

