//
//  AppDelegate.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import CoreData
import RealmSwift
import SlideMenuControllerSwift
import UserNotifications
import PushKit
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
import SwiftyJSON
import Reachability
import StoreKit
import VersionControl
import CoreDataManager
import CryptoSwift
import Alamofire
import WebRTC
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var showingVersionControl = false
    public var pendingToStoreInAlbum = [DownloadItem]()
    public var storedInAlbum = [Int]()
 var pendingPushes = [[String: String]]()

    var showingCallVC: CallContainerViewController?
    var recordingAudio = false
    var ratingShown = false

    var navigated = false
    var window: UIWindow?
    var versionLanguage = ""
    let reachability = try! Reachability()
    let dbVersion: UInt64 = 34
    var registrationToken: String?
    let messageKey = "onMessageReceived"
    let serialQueueNotisAppD = DispatchQueue(label: "com.vincles.serialQueueNotisAD")
    var splashVC: SplashScreenViewController?
    var showingLogin = false
    
    
    var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    var batteryState: UIDevice.BatteryState {
        return UIDevice.current.batteryState
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let fieldTrials = [String:String]()
        RTCInitFieldTrialDictionary(fieldTrials)
        RTCInitializeSSL()
        RTCSetupInternalTracer()
        
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        if UserDefaults.standard.value(forKey: "tamanyLletra") == nil{
            UserDefaults.standard.set("MITJA", forKey: "tamanyLletra")
        }
        
        if UserDefaults.standard.value(forKey: "saveToCameraRoll") == nil{
            UserDefaults.standard.set(true, forKey: "saveToCameraRoll")
        }
        
        startReachability()        
        //  Crashlytics().debugMode = true
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        Fabric.with([Crashlytics.self])
        
        // PUSH CONFIG
        
        FirebaseApp.configure()
        startPush(application: application)
        
        IQKeyboardManager.shared.enable = true
        
        configDatabase()
        setInitialLanguage()
        configMenu()
        configEnvironmentVars()
       // self.controlVersion()

        if !navigated{
            let splash = StoryboardScene.Splash.splashScreenViewController.instantiate()
            
            self.window?.rootViewController = SlideMenuController(mainViewController: UINavigationController(rootViewController: splash), leftMenuViewController: StoryboardScene.Menu.leftMenuTableViewController.instantiate())
        }
        
        return true
    }
    
    func controlVersion () {
        if !showingVersionControl{
            showingVersionControl = true
            
        let instanceOfAlert: T21AlertComponent = T21AlertComponent()
        instanceOfAlert.showAlert(withService: VERSION_CONTROL_URL, withLanguage:UserDefaults.standard.string(forKey: "i18n_language"), andCompletionBlock: { (error: Error?) in
            self.showingVersionControl = false
            self.managePendingPushes()
            if let error=error {
                print("ERROR CONTROLVERSION: ",error)
            }
        })
        }
        
    }
    
    func startReachability(){
        reachability.whenReachable = { reachability in
           
        }
        reachability.whenUnreachable = { _ in
            self.showNetworkPopup()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        if batteryState == .unplugged && batteryLevel == 0.2{
            showBatteryPopup(level: batteryLevel)
        }
        else if batteryState == .unplugged && batteryLevel == 0.1{
            showBatteryPopup(level: batteryLevel)
        }
        else if batteryState == .unplugged && batteryLevel == 0.05{
            showBatteryPopup(level: batteryLevel)
        }
    }
    
    func showBatteryPopup(level: Float){
        
        let battery = String(format: "%.0f", level*100)
        
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        popupVC.popupDescription = L10n.batteryLow("\(battery)%")
        popupVC.button1Title = L10n.ok
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 11;
        alertWindow.makeKeyAndVisible()
        
        alertWindow.rootViewController?.present(popupVC, animated: true, completion: nil)
    }
    
    func showNetworkPopup(){
        
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        popupVC.popupDescription = L10n.noNetwork
        popupVC.button1Title = L10n.ok
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 10;
        alertWindow.makeKeyAndVisible()
        
        alertWindow.rootViewController?.present(popupVC, animated: true, completion: nil)
    }
    
    @objc func rotated() {
        HUDHelper.sharedInstance.manageRotation()
        
    }
    
    func configEnvironmentVars(){
        
        let envName = Bundle.main.infoDictionary!["ENVIRONMENT"] as! String
        var envKeys = "env_keys"
        envKeys.append(envName)
        let envKeysPlist = Bundle.main.path(forResource: envKeys, ofType: "plist")!
        if let envDict = NSDictionary(contentsOfFile: envKeysPlist) as? [String: String]{
            
            IP = envDict["api_base_url"]!
            BASIC_AUTH_STR = envDict["api_key"]!
            SERVER_HOST_URL = envDict["vc_base_url"]!
            TENANT = envDict["TENANT"]!
            URL_PATH = envDict["URL_PATH"]!
            SUFFIX_LOGIN = envDict["SUFFIX_LOGIN"]!
            USERNAME_SUFFIX = envDict["USERNAME_SUFFIX"]!
            STUN_SERVER_URL = envDict["STUN_SERVER_URL"]!
            TURN_SERVER_UDP = envDict["TURN_SERVER_UDP"]!
            TURN_SERVER_UDP_USERNAME = envDict["TURN_SERVER_UDP_USERNAME"]!
            TURN_SERVER_UDP_PASSWORD = envDict["TURN_SERVER_UDP_PASSWORD"]!
            TURN_SERVER_TCP = envDict["TURN_SERVER_TCP"]!
            TURN_SERVER_TCP_USERNAME = envDict["TURN_SERVER_TCP_USERNAME"]!
            TURN_SERVER_TCP_PASSWORD = envDict["TURN_SERVER_TCP_PASSWORD"]!
        }
        var configKeys = "config_keys"
        configKeys.append(envName)
        let configKeysPlist = Bundle.main.path(forResource: configKeys, ofType: "plist")!
        if let configDict = NSDictionary(contentsOfFile: configKeysPlist) as? [String: String]{
            VERSION_CONTROL_URL = configDict["control_version_url"]!
            GA_TRACKING = configDict["analytic_key"]!
            RATING_URL = configDict["rate_url"]!

        }
    }
    
    func configDatabase(){
        let config = Realm.Configuration(
            schemaVersion: dbVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < self.dbVersion) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
    }
    
    func setInitialLanguage(){
        
        if let _ = UserDefaults.standard.string(forKey: "i18n_language") {} else {
            if(Locale.current.languageCode == "es"){
                UserDefaults.standard.set("es", forKey: "i18n_language")
            }
            else{
                UserDefaults.standard.set("ca", forKey: "i18n_language")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    func configMenu(){
        SlideMenuOptions.contentViewScale = 1
        
        let screenWidth  = UIScreen.main.fixedCoordinateSpace.bounds.width
        (UIDevice.current.userInterfaceIdiom == .pad) ? (SlideMenuOptions.leftViewWidth = screenWidth * 0.4) : (SlideMenuOptions.leftViewWidth = screenWidth * 0.8)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        for item in pendingToStoreInAlbum{
            if let id = item.downloadId, !storedInAlbum.contains(id){
                let albumSingleton = AlbumSingleton()
                albumSingleton.downloadImage = item.downloadImage
                albumSingleton.downloadId = item.downloadId
                albumSingleton.downloadVideo = item.downloadVideo
                albumSingleton.startDownloadToCameraRoll()
                storedInAlbum.append(id)
            }
        }
      
        storedInAlbum.removeAll()
        pendingToStoreInAlbum.removeAll()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        window?.endEditing(true)
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.controlVersion()
        
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        RTCShutdownInternalTracer()
        RTCCleanupSSL()
    }
    
}

extension AppDelegate{
    
    
    func pushLaunchOptions(notification: [String: AnyObject]){
        // 2
        let aps = notification["aps"] as! [String: AnyObject]
        
    }
    
    func startPush(application: UIApplication){
        self.registerVoIPPush()

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        let aps = userInfo["aps"] as! [String: AnyObject]
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                self.getNotificationSettings()
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
        UIApplication.shared.applicationIconBadgeNumber = 0

        print(response.notification.request.content.userInfo)

        let idString = response.notification.request.identifier
        let comps = idString.components(separatedBy: "_")
        
        
        var chatFrom: Int? = nil
        var idChat: Int? = nil
        var idUser: Int? = nil
        var idGroup: Int? = nil
        var idMeeting: Int? = nil
        var idHost: Int? = nil
        var code: String?
        
        switch response.notification.request.content.categoryIdentifier{
        case NOTI_NEW_MESSAGE:
            if let idInt = Int(comps[0]){
                chatFrom = idInt
            }
        case NOTI_NEW_CHAT_MESSAGE:
            if let idInt = Int(comps[0]){
                idChat = idInt
            }
        case NOTI_USER_LEFT_CIRCLE, NOTI_USER_UNLINKED, NOTI_USER_LINKED, NOTI_USER_UPDATED:
            if let idInt = Int(comps[0]){
                idUser = idInt
            }
        case NOTI_ADDED_TO_GROUP, NOTI_REMOVED_FROM_GROUP:
            if let idInt = Int(comps[0]){
                idGroup = idInt
            }
        case NOTI_NEW_USER_GROUP, NOTI_REMOVED_USER_GROUP:
            if let idInt = Int(comps[0]){
                idGroup = idInt
            }
        case NOTI_MEETING_INVITATION_EVENT,NOTI_MEETING_REJECTED_EVENT, NOTI_MEETING_ACCEPTED_EVENT, NOTI_MEETING_CHANGED_EVENT, NOTI_MEETING_INVITATION_REVOKE_EVENT, NOTI_MEETING_INVITATION_DELETED_EVENT, NOTI_MEETING_DELETED_EVENT:
            if let idInt = Int(comps[0]){
                idMeeting = idInt
            }
        case NOTI_INCOMING_CALL:
            if let idInt = Int(comps[0]){
                idUser = idInt
            }
        case NOTI_GROUP_USER_INVITATION_CIRCLE:
            let idInt = comps[0]
            code = idInt
            
        default:
            break
        }
        
        
        if let slideMenuController = self.window?.rootViewController as? SlideMenuController{
            
            
            
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            
            if let chatFrom = chatFrom{
                let circlesModelManager = CirclesGroupsModelManager.shared
                
                if (circlesModelManager.contactWithId(id: chatFrom) != nil){
                    let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                    let circlesModelManager = CirclesGroupsModelManager.shared
                    chatVC.toUserId = chatFrom
                    chatVC.toUser = circlesModelManager.contactWithId(id: chatFrom)
                    chatVC.showBackButton = true
                    if !navigated{
                        chatVC.openHomeOnBack = true
                    }
                    baseVC.containedViewController = chatVC
                    if let nav = slideMenuController.mainViewController as? UINavigationController{
                        nav.pushViewController(baseVC, animated: true)
                        navigated = true

                    }
                }
                else{
                    let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                    notsVC.showBackButton = true
                    if !navigated{
                        notsVC.openHomeOnBack = true
                    }
                    baseVC.containedViewController = notsVC
                    if let nav = slideMenuController.mainViewController as? UINavigationController{
                        nav.pushViewController(baseVC, animated: true)
                        navigated = true

                    }
                }
                
                
            }
            else if let idChat = idChat{
                let circlesModelManager = CirclesGroupsModelManager.shared
                if circlesModelManager.userGroupWithIdChat(idChat: idChat) != nil || circlesModelManager.dinamitzadorWithChatId(idChat: idChat) != nil{
                    let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                    if !navigated{
                        chatVC.openHomeOnBack = true
                    }
                    
                    if let group = circlesModelManager.groupWithChatId(idChat: idChat){
                        chatVC.group = group
                    }
                    else if let dinamitzadorGroup = circlesModelManager.dinamitzadorWithChatId(idChat: idChat){
                        chatVC.group = dinamitzadorGroup
                        chatVC.isDinam = true
                    }
                    
                    chatVC.showBackButton = true
                    if !navigated{
                        chatVC.openHomeOnBack = true
                    }
                    baseVC.containedViewController = chatVC
                    if let nav = slideMenuController.mainViewController as? UINavigationController{
                        nav.pushViewController(baseVC, animated: true)
                        navigated = true

                    }
                    
                }
                else{
                    let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                    notsVC.showBackButton = true
                    if !navigated{
                        notsVC.openHomeOnBack = true
                    }
                    baseVC.containedViewController = notsVC
                    if let nav = slideMenuController.mainViewController as? UINavigationController{
                        nav.pushViewController(baseVC, animated: true)
                        navigated = true

                    }
                }
                
            }
            else if idUser != nil{
                switch response.notification.request.content.categoryIdentifier{
                case  NOTI_USER_LINKED:
                    let circlesModelManager = CirclesGroupsModelManager.shared
                    
                    if (circlesModelManager.contactWithId(id: idUser!) != nil){
                        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                        chatVC.toUserId = idUser!
                        chatVC.toUser = circlesModelManager.contactWithId(id: idUser!)
                        chatVC.showBackButton = true
                        if !navigated{
                            chatVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = chatVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    else{
                        let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                        notsVC.showBackButton = true
                        if !navigated{
                            notsVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = notsVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    
                case NOTI_INCOMING_CALL:
                    let circlesModelManager = CirclesGroupsModelManager.shared
                    
                    if (circlesModelManager.contactWithId(id: idUser!) != nil){
                        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                        
                        let circlesManager = CirclesGroupsModelManager.shared
                        if circlesManager.contactWithId(id: idUser!) != nil{
                            chatVC.toUserId = idUser!
                            chatVC.toUser = circlesModelManager.contactWithId(id: idUser!)
                        }
                        else if let userObj = circlesManager.dinamitzadorWithId(id: idUser!){
                            var groupFound: Group?
                            if let groups = circlesManager.groups{
                                for group in groups{
                                    if let dinam = group.dynamizer{
                                        if dinam.id == userObj.id{
                                            groupFound = group
                                            break
                                        }
                                    }
                                }
                            }
                            if let groupFound = groupFound{
                                chatVC.isDinam = true
                                chatVC.group = groupFound
                            }
                            
                        }
                        
                        if !navigated{
                            chatVC.openHomeOnBack = true
                        }
                        chatVC.showBackButton = true
                        baseVC.containedViewController = chatVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    else{
                        let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                        notsVC.showBackButton = true
                        if !navigated{
                            notsVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = notsVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    
                default:
                    let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
                    contactsVC.showBackButton = true
                    baseVC.containedViewController = contactsVC
                    if let nav = slideMenuController.mainViewController as? UINavigationController{
                        nav.pushViewController(baseVC, animated: true)
                        navigated = true

                    }
                }
                
            }
            else if idGroup != nil{
                switch response.notification.request.content.categoryIdentifier{
                case NOTI_REMOVED_FROM_GROUP:
                    let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
                    contactsVC.showBackButton = true
                    contactsVC.filterContactsType = .groups
                    baseVC.containedViewController = contactsVC
                    if !navigated{
                        contactsVC.openHomeOnBack = true
                    }
                    if let nav = slideMenuController.mainViewController as? UINavigationController{
                        nav.pushViewController(baseVC, animated: true)
                        navigated = true

                    }
                case NOTI_ADDED_TO_GROUP:
                    let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                    let circlesModelManager = CirclesGroupsModelManager.shared
                    if (circlesModelManager.userGroupWithId(id: idGroup!) != nil){
                        chatVC.group = circlesModelManager.groupWithId(id: idGroup!)
                        chatVC.showBackButton = true
                        baseVC.containedViewController = chatVC
                        if !navigated{
                            chatVC.openHomeOnBack = true
                        }
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    else{
                        let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                        notsVC.showBackButton = true
                        if !navigated{
                            notsVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = notsVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    
                case NOTI_NEW_USER_GROUP, NOTI_REMOVED_USER_GROUP, NOTI_ADDED_TO_GROUP:
                    let circlesModelManager = CirclesGroupsModelManager.shared
                    if (circlesModelManager.userGroupWithId(id: idGroup!) != nil){
                        let groupVC = StoryboardScene.Chat.groupInfoViewController.instantiate()
                        groupVC.showBackButton = true
                        baseVC.containedViewController = groupVC
                        let circlesModelManager = CirclesGroupsModelManager.shared
                        groupVC.group = circlesModelManager.groupWithId(id: idGroup!)
                        if !navigated{
                            groupVC.openHomeOnBack = true
                        }
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    else{
                        let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                        notsVC.showBackButton = true
                        if !navigated{
                            notsVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = notsVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    
                default:
                    break
                }
                
            }
            else if idMeeting != nil{
                
                switch response.notification.request.content.categoryIdentifier{
                case NOTI_MEETING_INVITATION_EVENT,NOTI_MEETING_REJECTED_EVENT, NOTI_MEETING_ACCEPTED_EVENT, NOTI_MEETING_CHANGED_EVENT :
                    let meetingsModelManager = AgendaModelManager()
                    if meetingsModelManager.userMeetingWithId(id: idMeeting!) != nil{
                        let meetingVC = StoryboardScene.Agenda.agendaEventDetailViewController.instantiate()
                        meetingVC.showBackButton = true
                        if !navigated{
                            meetingVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = meetingVC
                        let agendaModelManager = AgendaModelManager()
                        meetingVC.meeting = agendaModelManager.meetingWithId(id: idMeeting!)
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    else{
                        let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                        notsVC.showBackButton = true
                        if !navigated{
                            notsVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = notsVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    
                case NOTI_MEETING_INVITATION_REVOKE_EVENT, NOTI_MEETING_DELETED_EVENT:
                    let agendaModelManager = AgendaModelManager()
                    if let meeting = agendaModelManager.userMeetingWithId(id: idMeeting!){
                        
                        let agendaVC = StoryboardScene.Agenda.agendaContainerViewController.instantiate()
                        agendaVC.showBackButton = true
                        baseVC.containedViewController = agendaVC
                        agendaVC.preloadOtherDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
                        
                        if !navigated{
                            agendaVC.openHomeOnBack = true
                        }
                        
                        baseVC.containedViewController = agendaVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    else{
                        let notsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                        notsVC.showBackButton = true
                        if !navigated{
                            notsVC.openHomeOnBack = true
                        }
                        baseVC.containedViewController = notsVC
                        if let nav = slideMenuController.mainViewController as? UINavigationController{
                            nav.pushViewController(baseVC, animated: true)
                            navigated = true

                        }
                    }
                    
                    
                default:
                    break
                    
                }
            }
            else if code != nil{
                
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                
                let addContactVC = StoryboardScene.Contacts.addContactViewController.instantiate()
                addContactVC.code = code!
                addContactVC.showBackButton = true
                if !navigated{
                    addContactVC.openHomeOnBack = true
                }
                baseVC.containedViewController = addContactVC
                if let nav = slideMenuController.mainViewController as? UINavigationController{
                    nav.pushViewController(baseVC, animated: true)
                    navigated = true

                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void){
        completionHandler([.alert, .badge, .sound])
        
    }
}


extension AppDelegate : PKPushRegistryDelegate {
    
    func registerVoIPPush() {
        let voipPushResgistry = PKPushRegistry(queue: DispatchQueue.main)
        voipPushResgistry.delegate = self
        voipPushResgistry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if type == PKPushType.voIP {
            self.registrationToken = pushCredentials.token.hexEncodedString()
            let profileModelManager = ProfileModelManager()
            profileModelManager.setPushkitToken(token: pushCredentials.token.hexEncodedString())
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        
        print(payload.dictionaryPayload)
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, String>
        
        if UserDefaults.standard.bool(forKey: "loginDone") && !showingVersionControl{
            let message = payloadDict?["alert"]
            managePushMessage(message: message)
            
        }
        else if UserDefaults.standard.bool(forKey: "loginDone") && showingVersionControl{
            if let payload = payloadDict{
                pendingPushes.append(payload)
            }
        }
    }
    
    func managePushMessage(message: String?){
        if let message = message{
            if let notificationDict = JSON(parseJSON: message).dictionaryObject{
                let notificationManager = NotificationManager()
                
                if let idUser = notificationDict["idUser"] as? Int ,  var idRoom = notificationDict["idRoom"] as? String,  let push_notification_time = notificationDict["push_notification_time"] as? Int64 , let idPush = notificationDict["id_push"] as? Int, let push_notification_type = notificationDict["push_notification_type"] as? String{
                    
                    if push_notification_type == NOTI_INCOMING_CALL{
                        let notificationsModelManager = NotificationsModelManager()
                        
                        _ = notificationsModelManager.getNextFakeNotificationId
                        
                        let notification = VincleNotification()
                        notification.type = NOTI_INCOMING_CALL
                        notification.id = idPush
                        
                        notification.idRoom = idRoom
                        notification.idUser = idUser
                        
                        let realm = try! Realm()
                        
                        let callee = realm.objects(AuthResponse.self).first?.userId
                        let profileModelManager = ProfileModelManager()
                        if let user = profileModelManager.getUserMe(){
                            if let calleeInt = callee{
                                if calleeInt == user.id{
                                    notification.creationTimeInt = push_notification_time
                                    notification.processed = true
                                    DispatchQueue.main.async {
                                        
                                        let realm = try! Realm()
                                        try! realm.write {
                                            realm.add(notification, update: true)
                                        }
                                    }
                                    
                                    ApiClient.cancelTasks()
                                    
                                    let notificationManager = NotificationManager()
                                    
                                    ApiClientURLSession.sharedInstance.getServerTime(onSuccess: {
                                        
                                        if let timeInt = UserDefaults.standard.object(forKey: "loginTime") as? Int64{
                                            if timeInt - push_notification_time < 30000{
                                                
                                                let circlesModelManager = CirclesGroupsModelManager.shared
                                                
                                                var show = true
                                                if circlesModelManager.userWithId(id: idUser) == nil{
                                                    show = false
                                                }
                                                
                                                let notificationNameCallStart = Notification.Name(NOTI_START_CALL)
                                                NotificationCenter.default.post(name: notificationNameCallStart, object: nil)
                                                
                                                if show{
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        let baseVC2 = StoryboardScene.Base.baseViewController.instantiate()
                                                        let callVC = StoryboardScene.Call.callContainerViewController.instantiate()
                                                        callVC.isCaller = false
                                                        callVC.callerId = idUser
                                                        callVC.notification = notification
                                                        callVC.roomId = idRoom
                                                        
                                                        baseVC2.containedViewController = callVC
                                                        
                                                        
                                                        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                                                        alertWindow.backgroundColor = .clear
                                                        alertWindow.rootViewController = UIViewController()
                                                        alertWindow.windowLevel = UIWindow.Level.alert + 5;
                                                        alertWindow.makeKeyAndVisible()
                                                        
                                                        
                                                        
                                                        
                                                        if (self.showingCallVC != nil){
                                                            DispatchQueue.main.async {
                                                                UIApplication.shared.beginIgnoringInteractionEvents()
                                                                
                                                                self.showingCallVC?.dismiss(animated: false, completion: {
                                                                    
                                                                    alertWindow.rootViewController?.present(baseVC2, animated: false, completion: nil)
                                                                    UIApplication.shared.endIgnoringInteractionEvents()
                                                                    
                                                                })
                                                            }
                                                            
                                                        }
                                                        else{
                                                            UIApplication.shared.beginIgnoringInteractionEvents()
                                                            
                                                            alertWindow.rootViewController?.present(baseVC2, animated: false, completion: nil)
                                                            UIApplication.shared.endIgnoringInteractionEvents()
                                                        }
                                                        
                                                        let state = UIApplication.shared.applicationState
                                                        if state == .background  || state == .inactive{
                                                            Timer.after(1.seconds, {
                                                                CallKitManager.incomingCall(user: user)
                                                            })
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                else{
                                                    DispatchQueue.main.async {
                                                        CallKitManager.endCall()
                                                        
                                                        notificationManager.showLocalNotificationForMissedCall(user: idUser, room: idRoom)
                                                    }
                                                }
                                                
                                            }
                                            else{
                                                DispatchQueue.main.async {
                                                    CallKitManager.endCall()
                                                    notificationManager.showLocalNotificationForMissedCall(user: idUser, room: idRoom)
                                                }
                                            }
                                        }
                                        
                                    }) {
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    else if push_notification_type == NOTI_ERROR_IN_CALL{
                        if (self.showingCallVC != nil){
                            self.showingCallVC!.receivedErrorInCall()
                            CallKitManager.endCall()
                        }
                        
                    }
                }
                else if (notificationDict["id_push"] as? Int) != nil {
                    
                    notificationManager.processNotification(noti: message)
                }
                
            }
        }
    }
    
    func managePendingPushes(){
        if pendingPushes.count > 0{
            let pending = pendingPushes.remove(at: 0)
            let message = pending["alert"]
            managePushMessage(message: message)
        }
        
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        NSLog("token invalidated")
        
        let profileModelManager = ProfileModelManager()
        profileModelManager.removePushkitToken()
        
    }
    
    func processNotification(_ json:String) {
        
    }
    
    
}

extension AppDelegate : PopUpDelegate {
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            
        }
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            
        }
    }
    func closeButtonClicked(popup: PopupViewController) {
        
    }
    
}


extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
