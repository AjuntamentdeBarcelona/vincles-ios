//
//  ModelManagerTest.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
@testable import VinclesDev
import SwiftyJSON

class CirclesManagerTest: CirclesGroupsModelManagerProtocol {
    
    var circles = [User]()
    var groups = [Group]()
    var dinamitzadors = [User]()
    
    var numberOfContacts: Int{
        return circles.count
    }
    
    func contactAt(index: Int) -> User {
        return circles[index]
    }
    
    var numberOfGroups: Int{
        return groups.count
    }
    
    func groupAt(index: Int) -> Group {
        return groups[index]
    }
    
    var numberOfDinamizadores: Int{
        return dinamitzadors.count
    }
    
    func dinamizadorAt(index: Int) -> User {
        return dinamitzadors[index]
    }
    
    func addCircles(array: [[String : Any]]) -> Bool {
        for dict in array{
            if let userDict = dict["user"] as? [String:AnyObject], let relation = dict["relationship"] as? String{
                let contact = User(json: JSON(userDict), relation: relation)
                circles.append(contact)
            }
        }
        return true
    }
    
    func addCircle(dict: [String : Any]) -> String {
        if let userDict = dict["userVincles"] as? [String:AnyObject], let relation = dict["relationship"] as? String{
            let contact = User(json: JSON(userDict), relation: relation)
            circles.append(contact)
            return contact.name
        }
        return ""
    }
    
    func addCirclesVinculat(array: [[String : Any]]) -> Bool {
        for dict in array{
            if let circleDict = dict["circle"] as? [String:AnyObject], let userDict = circleDict["userVincles"] as? [String:AnyObject],  let relation = dict["relationship"] as? String{
                let contact = User(json: JSON(userDict), relation: relation)
                circles.append(contact)
            }
        }
        return true
    }
    
 
    
    func addGroups(array: [[String : Any]]) -> Bool {
        for dict in array{
            
            if let groupDict = dict["group"] as? [String:AnyObject], let idDynamizerChat = dict["idDynamizerChat"] as? Int{
                let group = Group(json: JSON(groupDict), idDynChat: idDynamizerChat)
                groups.append(group)
                
                if let dynam = group.dynamizer{
                   dinamitzadors.append(dynam)
                    
                }
            }
            
        }
        return true
    }
    
    func removeUnexistingGroupItems(apiItems: [Int]) -> Bool {
        return true
    }
    
    func removeContactItem(id: Int) {
        let circle = circles.filter{ $0.id == id }.first
        circles.remove(at: circles.index(of: circle!)!)
    }
    
    func removeUnexistingCircleItems(apiItems: [Int]) -> Bool {
        return true
    }

}
