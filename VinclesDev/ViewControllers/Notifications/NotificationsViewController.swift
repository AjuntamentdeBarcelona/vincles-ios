//
//  NotificationsViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import SlideMenuControllerSwift
import Reachability
import Firebase

class NotificationsViewController: UIViewController, ProfileImageManagerDelegate, GroupImageManagerDelegate {
   
    
    @IBOutlet weak var tableView: UITableView!
    lazy var dataSource = NotificationsDataSource()
    lazy var notificationsModelManager = NotificationsModelManager()
    lazy var  notificationsManager = NotificationManager()
    var showBackButton = true
    @IBOutlet weak var noNotificationsLabel: UILabel!
    var openHomeOnBack = false
    let reachability = try! Reachability()
    let errorPermission = 1006

    override func viewDidLoad() {
        super.viewDidLoad()
        noNotificationsLabel.text = L10n.noNotifications
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        noNotificationsLabel.isHidden = true

        setDataSource()
        configNavigationBar()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileImageManager.sharedInstance.delegate = self
        GroupImageManager.sharedInstance.delegate = self

        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationsViewController.notificationProcessed), name: notificationName, object: nil)
        getNotifications()
        reloadTableData()
        
        Analytics.setScreenName(ANALYTICS_NOTIFICATIONS, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_NOTIFICATIONS)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func didDownload(userId: Int) {
        for cell in tableView.visibleCells{
            if let cell = cell as? NotificationsTableViewCell{
                if cell.userId == userId{
                    cell.setAvatar()
                }
            }
        }
    }
    
    func didError(userId: Int) {
        for cell in tableView.visibleCells{
            if let cell = cell as? NotificationsTableViewCell{
                if cell.userId == userId{
                    cell.setAvatar()
                }
            }
        }
    }
    
    func didDownload(groupId: Int) {
        
        for cell in tableView.visibleCells{
            if let inCell = cell as? NotificationsTableViewCell, inCell.groupId == groupId{
                inCell.setAvatar()
            }
        }
        
    }
    
    func didError(groupId: Int) {
        for cell in tableView.visibleCells{
            if let inCell = cell as? NotificationsTableViewCell, inCell.groupId == groupId{
                inCell.setAvatar()
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
            
        }
        
    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
        dataSource.items = notificationsModelManager.getItems()
        if dataSource.items.count == 0{
            noNotificationsLabel.isHidden = false
            tableView.isHidden = true
        }
        else{
            noNotificationsLabel.isHidden = true
            tableView.isHidden = false
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationsModelManager.markAllWatched()
        
    }
    func setDataSource(){
        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
        dataSource.items = notificationsModelManager.getItems()
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        dataSource.delegate = self
        
        if dataSource.items.count == 0{
            noNotificationsLabel.isHidden = false
            tableView.isHidden = true
        }
        else{
            noNotificationsLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
            
            baseViewController.navTitle = ""
            baseViewController.leftAction = leftAction
            
            baseViewController.navTitle = L10n.avisos
            
        }
    }
    
    
    func leftAction(_params: Any...) -> UIViewController?{
        if openHomeOnBack{
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let mainViewController = StoryboardScene.Main.homeViewController.instantiate()
                nav.setViewControllers([mainViewController], animated: true)
            }
            return nil
        }
        return self.navigationController?.popViewController(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension NotificationsViewController: NotificationsDataSourceDelegate{
    func actionButtonPressed(notification: VincleNotification) {
        switch notification.type {
        case NOTI_NEW_MESSAGE:
            let chatModelManager = ChatModelManager()
            let message = chatModelManager.messageWith(id: notification.idMessage)
            
            if let chatFrom = message?.idUserFrom{
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
                let circlesModelManager = CirclesGroupsModelManager.shared
                chatVC.toUserId = chatFrom
                chatVC.toUser = circlesModelManager.contactWithId(id: chatFrom)
                chatVC.showBackButton = true
                baseVC.containedViewController = chatVC
                if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                    nav.pushViewController(baseVC, animated: true)
                }
            }
        case NOTI_NEW_CHAT_MESSAGE:
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()

            let circlesModelManager = CirclesGroupsModelManager.shared
            
            let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
            
            if let group = circlesModelManager.groupWithChatId(idChat: notification.idChat){
                chatVC.group = group
            }
            else if let dinamitzadorGroup = circlesModelManager.dinamitzadorWithChatId(idChat: notification.idChat){
                chatVC.group = dinamitzadorGroup
                chatVC.isDinam = true
            }
            
            
            chatVC.showBackButton = true
            baseVC.containedViewController = chatVC
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
         
        case NOTI_USER_LINKED:
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
            let circlesModelManager = CirclesGroupsModelManager.shared
            chatVC.toUserId = notification.idUser
            chatVC.toUser = circlesModelManager.contactWithId(id: notification.idUser)
            chatVC.showBackButton = true
            baseVC.containedViewController = chatVC
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
        case NOTI_USER_UNLINKED, NOTI_USER_LEFT_CIRCLE:
            let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
            contactsVC.showBackButton = true
            
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            baseVC.containedViewController = contactsVC
            
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
        case NOTI_ADDED_TO_GROUP:
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            
            let circlesModelManager = CirclesGroupsModelManager.shared
            
            let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
            
            if let group = circlesModelManager.groupWithId(id: notification.idGroup){
                chatVC.group = group
            }
           
            
            
            chatVC.showBackButton = true
            baseVC.containedViewController = chatVC
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
            
        case NOTI_REMOVED_FROM_GROUP:
            let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
            contactsVC.showBackButton = true
            contactsVC.filterContactsType = .groups
            
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            baseVC.containedViewController = contactsVC
            
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
            
        case NOTI_MEETING_INVITATION_EVENT, NOTI_MEETING_CHANGED_EVENT, NOTI_MEETING_ACCEPTED_EVENT, NOTI_MEETING_REJECTED_EVENT, NOTI_FAKE_REMINDER_EVENT:
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()

            let meetingVC = StoryboardScene.Agenda.agendaEventDetailViewController.instantiate()
            meetingVC.showBackButton = true
            baseVC.containedViewController = meetingVC
            let agendaModelManager = AgendaModelManager()
            meetingVC.meeting = agendaModelManager.meetingWithId(id: notification.idMeeting)
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
            
        case NOTI_MEETING_INVITATION_REVOKE_EVENT, NOTI_MEETING_DELETED_EVENT:
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            
           /*
            let agendaVC = StoryboardScene.Agenda.ndaDayViewController.instantiate()
            agendaVC.showBackButton = true
            baseVC.containedViewController = agendaVC
            let agendaModelManager = AgendaModelManager()
            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){
                agendaVC.selectedDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
            }
            */
            
            let agendaVC = StoryboardScene.Agenda.agendaContainerViewController.instantiate()
            agendaVC.showBackButton = true
            baseVC.containedViewController = agendaVC
            let agendaModelManager = AgendaModelManager()
            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){
                agendaVC.preloadOtherDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
            }
            
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
        case NOTI_INCOMING_CALL:
            let circlesModelManager = CirclesGroupsModelManager.shared
            if WebRTCCallManager.sharedInstance.roomId == nil && circlesModelManager.contactWithId(id: notification.idUser) != nil{
                
                if reachability.connection != .none{
                   
                    if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized && AVCaptureDevice.authorizationStatus(for: .audio) ==  .authorized {
                        DispatchQueue.main.async {
                            self.newCall(notification: notification)
                        }
                        
                    } else {
                        
                        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
                                if granted {
                                    DispatchQueue.main.async {
                                        self.newCall(notification: notification)
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        self.errorPopupMicrophone()
                                        
                                    }
                                    
                                }
                            })
                        }
                        else if AVCaptureDevice.authorizationStatus(for: .audio) ==  .authorized {
                            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                                if granted {
                                    DispatchQueue.main.async {
                                        self.newCall(notification: notification)
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async {
                                        self.errorPopupVideo()
                                        
                                    }
                                    
                                }
                            })
                        }
                        else{
                            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                                if granted {
                                    AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
                                        if granted {
                                            DispatchQueue.main.async {
                                                self.newCall(notification: notification)
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                self.errorPopupMicrophone()
                                                
                                            }
                                            
                                        }
                                    })
                                } else {
                                    DispatchQueue.main.async {
                                        self.errorPopupVideo()
                                    }
                                    
                                }
                            })
                        }
                        
                    }
                    
                    
                    
                  
                }
                else{
                    let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                    popupVC.delegate = self
                    popupVC.modalPresentationStyle = .overCurrentContext
                    popupVC.popupTitle = L10n.appName
                    popupVC.popupDescription = L10n.callConnection
                    popupVC.button1Title = L10n.ok
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(popupVC, animated: true, completion: nil)
                }
              
            
           
            }
         
        case NOTI_GROUP_USER_INVITATION_CIRCLE:

            
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            
            let addContactVC = StoryboardScene.Contacts.addContactViewController.instantiate()
            addContactVC.code = notification.code
            addContactVC.showBackButton = true
            baseVC.containedViewController = addContactVC
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(baseVC, animated: true)
            }
        default:
            break
        }
    }
    
    func newCall(notification: VincleNotification){
        let circlesModelManager = CirclesGroupsModelManager.shared

        let baseVC2 = StoryboardScene.Base.baseViewController.instantiate()
        let callVC = StoryboardScene.Call.callContainerViewController.instantiate()
        callVC.isCaller = true
        callVC.calleeId = notification.idUser
        baseVC2.containedViewController = callVC
        
        self.present(baseVC2, animated: true, completion: nil)
        
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        
        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
        chatVC.toUserId = notification.idUser
        chatVC.toUser = circlesModelManager.contactWithId(id: notification.idUser)
        chatVC.showBackButton = true
        baseVC.containedViewController = chatVC
        if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
            nav.pushViewController(baseVC, animated: true)
        }
    }

    func errorPopupVideo(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.permisCameraVideo
        popupVC.button1Title = L10n.permisosAnarConfiguracio
        popupVC.button2Title = L10n.cancelar
        
        popupVC.view.tag = self.errorPermission
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func errorPopupMicrophone(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.permisMicrofon
        popupVC.button1Title = L10n.permisosAnarConfiguracio
        popupVC.button2Title = L10n.cancelar
        
        popupVC.view.tag = self.errorPermission
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func reloadTableData() {
        dataSource.items = notificationsModelManager.getItems()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        if dataSource.items.count == 0{
            noNotificationsLabel.isHidden = false
            tableView.isHidden = true
        }
        else{
            noNotificationsLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    
}

extension NotificationsViewController: PopUpDelegate{
    
  
    
    func firstButtonClicked(popup: PopupViewController) {
        if popup.view.tag == errorPermission{
            popup.dismissPopup {
                UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                
            }
            
            
        }
        else{
            popup.dismissPopup {
            }
            
        }
       
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
    }
    func closeButtonClicked(popup: PopupViewController) {
        
    }
}

