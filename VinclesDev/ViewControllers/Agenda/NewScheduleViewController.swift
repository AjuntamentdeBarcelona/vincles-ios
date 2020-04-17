//
//  NewScheduleViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import NextGrowingTextView
import Firebase

class NewScheduleViewController: UIViewController, ProfileImageManagerDelegate {
 
    
    var showBackButton = true

    @IBOutlet weak var crearCitaButton: HoverButton!
    @IBOutlet weak var titleTextView: NextGrowingTextView!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var labelInici: UILabel!
    @IBOutlet weak var labelIniciDate: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var labelDuration: UILabel!
    @IBOutlet weak var labelDurationValue: UILabel!
    @IBOutlet weak var tableDuration: UITableView!
    @IBOutlet weak var invitarButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    var minutesDuration = 60
    var meeting: Meeting?
    
    var selectedContacts = [User]()
    lazy var dataSource = AgendaCitaContactsDataSource()
    lazy var agendaManager = AgendaManager()

    var firstLoaded = false
    
    var preloadDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStrings()
        setFonts()
        configNavigationBar()
        setUI()
        setDateLabel()
        setDurationLabel()
        configDataSources()
        setExistingData()
        setPreloadedDate()

    }

    override func viewWillAppear(_ animated: Bool) {
        ProfileImageManager.sharedInstance.delegate = self
        
        Analytics.setScreenName(ANALYTICS_AGENDA_NEW_EVENT, screenClass: nil)
//        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
//        tracker.set(kGAIScreenName, value: ANALYTICS_AGENDA_NEW_EVENT)
//        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
//        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func didDownload(userId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? CitaContactsCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }
        
    }
    
    func didError(userId: Int) {
        for cell in collectionView.visibleCells{
            if let inCell = cell as? CitaContactsCollectionViewCell, inCell.userId == userId{
                inCell.setAvatar()
            }
        }
    }
    override func viewDidLayoutSubviews() {

    }
    override func viewDidAppear(_ animated: Bool) {
        if !firstLoaded{
            firstLoaded = true
            setExistingCV()
        }

    }
    override public var traitCollection: UITraitCollection {
        
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setFonts()
    }
    
    func configDataSources(){
        collectionView.register(UINib(nibName: "CitaContactsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contactCell")
        setCollectionViewColumns()
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource.clickDelegate = self
        dataSource.users = selectedContacts
        dataSource.circlesGroupsModelManager = CirclesGroupsModelManager.shared
        dataSource.profileModelManager = ProfileModelManager()
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
    
    func setFonts(){
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
            crearCitaButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 20.0)
            
        }
        else{
            crearCitaButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)
        }
    }
    
    func setUI(){
        titleTextView.layer.borderWidth = 1.0
        titleTextView.layer.borderColor = UIColor(named: .darkGray).cgColor
        titleTextView.textView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        titleTextView.textView.font = UIFont(font: FontFamily.Akkurat.regular, size: 18.0)
        titleTextView.textView.textColor = UIColor(named: .darkGray)
        titleTextView.textView.backgroundColor = .white
        titleTextView.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        titleTextView.placeholderAttributedText = NSAttributedString(string: L10n.nuevaCitaPlaceholder,
                                                                     attributes: [NSAttributedString.Key.font: self.titleTextView.textView.font!,
                                                                                  NSAttributedString.Key.foregroundColor: UIColor(named: .darkGray) ])
        
        titleTextView.maxNumberOfLines = 10
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(tapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        viewDate.layer.borderWidth = 1.0
        viewDate.layer.borderColor = UIColor(named: .darkGray).cgColor
        
        datePicker.minimumDate = Date()
        self.datePicker.addTarget(self, action: #selector(dateTimeChanged), for: .valueChanged);

        viewDuration.layer.borderWidth = 1.0
        viewDuration.layer.borderColor = UIColor(named: .darkGray).cgColor
        invitarButton.titleLabel?.numberOfLines = 2
        
        
    }
    
    func setExistingData(){
        if let meeting = meeting{
            titleTextView.textView.text = meeting.descrip
            datePicker.setDate(Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000)), animated: false)
            minutesDuration = meeting.duration
            setDurationLabel()
            crearCitaButton.setTitle(L10n.editarLaCita, for: .normal)
            
            setDateLabel()
        }
   
    }
    
    func setPreloadedDate(){
        if let preloadedDate = preloadDate{
            if preloadedDate > Date(){
                datePicker.setDate(preloadedDate, animated: false)
                setDateLabel()
            }
        }
        
    }
    
    func setExistingCV(){
        selectedContacts = [User]()
        if let meeting = meeting{
         
            for guest in meeting.guests{
                if let user = guest.userInfo{
                    selectedContacts.append(user)
                }
            }
        }
        dataSource.users = selectedContacts
        collectionView.reloadData()
        collectionView.setNeedsLayout()
        
        collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        
    }
    
    func setStrings(){
        crearCitaButton.setTitle(L10n.crearCita, for: .normal)
        labelInici.text = L10n.iniciCita
        labelDuration.text = L10n.duracionCita

        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        if(lang == "es"){
            datePicker.locale = Locale(identifier: "es")
        }
        else{
            datePicker.locale = Locale(identifier: "ca")
        }
        
        invitarButton.setTitle(L10n.convidarCita, for: .normal)
        invitarButton.setImage( UIImage(asset: Asset.Icons.Agenda.convidarAtresHover), for: .highlighted)

    }
    
    @objc func dateTimeChanged(){
        setDateLabel()
    }
    
    func setDateLabel(){
        let dateFormatter = DateFormatter()
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        if(lang == "es"){
            dateFormatter.locale = Locale(identifier: "es")
        }
        else{
            dateFormatter.locale = Locale(identifier: "ca")
        }
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        labelIniciDate.text = dateFormatter.string(from: datePicker.date)
    }
    
    func setDurationLabel(){
        switch minutesDuration {
        case 30:
            labelDurationValue.text = L10n.duracionMediaHora
        case 60:
            labelDurationValue.text = L10n.duracionUnaHora
        case 90:
            labelDurationValue.text = L10n.duracionHoraMedia
        case 120:
            labelDurationValue.text = L10n.duracionDosHoras
        default:
            break
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
       
         
        }
    }
    

    func leftAction(_params: Any...) -> UIViewController?{
        return self.navigationController?.popViewController(animated: true)
    }
    
    func rightAction(_params: Any...) -> UIViewController?{
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Agenda.newScheduleViewController.instantiate()
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
        return nil
        
    }
    
    @objc func tapView(){
        self.view.endEditing(true)
    }
    
    @IBAction func convidarContactes(_ sender: Any) {
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Agenda.agendaContactsViewController.instantiate()
        detailVC.delegate = self
        detailVC.selectedUsers = selectedContacts
        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NewScheduleViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "durationCell", for: indexPath)
        cell.accessoryType = .none
      
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = L10n.duracionMediaHora
            if minutesDuration == 30{
                cell.accessoryType = .checkmark
            }
        case 1:
            cell.textLabel?.text = L10n.duracionUnaHora
            if minutesDuration == 60{
                cell.accessoryType = .checkmark
            }
        case 2:
            cell.textLabel?.text = L10n.duracionHoraMedia
            if minutesDuration == 90{
                cell.accessoryType = .checkmark
            }
        case 3:
            if minutesDuration == 120{
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = L10n.duracionDosHoras
        default:
            break
        }
        cell.textLabel?.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 16.0)

        cell.subviews.forEach({
            if let btn = $0 as? UIButton {
                btn.subviews.forEach({
                    if let imageView = $0 as? UIImageView {
                        let image = imageView.image?.withRenderingMode(.alwaysTemplate)
                        imageView.image = image
                        imageView.tintColor = UIColor(named: .darkRed)
                    }
                })
            }
        })
        
        
        for case let button as UIButton in cell.subviews {
            let image = button.backgroundImage(for: .normal)?.withRenderingMode(.
                alwaysTemplate)
            button.setBackgroundImage(image, for: .normal)
        }
        cell.tintColor = UIColor(named: .darkRed)

        cell.accessoryView?.tintColor = UIColor(named: .darkRed)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            minutesDuration = 30
        case 1:
            minutesDuration = 60
        case 2:
            minutesDuration = 90
        case 3:
            minutesDuration = 120
        default:
            break
        }
        tableView.reloadData()
        setDurationLabel()

    }
    
    @IBAction func createMeeting(_ sender: Any) {
        if titleTextView.textView.text.isEmpty{
            showMandatoryPopUp()
        }
        else{
            saveMeeting()
        }
      
    }
    
    func saveMeeting(){
        HUDHelper.sharedInstance.showHud(message: L10n.loginLoadingEnviant)
        
        if let meeting = meeting{
            let ids = selectedContacts.map { $0.id }
            
            
            agendaManager.editMeeting(meetingId: meeting.id, date: Int64(datePicker.date.timeIntervalSince1970 * 1000), duration: minutesDuration, description: titleTextView.textView.text, inviteTo: ids, onSuccess: {
                self.navigationController?.popViewController(animated: true)
                HUDHelper.sharedInstance.hideHUD()
            }) { (error) in
                HUDHelper.sharedInstance.hideHUD()
                self.showErrorPopUp()
                
            }
            
            
        }
        else{
            let ids = selectedContacts.map { $0.id }
            
            
            agendaManager.createMeeting(date: Int64(datePicker.date.timeIntervalSince1970 * 1000), duration: minutesDuration, description: titleTextView.textView.text, inviteTo: ids, onSuccess: {
                
                
                self.navigationController?.popViewController(animated: true)
                HUDHelper.sharedInstance.hideHUD()
                
            }) { (error) in
                HUDHelper.sharedInstance.hideHUD()
                self.showErrorPopUp()
            }
        }
    }
    
    func showErrorPopUp(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()

        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        popupVC.popupDescription = L10n.citaGuardarError
        popupVC.button1Title = L10n.galeriaErrorSubirReintentar
        popupVC.button2Title = L10n.termsCancel
        popupVC.view.tag = 1001
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func showMandatoryPopUp(){
        let popupVC = StoryboardScene.Popup.popupViewController.instantiate()
        
        popupVC.delegate = self
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.popupTitle = L10n.appName
        popupVC.popupDescription = L10n.novaCitaTitleObligatorio
        popupVC.button1Title = L10n.ok
        popupVC.view.tag = 1002
        self.present(popupVC, animated: true, completion: nil)
    }
}

extension NewScheduleViewController: PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
            if popup.view.tag == 1001{
                self.saveMeeting()
            }
        }
    }
    
    func secondButtonClicked(popup: PopupViewController) {
        popup.dismissPopup {
        }

    }
    func closeButtonClicked(popup: PopupViewController) {
        
    }
    
}

extension NewScheduleViewController: AgendaContactsViewControllerDelegate{
    func selectedContacts(users: [User]) {
        selectedContacts = users
        dataSource.users = selectedContacts
        collectionView.reloadData()
        collectionView.setNeedsLayout()
   
        collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height


    }
    
    
}

extension NewScheduleViewController: AgendaCitaContactsDataSourceClickDelegate{
    func showRemovePopup(item: User) {
        if let index = selectedContacts.index(of: item){
            selectedContacts.remove(at: index)
            dataSource.users = selectedContacts
            collectionView.reloadData()
            collectionView.setNeedsLayout()
            
            collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        }
    }
    
}
