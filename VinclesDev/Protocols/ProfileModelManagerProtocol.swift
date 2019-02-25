//
//  ProfileModelManagerProtocol.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

protocol ProfileModelManagerProtocol {
    var userIsVincle: Bool {get}
    func getUserMe() -> User?
    func addOrUpdateUser(dict: [String:Any])
}
