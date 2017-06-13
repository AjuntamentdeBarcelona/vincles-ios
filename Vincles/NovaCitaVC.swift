/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/
 
 import UIKit
 import SVProgressHUD
 
 class NovaCitaVC: VinclesVC, UITableViewDataSource,UITableViewDelegate,UITextViewDelegate {
    
    @IBOutlet weak var descripcioLabel: UILabel!
    @IBOutlet weak var duradaLabel: UILabel!
    @IBOutlet weak var horaLabel: UILabel!
    @IBOutlet weak var horarisLabel: UILabel!
    @IBOutlet weak var diaLabel: UILabel!
    @IBOutlet weak var duradaBtn: UIButton!
    @IBOutlet weak var foldTableView: UITableView!
    @IBOutlet weak var descripCitaTextView: UITextView!
    @IBOutlet weak var diaCitaDatePicker: UIDatePicker!
    @IBOutlet weak var horaIniciDatePicker: UIDatePicker!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var horarisOcupatsLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var sendBtnTitle: UILabel!
    @IBOutlet weak var sendBtnImg: UIImageView!
    @IBOutlet weak var backNavBtn: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var usrVincle:UserVincle!
    

    var duradaCita = 30
    var isEditingCita = false
    
    var duradesCita = [30,60,90,120,150,180,210,240,270,300,330,360,390,420,450,480]
    
    var currentCita:Cita?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = NOVACITA_VC
        if (userCercle.vincleSelected != nil) {
            usrVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        addDoneButtonToKeyboard(descripCitaTextView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NovaCitaVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NovaCitaVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        setUI()
        setupCitaData()
        
        let bundle =  UserPreferences().bundleForLanguageSelected()
        
        if ((bundle.resourcePath?.rangeOfString("ca-ES.lproj")) == nil) {
            diaCitaDatePicker.locale = NSLocale(localeIdentifier: "es_ES")
        } else {
            diaCitaDatePicker.locale = NSLocale(localeIdentifier: "ca_ES")
        }
        
        diaLabel.text = langBundle.localizedStringForKey("DIA_LABEL", value: nil, table: nil)
        horarisLabel.text = langBundle.localizedStringForKey("HORARIS_LABEL", value: nil, table: nil)
        horaLabel.text = langBundle.localizedStringForKey("HORA_LABEL", value: nil, table: nil)
        duradaLabel.text = langBundle.localizedStringForKey("DURADA_LABEL", value: nil, table: nil)
        descripcioLabel.text = langBundle.localizedStringForKey("DESCRIPCIO_LABEL", value: nil, table: nil)
        
        
    }
    
    func getHorarisOcupats(from:NSDate,to:NSDate) {
        horarisOcupatsLabel.text = ""
        var str = ""
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        
        let citesDay = Cita.loadCitesDataFromCoreData(usrVincle.idCalendar!, from: from, to: to)
        
        for dat in citesDay {
            
            let toDate = calendar.dateByAddingUnit(.Minute, value: Int(dat.duration!)!,
                                                   toDate:  dat.date!, options: [])
            if dat == citesDay.last! {
                str += " \(hourFormatter.stringFromDate(dat.date!))-\(hourFormatter.stringFromDate(toDate!))"
            }else{
                str += " \(hourFormatter.stringFromDate(dat.date!))-\(hourFormatter.stringFromDate(toDate!))   "
            }
            horarisOcupatsLabel.text = str
        }
    }
    
    func setupCitaData() {
        
        let today = Utils().getCurrentLocalDate()
        
        if (currentCita != nil) {
            print("EVENT SELECTED ID \(currentCita!.id!)")
            diaCitaDatePicker.date = currentCita!.date!
            diaCitaDatePicker.minimumDate = today
            horaIniciDatePicker.date = currentCita!.date!
            descripCitaTextView.text = currentCita!.descript!
            duradaCita = Int(currentCita!.duration!)!
            duradaBtn.setTitle("\(duradaCita) mins",forState:.Normal)
            isEditingCita = true
            viewTitle.text = langBundle.localizedStringForKey("EDIT_APPOINTMENT_TITLE", value: nil, table: nil)
            
            let startDay = Utils().getStartOfDay(currentCita!.date!)
            let endDay = Utils().getEndOfDay(currentCita!.date!)
            getHorarisOcupats(startDay, to:endDay)
            
        }else{
            diaCitaDatePicker.date = today
            horaIniciDatePicker.date = today
            diaCitaDatePicker.minimumDate = today
            descripCitaTextView.text = ""
            duradaCita = duradesCita[1]
            duradaBtn.setTitle("\(duradaCita) mins",forState:.Normal)
            isEditingCita = false
            viewTitle.text = langBundle.localizedStringForKey("BTN_NEW_APPOINTMENT_AGENDA", value: nil, table: nil)
            
            let startDay = Utils().getStartOfDay(diaCitaDatePicker.date)
            let endDay = Utils().getEndOfDay(diaCitaDatePicker.date)
            getHorarisOcupats(startDay, to:endDay)
        }
    }
    
    func setUI() {
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        foldTableView.delegate = self
        foldTableView.dataSource = self
        descripCitaTextView.delegate = self
        duradaBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)
        duradaBtn.layer.cornerRadius = 4.0

    }
    
    override func viewWillDisappear(animated: Bool) {
        
        SVProgressHUD.dismiss()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return duradesCita.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(duradesCita[indexPath.row]) mins"
        cell.textLabel?.font = cell.textLabel?.font.fontWithSize(15)
        return cell
    }
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let cell = foldTableView.cellForRowAtIndexPath(indexPath)
        duradaBtn.setTitle(cell?.textLabel?.text,forState:.Normal)
        foldTableView.hidden = true
        duradaCita = duradesCita[indexPath.row]
        
        return false
    }
    
    func addDoneButtonToKeyboard(txtView:UITextView) {
        
        let doneToolBar = UIToolbar(frame: CGRectMake(0,0,320,50))
        doneToolBar.barStyle = .Default
        doneToolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                             UIBarButtonItem.init(title:langBundle.localizedStringForKey("KEYBOARD_DONE_BTN", value: nil, table: nil), style: .Done, target: self, action: #selector(doneButtonClickedDismissKeyboard))]
        doneToolBar.sizeToFit()
        descripCitaTextView.inputAccessoryView = doneToolBar
    }
    
    func doneButtonClickedDismissKeyboard() {
        descripCitaTextView.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                
                let insets: UIEdgeInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, keyboardSize.height, 0)
                
                self.scrollView.contentInset = insets
                self.scrollView.scrollIndicatorInsets = insets
                self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + keyboardSize.height)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let insets: UIEdgeInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, 0, 0)
        
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y)
    }
    
    func updateButtonSend(enabled:Bool) {
        
        if enabled {
            sendBtn.enabled = true
            sendBtn.alpha = 1
            sendBtnTitle.alpha = 1
            sendBtnImg.alpha = 1
        }else{
            sendBtn.enabled = false
            sendBtn.alpha = 0.4
            sendBtnTitle.alpha = 0.4
            sendBtnImg.alpha = 0.4
        }
    }
    
    
    @IBAction func enviarNovaCitaPressed(sender: UIButton) {
        let dateCombined = Utils().combineDateWithTime(diaCitaDatePicker.date, time: horaIniciDatePicker.date)
        let nowDate = Utils().getCurrentLocalDate()
        
        if dateCombined!.isGreaterThanDate(nowDate) && descripCitaTextView != "" {
            if isEditingCita {
                updateCita()
            }else{
                sendNewCita()
            }
        }else{
            let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message: langBundle.localizedStringForKey("ALERTA_CITA_BEFORE_CURRENT_TIME", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backBarBtnPress(sender: UIBarButtonItem) {
        
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKindOfClass(InicioTableViewController) {
                    let initVC = viewController as! InicioTableViewController
                    initVC.viewNameLbl.text = initVC.langBundle.localizedStringForKey("INIT_NAVBAR_TITLE", value: nil, table: nil)
                }
            }
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func sendNewCita() {
        
        if descripCitaTextView.text != "" {
            updateButtonSend(false)
            let dateCombined = Utils().combineDateWithTime(diaCitaDatePicker.date, time: horaIniciDatePicker.date)
            let date = Utils().milliSecondsSince1970(dateCombined!)
            
            let params:[String:AnyObject] = ["date":Double(date),
                                             "duration":duradaCita,
                                             "description":descripCitaTextView.text]
            SVProgressHUD.show()
            VinclesApiManager.sharedInstance.addEventToAgenda(params, idCalendar:Int(usrVincle.idCalendar!)!) { (result,eventID) in
                
                if result == "SUCCESS" {
                    SVProgressHUD.dismiss()
                    
                    let newCita = Cita.createBlankCitaEntity()
                    newCita.calendarId = self.usrVincle.idCalendar!
                    newCita.id = eventID
                    newCita.date = dateCombined!
                    newCita.duration = String(self.duradaCita)
                    newCita.descript = self.descripCitaTextView.text
                    newCita.state = EVENT_STATE_PENDING
                    
                    Cita.saveCitesContext()
                    
                    // create Sent Event to InitFeed
                    let initFeedParams:[String:AnyObject] =
                        ["date":Utils().getCurrentLocalDate(),
                         "type":INIT_CELL_EVENT_SENT,
                         "id":eventID,
                         "idUsrVincles":self.usrVincle.idCalendar!,
                         "isRead":false]
                    InitFeed.addNewFeedEntityOffline(initFeedParams)
                    
                    
                    self.backToAgendaVC()
                }
                if result == "FAILURE" {
                    SVProgressHUD.dismiss()
                    self.updateButtonSend(true)
                    let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ERROR_CITA_CREATE", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_INPUT_DESCRIPTION", value: nil, table: nil))
            updateButtonSend(true)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func updateCita() {
        
        if descripCitaTextView.text != "" {
            updateButtonSend(false)
            let dateCombined = Utils().combineDateWithTime(diaCitaDatePicker.date, time: horaIniciDatePicker.date)
            let date = Utils().milliSecondsSince1970(dateCombined!)
            
            let parameters:[String:AnyObject] = ["date":Double(date),
                                                 "duration":duradaCita,
                                                 "description":descripCitaTextView.text]
            
            SVProgressHUD.show()
            VinclesApiManager.sharedInstance.updateAgendaEvent(parameters,idCalendar:Int(usrVincle.idCalendar!)!,idEvent:Int(currentCita!.id!)!,completion: {(status) in
                
                if status == "SUCCESS" {
                    SVProgressHUD.dismiss()
                    
                    self.currentCita?.date = dateCombined
                    self.currentCita?.descript = self.descripCitaTextView.text
                    self.currentCita?.duration = String(self.duradaCita)
                    
                    Cita.saveCitesContext()
                    
                    self.backToAgendaVC()
                }
                if status == "FAILURE" {
                    SVProgressHUD.dismiss()
                    self.updateButtonSend(true)
                    let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ERROR_CITA_EDIT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
            
        }else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_INPUT_DESCRIPTION", value: nil, table: nil))
            updateButtonSend(true)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func backToAgendaVC() {
        
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Agenda
            self.presentViewController(secondViewController, animated: true, completion:nil)
        }
    }
    
    @IBAction func navBarCallBtnPress(sender: UIBarButtonItem) {
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Trucant
            SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
            self.presentViewController(secondViewController, animated: true, completion:nil)
        }
    }
    
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        
        print("DATE CHANGED \(sender.date)")
        
        let startDay = Utils().getStartOfDay(sender.date)
        let endDay = Utils().getEndOfDay(sender.date)
        getHorarisOcupats(startDay, to:endDay)
        
    }
    @IBAction func horaIniciDatePress(sender: UIDatePicker) {
        
        
    }
    
    @IBAction func duradaBtnPressed(sender: UIButton) {
        
        if foldTableView.hidden {
            foldTableView.hidden = false
        }else{
            foldTableView.hidden = true
        }
    }
 }
