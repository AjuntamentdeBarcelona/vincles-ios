//
//  AgendaContainerViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class AgendaContainerViewController: UIViewController {

    @IBOutlet weak var todayButton: HoverButton!
    @IBOutlet weak var tomorrowButton: HoverButton!
    @IBOutlet weak var monthButton: HoverButton!
    @IBOutlet weak var containerView: UIView!
    var coachMarksController = CoachMarksController()

    var showBackButton = true
    var showingOther = false
    var showingDate = Date()
    var openHomeOnBack = false

    var preloadOtherDate: Date?
    
    private lazy var todayViewController: AgendaDayViewController = {

        let dayVC = StoryboardScene.Agenda.ndaDayViewController.instantiate()
        dayVC.selectedDate = Date()
        dayVC.dayType = .today
        self.add(asChildViewController: dayVC)
        
        return dayVC
    }()
    
    private lazy var tomorrowViewController: AgendaDayViewController = {
        
        let dayVC = StoryboardScene.Agenda.ndaDayViewController.instantiate()
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()){
            dayVC.selectedDate = tomorrow
        }
        dayVC.dayType = .tomorrow

        self.add(asChildViewController: dayVC)
        
        return dayVC
    }()
    
    private lazy var monthViewController: AgendaMonthViewController = {
        
        let monthVC = StoryboardScene.Agenda.agendaMonthViewController.instantiate()
        monthVC.container = self

        self.add(asChildViewController: monthVC)
        
        return monthVC
    }()
    
    private lazy var anotherDayViewController: AgendaDayViewController = {
        
        let dayVC = StoryboardScene.Agenda.ndaDayViewController.instantiate()
        dayVC.dayType = .other
        dayVC.selectedDate = Date()

        self.add(asChildViewController: dayVC)
        
        return dayVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachMarksController.dataSource = self
        coachMarksController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        coachMarksController.overlay.allowTap = true
        
        setStrings()
        setFonts()
        configNavigationBar()
        
        initialSetup()
        preloadAnother()
        addHelpButton()
    }
    
    func addHelpButton(){
        let helpButton = UIButton()
        
        helpButton.frame = (UIDevice.current.userInterfaceIdiom == .pad) ? CGRect(x:0, y:0, width:160, height:30) : CGRect(x:0, y:0, width:30, height:30)
        (UIDevice.current.userInterfaceIdiom == .pad) ? helpButton.setTitle(L10n.ayuda, for: .normal) : helpButton.setTitle("", for: .normal)
        helpButton.setImage(UIImage(asset: Asset.Icons.ajuda), for: .normal)
        helpButton.addTarget(self, action: #selector(showHelp), for: .touchUpInside)
        helpButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 23.0)
        helpButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        if let baseViewController = self.parent as? BaseViewController{
            baseViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
        }
    }
    
    @objc func showHelp(){
        startInstructions()
    }
    
    func startInstructions() {
        self.coachMarksController.start(on: self)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: GA_TRACKING) else {return}
        tracker.set(kGAIScreenName, value: ANALYTICS_AGENDA)
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    func setStrings(){
        todayButton.setTitle(L10n.agendaHoy, for: .normal)
        tomorrowButton.setTitle(L10n.agendaManana, for: .normal)
        monthButton.setTitle(L10n.agendaMes, for: .normal)
    }
    
    func setFonts(){
        monthButton.titleLabel?.numberOfLines = 2
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular) {
            todayButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 20.0)
            monthButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 20.0)
            tomorrowButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 20.0)

        }
        else{
            todayButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)
            monthButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)
            tomorrowButton.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 16.0)
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
            
            baseViewController.rightButtonTitle = L10n.agendaNuevaCita
            baseViewController.rightButtonImage = UIImage(asset: Asset.Icons.Agenda.novaCita)
            baseViewController.rightButtonHightlightedImage = UIImage(asset: Asset.Icons.Agenda.novaCitaHover)
            
            baseViewController.rightAction = rightAction

        }
    }
    
    
    func leftAction(_params: Any...) -> UIViewController?{
        if showingOther{
            showingOther = false
            remove(asChildViewController: todayViewController)
            remove(asChildViewController: tomorrowViewController)
            remove(asChildViewController: anotherDayViewController)
            add(asChildViewController: monthViewController)
            return nil
        }
        else{
            if openHomeOnBack{
                if let nav = self.slideMenuController()?.mainViewController as? UINavigationController{
                    let mainViewController = StoryboardScene.Main.homeViewController.instantiate()
                    nav.setViewControllers([mainViewController], animated: true)
                }
                return nil
            }
            return self.navigationController?.popViewController(animated: true)
        }
    }
    
    func rightAction(_params: Any...) -> UIViewController?{
        
        let baseVC = StoryboardScene.Base.baseViewController.instantiate()
        let detailVC = StoryboardScene.Agenda.newScheduleViewController.instantiate()
        
        detailVC.preloadDate = showingDate

        baseVC.containedViewController = detailVC
        self.navigationController?.pushViewController(baseVC, animated: true)
        return nil
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setFonts()
    }
    
    
    override public var traitCollection: UITraitCollection {
        
        
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    func initialSetup(){
        remove(asChildViewController: tomorrowViewController)
        remove(asChildViewController: monthViewController)
        add(asChildViewController: todayViewController)
        remove(asChildViewController: anotherDayViewController)

    }
    
    func preloadAnother(){
        if let preloadDate = preloadOtherDate{
            showingDate = preloadDate
            
            anotherDayViewController.selectedDate = preloadDate
            remove(asChildViewController: todayViewController)
            remove(asChildViewController: tomorrowViewController)
            add(asChildViewController: anotherDayViewController)
            remove(asChildViewController: monthViewController)
            showingOther = false
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    @IBAction func todayAction(_ sender: Any) {
        showingOther = false
        showingDate = Date()
        remove(asChildViewController: tomorrowViewController)
        remove(asChildViewController: monthViewController)
        remove(asChildViewController: anotherDayViewController)
        add(asChildViewController: todayViewController)
    }
    
    @IBAction func tomorrowAction(_ sender: Any) {
        showingOther = false
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()){
            showingDate = tomorrow
        }
        remove(asChildViewController: todayViewController)
        remove(asChildViewController: monthViewController)
        remove(asChildViewController: anotherDayViewController)
        add(asChildViewController: tomorrowViewController)
    }
    
    @IBAction func monthAction(_ sender: Any) {
        showingOther = false
        showingDate = Date()

        remove(asChildViewController: todayViewController)
        remove(asChildViewController: tomorrowViewController)
        remove(asChildViewController: anotherDayViewController)
        add(asChildViewController: monthViewController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAnotherDay(date: Date){
        showingDate = date

        anotherDayViewController.selectedDate = date
        remove(asChildViewController: todayViewController)
        remove(asChildViewController: tomorrowViewController)
        add(asChildViewController: anotherDayViewController)
        remove(asChildViewController: monthViewController)
        showingOther = true
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

extension AgendaContainerViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        var coachMark : CoachMark
        
        switch(index) {
        case 0:
            coachMark = coachMarksController.helper.makeCoachMark(for: todayButton)
        case 1:
            coachMark = coachMarksController.helper.makeCoachMark(for: tomorrowButton)
        case 2:
            coachMark = coachMarksController.helper.makeCoachMark(for: monthButton)
        case 3:
            if let baseViewController = self.parent as? BaseViewController{
                coachMark = coachMarksController.helper.makeCoachMark(for: baseViewController.navigationBar.rightButton)
            }
            else{
                coachMark = coachMarksController.helper.makeCoachMark()
            }
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
        }
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        return coachMark
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var bodyView : CoachMarkBodyView
        var arrowView : CoachMarkArrowView?
        let coachMarkBodyView = TransparentCoachMarkBodyView()
        
        switch(index) {
            
        case 0:
            coachMarkBodyView.hintLabel.text = L10n.wtCalendariAvui
        case 1:
            coachMarkBodyView.hintLabel.text = L10n.wtCalendariDema
        case 2:
            coachMarkBodyView.hintLabel.text = L10n.wtCalendariMes
        case 3:
            coachMarkBodyView.hintLabel.text = L10n.wtCalendariCrear
        default:
            break
        }
        
        
        
        bodyView = coachMarkBodyView
        arrowView = nil
        
        return (bodyView: bodyView, arrowView: arrowView)
        
        
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    
}



