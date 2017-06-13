/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CoreData
import SwiftyJSON


class Missatges: NSManagedObject {
    
    
    class func createBlankMissatgesEntity() -> Missatges {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Missatges", inManagedObjectContext: managedObjectContext)
        let missatge = Missatges(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        return missatge
    }

    class func loadMissatgesFromCoreData(msgFrom:String) -> [Missatges] {
        var misstges:[Missatges] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Missatges")

        let predicate = NSPredicate(format: "%K == %@","idUserFrom",msgFrom)
        request.sortDescriptors = [NSSortDescriptor(key: "sendTime", ascending: false)]
        request.predicate = predicate

        do{
            let results = try managedContext.executeFetchRequest(request) as! [Missatges]
            misstges = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return misstges
    }
    
    class func getMsgWithID(msgID:String) -> Missatges? {
        var missatge:Missatges?
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Missatges")

        let predicate = NSPredicate(format: "%K == %@","id",msgID)
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Missatges]
            if results.count > 0 {
              missatge = results.first!
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return missatge
    }
    
    
    class func entityMissatgesEmpty(msgFrom:String) -> Bool
    {
        var dataResults:[Missatges]!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Missatges")
        let predicate = NSPredicate(format: "%K == %@","idUserFrom",msgFrom)
        request.sortDescriptors = [NSSortDescriptor(key: "sendTime", ascending: false)]
        request.predicate = predicate

        do{
            let results = try managedContext.executeFetchRequest(request) as![Missatges]
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
    
    class func deleteMissatgesEntity(idx:Int) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName: "Missatges")
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Missatges]
            managedContext.deleteObject(results[idx])
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    class func addNewMissatgeToEntity(json:JSON) -> Missatges {
        
        let newMissatge = self.createBlankMissatgesEntity()
        newMissatge.id = json["id"].stringValue
        newMissatge.idUserFrom = json["idUserFrom"].stringValue
        newMissatge.idUserTo = json["idUserTo"].stringValue
        newMissatge.metadataTipus = json["metadataTipus"].stringValue
        let dateTransform = Double(json["sendTime"].stringValue)
        let msgDate = Utils().nsDateFromMilliSeconds(dateTransform!)
        newMissatge.sendTime = msgDate
        newMissatge.text = json["text"].stringValue
        newMissatge.watched = json["watched"].boolValue
        
        newMissatge.idAdjuntContents =
            NSKeyedArchiver.archivedDataWithRootObject((json["idAdjuntContents"].object))
        
        self.saveMissatgesContext()
        
        return newMissatge
    }
    
    class func deleteAllMessagesFromUser(fromUsr:String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Missatges")
        let predicate = NSPredicate(format: "%K == %@","idUserFrom",fromUsr)
        request.predicate = predicate
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request) as![Missatges]
            
            for miss in results {
                managedObjectContext.deleteObject(miss)
            }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        self.saveMissatgesContext()
    }
    
    class func saveMissatgesContext() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        do {  // save to CoreData
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    


}
