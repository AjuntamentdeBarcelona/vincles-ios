//
//  GalleryDetailViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AVKit
import SimpleImageViewer
import Firebase

class GallerySwipeViewController: UIViewController, ContentManagerDelegate {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataSource = GallerySwipeCollectionViewDataSource()
    var galleryManager: GalleryManager?
    lazy var galleryModelManager = GalleryModelManager()
    
    var currentContentIndex: Int?
//    var timeView: GaleriaInfoHoraView?
    
    @IBOutlet weak var dismissButtonSize: NSLayoutConstraint!
    var filterGalleryType = FilterContentType.all
    lazy var circlesManager = CirclesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDataSources()
        updateGalleryGrid()
        
        
        self.collectionView?.alpha = 0
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: false)
            self.collectionView?.alpha = 1
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true

        ContentManager.sharedInstance.delegate = self
        
        
        let notificationName = Notification.Name(NOTI_TOKEN_EXPIRED)
        NotificationCenter.default.addObserver(self, selector: #selector(GallerySwipeViewController.dismissProg), name: notificationName, object: nil)
        
        Analytics.setScreenName(ANALYTICS_GALLERY_DETAIL, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_GALLERY_DETAIL)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
        
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            self.dismissButtonSize.constant = 60
            self.dismissButton.layoutIfNeeded()
        }
   
     
    }
    
    func didDownload(contentId: Int) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didError(contentId: Int) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    func didCorrupted(contentId: Int) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false

        NotificationCenter.default.removeObserver(self)
    }
    @objc func dismissProg(){
        self.dismiss(animated: false, completion: nil)
    }
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        collectionView!.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            
            self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: false)
        }
    }
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "SingleVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "videoCell")
        dataSource.galleryManager = galleryManager
        dataSource.galleryFilter = filterGalleryType
        dataSource.galleryModelManager = GalleryModelManager()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
        dataSource.clickDelegate = self
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
    
    @IBAction func prevAction(_ sender: Any) {
        currentContentIndex! -= 1
        self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: true)
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        currentContentIndex! += 1
        self.collectionView?.scrollToItem(at:IndexPath(item: self.currentContentIndex!, section: 0), at: .left, animated: true)
        
    }
    
    func leftAction(_params: Any...) -> UIViewController?{
        return self.navigationController?.popViewController(animated: true)
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
            guard let content =  self.galleryModelManager.contentAt(index: self.currentContentIndex!) else{
                return
            }
            detailVC.contentIds = [content.idContent]
        case .mine:
            guard let content =  self.galleryModelManager.mineContentAt(index: self.currentContentIndex!) else{
                return
            }
            detailVC.contentIds = [content.idContent]
        case .sent:
            guard let content =  self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!) else{
                return
            }
            detailVC.contentIds = [content.idContent]
            
        }
        
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
        
    }
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension GallerySwipeViewController: GalleryDetailCollectionViewDataSourceClickDelegate{
    func showVideoCorruptedError() {
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.chatVideoCorrupted
        popupVC.button1Title = L10n.ok
        
        self.present(popupVC, animated: true, completion: nil)
    }
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    
    func selectedContent(content: Content) {
        
        if let url = ContentManager.sharedInstance.getVideoLink(contentId: content.idContent, isGroup: false){
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            if playerViewController.player != nil{
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
            
        }
        
       
    }
    
    func selectedImageView(imageView: UIImageView) {
        
    }
    
    func didScrollTo(content: Content, index: Int) {
        currentContentIndex = index
    }
    
    func loadMoreItems(){
        getContentsLibrary()
    }
    
}

extension GallerySwipeViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            if popup.view.tag == 1001{
                var contentId = -1
                switch self.filterGalleryType {
                case .all:
                    guard let content =  self.galleryModelManager.contentAt(index: self.currentContentIndex!) else{
                        return
                    }
                    contentId = content.id
                case .mine:
                    guard let content =  self.galleryModelManager.mineContentAt(index: self.currentContentIndex!) else{
                        return
                    }
                    contentId = content.id
                case .sent:
                    guard let content =  self.galleryModelManager.sharedContentAt(index: self.currentContentIndex!) else{
                        return
                    }
                    contentId = content.id
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
                    }
                    
                    
                }) { (error) in
                    let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                    popupVC.delegate = self
                    popupVC.modalPresentationStyle = .overCurrentContext
                    popupVC.popupTitle = "Error"
                    popupVC.popupDescription = error
                    popupVC.button1Title = L10n.ok
                    
                    self.present(popupVC, animated: true, completion: {
                        
                    
                    })
                }
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

class GallerySwipeCollectionViewDataSource:GalleryDetailCollectionViewDataSource{
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var content: Content?
        switch galleryFilter {
        case .all:
            content = galleryModelManager.contentAt(index: indexPath.row)
        case .mine:
            content = galleryModelManager.mineContentAt(index: indexPath.row)
        case .sent:
            content = galleryModelManager.sharedContentAt(index: indexPath.row)
        }
        
        if (content?.mimeType.contains("image"))!{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwipeImageCell", for: indexPath) as! GallerySwipeCollectionViewCell
            switch galleryFilter {
            case .all:
                if let content = content{
                    cell.configWithCont(contentId: content.idContent)
                }
            case .mine:
                if let content = content{
                    cell.configWithCont(contentId: content.idContent)
                }
            case .sent:
                if let content = content{
                    cell.configWithCont(contentId: content.idContent)
                }
                
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! SingleVideoCollectionViewCell
        switch galleryFilter {
        case .all:
            if let content = content{
                cell.configWithCont(contentId: content.idContent)
            }
        case .mine:
            if let content = content{
                cell.configWithCont(contentId: content.idContent)
            }
        case .sent:
            if let content = content{
                cell.configWithCont(contentId: content.idContent)
            }
            
        }
        return cell
    }
}
