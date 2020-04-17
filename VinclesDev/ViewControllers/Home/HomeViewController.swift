//
//  HomeViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import AlamofireImage
import RealmSwift
import Crashlytics
import AppStoreRatings
import Firebase

class HomeViewController: UIViewController, ProfileImageManagerDelegate, GroupImageManagerDelegate {
    func didDownload(userId: Int) {
        if let user = profileModelManager.getUserMe(), userId == user.id{
            self.viewHeader.configWithUser()
        }
        else{
            for cell in viewContactes.contactsCollectionView.visibleCells{
                if let inCell = cell as? ContactCollectionViewCell, inCell.userId == userId{
                    inCell.setAvatar()
                }
            }
        }
    }
    
    func didError(userId: Int) {
        if let user = profileModelManager.getUserMe(), userId == user.id{
            self.viewHeader.configWithError()
        }
        else{
            for cell in viewContactes.contactsCollectionView.visibleCells{
                if let inCell = cell as? ContactCollectionViewCell, inCell.userId == userId{
                    inCell.setAvatar()
                }
            }
        }
    }
    
    func didDownload(groupId: Int) {
       
            for cell in viewContactes.contactsCollectionView.visibleCells{
                if let inCell = cell as? ContactCollectionViewCell, inCell.groupId == groupId{
                    inCell.setAvatar()
                }
            }
        
    }
    
    func didError(groupId: Int) {
        for cell in viewContactes.contactsCollectionView.visibleCells{
            if let inCell = cell as? ContactCollectionViewCell, inCell.groupId == groupId{
                inCell.setAvatar()
            }
        }
    }
    
    @IBOutlet weak var viewNotifications: NotificationsView!
    @IBOutlet weak var viewContactes: ContactesGridView!
    @IBOutlet weak var viewAllContacts: ContactesView!
    @IBOutlet weak var viewAlbums: AlbumView!
    @IBOutlet weak var viewCites: CalendariView!
    @IBOutlet weak var viewHeader: WelcomeHeaderView!
    @IBOutlet weak var viewAllGroups: GroupsView!
    @IBOutlet weak var stackContactes: UIStackView!

    lazy var dataSource = ContactsCollectionViewDataSource()
    lazy var circlesManager = CirclesManager()
    lazy var profileManager = ProfileManager()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager.shared
    lazy var profileModelManager = ProfileModelManager()
    lazy var agendaModelManager = AgendaModelManager()

    var loadingCV = false

    static var walkthroughDimColor = UIColor.black.withAlphaComponent(0.9).cgColor
    var notificationToken: NotificationToken? = nil

    var coachMarksController = CoachMarksController()

    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        DataConsumptionManager.sharedInstance.sendPendingUsages()
      
      
        if let user = profileModelManager.getUserMe(){
            _ = ProfileImageManager.sharedInstance.getProfilePicture(userId: user.id)
        }
    
        coachMarksController.dataSource = self
        coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        coachMarksController.overlay.allowTap = true

        UserDefaults.standard.set(true, forKey: "saveToCameraRoll")
        if UserDefaults.standard.bool(forKey: "saveToCameraRoll"){
            let albumSingleton = AlbumSingleton()
           albumSingleton.createAlbum()
        }
        
        configDataSources()
        addTapGestures()
        self.slideMenuController()?.addLeftGestures()

        if !profileModelManager.userIsVincle{
            viewAllGroups.isHidden = true
        }
       
        self.navigationController!.viewControllers = [self]
        if UserDefaults.standard.bool(forKey: "tutorialShown"){
            DispatchQueue.main.async {
                let delegate = UIApplication.shared.delegate as! AppDelegate
             //   if !delegate.ratingShown{
                if let url = URL(string: RATING_URL){
					DispatchQueue.main.async {
                        AppStoreRatings.shared.updateRatingStats(configURL: url) { result in
                            switch result {
                            case .success(let isDialogRequested):
                                NSLog("Finished: isDialogRequested: \(isDialogRequested)")
                                
                            case .failure(let error):
                                NSLog("error: \(error.localizedDescription)")
                                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                   
                    delegate.ratingShown = true
				}

                    
                    /*
                    AppStoreRatings.shared.debugCurrentStatus(configURL: url) { result in
                        switch result {
                            
                        case let .success(willRequestDialog, launchCountsRemaining, daysRemaining, wasPreviouslyRequested):
                            NSLog("willRequestDialog: \(willRequestDialog)")
                            NSLog("wasPreviouslyRequested: \(wasPreviouslyRequested)")
                            NSLog("launchCountsRemaining: \(launchCountsRemaining)")
                            NSLog("daysRemaining: \(String(format: "%.3f", daysRemaining))")
                            
                        case .failure(let error):
                            NSLog("error: \(error.localizedDescription)")
                        }
                    }
                    */
               // }
                
            }
        }
        
        addHelpButton()
    }
    
    
    func addHelpButton(){
        let helpButton = UIButton()

        helpButton.frame = (UIDevice.current.userInterfaceIdiom == .pad) ? CGRect(x:0, y:0, width:160, height:30) : CGRect(x:0, y:0, width:30, height:30)
        (UIDevice.current.userInterfaceIdiom == .pad) ? helpButton.setTitle(L10n.ayuda, for: .normal) : helpButton.setTitle("", for: .normal)
        helpButton.setImage(UIImage(asset: Asset.Icons.ajuda), for: .normal)
        helpButton.addTarget(self, action: #selector(showHelp), for: .touchUpInside)
        helpButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 23.0)
        helpButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    
    @objc func showHelp(){
        startInstructions()
    }
    
    func startInstructions() {
        self.coachMarksController.start(on: self)
        
        let windowz = UIApplication.shared.windows
        print("subviews",windowz)
    }
    
    func reloadStrings(){
        viewAlbums.albumLabel.text = L10n.homeFotos
        viewCites.albumLabel.text = L10n.homeCalendario
        
        let stringValue = L10n.homeAvisos
        let attrString = NSMutableAttributedString(string: stringValue)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0 // change line spacing between paragraph like 36 or 48
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: stringValue.count))
        viewNotifications.labelAvisos.attributedText = attrString

        viewAllGroups.albumLabel.text = L10n.homeVinclesGrups

        viewAllContacts.albumLabel.text = L10n.homeContactos
        if profileModelManager.userIsVincle{
            viewAllContacts.albumLabel.text = L10n.homeVinclesFamilia
        }
        
    }
    
    func reloadAgendaCounter(){
        let count = agendaModelManager.numberOfUnansweredMeetings
        if count == 0{
            viewCites.counterLabel.isHidden = true
        }
        else{
            viewCites.counterLabel.isHidden = false
            viewCites.counterLabel.text = "\(count)"
        }

    }
    func reloadNotification(){
        let notificationsModelManager = NotificationsModelManager()
        let items = notificationsModelManager.getItems()
        let count = items.filter{ $0.watched == false }.count
        if count == 0{
            viewNotifications.centerBell.isActive = true
            viewNotifications.alignLeftBell.isActive = false
            viewNotifications.notificationsBubble.isHidden = true
        }
        else{
            viewNotifications.notificationsLabel.text = "\(count)"
            viewNotifications.notificationsBubble.isHidden = false
            viewNotifications.centerBell.isActive = false
            viewNotifications.alignLeftBell.isActive = true
        }
    }
    
    func getNotifications(){
        
        let notificationsManager = NotificationManager()
        
        notificationsManager.getNotifications(onSuccess: { (hasMoreItems) in
            if hasMoreItems{
                self.getNotifications()
            }
            else{
                notificationsManager.processUnwatchedNotifications()
            }
        }) { (error) in
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileImageManager.sharedInstance.delegate = self
        GroupImageManager.sharedInstance.delegate = self

        self.setupNavigationBar(barButtons: true)
        self.viewHeader.configWithUser()
        reloadStrings()
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.notificationProcessed), name: notificationName, object: nil)
        reloadNotification()
        reloadAgendaCounter()
        
        let notificationNameCall = Notification.Name(CALL_FINISHED)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updateContactsGridNoti), name: notificationNameCall, object: nil)

        Analytics.setScreenName(ANALYTICS_HOME, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_HOME)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
        
       // UserDefaults.standard.set(false, forKey: "tutorialShown")

        if !UserDefaults.standard.bool(forKey: "tutorialShown"){
            UserDefaults.standard.set(true, forKey: "tutorialShown")
            showTutorial()
        }
      
        if !profileModelManager.userIsVincle{
            viewAllGroups.isHidden = true
        }

        getNotifications()

    }
    
    
    @objc func updateContactsGridNoti(_ notification: NSNotification){
        updateContactsGrid()
        reloadNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      //  setWalkthrough()
        
        if !loadingCV{
            loadingCV = false
            updateContactsGrid()
            
        }
        

    }

    override func viewDidDisappear(_ animated: Bool) {
       // NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
       
        if let type = notification.userInfo?["type"] as? String, (type == NOTI_NEW_MESSAGE || type == NOTI_USER_LINKED || type == NOTI_ADDED_TO_GROUP || type == NOTI_REMOVED_FROM_GROUP || type == NOTI_USER_UNLINKED || type == NOTI_USER_LEFT_CIRCLE || type == NOTI_NEW_CHAT_MESSAGE || type == NOTI_GROUP_UPDATED || type == NOTI_MEETING_INVITATION_EVENT || type == NOTI_INCOMING_CALL){
                updateContactsGrid()
        }
        else if let type = notification.userInfo?["type"] as? String, (type == NOTI_USER_UPDATED){
            if let idUser = notification.userInfo?["idUser"] as? Int{
                if circlesManager.userIsCircleOrDynamizer(id: idUser){
                    updateContactsGrid()
                }

            }
        }
        reloadNotification()
        reloadAgendaCounter()

    }
    
    override public var traitCollection: UITraitCollection {
 

        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    func setWalkthrough(){
        let descriptors = [
            TutorialItem(sourceView: (self.navigationItem.leftBarButtonItem?.customView)!, paddingX: 5, paddingY: 5, radius: 10, tutorialText: L10n.tutorialMenu, leftAlignment: true),
            TutorialItem(sourceView: (self.navigationItem.rightBarButtonItem?.customView)!, paddingX: 5, paddingY: 5, radius: 10, tutorialText: L10n.tutorialAyuda, leftAlignment: false)
        ]
        
        tutorialView?.cutHolesForViewDescriptors(descriptors)
        tutorialView?.addCloseButton()
        tutorialView?.closeButton?.addTarget(self, action: #selector(clickFinishTutorial), for: .touchUpInside)

    }
    
    func showTutorial(){
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 2;
        alertWindow.makeKeyAndVisible()
        let tutorialVC = StoryboardScene.Tutorial.tutorialViewController.instantiate()

        alertWindow.rootViewController?.present(tutorialVC, animated: true, completion: nil)
        
    }
    
    @objc func clickFinishTutorial() {
        finishTutorial()
    }
    
    func addTapGestures(){
        viewNotifications.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapNotifications)))
        viewAllContacts.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapAllContacts)))
        viewAlbums.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapAlbums)))
        viewCites.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapCites)))
        viewHeader.headerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapHeader)))
        viewAllGroups.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapAllGroups)))

    }
    
    @objc func tapNotifications() {
        let notificationsVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        baseVC.containedViewController = notificationsVC
        self.navigationController?.pushViewController(baseVC, animated: true)
     //   self.navigationController?.pushViewController(StoryboardScene.Main.homeViewController.instantiate(), animated: true)
    }
    
    @objc func tapAllContacts() {
        let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
        if profileModelManager.userIsVincle{
            contactsVC.filterContactsType = .family
        }
        else{
            contactsVC.filterContactsType = .all
        }
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        baseVC.containedViewController = contactsVC
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    @objc func tapAllGroups() {
        let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
        contactsVC.filterContactsType = .groups
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        baseVC.containedViewController = contactsVC
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    @objc func tapAlbums() {
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        baseVC.containedViewController = StoryboardScene.Gallery.galleryViewController.instantiate()
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    @objc func tapCites() {
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        baseVC.containedViewController = StoryboardScene.Agenda.agendaContainerViewController.instantiate()
        self.navigationController?.pushViewController(baseVC, animated: true)
        
    }
    
    @objc func tapHeader() {
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        baseVC.containedViewController = StoryboardScene.Configuracio.configMainViewController.instantiate()
        self.navigationController?.pushViewController(baseVC, animated: true)
        
    }
    
    func configDataSources(){
        if UIDevice.current.userInterfaceIdiom == .pad {
            dataSource.columns = 3
            dataSource.rows = 2
        }
        else{
            dataSource.columns = 2
            dataSource.rows = 2
        }
        viewContactes.contactsCollectionView.delegate = dataSource
        viewContactes.contactsCollectionView.dataSource = dataSource
        dataSource.circlesManager = CirclesGroupsModelManager.shared
        dataSource.profileModelManager = ProfileModelManager()
        dataSource.clickDelegate = self
    }
    
    func updateContactsGrid(){
        
        if profileModelManager.userIsVincle{
            if circlesGroupsModelManager.numberOfContacts + circlesGroupsModelManager.numberOfGroups + circlesGroupsModelManager.numberOfDinamizadores == 0{
                viewContactes.contactsCollectionView.isHidden = true
                viewContactes.noContactsView.isHidden = false
            }
            else{
                viewContactes.contactsCollectionView.isHidden = false
                viewContactes.noContactsView.isHidden = true
            }
            
         
        }
        else{
            if self.circlesGroupsModelManager.numberOfContacts == 0{
                viewContactes.contactsCollectionView.isHidden = true
                viewContactes.noContactsView.isHidden = false
            }
            else{
                viewContactes.contactsCollectionView.isHidden = false
                viewContactes.noContactsView.isHidden = true
            }
            
        }
        
       
        viewContactes.contactsCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews() 
        viewContactes.contactsCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HomeViewController: ContactsCollectionViewDataSourceClickDelegate{
    func selectedDinamitzador(group: Group) {
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
        baseVC.containedViewController = chatVC
        chatVC.group = group
        chatVC.isDinam = true
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    func selectedGroup(group: Group) {

        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
        baseVC.containedViewController = chatVC
        chatVC.group = group
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    func selectedContact(user: User) {
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
        baseVC.containedViewController = chatVC
        chatVC.toUserId = user.id
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    
}

extension HomeViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        var coachMark : CoachMark

        switch(index) {
        case 0:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.viewNotifications)
        case 1:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.stackContactes)
        case 2:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.viewAlbums)
        case 3:
            coachMark = coachMarksController.helper.makeCoachMark(for: self.viewCites)
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
        }
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        return coachMark

    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var bodyView : CoachMarkBodyView
        var arrowView : CoachMarkArrowView?
        let coachMarkBodyView = TransparentCoachMarkBodyView()

        switch(index) {
     
        case 0:
            coachMarkBodyView.hintLabel.text = L10n.wtHomeNotificacions
        case 1:
            coachMarkBodyView.hintLabel.text = L10n.wtHomeContactes
        case 2:
            coachMarkBodyView.hintLabel.text = L10n.wtHomeGaleria
        case 3:
            coachMarkBodyView.hintLabel.text = L10n.wtHomeCalendari
        default:
            break
        }
        
        
        
        bodyView = coachMarkBodyView
        arrowView = nil
        
        return (bodyView: bodyView, arrowView: arrowView)
     

    }

    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    
}
