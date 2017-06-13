/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CoreData
import SwiftyJSON


class UserVincle: NSManagedObject {
    
    class func loadUserVincleCoreData() -> [UserVincle] {
        var vincles:[UserVincle] = []

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"UserVincle")
        do{
            let results = try managedContext.executeFetchRequest(request) as! [UserVincle]
            
            vincles = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")

        }
        return vincles
    }
    
    class func loadUserVinclesAtIndex(idx:Int) -> UserVincle {
        
        var vincles:[UserVincle] = []

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"UserVincle")
        do{
            let results = try managedContext.executeFetchRequest(request) as! [UserVincle]
            
            vincles = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return vincles[idx]
    }
    
    class func entityUserVinclesEmpty() -> Bool
    {
        var dataResults:[UserVincle]!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"UserVincle")
        do{
            let results = try managedContext.executeFetchRequest(request) as![UserVincle]
            dataResults = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if dataResults.count == 0 {
            return true
        }else{
            return false
        }
    }
    
    class func deleteVincleEntity(idx:Int) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "UserVincle")
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [UserVincle]
            managedContext.deleteObject(results[idx])
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    class func createBlankVinclesEntity() -> UserVincle {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("UserVincle", inManagedObjectContext: managedObjectContext)
        let userVincle = UserVincle(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        return userVincle

    }
    
    class func saveUserVincleContext() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        do {  // save to CoreData
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    class func loadUserVincleWithID(usrID:String) -> UserVincle? {
        
        var vincle:UserVincle?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
 
        let request = NSFetchRequest(entityName:"UserVincle")
        let predicate = NSPredicate(format: "%K == %@","id",usrID)
        request.predicate = predicate
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request) as![UserVincle]
            
            if results.count > 0 {
                vincle = results.first
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return vincle
    }
    
    class func loadUserVincleWithCalendarID(calendarID:String) -> UserVincle? {
        var vincle:UserVincle?
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName:"UserVincle")
        let predicate = NSPredicate(format: "%K == %@","idCalendar",calendarID)
        request.predicate = predicate
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request) as![UserVincle]
            if results.count > 0 {
               vincle = results.first
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return vincle
    }
    
    class func updateUserVincles(usr:UserVincle,params:JSON) {
        
        
        usr.name! = params["name"].stringValue
        usr.lastname! = params["lastname"].stringValue
        usr.alias! = params["alias"].stringValue
        usr.email! = params["email"].stringValue
        usr.phone! = params["phone"].stringValue
        usr.liveInBarcelona! = params["liveInBarcelona"].boolValue
        usr.idContentPhoto! = params["idContentPhoto"].stringValue
        
        UserVincle.saveUserVincleContext()
        
    }
    
}
