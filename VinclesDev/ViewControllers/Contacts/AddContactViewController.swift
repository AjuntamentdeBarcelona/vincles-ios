//
//  AddContactViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import ContextMenu
import Firebase

class AddContactViewController: UIViewController  {

    @IBOutlet weak var cancelarButton: HoverButton!
    @IBOutlet weak var veureCodiLabel: UILabel!
    @IBOutlet weak var veureCodiButton: HoverButton!
    @IBOutlet weak var codiLabel: UILabel!
    @IBOutlet weak var tincCodiLabel: UILabel!
    @IBOutlet weak var codiTextField: UITextField!
    @IBOutlet weak var afegirContacteButton: HoverButton!
    @IBOutlet weak var stackViewVeure: UIStackView!
    @IBOutlet weak var stackViewPosar: UIStackView!
    @IBOutlet weak var heightVeureButton: NSLayoutConstraint!
    @IBOutlet weak var heightPosarButton: NSLayoutConstraint!
    @IBOutlet weak var heightTF: NSLayoutConstraint!
    @IBOutlet weak var viewVeure: UIView!
    @IBOutlet weak var selectKinkshipButton: HoverButton!
    
    lazy var circlesManager = CirclesManager()
    lazy var profileModelManager = ProfileModelManager()
    var openHomeOnBack = false
    
    var code = ""
    
    var showBackButton = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        configNavigationBar()
        setStrings()
        
    }

    
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    func setUI(){
        

        self.codiTextField.layer.cornerRadius = 12
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            
            self.selectKinkshipButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
            veureCodiLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            tincCodiLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 14.0)
            veureCodiButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
            cancelarButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
            afegirContacteButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
            codiTextField.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
            
            
            stackViewVeure.spacing = 10.0
            stackViewPosar.spacing = 10.0
            heightVeureButton.constant = 40
            heightPosarButton.constant = 40
            codiLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 20.0)
            heightTF.constant = 40
            
        }
        
        if !profileModelManager.userIsVincle{
            viewVeure.isHidden = true
        }
        
        codiTextField.text = code
    }
    
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
            
            baseViewController.navTitle = ""
            baseViewController.leftAction = leftAction
            
        }
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
    
    func setStrings(){
        
        veureCodiLabel.text = L10n.contactsAfegirCodi
        veureCodiButton.setTitle(L10n.contactsAfegirVeureCodiButton, for: .normal)
        tincCodiLabel.text = L10n.contactsAfegirTincCodi
        selectKinkshipButton.setTitle(L10n.contactsAfegirRelacionButton, for: .normal)
        codiTextField.placeholder = L10n.contactsAfegirEscriuCodi
        afegirContacteButton.setTitle(L10n.contactsAfegirContacte, for: .normal)
        cancelarButton.setTitle(L10n.contactsAfegirCancelar, for: .normal)

    }
    
    @IBAction func backAction(_ sender: Any) {
        if let baseViewController = self.parent as? BaseViewController{
            _ = baseViewController.leftAction!()
        }
        
    }
    
    @IBAction func generateCode(_ sender: Any) {
        circlesManager.generateCode(onSuccess: { (result) in
            self.codiLabel.text = result
        }) { (error) in
            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = "Error"
            popupVC.popupDescription = error
            popupVC.button1Title = L10n.ok
            
            self.present(popupVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func selectKinkship(_ sender: UIButton) {
        
        let dropDownVC = StoryboardScene.Contacts.dropDownViewController.instantiate()
        dropDownVC.sender = self
        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: dropDownVC)
    }
    
    var selectedIndex = -1
    @IBAction func addCode(_ sender: Any) {
        
        if self.selectedIndex == -1 {
            let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
            popupVC.delegate = self
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.popupTitle = "Error"
            popupVC.popupDescription = L10n.contactsAfegirRelacionError
            popupVC.button1Title = L10n.ok
            
            self.present(popupVC, animated: true, completion: nil)
        }else{
            let relationships = [RELATION_PARTNER, RELATION_CHILD, RELATION_GRANDCHILD, RELATION_FRIEND, RELATION_VOLUNTEER, RELATION_CAREGIVER, RELATION_BROTHER, RELATION_NEPHEW, RELATION_OTHER]
            
            circlesManager.addCode(code: codiTextField.text!, relationShip: relationships[self.selectedIndex], onSuccess: {user in
                self.codiTextField.text = ""
                let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                popupVC.delegate = self
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.popupTitle = L10n.contacteAfegitTitle
                popupVC.userId = user.id
                popupVC.popupDescription = "\(L10n.contacteAfegit1)\(user.name)\(L10n.contacteAfegit2)"
                popupVC.button1Title = L10n.ok
                
                self.present(popupVC, animated: true, completion: nil)
                
                
            }) { (error) in
                let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
                popupVC.delegate = self
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.popupTitle = "Error"
                popupVC.popupDescription = error
                popupVC.button1Title = L10n.ok
                
                self.present(popupVC, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Analytics.setScreenName(ANALYTICS_ADD_CONTACTS, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_ADD_CONTACTS)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact && self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact) {
            veureCodiLabel.isHidden = false
            tincCodiLabel.isHidden = false

        }
        else{
            veureCodiLabel.isHidden = false
            tincCodiLabel.isHidden = false
        }
    }

}

extension AddContactViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        
    }
    func closeButtonClicked(popup: PopupViewController) {
        
    }
}

