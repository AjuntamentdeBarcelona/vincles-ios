//
//  SplashScreenViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SlideMenuControllerSwift
import CoreDataManager
import EventKit

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var barcelonaLogoTop: NSLayoutConstraint!
    @IBOutlet weak var barcelonaLogoWidth: NSLayoutConstraint!
    @IBOutlet weak var appIconWidth: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    
    lazy var handler = OAuth2Handler()
    lazy var circlesManager = CirclesManager()
    lazy var profileManager = ProfileManager()
    lazy var authModelManager = AuthModelManager()
    lazy var  notificationsManager = NotificationManager()
    lazy var  notificationsModelManager = NotificationsModelManager()
    lazy var libraryManager = GalleryManager()
    
    var msg = ""
    
    var newToken = false
    var cannotRenew = false
    
    var chatFrom: Int?
    var idChat: Int?
    var idUser: Int?
    var idGroup: Int?
    var idOpenGroup: Int?
    var notificationType:String?
    var idMeeting: Int?
    var code:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.slideMenuController()?.removeLeftGestures()
        
        if checkMigration(){
            let dbModelManager = DBModelManager()
            dbModelManager.removeAllItemsFromDatabase()
            
            Timer.after(0.2.seconds) {
                
                
                let authorizationStatus = EKEventStore.authorizationStatus(for: .event);
                switch authorizationStatus {
                case .notDetermined:
                    print("notDetermined");
                case .restricted:
                    print("restricted");
                case .denied:
                    print("denied");
                case .authorized:
                    EventsLoader.removeAllEvents()
                    EventsLoader.removeCalendar()
                    
                }
                
                let cdm = CoreDataManager.sharedInstance
                
                let mainCtx = cdm.mainContext
                
                let users = mainCtx.managerFor(UserCercle.self).array
                
                
                let email = users[0].mail
                let password = users[0].password
                let pass = Utils().getDecryptedPass(pass: password!, id: users[0].id!)
                
                let authManager = AuthManager()
                
                authManager.login(email: email!, password: pass, onSuccess: { () in
                    
                    self.removeOldDatabase()
                    
                    self.getProfile()
                    
                    
                }) { (error) in
                    
                    DispatchQueue.main.async { [unowned self] in
                        self.navigationController?.pushViewController(StoryboardScene.Auth.termsConditionsViewController.instantiate(), animated: true)
                    }
                    self.removeOldDatabase()
                    
                }
            }
        }
        else{
            setTimer()
            
            if authModelManager.hasUser && UserDefaults.standard.bool(forKey: "loginDone"){
                
                getNotifications()
            }
        }
        
        
        setConstraints()
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            labelTitle.font = UIFont(font: FontFamily.SourceSansPro.extraLight, size: 55)
        }
        
        
    }
    
    func removeOldDatabase(){
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for file in fileURLs{
                let pathExtention = file.pathExtension
                print(file.path)
                if !file.path.contains("realm") && !file.path.contains("webrtc_logs"){
                    try? fileManager.removeItem(at: file)
                }
                
                
            }
            // process files
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
    }
    
    func checkMigration() -> Bool{
        CoreDataManager.sharedInstance.setupWithModel("Vincles", andFileName: "SingleViewCoreData.sqlite")
        
        let cdm = CoreDataManager.sharedInstance
        
        let mainCtx = cdm.mainContext
        
        let users = mainCtx.managerFor(UserCercle.self).array
        
        return users.count > 0
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_SPLASH)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    func setConstraints(){
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.regular) {
                barcelonaLogoTop.constant = self.view.bounds.size.height * 0.1
                barcelonaLogoWidth.constant = self.view.bounds.size.width * 0.5
                appIconWidth.constant = self.view.bounds.size.width * 0.4
            }
            else{
                barcelonaLogoTop.constant = self.view.bounds.size.height * 0.1
                barcelonaLogoWidth.constant =  self.view.bounds.size.width * 0.25
                appIconWidth.constant =  self.view.bounds.size.width * 0.15
            }
            
        }
        else{
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact) {
                barcelonaLogoTop.constant =  self.view.bounds.size.height * 0.1
                barcelonaLogoWidth.constant =  self.view.bounds.size.width * (1/3)
                appIconWidth.constant = self.view.bounds.size.width * 0.3
            }
            else{
                barcelonaLogoTop.constant = self.view.bounds.size.height * 0.1
                barcelonaLogoWidth.constant = self.view.bounds.size.width * 0.25
                appIconWidth.constant = self.view.bounds.size.width * 0.15
            }
            
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setConstraints()
    }
    
    func setTimer(){
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(runTimeCoded), userInfo: nil, repeats: false)
    }
    
    @objc func runTimeCoded(){
        if(!newToken){
            // handler.cancelTask()
        }
        setNavigation()
    }
    
    func setNavigation(){
        AlarmSingleton.sharedInstance.setupAlarm()
        
        if cannotRenew{
            if UserDefaults.standard.bool(forKey: "termsApproved"){
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if (!appDelegate.navigated){
                    appDelegate.navigated = true
                    self.navigationController?.pushViewController(StoryboardScene.Auth.loginViewController.instantiate(), animated: true)
                }
            }
            else{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                if (!appDelegate.navigated){
                    appDelegate.navigated = true
                    self.navigationController?.pushViewController(StoryboardScene.Auth.termsConditionsViewController.instantiate(), animated: true)
                }
                
                
            }
        }
        else if authModelManager.hasUser && UserDefaults.standard.bool(forKey: "loginDone")
        {
            
            self.slideMenuController()?.addLeftGestures()
            
            if let chatId = chatFrom{
                let circlesModelManager = CirclesGroupsModelManager()
                
                let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                chatVC.toUserId = chatId
                chatVC.toUser = circlesModelManager.contactWithId(id: chatId)
                chatVC.showBackButton = true
                chatVC.openHomeOnBack = true
                
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                baseVC.containedViewController = chatVC
                
                self.navigationController?.pushViewController(baseVC, animated: true)
                
            }
            else if let chatId = idChat{
                let circlesModelManager = CirclesGroupsModelManager()
                
                let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                if let group = circlesModelManager.groupWithChatId(idChat: chatId){
                    chatVC.group = group
                }
                else if let dinamitzadorGroup = circlesModelManager.dinamitzadorWithChatId(idChat: chatId){
                    chatVC.group = dinamitzadorGroup
                    chatVC.isDinam = true
                }
                chatVC.showBackButton = true
                chatVC.openHomeOnBack = true
                
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                baseVC.containedViewController = chatVC
                
                self.navigationController?.pushViewController(baseVC, animated: true)
                
            }
            else if idUser != nil{
                if let type = notificationType{
                    switch type{
                    case  NOTI_USER_LINKED:
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        
                        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                        let circlesModelManager = CirclesGroupsModelManager()
                        chatVC.toUserId = idUser!
                        chatVC.toUser = circlesModelManager.contactWithId(id: idUser!)
                        chatVC.showBackButton = true
                        baseVC.containedViewController = chatVC
                        chatVC.openHomeOnBack = true
                        
                        self.navigationController?.pushViewController(baseVC, animated: true)
                        
                    default:
                        let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
                        contactsVC.showBackButton = true
                        contactsVC.openHomeOnBack = true
                        
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        baseVC.containedViewController = contactsVC
                        
                        self.navigationController?.pushViewController(baseVC, animated: true)
                        
                    }
                }
                
                
                
            }
            else if idGroup != nil{
                if let type = notificationType{
                    switch type{
                    case  NOTI_REMOVED_FROM_GROUP:
                        
                        let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
                        contactsVC.showBackButton = true
                        contactsVC.openHomeOnBack = true
                        contactsVC.filterContactsType = .groups
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        baseVC.containedViewController = contactsVC
                        
                        
                        self.navigationController?.pushViewController(baseVC, animated: true)
                        
                        
                    default:
                        let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
                        contactsVC.showBackButton = true
                        contactsVC.openHomeOnBack = true
                        
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        baseVC.containedViewController = contactsVC
                        
                        
                        self.navigationController?.pushViewController(baseVC, animated: true)
                        
                    }
                }
                
                
                
                
            }
            else if idOpenGroup != nil{
                
                if let type = notificationType{
                    switch type{
                    case  NOTI_ADDED_TO_GROUP:
                        
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        
                        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                        let circlesModelManager = CirclesGroupsModelManager()
                        chatVC.group = circlesModelManager.groupWithId(id: idOpenGroup!)
                        chatVC.showBackButton = true
                        chatVC.openHomeOnBack = true
                        baseVC.containedViewController = chatVC
                        self.navigationController?.pushViewController(baseVC, animated: true)
                        
                    default:
                        let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
                        contactsVC.showBackButton = true
                        contactsVC.openHomeOnBack = true
                        
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        baseVC.containedViewController = contactsVC
                        
                        
                        self.navigationController?.pushViewController(baseVC, animated: true)
                        
                    }
                }
                
                
                
                
            }
                
            else if idMeeting != nil{
                if let type = notificationType{
                    switch type{
                    case NOTI_MEETING_INVITATION_EVENT, NOTI_MEETING_REJECTED_EVENT, NOTI_MEETING_ACCEPTED_EVENT, NOTI_MEETING_CHANGED_EVENT:
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        
                        let meetingVC = StoryboardScene.Agenda.agendaEventDetailViewController.instantiate()
                        meetingVC.showBackButton = true
                        meetingVC.openHomeOnBack = true
                        baseVC.containedViewController = meetingVC
                        let agendaModelManager = AgendaModelManager()
                        meetingVC.meeting = agendaModelManager.meetingWithId(id: idMeeting!)
                        self.navigationController?.pushViewController(baseVC, animated: true)
                    case NOTI_MEETING_INVITATION_REVOKE_EVENT, NOTI_MEETING_DELETED_EVENT:
                        let agendaModelManager = AgendaModelManager()
                        if let meeting = agendaModelManager.meetingWithId(id: idMeeting!){
                            
                            /*
                             let agendaVC = StoryboardScene.Agenda.ndaDayViewController.instantiate()
                             agendaVC.selectedDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
                             agendaVC.showBackButton = true
                             */
                            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                            
                            let agendaVC = StoryboardScene.Agenda.agendaContainerViewController.instantiate()
                            agendaVC.showBackButton = true
                            baseVC.containedViewController = agendaVC
                            agendaVC.preloadOtherDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
                            
                            agendaVC.openHomeOnBack = true
                            baseVC.containedViewController = agendaVC
                            self.navigationController?.pushViewController(baseVC, animated: true)
                            
                        }
                        
                    default:
                        break
                        
                    }
                }
                
            }
                
            else if code != nil{
                
                if let type = notificationType{
                    switch type{
                    case  NOTI_GROUP_USER_INVITATION_CIRCLE:
                        
                        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                        
                        let addContactVC = StoryboardScene.Contacts.addContactViewController.instantiate()
                        addContactVC.code = code!
                        addContactVC.showBackButton = true
                        baseVC.containedViewController = addContactVC
                        self.navigationController?.pushViewController(baseVC, animated: true)
                        
                        
                    default:
                        break
                        
                    }
                }
                
                
                
                
            }
                
                
            else{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                if (!appDelegate.navigated){
                    appDelegate.navigated = true
                    let homeVC = StoryboardScene.Main.homeViewController.instantiate()
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
                
                
                
            }
        }
        else{
            if UserDefaults.standard.bool(forKey: "termsApproved"){
                self.navigationController?.pushViewController(StoryboardScene.Auth.loginViewController.instantiate(), animated: true)
            }
            else{
                self.navigationController?.pushViewController(StoryboardScene.Auth.termsConditionsViewController.instantiate(), animated: true)
                
                
            }
        }
    }
    
    func getNotifications(){
        
        
        notificationsManager.getNotifications(onSuccess: { (hasMoreItems) in
            if hasMoreItems{
                self.getNotifications()
            }
            else{
                self.notificationsManager.processUnwatchedNotifications()
            }
        }) { (error) in
            self.notificationsManager.processUnwatchedNotifications()
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func managerError(){
        setNavigation()
        
    }
    
    func getProfile(){
        print("LOGIN 1")
        
        
        let profileManager = ProfileManager()
        profileManager.getSelfProfile(onSuccess: {
            
            self.getGalleryItems()
            
        }) { (error) in
            self.managerError()
        }
    }
    
    func getGalleryItems(){
        print("LOGIN 2")
        libraryManager.fromDate = nil
        libraryManager.getContentsLibrary(onSuccess: { (hasMoreItems, needsReload) in
            if hasMoreItems{
                self.getGalleryItems()
            }
            else{
                self.getCirclesUser()
                
            }
        }) { (error) in
            //   self.getCirclesUser()
            
            self.managerError()
        }
    }
    
    func getCirclesUser(){
        print("LOGIN 3")
        
        circlesManager.getCirclesUser(onSuccess: { needsReload in
            let profileModelManager = ProfileModelManager()
            if profileModelManager.userIsVincle{
                self.circlesManager.getGroupsUser(onSuccess: { needsReloadGroups in
                    self.getMissatgesChatsUser()
                }, onError: { (error) in
                    
                })
            }
            else{
                self.getMissatgesChatsUser()
            }
            
        }, onError: { (error) in
            self.managerError()
        })
    }
    
    func getMissatgesChatsUser(){
        print("LOGIN 4")
        
        let chatManager = ChatManager()
        chatManager.getAllChatUserMessages(onSuccess: {
            let profileModelManager = ProfileModelManager()
            if profileModelManager.userIsVincle{
                self.getParticipantsGroup()
            }
            else{
                self.getServerTime()
                
            }
        }) { (error) in
            self.managerError()
        }
    }
    
    func getParticipantsGroup(){
        print("LOGIN 5")
        
        let circlesManager = CirclesManager()
        circlesManager.getAllGroupsParticipants(onSuccess: {
            self.getMissatgesChatsGroup()
            
        }) { (error) in
            self.managerError()
        }
    }
    
    
    func getMissatgesChatsGroup(){
        let chatManager = ChatManager()
        chatManager.getAllChatGroupMessages(onSuccess: {
            self.getMissatgesChatsDinamitzadors()
            
        }) { (error) in
            self.managerError()
        }
    }
    
    
    
    func getMissatgesChatsDinamitzadors(){
        let chatManager = ChatManager()
        chatManager.getAllChatDinamitzadorsMessages(onSuccess: {
            self.getServerTime()
        }) { (error) in
            self.managerError()
        }
    }
    
    func getMeetings(){
        let agendaManager = AgendaManager()
        agendaManager.getMeetings(onSuccess: { (hasMoreItems) in
            if hasMoreItems{
                self.getMeetings()
            }
            else{
                
                
                ApiClient.sendMigrationStatus(onSuccess: {
                    
                    UserDefaults.standard.set(true, forKey: "loginDone")
                    let homeVC = StoryboardScene.Main.homeViewController.instantiate()
                    //                    self.navigationController?.viewControllers = [homeVC]
                    self.navigationController?.pushViewController(homeVC, animated: true)
                    
                }, onError: { (error) in
                    self.managerError()
                })
                
                //  AlarmSingleton.sharedInstance.setupAlarm()
                
            }
        }) { (error) in
            self.managerError()
            
        }
    }
    
    func getServerTime(){
        notificationsManager.getServerTime(onSuccess: {
            self.notificationsManager.setWatchedNotifications()
            self.getMeetings()
        }) {
            self.managerError()
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

