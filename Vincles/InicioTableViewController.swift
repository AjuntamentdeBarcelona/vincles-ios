/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import CoreData

class InicioTableViewController: VinclesTableVC {
    
    
    @IBOutlet var inicioTableView: UITableView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var trucadaBarItem: UIBarButtonItem!
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkBtn: UIButton!
    @IBOutlet weak var noNetworkLabel: UILabel!
    @IBOutlet weak var noNetworkText: UILabel!
    
    var refresh: UIRefreshControl!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var userVincle:UserVincle!
    
    var viewNameLbl:UILabel!
    var vincleImgView:UIImageView = {
        
        return UIImageView(frame: CGRectMake(0, 0, 40, 40))
    }()
    
    @nonobjc var initFeed:[InitFeed] = []
    var sections:[[NSDate:[InitFeed]]]!
    var feedsPerDate:[[InitFeed]] = []
    var sectionDates:[NSDate] = []
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = INICIOTABLE_VC
        if  (userCercle.vincleSelected != nil) {
            noNetworkView.hidden = true
            noNetworkView.frame = CGRectMake(0 , 0, self.view.frame.width, 0)
            
            userVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        getVinclePhoto()
        
        
        //Set UI
        noNetworkLabel.text = self.langBundle.localizedStringForKey("BTN_NEW_USER_LABEL", value: nil, table: nil)
        noNetworkText.text = self.langBundle.localizedStringForKey("NO_USERS_TEXT", value: nil, table: nil)

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(InicioTableViewController.refreshFromBackGround), name:
            UIApplicationWillEnterForegroundNotification, object: nil)

        tableView.registerNib(UINib.init(nibName:"cellType1", bundle: nil),
                              forCellReuseIdentifier: "cellType1")
        tableView.registerNib(UINib.init(nibName:"cellType2", bundle: nil),
                              forCellReuseIdentifier: "cellType2")
        tableView.registerNib(UINib.init(nibName:"cellType3", bundle: nil),
                              forCellReuseIdentifier: "cellType3")
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(InicioTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresh)
        
        if (userCercle.vincleSelected != nil){
            if SingletonVars.sharedInstance.isFirstAppLoad == true {
                VinclesApiManager().loginSelfUserWithCompletion(userCercle.username!, pwd: userCercle.password!, usrId: userCercle.id!, completion: { (result) in
                    
                    if result == "Logged" {
                    }
                    if result == "Error login" {
                    }
                })
                SingletonVars.sharedInstance.isFirstAppLoad = false
            }
            
            if SingletonVars.sharedInstance.initMenuHasToChange && self.revealViewController() != nil  {
                changeInitialVC(SingletonVars.sharedInstance.initDestination)
            }
            checkIncomingCita()
            loadFeedsFromCoreData()
            
        }
        setNavBar()
        
        if  (userCercle.vincleSelected != nil){
            print("CERCLE USR == \(userCercle.username!) PASS \(userCercle.password!) CERCLE ID \(userCercle.id!) ")
        }
    }
    

    
    
    override func viewDidAppear(animated: Bool) {
        
        tableView.reloadData()
    }
    
    
    func refresh(sender: AnyObject) {
        reload()
        refresh.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        
      super.viewWillAppear(animated)
        
        let  aDel = UIApplication.sharedApplication().delegate as! AppDelegate
        dispatch_barrier_sync(aDel.serialQueueNotisAppD) {
            
            if (userCercle.vincleSelected != nil){
                NotificationManager.checkNewNotifications() { result in
                    if result == "TASK END" {
                        print("INITFEED")
                    }
                }
            }
        }
        aDel.checkFcmConnection()
    }
    
    func refreshFromBackGround() {
        performSelector(#selector(InicioTableViewController.reload), withObject: self, afterDelay: 1.0)
    }
    
    func reload() {
        checkIncomingCita()
        loadFeedsFromCoreData()
        tableView.reloadData()
    }
    
    func result() { // unused
        var sections:[[NSDate:[InitFeed]]] = []
        
        for i in 0 ..< sectionDates.count {
            sections.append([sectionDates[i]:feedsPerDate[i]])
        }
    }
    
    func loadFeedsInSections(idx:Int,refDate:NSDate) { // unused
        
        sectionDates.append(refDate)
        
        let allFeeds = InitFeed.loadInitFeeds()
        var arryDates:[InitFeed] =  []
        
        for i in idx ..< allFeeds.count {
            
            let compo = Utils().getCalendarComponentsFromDate(allFeeds[i].date!)
            let refCompo = Utils().getCalendarComponentsFromDate(refDate)
            if compo.year == refCompo.year && compo.month == refCompo.month &&
                compo.day == refCompo.day{
                
                arryDates.append(allFeeds[i])
                
                if i == allFeeds.count-1 {
                    feedsPerDate.append(arryDates)
                    result()
                    return
                }
            }else{
                if i == allFeeds.count-1 {
                    feedsPerDate.append(arryDates)
                    sectionDates.append(refDate)
                    result()
                }else{
                    feedsPerDate.append(arryDates)
                    self.loadFeedsInSections(i,refDate:allFeeds[i].date!)
                    break
                }
            }
        }
    }
    
   private func loadFeedsFromCoreData() {
        
        initFeed = InitFeed.loadInitFeeds()
        
        inicioTableView.reloadData()
    }
    
    func checkIncomingCita() {
        
        let fromDate = Utils().getCurrentLocalDate()
        let toDate = fromDate.addHours(2)
        let calendar = NSCalendar.currentCalendar()
        let currDatePlus120 = calendar.dateByAddingUnit(.Minute, value: 120, toDate: fromDate, options: [])
        var feedDates:[String] = []
        let currenFeeds = InitFeed.loadFeedsWithType(INIT_CELL_INCOMING_EVENT)
        
        for ids in currenFeeds {
            feedDates.append(ids.id!)
        }
        let nextHourCites = Cita.loadAllCitesFromInterval(fromDate, to: toDate)
        
        for dat in nextHourCites {
            if dat.date!.isLessThanDate(currDatePlus120!) == true &&
                dat.descript! != "" {
                if feedDates.contains(dat.id!) {
                }else{
                    let params:[String:AnyObject] = [
                        "id":dat.id!,
                        "date":Utils().getCurrentLocalDate(),
                        "idUsrVincles":dat.calendarId!,
                        "type":INIT_CELL_INCOMING_EVENT,
                        "objectDate":dat.date!,
                        "textBody":dat.descript!,
                        "isRead":false]
                    
                    InitFeed.addNewFeedEntityOffline(params)
                }
            }
        }
    }
    
    func changeInitialVC(frontVC:MenuInitDestination) {
        
        switch frontVC {
        case .Inicio:
            print("nothing")
        case .Redes:
            print("redes")
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("xarxesVC") as? XarxesVC {
                let navController = UINavigationController(rootViewController: secondViewController)
                navController.navigationBar.barTintColor = UIColor(hexString: HEX_RED_BTN)
                navController.setViewControllers([secondViewController], animated:true)
                self.revealViewController().setFrontViewController(navController, animated: true)
                SingletonVars.sharedInstance.initDestination = .Inicio
            }
        case .Mensajes:
            print("mensajes")
            if let rootVC = self.storyboard?.instantiateViewControllerWithIdentifier("missatgesFeed") as? MissatgesFeedVC {
                rootVC.goToNewMessage = false
                rootVC.messageJustSent = true
                let navController = UINavigationController(rootViewController: rootVC)
                navController.navigationBar.barTintColor = UIColor(hexString: HEX_RED_BTN)
                navController.setViewControllers([rootVC], animated:true)
                self.revealViewController().setFrontViewController(navController, animated: true)
                SingletonVars.sharedInstance.initDestination = .Inicio
            }
        case .CrearMensajes:
            print("crearMensajes")
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("missatgesFeed") as? MissatgesFeedVC {
                secondViewController.goToNewMessage = true
                let navController = UINavigationController(rootViewController: secondViewController)
                navController.navigationBar.barTintColor = UIColor(hexString: HEX_RED_BTN)
                navController.setViewControllers([secondViewController], animated:true)
                self.revealViewController().setFrontViewController(navController, animated: true)
                SingletonVars.sharedInstance.initDestination = .Inicio
            }
        case .VideoLlamada:
            print("videollamada")
            if let rootVC = self.storyboard?.instantiateViewControllerWithIdentifier("videoTrucadaVC") as? VideoTrucadaVC {
                
                
                let navController = UINavigationController(rootViewController: rootVC)
                navController.navigationBar.barTintColor = UIColor(hexString: HEX_RED_BTN)
                navController.setViewControllers([rootVC], animated:true)
                self.revealViewController().setFrontViewController(navController, animated: true)
                SingletonVars.sharedInstance.initDestination = .Inicio
            }
        case .Trucant:
            print("trucant")
            if let rootVC = self.storyboard?.instantiateViewControllerWithIdentifier("videoTrucadaVC") as? VideoTrucadaVC {
                
            let secondVC = self.storyboard?.instantiateViewControllerWithIdentifier("trucantVC") as! TrucantVC
            secondVC.userName = SingletonVars.sharedInstance.idUserCall
            secondVC.roomName = SingletonVars.sharedInstance.idRoomCall
            
            let navController = UINavigationController(rootViewController: rootVC)
            navController.navigationBar.barTintColor = UIColor(hexString: HEX_RED_BTN)
            navController.setViewControllers([rootVC,secondVC], animated:true)
            self.revealViewController().setFrontViewController(navController, animated: true)
            SingletonVars.sharedInstance.initDestination = .Inicio

               
            }
        case .Agenda:
            print("agenda")
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AgendaVC") as? AgendaViewController {
                let navController = UINavigationController(rootViewController: secondViewController)
                navController.navigationBar.barTintColor = UIColor(hexString: HEX_RED_BTN)
                navController.setViewControllers([secondViewController], animated:true)
                self.revealViewController().setFrontViewController(navController, animated: true)
                SingletonVars.sharedInstance.initDestination = .Inicio
            }
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return initFeed.count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        tableView.headerViewForSection(section)?.textLabel?.alpha = 0.8
        
        return formatter.stringFromDate(NSDate())
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch initFeed[indexPath.row].type! {
        case INIT_CELL_AUDIO_MSG:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_IMAGE_MSG:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_VIDEO_MSG:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_CONNECTED_TO:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_DISCONNECTED_OF:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell

        case INIT_CELL_EVENT_SENT:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_EVENT_ACCEPTED:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType3", forIndexPath: indexPath) as! CellType3TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_EVENT_REJECTED:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType3", forIndexPath: indexPath) as! CellType3TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_EVENT_DELETED:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType3", forIndexPath: indexPath) as! CellType3TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_INCOMING_EVENT:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType2", forIndexPath: indexPath) as! CellType2TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_LOST_CALL:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        case INIT_CELL_CALL_REALIZED:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            cell.setCellContent(initFeed[indexPath.row])
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("cellType1", forIndexPath: indexPath) as! CellType1TableViewCell
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch initFeed[indexPath.row].type! {
        case INIT_CELL_CONNECTED_TO:
            return 77.0
        case INIT_CELL_DISCONNECTED_OF:
            return 77.0
        case INIT_CELL_AUDIO_MSG:
            return 77.0
        case INIT_CELL_VIDEO_MSG:
            return 77.0
        case INIT_CELL_IMAGE_MSG:
            return 77.0
        case INIT_CELL_EVENT_SENT:
            return 77.0
        case INIT_CELL_EVENT_ACCEPTED:
            let charCount = initFeed[indexPath.row].textBody!.characters.count
            if charCount < 20 {
                return 140
            }else{
                return 158.0
            }
        case INIT_CELL_EVENT_REJECTED:
            let charCount = initFeed[indexPath.row].textBody!.characters.count
            if charCount < 20 {
                return 140
            }else{
                return 158.0
            }
        case INIT_CELL_EVENT_DELETED:
            let charCount = initFeed[indexPath.row].textBody!.characters.count
            if charCount < 20 {
                return 140
            }else{
                return 158.0
            }
        default:
            return 77.0
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let feed = initFeed[indexPath.row]
        
        if feed.isRead! == false {
            feed.isRead! = true
            InitFeed.saveInitFeedContext()
        }
        
        checkFeedSelected(feed)
        
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let feed = initFeed[indexPath.row]
        
        if editingStyle == .Delete {
            deleteFeed(feed,idxPath:indexPath)
        }
    }
    
    func changeUserVinclesSelectedWithCalendar(calendarID:String)  {
        
        let newVincles = UserVincle.loadUserVincleWithCalendarID(calendarID)!
        userCercle.vincleSelected = newVincles.id!
        UserCercle.saveUserCercleEntity(userCercle)
        changeNavBarPhoto(newVincles)
    }
    
    func changeUserVinclesSelectedWithID(usrID:String) {
        
        let newVincles = UserVincle.loadUserVincleWithID(usrID)!
        userCercle.vincleSelected = newVincles.id!
        
        UserCercle.saveUserCercleEntity(userCercle)
        changeNavBarPhoto(newVincles)
    }
    
    func changeNavBarPhoto(vincl:UserVincle) {
        
        let imgData = Utils().imageFromBase64ToData(vincl.photo!)
        let vincImg = UIImage(data: imgData)
        vincleImgView.image = vincImg
    }
    
    func checkFeedSelected(feed:InitFeed) {
        
        switch feed.type! {
        case INIT_CELL_AUDIO_MSG:
            
            let audioMsg = Missatges.getMsgWithID(feed.id!)
            let fromVincl = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)
            
            if fromVincl != nil {
                if audioMsg != nil {
                    if audioMsg!.idUserFrom! != userCercle.vincleSelected! {
                        changeUserVinclesSelectedWithID(audioMsg!.idUserFrom!)
                    }
                    performSegueWithIdentifier("fromInit_msgAudioRead", sender: audioMsg!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_MESSAGE_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_MISSATGE_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        case INIT_CELL_IMAGE_MSG:
            
            let imgMsg = Missatges.getMsgWithID(feed.id!)
            let fromVincl = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)
            
            if fromVincl != nil {
                if imgMsg != nil {
                    if imgMsg!.idUserFrom! != userCercle.vincleSelected! {
                        changeUserVinclesSelectedWithID(imgMsg!.idUserFrom!)
                    }
                    performSegueWithIdentifier("fromInit_msgFotoRead", sender: imgMsg!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_MESSAGE_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_MISSATGE_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        case INIT_CELL_VIDEO_MSG:
            
            let videoMsg = Missatges.getMsgWithID(feed.id!)
            let fromVincl = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)
            
            if fromVincl != nil {
                if videoMsg != nil {
                    if videoMsg!.idUserFrom! != userCercle.vincleSelected! {
                        changeUserVinclesSelectedWithID(videoMsg!.idUserFrom!)
                    }
                    performSegueWithIdentifier("fromInit_msgVideoRead", sender: videoMsg!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_MESSAGE_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_MISSATGE_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        case INIT_CELL_CONNECTED_TO:
            
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                
                SingletonVars.sharedInstance.initMenuHasToChange = true
                SingletonVars.sharedInstance.initDestination = .Redes
                self.presentViewController(secondViewController, animated: true, completion:nil)
            }
        case INIT_CELL_DISCONNECTED_OF:
            
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                
                SingletonVars.sharedInstance.initMenuHasToChange = true
                SingletonVars.sharedInstance.initDestination = .Redes
                self.presentViewController(secondViewController, animated: true, completion:nil)
            }
        case INIT_CELL_EVENT_SENT:
            
            let cita = Cita.getOptionalCitaWithID(feed.id!)
            let theVincle = UserVincle.loadUserVincleWithCalendarID(feed.idUsrVincles!)
            
            if theVincle != nil {
                if cita != nil {
                    if feed.idUsrVincles! != userVincle.idCalendar! {
                        changeUserVinclesSelectedWithCalendar(feed.idUsrVincles!)
                    }
                    performSegueWithIdentifier("fromInit_mesDetail", sender: cita!.date!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        case INIT_CELL_EVENT_ACCEPTED:
            
            let cita = Cita.getOptionalCitaWithID(feed.id!)
            let theVincle = UserVincle.loadUserVincleWithCalendarID(feed.idUsrVincles!)
            
            if theVincle != nil {
                if cita != nil {
                    if feed.idUsrVincles! != userVincle.idCalendar! {
                        changeUserVinclesSelectedWithCalendar(feed.idUsrVincles!)
                    }
                    performSegueWithIdentifier("fromInit_mesDetail", sender: cita!.date!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        case INIT_CELL_EVENT_REJECTED:
            
            let cita = Cita.getOptionalCitaWithID(feed.id!)
            let theVincle = UserVincle.loadUserVincleWithCalendarID(feed.idUsrVincles!)
            
            if theVincle != nil {
                if cita != nil {
                    if feed.idUsrVincles! != userVincle.idCalendar! {
                        changeUserVinclesSelectedWithCalendar(feed.idUsrVincles!)
                    }
                    performSegueWithIdentifier("fromInit_mesDetail", sender: cita!.date!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        case INIT_CELL_EVENT_DELETED:
            
            let cita = Cita.getOptionalCitaWithID(feed.id!)
            let theVincle = UserVincle.loadUserVincleWithCalendarID(feed.idUsrVincles!)
            
            if theVincle != nil {
                if cita != nil {
                    if feed.idUsrVincles! != userVincle.idCalendar! {
                        changeUserVinclesSelectedWithCalendar(feed.idUsrVincles!)
                    }
                    performSegueWithIdentifier("fromInit_mesDetail", sender: cita!.date!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
         
            
        case INIT_CELL_INCOMING_EVENT:
            
            let cita = Cita.getOptionalCitaWithID(feed.id!)
            let theVincle = UserVincle.loadUserVincleWithCalendarID(feed.idUsrVincles!)
            
            if theVincle != nil {
                if cita != nil {
                    if feed.idUsrVincles! != userVincle.idCalendar! {
                        changeUserVinclesSelectedWithCalendar(feed.idUsrVincles!)
                    }
                    performSegueWithIdentifier("fromInit_mesDetail", sender: cita!.date!)
                }else{
                    let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_NON_EXISTENT", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_CITA_UNLINKED", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        case INIT_CELL_LOST_CALL:
            
            let theVincle = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)
            
            if theVincle != nil {
                if feed.idUsrVincles! != userVincle.id! {
                    changeUserVinclesSelectedWithID(feed.idUsrVincles!)
                }
                if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                    
                    SingletonVars.sharedInstance.initMenuHasToChange = true
                    SingletonVars.sharedInstance.initDestination = .VideoLlamada
                    self.presentViewController(secondViewController, animated: true, completion:nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_NOT_CONNECTED_CIRCLE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        case INIT_CELL_CALL_REALIZED:
            
            let theVincle = UserVincle.loadUserVincleWithID(feed.idUsrVincles!)
            
            if theVincle != nil {
                if feed.idUsrVincles! != userVincle.id! {
                    changeUserVinclesSelectedWithID(feed.idUsrVincles!)
                }
                if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                    
                    SingletonVars.sharedInstance.initMenuHasToChange = true
                    SingletonVars.sharedInstance.initDestination = .VideoLlamada
                    self.presentViewController(secondViewController, animated: true, completion:nil)
                }
            }else{
                let alert = Utils().postAlert(langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:langBundle.localizedStringForKey("ALERTA_NOT_CONNECTED_CIRCLE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        default:
            print("default")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segue.identifier! {
        case "fromInit_msgAudioRead":
            viewNameLbl.text = langBundle.localizedStringForKey("MSG_NAVBAR_TITLE", value: nil, table: nil)
            let vc = segue.destinationViewController as! MsgAudioReadVC
            let auMiss = sender as! Missatges
            if auMiss.watched! == 0 {
                auMiss.watched = 1
                Missatges.saveMissatgesContext()
            }
            vc.missatge = auMiss
            
        case "fromInit_msgFotoRead":
            viewNameLbl.text = langBundle.localizedStringForKey("MSG_NAVBAR_TITLE", value: nil, table: nil)
            let vc = segue.destinationViewController as! MsgFotoRead
            vc.missatge = sender as! Missatges
            
        case "fromInit_msgVideoRead":
            viewNameLbl.text = langBundle.localizedStringForKey("MSG_NAVBAR_TITLE", value: nil, table: nil)
            let vc = segue.destinationViewController as! MsgVideoReadVC
            vc.missatge = sender as! Missatges
            
        case "fromInit_mesDetail":
            viewNameLbl.text = langBundle.localizedStringForKey("AGENDA_NAVBAR_TITLE", value: nil, table: nil)
            let vc = segue.destinationViewController as! MesDetailVC
            let cit = sender as! NSDate
            vc.currenDate = cit
            vc.comesFromInit = true
   
        default:
            print("DEFAULT")
        }
    }
    
    func deleteFeed(feed:InitFeed,idxPath:NSIndexPath) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        managedContext.deleteObject(feed)
        
        InitFeed.saveInitFeedContext()
        
        self.initFeed.removeAtIndex(idxPath.row)
        self.inicioTableView.deleteRowsAtIndexPaths([idxPath], withRowAnimation:.Fade)
        self.inicioTableView.reloadData()
    }
    

    func getVinclePhoto() {
        if (userVincle != nil){
            if let _ = userVincle.photo
            {
                let imgData = Utils().imageFromBase64ToData(self.userVincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.vincleImgView.image = xarxaImg
                    print("IMAGE ADDED")
                })
            }
            else
            {
                Utils().retrieveUserVinclesProfilePhoto(userVincle, completion: { (result, imgB64) in
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.vincleImgView.image = xarxaImg
                    })
                })
            }
        }
        else{
            
            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            self.vincleImgView.image = xarxaImg
        }
        
    }
    
    func setNavBar() {
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let navBar = self.navigationController?.navigationBar
        navBar?.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        
        viewNameLbl = UILabel(frame:CGRectMake(0,0,150,70))
        viewNameLbl.text = langBundle.localizedStringForKey("INIT_NAVBAR_TITLE", value: nil, table: nil)
        viewNameLbl.textColor = UIColor.whiteColor()
        viewNameLbl.font = UIFont(name: "Akkurat", size: 22)
        navBar?.addSubview(viewNameLbl)
        
        let pinLblLeft = NSLayoutConstraint(item: viewNameLbl, attribute: .Left,
                                            relatedBy: .Equal, toItem: navBar, attribute: .LeftMargin,
                                            multiplier: 1.0, constant: 63)
        let pinLblTop = NSLayoutConstraint(item: viewNameLbl, attribute: .Top,
                                           relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                           multiplier: 1.0, constant: -15)
        let heightLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Height,
                                                relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                                multiplier: 1, constant: 50)
        let widthLblConst = NSLayoutConstraint(item: viewNameLbl, attribute: .Width,
                                               relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                               multiplier: 1, constant: 150)
        
        viewNameLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinLblLeft,pinLblTop,heightLblConst,widthLblConst])
        
        vincleImgView.contentMode = .ScaleAspectFill
        
        navBar?.addSubview(vincleImgView)
        
        vincleImgView.layer.borderColor = UIColor.whiteColor().CGColor
        vincleImgView.layer.borderWidth = 0.0
        vincleImgView.layer.masksToBounds = false
        vincleImgView.layer.cornerRadius = vincleImgView.frame.size.height/2
        vincleImgView.clipsToBounds = true
        
        let pinRight = NSLayoutConstraint(item: vincleImgView, attribute: .Right,
                                          relatedBy: .Equal, toItem: navBar, attribute: .RightMargin,
                                          multiplier: 1.0, constant: -57)
        let pinTop = NSLayoutConstraint(item: vincleImgView, attribute: .Top,
                                        relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                        multiplier: 1.0, constant: -9)
        let heightConst = NSLayoutConstraint(item: vincleImgView, attribute: .Height,
                                             relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                             multiplier: 1, constant: 40)
        let widthConst = NSLayoutConstraint(item: vincleImgView, attribute: .Width,
                                            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                            multiplier: 1, constant: 40)
        
        vincleImgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinRight,pinTop,heightConst,widthConst])
    }
    
    
    @IBAction func barCallBtnPress(sender: UIBarButtonItem) {
        
        if (userCercle.vincleSelected != nil){
            if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
                SingletonVars.sharedInstance.initMenuHasToChange = true
                SingletonVars.sharedInstance.initDestination = .Trucant
                            SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
                self.presentViewController(secondViewController, animated: true, completion:nil)
            }
        }
        else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message:self.langBundle.localizedStringForKey("ALERT_NO_USERS_MESSAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func clearInitFeedEntityTEST() { // TEST
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let request = NSFetchRequest(entityName:"InitFeed")
        
        do{
            let results = try managedContext.executeFetchRequest(request) as! [InitFeed]
            for i in 0 ..< results.count {
                managedContext.deleteObject(results[i])
            }
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func getDefaultPhoto() -> String {
        
        let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
        let photoData = UIImageJPEGRepresentation(xarxaImg!, 0.1)
        let bse64 = Utils().imageFromImgtoBase64(photoData!)
        
        return bse64
    }
}
