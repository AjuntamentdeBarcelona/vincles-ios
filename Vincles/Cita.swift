/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/
import Foundation
import CoreData
import SwiftyJSON


class Cita: NSManagedObject {
    
    class func createBlankCitaEntity() -> Cita {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Cita", inManagedObjectContext: managedObjectContext)
        let cita = Cita(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        return cita
    }
    
    class func saveCitesContext() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        do {  // save to CoreData
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    class func entityCitaEmpty(from:NSDate,to:NSDate) -> Bool
    {
        var dataResults:[Cita] = []
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ ",from,to)
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as![Cita]
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
    
    class func loadCitesDataFromCoreData(calendarId:String,from:NSDate,to:NSDate) -> [Cita] {
        
        var cites:[Cita] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        
        let predicate1 = NSPredicate(format: "%K == %@","calendarId",calendarId)
        let predicate2 = NSPredicate(format: "date >= %@ && date <= %@ ",from,to)
        
        let predicArry = [predicate1,predicate2]
        
        let predicates = NSCompoundPredicate.init(andPredicateWithSubpredicates: predicArry)
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = predicates
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            cites = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cites
    }
    
    class func loadAllCitesFromInterval(from:NSDate,to:NSDate) -> [Cita] {
        
        var cites:[Cita] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        
        let predicate = NSPredicate(format: "date >= %@ && date <= %@ ",from,to)
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            cites = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cites
    }
    
    class func loadAllCitesDataFromCoreDataWithDate(calendarID:String, from:NSDate) -> [Cita] {
        
        var cites:[Cita] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")

        let predicate = NSPredicate(format: "date >= %@ && calendarId == %@", from, calendarID)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            cites = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cites
    }

    class func loadAllCitesDataFromCoreData(calendarID:String) -> [Cita] {
        
        var cites:[Cita] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        
        let predicate = NSPredicate(format: "%K == %@","calendarId",calendarID)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            cites = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cites
    }
    
    class func getCitaWithID(eventID:String) -> Cita {
        
        var cita:Cita!
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        
        let predicate = NSPredicate(format: "%K == %@","id",eventID)
        request.predicate = predicate

        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            cita = results.first
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cita
    }

    class func getOptionalCitaWithID(eventID:String) -> Cita? {
        
        var cita:Cita?
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        
        let predicate = NSPredicate(format: "%K == %@","id",eventID)
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            
            if results.count > 0 {
                cita = results.first!
            }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cita
    }
    
    class func addNewCitaToEntity(json:JSON) -> Cita {
        
        let newCita = self.createBlankCitaEntity()
        newCita.id = json["id"].stringValue
        let dateTransform = Double(json["date"].stringValue)
        
        let citaDate = Utils().nsDateFromMilliSeconds(dateTransform!)
        newCita.date = citaDate
        newCita.descript = json["description"].stringValue
        newCita.state = json["state"].stringValue
        newCita.calendarId = json["calendarId"].stringValue
        newCita.duration = json["duration"].stringValue

        self.saveCitesContext()
        
        return newCita
    }
    
    class func getAllCitesFromVincle(calID:String) -> [Cita] {
        
        var cites:[Cita] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        
        let predicate = NSPredicate(format: "%K == %@","calendarId",calID)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [Cita]
            cites = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return cites
    }
    
    class func deleteAllCitesFromUser(calendarID:String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"Cita")
        let predicate = NSPredicate(format: "%K == %@","calendarId",calendarID)
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as![Cita]
            
            for miss in results {
                managedContext.deleteObject(miss)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        self.saveCitesContext()
    }
    
    
}
