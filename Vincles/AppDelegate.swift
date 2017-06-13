
/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/


import UIKit
import CoreData
import SwiftyJSON
import EventKit
import AVFoundation
import Fabric
import Crashlytics
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    var myTimer : NSTimer? = NSTimer()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"
    
    let serialQueueNotisAppD = dispatch_queue_create(
        "com.vincles.serialQueueNotisAD", DISPATCH_QUEUE_SERIAL)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        
        NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow:2))
        
        
        Fabric.with([Crashlytics.self])
        
        startGCM(application)
        unlockViaNotification(launchOptions)
        
        var configureError:NSError? = nil
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google Analytics services: \(configureError)")
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
        gai?.logger.logLevel = GAILogLevel.Verbose
        
        application.beginBackgroundTaskWithName("showNotification", expirationHandler: nil)

        let lagWorkaround = UITextField()
        self.window?.addSubview(lagWorkaround)
        lagWorkaround.becomeFirstResponder()
        lagWorkaround.resignFirstResponder()
        lagWorkaround.removeFromSuperview()
        
        let isUserDataEmpty = UserCercle.entityUserCercleEmpty()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if isUserDataEmpty {
            print("DATA USER CERCLE IS EMPTY")
            
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("TermsConditionsVC") as! TermsConditionsVC
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        }else{
            
            print("DATA USER CERCLE NOT NIL")
            
            let isUserVincleEmpty = UserVincle.entityUserVinclesEmpty()
            let isUserCercleVerified = UserCercle.entityUserCercleVerified()
            
            print("USERCERCLE VERIFIED =", isUserCercleVerified)
            
            let installPref = NSUserDefaults.standardUserDefaults().valueForKey("install") as! [NSString:Int]
            
            if isUserVincleEmpty {
                print("NO USER VINCLE ADDED")

                if isUserCercleVerified != true {
                    let initialViewController = storyboard.instantiateViewControllerWithIdentifier("ConfirmationCodeVC") as! ConfirmationCodeViewController
                    NotificationManager.loadLastProcessNotiEpoch()
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
                else{
                    SingletonVars.sharedInstance.isFirstAppLoad = true
                    NotificationManager.loadLastProcessNotiEpoch()
                    let initialViewController = storyboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
            }
                
            else{
                print("USER CERCLE NOT NIL AND VINCLES ADDED")
                
                SingletonVars.sharedInstance.isFirstAppLoad = true
                NotificationManager.loadLastProcessNotiEpoch()
                let initialViewController = storyboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }

        }
        
        rateMe()
        
        return true
    }

    func unlockViaNotification(launchOpt:[NSObject: AnyObject]?) {

        print("LAUNCH OPT == \(launchOpt)")
        if let options = launchOpt {
            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                if let userInfo = notification.userInfo {
                    let customField1 = userInfo["CustomField1"] as! String
                    
                }
            }
        }
    }

    
    func startGCM(application: UIApplication){
        FIRApp.configure()

            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        
        application.registerForRemoteNotifications()
        
    }
    
    func checkFcmConnection() {
        print("Check FCM connection")
        if (!self.connectedToGCM) {
            FIRMessaging.messaging().connectWithCompletion({ (error) in
                if error != nil {
                    print("Unable to connect with FCM. \(error)")
                } else {
                    self.connectedToGCM = true
                    print("Connected to FCM")
                    self.registrationToken = FIRInstanceID.instanceID().token()
                    self.subscribeToTopic()
                    self.checkInstallation()

                }
            })
        }
        else {
            self.checkInstallation();
        }
    }
    
    func checkInstallation() {
        print("Check Installation")
        if (VinclesApiManager().installationDone) {
            return
        }
        
        let usrCercle = UserCercle.loadUserCercleCoreData()
        
        self.registrationToken = FIRInstanceID.instanceID().token()
                
        if (usrCercle?.username  != nil) &&
            self.registrationToken != nil && usrCercle?.id  != nil {
            print("CERCLE \(usrCercle!.nom!)")
            VinclesApiManager().loginSelfUserWithCompletion(usrCercle!.username!,
                pwd: usrCercle!.password!, usrId: usrCercle!.id!, completion: { (result) in
                    
                    if result == "Logged" {
                        // GET VENDOR ID VALUE
                        let vendorID = UIDevice.currentDevice().identifierForVendor!.UUIDString
                        let params = ["idUser":usrCercle!.id!,
                                      "so":"IOS",
                                      "imei":vendorID,
                                      "pushToken":self.registrationToken!]
                        
                        VinclesApiManager().updateInstallation(params)
                    }
                    else if result == "Error login" {
                        print("LOGIN SELF FAILED")
                    }
            })
        } else {
            print("USER CERCLE IS NIL")
        }
        
    }

    // [START receive_apns_token_error]
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
        // [END receive_apns_token_error]
        let userInfo = ["error": error.localizedDescription]
        NSNotificationCenter.defaultCenter().postNotificationName(
            registrationKey, object: nil, userInfo: userInfo)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        if notificationSettings.types != .None {
            print("REGISTERED FOR NOTIS")
        }else{
            print("NOT REGISTERED FOR NOTIS")
        }
    }
    
    // [START ack_message_reception]
    func application( application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Notification received: \(userInfo)")
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                                                                  userInfo: userInfo)
        
        self.processNotification(userInfo as! [String:AnyObject])
    }
    
    func application( application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                                                   fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        print("Notification received with completion with handler: \(userInfo)")
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                                                                  userInfo: userInfo)
        self.processNotification(userInfo as! [String:AnyObject])
        handler(UIBackgroundFetchResult.NewData);
        
        // [END_EXCLUDE]
    }
    
    // [END ack_message_reception]
    func processNotification(userInfo:[String:AnyObject]) {
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        
        if userInfo["push_notification_type"] != nil && userInfo["push_notification_type"] as! String == NOTI_INCOMING_CALL {
            
            if let vinc = UserVincle.loadUserVincleWithID(userInfo["idUser"] as! String) {

                if SingletonVars.sharedInstance.callInProgress == false {
                    SingletonVars.sharedInstance.notificationCallActive = true
                    
                    let notification = UILocalNotification()
                    notification.alertAction = "Go back to App"
                    notification.soundName = "ringv3.caf"
                    notification.alertBody = "\(vinc.name!) \(langBundle.localizedStringForKey("NOTI_TITLE_INCOMING_CALL", value: nil, table: nil))"
                    notification.fireDate = NSDate(timeIntervalSinceNow: 1)
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                    print("notificació trucada entrant: \(notification.alertBody!)")
                    
                    SingletonVars.sharedInstance.isCaller = false
                    SingletonVars.sharedInstance.idRoomCall = userInfo["idRoom"] as! String
                    SingletonVars.sharedInstance.idUserCall = userInfo["idUser"] as! String
                    
                    myTimer = NSTimer.scheduledTimerWithTimeInterval(
                        CALL_WAIT_LIMIT, target: self, selector: #selector(callNotificationTimeout),
                        userInfo: notification, repeats: false)
                    
                    var hostVC = self.window?.rootViewController
                    while let next = hostVC?.presentedViewController {
                        hostVC = next
                    }
                    
                    if let secondViewController = hostVC!.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                        SingletonVars.sharedInstance.initMenuHasToChange = true
                        SingletonVars.sharedInstance.initDestination = .Trucant
                        SingletonVars.sharedInstance.isCaller = false;
                        hostVC!.presentViewController(secondViewController, animated: true, completion: {
                            
                        })
                    }
                }
            }
            
        } else {
            if userInfo["id_push"] != nil {
                dispatch_barrier_sync(serialQueueNotisAppD) {
                    NotificationManager.checkNewNotifications() { result in
                        if result == "TASK END" {
                            print("NOTI RECEIVED \(self.serialQueueNotisAppD.description)")
                        }
                    }
                }
            } else {
                print("UNKNOWN NOTIFICATION \(userInfo)")
            }
        }
    }
    
    func callNotificationTimeout() {
        if SingletonVars.sharedInstance.notificationCallActive == true {
            var hostVC = self.window?.rootViewController
            while let next = hostVC?.presentedViewController {
                hostVC = next
            }
            hostVC!.dismissViewControllerAnimated(true, completion: nil)
            
            discardCallNotifications()
            
            let params:[String:AnyObject] = ["date":Utils().getCurrentLocalDate(),
                                             "type":INIT_CELL_LOST_CALL,
                                             "idUsrVincles":SingletonVars.sharedInstance.idUserCall,
                                             "isRead":false]
            InitFeed.addNewFeedEntityOffline(params)
        }
    }
    
    func discardCallNotifications() {
        if SingletonVars.sharedInstance.notificationCallActive == true {
            SingletonVars.sharedInstance.notificationCallActive = false
            SingletonVars.sharedInstance.callInProgress = false
            let noti:UILocalNotification = myTimer?.userInfo as! UILocalNotification
            UIApplication.sharedApplication().cancelLocalNotification(noti)
        }
    }
    
    // [START upstream_callbacks]
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
    }
    // [END upstream_callbacks]
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            FIRMessaging.messaging().subscribeToTopic(subscriptionTopic)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        //        self.saveLastProcessNotiEpoch()
    }
    
    // [START disconnect_gcm_service]
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        NotificationManager.saveLastProcessNotiEpoch()
        FIRMessaging.messaging().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]
        
    }
    // [END disconnect_gcm_service]
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        rateMe()
        
    }
    
    // RATE THE APP
    
    //First get the nsObject by defining as an optional anyObject
    let appVersion: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    func rateMe() {

        if ((NSUserDefaults.standardUserDefaults().objectForKey("lastShownDate") as? NSDate) == nil) {
            addWeek()
        }
        
        let lastVersionRated = NSUserDefaults.standardUserDefaults().stringForKey("versionRate")
        let lastShownDate = NSUserDefaults.standardUserDefaults().objectForKey("lastShownDate") as? NSDate
        let today = NSDate()
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = appVersion as! String
        
        if today.timeIntervalSince1970 >= lastShownDate?.timeIntervalSince1970 {
            if (lastVersionRated == nil || Int(lastVersionRated!) < Int(version)) {
                showRateMe()
            }
        }
    }
    
    func addWeek() {
        let startDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.day = 7
        let date = calendar.dateByAddingComponents(components, toDate: startDate, options: [])
        NSUserDefaults.standardUserDefaults().setObject(date, forKey: "lastShownDate")
    }
    
    func showRateMe() {
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        let alert = UIAlertController(title: "\(langBundle.localizedStringForKey("RATE_TITLE", value: nil, table: nil))", message: "\(langBundle.localizedStringForKey("RATE_THANKS", value: nil, table: nil))\(appName)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "\(langBundle.localizedStringForKey("RATE_RATE", value: nil, table: nil))\(appName)", style: UIAlertActionStyle.Default, handler: { alertAction in
            UIApplication.sharedApplication().openURL(NSURL(string : "http://www.google.es")!)
            alert.dismissViewControllerAnimated(true, completion: nil)
            NSUserDefaults.standardUserDefaults().setObject(self.appVersion as! String, forKey: "versionRate")
        }))
        alert.addAction(UIAlertAction(title: "\(langBundle.localizedStringForKey("RATE_REMEMBER_LATER", value: nil, table: nil))", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        addWeek()
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    // [START connect_gcm_service]
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Connect to the GCM server to receive non-APNS notifications
        checkFcmConnection()
    }
    // [END connect_gcm_service]
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        NotificationManager.saveLastProcessNotiEpoch()
        self.saveContext()
    }
    
    
    func showAlertAppDelegate(title : String,message : String,buttonTitle : String,window: UIWindow){
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler: nil))
        
        var hostVC = self.window?.rootViewController
        
        while let next = hostVC?.presentedViewController {
            hostVC = next
        }
        hostVC?.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. 
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Vincles", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:true]
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        print ("SAVE CONTEXT")
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    
    
}

