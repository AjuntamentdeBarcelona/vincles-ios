//
//  GroupInfoViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

import Popover

class GroupInfoViewController: UIViewController {
    
    var group: Group?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var descLabel: UILabel!

    
    var tableView: UITableView?
    var selectedUser: User?
    
    lazy var dataSource = GroupUsersDataSource()
    lazy var circlesManager = CirclesManager()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager()
    lazy var profileModelManager = ProfileModelManager()
    
    var showBackButton = true
    
    var popupVC: PopupViewController!
    var loadingCV = false
    var screenRotated = false
    
    var openHomeOnBack = false
    
    lazy var notificationManager = NotificationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configDataSources()
        configNavigationBar()
        setStrings()
        setInitialState()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        updateContactsGrid()
        
     
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(GroupInfoViewController.notificationProcessed), name: notificationName, object: nil)
        
        getNotifications()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_GROUP_INFO)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      //   NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
        
        if let type = notification.userInfo?["type"] as? String, (type == NOTI_REMOVED_USER_GROUP || type == NOTI_NEW_USER_GROUP){
            if let idGroup = notification.userInfo?["idGroup"] as? Int, idGroup == group?.id{
                updateContactsGrid()
            }
            
        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_USER_UPDATED,  let idUser = notification.userInfo?["idUser"] as? Int, let users = group?.users{
            for user in users{
                if idUser == user.id{
                    updateContactsGrid()
                }
            }
            
        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_GROUP_UPDATED,  let idGroup = notification.userInfo?["idGroup"] as? Int, group !=  nil, idGroup == group!.id{
            if let baseViewController = self.parent as? BaseViewController{
                
                if let central = baseViewController.customCentralView as? GalleryDetailUserHeader{
                    central.configWithGroup(group: group!)
                }
            }
            setInitialState()
            
        }
        
    }
    
    func getNotifications(){
        
        notificationManager.getNotifications(onSuccess: { (hasMoreItems) in
            if hasMoreItems{
                self.getNotifications()
            }
            else{
                self.notificationManager.processUnwatchedNotifications()
            }
        }) { (error) in
            
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
    
    
    
    
    func setCollectionViewLayout(){
        setCollectionViewColumns()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
      //   NotificationCenter.default.removeObserver(self)
    }
   
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "GroupParticipantCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contactCell")
        setCollectionViewColumns()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource.clickDelegate = self
        dataSource.group = group
        dataSource.circlesGroupsModelManager = CirclesGroupsModelManager()
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
        descLabel.text = group!.descript
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
            
            baseViewController.leftAction = leftAction
            
            let headerView = GalleryDetailUserHeader(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            
            baseViewController.customCentralView = headerView
            headerView.configWithGroup(group: group!)
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
      
    }
    
    func setUI(){
        descLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 18.0)

        descLabel.numberOfLines = 0
        if UIDevice.current.userInterfaceIdiom == .phone {
            descLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)

        }
    }
    

   
    
    func updateContactsGrid(){
        collectionView.reloadData()
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension GroupInfoViewController: GroupUsersDataSourceClickDelegate{

    func selectedContact(user: User) {
      
        let circlesManager = CirclesManager()
        circlesManager.inviteUserFromGroup(groupId: group!.id, userId: user.id, onSuccess: {
            self.popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            self.popupVC.delegate = self
            self.popupVC.modalPresentationStyle = .overCurrentContext
            self.popupVC.popupTitle = L10n.afegirContacteTitol
            self.popupVC.popupDescription = L10n.afegirContacteDesc
            
            
            self.popupVC.button1Title = L10n.ok
            
            self.present(self.popupVC, animated: true, completion: nil)
        }) { (error) in
            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = "Error"
            popupVC.popupDescription = error
            popupVC.button1Title = L10n.ok
            
            self.present(popupVC, animated: true, completion: nil)
        }
       
        
    }

}

extension GroupInfoViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {

    }
    
}

