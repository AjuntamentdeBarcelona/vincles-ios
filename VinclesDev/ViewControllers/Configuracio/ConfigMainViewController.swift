//
//  ConfigMainViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class ConfigMainViewController: UIViewController {
    
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var fotoTitleLabel: UILabel!
    @IBOutlet weak var fotoChooseLabel: UILabel!
    @IBOutlet weak var idiomaLabel: UILabel!
    @IBOutlet weak var idiomaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var userDataLabel: UILabel!
    @IBOutlet weak var personalDataLabel: UILabel!
    @IBOutlet weak var tamanyLabel: UILabel!
    @IBOutlet weak var tamanySegmentedControl: UISegmentedControl!
    @IBOutlet weak var sincronitzarLabel: UILabel!
    @IBOutlet weak var sincronitzarSegmentedControl: UISegmentedControl!
    @IBOutlet weak var descarregaLabel: UILabel!
    @IBOutlet weak var descarregaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var galeriaLabel: UILabel!
    @IBOutlet weak var galeriaSegmentedControl: UISegmentedControl!
    
    lazy var picker = UIImagePickerController()
    lazy var pickerVideo = UIImagePickerController()
    
    lazy var authManager = AuthManager()
    lazy var profileModelManager = ProfileModelManager()
    lazy var profileManager = ProfileManager()
    lazy var notificationsManager = NotificationManager()
    
    var photoChanged = false
    var showBackButton = true
    
    var lastImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        addDelegates()
        
        self.setupNavigationBar(tapLogoEnabled: false)
        configNavigationBar()
        setImage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStrings()
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_CONFIGURATION)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func addTargets(){
        
        
        
        
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
            
            baseViewController.navTitle = L10n.configuracio
            baseViewController.leftAction = leftAction
            
        }
    }
    
    
    func leftAction(_params: Any...) -> UIViewController?{
        return self.navigationController?.popViewController(animated: true)
        
    }
    
    func addDelegates(){
        picker.delegate = self
        pickerVideo.delegate = self
        
    }
    
    func setImage(){
        self.userImageView.layer.borderColor = UIColor.white.cgColor
        self.userImageView.layer.borderWidth = 4.0
        if let user = profileModelManager.getUserMe(){
            let mediaManager = MediaManager()
            userImageView.tag = user.id
            
            mediaManager.setProfilePicture(userId: user.id, imageView: userImageView) {
                
            }
        }
    }
    
    func setStrings(){
        fotoTitleLabel.text = L10n.registerFotoTitle
        fotoChooseLabel.text = L10n.registerFoto
        idiomaLabel.text = L10n.registerLanguage
        personalDataLabel.text = L10n.registerPersonalData
        tamanyLabel.text = L10n.configuracioTamany
        descarregaLabel.text = L10n.condifuracioDescarrega
        idiomaSegmentedControl.setTitle(L10n.registerCatala, forSegmentAt: 0)
        idiomaSegmentedControl.setTitle(L10n.registerCastellano, forSegmentAt: 1)
        galeriaLabel.text = L10n.configuracioGaleria

        if let lang = UserDefaults.standard.value(forKey: "i18n_language") as? String, lang == "ca"{
            self.idiomaSegmentedControl.selectedSegmentIndex = 0
        }
        else{
            self.idiomaSegmentedControl.selectedSegmentIndex = 1
        }
        
        
        if let user = profileModelManager.getUserMe(){
            print(user.email)
            let resiString = user.liveInBarcelona ? L10n.configuracioResident : L10n.configuracioNoResident
            userDataLabel.text = "\(user.username)\n\(user.name) \(user.lastname)\n\(user.phone)\n\(resiString)"   
        }
        
        tamanySegmentedControl.setTitle(L10n.configuracioTamanyPetit, forSegmentAt: 0)
        tamanySegmentedControl.setTitle(L10n.configuracioTamanyMitja, forSegmentAt: 1)
        tamanySegmentedControl.setTitle(L10n.configuracioTamanyGran, forSegmentAt: 2)
        
        sincronitzarLabel.text = L10n.configuracioSincronitzar
        
        
        if UserDefaults.standard.value(forKey: "tamanyLletra") == nil{
            UserDefaults.standard.set("MITJA", forKey: "tamanyLletra")
        }
        
        if let tamany = UserDefaults.standard.value(forKey: "tamanyLletra") as? String{
            if tamany == "PETIT"{
                tamanySegmentedControl.selectedSegmentIndex = 0
            }
            else if tamany == "MITJA"{
                tamanySegmentedControl.selectedSegmentIndex = 1
            }
            else if tamany == "GRAN"{
                tamanySegmentedControl.selectedSegmentIndex = 2
            }
        }
        
        sincronitzarSegmentedControl.selectedSegmentIndex = 1
        if UserDefaults.standard.bool(forKey: "sincroCalendari"){
            sincronitzarSegmentedControl.selectedSegmentIndex = 0
        }
        
        
        
        descarregaSegmentedControl.selectedSegmentIndex = 0
        if UserDefaults.standard.bool(forKey: "manualDownload"){
            descarregaSegmentedControl.selectedSegmentIndex = 1
        }
        
        galeriaSegmentedControl.selectedSegmentIndex = 0
        if !UserDefaults.standard.bool(forKey: "saveToCameraRoll"){
            galeriaSegmentedControl.selectedSegmentIndex = 1
        }
        
    }
    
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        switch sender {
        case tamanySegmentedControl:
            if tamanySegmentedControl.selectedSegmentIndex == 0{
                UserDefaults.standard.set("PETIT", forKey: "tamanyLletra")
            }
            else if tamanySegmentedControl.selectedSegmentIndex == 1{
                UserDefaults.standard.set("MITJA", forKey: "tamanyLletra")
            }
            else if tamanySegmentedControl.selectedSegmentIndex == 2{
                UserDefaults.standard.set("GRAN", forKey: "tamanyLletra")
            }
        case sincronitzarSegmentedControl:
            if sincronitzarSegmentedControl.selectedSegmentIndex == 0{
                UserDefaults.standard.set(true, forKey: "sincroCalendari")
                EventsLoader.syncAllMeetings()
            }
            else if sincronitzarSegmentedControl.selectedSegmentIndex == 1{
                UserDefaults.standard.set(false, forKey: "sincroCalendari")
                EventsLoader.removeAllEvents()
                EventsLoader.removeCalendar()

            }
        case idiomaSegmentedControl:
            if self.idiomaSegmentedControl.selectedSegmentIndex == 0 {
                UserDefaults.standard.set("ca", forKey: "i18n_language")
            }
            else{
                UserDefaults.standard.set("es", forKey: "i18n_language")
                
            }
            configNavigationBar()
            
            if let baseViewController = self.parent as? BaseViewController{
                baseViewController.setupNavigationBar(barButtons: true, tapLogoEnabled: true)
                
            }
            setStrings()
        case descarregaSegmentedControl:
            if self.descarregaSegmentedControl.selectedSegmentIndex == 0 {
                UserDefaults.standard.set(false, forKey: "manualDownload")
            }
            else{
                UserDefaults.standard.set(true, forKey: "manualDownload")
                
            }
        case galeriaSegmentedControl:
            if self.galeriaSegmentedControl.selectedSegmentIndex == 0 {
                UserDefaults.standard.set(true, forKey: "saveToCameraRoll")
            }
            else{
                UserDefaults.standard.set(false, forKey: "saveToCameraRoll")
                
            }
        default:
            break
        }
        
        
    }
    
    // MARK: Photo management
    @IBAction func fotoAction(_ sender: UIButton) {
        showPhotoSheet()
    }
    
    func showPhotoSheet(){
        
        lastImage = userImageView.image
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: L10n.registerEscogeFoto, preferredStyle: .actionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: L10n.cancelar, style: .cancel) { _ in })
        
        actionSheetController.addAction(UIAlertAction(title: L10n.registerFotoCamara, style: .default) { _ in
            self.pickerVideo.allowsEditing = false
            self.pickerVideo.sourceType = .camera
            self.pickerVideo.cameraCaptureMode = .photo
            
            
            self.present(self.pickerVideo, animated: true, completion: nil)
            
        })
        
        actionSheetController.addAction(UIAlertAction(title: L10n.registerFotoGaleria, style: .default) { _ in
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.picker.modalPresentationStyle = .popover
            self.picker.popoverPresentationController?.sourceView = self.userImageView
            self.picker.popoverPresentationController?.sourceRect = self.userImageView.bounds
            
            self.present(self.picker, animated: true, completion: nil)
        })
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = userImageView
            popoverController.sourceRect = userImageView.bounds
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func idiomaDidChange(_ sender: Any) {
        if self.idiomaSegmentedControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.set("ca", forKey: "i18n_language")
        }
        else{
            UserDefaults.standard.set("es", forKey: "i18n_language")
            
        }
        configNavigationBar()
        
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.setupNavigationBar(barButtons: true, tapLogoEnabled: true)
            
        }
        setStrings()
    }
    
    
    @IBAction func editDataAction(_ sender: Any) {
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Configuracio.configPersonalDataViewController.instantiate()
        detailVC.userImage = userImageView.image
        
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendPhoto(){
        
        let mediaManager = MediaManager()
        
        if let image = userImageView.image{
            HUDHelper.sharedInstance.showHud(message: L10n.loginLoadingEnviant)

            self.profileManager.changeUserPhoto(photo: image, onSuccess: {
                HUDHelper.sharedInstance.hideHUD()

                if let user = self.profileModelManager.getUserMe(){
                    mediaManager.removeProfilePicture(userId: user.id)
                    self.getNotifications()
                }
                
            }, onError: { (error) in
                HUDHelper.sharedInstance.hideHUD()

                self.showRetryPopup()
                
            })
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
    
    func showRetryPopup(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.configGuardarError
        
        popupVC.button1Title = L10n.galeriaErrorSubirReintentar
        popupVC.button2Title = L10n.termsCancel
        
        self.present(popupVC, animated: true, completion: nil)
    }
    
}

extension ConfigMainViewController: BaseTextFieldDelegate {
    func showAlert(alert: String) {
        self.showAlert(withTitle: "", message: alert)
    }
}

extension ConfigMainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DispatchQueue.main.async { [unowned self] in
            let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.userImageView.image = chosenImage
            self.userImageView.layer.borderColor = UIColor.white.cgColor
            self.userImageView.layer.borderWidth = 4.0
            self.photoChanged = true
            self.sendPhoto()
        }
        
        
        dismiss(animated:true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
}

extension ConfigMainViewController: PopUpDelegate{
    
    
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            self.sendPhoto()
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            if self.lastImage != nil{
                self.userImageView.image = self.lastImage!
            }
            else{
                self.userImageView.image = UIImage()
            }
        }
    }
    
}
