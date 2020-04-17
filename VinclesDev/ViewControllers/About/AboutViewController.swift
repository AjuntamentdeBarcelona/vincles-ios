//
//  AboutViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Firebase

class AboutViewController: UIViewController {

    var showBackButton = true

    @IBOutlet weak var termsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configNavigationBar()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        setStrings()
        
        Analytics.setScreenName(ANALYTICS_ABOUT, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_ABOUT)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
            
            baseViewController.navTitle = L10n.sobreVincles
   
        }
    }
    
    func setStrings(){
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            termsTextView.text = L10n.sobreVinclesText(version + " (" + (Bundle.main.infoDictionary?["CFBundleVersion"] as! String) + ")")

        }

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
