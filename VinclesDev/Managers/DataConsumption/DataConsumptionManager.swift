//
//  DataConsumptionManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class DataConsumptionManager: NSObject {
    static let sharedInstance = DataConsumptionManager()
    var debugMode = false

    func sendPendingUsages(){
        if let arrayPending = UserDefaults.standard.object(forKey: "pending") as? [String]{
            
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "ddMMyyyy"
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())

            let dateStringToday = dateFormatterGet.string(from: Date())
            
            for date in arrayPending{
                if debugMode || date != dateStringToday{

                    let profileModelManager = ProfileModelManager()
                    if let id = profileModelManager.getUserMe()?.id{
                        if let existingObject = UserDefaults.standard.object(forKey: date) as? [[String: AnyObject]]{
                            var params = [String: AnyObject]()
                            params["details"] = existingObject as AnyObject
                            params["userId"] = id as AnyObject
                            if let dateObj = dateFormatterGet.date(from: date){
                                params["consumeDate"] = Int64(dateObj.timeIntervalSince1970) * 1000 as AnyObject
                                ApiClient.postDataUsage(params: params, onSuccess: {
                                    
                                    
                                    
                                 
                                    if let pending  = UserDefaults.standard.object(forKey: "pending") as? [String]{
                                        var pend = pending
                                        if let index = pending.firstIndex(of: date){
                                            pend.remove(at: index)
                                        }
                                        UserDefaults.standard.set(pend, forKey: date)
                                        UserDefaults.standard.synchronize()
                                    }
                                }) { (error) in
                                    
                                }
                            }
                           
                            
                        }
                  }
                    
                   
                   
                }
            }
        }
    }
    
    func addDownSizeToRequest(request: String, size: Int){
        
        /*
 {"details":[{"down":407678,"callType":"GetUserPhotoRequest","up":0},{"down":0,"callType":"MigrationPostLogin","up":0},{"down":0,"callType":"PostDataUsageRequest","up":0},{"down":12,"callType":"StartVideoconferenceRequest","up":0},{"down":0,"callType":"VideoCall","up":0}],"consumeDate":1554804000000,"userId":0}
 */
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "ddMMyyyy"
        let dateString = dateFormatterGet.string(from: Date())
        if let existingObject = UserDefaults.standard.object(forKey: dateString) as? [[String: AnyObject]]{
            var foundDict = false
            var newArray = [[String: AnyObject]]()
            
            for dict in existingObject{
                if let callType = dict["callType"] as? String, callType == request{
                    var copyDict = dict
                    copyDict["down"] = dict["down"] as! Int + size as AnyObject
                    foundDict = true
                    newArray.append(copyDict)
                }
                else{
                    newArray.append(dict)
                }
            }
            
            if !foundDict{
                var newDict = [String: AnyObject]()
                newDict["callType"] = request as AnyObject
                newDict["down"] = size as AnyObject
                newDict["up"] = 0 as AnyObject
                newArray.append(newDict)

            }
           
            UserDefaults.standard.set(newArray, forKey: dateString)
            UserDefaults.standard.synchronize()

        }
        else{
            var rootArray = [[String: AnyObject]]()
           
            var newDict = [String: AnyObject]()
            newDict["callType"] = request as AnyObject
            newDict["down"] = size as AnyObject
            newDict["up"] = 0 as AnyObject
            rootArray.append(newDict)
            
            
            UserDefaults.standard.set(rootArray, forKey: dateString)
            UserDefaults.standard.synchronize()

            if let arrayPending = UserDefaults.standard.object(forKey: "pending") as? [String]{
                var pending = arrayPending
                pending.append(dateString)
                UserDefaults.standard.set(pending, forKey: "pending")
                UserDefaults.standard.synchronize()

            }
            else{
                var newPending = [String]()
                newPending.append(dateString)
                UserDefaults.standard.set(newPending, forKey: "pending")
                UserDefaults.standard.synchronize()
            }
        }
        
    }
    
    func addUpSizeToRequest(request: String, size: Int){
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "ddMMyyyy"
        let dateString = dateFormatterGet.string(from: Date())
        if let existingObject = UserDefaults.standard.object(forKey: dateString) as? [[String: AnyObject]]{
            var foundDict = false
            var newArray = [[String: AnyObject]]()
            
            for dict in existingObject{
                if let callType = dict["callType"] as? String, callType == request{
                    var copyDict = dict
                    copyDict["up"] = dict["up"] as! Int + size as AnyObject
                    foundDict = true
                    newArray.append(copyDict)
                }
                else{
                    newArray.append(dict)
                }
            }
            
            if !foundDict{
                var newDict = [String: AnyObject]()
                newDict["callType"] = request as AnyObject
                newDict["down"] = 0 as AnyObject
                newDict["up"] = size as AnyObject
                newArray.append(newDict)
                
            }
            
            UserDefaults.standard.set(newArray, forKey: dateString)
            UserDefaults.standard.synchronize()

        }
        else{
            var rootArray = [[String: AnyObject]]()
            
            var newDict = [String: AnyObject]()
            newDict["callType"] = request as AnyObject
            newDict["down"] = 0 as AnyObject
            newDict["up"] = size as AnyObject
            rootArray.append(newDict)
            
            
            UserDefaults.standard.set(rootArray, forKey: dateString)
            UserDefaults.standard.synchronize()

            if let arrayPending = UserDefaults.standard.object(forKey: "pending") as? [String]{
                var pending = arrayPending
                pending.append(dateString)
                UserDefaults.standard.set(pending, forKey: "pending")
                UserDefaults.standard.synchronize()

            }
            else{
                var newPending = [String]()
                newPending.append(dateString)
                UserDefaults.standard.set(newPending, forKey: "pending")
                UserDefaults.standard.synchronize()

            }
        }
    }
}

