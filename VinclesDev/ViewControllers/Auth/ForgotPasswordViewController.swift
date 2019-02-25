//
//  ForgotPasswordViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTF: EmailTextField!
    @IBOutlet weak var loginButton: AlphaButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    var authManager = AuthManager()

    var formValid: Bool{
        get{
            return emailTF.isValid
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(tapLogoEnabled: false)

        addDelegates()
        addTargets()
        addStrings()
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_FORGOT_PASSWORD)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func addDelegates(){
        emailTF.baseTextFieldDelegate = self
    }
    
    func addTargets(){
        emailTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func addStrings(){
        headerLabel.text = L10n.forgotHeader
        loginButton.setTitle(L10n.forgotButton, for: .normal)
        emailTF.placeholder = L10n.forgotEmail
    }
    
    // MARK: Targets
    @objc func textFieldDidChange(_ textField: UITextField) {
        loginButton.isEnabled = formValid
    }
    
    // MARK: Actions
    @IBAction func loginAction(_ sender: Any) {
        authManager.recoverPassword(email: emailTF.text!, onSuccess: { () in
            let actionSheetController: UIAlertController = UIAlertController(title: L10n.forgotButton, message: L10n.forgotAlert, preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                self.navigationController?.popViewController(animated: true)
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }) { (error) in
            self.showAlert(withTitle: "Error", message: error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ForgotPasswordViewController: BaseTextFieldDelegate {
    func showAlert(alert: String) {
        self.showAlert(withTitle: "", message: alert)
    }
}
