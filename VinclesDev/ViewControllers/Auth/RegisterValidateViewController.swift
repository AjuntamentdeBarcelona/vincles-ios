//
//  RegisterValidateViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SlideMenuControllerSwift

class RegisterValidateViewController: UIViewController {

    @IBOutlet weak var codiTF: RequiredTextField!
    @IBOutlet weak var validateButton: AlphaButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    
    var params: [String:Any]?
    var image: UIImage?
    var saveData = false
    
    lazy var authManager = AuthManager()
    lazy var profileManager = ProfileManager()
    lazy var mediaManager = MediaManager()
    lazy var libraryManager = GalleryManager()
    lazy var keychainManager = KeychainManager()

    var formValid: Bool{
        get{
            return codiTF.isValid
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(tapLogoEnabled: false)

        addDelegates()
        addTargets()
        setStrings()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_REGISTER_VALIDATE)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func addDelegates(){
        codiTF.baseTextFieldDelegate = self
    }

    func addTargets(){
        codiTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setStrings(){
        headerLabel.text = L10n.validacionHeader
        descriptionLabel.text = L10n.validacionDescripcion
        codiTF.placeholder = L10n.validacionPlaceholder
        validateButton.setTitle(L10n.validacionValidar, for: .normal)
        resendButton.setTitle(L10n.validacionReenviar, for: .normal)
    }
    
    // MARK: Targets
    @objc func textFieldDidChange(_ textField: UITextField) {
        validateButton.isEnabled = formValid
    }
    
    @IBAction func validarAction(_ sender: Any) {
        authManager.validateRegister(email: params!["email"] as! String, code: codiTF.text!.keepNumericsOnly , onSuccess: {
            /*
            let loginVC = StoryboardScene.Auth.loginViewController.instantiate()
            UserDefaults.standard.set(true, forKey: "pendingSendPhoto")
            loginVC.hideBack = true
             self.navigationController?.pushViewController(loginVC, animated: true)
 */
            self.doAutomaticLogin()
        }) { (error) in
            self.showAlert(withTitle: "Error", message: error)
        }
    }
    
    func doAutomaticLogin(){
        HUDHelper.sharedInstance.showHud(message: L10n.cargando)
        
        authManager.login(email: params!["email"] as! String, password: params!["password"] as! String, onSuccess: { () in
            self.getProfile()
            
            
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            self.showAlert(withTitle: "Error", message: error)
        }
    }
    
    func getProfile(){
        
        profileManager.getSelfProfile(onSuccess: {
            self.sendPhoto()
            
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
        }
    }
    
    
    func sendPhoto(){
        let mediaManager = MediaManager()
        
        mediaManager.getUserPhotoRegister(onCompletion: { (image) in
            if let image = image{
                self.profileManager.changeUserPhoto(photo: image, onSuccess: {
                    self.getServerTime()
                    
                }, onError: { (error) in

                    
                })
            }
            
        })
        
        
    }
    
    func getServerTime(){
        let notificationsManager = NotificationManager()
        notificationsManager.getServerTime(onSuccess: {
            self.manageKeychainData()
            HUDHelper.sharedInstance.hideHUD()
            self.navigationController?.pushViewController(StoryboardScene.Main.homeViewController.instantiate(), animated: true)
            
        }) {

        }
    }
    
    @IBAction func reenviarAction(_ sender: Any) {
        authManager.registerVinculat(params: params!, image: image!,  onSuccess: {
            
            
        }) { (error) in
            self.showAlert(withTitle: "Error", message: error)
        }
    }
    
    func manageKeychainData(){
        if saveData{
            keychainManager.saveCredentials(email: params!["email"] as! String!, password: params!["password"] as! String)
        }
        else{
            keychainManager.removeCredentials()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension RegisterValidateViewController: BaseTextFieldDelegate {
    func showAlert(alert: String) {
        self.showAlert(withTitle: "", message: alert)
    }
}
