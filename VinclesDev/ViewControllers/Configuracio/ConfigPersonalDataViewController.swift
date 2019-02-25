//
//  ConfigPersonalDataViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import IQKeyboardManagerSwift

class ConfigPersonalDataViewController: UIViewController {

  
    @IBOutlet weak var nomTF: RequiredTextField!
    @IBOutlet weak var cognomsTF: RequiredTextField!
    @IBOutlet weak var emailTF: OptionalTextField!
    @IBOutlet weak var usuariTF: OptionalTextField!

    @IBOutlet weak var phoneTF: NumericTextField!
    @IBOutlet weak var barcelonaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var registrarAlphaButton: AlphaButton!
    @IBOutlet weak var personalDataLabel: UILabel!
    @IBOutlet weak var barcelonaLabel: UILabel!
    
    @IBOutlet weak var nomLabel: UILabel!
    @IBOutlet weak var cognomsLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usuariLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!

    @IBOutlet weak var contrasenyaActualTF: OptionalTextField!
    @IBOutlet weak var novaContrasenyaTF: OptionalTextField!
    @IBOutlet weak var repeteixContrasenyaTF: OptionalTextField!
    @IBOutlet weak var contrasenyaActualLabel: UILabel!
    @IBOutlet weak var novaContrasenyaLabel: UILabel!
    @IBOutlet weak var repeteixContrasenyaLabel: UILabel!

    lazy var profileModelManager = ProfileModelManager()
    lazy var profileManager = ProfileManager()
    var userImage: UIImage?
    
    let retryPopupTag = 1001
    let errorPopupTag = 1002
    
    var formValid: Bool{
        get{
            return nomTF.isValid && cognomsTF.isValid && phoneTF.isValid && barcelonaSegmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        addDelegates()
        setStrings()
        registrarAlphaButton.tag = 10001
        configNavigationBar()
        registrarAlphaButton.isEnabled = formValid
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapView(_:)))
        tap.cancelsTouchesInView = false
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.view.addGestureRecognizer(tap)

        }
        
        let tapButton = UITapGestureRecognizer(target: self, action:#selector(tapButton(_:)))
        tapButton.cancelsTouchesInView = false
        registrarAlphaButton.addGestureRecognizer(tapButton)

        
    }
    
    @objc func tapButton(_ sender: UITapGestureRecognizer){
        self.guardarDades()
        self.view.endEditing(true)

    }
    
    @objc func tapView(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        IQKeyboardManager.shared.enableAutoToolbar = true
     
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        IQKeyboardManager.shared.enableAutoToolbar = false
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_CONFIGURATION_PERSONAL_DATA)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.leftButtonTitle = L10n.volver
            baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
            baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            baseViewController.navTitle = L10n.registerPersonalData
            baseViewController.leftAction = leftAction
            
        }
    }
    
    
    func leftAction(_params: Any...) -> UIViewController?{
        return self.navigationController?.popViewController(animated: true)
        
    }
    
    func addTargets(){
        emailTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        nomTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        cognomsTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
        phoneTF.addTarget(self, action: #selector(fieldsDidChange(_:)), for: .editingChanged)
      
      

    }
    
    func addDelegates(){
     
        nomTF.baseTextFieldDelegate = self
        cognomsTF.baseTextFieldDelegate = self
        phoneTF.baseTextFieldDelegate = self
    }
    
    func setStrings(){
        emailTF.autocorrectionType = .no
        nomTF.autocorrectionType = .no
        cognomsTF.autocorrectionType = .no
        phoneTF.autocorrectionType = .no
        novaContrasenyaTF.autocorrectionType = .no
        repeteixContrasenyaTF.autocorrectionType = .no
        contrasenyaActualTF.autocorrectionType = .no

        emailTF.isEnabled = false
        emailTF.isValid = true
        emailTF.rightViewMode = .never
        emailTF.placeholder = L10n.registerEmail

        usuariTF.isEnabled = false
        usuariTF.isValid = true
        usuariTF.rightViewMode = .never
        usuariTF.placeholder = L10n.configuracioAlias

        nomTF.placeholder = L10n.registerName
        cognomsTF.placeholder = L10n.registerSurname
        phoneTF.placeholder = L10n.registerPhone
  
        nomLabel.text = L10n.registerName
        cognomsLabel.text = L10n.registerSurname
        emailLabel.text = L10n.registerEmail
        usuariLabel.text = L10n.configuracioAlias
        phoneLabel.text = L10n.registerPhone

        novaContrasenyaTF.placeholder = L10n.configuracioNovaContrasenya
        repeteixContrasenyaTF.placeholder = L10n.configuracioRepeteixContrasenya
        contrasenyaActualTF.placeholder = L10n.configuracioContrasenyaActual
        novaContrasenyaTF.isValid = true
        novaContrasenyaTF.rightViewMode = .never
        repeteixContrasenyaTF.isValid = true
        repeteixContrasenyaTF.rightViewMode = .never
        contrasenyaActualTF.isValid = true
        contrasenyaActualTF.rightViewMode = .never
        
        novaContrasenyaLabel.text = L10n.configuracioNovaContrasenya
        repeteixContrasenyaLabel.text = L10n.configuracioRepeteixContrasenya
        contrasenyaActualLabel.text = L10n.configuracioContrasenyaActual

        registrarAlphaButton.setTitle(L10n.configuracioTamanyGuardar, for: .normal)
   
        personalDataLabel.text = L10n.registerPersonalData
    
        barcelonaLabel.text = L10n.registerBcn
        
        if let user = profileModelManager.getUserMe(){
            
            barcelonaSegmentedControl.selectedSegmentIndex = 1
            if user.liveInBarcelona{
                barcelonaSegmentedControl.selectedSegmentIndex = 0
            }
            
            nomTF.text = user.name
            cognomsTF.text = user.lastname
            phoneTF.text = user.phone
            usuariTF.text = user.username
            emailTF.text = user.email
            if user.email.isEmpty{
                emailTF.text = " "
            }
            emailTF.checkValid()
            nomTF.checkValid()
            cognomsTF.checkValid()
            phoneTF.checkValid()

            usuariTF.textColor = UIColor(named: .darkGray)
            emailTF.textColor = UIColor(named: .darkGray)
            
            let profileModelManager = ProfileModelManager()
            if !profileModelManager.userIsVincle{
                usuariTF.text = user.email
            }
        }
        
        
    }
    
    // MARK: Targets
    @objc func fieldsDidChange(_ sender: AnyObject) {
        registrarAlphaButton.isEnabled = formValid
      
    }
    
    @objc func alertClicked(_ button: UIButton) {
       
    }
    
    func guardarDades(){
        profileManager.updateUser(name: nomTF.text!, lastname: cognomsTF.text!, phone: phoneTF.text!, liveInBarcelona: barcelonaSegmentedControl.selectedSegmentIndex == 0, onSuccess: {
            if (self.novaContrasenyaTF.text?.isEmpty)!{
                self.navigationController?.popViewController(animated: true)
            }
            else{
                if self.novaContrasenyaTF.text != self.repeteixContrasenyaTF.text{
                    let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                    popupVC.delegate = self
                    popupVC.view.tag = self.errorPopupTag
                    popupVC.modalPresentationStyle = .overCurrentContext
                    popupVC.popupTitle = "Error"
                    popupVC.popupDescription = L10n.configuracioContrasenyaNoCoincideixen
                    popupVC.button1Title = L10n.ok
                    
                    self.present(popupVC, animated: true, completion: nil)
                }
                else if (self.contrasenyaActualTF.text?.isEmpty)!{
                    let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                    popupVC.delegate = self
                    popupVC.view.tag = self.errorPopupTag
                    popupVC.modalPresentationStyle = .overCurrentContext
                    popupVC.popupTitle = "Error"
                    popupVC.popupDescription = L10n.configuracioFaltaContrasenyaActual
                    popupVC.button1Title = L10n.ok
                    
                    self.present(popupVC, animated: true, completion: nil)
                }
                else{
                    self.self.profileManager.changePassword(newPassword: self.novaContrasenyaTF.text!, currentPassword: self.contrasenyaActualTF.text!, onSuccess: {
                        
                        self.checkKeychain()
                       
                        self.navigationController?.popViewController(animated: true)

                    }, onError: { (error) in
                        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                        popupVC.delegate = self
                        popupVC.modalPresentationStyle = .overCurrentContext
                        popupVC.popupTitle = "Error"
                        popupVC.popupDescription = error
                        popupVC.button1Title = L10n.ok
                        popupVC.view.tag = self.errorPopupTag

                        self.present(popupVC, animated: true, completion: nil)

                    })
                }

            }
        }) { (error) in
            self.showRetryPopup()
        }
        
        
    }
    
    func checkKeychain(){
        let keychainManager = KeychainManager()
        
        let (email, password) = keychainManager.getCredentials()
        
        if let email = email, let _ = password{
            keychainManager.saveCredentials(email: email, password: self.novaContrasenyaTF.text!)
        }
        
    }
    
    @IBAction func registerAction(_ sender: Any) {
       guardarDades()
    }
    
    
    func showRetryPopup(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = "Error"
        popupVC.popupDescription = L10n.configGuardarError
        popupVC.view.tag = self.retryPopupTag

        popupVC.button1Title = L10n.galeriaErrorSubirReintentar
        popupVC.button2Title = L10n.termsCancel
      
        self.present(popupVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ConfigPersonalDataViewController: PopUpDelegate{
    
 
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            if popup.view.tag == self.retryPopupTag{
                self.guardarDades()
            }
        }

    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
    }
    
}


extension ConfigPersonalDataViewController: BaseTextFieldDelegate {
    func showAlert(alert: String) {
        self.showAlert(withTitle: "", message: alert)
    }
}
