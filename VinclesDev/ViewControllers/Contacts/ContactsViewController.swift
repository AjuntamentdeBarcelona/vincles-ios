//
//  ContactsViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Popover
import Firebase

class ContactsViewController: UIViewController, ProfileImageManagerDelegate, GroupImageManagerDelegate {
  

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filtrarButton: HoverButton!
    @IBOutlet weak var eliminarButton: HoverButton!
    @IBOutlet weak var afegirButton: HoverButton!
    @IBOutlet weak var cancelarButton: HoverButton!
    @IBOutlet weak var optionsStack: UIStackView!
    @IBOutlet weak var noContactsLabel: UILabel!

    var tableView: UITableView?
    var selectedUser: User?

    lazy var dataSource = ContactsGroupsDataSource()
    lazy var circlesManager = CirclesManager()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager.shared
    lazy var profileModelManager = ProfileModelManager()

    fileprivate var popover: Popover!
    fileprivate var texts = [L10n.contactsFilterVerTodos, L10n.contactsVerFamilia, L10n.contactsFilterVerGrupos, L10n.contactsFilterVerDinamizadores]
    
    var showBackButton = true

    var filterContactsType = FilterContactsType.all
    
    var popupVC: PopupViewController!
    var loadingCV = false
    var screenRotated = false

    var openHomeOnBack = false

    var coachMarksController = CoachMarksController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationNameCall = Notification.Name(CALL_FINISHED)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.updateContactsGridNoti), name: notificationNameCall, object: nil)

        coachMarksController.dataSource = self
        coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        coachMarksController.overlay.allowTap = true
        
        configDataSources()
        configNavigationBar()
        setStrings()
        setInitialState()
        setUI()
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
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        }
    }
    
    @objc func showHelp(){
        startInstructions()
    }
    
    func startInstructions() {
        self.coachMarksController.start(on: self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
       
        updateContactsGrid()

        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsViewController.notificationProcessed), name: notificationName, object: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
       //  NotificationCenter.default.removeObserver(self)
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileImageManager.sharedInstance.delegate = self
        GroupImageManager.sharedInstance.delegate = self

        Analytics.setScreenName(ANALYTICS_CONTACTS, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_CONTACTS)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    func didDownload(userId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? ContactItemCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }

    }
    
    func didError(userId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? ContactItemCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }
    }
    
    func didDownload(groupId: Int) {
        
        for cell in collectionView.visibleCells{
            if let inCell = cell as? ContactItemCollectionViewCell, inCell.groupId == groupId{
                inCell.setAvatar()
            }
        }
        
    }
    
    func didError(groupId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? ContactItemCollectionViewCell, inCell.groupId == groupId{
                inCell.setAvatar()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setCollectionViewLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setStrings()
    }
    
    
  
    @objc func updateContactsGridNoti(_ notification: NSNotification){
        updateContactsGrid()
    }
    
    func setCollectionViewLayout(){
        setCollectionViewColumns()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
      //   NotificationCenter.default.removeObserver(self)
    }
    @objc func rotated() {
        if popover != nil{
            if popover.frame.width != 0.0{
                screenRotated = true
                popover.dismiss()
            }
        }
 
        
    }
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "ContactItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contactCell")
        setCollectionViewColumns()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource.clickDelegate = self
        dataSource.contactsFilter = filterContactsType
        dataSource.circlesGroupsModelManager = CirclesGroupsModelManager.shared
        dataSource.profileModelManager = ProfileModelManager()


    }
    
    func setCollectionViewColumns(){
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            dataSource.columns = 3
        }
        else  if UIDevice.current.userInterfaceIdiom == .pad {
            dataSource.columns = 4
        }
        else if UIDevice.current.userInterfaceIdiom == .phone && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            dataSource.columns = 2
        }
        else  if UIDevice.current.userInterfaceIdiom == .phone{
            dataSource.columns = 3
        }
    }

   
    
    func setInitialState(){
        noContactsLabel.isHidden = true

        cancelarButton.isHidden = true
        noContactsLabel.text = L10n.homeNoContacts

        if !profileModelManager.userIsVincle{
            filtrarButton.isHidden = true
        }
        
        if filterContactsType == .all || filterContactsType == .family {
            eliminarButton.isEnabled = true
            eliminarButton.alpha = 1
        }
        else{
            eliminarButton.isEnabled = false
            eliminarButton.alpha = 0.5
        }
        
        setTitleForFilter()
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }

            baseViewController.navTitle = L10n.contactos
            baseViewController.leftAction = leftAction
            
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
    
    func setStrings(){
        cancelarButton.setTitle(L10n.contactsCancelar, for: .normal)

        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
            filtrarButton.setTitle(L10n.galeriaFiltrar, for: .normal)
            eliminarButton.setTitle(L10n.contacteEliminar, for: .normal)
            afegirButton.setTitle(L10n.contactsAfegirContacte, for: .normal)
        }
        else{
            filtrarButton.setTitle("", for: .normal)
            eliminarButton.setTitle("", for: .normal)
            afegirButton.setTitle("", for: .normal)

        }
    }
    
    func setUI(){
        if UIDevice.current.userInterfaceIdiom == .phone{
           
            cancelarButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
         
            
        }
        
    }
    
    func setTitleForFilter(){
        if let baseViewController = self.parent as? BaseViewController{
            if profileModelManager.userIsVincle{
                switch filterContactsType{
                case .all:
                    baseViewController.navTitle = L10n.contactsFiltradoTodos
                case .dinams:
                    baseViewController.navTitle = L10n.contactsFiltradoDinamizadores
                case .family:
                    baseViewController.navTitle = L10n.contactsFiltradoFamilia
                case .groups:
                    baseViewController.navTitle = L10n.contactsFiltradoGrupos
                }
            }
            
        }
        
        
    }
    
    func configPopover(){
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .showBlackOverlay(false)
        ]
        
        
        if UIDevice.current.userInterfaceIdiom == .phone && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: 180))
        }
        else{
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 180))
        }
     
    
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.isScrollEnabled = false
        tableView!.clipsToBounds = true
        tableView!.backgroundColor = .clear
        self.popover = Popover(options: popoverOptions, showHandler: {
            
            
        }, dismissHandler: {
            if self.screenRotated{
                self.screenRotated = false
                self.configPopover()
            }
        })
        
        self.popover.layer.shadowOpacity = 0.5
        self.popover.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.popover.layer.shadowRadius = 2
        
        tableView!.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView!.frame.size.width, height: 1))
        
        self.popover.show(tableView!, fromView: self.filtrarButton)

    }
    
    func updateContactsGrid(){
        
        
            switch filterContactsType {
            case .all:
                if profileModelManager.userIsVincle{
                    if circlesGroupsModelManager.numberOfContacts + circlesGroupsModelManager.numberOfGroups + circlesGroupsModelManager.numberOfDinamizadores == 0{
                        noContactsLabel.isHidden = false
                        collectionView.isHidden = true
                        noContactsLabel.text = L10n.homeNoContacts

                    }
                    else{
                        noContactsLabel.isHidden = true
                        collectionView.isHidden = false
                    }
                }
                else{
                    if circlesGroupsModelManager.numberOfContacts == 0{
                        noContactsLabel.isHidden = false
                        collectionView.isHidden = true
                    }
                    else{
                        noContactsLabel.isHidden = true
                        collectionView.isHidden = false
                    }
                }
            case .family:
                noContactsLabel.text = L10n.homeNoContacts

                if circlesGroupsModelManager.numberOfContacts == 0{
                    noContactsLabel.isHidden = false
                    collectionView.isHidden = true
                }
                else{
                    noContactsLabel.isHidden = true
                    collectionView.isHidden = false
                }
            case .groups:
                noContactsLabel.text = L10n.homeNoGroups

                if circlesGroupsModelManager.numberOfGroups == 0{
                    noContactsLabel.isHidden = false
                    collectionView.isHidden = true
                }
                else{
                    noContactsLabel.isHidden = true
                    collectionView.isHidden = false
                }
            case .dinams:
                noContactsLabel.text = L10n.homeNoContacts

                if circlesGroupsModelManager.numberOfDinamizadores == 0{
                    noContactsLabel.isHidden = false
                    collectionView.isHidden = true
                }
                else{
                    noContactsLabel.isHidden = true
                    collectionView.isHidden = false
                }
            }
        
        
        
       
        dataSource.contactsFilter = filterContactsType
        setTitleForFilter()
        collectionView.reloadData()
    }
    
    @IBAction func eliminarAction(_ sender: Any) {
        dataSource.editMode =  true
        updateContactsGrid()
        cancelarButton.isHidden = false
        optionsStack.isHidden = true
     //   showRemovePopup()
    }
    
   
    
    @IBAction func filtrarAction(_ sender: Any) {
        configPopover()

    }
    
    @IBAction func addContact(_ sender: Any) {
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Contacts.addContactViewController.instantiate()
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
        
    }
    
    @IBAction func cancelar(_ sender: Any) {
        dataSource.editMode =  false
        updateContactsGrid()
        cancelarButton.isHidden = true
        optionsStack.isHidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        filterContactsType = FilterContactsType(rawValue: indexPath.row)!
        updateContactsGrid()
        
        
        if filterContactsType == .all || filterContactsType == .family {
            eliminarButton.isEnabled = true
            eliminarButton.alpha = 1
        }
        else{
            eliminarButton.isEnabled = false
            eliminarButton.alpha = 0.5
        }
        
        self.popover.dismiss()
    }
}

extension ContactsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = UIColor(named: .grayChatSent)
        cell.textLabel?.font = UIFont(font: FontFamily.AkkuratLight.light, size: 16.0)
        cell.tintColor = UIColor(named: .darkRed)
        if indexPath.row == filterContactsType.rawValue{
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor(named: .darkRed)
        }
        return cell
    }
}

extension ContactsViewController: ContactsGroupsDataSourceClickDelegate{
 

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
    
    func showRemovePopup(item: Any) {
    
        
        popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.eliminarPopupTitle
        if let userItem = item as? User{
            popupVC.popupDescription = "\(L10n.eliminarPopupDesc1)\(userItem.name)\(L10n.eliminarPopupDesc2)"
            selectedUser = userItem
        }
       
        
        popupVC.button1Title = L10n.eliminarPopupButton1
        popupVC.button2Title = L10n.eliminarPopupButton2
      
        self.present(popupVC, animated: true, completion: nil)
        
    }
    
    
}

extension ContactsViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        if let user = selectedUser{

            let profileModelManager = ProfileModelManager()
            if profileModelManager.userIsVincle{
                circlesManager.removeContact(contactId: user.id, onSuccess: {
                    popup.dismissPopup {
                    }
                    self.updateContactsGrid()
                }, onError: { (error) in
                    self.popupVC.titleLabel.text = L10n.eliminarPopupTitleReintentar
                    popup.dismissPopup {
                        
                    }
                })

            }
            else{
                circlesManager.removeContactFromVinculat(idCircle: user.idCircle, onSuccess: {
                    popup.dismissPopup {
                    }
                    self.updateContactsGrid()
                }, onError: { (error) in
                    self.popupVC.titleLabel.text = L10n.eliminarPopupTitleReintentar
                    popup.dismissPopup {
                        
                    }
                })
            }
        
        }
    }
    func closeButtonClicked(popup: PopupViewController) {
        
    }
}

extension ContactsViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        var coachMark : CoachMark
        if cancelarButton.isHidden{
            if !profileModelManager.userIsVincle{
                switch(index) {
                case 0:
                    coachMark = coachMarksController.helper.makeCoachMark(for: afegirButton)
                case 1:
                    coachMark = coachMarksController.helper.makeCoachMark(for: eliminarButton)
                    
                default:
                    coachMark = coachMarksController.helper.makeCoachMark()
                }
            }
            else{
                switch(index) {
                case 0:
                    coachMark = coachMarksController.helper.makeCoachMark(for: filtrarButton)
                case 1:
                    coachMark = coachMarksController.helper.makeCoachMark(for: afegirButton)
                case 2:
                    coachMark = coachMarksController.helper.makeCoachMark(for: eliminarButton)
                    
                default:
                    coachMark = coachMarksController.helper.makeCoachMark()
                }
            }
            
        }
        else{
            coachMark = coachMarksController.helper.makeCoachMark(for: cancelarButton)

        }
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0

        return coachMark
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var bodyView : CoachMarkBodyView
        var arrowView : CoachMarkArrowView?
        let coachMarkBodyView = TransparentCoachMarkBodyView()
        
        
        if cancelarButton.isHidden{
            if !profileModelManager.userIsVincle{
                switch(index) {
                case 0:
                    coachMarkBodyView.hintLabel.text = L10n.wtContactesAfegir
                case 1:
                    coachMarkBodyView.hintLabel.text = L10n.wtContactesEliminar
                    
                default:
                    break
                }
            }
            else{
                switch(index) {
                    
                case 0:
                    coachMarkBodyView.hintLabel.text = L10n.wtContactesFiltrar
                case 1:
                    coachMarkBodyView.hintLabel.text = L10n.wtContactesAfegir
                case 2:
                    coachMarkBodyView.hintLabel.text = L10n.wtContactesEliminar
                    
                default:
                    break
                }
            }
           
        }
        else{
            coachMarkBodyView.hintLabel.text = L10n.wtContactesEliminarBoto
        }
        
        
        bodyView = coachMarkBodyView
        arrowView = nil
        
        return (bodyView: bodyView, arrowView: arrowView)
        
        
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if cancelarButton.isHidden{
            if !profileModelManager.userIsVincle{
                return 2
            }
            return 3
        }
        else{
            return 1
        }
    }
    
    
}



