//
//  AuthModelManagerProtocol.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol AuthModelManagerProtocol {
    var hasUser: Bool {get}
    func saveAuthResponse(dict: [String:Any])
    func getAuthResponse() -> AuthResponse?
    func updateAuthResponse(accessToken: String, refreshToken: String, expiresIn: Int)
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
}
