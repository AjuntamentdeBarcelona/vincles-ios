/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CoreData


class UserCercle: NSManagedObject {
    
   class func loadUserCercleCoreData() -> UserCercle? {
    var user:UserCercle?

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"UserCercle")
        do{
            let results = try managedContext.executeFetchRequest(request) as?[UserCercle]
            user = results!.first
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return user
    }
    
    class func saveUserCercleEntity(entity:UserCercle) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext

        do {  // save to CoreData
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    class func entityUserCercleEmpty() -> Bool
    {
        var dataResults:[UserCercle]!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"UserCercle")
        do{
            let results = try managedContext.executeFetchRequest(request) as![UserCercle]
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
    
    class func entityUserCercleVerified() -> Bool
    {
        var user:UserCercle?

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"UserCercle")
        do{
            let results = try managedContext.executeFetchRequest(request) as?[UserCercle]
            user = results!.first
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if user!.active != nil
            
        {
            print ("USER ACTIVE= ", user!.active)
            if user!.active == 1
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }

     
    }
    
    class func deleteUserData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Delete Missatges
        let requestM = NSFetchRequest(entityName:"Missatges")
        
        do{
            let resultsM = try managedContext.executeFetchRequest(requestM) as! [Missatges]
            for i in 0 ..< resultsM.count {
                managedContext.deleteObject(resultsM[i])
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        //Delete Citas
        let requestC = NSFetchRequest(entityName:"Cita")
        
        do{
            let resultsC = try managedContext.executeFetchRequest(requestC) as! [Cita]
            for i in 0 ..< resultsC.count {
                managedContext.deleteObject(resultsC[i])
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        //Delete Feed
        let requestF = NSFetchRequest(entityName:"InitFeed")
        
        do{
            let resultsF = try managedContext.executeFetchRequest(requestF) as! [InitFeed]
            for i in 0 ..< resultsF.count {
                managedContext.deleteObject(resultsF[i])
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        //Delete UserVincles
        let requestV = NSFetchRequest(entityName:"UserVincle")
        do{
            let resultsV = try managedContext.executeFetchRequest(requestV) as?[UserVincle]
            for i in 0 ..< resultsV!.count {
                managedContext.deleteObject(resultsV![i])
            }
            try managedContext.save()
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        //Delet UserCercles
        let requestU = NSFetchRequest(entityName:"UserCercle")
        do{
            let resultsU = try managedContext.executeFetchRequest(requestU) as?[UserCercle]

            for i in 0 ..< resultsU!.count {
                managedContext.deleteObject(resultsU![i])
            }
            try managedContext.save()
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }


    }
    
}
