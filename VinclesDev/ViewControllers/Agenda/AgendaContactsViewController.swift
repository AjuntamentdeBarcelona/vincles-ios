//
//  AgendaContactsViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol AgendaContactsViewControllerDelegate{
    func selectedContacts(users: [User])
}

class AgendaContactsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelarCompartirButton: HoverButton!
    @IBOutlet weak var confirmarCompartirButton: HoverButton!
    
    lazy var circlesManager = CirclesManager()
    lazy var dataSource = AgendaContactsDataSource()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager()
    
    var delegate: AgendaContactsViewControllerDelegate?
    var selectedUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configDataSources()
        configNavigationBar()
        setStrings()
        configInitialStates()
        
        
    }
    
    
    @objc func notificationProcessed(_ notification: NSNotification){

        if let type = notification.userInfo?["type"] as? String, (type == NOTI_USER_LINKED || type == NOTI_USER_UNLINKED || type == NOTI_USER_LEFT_CIRCLE){
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
        NotificationCenter.default.addObserver(self, selector: #selector(AgendaContactsViewController.notificationProcessed), name: notificationName, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      //   NotificationCenter.default.removeObserver(self)
        
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
            cancelarCompartirButton.setTitle(L10n.convidarCitaCancelar, for: .normal)
            confirmarCompartirButton.setTitle(L10n.convidarCitaAcceptar, for: .normal)
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
            
            baseViewController.navTitle = L10n.convidarCitaContactes
            
            baseViewController.leftAction = leftAction
            //    baseViewController.navigationBar.rightTitle = "Dreta llarg"
            //   baseViewController.navigationBar.rightImage = UIImage(asset: Asset.Icons.Navigation.tornar)
            //    baseViewController.navigationBar.rightHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            
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
        dataSource.selectedUsers = selectedUsers
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource.clickDelegate = self
        dataSource.circlesGroupsModelManager = CirclesGroupsModelManager()
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
        selectedUsers.removeAll()
        delegate?.selectedContacts(users: selectedUsers)

        if let baseViewController = self.parent as? BaseViewController{
            _ = baseViewController.leftAction!()
        }
    }
    
    @IBAction func confirmarCompartirAction(_ sender: Any) {
        let selectedContacts = dataSource.selectedUsers
        delegate?.selectedContacts(users: selectedContacts)
        self.navigationController?.popViewController(animated: true)
       
    }
}

extension AgendaContactsViewController: AgendaContactsDataSourceClickDelegate{
    
    func selectedShareContacts(users: [User]){
        selectedUsers = users
        switch users.count {
        case 0:
            confirmarCompartirButton.alpha = 0.5
            confirmarCompartirButton.isEnabled = false
        default:
            confirmarCompartirButton.alpha = 1
            confirmarCompartirButton.isEnabled = true
        }
    }
    
}

extension AgendaContactsViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        self.navigationController?.popViewController(animated: true)
        popup.dismissPopup {
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        
    }
    
}


