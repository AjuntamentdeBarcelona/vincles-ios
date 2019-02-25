//
//  ChatViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import NextGrowingTextView
import MobileCoreServices
import AVKit
import SimpleImageViewer
import IQKeyboardManagerSwift
import SwiftyTimer
import Reachability
import AVFoundation

class ChatContainerViewController: UIViewController {
    var showBackButton = true
    let reachability = Reachability()!
    var exportSession: AVAssetExportSession?

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var textButton: HoverButton!
    @IBOutlet weak var fotoButton: HoverButton!
    @IBOutlet weak var videoButton: HoverButton!
    @IBOutlet weak var audioButton: HoverButton!
    @IBOutlet weak var galeriaButton: HoverButton!
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    
    @IBOutlet weak var volverTextButton: UIButton!
    @IBOutlet weak var enviarButton: UIButton!

    @IBOutlet weak var viewGeneralOptions: UIView!
    @IBOutlet weak var viewRecord: UIView!

    @IBOutlet weak var volverAudioButton: UIButton!
    @IBOutlet weak var enviarAudioButton: UIButton!
    @IBOutlet weak var labelGrabando: UILabel!
    @IBOutlet weak var labelTiempo: UILabel!
    @IBOutlet weak var progressTiempo: UIProgressView!

    lazy var chatManager = ChatManager()
    lazy var mediaManager = MediaManager()
    lazy var chatModelManager = ChatModelManager()

    lazy var circlesGroupsModelManager = CirclesGroupsModelManager()
    lazy var profileModelManager = ProfileModelManager()

    lazy var picker = UIImagePickerController()
    
    lazy var chatDataSource = ChatDataSource()
    var isDinam = false
    var toUserId = -1
    var toUser: User?

    var recordTimer = Timer()
    var seconds = 60

    lazy var  notificationsManager = NotificationManager()
    lazy var  notificationsModelManager = NotificationsModelManager()

    var openHomeOnBack = false

    let textTag = 1001
    let uploadPhotoTag = 1002
    let uploadVideoTag = 1003
    let uploadAudioTag = 1004
    let errorGrabacioTag = 1005

    var group: Group?
    
    var coachMarksController = CoachMarksController()

    override func viewDidAppear(_ animated: Bool) {
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatContainerViewController.notificationProcessed), name: notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatContainerViewController.menuOpened), name: Notification.Name("MenuOpen"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ChatContainerViewController.audioStopped), name: Notification.Name("AudioStop"), object: nil)

        getNotifications()


    }
    
    @objc func audioStopped(){
        for cell in tableView.visibleCells{
            if let cell = cell as? IncomingChatTableViewCell{
                cell.stopAudio()
            }
            else if let cell = cell as? OutgoingChatTableViewCell{
                cell.stopAudio()
            }
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
       //  NotificationCenter.default.removeObserver(self)
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        coachMarksController.dataSource = self
        coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        coachMarksController.overlay.allowTap = true
        
        growingTextView.textView.autocorrectionType = .no
        let item : UITextInputAssistantItem = growingTextView.textView.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        
        growingTextView.textView.inputAccessoryView = nil
        
        self.setupNavigationBar(barButtons: true)

        self.tableView.backgroundColor = UIColor(named: .clearGrayChat)

        if toUserId != -1{
            toUser = circlesGroupsModelManager.contactWithId(id: toUserId)
        }
        
        
        configNavigationBar()
        setStrings()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatContainerViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatContainerViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        configUI()
        
        tableView.transform =  CGAffineTransform(scaleX: 1, y: -1)

        
        setDataSource()
        
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
    

    @objc func menuOpened(_ notification: NSNotification){
        growingTextView.textView.resignFirstResponder()
    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
        if let idFrom = notification.userInfo?["idFrom"] as? Int,  let idTo = notification.userInfo?["idTo"] as? Int, (idFrom == toUserId || idTo == toUserId){
            chatDataSource.items = chatModelManager.buildItemsArray(circleId: toUserId)
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
               // self.tableView.scrollToBottom()
            }
            
        }
        else if let idChat = notification.userInfo?["idChat"] as? Int, idChat == group?.idChat{
            chatDataSource.items = chatModelManager.buildGroupItemsArray(idChat: idChat)
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
                // self.tableView.scrollToBottom()
            }
            
        }
        else if let idChat = notification.userInfo?["idChat"] as? Int, idChat == group?.idDynamizerChat{
            
            chatDataSource.items = chatModelManager.buildDinamitzadorItemsArray(idChat: (group?.idChat)!)
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
                // self.tableView.scrollToBottom()
            }
            
        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_USER_UPDATED, let idUser = notification.userInfo?["idUser"] as? Int, (idUser == toUserId || idUser == toUserId){
            // USER CHANGE WHILE IN USER CHAT

            if let baseViewController = self.parent as? BaseViewController{
                
                if let central = baseViewController.customCentralView as? GalleryDetailUserHeader{
                    central.configWithUser(user: toUser!)
                }
                
                
            }
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
                // self.tableView.scrollToBottom()
            }
            
        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_USER_UPDATED,  let idUser = notification.userInfo?["idUser"] as? Int, group !=  nil, isDinam, idUser == group!.dynamizer?.id{
            // DYNAMIZER CHANGE WHILE IN DYNAMIZER CHAT

            if let baseViewController = self.parent as? BaseViewController{

                if let central = baseViewController.customCentralView as? GalleryDetailUserHeader{
                    central.configWithUser(user: group!.dynamizer!)
                }

                
            }
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
                // self.tableView.scrollToBottom()
            }
            
        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_USER_UPDATED,  let idUser = notification.userInfo?["idUser"] as? Int, group !=  nil, isDinam == false, idUser == group!.dynamizer?.id{
            // DYNAMIZER CHANGE WHILE IN GROUP CHAT
            if let baseViewController = self.parent as? BaseViewController{
                
                if let right = baseViewController.customRightView as? ChatDinamitzadorHeader{
                    right.configWithGroup(group: group!)
                }
                
                
            }
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
                // self.tableView.scrollToBottom()
            }
            
        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_GROUP_UPDATED,  let idGroup = notification.userInfo?["idGroup"] as? Int, group !=  nil, isDinam == false, idGroup == group!.id{
            // GROUP CHANGE WHILE IN GROUP CHAT
            if let baseViewController = self.parent as? BaseViewController{
                
                if let central = baseViewController.customCentralView as? GalleryDetailUserHeader{
                    central.configWithGroup(group: group!)
                }
                if let right = baseViewController.customRightView as? ChatDinamitzadorHeader{
                    right.configWithGroup(group: group!)
                }
            }
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
                // self.tableView.scrollToBottom()
            }
            
        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_INCOMING_CALL{
            chatDataSource.items = chatModelManager.buildItemsArray(circleId: toUserId)
            tableView.reloadData()
            DispatchQueue.main.async { () -> Void in
                // self.tableView.scrollToBottom()
            }
        }
        

        else{
 
        }
    }
    
    func setDataSource(){
        tableView.register(UINib(nibName: "IncomingChatTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingTextCell")
        tableView.register(UINib(nibName: "OutgoingChatTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingTextCell")
        tableView.register(UINib(nibName: "ChatDayTableViewCell", bundle: nil), forCellReuseIdentifier: "dayCell")
        tableView.register(UINib(nibName: "ChatCallTableViewCell", bundle: nil), forCellReuseIdentifier: "callCell")

        if toUserId != -1{
            chatDataSource.toUser = toUser
            chatDataSource.toUserId = toUserId
            chatDataSource.items = chatModelManager.buildItemsArray(circleId: toUserId)
        }
        else if group != nil{
            chatDataSource.group = group
            if isDinam{
                chatDataSource.items = chatModelManager.buildDinamitzadorItemsArray(idChat: (group?.idChat)!)

            }
            else{
                chatDataSource.items = chatModelManager.buildGroupItemsArray(idChat: (group?.idChat)!)

            }
            chatDataSource.isDinam = isDinam

        }
       
        chatDataSource.dsDelegate = self


        tableView.dataSource = chatDataSource
        tableView.delegate = chatDataSource
        DispatchQueue.main.async { () -> Void in
           // self.tableView.scrollToBottom()
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
    
  
    override func viewWillDisappear(_ animated: Bool) {
        if toUserId != -1{
            chatModelManager.markAllMessageWatched(circleId: toUserId)
        }
        else if group != nil{
            
            var idChat = -1
            
            if isDinam{
                if let chatId = group?.idDynamizerChat{
                    idChat = chatId
                }
            }
            else{
                if let chatId = group?.idChat{
                    idChat = chatId
                }
            }
            // DONE WATCHED: Marcar missatges llegits
            chatModelManager.markAllGroupMessageWatched(idChat: idChat)
            
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        AudioManager.sharedInstance.player?.stop()
        audioStopped()

    }
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        growingTextView.textView.autocorrectionType = .no
        let item : UITextInputAssistantItem = growingTextView.textView.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
         IQKeyboardManager.shared.enableAutoToolbar = false
        
        growingTextView.textView.inputAccessoryView = nil
        
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_CHAT)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    deinit {
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configUI(){
        
        galeriaButton.titleLabel?.numberOfLines = 2
        viewRecord.isHidden = true

        enviarButton.semanticContentAttribute = .forceRightToLeft
        enviarAudioButton.semanticContentAttribute = .forceRightToLeft

        self.growingTextView.textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        self.growingTextView.textView.font = UIFont(font: FontFamily.Akkurat.regular, size: 18.0)
        self.growingTextView.textView.textColor = UIColor(named: .darkGray)
        self.growingTextView.textView.backgroundColor = .white
        self.growingTextView.layer.borderColor = UIColor(named: .darkGray).cgColor
        self.growingTextView.layer.borderWidth = 1.0
        self.growingTextView.layer.cornerRadius = 10
        self.growingTextView.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: L10n.chatPlaceholder,
                                                                            attributes: [NSAttributedStringKey.font: self.growingTextView.textView.font!,
                                                                                         NSAttributedStringKey.foregroundColor: UIColor(named: .darkGray)
                                                                                
            ])
        
        
        
    }
    
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //key point 0,
                self.inputContainerViewBottom.constant =  0
                
               
                if let baseViewController = self.parent as? BaseViewController{
                    baseViewController.navigationBarHeight.constant = 100.0

                    if UIDevice.current.userInterfaceIdiom == .phone {
                        baseViewController.navigationBarHeight.constant = 70.0
                    }
                }
                //textViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
 
        
        if let userInfo = sender.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                var keyboardHeight = keyboardSize.size.height
                inputContainerViewBottom.constant = keyboardHeight
                
                if #available(iOS 11.0, *) {
                    if let baseViewController = self.parent as? BaseViewController{
                        let bottomInset = baseViewController.view.safeAreaInsets.bottom
                        keyboardHeight -= bottomInset
                        inputContainerViewBottom.constant = keyboardHeight
                        
                        baseViewController.navigationBarHeight.constant = 0
                    }
                    
                  
                    
                    
                }
                
                DispatchQueue.main.async { () -> Void in
                  //  self.tableView.scrollToBottom()
                }
            }
        }
    }
    
  
    
    func setStrings(){
        labelGrabando.text = L10n.chatGrabando
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
            textButton.setTitle(L10n.chatText, for: .normal)
            fotoButton.setTitle(L10n.chatFoto, for: .normal)
            videoButton.setTitle(L10n.chatVideo, for: .normal)
            audioButton.setTitle(L10n.chatAudio, for: .normal)
            galeriaButton.setTitle(L10n.chatGaleria, for: .normal)
            volverTextButton.setTitle(L10n.chatSortirText, for: .normal)
            enviarButton.setTitle(L10n.chatEnviar, for: .normal)
            volverAudioButton.setTitle(L10n.cancelar, for: .normal)
            enviarAudioButton.setTitle(L10n.chatEnviar, for: .normal)
        }
        else{
           textButton.setTitle("", for: .normal)
            fotoButton.setTitle("", for: .normal)
            videoButton.setTitle("", for: .normal)
            audioButton.setTitle("", for: .normal)
            galeriaButton.setTitle("", for: .normal)
            volverTextButton.setTitle("", for: .normal)
            enviarButton.setTitle("", for: .normal)
            volverAudioButton.setTitle("", for: .normal)
            enviarAudioButton.setTitle("", for: .normal)
        }
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
            
       
            
            let headerView = GalleryDetailUserHeader(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

            if toUserId != -1{
                // baseViewController.navTitle = toUser?.name
                headerView.configWithUser(user: toUser!)

                baseViewController.rightButtonTitle = L10n.trucar
                baseViewController.rightButtonImage = UIImage(asset: Asset.Icons.Chat.trucar)
                baseViewController.rightButtonHightlightedImage = UIImage(asset: Asset.Icons.Chat.trucarHover)
            }
            else if group != nil{
                if isDinam{
                    baseViewController.navTitle = group!.dynamizer?.name
                    headerView.configWithUser(user: group!.dynamizer!)

                }
                else{
                    baseViewController.navTitle = group!.name
                    headerView.configWithGroup(group: group!)
                    headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapGroupHeader)))
                    
                    let dinamHeader = ChatDinamitzadorHeader(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
                    dinamHeader.configWithGroup(group: group!)
                    baseViewController.customRightView = dinamHeader
                    dinamHeader.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapDinamitzador)))
                }
              

            }
            
            
            
            baseViewController.customCentralView = headerView

            baseViewController.leftAction = leftAction
            baseViewController.rightAction = rightAction

        }
    }
    
    @objc func tapGroupHeader(){
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Chat.groupInfoViewController.instantiate()
        detailVC.group = group!
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
     @objc func tapDinamitzador(){
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let chatVC = StoryboardScene.Chat.chatContainerViewController.instantiate()
        baseVC.containedViewController = chatVC
        chatVC.group = group
        chatVC.isDinam = true
        self.navigationController?.pushViewController(baseVC, animated: true)
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
    
    func rightAction(_params: Any...) -> UIViewController?{
        if reachability.connection != .none{
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            let outgoingCallVC = StoryboardScene.Call.outgoingCallViewController.instantiate()
            outgoingCallVC.user = toUser
            baseVC.containedViewController = outgoingCallVC
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 5;
            alertWindow.makeKeyAndVisible()
            
            alertWindow.rootViewController?.present(baseVC, animated: true, completion: nil)
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
      
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showTextOptions(_ sender: Any) {
        
        viewGeneralOptions.isHidden = true
        inputContainerView.isHidden = false
        growingTextView.textView.becomeFirstResponder()
       
    }
    
    @IBAction func backFromText(_ sender: Any) {
        growingTextView.textView.resignFirstResponder()
        viewGeneralOptions.isHidden = false
        inputContainerView.isHidden = true
    }
    
    @IBAction func sendText(_ sender: Any) {
      
        if growingTextView.textView.text.isEmpty{
            return
        }
        
        uploadText(text: growingTextView.textView.text)
        
    }
    
    func uploadText(text: String){
        
        if group == nil{
            guard let toId = toUser?.id else{
                return
            }
            
            enviarButton.alpha = 0.5
            enviarButton.isEnabled = false

            chatManager.sendUserTextMessage(toUser: toId , message: text, onSuccess: { (res) in

                self.chatManager.getChatUserMessageById(idMessage: res, onSuccess: { (message) in
                    
                    self.growingTextView.textView.text = ""
                    
                    self.chatModelManager.markAllMessageWatched(circleId: self.toUserId)
                    
                    self.chatDataSource.items = self.chatModelManager.buildItemsArray(circleId: self.toUserId)
                    self.enviarButton.alpha = 1
                    self.enviarButton.isEnabled = true
                    self.tableView.reloadData()
                    DispatchQueue.main.async { () -> Void in
                        // self.tableView.scrollToBottom()
                    }
                }, onError: { (error, status) in
                    self.enviarButton.alpha = 1
                    self.enviarButton.isEnabled = true
                    self.showRetryPopup(messageType: .text, tag: self.textTag, text: text)
                })
                
            }) { (error) in
                self.enviarButton.alpha = 1
                self.enviarButton.isEnabled = true
                self.showRetryPopup(messageType: .text, tag: self.textTag, text: text)
            }
        }
        else{
            var idChat = -1
            
            if isDinam{
                if let chatId = group?.idDynamizerChat{
                    idChat = chatId
                }
            }
            else{
                if let chatId = group?.idChat{
                    idChat = chatId
                }
                
            }
            self.enviarButton.alpha = 0.5
            self.enviarButton.isEnabled = false
            chatManager.sendGroupTextMessage(idChat: idChat, message: text, onSuccess: { (res) in
                if self.isDinam{
                    self.chatManager.getChatDinamitzadorMessageById(idChat: idChat, idMessage: res,  onSuccess: { (message) in

                        self.enviarButton.alpha = 1
                        self.enviarButton.isEnabled = true
                       self.completedDimanitzador()
                        
                    }, onError: { (error) in
                        self.enviarButton.alpha = 1
                        self.enviarButton.isEnabled = true
                        self.showRetryPopup(messageType: .text, tag: self.textTag, text: text)
                    })
                }
                else{
                    self.chatManager.getChatGroupMessageById(idChat: idChat, idMessage: res,  onSuccess: { (message) in

                        self.enviarButton.alpha = 1
                        self.enviarButton.isEnabled = true
                      self.completedGroup()
                        

                    }, onError: { (error, status) in
                        self.enviarButton.alpha = 1
                        self.enviarButton.isEnabled = true
                        self.showRetryPopup(messageType: .text, tag: self.textTag, text: text)
                    })
                }
                
            }) { (error) in
                
            }
            
          
        }
        
    }
    
    func completedGroupAndDinam(){

    }
    
    func completedGroup(){
        self.growingTextView.textView.text = ""
        // DONE WATCHED

        if group != nil{
            
            var idChat = -1
            
            if isDinam{
                if let chatId = group?.idDynamizerChat{
                    idChat = chatId
                }
            }
            else{
                if let chatId = group?.idChat{
                    idChat = chatId
                }
            }
            chatModelManager.markAllGroupMessageWatched(idChat: idChat)
            
        }
        self.chatDataSource.items = self.chatModelManager.buildGroupItemsArray(idChat: group!.idChat)
        
        self.tableView.reloadData()
        DispatchQueue.main.async { () -> Void in
            // self.tableView.scrollToBottom()
        }
    }
    
    func completedDimanitzador(){
        self.growingTextView.textView.text = ""
        // DONE WATCHED
        if group != nil{
            
            var idChat = -1
            
            if isDinam{
                if let chatId = group?.idDynamizerChat{
                    idChat = chatId
                }
            }
            else{
                if let chatId = group?.idChat{
                    idChat = chatId
                }
            }
            chatModelManager.markAllGroupMessageWatched(idChat: idChat)
            
        }
        self.chatDataSource.items = self.chatModelManager.buildDinamitzadorItemsArray(idChat: group!.idChat)
        
        self.tableView.reloadData()
        DispatchQueue.main.async { () -> Void in
            // self.tableView.scrollToBottom()
        }
    }
    
    

    @IBAction func cameraImage(_ sender: Any) {
        picker.delegate = self

        self.picker.allowsEditing = false

        self.picker.sourceType = .camera
        self.picker.mediaTypes = [kUTTypeImage as String]
        self.present(self.picker, animated: true, completion: nil)
        
    }
    
    @IBAction func cameraVideo(_ sender: Any) {
        picker.delegate = self

        self.picker.allowsEditing = false
        picker.videoMaximumDuration = TimeInterval(120)
        self.picker.sourceType = .camera
        self.picker.mediaTypes = [kUTTypeMovie as String]
        self.present(self.picker, animated: true, completion: nil)
    }
    
    @IBAction func album(_ sender: Any) {
      
        picker.delegate = self
        
        self.picker.allowsEditing = false
        
        self.picker.sourceType = .photoLibrary
        self.picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]

        self.present(self.picker, animated: true, completion: nil)
      
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        viewRecord.isHidden = false
        viewGeneralOptions.isHidden = true
        
        
        startRecording()

    }
    
    @IBAction func backFromAudio(_ sender: Any) {
        viewGeneralOptions.isHidden = false
        viewRecord.isHidden = true
        endRecording(send: false)

    }
    
    @IBAction func sendAudio(_ sender: Any) {
        viewGeneralOptions.isHidden = false
        viewRecord.isHidden = true
        endRecording(send: true)
    }
    
    func startRecording(){
        labelTiempo.text = "00:60"
        progressTiempo.setProgress(0, animated: false)
        AudioManager.sharedInstance.checkPermision { (allowed) in
            if allowed{
                self.seconds = 60
                AudioManager.sharedInstance.startRecording()
                self.recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ChatContainerViewController.updateTimer)), userInfo: nil, repeats: true)
            }
            else{
                self.viewGeneralOptions.isHidden = false
                self.viewRecord.isHidden = true
                AudioManager.sharedInstance.finishRecording(success: false)
                
                let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                popupVC.delegate = self
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.popupTitle = "Error"
                popupVC.popupDescription = L10n.chatErrorGrabacio
                popupVC.button1Title = L10n.ok
                popupVC.view.tag = self.errorGrabacioTag
                self.present(popupVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        let invertedSec = 60 - seconds
        let progress = (Double(invertedSec) * 100) / 6000
        labelTiempo.text = "00:\(String(format: "%02d", seconds))" //This will update the label.
        progressTiempo.setProgress(Float(progress), animated: true)
        if seconds == 0{
            viewGeneralOptions.isHidden = false
            viewRecord.isHidden = true
            endRecording(send: true)
        }
    }
    
    func endRecording(send: Bool){
        recordTimer.invalidate()
        AudioManager.sharedInstance.finishRecording(success: true)
        if(send){
            if let data = AudioManager.sharedInstance.getData(){
               uploadAudio(data: data)
            }
           
        }
        else{
            
        }
    }
    
    func uploadAudio(data: Data){
        
        mediaManager.uploadAudio(audioData: data, onSuccess: { (response) in
            AudioManager.sharedInstance.saveRecording(contentId: response)
            
            if self.group == nil{
                guard let toId = self.toUser?.id else{
                    return
                }
                
                self.chatManager.sendAudioMessage(toUser: toId, contentId: response, onSuccess: { res in
                    
                    self.chatManager.getChatUserMessageById(idMessage: res, onSuccess: { (message) in
                        
                        if message.idAdjuntContents.count > 0{
                            self.mediaManager.saveChatAudio(contentId: message.idAdjuntContents[0], audioData: data)
                        }
                        
                        self.chatModelManager.markAllMessageWatched(circleId: self.toUserId)
                        
                        self.chatDataSource.items = self.chatModelManager.buildItemsArray(circleId: self.toUserId)
                        
                        self.tableView.reloadData()
                        DispatchQueue.main.async { () -> Void in
                            // self.tableView.scrollToBottom()
                        }
                    }, onError: { (error, status) in
                        self.showRetryPopup(messageType: .audio, tag: self.uploadAudioTag, data: data)
                        
                    })
                    
                }, onError: { (error) in
                    self.showRetryPopup(messageType: .audio, tag: self.uploadAudioTag, data: data)
                    
                })
            }
            else{
                var chatId = -1
                
                if self.isDinam{
                    if let id = self.group?.idDynamizerChat{
                        chatId = id
                    }
                }
                else{
                    if let id = self.group?.idChat{
                        chatId = id
                    }
                    
                }
                
                
                self.chatManager.sendGroupAudioMessage(idChat: chatId, contentId: response, onSuccess: { (res) in
                    
                    if self.isDinam{
                        self.chatManager.getChatDinamitzadorMessageById(idChat: chatId, idMessage: res,  onSuccess: { (message) in
                            if message.idContent != -1{
                                self.mediaManager.saveChatAudioGroup(idMessage: message.id, audioData: data)
                            }
                            self.completedDimanitzador()
                        }, onError: { (error) in
                            self.showRetryPopup(messageType: .audio, tag: self.uploadAudioTag, data: data)
                        })
                    }
                    else{
                        self.chatManager.getChatGroupMessageById(idChat: chatId, idMessage: res,  onSuccess: { (message) in
                            if message.idContent != -1{
                                self.mediaManager.saveChatAudioGroup(idMessage: message.id, audioData: data)
                            }
                            self.completedGroup()
                        }, onError: { (error, status) in
                                self.showRetryPopup(messageType: .audio, tag: self.uploadAudioTag, data: data)
                        })
                    }
                    
                  
                }) { (error) in
                    self.showRetryPopup(messageType: .audio, tag: self.uploadAudioTag, data: data)
                }
                
            }
            
            
        }, onError: { (error) in
            self.showRetryPopup(messageType: .audio, tag: self.uploadAudioTag, data: data)
            
        })
    }
    


}

extension ChatContainerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated:true, completion: nil)
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let data = UIImageJPEGRepresentation(chosenImage, 0.8){
            self.uploadImage(data: data)
        }
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL{
            encodeVideo(videoURL)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    func uploadVideo(data: Data){

        let mediaManager = MediaManager()
        
        
        mediaManager.uploadVideo(videoData: data, onSuccess: { contentId in
            if self.group == nil{
                guard let toId = self.toUser?.id else{
                    return
                }
                self.chatManager.sendUserVideoMessage(toUser: toId, contentId: contentId, onSuccess: { (res) in
                    
                   
                    self.chatManager.getChatUserMessageById(idMessage: res, onSuccess: { (message) in
                        
                        if message.idAdjuntContents.count > 0{
                            mediaManager.saveChatVideo(contentId: message.idAdjuntContents[0], videoData: data)
                        }
                        
                        self.chatModelManager.markAllMessageWatched(circleId: self.toUserId)
                        
                        self.chatDataSource.items = self.chatModelManager.buildItemsArray(circleId: self.toUserId)
                        
                        self.tableView.reloadData()
                        
                    }, onError: { (error, status) in
                        self.showRetryPopup(messageType: .video, tag: self.uploadVideoTag, data: data)
                        
                    })
                }, onError: { (error) in
                    self.showRetryPopup(messageType: .video, tag: self.uploadVideoTag, data: data)
                    
                })
            }
            else{
                var chatId = -1
                
                if self.isDinam{
                    if let id = self.group?.idDynamizerChat{
                        chatId = id
                    }
                }
                else{
                    if let id = self.group?.idChat{
                        chatId = id
                    }
                    
                }
                
                
                self.chatManager.sendGroupVideoMessage(idChat: chatId, contentId: contentId, onSuccess: { (res) in
                    
                    
                    if self.isDinam{
                        self.chatManager.getChatDinamitzadorMessageById(idChat: chatId, idMessage: res,  onSuccess: { (message) in
                            if message.idContent != -1{
                                mediaManager.saveChatVideoGroup(idMessage: message.id, videoData: data)
                            }
                            self.completedDimanitzador()
                        }, onError: { (error) in
                            self.showRetryPopup(messageType: .video, tag: self.uploadVideoTag, data: data)
                        })
                    }
                    else{
                        self.chatManager.getChatGroupMessageById(idChat: chatId, idMessage: res,  onSuccess: { (message) in
                            if message.idContent != -1{
                                mediaManager.saveChatVideoGroup(idMessage: message.id, videoData: data)
                            }
                            self.completedGroup()
                        }, onError: { (error, status) in
                            self.showRetryPopup(messageType: .video, tag: self.uploadVideoTag, data: data)
                        })
                    }
                    
                   
                }) { (error) in
                    self.showRetryPopup(messageType: .video, tag: self.uploadVideoTag, data: data)
                }
                
                
            }
           
        }, onError: { (error) in
            self.showRetryPopup(messageType: .video, tag: self.uploadVideoTag, data: data)
            
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
                print(time)
                print("Successful!")
                print(self.exportSession!.outputURL)
                let mediaPath = self.exportSession!.outputURL?.path as NSString!
                print(mediaPath)
                
                let videoData = try! Data(contentsOf: self.exportSession!.outputURL!)
                self.uploadVideo(data: videoData)
                
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
    
    func uploadImage(data: Data){
        let mediaManager = MediaManager()
        mediaManager.uploadPhoto(imageData: data, onSuccess: { contentId in
            if self.group == nil{
                guard let toId = self.toUser?.id else{
                    return
                }
                self.chatManager.sendUserImageMessage(toUser: toId, contentId: contentId, onSuccess: { (sent) in
                    
                    
                    self.chatManager.getChatUserMessageById(idMessage: sent, onSuccess: { (message) in
                        if message.idAdjuntContents.count > 0{
                            mediaManager.saveChatImage(contentId: message.idAdjuntContents[0], imageData: data)
                        }
                        self.chatModelManager.markAllMessageWatched(circleId: self.toUserId)
                        
                        self.chatDataSource.items = self.chatModelManager.buildItemsArray(circleId: self.toUserId)
                        
                        self.tableView.reloadData()
                        
                    }, onError: { (error, status) in
                        print(error)
                        self.showRetryPopup(messageType: .image, tag: self.uploadPhotoTag, data: data)
                        
                    })
                }, onError: { (error) in
                    self.showRetryPopup(messageType: .image, tag: self.uploadPhotoTag, data: data)
                    
                })
            }
            else{
                var chatId = -1
                
                if self.isDinam{
                    if let id = self.group?.idDynamizerChat{
                        chatId = id
                    }
                }
                else{
                    if let id = self.group?.idChat{
                        chatId = id
                    }
                    
                }
                
                self.chatManager.sendGroupImageMessage(idChat: chatId, contentId: contentId, onSuccess: { (res) in
                    
                    if self.isDinam{
                        self.chatManager.getChatDinamitzadorMessageById(idChat: chatId, idMessage: res,  onSuccess: { (message) in
                            if message.idContent != -1{
                                mediaManager.saveChatImageGroup(idMessage: message.id, imageData: data)
                            }
                            self.completedDimanitzador()
                        }, onError: { (error) in
                            self.showRetryPopup(messageType: .video, tag: self.uploadPhotoTag, data: data)
                        })
                    }
                    else{
                        self.chatManager.getChatGroupMessageById(idChat: chatId, idMessage: res,  onSuccess: { (message) in
                            if message.idContent != -1{
                                mediaManager.saveChatImageGroup(idMessage: message.id, imageData: data)
                            }
                            self.completedGroup()
                        }, onError: { (error, status) in
                            self.showRetryPopup(messageType: .video, tag: self.uploadPhotoTag, data: data)
                        })
                    }
                    
                  
                }) { (error) in
                    self.showRetryPopup(messageType: .video, tag: self.uploadPhotoTag, data: data)
                }
            }
            
        }, onError: { (error) in
            self.showRetryPopup(messageType: .image, tag: self.uploadPhotoTag, data: data)
        })
    }
    
    
}

extension ChatContainerViewController: PopUpDelegate{
    
    func showRetryPopup(messageType: MessageType, tag: Int, data: Data? = nil, text: String? = nil){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = tag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        switch messageType {
        case .audio:
            popupVC.popupDescription = L10n.chatErrorSubirAudio
        case .video:
            popupVC.popupDescription = L10n.chatErrorSubirVideo
        case .image:
            popupVC.popupDescription = L10n.chatErrorSubirImagen
        case .text:
            popupVC.popupDescription = L10n.chatErrorSubirTexto
        }
        popupVC.button1Title = L10n.galeriaErrorSubirReintentar
        popupVC.button2Title = L10n.termsCancel
        popupVC.data = data
        popupVC.text = text
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func firstButtonClicked(popup: PopupViewController) {
        switch popup.view.tag {
        case errorGrabacioTag:
            popup.dismissPopup {
            }
        case uploadPhotoTag:
            popup.dismissPopup {
                if let data = popup.data{
                    self.uploadImage(data: data)
                }
            }
        case uploadVideoTag:
            popup.dismissPopup {
                if let data = popup.data{
                    self.uploadVideo(data: data)
                }
            }
        case uploadAudioTag:
            popup.dismissPopup {
                if let data = popup.data{
                    self.uploadAudio(data: data)
                }
            }
        case textTag:
            popup.dismissPopup {
                if let text = popup.text{
                    self.uploadText(text: text)
                }
            }
        default:
            popup.dismissPopup {
            }
        }
      
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
    }
    
}

extension ChatContainerViewController: ChatDataSourceDelegate{
  
    func reloadTable() {
       
        if group == nil{
            chatDataSource.items = chatModelManager.buildItemsArray(circleId: toUserId)

        }
        else{
            if isDinam{
                chatDataSource.items = chatModelManager.buildDinamitzadorItemsArray(idChat: (group?.idChat)!)
                
            }
            else{
                chatDataSource.items = chatModelManager.buildGroupItemsArray(idChat: (group?.idChat)!)
                
            }
        }
    
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }
    }

    func tappedImage(imageView: UIImageView) {
        let configuration = ImageViewerConfiguration { config in
            config.image = imageView.image
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
    
    func tappedVideo(contentId: Int, isGroup: Bool) {
        if group == nil{
            let mediaManager = MediaManager()
            mediaManager.setGalleryVideo(contentId: contentId, imageView: nil) { (success, fileUrl, id) in
                if let url = fileUrl{
                    self.playVideoUrl(url: url)
                }
            }
        }
        else{
            let mediaManager = MediaManager()
            mediaManager.setGalleryVideo(contentId: contentId, imageView: nil, isGroup: true) { (success, fileUrl, id) in
                if let url = fileUrl{
                    self.playVideoUrl(url: url)
                }
                
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
    
    func presentImage(imageView: UIImageView){
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }

}

extension ChatContainerViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        var coachMark : CoachMark
        if !viewGeneralOptions.isHidden{
            switch(index) {
            case 0:
                coachMark = coachMarksController.helper.makeCoachMark(for: textButton)
            case 1:
                coachMark = coachMarksController.helper.makeCoachMark(for: fotoButton)
            case 2:
                coachMark = coachMarksController.helper.makeCoachMark(for: videoButton)
            case 3:
                coachMark = coachMarksController.helper.makeCoachMark(for: audioButton)
            case 4:
                coachMark = coachMarksController.helper.makeCoachMark(for: galeriaButton)
            case 5:
                if let baseViewController = self.parent as? BaseViewController{
                    coachMark = coachMarksController.helper.makeCoachMark(for: baseViewController.navigationBar.rightButton)
                }
                else{
                    coachMark = coachMarksController.helper.makeCoachMark()
                }
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
            }
        }
        else if !viewRecord.isHidden{
            coachMark = coachMarksController.helper.makeCoachMark(for: viewRecord)
        }
        else if !inputContainerView.isHidden{
            coachMark = coachMarksController.helper.makeCoachMark(for: inputContainerView)
        }
        else{
            coachMark = coachMarksController.helper.makeCoachMark(for: viewRecord)
        }
       
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        return coachMark
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var bodyView : CoachMarkBodyView
        var arrowView : CoachMarkArrowView?
        let coachMarkBodyView = TransparentCoachMarkBodyView()
        if !viewGeneralOptions.isHidden{
            switch(index) {
                
            case 0:
                coachMarkBodyView.hintLabel.text = L10n.wtChatText
            case 1:
                coachMarkBodyView.hintLabel.text = L10n.wtChatFoto
            case 2:
                coachMarkBodyView.hintLabel.text = L10n.wtChatVideo
            case 3:
                coachMarkBodyView.hintLabel.text = L10n.wtChatAudio
            case 4:
                coachMarkBodyView.hintLabel.text = L10n.wtChatGaleria
            case 5:
                if toUserId != -1{
                    coachMarkBodyView.hintLabel.text = L10n.wtChatTrucar
                }else{
                   coachMarkBodyView.hintLabel.text = L10n.wtChatCompte
                }
                
                
            default:
                break
            }

        }
        else if !viewRecord.isHidden{
            coachMarkBodyView.hintLabel.text = L10n.wtChatRecord
        }
        else if !inputContainerView.isHidden{
            coachMarkBodyView.hintLabel.text = L10n.wtChatSendText
        }
        bodyView = coachMarkBodyView
        arrowView = nil
        
        return (bodyView: bodyView, arrowView: arrowView)
        
        
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if !viewGeneralOptions.isHidden{
            
            if self.isDinam {
                return 5
            }
            return 6
        }
        else if !viewRecord.isHidden{
            return 1
        }
        else if !inputContainerView.isHidden{
            return 1
        }
        return 0
       
    }
    
    
}
