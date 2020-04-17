//
//  AgendaEventDetailViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Firebase

class AgendaEventDetailViewController: UIViewController, ProfileEventImageManagerDelegate {

    var showBackButton = true
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var labelDescripcio: UILabel!
    @IBOutlet weak var labelHora: UILabel!
    @IBOutlet weak var labelCreador: UILabel!
    @IBOutlet weak var labelTitCreador: UILabel!

    @IBOutlet weak var imageCreador: CircularImageView!

    @IBOutlet weak var convidatsLabel: UILabel!
    @IBOutlet weak var dataHoraLabel: UILabel!
    @IBOutlet weak var detallsCitaLabel: UILabel!
    
    var meeting: Meeting!
    lazy var dataSource = MeetingGuestsDataSource()
    var openHomeOnBack = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        setUI()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileEventImageManager.sharedInstance.delegate = self
        
        Analytics.setScreenName(ANALYTICS_AGENDA_EVENT_DETAIL, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_AGENDA_EVENT_DETAIL)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configDataSources()

        let notificationName = Notification.Name(NOTIFICATION_PROCESSED)
        NotificationCenter.default.addObserver(self, selector: #selector(AgendaDayViewController.notificationProcessed), name: notificationName, object: nil)
        

    }
    
    @objc func notificationProcessed(_ notification: NSNotification){
        if let type = notification.userInfo?["type"] as? String, type == NOTI_MEETING_INVITATION_EVENT || type == NOTI_MEETING_CHANGED_EVENT || type ==  NOTI_MEETING_ACCEPTED_EVENT || type == NOTI_MEETING_REJECTED_EVENT  || type == NOTI_MEETING_INVITATION_DELETED_EVENT {
            setUI()
            collectionView.reloadData()
            collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height

        }
        else if let type = notification.userInfo?["type"] as? String, type == NOTI_MEETING_INVITATION_REVOKE_EVENT || type == NOTI_MEETING_DELETED_EVENT,  let idMeeting = notification.userInfo?["idMeeting"] as? Int  {
            if idMeeting == meeting.id{
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
   
    override public var traitCollection: UITraitCollection {
        
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    func didDownloadEvent(userId: Int) {
        setUI()
        
        for cell in collectionView.visibleCells{
            if let inCell = cell as? EventGuestCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }
    }
    
    func didErrorEvent(userId: Int) {
        setUI()
        
        for cell in collectionView.visibleCells{
            if let inCell = cell as? EventGuestCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }
    }
    
    func setUI(){
      
        convidatsLabel.text = L10n.citaDetallConvidats
        dataHoraLabel.text = L10n.citaDetallDataHora
        detallsCitaLabel.text = L10n.citaDetallDetallCita
        
        if let tamanyLletra = UserDefaults.standard.value(forKey: "tamanyLletra") as? String{
            switch tamanyLletra{
            case "PETIT":
                detallsCitaLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(SMALL_FONT_CHAT))
                convidatsLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(SMALL_FONT_CHAT))
                
                dataHoraLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(SMALL_FONT_CHAT))
                labelTitCreador.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(SMALL_FONT_CHAT))

                labelDescripcio.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(SMALL_FONT_CHAT))
                labelHora.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(SMALL_FONT_CHAT))
                labelCreador.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(SMALL_FONT_CHAT))


            case "MITJA":
                
                detallsCitaLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(MEDIUM_FONT_AGENDA))
                convidatsLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(MEDIUM_FONT_AGENDA))
                
                dataHoraLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(MEDIUM_FONT_AGENDA))
                labelTitCreador.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(MEDIUM_FONT_AGENDA))
                
                labelDescripcio.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(MEDIUM_FONT_AGENDA))
                labelHora.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(MEDIUM_FONT_AGENDA))
                labelCreador.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(MEDIUM_FONT_AGENDA))
                
              
                

            case "GRAN":
                
                detallsCitaLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(BIG_FONT_CHAT))
                convidatsLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(BIG_FONT_CHAT))
                
                dataHoraLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(BIG_FONT_CHAT))
                labelTitCreador.font = UIFont(font: FontFamily.AkkuratBold.bold, size: CGFloat(BIG_FONT_CHAT))
                
                labelDescripcio.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(BIG_FONT_CHAT))
                labelHora.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(BIG_FONT_CHAT))
                labelCreador.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(BIG_FONT_CHAT))

            default:
                break
            }
        }
        
        
        
        viewDetails.backgroundColor = .white
        viewDetails.layer.borderWidth = 1.0
        viewDetails.layer.borderColor = UIColor(named: .darkGray).cgColor
       
        labelDescripcio.text = meeting.descrip
        
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: lang!)
        
        let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
        
        let calendar = Calendar.current
        if let endDate = calendar.date(byAdding: .minute, value: meeting.duration, to: initDate){
            
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
            let weekday = dateFormatterWeekday.string(from: initDate)

            labelHora.text = weekday.capitalizingFirstLetter() + " " + dateFormatterGet.string(from: initDate) + "\n" + dateFormatter.string(from: initDate) + " a " + dateFormatter.string(from: endDate)
            
        }
        
        if let creador = meeting.hostInfo{
            labelCreador.text = creador.name + " " + creador.lastname
            
            if let url = ProfileEventImageManager.sharedInstance.getProfilePicture(userId: creador.id, meetingId: meeting.id), let image = UIImage(contentsOfFile: url.path){
                imageCreador.image = image
            }
            else{
                imageCreador.image = UIImage(named: "perfilplaceholder")
            }
            
           
        }
        
        if meeting.guests.count == 0{
            convidatsLabel.isHidden = true
        }
        else{
            convidatsLabel.isHidden = false
        }
    }
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "EventGuestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contactCell")
        setCollectionViewColumns()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource

        dataSource.meeting = meeting
       
        if meeting.guests.count == 0{
            convidatsLabel.isHidden = true
        }
        else{
            convidatsLabel.isHidden = false
        }
        collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        
    }
    
    func setCollectionViewColumns(){
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            dataSource.columns = 3
        }
        else  if UIDevice.current.userInterfaceIdiom == .pad {
            dataSource.columns = 4
        }
        else if UIDevice.current.userInterfaceIdiom == .phone && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            dataSource.columns = 2
        }
        else  if UIDevice.current.userInterfaceIdiom == .phone{
            dataSource.columns = 3
        }
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
            
          //  baseViewController.rightButtonTitle = L10n.agendaNuevaCita
          //  baseViewController.rightButtonImage = UIImage(asset: Asset.Icons.Agenda.novaCita)
          //  baseViewController.rightButtonHightlightedImage = UIImage(asset: Asset.Icons.Agenda.novaCitaHover)
            
          //  baseViewController.rightAction = rightAction
          

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
