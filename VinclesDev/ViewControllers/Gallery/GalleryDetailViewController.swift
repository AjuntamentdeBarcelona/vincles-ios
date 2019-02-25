//
//  GalleryDetailViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AVKit
import SimpleImageViewer

class GalleryDetailViewController: UIViewController {

    @IBOutlet weak var compartirButton: HoverButton!
    @IBOutlet weak var eliminarButton: HoverButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainStack: UIStackView!
    
    let dataSource = GalleryDetailCollectionViewDataSource()
    var galleryManager: GalleryManager?
    lazy var galleryModelManager = GalleryModelManager()

    var currentContentIndex: Int?
    var headerView: GalleryDetailUserHeader?
    var timeView: GaleriaInfoHoraView?

    var filterGalleryType = FilterContentType.all
    lazy var circlesManager = CirclesManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        configDataSources()
        configNavigationBar()
        configUI()
        updateGalleryGrid()

        self.collectionView?.alpha = 0
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: false)
            self.collectionView?.alpha = 1
        }
        
        updateButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryDetailViewController.notificationProcessed), name: Notification.Name(NOTIFICATION_PROCESSED), object: nil)

    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
      if let type = notification.userInfo?["type"] as? String, (type == NOTI_USER_UPDATED){
            if let idUser = notification.userInfo?["idUser"] as? Int{
                if circlesManager.userIsCircleOrDynamizer(id: idUser){
                    updateContentInfo()
                }
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_GALLERY_DETAIL)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView!.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            
            self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: false)
        }
    }

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setStrings()
    }
    
    func setStrings(){
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
            eliminarButton.setTitle(L10n.galeriaEliminar, for: .normal)
            compartirButton.setTitle(L10n.galeriaCompartir, for: .normal)
        }
        else{
            eliminarButton.setTitle("", for: .normal)
            compartirButton.setTitle("", for: .normal)
        }
    }
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "SinglePhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        collectionView.register(UINib(nibName: "SingleVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "videoCell")
        dataSource.galleryManager = galleryManager
        dataSource.galleryFilter = filterGalleryType
        dataSource.galleryModelManager = GalleryModelManager()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
        dataSource.clickDelegate = self
    }
    
    func configUI(){
        prevButton.setImage(UIImage(asset: Asset.Icons.Galeria.anteriorHover), for: .highlighted)
        nextButton.setImage(UIImage(asset: Asset.Icons.Galeria.seguentHover), for: .highlighted)

        if  (UIDevice.current.userInterfaceIdiom == .phone){
            prevButton.isHidden = true
            nextButton.isHidden = true
        }
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.leftButtonTitle = L10n.volver
            baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
            baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            
            baseViewController.navTitle = L10n.galeriaTitle
            
            baseViewController.leftAction = leftAction
            
            headerView = GalleryDetailUserHeader(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            
            
            switch filterGalleryType {
            case .all:
                if let user =  self.galleryModelManager.contentAt(index: self.currentContentIndex!).userCreator{
                    headerView!.configWithUser(user: user)
                }
                else{
                    headerView!.configWithName(name: self.galleryModelManager.contentAt(index: self.currentContentIndex!).userName)
                }
            case .mine:
                if let user =  self.galleryModelManager.mineContentAt(index: self.currentContentIndex!).userCreator{
                    headerView!.configWithUser(user: user)
                }
                else{
                    headerView!.configWithName(name: self.galleryModelManager.mineContentAt(index: self.currentContentIndex!).userName)
                }
            case .sent:
                if let user =  self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!).userCreator{
                    headerView!.configWithUser(user: user)
                }
                else{
                    headerView!.configWithName(name: self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!).userName)
                }
                
            }
            
            baseViewController.customCentralView = headerView!
     
            
            timeView = GaleriaInfoHoraView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            if  (UIDevice.current.userInterfaceIdiom == .pad){
                baseViewController.customRightView = timeView!
            }
            else{
                mainStack.insertArrangedSubview(timeView!, at: 0)
                timeView?.translatesAutoresizingMaskIntoConstraints = false
                timeView!.addConstraint(NSLayoutConstraint(item: timeView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
                timeView!.superview?.addConstraint(NSLayoutConstraint(item: timeView!, attribute: .centerX, relatedBy: .equal, toItem: timeView!.superview, attribute: .centerX, multiplier: 1, constant: 0))

            }
            switch filterGalleryType {
            case .all:
                timeView!.configWithContent(content: self.galleryModelManager.contentAt(index: self.currentContentIndex!))
            case .mine:
                timeView!.configWithContent(content: self.galleryModelManager.mineContentAt(index: self.currentContentIndex!))
            case .sent:
                timeView!.configWithContent(content: self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!))
            }
            
        }
    }
    
    func getContentsLibrary(){
        galleryManager?.getContentsLibrary( onSuccess: { (hasMoreItems, reload) in
            if reload{
                self.updateGalleryGrid()
            }
        }) { (error) in
            
            
        }
    }
    
    func updateGalleryGrid(){
        collectionView.reloadData()

    }
    
    func updateButtons(){
        if currentContentIndex == 0{
            prevButton.setImage(UIImage(asset: Asset.Icons.Galeria.anteriorUltima), for: .normal)
            prevButton.isEnabled = false
        }
        else{
            prevButton.setImage(UIImage(asset: Asset.Icons.Galeria.anterior), for: .normal)
            prevButton.isEnabled = true
        }
        
        var numContents = 0
        
        switch filterGalleryType {
        case .all:
            numContents = galleryModelManager.numberOfContents
        case .mine:
            numContents = galleryModelManager.numberOfMineContents
        case .sent:
            numContents = galleryModelManager.numberOfSharedContents
        }
        
        
        if currentContentIndex == numContents - 1{
            nextButton.setImage(UIImage(asset: Asset.Icons.Galeria.seguentUltima), for: .normal)
            nextButton.isEnabled = false
        }
        else{
            nextButton.setImage(UIImage(asset: Asset.Icons.Galeria.seguent), for: .normal)
            nextButton.isEnabled = true
        }
    }
    
    @IBAction func prevAction(_ sender: Any) {
        currentContentIndex! -= 1
        updateButtons()
        self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: true)
        
      updateContentInfo()
    
    }
    
    @IBAction func nextAction(_ sender: Any) {
        currentContentIndex! += 1
        updateButtons()
        self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: true)
        updateContentInfo()

    }
    
    func updateContentInfo(){
        switch filterGalleryType {
        case .all:
            headerView!.configWithUser(user: self.galleryModelManager.contentAt(index: self.currentContentIndex!).userCreator!)
            timeView!.configWithContent(content: self.galleryModelManager.contentAt(index: self.currentContentIndex!))
            
        case .mine:
            headerView!.configWithUser(user: self.galleryModelManager.contentAt(index: self.currentContentIndex!).userCreator!)
            timeView!.configWithContent(content: self.galleryModelManager.mineContentAt(index: self.currentContentIndex!))
        case .sent:
            headerView!.configWithUser(user: self.galleryModelManager.contentAt(index: self.currentContentIndex!).userCreator!)
            timeView!.configWithContent(content: self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!))
        }
        
    }
    
    func leftAction(_params: Any...) -> UIViewController?{
        return self.navigationController?.popViewController(animated: true)
    }
    
    
    func playVideo(content: Content){
        
        let mediaManager = MediaManager()
        mediaManager.setGalleryVideo(contentId: content.idContent, imageView: nil) { (success, fileUrl, id) in
            if let url = fileUrl{
                self.playVideoUrl(url: url)
            }
        }
       
    }
    
    func playVideoUrl(url: URL){
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        if playerViewController.player != nil{
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }

    }

    
    @IBAction func removeContentAction(_ sender: Any) {

        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.view.tag = 1001
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.galeriaEliminar
        popupVC.popupDescription = L10n.galeriaEliminarTitle
        popupVC.button1Title = L10n.termsAccept
        popupVC.button2Title = L10n.termsCancel
        
        self.present(popupVC, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func confirmarCompartirAction(_ sender: Any) {
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Gallery.galleryCompartirContactsViewController.instantiate()
        
        switch filterGalleryType {
        case .all:
            detailVC.contentIds = [self.galleryModelManager.contentAt(index: self.currentContentIndex!).idContent]
        case .mine:
            detailVC.contentIds = [self.galleryModelManager.mineContentAt(index: self.currentContentIndex!).idContent]
        case .sent:
            detailVC.contentIds = [self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!).idContent]
        }
        
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension GalleryDetailViewController: GalleryDetailCollectionViewDataSourceClickDelegate{
    func selectedContent(content: Content) {
        
        if content.mimeType.contains("video"){
            playVideo(content: content)
        }
    }
    
    func selectedImageView(imageView: UIImageView) {
        
        let gallerySwipeVC = StoryboardScene.Gallery.gallerySwipeViewController.instantiate()
        gallerySwipeVC.currentContentIndex = self.currentContentIndex
        present(gallerySwipeVC, animated: true)
    }

    func didScrollTo(content: Content, index: Int) {
        headerView!.configWithUser(user: content.userCreator!)
        timeView!.configWithContent(content: content)
        currentContentIndex = index
        updateButtons()
    }
    
    func loadMoreItems(){
        getContentsLibrary()
    }
    
}

extension GalleryDetailViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            if popup.view.tag == 1001{
                var contentId = -1
                switch self.filterGalleryType {
                case .all:
                    contentId = self.galleryModelManager.contentAt(index: self.currentContentIndex!).id
                case .mine:
                    contentId = self.galleryModelManager.mineContentAt(index: self.currentContentIndex!).id
                case .sent:
                    contentId = self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!).id
                }
                
                let mediaManager = MediaManager()
                mediaManager.removeContentFromLibrary(contentId: contentId, onSuccess: {
                    
                    var numContents = 0
                    
                    switch self.filterGalleryType {
                    case .all:
                        numContents = self.galleryModelManager.numberOfContents
                    case .mine:
                        numContents = self.galleryModelManager.numberOfMineContents
                    case .sent:
                        numContents = self.galleryModelManager.numberOfSharedContents
                    }
                    
                    if numContents == 0{
                        if let baseViewController = self.parent as? BaseViewController{
                            _ = baseViewController.leftAction!()
                        }
                    }
                    else{
                        if self.currentContentIndex! > 0{
                            self.currentContentIndex! -= 1
                        }
                        self.updateGalleryGrid()
                        self.updateButtons()
                    }
                    
                    
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
        
        
      
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
    }
    
}

