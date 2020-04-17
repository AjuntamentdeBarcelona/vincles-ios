//
//  AgendaMonthViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class AgendaMonthViewController: UIViewController, CalendarViewDataSource, CalendarViewDelegate {

    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    var container: AgendaContainerViewController?

    var calLoaded = false
    var firstScroll = false

    lazy var agendaManager = AgendaManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configCalendar()
        setStrings()
    }

    func configCalendar(){
        calendarView.isHidden = true
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.backgroundColor = .white

    }
    
    func setStrings(){
        mondayLabel.text = L10n.agendaLunes
        tuesdayLabel.text = L10n.agendaMartes
        wednesdayLabel.text = L10n.agendaMiercoles
        thursdayLabel.text = L10n.agendaJueves
        fridayLabel.text = L10n.agendaViernes
        saturdayLabel.text = L10n.agendaSabado
        sundayLabel.text = L10n.agendaDomingo

        if UIDevice.current.userInterfaceIdiom == .phone  {
            mondayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 11.0)
            tuesdayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 11.0)
            wednesdayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 11.0)
            thursdayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 11.0)
            fridayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 11.0)
            saturdayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 11.0)
            sundayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 11.0)
            monthLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 13.0)

        }
    }
    override public var traitCollection: UITraitCollection {
        
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if calLoaded == false{
            self.calendarView.isHidden = true
        }

        
    }
    override func viewDidAppear(_ animated: Bool) {
        if calLoaded == false{
            calLoaded = true
            
            EventsLoader.load(from: self.startDate(), to: self.endDate()) { // (events:[CalendarEvent]?) in
                if let events = $0 {
                    self.calendarView.events = events
                } else {
                    // notify for access not access not granted
                }
            }
            
            
            
            
            let today = Date()
            self.calendarView.setDisplayDate(today)
            
            guard let date = calendarView.dateFromScrollViewPosition() else { return }
            
            self.displayDateOnHeader(date)
            calendarView.isHidden = false
            loadEventsFromApi()
        }
        
        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(AgendaDayViewController.notificationProcessed), name: notificationName, object: nil)
    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
        if let type = notification.userInfo?["type"] as? String, type == NOTI_MEETING_INVITATION_EVENT || type == NOTI_MEETING_CHANGED_EVENT || type == NOTI_MEETING_INVITATION_REVOKE_EVENT  || type == NOTI_MEETING_INVITATION_DELETED_EVENT || type == NOTI_MEETING_DELETED_EVENT   {
          
            calendarView.reloadData()
        }
    }
    
    
    func displayDateOnHeader(_ date: Date) {
        let month = calendarView.calendar.component(.month, from: date) // get month
        let dateFormatter = DateFormatter()
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        if(lang == "es"){
            dateFormatter.locale = Locale(identifier: "es")
        }
        else{
            dateFormatter.locale = Locale(identifier: "ca")
        }
        let monthName = dateFormatter.standaloneMonthSymbols[(month-1) % 12] // 0 indexed array
        
        let year = calendarView.calendar.component(.year, from: date)
        
        self.monthLabel.text = monthName.uppercased() + " " + String(year)
        
    }

    
    // MARK : KDCalendarDelegate
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date) {
        
        if let container = self.parent as? AgendaContainerViewController{
            container.loadAnotherDay(date: date)
        }
       
        
        
    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
      
        
    }
    
    func loadEventsFromApi(){
        guard let monthInitialDate = calendarView.dateFromScrollViewPosition() else { return }

        let agendaModelManager = AgendaModelManager()
        if let oldestMeeting = agendaModelManager.oldestMeetingDate{
            let oldestMeetingDate = Date(timeIntervalSince1970: TimeInterval(oldestMeeting / 1000))
            
            if monthInitialDate < oldestMeetingDate{
                HUDHelper.sharedInstance.showHud(message: "")
                
                getMeetings(date: monthInitialDate)
               
                
            }
           
        }
    }
    
    func getMeetings(date: Date){
        agendaManager.getMeetings(startDate: Date(), onSuccess: { (hasMoreItems) in
            if hasMoreItems{
                self.getMeetings(date: date)
            }
            else{
                self.calendarView.reloadData()
                HUDHelper.sharedInstance.hideHUD()
            }
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            
        }
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
        guard let monthInitialDate = calendarView.dateFromScrollViewPosition() else { return }
        
        if firstScroll{
          loadEventsFromApi()
        }
        else{
            firstScroll = true
        }
       
        self.displayDateOnHeader(monthInitialDate)

    }
    
    
    // MARK : Events
    
    @IBAction func onValueChange(_ picker : UIDatePicker) {
        self.calendarView.setDisplayDate(picker.date, animated: true)
    }
    
    @IBAction func goToPreviousMonth(_ sender: Any) {
        self.calendarView.goToPreviousMonth()
    }
    @IBAction func goToNextMonth(_ sender: Any) {
        self.calendarView.goToNextMonth()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
