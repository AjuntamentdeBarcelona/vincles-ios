//
//  AgendaDayViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class AgendaDayViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDatesLabel: UILabel!
    @IBOutlet weak var noDatesView: UIView!

    lazy var dataSource = MeetingsDataSource()
    var showBackButton = true
    var isToday = false
    var isTomorrow = false
    lazy var agendaManager = AgendaManager()
    lazy var agendaModelManager = AgendaModelManager()
    let deleteTag = 1001
    let deleteErrorTag = 1002
    let declineTag = 1003
    let declineErrorTag = 1004
    let acceptErrorTag = 1006
    
    var deleteMeetingId: Int?
    var declineMeetingId: Int?
    var acceptMeetingId: Int?

    var openHomeOnBack = false

    enum DayType {
        case today
        case tomorrow
        case other
    }
    
    var dayType: DayType = .other
    

    var selectedDate = Date(){
        didSet {
            if topLabel != nil{
                setTopLabel()
                
                setDataSource()
                tableView.reloadData()

            }
        }
    }

    
    
    @IBOutlet weak var topLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        noDatesLabel.text = L10n.citesNo
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        configNavigationBar()
        setDataSource()
        setTopLabel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(AgendaDayViewController.notificationProcessed), name: notificationName, object: nil)
        
        tableView.reloadData()
        if self.agendaModelManager.numberOfMeetingsOn(date: self.selectedDate) == 0{
            self.tableView.isHidden = true
            self.noDatesView.isHidden = false
        }
        else{
            self.tableView.isHidden = false
            self.noDatesView.isHidden = true
        }
    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
        if let type = notification.userInfo?["type"] as? String, type == NOTI_MEETING_INVITATION_EVENT || type == NOTI_MEETING_CHANGED_EVENT || type == NOTI_MEETING_INVITATION_REVOKE_EVENT  || type == NOTI_MEETING_INVITATION_DELETED_EVENT || type == NOTI_MEETING_DELETED_EVENT   {
            tableView.reloadData()
            if self.agendaModelManager.numberOfMeetingsOn(date: self.selectedDate) == 0{
                self.tableView.isHidden = true
                self.noDatesView.isHidden = false
            }
            else{
                self.tableView.isHidden = false
                self.noDatesView.isHidden = true
            }
        }
    }
    
    func setDataSource(){
        tableView.register(UINib(nibName: "AgendaMeetingTableViewCell", bundle: nil), forCellReuseIdentifier: "meetingCell")
        dataSource.selectedDate = selectedDate
        if agendaModelManager.numberOfMeetingsOn(date: selectedDate) == 0{
            tableView.isHidden = true
            noDatesView.isHidden = false
        }
        else{
            tableView.isHidden = false
            noDatesView.isHidden = true
        }
        dataSource.clickDelegate = self
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        
      
    }
    
    func setTopLabel(){
        let blackAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.black ] as [NSAttributedStringKey : Any]
        let redAttribute = [NSAttributedStringKey.foregroundColor: UIColor(named: .darkRed) ] as [NSAttributedStringKey : Any]
        
        // let firstString = NSMutableAttributedString(string: L10n.chatTu, attributes: blackAttribute)
        //  firstString.append(NSAttributedString(string: " \(hour)" , attributes: grayAttribute))
        
        // topLabel.attributedText = firstString
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateStyle = .long
        dateFormatterGet.timeStyle = .none
        dateFormatterGet.locale = Locale.current
        
        let dateFormatterWeekday = DateFormatter()
        dateFormatterWeekday.dateFormat = "EEEE "
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        if(lang == "es"){
            dateFormatterGet.locale = Locale(identifier: "es")
            dateFormatterWeekday.locale = Locale(identifier: "es")
        }
        else{
            dateFormatterGet.locale = Locale(identifier: "ca")
            dateFormatterWeekday.locale = Locale(identifier: "ca")
            
        }
        
        
     //   topLabel.text = dateFormatterGet.string(from: selectedDate)
        
        switch dayType {
        case .today:
            let firstString = NSMutableAttributedString(string: L10n.agendaAvui, attributes: blackAttribute)
            firstString.append(NSAttributedString(string: " \(dateFormatterWeekday.string(from: selectedDate))" , attributes: blackAttribute))
            
            firstString.append(NSAttributedString(string: " \(dateFormatterGet.string(from: selectedDate))" , attributes: redAttribute))
            topLabel.attributedText = firstString
        case .tomorrow:
            let firstString = NSMutableAttributedString(string: L10n.agendaDema, attributes: blackAttribute)
            firstString.append(NSAttributedString(string: " \(dateFormatterWeekday.string(from: selectedDate))" , attributes: blackAttribute))
            
            firstString.append(NSAttributedString(string: " \(dateFormatterGet.string(from: selectedDate))" , attributes: redAttribute))
            topLabel.attributedText = firstString
        case .other:
            let weekday = dateFormatterWeekday.string(from: selectedDate)
            let firstString = NSMutableAttributedString(string: weekday.capitalizingFirstLetter(), attributes: blackAttribute)
            
            firstString.append(NSAttributedString(string: " \(dateFormatterGet.string(from: selectedDate))" , attributes: redAttribute))
            topLabel.attributedText = firstString
            
        }
        
    }
    func configNavigationBar(){
        if let baseViewController = self.parent as? BaseViewController{
            
            if showBackButton{
                baseViewController.leftButtonTitle = L10n.volver
                baseViewController.leftButtonImage = UIImage(asset: Asset.Icons.Navigation.tornar)
                baseViewController.leftButtonHightlightedImage = UIImage(asset: Asset.Icons.Navigation.tornarHover)
            }
            
            baseViewController.leftAction = leftAction
            baseViewController.navTitle = ""
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
    
    override public var traitCollection: UITraitCollection {
        
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteCita(){
        if let deleteCitaId = deleteMeetingId{
            
            HUDHelper.sharedInstance.showHud(message: L10n.loginLoadingEnviant)
            
            agendaManager.deleteMeeting(meetingId: deleteCitaId, onSuccess: {
                self.deleteMeetingId = nil
                HUDHelper.sharedInstance.hideHUD()
                self.tableView.reloadData()
                if self.agendaModelManager.numberOfMeetingsOn(date: self.selectedDate) == 0{
                    self.tableView.isHidden = true
                    self.noDatesView.isHidden = false
                }
                else{
                    self.tableView.isHidden = false
                    self.noDatesView.isHidden = true
                }
            }, onError: { (error) in
                self.showErrorPopUp(tag: self.deleteErrorTag)
                HUDHelper.sharedInstance.hideHUD()
            })
            
        }
    }
    
    func acceptMeeting(){
        if let acceptCitaId = acceptMeetingId{
            HUDHelper.sharedInstance.showHud(message: L10n.loginLoadingEnviant)
            
            agendaManager.acceptInvitation(meetingId: acceptCitaId, onSuccess: {
                self.acceptMeetingId = nil
                HUDHelper.sharedInstance.hideHUD()
                self.tableView.reloadData()
                if self.agendaModelManager.numberOfMeetingsOn(date: self.selectedDate) == 0{
                    self.tableView.isHidden = true
                    self.noDatesView.isHidden = false
                }
                else{
                    self.tableView.isHidden = false
                    self.noDatesView.isHidden = true
                }
            }, onError: { (error) in
                self.showErrorPopUp(tag: self.acceptErrorTag)
                HUDHelper.sharedInstance.hideHUD()
            })
            
        }
        
       
    }
    
    func declineInvitation(){
        if let declineMeetingId = declineMeetingId{
            HUDHelper.sharedInstance.showHud(message: L10n.loginLoadingEnviant)

            agendaManager.declineInvitation(meetingId: declineMeetingId, onSuccess: {
                self.declineMeetingId = nil
                HUDHelper.sharedInstance.hideHUD()
                self.tableView.reloadData()
                if self.agendaModelManager.numberOfMeetingsOn(date: self.selectedDate) == 0{
                    self.tableView.isHidden = true
                    self.noDatesView.isHidden = false
                }
                else{
                    self.tableView.isHidden = false
                    self.noDatesView.isHidden = true
                }
            }, onError: { (error) in
                self.showErrorPopUp(tag: self.declineErrorTag)
                HUDHelper.sharedInstance.hideHUD()
            })
        }
        
      
    }
    
    func showErrorPopUp(tag: Int){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = tag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        popupVC.popupDescription = L10n.citaEliminarError
        popupVC.button1Title = L10n.galeriaErrorSubirReintentar
        popupVC.button2Title = L10n.termsCancel
        
        self.present(popupVC, animated: true, completion: nil)
    }
    
}

extension AgendaDayViewController: PopUpDelegate {
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            if popup.view.tag == self.deleteTag{
                self.deleteCita()
            }
            else if popup.view.tag == self.deleteErrorTag{
                self.deleteCita()
            }
            else if popup.view.tag == self.acceptErrorTag{
                self.acceptMeeting()
            }
            else if popup.view.tag == self.declineTag{
                self.declineInvitation()
            }
            else if popup.view.tag == self.declineErrorTag{
                self.declineInvitation()
            }
        }
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            if popup.view.tag == self.deleteTag{
                self.deleteMeetingId = nil
            }
            else if popup.view.tag == self.deleteErrorTag{
                self.deleteMeetingId = nil
            }
            else if popup.view.tag == self.acceptErrorTag{
                self.acceptMeetingId = nil
            }
            else if popup.view.tag == self.declineErrorTag{
                self.declineMeetingId = nil
            }
            else if popup.view.tag == self.declineTag{
                self.declineMeetingId = nil
            }
        }
    }
}

extension AgendaDayViewController: MeetingsDataSourceClickDelegate {
    func deleteMeeting(meeting: Meeting) {
        
        deleteMeetingId = meeting.id
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = deleteTag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.galeriaEliminar
        popupVC.popupDescription = L10n.citaPopUpEliminar
        popupVC.button1Title = L10n.termsAccept
        popupVC.button2Title = L10n.termsCancel
        
        self.present(popupVC, animated: true, completion: nil)
        
        
    }
    
    func editMeeting(meeting: Meeting) {
        let agendaVC = StoryboardScene.Agenda.newScheduleViewController.instantiate()
        agendaVC.meeting = meeting
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        agendaVC.showBackButton = true
        baseVC.containedViewController = agendaVC
        
        
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    func selectedMeeting(meeting: Meeting) {
        let agendaVC = StoryboardScene.Agenda.agendaEventDetailViewController.instantiate()
        agendaVC.meeting = meeting
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        agendaVC.showBackButton = true
        baseVC.containedViewController = agendaVC
        
        
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    func acceptMeeting(meeting: Meeting) {
        
        acceptMeetingId = meeting.id
        acceptMeeting()
        
        
    }
    
    func declineMeeting(meeting: Meeting) {
        
        declineMeetingId = meeting.id
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        popupVC.view.tag = declineTag
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.citaRebutjarPopUpTitle
        popupVC.popupDescription = L10n.citaPopUpRechazar
        popupVC.button1Title = L10n.termsAccept
        popupVC.button2Title = L10n.termsCancel
        
        self.present(popupVC, animated: true, completion: nil)
    }
}


