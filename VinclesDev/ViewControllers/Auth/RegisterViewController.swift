//
//  RegisterViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import EventKit
import Photos
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var idiomaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var nomTF: RequiredTextField!
    @IBOutlet weak var cognomsTF: RequiredTextField!
    @IBOutlet weak var emailTF: EmailTextField!
    @IBOutlet weak var passwordTF: PasswordTextField!
    @IBOutlet weak var repeatPasswordTF: PasswordTextField!
    @IBOutlet weak var phoneTF: NumericTextField!
    @IBOutlet weak var ageDatePicker: AdultDatePicker!
    @IBOutlet weak var genreSegmentedControl: UISegmentedControl!
    @IBOutlet weak var barcelonaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var registrarAlphaButton: AlphaButton!
    @IBOutlet weak var datePickerAlertButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var fotoTitleLabel: UILabel!
    @IBOutlet weak var fotoChooseLabel: UILabel!
    @IBOutlet weak var personalDataLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var barcelonaLabel: UILabel!
    @IBOutlet weak var idiomaAlertButton: UIButton!
    @IBOutlet weak var genreAlertButton: UIButton!
    @IBOutlet weak var barcelonaAlertButton: UIButton!
    @IBOutlet weak var fotoAlertButton: UIButton!
    @IBOutlet weak var idiomaLabel: UILabel!
    @IBOutlet weak var guardarDadesLabel: UILabel!
    @IBOutlet weak var guardarDadesSwitch: UISwitch!
    
    lazy var picker = UIImagePickerController()
    lazy var pickerVideo = UIImagePickerController()

    lazy var authManager = AuthManager()
    let errorPermission = 1006

    var photoChanged = false
    
    var formValid: Bool{
        get{
            return emailTF.isValid && passwordTF.isValid && nomTF.isValid && cognomsTF.isValid && phoneTF.isValid && repeatPasswordTF.isValid && ageDatePicker.isValid && passwordTF.text! == repeatPasswordTF.text && idiomaSegmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment && genreSegmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment && barcelonaSegmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment && photoChanged
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        addDelegates()
        setStrings()
        self.setupNavigationBar(tapLogoEnabled: false)

     
     
        registrarAlphaButton.isEnabled = false
        idiomaSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        genreSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        barcelonaSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Analytics.setScreenName(ANALYTICS_REGISTER, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_REGISTER)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    func addTargets(){
        emailTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        nomTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        cognomsTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        phoneTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        repeatPasswordTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        ageDatePicker.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .valueChanged)
        repeatPasswordTF.partnerTextField = passwordTF
        passwordTF.partnerTextField = repeatPasswordTF

        datePickerAlertButton.addTarget(self, action: #selector(alertClicked(_:)), for: .touchUpInside)
        fotoAlertButton.addTarget(self, action: #selector(alertClicked(_:)), for: .touchUpInside)
        genreAlertButton.addTarget(self, action: #selector(alertClicked(_:)), for: .touchUpInside)
        idiomaAlertButton.addTarget(self, action: #selector(alertClicked(_:)), for: .touchUpInside)
        barcelonaAlertButton.addTarget(self, action: #selector(alertClicked(_:)), for: .touchUpInside)

    }

    func addDelegates(){
        picker.delegate = self
        pickerVideo.delegate = self

        emailTF.baseTextFieldDelegate = self
        passwordTF.baseTextFieldDelegate = self
        nomTF.baseTextFieldDelegate = self
        cognomsTF.baseTextFieldDelegate = self
        phoneTF.baseTextFieldDelegate = self
        repeatPasswordTF.baseTextFieldDelegate = self
    }
    
    func setStrings(){
        idiomaLabel.text = L10n.registerLanguage
        headerLabel.text = L10n.registerHeader
        nomTF.placeholder = L10n.registerName
        cognomsTF.placeholder = L10n.registerSurname
        emailTF.placeholder = L10n.registerEmail
        passwordTF.placeholder = L10n.registerPassword
        repeatPasswordTF.placeholder = L10n.registerRepeatPassword
        phoneTF.placeholder = L10n.registerPhone
        genreSegmentedControl.setTitle(L10n.registerGenderMasc, forSegmentAt: 0)
        genreSegmentedControl.setTitle(L10n.registerGenderFem, forSegmentAt: 1)
        registrarAlphaButton.setTitle(L10n.registerButton, for: .normal)
        fotoTitleLabel.text = L10n.registerFotoTitle
        fotoChooseLabel.text = L10n.registerFoto
        personalDataLabel.text = L10n.registerPersonalData
        birthLabel.text = L10n.registerBirthdate
        genreLabel.text = L10n.registerGender
        barcelonaLabel.text = L10n.registerBcn
        idiomaSegmentedControl.setTitle(L10n.registerCatala, forSegmentAt: 0)
        idiomaSegmentedControl.setTitle(L10n.registerCastellano, forSegmentAt: 1)

        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        if(lang == "es"){
            ageDatePicker.locale = Locale(identifier: "es")
        }
        else{
            ageDatePicker.locale = Locale(identifier: "ca")
        }
        guardarDadesLabel.text = L10n.loginGuardarDades

    }
    
    // MARK: Targets
    @objc func fieldsDidChange(_ sender: AnyObject) {
        registrarAlphaButton.isEnabled = formValid
        
        if let senderDatePicker = sender as? AdultDatePicker, senderDatePicker == ageDatePicker{
            datePickerAlertButton.isHidden = senderDatePicker.isValid
        }
    }

    @objc func alertClicked(_ button: UIButton) {
        switch button {
        case datePickerAlertButton:
            self.showAlert(withTitle: "", message: L10n.ageRequired)
        case fotoAlertButton:
            self.showAlert(withTitle: "", message: L10n.requiredField)
        case genreAlertButton:
            self.showAlert(withTitle: "", message: L10n.requiredField)
        case idiomaAlertButton:
            self.showAlert(withTitle: "", message: L10n.requiredField)
        case barcelonaAlertButton:
            self.showAlert(withTitle: "", message: L10n.requiredField)
        default:
            break
        }
    }
    
    
    // MARK: Photo management
    @IBAction func fotoAction(_ sender: UIButton) {
        showPhotoSheet()
    }
    
    func showPhotoSheet(){
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: L10n.registerEscogeFoto, preferredStyle: .actionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: L10n.cancelar, style: .cancel) { _ in })
        
        actionSheetController.addAction(UIAlertAction(title: L10n.registerFotoCamara, style: .default) { _ in
           
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                self.newPhotoCamera()
                
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        DispatchQueue.main.async {
                            self.newPhotoCamera()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorPopupPhoto()
                        }
                        
                    }
                })
            }
        })
        
        actionSheetController.addAction(UIAlertAction(title: L10n.registerFotoGaleria, style: .default) { _ in
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.newPhotoGallery()
                    }
                case .restricted:
                    DispatchQueue.main.async {
                        self.errorPopupGallery()
                    }
                case .denied:
                    DispatchQueue.main.async {
                        self.errorPopupGallery()
                    }
                default:
                    // place for .notDetermined - in this callback status is already determined so should never get here
                    break
                }
            }
        })
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = userImageView
            popoverController.sourceRect = userImageView.bounds
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func newPhotoCamera(){
        self.pickerVideo.allowsEditing = false
        self.pickerVideo.sourceType = .camera
        self.pickerVideo.cameraCaptureMode = .photo
        
        
        self.present(self.pickerVideo, animated: true, completion: nil)
    }
    
    func newPhotoGallery(){
        self.picker.allowsEditing = false
        self.picker.sourceType = .photoLibrary
        self.picker.modalPresentationStyle = .popover
        self.picker.popoverPresentationController?.sourceView = self.userImageView
        self.picker.popoverPresentationController?.sourceRect = self.userImageView.bounds
        
        self.present(self.picker, animated: true, completion: nil)
    }
    
    func errorPopupGallery(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.permisGaleria
        popupVC.button1Title = L10n.permisosAnarConfiguracio
        popupVC.button2Title = L10n.cancelar
        
        popupVC.view.tag = self.errorPermission
        self.present(popupVC, animated: true, completion: nil)
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
    
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        switch sender {
        case barcelonaSegmentedControl:
            barcelonaAlertButton.isHidden = true
        case genreSegmentedControl:
            genreAlertButton.isHidden = true
        case idiomaSegmentedControl:
            idiomaAlertButton.isHidden = true
        default:
            break
        }
        registrarAlphaButton.isEnabled = formValid

    }
    
    @IBAction func idiomaDidChange(_ sender: Any) {
        if self.idiomaSegmentedControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.set("ca", forKey: "i18n_language")
        }
        else{
            UserDefaults.standard.set("es", forKey: "i18n_language")
            
        }
        nomTF.reloadAlert()
        cognomsTF.reloadAlert()
        emailTF.reloadAlert()
        passwordTF.reloadAlert()
        repeatPasswordTF.reloadAlert()
        phoneTF.reloadAlert()

        setStrings()
    }
    
    // MARK: Actions
    @IBAction func registerAction(_ sender: Any) {
        let dbModelManager = DBModelManager()
        dbModelManager.removeAllItemsFromDatabase()
        
        let params = ["email": emailTF.text!, "password": passwordTF.text!, "name": nomTF.text!, "lastname": cognomsTF.text!, "birthdate": Int(ageDatePicker.date.timeIntervalSince1970), "phone": phoneTF.text!, "gender": genreSegmentedControl.selectedSegmentIndex == 0 ? "MALE": "FEMALE", "liveInBarcelona": barcelonaSegmentedControl.selectedSegmentIndex == 0 ? true: false, "photoMimeType":  "image/png"] as [String : Any]
        
        authManager.registerVinculat(params: params, image: userImageView.image!,  onSuccess: {

            let authorizationStatus = EKEventStore.authorizationStatus(for: .event);
            switch authorizationStatus {
            case .notDetermined:
                break
            case .restricted:
                break
            case .denied:
                break
            case .authorized:
                EventsLoader.removeAllEvents()
                EventsLoader.removeCalendar()

            }
            
            
            UserDefaults.standard.set(false, forKey: "pendingSendPhoto")

                if self.idiomaSegmentedControl.selectedSegmentIndex == 0 {
                    UserDefaults.standard.set("ca", forKey: "i18n_language")
                }
                else{
                    UserDefaults.standard.set("es", forKey: "i18n_language")

                }
            let validacionVC = StoryboardScene.Auth.registerValidateViewController.instantiate()
            validacionVC.saveData = self.guardarDadesSwitch.isOn
            validacionVC.params = params
            validacionVC.image = self.userImageView.image!

            self.navigationController?.pushViewController(validacionVC, animated: true)

            
        }) { (error) in
            self.showAlert(withTitle: "Error", message: error)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RegisterViewController: BaseTextFieldDelegate {
    func showAlert(alert: String) {
        self.showAlert(withTitle: "", message: alert)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let chosenImage = info[.originalImage] as! UIImage
        userImageView.image = chosenImage
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.borderWidth = 4.0
        photoChanged = true
        registrarAlphaButton.isEnabled = formValid
fotoAlertButton.isHidden = true
        dismiss(animated:true, completion: nil)
    }
   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
}

extension RegisterViewController: PopUpDelegate{
    
    
    func firstButtonClicked(popup: PopupViewController) {
        if popup.view.tag == errorPermission{
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
        if popup.view.tag == errorPermission{
            popup.dismissPopup {
                
            }
        }
        else{
            popup.dismissPopup {
              
            }
        }
        
    }
    func closeButtonClicked(popup: PopupViewController) {
        
    }
}
