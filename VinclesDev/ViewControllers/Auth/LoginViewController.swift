//
//  LoginViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import SlideMenuControllerSwift
import EventKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: RequiredTextField!
    @IBOutlet weak var passwordTF: RequiredTextField!
    @IBOutlet weak var loginButton: AlphaButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var guardarDadesLabel: UILabel!
    @IBOutlet weak var guardarDadesSwitch: UISwitch!
    
    lazy var keychainManager = KeychainManager()
    
    var hideBack = false
    
    var formValid: Bool{
        get{
            return emailTF.isValid && passwordTF.isValid
        }
    }
    
    lazy var authManager = AuthManager()
    lazy var libraryManager = GalleryManager()
    lazy var mediaManager = MediaManager()
    lazy var profileManager = ProfileManager()
    lazy var notificationsManager = NotificationManager()
    lazy var notificationsModelManager = NotificationsModelManager()
    lazy var circlesManager = CirclesManager()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager()
    lazy var profileModelManager = ProfileModelManager()
    lazy var agendaManager = AgendaManager()

    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dbModelManager = DBModelManager()
      //  dbModelManager.removeAllItemsFromDatabase()

        
        self.slideMenuController()?.removeLeftGestures()
        
        self.setupNavigationBar(tapLogoEnabled: false)
        
        addDelegates()
        addTargets()
        setStrings()
        
        checkKeychain()
        // Test agenda
      //   emailTF.text = "guites52"
     //    passwordTF.text = "G2anXY5ql61ç"
     //    loginButton.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
            self.navigationItem.setHidesBackButton(true, animated: false)
            setStrings()
            emailTF.reloadAlert()
            passwordTF.reloadAlert()
        
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_LOGIN)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDelegates(){
        emailTF.baseTextFieldDelegate = self
        passwordTF.baseTextFieldDelegate = self
    }
    
    func addTargets(){
        emailTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setStrings(){
        guardarDadesLabel.text = L10n.loginGuardarDades
        headerLabel.text = L10n.loginHeader
        descriptionLabel.text = L10n.loginDescription
        emailTF.placeholder = L10n.loginEmail
        passwordTF.placeholder = L10n.loginPassword
        forgotButton.setTitle(L10n.loginForgot, for: .normal)
        loginButton.setTitle(L10n.loginEntrar, for: .normal)
        registerButton.setTitle(L10n.loginRegistrar, for: .normal)
    }
    
    // MARK: Targets
    @objc func textFieldDidChange(_ textField: UITextField) {
        loginButton.isEnabled = formValid
    }
    
    // MARK: Actions
    @IBAction func loginAction(_ sender: Any) {
       //    emailTF.text = "adminvincle"
         //  passwordTF.text = "p4ssw0rd"

        let dbModelManager = DBModelManager()
        dbModelManager.removeAllItemsFromDatabase()
        
       Timer.after(0.2.seconds) {
            HUDHelper.sharedInstance.showHud(message: L10n.loginLoadingEnviant)

        
        let authorizationStatus = EKEventStore.authorizationStatus(for: .event);
        switch authorizationStatus {
        case .notDetermined:
            print("notDetermined");
        case .restricted:
            print("restricted");
        case .denied:
            print("denied");
        case .authorized:
            EventsLoader.removeAllEvents()
            EventsLoader.removeCalendar()

        }
        

            self.authManager.login(email: self.emailTF.text!, password: self.passwordTF.text!, onSuccess: { () in

                self.getProfile()
                
                
            }) { (error) in
                HUDHelper.sharedInstance.hideHUD()
                self.showAlert(withTitle: "Error", message: error)
            }
       }
      
    }

    func managerError(){
        let dbModelManager = DBModelManager()
        dbModelManager.removeAllItemsFromDatabase()

        HUDHelper.sharedInstance.hideHUD()

        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        popupVC.popupDescription = L10n.loginErrorRecuperant

        popupVC.button1Title = L10n.ok

        self.present(popupVC, animated: true, completion: nil)
        
    }
    
    func getProfile(){
        print("LOGIN 1")

        HUDHelper.sharedInstance.showHud(message: L10n.loginLoadingRecuperant)

        let profileManager = ProfileManager()
        profileManager.getSelfProfile(onSuccess: {
            
            self.getGalleryItems()

        }) { (error) in
            self.managerError()
        }
    }
    
    func getGalleryItems(){
        print("LOGIN 2")

        libraryManager.fromDate = nil
        libraryManager.getContentsLibrary(onSuccess: { (hasMoreItems, needsReload) in
            if hasMoreItems{
                self.getGalleryItems()
            }
            else{
                self.getCirclesUser()
                
            }
        }) { (error) in
              self.managerError()
            //  self.getCirclesUser()

        }
    }
    
    func getCirclesUser(){
        print("LOGIN 3")

        circlesManager.getCirclesUser(onSuccess: { needsReload in
            if self.profileModelManager.userIsVincle{
                self.circlesManager.getGroupsUser(onSuccess: { needsReloadGroups in
                    self.getMissatgesChatsUser()
                }, onError: { (error) in
                    
                })
            }
            else{
                self.getMissatgesChatsUser()
            }
            
        }, onError: { (error) in
            self.managerError()
        })
    }
    
    func getMissatgesChatsUser(){
        print("LOGIN 4")

        let chatManager = ChatManager()
        chatManager.getAllChatUserMessages(onSuccess: {
            if self.profileModelManager.userIsVincle{
                self.getParticipantsGroup()
            }
            else{
                self.getServerTime()

            }
        }) { (error) in
            self.managerError()
        }
    }
    
    func getParticipantsGroup(){
        print("LOGIN 5")

        let circlesManager = CirclesManager()
        circlesManager.getAllGroupsParticipants(onSuccess: {
            self.getMissatgesChatsGroup()
            
        }) { (error) in
            self.managerError()
        }
    }
    
    
    func getMissatgesChatsGroup(){
        let chatManager = ChatManager()
        chatManager.getAllChatGroupMessages(onSuccess: {
            self.getMissatgesChatsDinamitzadors()

        }) { (error) in
            self.managerError()
        }
    }
    
   
    
    func getMissatgesChatsDinamitzadors(){
        let chatManager = ChatManager()
        chatManager.getAllChatDinamitzadorsMessages(onSuccess: {
           self.getServerTime()
        }) { (error) in
            self.managerError()
        }
    }
    
    func getMeetings(){

        agendaManager.getMeetings(onSuccess: { (hasMoreItems) in
            if hasMoreItems{
                self.getMeetings()
            }
            else{
              
                
                ApiClient.sendMigrationStatus(onSuccess: {
                    
                    UserDefaults.standard.set(true, forKey: "loginDone")
                    self.manageKeychainData()
                    HUDHelper.sharedInstance.hideHUD()
//                    self.navigationController?.pushViewController(StoryboardScene.Main.homeViewController.instantiate(), animated: true)
                    self.navigationController?.viewControllers = [StoryboardScene.Main.homeViewController.instantiate()]

                }, onError: { (error) in
                    HUDHelper.sharedInstance.hideHUD()
                    self.managerError()
                })
                
              //  AlarmSingleton.sharedInstance.setupAlarm()

            }
        }) { (error) in
            self.managerError()

        }
    }
    
   
    
    func getServerTime(){
        notificationsManager.getServerTime(onSuccess: {
            self.notificationsManager.setWatchedNotifications()
            self.getMeetings()
        }) {
            self.managerError()
        }
    }
    
    
    func checkKeychain(){
        let (email, password) = keychainManager.getCredentials()
        
        if let email = email, let password = password{
            emailTF.text = email
            passwordTF.text = password
            guardarDadesSwitch.setOn(true, animated: false)
            loginButton.isEnabled = formValid
            emailTF.checkValid()
            passwordTF.checkValid()

        }
        
    }
    
    
    func manageKeychainData(){
        if guardarDadesSwitch.isOn{
            keychainManager.saveCredentials(email: emailTF.text!, password: passwordTF.text!)
        }
        else{
            keychainManager.removeCredentials()
        }
    }
    
    
    @IBAction func registerAction(_ sender: Any) {
        self.navigationController?.pushViewController(StoryboardScene.Auth.registerViewController.instantiate(), animated: true)
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        self.navigationController?.pushViewController(StoryboardScene.Auth.forgotPasswordViewController.instantiate(), animated: true)
    }
}

extension LoginViewController: BaseTextFieldDelegate {
    func showAlert(alert: String) {
        self.showAlert(withTitle: "", message: alert)
    }
}

extension LoginViewController: PopUpDelegate {
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
    }
    

}
