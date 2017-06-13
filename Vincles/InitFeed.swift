/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CoreData
import SwiftyJSON


class InitFeed: NSManagedObject {
    
    class func createBlankInitFeedEntity() -> InitFeed {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("InitFeed", inManagedObjectContext: managedObjectContext)
        let initFeed = InitFeed(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        return initFeed
    }
    
    class func saveInitFeedContext() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        do {  // save to CoreData
            try managedObjectContext.save()
            
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    class func loadInitFeeds() -> [InitFeed] {
        
        var initFeeds:[InitFeed] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"InitFeed")
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [InitFeed]
            initFeeds = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return initFeeds
    }
    
    class func loadFeedsWithType(type:String) -> [InitFeed] {
        
        var typedFeeds:[InitFeed] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"InitFeed")
        
        let predicate = NSPredicate(format: "%K == %@","type",type)
        request.predicate = predicate
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [InitFeed]
            typedFeeds = results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return typedFeeds
        
    }
    
    class func addNewInitFeedFromNotification(objectJSON:JSON?,notiJSON:JSON) -> InitFeed {
        
        let initFeed = self.createBlankInitFeedEntity()
        
        switch notiJSON["type"].stringValue {
        case "NEW_MESSAGE":
            initFeed.id = objectJSON!["id"].stringValue
            initFeed.date = Utils().nsDateFromMilliSeconds(Double(notiJSON["creationTime"].stringValue)!)
            initFeed.type = objectJSON!["metadataTipus"].stringValue
            initFeed.idUsrVincles = objectJSON!["idUserFrom"].stringValue
            initFeed.isRead = false
            self.saveInitFeedContext()
            
        default:
            print(notiJSON["type"].stringValue)
        }
        return initFeed
    }
    
    class func addNewFeedEntityOffline(params:[String:AnyObject]) {
        
        let initFeed = self.createBlankInitFeedEntity()
        
        switch params["type"] as! String {
        case INIT_CELL_CONNECTED_TO:
            initFeed.idUsrVincles = (params["userFrom"] as! String)
            initFeed.date = (params["date"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.vincleName = (params["vincleName"] as! String)
            initFeed.vincleLastName = (params["vincleLastName"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()
            
        case INIT_CELL_DISCONNECTED_OF:
            initFeed.date = (params["date"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.vincleName = (params["vincleName"] as! String)
            initFeed.vincleLastName = (params["vincleLastName"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()

        case INIT_CELL_EVENT_SENT:
            initFeed.date = (params["date"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.id = (params["id"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            initFeed.idUsrVincles = (params["idUsrVincles"] as! String)
            self.saveInitFeedContext()
            
        case INIT_CELL_EVENT_ACCEPTED:
            initFeed.date = (params["date"] as! NSDate)
            initFeed.objectDate = (params["objectDate"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.id = (params["id"] as! String)
            initFeed.idUsrVincles = (params["idUsrVincles"] as! String)
            initFeed.textBody = (params["textBody"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()
            
        case INIT_CELL_EVENT_REJECTED:
            initFeed.date = (params["date"] as! NSDate)
            initFeed.objectDate = (params["objectDate"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.id = (params["id"] as! String)
            initFeed.idUsrVincles = (params["idUsrVincles"] as! String)
            initFeed.textBody = (params["textBody"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()
            
        case INIT_CELL_EVENT_DELETED:
            
            initFeed.date = (params["date"] as! NSDate)
            initFeed.objectDate = (params["objectDate"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.id = (params["id"] as! String)
            initFeed.idUsrVincles = (params["idUsrVincles"] as! String)
            initFeed.textBody = (params["textBody"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()


        case INIT_CELL_INCOMING_EVENT:
            initFeed.objectDate = (params["objectDate"] as! NSDate)
            initFeed.date = (params["date"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.id = (params["id"] as! String)
            initFeed.idUsrVincles = (params["idUsrVincles"] as! String)
            initFeed.textBody = (params["textBody"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()
            
        case INIT_CELL_LOST_CALL:
            initFeed.date = (params["date"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.idUsrVincles = (params["idUsrVincles"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()
            
        case INIT_CELL_CALL_REALIZED:
            initFeed.date = (params["date"] as! NSDate)
            initFeed.type = (params["type"] as! String)
            initFeed.idUsrVincles = (params["idUsrVincles"] as! String)
            initFeed.isRead = params["isRead"] as! Bool
            self.saveInitFeedContext()
    
        default:
            print("default")
        }
    }
}
