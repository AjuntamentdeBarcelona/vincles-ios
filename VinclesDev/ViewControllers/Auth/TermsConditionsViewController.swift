//
//  TermsConditionsViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class TermsConditionsViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.slideMenuController()?.removeLeftGestures()

        setStrings()
        self.setupNavigationBar(tapLogoEnabled: false)
    }

   
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)

        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_TERMS)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.termsTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setStrings(){
        headerLabel.text = L10n.termsHeader
        termsTextView.text = L10n.termsText
        cancelButton.setTitle(L10n.termsCancel, for: .normal)
        acceptButton.setTitle(L10n.termsAccept, for: .normal)
    }
    
    @IBAction func acceptarAction(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "termsApproved")
        self.navigationController?.pushViewController(StoryboardScene.Auth.loginViewController.instantiate(), animated: true)
    }
    
    
    @IBAction func cancelarAction(_ sender: Any) {
        self.showAlert(withTitle: "Alerta", message: L10n.termsMustAccept, button: L10n.termsOk)
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
