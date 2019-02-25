//
//  LeftMenuTableViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import SlideMenuControllerSwift

enum LeftMenu: Int {
    case main = 0
    case contacts
    case notifications
    case calendar
    case gallery
    case settings
    case about
    case logout
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftMenuTableViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var userLabel: UILabel!
    lazy var authManager = AuthManager()
    lazy var profileManager = ProfileManager()
    lazy var authModelManager = AuthModelManager()
    lazy var profileModelManager = ProfileModelManager()

    var menus = [L10n.principal, L10n.contactos, L10n.notificaciones, L10n.calendario , L10n.homeFotos, L10n.configuracion, L10n.sobreVincles, L10n.salir]
    lazy var mainViewController = StoryboardScene.Main.homeViewController.instantiate()

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapProfile)))
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("MenuOpen"), object: nil)
        menus = [L10n.principal, L10n.contactos, L10n.notificaciones, L10n.calendario , L10n.homeFotos, L10n.configuracion, L10n.sobreVincles, L10n.salir]
        getProfile()
        tableView.reloadData()
    }
    
    func getProfile(){
        if authModelManager.hasUser{
            profileManager.getSelfProfileNoValidation(onSuccess: {
                self.configHeader()
            }) { (error) in
                
            }
        }
      
    }

    func configHeader(){
        if let user = profileModelManager.getUserMe(){
            userLabel.text = "\(user.name)"
            
            let mediaManager = MediaManager()
            userImageView.tag = user.id
            mediaManager.setProfilePicture(userId: user.id, imageView: userImageView) {
                
            }
        }
    }
    
    func configUI(){
        userImageView.image = UIImage()
        userLabel.text = ""
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.borderWidth = 3.0
        self.tableView.backgroundColor = UIColor(named: .darkGray)
    }

    @objc func tapProfile() {
        self.closeLeft()

        if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
            let baseVC = StoryboardScene.Base.baseViewController.instantiate()
            let configVC = StoryboardScene.Configuracio.configMainViewController.instantiate()
            configVC.showBackButton = false
            baseVC.containedViewController = configVC
            nav.pushViewController(baseVC, animated: true)
        }
    }
    
    func changeViewController(_ menu: LeftMenu) {
        self.closeLeft()
        switch menu {
        case .main:
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.setViewControllers([mainViewController], animated: true)
            }
        case .gallery:
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                let galleryVC = StoryboardScene.Gallery.galleryViewController.instantiate()
                galleryVC.showBackButton = false
                baseVC.containedViewController = galleryVC
                nav.pushViewController(baseVC, animated: true)
            }
        case .contacts:
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                let contactsVC = StoryboardScene.Contacts.contactsViewController.instantiate()
                contactsVC.showBackButton = false
                baseVC.containedViewController = contactsVC
                nav.pushViewController(baseVC, animated: true)
            }
        case .settings:
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                let configVC = StoryboardScene.Configuracio.configMainViewController.instantiate()
                configVC.showBackButton = false
                baseVC.containedViewController = configVC
                nav.pushViewController(baseVC, animated: true)
            }
        case .calendar:
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                let calVC = StoryboardScene.Agenda.agendaContainerViewController.instantiate()
                calVC.showBackButton = false
                baseVC.containedViewController = calVC
                nav.pushViewController(baseVC, animated: true)
            }
        case .notifications:
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                let calVC = StoryboardScene.Notifications.notificationsViewController.instantiate()
                calVC.showBackButton = false
                baseVC.containedViewController = calVC
                nav.pushViewController(baseVC, animated: true)
            }
        case .about :
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let baseVC = StoryboardScene.Base.baseViewController.instantiate()
                let calVC = StoryboardScene.About.aboutViewController.instantiate()
                calVC.showBackButton = false
                baseVC.containedViewController = calVC
                nav.pushViewController(baseVC, animated: true)
            }
        case .logout:
            logout()
        default:
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                nav.pushViewController(mainViewController, animated: true)
            }
            
        }
    }
    
    func logout(){
        
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.logoutPopupTitle
        popupVC.popupDescription = L10n.logoutPopupDesc
        popupVC.button1Title = L10n.logoutPopupButton1
        popupVC.button2Title = L10n.logoutPopupButton2
        
        self.present(popupVC, animated: true, completion: nil)
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        var image = UIImage()
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .main:
                image = UIImage(asset: Asset.Icons.Menu.menuInici)
            case .calendar:
                image = UIImage(asset: Asset.Icons.Menu.menuCalendari)
            case .contacts:
                image = UIImage(asset: Asset.Icons.Menu.menuXarxes)
            case .gallery:
                image = UIImage(asset: Asset.Icons.Menu.menuGaleria)
            case .logout:
                image = UIImage(asset: Asset.Icons.Menu.menuLogout)
            case .notifications:
                image = UIImage(asset: Asset.Icons.Menu.menuNotifications)
            case .settings:
                image = UIImage(asset: Asset.Icons.Menu.menuConfiguracio)
            case .about:
                image = UIImage(asset: Asset.Icons.Menu.menuSobrevincles)
            }
        }
        cell.configWith(title: menus[indexPath.row], image: image)
        
        return cell
    }
    
    // MARK: - Scroll view delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.slideMenuController()?.leftPanGesture?.isEnabled = false
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.slideMenuController()?.leftPanGesture?.isEnabled = true
        
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate){
            self.slideMenuController()?.leftPanGesture?.isEnabled = true
        }
        
    }
    
}


extension LeftMenuTableViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }
        
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        self.closeLeft()
        UserDefaults.standard.set(false, forKey: "loginDone")

        let notificationManager = NotificationManager()
        notificationManager.deleteLocalNotifications()
        
        AlarmSingleton.sharedInstance.stop()
        
        authManager.logout(onSuccess: {
            
            popup.dismissPopup {
            }
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let loginVC = StoryboardScene.Auth.loginViewController.instantiate()
                loginVC.hideBack = true
                nav.viewControllers = [loginVC]
//                nav.pushViewController(loginVC, animated: true)
                UserDefaults.standard.set(false, forKey: "loginDone")

            }
        }) { (error) in
            popup.dismissPopup {
            }
            if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                let loginVC = StoryboardScene.Auth.loginViewController.instantiate()
                loginVC.hideBack = true
                nav.pushViewController(loginVC, animated: true)
                UserDefaults.standard.set(false, forKey: "loginDone")

            }
            
        }
        
        
    }
    
}
