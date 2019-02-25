//
//  ContactItem.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class ContactItem: NSObject {

    var name = ""
    var surname = ""
    var unreadMessagesAndLostCalls = 0
    var totalMessages = 0
    var user: User?
    var group: Group?
    var isDinam = false
    var lastInteraction = Date(timeIntervalSince1970: 0)
    
}
