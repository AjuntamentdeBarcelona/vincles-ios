//
//  GalleryViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Popover
import MobileCoreServices
import RealmSwift
import AVFoundation
import Firebase

class GalleryViewController: UIViewController, ContentManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filtrarButton: HoverButton!
    @IBOutlet weak var compartirButton: HoverButton!
    @IBOutlet weak var nuevaFotoButton: HoverButton!
    @IBOutlet weak var nuevoVideoButton: HoverButton!
    @IBOutlet weak var cancelarCompartirButton: HoverButton!
    @IBOutlet weak var confirmarCompartirButton: HoverButton!
    @IBOutlet weak var eliminarButton: HoverButton!
    @IBOutlet weak var seleccionarTodoButton: HoverButton!
    @IBOutlet weak var noContentLabel: UILabel!

    var tableView: UITableView?
    var tableViewSelect: UITableView?

    lazy var picker = UIImagePickerController()
    
    lazy var galleryManager = GalleryManager()
    lazy var dataSource = GalleryCollectionViewDataSource()
    lazy var galleryModelManager = GalleryModelManager()
    lazy var notificationsManager = NotificationManager()
    var exportSession: AVAssetExportSession?

    fileprivate var popover: Popover!
    fileprivate var popoverSelect: Popover!

    fileprivate var texts = [L10n.galeriaVerTodos, L10n.galeriaVerMios, L10n.galeriaVerRecibidos]
    fileprivate var textsSelect = [L10n.galeriaOptionCompartir, L10n.galeriaOptionBorrar]

    var showBackButton = true

    var filterGalleryType = FilterContentType.all
    var loadingCV = false
    
    var notificationToken: NotificationToken? = nil

    var screenRotated = false
   
    let deleteTag = 1001
    let uploadPhotoTag = 1002
    let uploadVideoTag = 1003
    let deleteErrorTag = 1004
    let errorSpace = 1005
    let errorPermission = 1006
    let errorMaxItems = 1007

    var coachMarksController = CoachMarksController()

    override func viewDidLoad() {
        super.viewDidLoad()
        noContentLabel.isHidden = true
        seleccionarTodoButton.setTitle(L10n.galeriaSeleccionarTodo, for: .normal)

        print("errorIDs \(ContentManager.sharedInstance.errorIds)")
        coachMarksController.dataSource = self
        coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        coachMarksController.overlay.allowTap = true
        seleccionarTodoButton.isHidden = true
        
        getNotifications()

        configDataSources()
        configNavigationBar()
        setStrings()
        initPicker()
        addDelegates()
        configInitialStates()
        loadingCV = true
     
        addHelpButton()
        
       //  Timer.every(3.seconds) {
          //  print("downloadingIds \(ContentManager.sharedInstance.downloadingIds)" )
      //   }
        
        if self.dataSource.getNumberOfItems() == 0{
            noContentLabel.isHidden = false
        }
        else{
            noContentLabel.isHidden = true
            
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        ContentManager.sharedInstance.delegate = self
        
        Analytics.setScreenName(ANALYTICS_GALLERY, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_GALLERY)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    override func viewWillDisappear(_ animated: Bool) {
       //  NotificationCenter.default.removeObserver(self)
    }
    @objc func rotated() {
        if popover != nil{
            if popover.frame.width != 0.0{
                screenRotated = true
                popover.dismiss()
            }
        }
        if popoverSelect != nil{
            if popoverSelect.frame.width != 0.0{
                screenRotated = true
                popoverSelect.dismiss()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !loadingCV{
            setNoCompartir()
            updateGalleryGrid()
        }
       
        loadingCV = false
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.notificationProcessed), name: notificationName, object: nil)

        let notificationNameCallFinish = Notification.Name(NOTI_FINISH_CALL)
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.callFinish), name: notificationNameCallFinish, object: nil)
        

    }
    
    func didDownload(contentId: Int) {

        DispatchQueue.main.async {
            for cell in self.collectionView.visibleCells{
                
                if let galleryCell = cell as? GaleriaItemCollectionViewCell, galleryCell.contentId == contentId{
                    
                    var selected = false
                    if let indexPath = self.collectionView.indexPath(for: cell){
                        
                        if self.dataSource.selectedIndexPaths.contains(indexPath.row){
                            selected = true
                        }
                    }

                    galleryCell.setImageWith(contentId: contentId, selectionMode: self.dataSource.selectionMode, selected: selected, isVideo: galleryCell.isVideo)
                }
            }
            
        }
    }
    
    func didError(contentId: Int) {
        DispatchQueue.main.async {
            
            for cell in self.collectionView.visibleCells{
                if let galleryCell = cell as? GaleriaItemCollectionViewCell, galleryCell.contentId == contentId{
                    galleryCell.setError()
                }
            }
            
        }
    }
    
    func didCorrupted(contentId: Int) {
        DispatchQueue.main.async {
            
            
            for cell in self.collectionView.visibleCells{
                if let galleryCell = cell as? GaleriaItemCollectionViewCell, galleryCell.contentId == contentId{
                    galleryCell.setVideoCorrupted()
                }
            }
        }
    }
   
    
    
    @objc func callFinish(){
        self.updateGalleryGrid()
    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
        if let type = notification.userInfo?["type"] as? String, type == NOTI_NEW_PHOTO_CHAT{
            updateGalleryGrid()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
        setCollectionViewLayout()
    }
    
    override public var traitCollection: UITraitCollection {
        
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
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
        else  if UIDevice.current.userInterfaceIdiom == .pad  {
            dataSource.columns = 5
        }
        else if UIDevice.current.userInterfaceIdiom == .phone && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            dataSource.columns = 2
        }
        else  if UIDevice.current.userInterfaceIdiom == .phone && UIApplication.shared.statusBarOrientation.isLandscape  {
            dataSource.columns = 4
        }
    }
    
    func addDelegates(){
        picker.delegate = self
    }
    
    func initPicker(){
        self.picker.allowsEditing = false
    }
    
    func configInitialStates(){
        confirmarCompartirButton.alpha = 0.5
        confirmarCompartirButton.isEnabled = false
        eliminarButton.alpha = 0.5
        eliminarButton.isEnabled = false
    }
    
    func setStrings(){
        noContentLabel.text = L10n.galeriaVacia
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
            filtrarButton.setTitle(L10n.galeriaFiltrar, for: .normal)
            compartirButton.setTitle(L10n.galeriaSeleccionar, for: .normal)
            nuevoVideoButton.setTitle(L10n.galeriaNuevoVideo, for: .normal)
            nuevaFotoButton.setTitle(L10n.galeriaNuevaFoto, for: .normal)
            cancelarCompartirButton.setTitle(L10n.galeriaCancelarCompartir, for: .normal)
            confirmarCompartirButton.setTitle(L10n.galeriaConfirmarCompartirUn, for: .normal)
            eliminarButton.setTitle(L10n.galeriaEliminar, for: .normal)
            
        }
        else{
            filtrarButton.setTitle("", for: .normal)
            compartirButton.setTitle("", for: .normal)
            nuevoVideoButton.setTitle("", for: .normal)
            nuevaFotoButton.setTitle("", for: .normal)
            cancelarCompartirButton.setTitle("", for: .normal)
            confirmarCompartirButton.setTitle("", for: .normal)
            eliminarButton.setTitle("", for: .normal)

        }
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
         
           setTitleForFilter()
            baseViewController.leftAction = leftAction
      
        }
    }
    
    func setTitleForFilter(){
        if let baseViewController = self.parent as? BaseViewController{
       
            switch filterGalleryType{
            case .all:
                baseViewController.navTitle = L10n.galeriaTodos
            case .mine:
                baseViewController.navTitle = L10n.galeriaMios
            case .sent:
                baseViewController.navTitle = L10n.galeriaCompartidos
                
            }
           
        }
    }
    
    func configPopover(){
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .showBlackOverlay(false)
        ]
        
        if UIDevice.current.userInterfaceIdiom == .phone && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: 135))
        }
        else{
            tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 135))
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
    
    func leftAction(_params: Any...) -> UIViewController?{
        return self.navigationController?.popViewController(animated: true)
    }
    
  
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "GaleriaItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "galleryCell")
        collectionView.register(UINib(nibName: "GaleriaLoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "loadingCell")

        setCollectionViewColumns()
        dataSource.galleryManager = galleryManager
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource.clickDelegate = self
        dataSource.galleryFilter = .all
        dataSource.galleryModelManager = GalleryModelManager()
    }
    
    
    func updateGalleryGrid(){
        print(self.dataSource.getNumberOfItems())
        if self.dataSource.getNumberOfItems() == 0{
            noContentLabel.isHidden = false
        }
        else{
            noContentLabel.isHidden = true

        }
        collectionView.reloadData()
    }
    
    @IBAction func seleccionarTodo(_ sender: Any) {
        if seleccionarTodoButton.currentTitle == L10n.galeriaSeleccionarTodo{
            seleccionarTodoButton.setTitle(L10n.galeriaDeseleccionarTodo, for: .normal)
            self.dataSource.selectAll()
            self.updateGalleryGrid()

        }
        else{
            seleccionarTodoButton.setTitle(L10n.galeriaSeleccionarTodo, for: .normal)
            self.dataSource.selectedIndexPaths = [Int]()
            self.updateGalleryGrid()
        }
        
         selectedShareFiles(indexes: dataSource.selectedIndexPaths)

    }
    
    @IBAction func filtrarAction(_ sender: Any) {
        configPopover()
    }
    
    func updateCompartirTitle(){
        if let baseViewController = self.parent as? BaseViewController{
            if eliminarButton.isHidden{
                baseViewController.navTitle = "\(L10n.galeriaCompartirTitle) (\(dataSource.selectedIndexPaths.count)/\(dataSource.maxSelectItems))"
            }
            else{
                baseViewController.navTitle = "\(L10n.galeriaCompartirTitle)"
            }
        }
    }
    
    func configPopoverSelect(){
        
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .showBlackOverlay(false)
        ]
        
        if UIDevice.current.userInterfaceIdiom == .phone && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            tableViewSelect = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: 90))
        }
        else{
            tableViewSelect = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: 90))
        }
        
        
        tableViewSelect!.delegate = self
        tableViewSelect!.dataSource = self
        tableViewSelect!.isScrollEnabled = false
        tableViewSelect!.clipsToBounds = true
        tableViewSelect!.backgroundColor = .clear
        self.popoverSelect = Popover(options: popoverOptions, showHandler: {
            
            
        }, dismissHandler: {
            if self.screenRotated{
                print("SCREEN ROTATED")
                self.screenRotated = false
                self.configPopoverSelect()
                
            }
        })
        
        self.popoverSelect.layer.shadowOpacity = 0.5
        self.popoverSelect.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.popoverSelect.layer.shadowRadius = 2
        tableViewSelect!.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableViewSelect!.frame.size.width, height: 1))
        
        self.popoverSelect.show(tableViewSelect!, fromView: self.compartirButton)
    }
    
    @IBAction func compartirAction(_ sender: Any) {
      
        configPopoverSelect()
        
        /*
       updateCompartirTitle()
        
        filtrarButton.isHidden = true
        compartirButton.isHidden = true
        nuevoVideoButton.isHidden = true
        nuevaFotoButton.isHidden = true
        cancelarCompartirButton.isHidden = false
        confirmarCompartirButton.isHidden = false
        eliminarButton.isHidden = false
        dataSource.selectionMode = true
        collectionView.reloadData()
 */
    }
    
    @IBAction func newPhotoAction(_ sender: Any) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            self.newPhoto()

        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.newPhoto()
                    }
                } else {
                    DispatchQueue.main.async {
                       self.errorPopupPhoto()
                    }
                  
                }
            })
        }
        
     
    }
    
    func newPhoto(){
        self.picker.sourceType = .camera
        self.picker.mediaTypes = [kUTTypeImage as String]
        self.present(self.picker, animated: true, completion: nil)
    }
    
    func errorPopupPhoto(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.permisCamera
        popupVC.button1Title = L10n.permisosAnarConfiguracio
        popupVC.button2Title = L10n.cancelar
        
        popupVC.view.tag = self.errorPermission
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func errorPopupMax(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.galeriaMaxItems
        popupVC.button1Title = L10n.ok
        
        popupVC.view.tag = self.errorMaxItems
        self.present(popupVC, animated: true, completion: nil)
    }
    
    
    @IBAction func newVideoAction(_ sender: Any) {
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized && AVCaptureDevice.authorizationStatus(for: .audio) ==  .authorized {
            newVideo()
        } else {
            
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
                    if granted {
                        DispatchQueue.main.async {
                            self.newVideo()
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
                            self.newVideo()
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
                                    self.newVideo()
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
    
    func newVideo(){
        let storageManager = StorageManager()
        
        
        if !storageManager.availableSpaceForVideo(){
            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = "Error"
            popupVC.popupDescription = L10n.errorEspai
            popupVC.button1Title = L10n.ok
            popupVC.view.tag = self.errorSpace
            self.present(popupVC, animated: true, completion: nil)
            return
        }
        self.picker.videoMaximumDuration = TimeInterval(VIDEO_MAX_SECONDS)
        self.picker.sourceType = .camera
        self.picker.mediaTypes = [kUTTypeMovie as String]
        self.present(self.picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelarCompartirAction(_ sender: Any) {
        self.setNoCompartir()
        self.updateGalleryGrid()
    }
    
    func setNoCompartir(){
        filtrarButton.isHidden = false
        compartirButton.isHidden = false
        nuevoVideoButton.isHidden = false
        nuevaFotoButton.isHidden = false
        cancelarCompartirButton.isHidden = true
        confirmarCompartirButton.isHidden = true
        eliminarButton.isHidden = true
        dataSource.selectionMode = false
        dataSource.deleteMode = false
        seleccionarTodoButton.setTitle(L10n.galeriaSeleccionarTodo, for: .normal)
        dataSource.selectAllMode = false
        seleccionarTodoButton.isHidden = true

        dataSource.selectedIndexPaths = [Int]()
        selectedShareFiles(indexes: dataSource.selectedIndexPaths)
        setTitleForFilter()

    }
    
    @IBAction func confirmarCompartirAction(_ sender: Any) {
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Gallery.galleryCompartirContactsViewController.instantiate()
        let (contentIds, metadataTipus) = dataSource.selectedItemsForSelectedIndexPaths()
        detailVC.contentIds = contentIds
        detailVC.metadataTipus = metadataTipus

        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
        
    }
    
    @IBAction func eliminarAction(_ sender: Any) {

        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = deleteTag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.galeriaEliminar
        popupVC.popupDescription = L10n.galeriaEliminarTitle
        popupVC.button1Title = L10n.termsAccept
        popupVC.button2Title = L10n.termsCancel
        
        self.present(popupVC, animated: true, completion: nil)

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension GalleryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == tableViewSelect{
            if indexPath.row == 0{
                
                filtrarButton.isHidden = true
                compartirButton.isHidden = true
                nuevoVideoButton.isHidden = true
                nuevaFotoButton.isHidden = true
                cancelarCompartirButton.isHidden = false
                confirmarCompartirButton.isHidden = false
                eliminarButton.isHidden = true
                dataSource.selectionMode = true
                dataSource.deleteMode = false
                seleccionarTodoButton.setTitle(L10n.galeriaSeleccionarTodo, for: .normal)
                dataSource.selectAllMode = false
                self.updateGalleryGrid()
                self.popoverSelect.dismiss()
                seleccionarTodoButton.isHidden = true
                updateCompartirTitle()

            }
            else{
                
                filtrarButton.isHidden = true
                compartirButton.isHidden = true
                nuevoVideoButton.isHidden = true
                nuevaFotoButton.isHidden = true
                cancelarCompartirButton.isHidden = false
                confirmarCompartirButton.isHidden = true
                eliminarButton.isHidden = false
                dataSource.selectionMode = true
                dataSource.deleteMode = true
                seleccionarTodoButton.setTitle(L10n.galeriaSeleccionarTodo, for: .normal)
                dataSource.selectAllMode = false
                self.updateGalleryGrid()
                self.popoverSelect.dismiss()
                seleccionarTodoButton.isHidden = false
                updateCompartirTitle()

            }
            return
        }
        filterGalleryType = FilterContentType(rawValue: indexPath.row)!
        dataSource.galleryFilter = filterGalleryType
        updateGalleryGrid()
        tableView.reloadData()
        self.popover.dismiss()
        setTitleForFilter()
    }
}

extension GalleryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView == self.tableViewSelect{
            return textsSelect.count
        }
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if tableView == self.tableViewSelect{
            cell.textLabel?.text = self.textsSelect[(indexPath as NSIndexPath).row]
        }
        else{
            cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]

        }
        cell.textLabel?.textColor = UIColor(named: .grayChatSent)
        cell.textLabel?.font = UIFont(font: FontFamily.AkkuratLight.light, size: 16.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.tintColor = UIColor(named: .darkRed)
        if tableView == self.tableViewSelect{

        }
        else{
            if indexPath.row == filterGalleryType.rawValue{
                cell.accessoryType = .checkmark
                cell.textLabel?.textColor = UIColor(named: .darkRed)
            }
        }

        
      
        return cell
    }
}

extension GalleryViewController: GalleryCollectionViewDataSourceClickDelegate{
    
    func showVideoCorruptedError() {
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.chatVideoCorrupted
        popupVC.button1Title = L10n.ok
        
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func showMaxError() {
        self.errorPopupMax()
    }
    
    func reloadCollectionView() {
        self.updateGalleryGrid()
        self.collectionView.layoutIfNeeded()

    }
    
    func selectedContent(index: Int) {
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Gallery.galleryDetailViewController.instantiate()
        detailVC.filterGalleryType = filterGalleryType
        detailVC.galleryManager = galleryManager
        detailVC.currentContentIndex = index
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
        
    }
    
    func selectedShareFiles(indexes: [Int]) {
        eliminarButton.alpha = 1
        eliminarButton.isEnabled = true
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
            eliminarButton.alpha = 0.5
            eliminarButton.isEnabled = false
        case 1:
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
                confirmarCompartirButton.setTitle(L10n.galeriaConfirmarCompartirUn, for: .normal)
            }
            else{
                confirmarCompartirButton.setTitle("", for: .normal)
            }
            confirmarCompartirButton.alpha = 1
            confirmarCompartirButton.isEnabled = true
            eliminarButton.alpha = 1
            eliminarButton.isEnabled = true
        default:
            if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
                confirmarCompartirButton.setTitle(L10n.galeriaConfirmarCompartirVaris, for: .normal)
            }
            else{
                confirmarCompartirButton.setTitle("", for: .normal)
            }
        }
        
    }
    
    func loadMoreItems() {
       // getContentsLibrary()
    }
    
   
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated:true, completion: nil)
        
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let data = chosenImage.jpegData(compressionQuality: 0.8){
           uploadImage(imageData: data)
        }
        else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            encodeVideo(videoURL)

        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    func uploadImage(imageData: Data){
        HUDHelper.sharedInstance.showHud(message: "")

        let mediaManager = MediaManager()
        mediaManager.uploadPhoto(imageData: imageData, onSuccess: { contentId in
            self.updateGalleryGrid()
            HUDHelper.sharedInstance.hideHUD()

        }, onError: { (error) in
            HUDHelper.sharedInstance.hideHUD()

            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.view.tag = self.uploadPhotoTag
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = L10n.appName
            popupVC.popupDescription = L10n.galeriaErrorSubir
            popupVC.button1Title = L10n.galeriaErrorSubirReintentar
            popupVC.button2Title = L10n.termsCancel
            popupVC.data = imageData
            self.present(popupVC, animated: true, completion: nil)
            
            
        })
    }
    
    func uploadVideo(videoData: Data){
        print("There were \(videoData.count) bytes")
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(videoData.count))
        print("formatted result: \(string)")
    
        let profileManager = AuthModelManager()
        
        if !profileManager.hasUser{
            return
        }
        HUDHelper.sharedInstance.showHud(message: "")

        let mediaManager = MediaManager()
        mediaManager.uploadVideo(videoData: videoData, onSuccess: { contentId in
            self.updateGalleryGrid()
            HUDHelper.sharedInstance.hideHUD()

        }, onError: { (error) in
            HUDHelper.sharedInstance.hideHUD()

            
            if !profileManager.hasUser{
                return
            }
            
            HUDHelper.sharedInstance.hideHUD()

            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.view.tag = self.uploadVideoTag
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = L10n.appName
            popupVC.popupDescription = L10n.galeriaErrorSubir
            popupVC.button1Title = L10n.galeriaErrorSubirReintentar
            popupVC.button2Title = L10n.termsCancel
            popupVC.data = videoData
            self.present(popupVC, animated: true, completion: nil)
        })
        
       
    }
    
    func encodeVideo(_ videoURL: URL)  {
        HUDHelper.sharedInstance.showHud(message: "")

        let exportManager = VideoExportManager()
        exportManager.exportVideo(url: videoURL) { (data, error) in
            if data != nil{
                 self.uploadVideo(videoData: data!)
                 self.deleteFile(videoURL)

            }
            else if error != nil{
                HUDHelper.sharedInstance.hideHUD()

            }
        }
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
}

extension GalleryViewController: PopUpDelegate{
    
    func showRetryPopup(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = deleteErrorTag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        
        popupVC.popupDescription = L10n.galeriaEliminarErrorUn
        if self.dataSource.selectedIndexPaths.count > 1{
            popupVC.popupDescription = L10n.galeriaEliminarErrorVaris
        }
        popupVC.button1Title = L10n.galeriaErrorSubirReintentar
        popupVC.button2Title = L10n.termsCancel

        self.present(popupVC, animated: true, completion: nil)
    }
    
    func removeConfirmedAction(){
        for indexPath in self.dataSource.selectedIndexPaths{
            
            var item: Content?
            
            switch self.filterGalleryType {
            case .all:
                item = self.galleryModelManager.contentAt(index: indexPath)
            case .mine:
                item = self.galleryModelManager.mineContentAt(index: indexPath)
            case .sent:
                item = self.galleryModelManager.sharedContentAt(index: indexPath)
            }
            
            if let item = item{
                let mediaManager = MediaManager()
                let iddd = item.id
                mediaManager.removeContentFromLibrary(contentId: iddd, onSuccess: {
                    print("removeContentFromLibrary \(iddd)")
                    self.dataSource.selectedIndexPaths.remove(at: self.dataSource.selectedIndexPaths.index(of: indexPath)!)
                    if self.dataSource.selectedIndexPaths.count == 0{
                        self.setTitleForFilter()
                        HUDHelper.sharedInstance.hideHUD()

                        self.filtrarButton.isHidden = false
                        self.compartirButton.isHidden = false
                        self.nuevoVideoButton.isHidden = false
                        self.nuevaFotoButton.isHidden = false
                        self.cancelarCompartirButton.isHidden = true
                        self.confirmarCompartirButton.isHidden = true
                        self.eliminarButton.isHidden = true
                        self.dataSource.selectionMode = false
                        self.seleccionarTodoButton.isHidden = true
                        
                        self.dataSource.deleteMode = false
                        self.dataSource.selectedIndexPaths = [Int]()
                        self.updateGalleryGrid()
                    }
                    
                    
                }) { (error) in
                    self.showRetryPopup()
                    HUDHelper.sharedInstance.hideHUD()

                }
            }
            
        }

    }
    
    func removeConfirmed(){
        HUDHelper.sharedInstance.showHud(message: "")

        if dataSource.selectAllMode{
            let libraryManager = GalleryManager()
            libraryManager.getContentsLibrary(onSuccess: { (hasMoreItems, needsReload) in
                if hasMoreItems{
                    self.removeConfirmed()
                }
                else{
                    self.dataSource.selectedIndexPaths = [Int]()
                    for i in 0..<self.dataSource.getNumberOfItems(){
                        self.dataSource.selectedIndexPaths.append(i)
                    }
                    self.removeConfirmedAction()

                }
            }) { (error) in
                HUDHelper.sharedInstance.hideHUD()
                self.showRetryPopup()
                
            }

        }
        else{
            removeConfirmedAction()
        }
        
    }
    
    func firstButtonClicked(popup: PopupViewController) {
        if popup.view.tag == deleteErrorTag{
            popup.dismissPopup {
                self.removeConfirmed()
            }
        }
        else if popup.view.tag == deleteTag{
            popup.dismissPopup {
                self.removeConfirmed()
            }
            
           
        }
        
        else if popup.view.tag == uploadPhotoTag{
            popup.dismissPopup {
                if let data = popup.data{
                    self.uploadImage(imageData: data)
                }
            }
            
            
        }
        else if popup.view.tag == uploadVideoTag{
            popup.dismissPopup {
                if let data = popup.data{
                    self.uploadVideo(videoData: data)
                }
            }
            
            
        }
        else if popup.view.tag == errorSpace{
            popup.dismissPopup {

            }
            
            
        }
        else if popup.view.tag == errorPermission{
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



extension GalleryViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        var coachMark : CoachMark
        
        if !filtrarButton.isHidden{
            switch(index) {
            case 0:
                coachMark = coachMarksController.helper.makeCoachMark(for: filtrarButton)
            case 1:
                coachMark = coachMarksController.helper.makeCoachMark(for: compartirButton)
            case 2:
                coachMark = coachMarksController.helper.makeCoachMark(for: nuevaFotoButton)
            case 3:
                coachMark = coachMarksController.helper.makeCoachMark(for: nuevoVideoButton)
                
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
            }
        }
        else{
            switch(index) {
            case 0:
                coachMark = coachMarksController.helper.makeCoachMark(for: cancelarCompartirButton)
            case 1:
                coachMark = coachMarksController.helper.makeCoachMark(for: eliminarButton)
            case 2:
                coachMark = coachMarksController.helper.makeCoachMark(for: confirmarCompartirButton)
            
                
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
            }
        }
       
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        return coachMark
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var bodyView : CoachMarkBodyView
        var arrowView : CoachMarkArrowView?
        let coachMarkBodyView = TransparentCoachMarkBodyView()
        if !filtrarButton.isHidden{
            switch(index) {
                
            case 0:
                coachMarkBodyView.hintLabel.text = L10n.wtGaleriaFiltrar
            case 1:
                coachMarkBodyView.hintLabel.text = L10n.wtGaleriaCompartir
            case 2:
                coachMarkBodyView.hintLabel.text = L10n.wtGaleriaNovaFoto
            case 3:
                coachMarkBodyView.hintLabel.text = L10n.wtGaleriaNouVideo
            default:
                break
            }
        }
        else{
            switch(index) {
                
            case 0:
                coachMarkBodyView.hintLabel.text = L10n.wtGaleriaTornar
            case 1:
                coachMarkBodyView.hintLabel.text = L10n.wtGaleriaEliminar
            case 2:
                coachMarkBodyView.hintLabel.text = L10n.wtGaleriaCompartirContactes
           
            default:
                break
            }
        }

        bodyView = coachMarkBodyView
        arrowView = nil
        
        return (bodyView: bodyView, arrowView: arrowView)
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if !filtrarButton.isHidden{
            return 4
        }
        return 3
    }
    
    
}



