//
//  ModelManagerProtocol.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol CirclesGroupsModelManagerProtocol {
    var numberOfContacts: Int {get}
    func contactAt(index: Int) -> User
    var numberOfGroups: Int {get}
    func groupAt(index: Int) -> Group
    var numberOfDinamizadores: Int {get}
    func dinamizadorAt(index: Int) -> User
    func addCircles(array: [[String:Any]]) -> Bool
    func addCircle(dict: [String:Any]) -> User?
    func addCirclesVinculat(array: [[String:Any]]) -> Bool
    func removeUnexistingCircleItems(apiItems: [Int]) -> Bool
    func addGroups(array: [[String:Any]]) -> Bool
    func removeUnexistingGroupItems(apiItems: [Int]) -> Bool
    func removeContactItem(id: Int) -> Bool
    func groupParticipantAt(index: Int, id: Int) -> User?
}
