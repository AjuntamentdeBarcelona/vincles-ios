/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import Foundation
import CoreData

class MenuTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usrVinclesLabel: UILabel!
    @IBOutlet weak var xarxesLabel: UILabel!
    @IBOutlet weak var iniciCellLabel: UILabel!
    @IBOutlet weak var videoTrucCellLabel: UILabel!
    @IBOutlet weak var missatgesCellLabel: UILabel!
    @IBOutlet weak var agendaCellLabel: UILabel!
    @IBOutlet weak var notesCellLabel: UILabel!
    @IBOutlet weak var configuracioCellLabel: UILabel!
    @IBOutlet weak var sobreVinclesCellLabel: UILabel!
    @IBOutlet weak var xarxesBtn: UIButton!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    
    var cellSelected:NSIndexPath?
    
    var langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var currVincle:UserVincle!
    var currentLang:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userCercle.vincleSelected != nil) {
            currVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        currentLang = checkLanguage()
        
        
    }
    
    @IBAction func logoutBtnPress(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let alert = UIAlertController(title: "\(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil))", message: "\(langBundle.localizedStringForKey("ALERT_LOGOUT_TEXT", value: nil, table: nil))", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "\(langBundle.localizedStringForKey("ALERT_LOGOUT_CONFIRM", value: nil, table: nil))", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
            
            self.resetCoreData()
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TermsConditionsVC") as! TermsConditionsVC
            self.presentViewController(vc, animated: true, completion: nil)
            
            appDelegate.window!.rootViewController = vc
            appDelegate.window!.makeKeyAndVisible()
            
            
        }))
        alert.addAction(UIAlertAction(title: "\(langBundle.localizedStringForKey("ALERT_LOGOUT_CANCEL", value: nil, table: nil))", style: UIAlertActionStyle.Default, handler: { alertAction in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if (userCercle.vincleSelected != nil) {
            currVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        let langChange = checkLanguage()
        
        if langChange != currentLang {
            langBundle = UserPreferences().bundleForLanguageSelected()
            setUI()
            currentLang = langChange
        }
        self.getVinclePhoto()
        setUI()
    }
    
    func getVinclePhoto() {
        
        if (currVincle != nil){
            if let _ = currVincle.photo {
                let imgData = Utils().imageFromBase64ToData(self.currVincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.profileImageView.image = xarxaImg
                })
            }else{
                Utils().retrieveUserVinclesProfilePhoto(currVincle, completion: { (result, imgB64) in
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.profileImageView.image = xarxaImg
                    })
                })
            }
        }
        else{
            let b64Photo = self.getDefaultPhoto()
            let imgData = Utils().imageFromBase64ToData(b64Photo)
            let xarxaImg = UIImage(data: imgData)
            self.profileImageView.image = xarxaImg
        }
    }
    
    func getDefaultPhoto() -> String {
        
        let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
        let photoData = UIImageJPEGRepresentation(xarxaImg!, 0.1)
        let bse64 = Utils().imageFromImgtoBase64(photoData!)
        
        return bse64
    }
    
    func checkLanguage() -> String {
        var lng = ""
        let nsusr = NSUserDefaults.standardUserDefaults()
        let lang = nsusr.valueForKey("language") as! [NSString:Int]
        
        if lang["CatCast"] == 0 {
            lng = "ca-ES"
        }else{
            lng = "es"
        }
        return lng
    }
    
    func setUI() {
        if(currVincle != nil){
            usrVinclesLabel.text = currVincle.alias
        }else{
            
            usrVinclesLabel.text = langBundle.localizedStringForKey("NO_USERS", value: nil, table: nil)
        }
        
        xarxesLabel.text = langBundle.localizedStringForKey("BTN_MENU_XARXES", value: nil, table: nil)
        iniciCellLabel.text = langBundle.localizedStringForKey("BTN_MENU_START", value: nil, table: nil)
        videoTrucCellLabel.text = langBundle.localizedStringForKey("BTN_MENU_VIDEOCALL", value: nil, table: nil)
        missatgesCellLabel.text = langBundle.localizedStringForKey("BTN_MENU_MESSAGES", value: nil, table: nil)
        agendaCellLabel.text = langBundle.localizedStringForKey("BTN_MENU_AGENDA", value: nil, table: nil)
        notesCellLabel.text = langBundle.localizedStringForKey("BTN_MENU_NOTES", value: nil, table: nil)
        configuracioCellLabel.text = langBundle.localizedStringForKey("BTN_MENU_CONFIGURATION", value: nil, table: nil)
        sobreVinclesCellLabel.text = langBundle.localizedStringForKey("BTN_MENU_ABOUT", value: nil, table: nil)
        logoutLabel.text = langBundle.localizedStringForKey("BTN_LOGOUT_LABEL", value: nil, table: nil)
        
        tableView.tableFooterView = UIView()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.profileImageView.layer.borderWidth = 2.0
            self.profileImageView.layer.masksToBounds = false
            self.profileImageView.layer.borderColor = UIColor.grayColor().CGColor
            self.profileImageView.layer.cornerRadius = 10
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
            self.profileImageView.clipsToBounds = true
            
        })
    }
    
    func resetCoreData (){
        
        UserCercle.deleteUserData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        cellSelected = indexPath

        switch indexPath.row {
        case 0:
            print("Inicio")
        case 1:
            print("Videollamada")
        case 2:
            print("Mensajes")
        case 3:
            print("Agenda")
        case 4:
            print("Notas")
        case 5:
            print("Configuración")
        case 6:
            print("SobreVincles")
        case 7:
            print("Logout")
        default:
            print("")
        }
        
        return true
    }
    
    @IBAction func xarxesBtnPress(sender: AnyObject) {
        
        if let _ = cellSelected {
            tableView.deselectRowAtIndexPath(cellSelected!, animated: true)
        }
    }
}
