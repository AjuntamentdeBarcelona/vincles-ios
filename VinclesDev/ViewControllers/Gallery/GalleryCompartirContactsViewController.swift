//
//  GalleryCompartirContactsViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Firebase


class GalleryCompartirContactsViewController: UIViewController, ProfileImageManagerDelegate, GroupImageManagerDelegate {

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelarCompartirButton: HoverButton!
    @IBOutlet weak var confirmarCompartirButton: HoverButton!
    
    var contents = [Content]()
    lazy var galleryManager = GalleryManager()
    lazy var circlesManager = CirclesManager()
    lazy var dataSource = GalleryContactsCollectionViewDataSource()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager.shared

    var contentIds = [Int]()
    let shareErrorTag = 1001
    let sharedTag = 1000
    let maxErrorTag = 1002

    var metadataTipus = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configDataSources()
        configNavigationBar()
        setStrings()
        configInitialStates()
        
        
    }
    
    
    @objc func notificationProcessed(_ notification: NSNotification){
       if let type = notification.userInfo?["type"] as? String, (type == NOTI_USER_LINKED || type == NOTI_USER_UNLINKED || type == NOTI_USER_LEFT_CIRCLE || type == NOTI_INCOMING_CALL){
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        updateContactsGrid()

        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryCompartirContactsViewController.notificationProcessed), name: notificationName, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileImageManager.sharedInstance.delegate = self
        GroupImageManager.sharedInstance.delegate = self

        Analytics.setScreenName(ANALYTICS_GALLERY_SHARE, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_GALLERY_SHARE)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func didDownload(userId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? GaleriaContactCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }
    }
    
    func didError(userId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? GaleriaContactCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }
    }
    
    func didDownload(groupId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? GaleriaContactCollectionViewCell, inCell.groupId == groupId{
                inCell.setAvatar()
            }
        }
    }
    
    func didError(groupId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? GaleriaContactCollectionViewCell, inCell.groupId == groupId{
                inCell.setAvatar()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       //  NotificationCenter.default.removeObserver(self)
        
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
    
    func setCollectionViewColumns(){
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            dataSource.columns = 4
        }
        else  if UIDevice.current.userInterfaceIdiom == .pad{
            dataSource.columns = 5
        }
        if UIDevice.current.userInterfaceIdiom == .phone && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            dataSource.columns = 2
        }
        else  if UIDevice.current.userInterfaceIdiom == .phone {
            dataSource.columns = 4
        }
    }
    
    func configInitialStates(){
        confirmarCompartirButton.alpha = 0.5
        confirmarCompartirButton.isEnabled = false
    }
    
    func setStrings(){
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
            cancelarCompartirButton.setTitle(L10n.galeriaCancelarCompartir, for: .normal)
            confirmarCompartirButton.setTitle(L10n.galeriaConfirmarCompartirUn, for: .normal)
        }
        else{
            cancelarCompartirButton.setTitle("", for: .normal)
            confirmarCompartirButton.setTitle("", for: .normal)
        }
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.leftButtonTitle = L10n.volver
            baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
            baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            
            updateCompartirTitle()
            
            baseViewController.leftAction = leftAction
            //    baseViewController.navigationBar.rightTitle = "Dreta llarg"
            //   baseViewController.navigationBar.rightImage = UIImage(asset: Asset.Icons.Navigation.tornar)
            //    baseViewController.navigationBar.rightHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            
        }
        
    }
    
    func updateCompartirTitle(){
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.navTitle = "\(L10n.galeriaCompartirContactesTitle) (\(dataSource.selectedIndexPaths.count)/\(dataSource.maxSelectItems))"
        }
    }
    
    func leftAction(_params: Any...) -> UIViewController?{
        return self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "GaleriaContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contactCell")
        setCollectionViewColumns()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource.clickDelegate = self
        dataSource.circlesGroupsModelManager = CirclesGroupsModelManager.shared
    }
    

    
    func updateContactsGrid(){
        if self.circlesGroupsModelManager.numberOfContacts == 0{
            //   viewContactes.contactsCollectionView.isHidden = true
            //   viewContactes.noContactsView.isHidden = false
        }
        else{
            //    viewContactes.contactsCollectionView.isHidden = false
            //   viewContactes.noContactsView.isHidden = true
        }
        collectionView.reloadData()
    }
    
    @IBAction func cancelarCompartirAction(_ sender: Any) {
        if let baseViewController = self.parent as? BaseViewController{
            _ = baseViewController.leftAction!()
        }
    }
    
    func share(){
        let selectedContacts = dataSource.selectedContactsForSelectedIndexPaths()
        
        galleryManager.shareContent(contentId: contentIds, contactIds: selectedContacts, metadataTipus: metadataTipus, onSuccess: {
       
            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.delegate = self
            popupVC.view.tag = self.sharedTag
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = L10n.appName
            popupVC.popupDescription = L10n.galeriaCompartido
            popupVC.button1Title = L10n.ok
            
            self.present(popupVC, animated: true, completion: nil)
        }) { (error) in
            self.showRetryPopup()
        }
    }
    @IBAction func confirmarCompartirAction(_ sender: Any) {
        share()
    }
    
    func showRetryPopup(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = shareErrorTag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        
        popupVC.popupDescription = L10n.galeriaCompartirError
     
        popupVC.button1Title = L10n.galeriaErrorSubirReintentar
        popupVC.button2Title = L10n.termsCancel
        
        self.present(popupVC, animated: true, completion: nil)
    }
}

extension GalleryCompartirContactsViewController: GalleryContactsCollectionViewDataSourceClickDelegate{
    
    func maxError() {
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = maxErrorTag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"

        popupVC.popupDescription = L10n.galeriaMaxContacts
        
        popupVC.button1Title = L10n.ok
        
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func selectedShareContacts(indexes: [Int]){
         updateCompartirTitle()
        switch indexes.count {
        case 0:
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
                confirmarCompartirButton.setTitle(L10n.galeriaConfirmarCompartirUn, for: .normal)
            }
            else{
                confirmarCompartirButton.setTitle("", for: .normal)
            }
            confirmarCompartirButton.alpha = 0.5
            confirmarCompartirButton.isEnabled = false
        case 1:
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
                confirmarCompartirButton.setTitle(L10n.galeriaConfirmarCompartirUn, for: .normal)
            }
            else{
                confirmarCompartirButton.setTitle("", for: .normal)
            }
            confirmarCompartirButton.alpha = 1
            confirmarCompartirButton.isEnabled = true
        default:
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
                confirmarCompartirButton.setTitle(L10n.galeriaConfirmarCompartirVaris, for: .normal)
            }
            else{
                confirmarCompartirButton.setTitle("", for: .normal)
            }
        }
    }
    
}

extension GalleryCompartirContactsViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        if popup.view.tag == sharedTag{
            self.navigationController?.popViewController(animated: true)
            popup.dismissPopup {
            }
            
        }
        else if popup.view.tag == shareErrorTag{
            popup.dismissPopup {
                self.share()
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


