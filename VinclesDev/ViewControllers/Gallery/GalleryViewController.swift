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

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filtrarButton: HoverButton!
    @IBOutlet weak var compartirButton: HoverButton!
    @IBOutlet weak var nuevaFotoButton: HoverButton!
    @IBOutlet weak var nuevoVideoButton: HoverButton!
    @IBOutlet weak var cancelarCompartirButton: HoverButton!
    @IBOutlet weak var confirmarCompartirButton: HoverButton!
    @IBOutlet weak var eliminarButton: HoverButton!

    var tableView: UITableView?
    lazy var picker = UIImagePickerController()
    
    lazy var galleryManager = GalleryManager()
    lazy var dataSource = GalleryCollectionViewDataSource()
    lazy var galleryModelManager = GalleryModelManager()
    lazy var notificationsManager = NotificationManager()
    var exportSession: AVAssetExportSession?

    fileprivate var popover: Popover!

    fileprivate var texts = [L10n.galeriaVerTodos, L10n.galeriaVerMios, L10n.galeriaVerRecibidos]
    
    var showBackButton = true

    var filterGalleryType = FilterContentType.all
    var loadingCV = false
    
    var notificationToken: NotificationToken? = nil

    var screenRotated = false
   
    let deleteTag = 1001
    let uploadPhotoTag = 1002
    let uploadVideoTag = 1003
    let deleteErrorTag = 1004

    var coachMarksController = CoachMarksController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachMarksController.dataSource = self
        coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        coachMarksController.overlay.allowTap = true
        
        getNotifications()

        configDataSources()
        configNavigationBar()
        setStrings()
        initPicker()
        addDelegates()
        configInitialStates()
        loadingCV = true
     
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
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_GALLERY)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !loadingCV{
            setNoCompartir()
            updateGalleryGrid()
        }
       
        loadingCV = false
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.notificationProcessed), name: notificationName, object: nil)

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
        setCollectionViewColumns()
        dataSource.galleryManager = galleryManager
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource.clickDelegate = self
        dataSource.galleryFilter = .all
        dataSource.galleryModelManager = GalleryModelManager()
    }
    
    
    func updateGalleryGrid(){
        if self.galleryModelManager.numberOfContents == 0{
            //   viewContactes.contactsCollectionView.isHidden = true
            //   viewContactes.noContactsView.isHidden = false
        }
        else{
            //    viewContactes.contactsCollectionView.isHidden = false
            //   viewContactes.noContactsView.isHidden = true
        }
        collectionView.reloadData()
    }
    
    
    @IBAction func filtrarAction(_ sender: Any) {
        configPopover()
    }
    
    @IBAction func compartirAction(_ sender: Any) {
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.navTitle = L10n.galeriaCompartirTitle
        }
        
        filtrarButton.isHidden = true
        compartirButton.isHidden = true
        nuevoVideoButton.isHidden = true
        nuevaFotoButton.isHidden = true
        cancelarCompartirButton.isHidden = false
        confirmarCompartirButton.isHidden = false
        eliminarButton.isHidden = false
        dataSource.selectionMode = true
        collectionView.reloadData()
    }
    
    @IBAction func newPhotoAction(_ sender: Any) {
        self.picker.sourceType = .camera
        self.picker.mediaTypes = [kUTTypeImage as String]
        self.present(self.picker, animated: true, completion: nil)
    }
    
    @IBAction func newVideoAction(_ sender: Any) {
        self.picker.sourceType = .camera
        self.picker.mediaTypes = [kUTTypeMovie as String]
        self.present(self.picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelarCompartirAction(_ sender: Any) {
        self.setNoCompartir()
        collectionView.reloadData()
    }
    
    func setNoCompartir(){
        setTitleForFilter()
        filtrarButton.isHidden = false
        compartirButton.isHidden = false
        nuevoVideoButton.isHidden = false
        nuevaFotoButton.isHidden = false
        cancelarCompartirButton.isHidden = true
        confirmarCompartirButton.isHidden = true
        eliminarButton.isHidden = true
        dataSource.selectionMode = false
        dataSource.selectedIndexPaths = [Int]()
        selectedShareFiles(indexes: dataSource.selectedIndexPaths)
    }
    
    @IBAction func confirmarCompartirAction(_ sender: Any) {
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Gallery.galleryCompartirContactsViewController.instantiate()
        detailVC.contentIds = dataSource.selectedItemsForSelectedIndexPaths()
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
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = UIColor(named: .grayChatSent)
        cell.textLabel?.font = UIFont(font: FontFamily.AkkuratLight.light, size: 16.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.tintColor = UIColor(named: .darkRed)
        if indexPath.row == filterGalleryType.rawValue{
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor(named: .darkRed)
        }
        return cell
    }
}

extension GalleryViewController: GalleryCollectionViewDataSourceClickDelegate{
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated:true, completion: nil)
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let data = UIImageJPEGRepresentation(chosenImage, 0.8){
           uploadImage(imageData: data)
        }
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL{
            encodeVideo(videoURL)

        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    func uploadImage(imageData: Data){
        let mediaManager = MediaManager()
        mediaManager.uploadPhoto(imageData: imageData, onSuccess: { contentId in
            self.updateGalleryGrid()
        }, onError: { (error) in
            
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
        
        let mediaManager = MediaManager()
        mediaManager.uploadVideo(videoData: videoData, onSuccess: { contentId in
            self.updateGalleryGrid()
            
        }, onError: { (error) in
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
        
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        
        let startDate = Foundation.Date()
        
        //Create Export session
        exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        // exportSession = AVAssetExportSession(asset: composition, presetName: mp4Quality)
        //Creating temp path to save the converted video
        
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
        let url = URL(fileURLWithPath: myDocumentPath)
        
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        
        let filePath = documentsDirectory2.appendingPathComponent("rendered-Video.mp4")
        deleteFile(filePath)
        
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do {
                try FileManager.default.removeItem(atPath: myDocumentPath)
            }
            catch let error {
                print(error)
            }
        }
        
        exportSession!.outputURL = filePath
        exportSession!.outputFileType = AVFileType.mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, 0)
        let range = CMTimeRangeMake(start, avAsset.duration)
        exportSession!.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch self.exportSession!.status {
            case .failed:
                print("%@",self.exportSession?.error)
            case .cancelled:
                print("Export canceled")
            case .completed:
                //Video conversion finished
                let endDate = Foundation.Date()
                
                let time = endDate.timeIntervalSince(startDate)
                print("Successful!")
                let mediaPath = self.exportSession!.outputURL?.path as NSString!

                
                let videoData = try! Data(contentsOf: self.exportSession!.outputURL!)
                self.uploadVideo(videoData: videoData)
                self.deleteFile(self.exportSession!.outputURL!)

                //self.mediaPath = String(self.exportSession.outputURL!)
            // self.mediaPath = self.mediaPath.substringFromIndex(7)
            default:
                break
            }
            
        })
        
        
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
    
    func removeConfirmed(){
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
                mediaManager.removeContentFromLibrary(contentId: item.id, onSuccess: {
                    
                    self.dataSource.selectedIndexPaths.remove(at: self.dataSource.selectedIndexPaths.index(of: indexPath)!)
                    if self.dataSource.selectedIndexPaths.count == 0{
                        self.setTitleForFilter()
                        
                        self.filtrarButton.isHidden = false
                        self.compartirButton.isHidden = false
                        self.nuevoVideoButton.isHidden = false
                        self.nuevaFotoButton.isHidden = false
                        self.cancelarCompartirButton.isHidden = true
                        self.confirmarCompartirButton.isHidden = true
                        self.eliminarButton.isHidden = true
                        self.dataSource.selectionMode = false
                        self.dataSource.selectedIndexPaths = [Int]()
                        self.collectionView.reloadData()
                    }
                    
                    
                }) { (error) in
                    self.showRetryPopup()
                    
                }
            }
            
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
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }

        
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



