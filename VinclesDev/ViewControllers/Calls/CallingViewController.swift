//
//  CallingViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol CallingViewControllerDelegate: AnyObject {
    func cancelCall()
    func retryCall()
    func sendMessage()

}


class CallingViewController: UIViewController, ProfileImageManagerDelegate {
  
    
    weak var delegate:CallingViewControllerDelegate?

    @IBOutlet weak var penjarButton: HoverButton!
    @IBOutlet weak var receptorImageView: UIImageView!
    @IBOutlet weak var emisorImageView: UIImageView!
    @IBOutlet weak var outgoingView: UIView!
    @IBOutlet weak var cannotCallView: UIView!
    @IBOutlet weak var missatgeButton: HoverButton!
    @IBOutlet weak var retryButton: HoverButton!
    @IBOutlet weak var viewFotosOutgoing: UIView!
    @IBOutlet weak var dotsView: UIView!
    @IBOutlet weak var firstDotCircle: UIView!
    @IBOutlet weak var secondDotCircle: UIView!
    @IBOutlet weak var thirdDotCircle: UIView!
    @IBOutlet weak var fourthDotCircle: UIView!
    @IBOutlet weak var fifthDotCircle: UIView!
    @IBOutlet weak var fourthDot: UIView!
    @IBOutlet weak var fifthDot: UIView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var errorImageView: UIImageView!

    var dotsTimer: Timer!
    var dotSequenceIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTimers()
        setupProfileImages()

    }
    
    func setupUI(){
        initDots()
        cannotCallView.isHidden = true
        outgoingView.isHidden = false
        viewFotosOutgoing.isHidden = false
        errorImageView.isHidden = true
        if UIDevice.current.userInterfaceIdiom == .pad{
            labelInfo.font =  UIFont(font: FontFamily.Akkurat.regular, size: 28.0)
        }
        penjarButton.setTitle(L10n.callEnd, for: .normal)
  
        missatgeButton.setTitle(L10n.callMessage, for: .normal)
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            missatgeButton.setTitle(L10n.callMessagePhone, for: .normal)
            
        }
        missatgeButton.titleLabel?.numberOfLines = 2
        retryButton.setTitle(L10n.callRetry, for: .normal)
        
        cannotCallView.isHidden = true
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            fourthDot.isHidden = true
            fifthDot.isHidden = true
        }
    }
    
    func setupTimers(){
        if dotsTimer != nil{
            dotsTimer.invalidate()
        }
        dotsTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(animateDots), userInfo: nil, repeats: true)
    }
    
    
    func didDownload(userId: Int) {
        setupProfileImages()
    }
    
    func didError(userId: Int) {
        setupProfileImages()
    }
    
    func setupProfileImages(){
        let profileModelManager = ProfileModelManager()

        if let me = profileModelManager.getUserMe(){
            
            if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: me.id), let image = UIImage(contentsOfFile: url.path){
                emisorImageView.image = image
            }
            else{
                emisorImageView.image = UIImage(named: "perfilplaceholder")
            }
           
        }
        
        if let user = WebRTCCallManager.sharedInstance.calleeId{
            let circlesGroupsModelManager = CirclesGroupsModelManager.shared
            if let callee = circlesGroupsModelManager.contactWithId(id: user){
                labelInfo.text =  "\(L10n.calling) \(callee.name)"
                
                if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: callee.id), let image = UIImage(contentsOfFile: url.path){
                    receptorImageView.image = image
                }
                else{
                    receptorImageView.image = UIImage(named: "perfilplaceholder")
                }
                
                
                if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: callee.id), let image = UIImage(contentsOfFile: url.path){
                    errorImageView.image = image
                }
                else{
                    errorImageView.image = UIImage(named: "perfilplaceholder")
                }
                
              
            }
        }
    }
    
    func initDots(){
        dotSequenceIndex = 0
        firstDotCircle.backgroundColor = UIColor(named: .clearGray)
        secondDotCircle.backgroundColor = UIColor(named: .clearGray)
        thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
        fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
        fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
    }
    
    @objc func animateDots(){
        switch dotSequenceIndex{
        case 0:
            firstDotCircle.backgroundColor = UIColor(named: .clearGray)
            secondDotCircle.backgroundColor = UIColor(named: .clearGray)
            thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 1:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .clearGray)
            thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 2:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .clearGray)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 3:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .darkRed)
            fourthDotCircle.backgroundColor = UIColor(named: .clearGray)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 4:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .darkRed)
            fourthDotCircle.backgroundColor = UIColor(named: .darkRed)
            fifthDotCircle.backgroundColor = UIColor(named: .clearGray)
        case 5:
            firstDotCircle.backgroundColor = UIColor(named: .darkRed)
            secondDotCircle.backgroundColor = UIColor(named: .darkRed)
            thirdDotCircle.backgroundColor = UIColor(named: .darkRed)
            fourthDotCircle.backgroundColor = UIColor(named: .darkRed)
            fifthDotCircle.backgroundColor = UIColor(named: .darkRed)
        default:
            break
        }
        
        dotSequenceIndex += 1
        if UIDevice.current.userInterfaceIdiom == .phone{
            if dotSequenceIndex == 4{
                dotSequenceIndex = 0
            }
        }
        else{
            if dotSequenceIndex == 6{
                dotSequenceIndex = 0
            }
        }
    }
    
    func cancelOutgoingCall(){
        // TIMER ESGOTAT
        
        dotsTimer.invalidate()
        
        viewFotosOutgoing.isHidden = true
    
        if let user = WebRTCCallManager.sharedInstance.calleeId{
            let circlesGroupsModelManager = CirclesGroupsModelManager.shared
            if let callee = circlesGroupsModelManager.contactWithId(id: user){
                labelInfo.text =  "\(callee.name) \(L10n.callNoContesta)"

            }
        }
        
        cannotCallView.isHidden = false
        outgoingView.isHidden = true
        errorImageView.isHidden = false

    }
    
    func receivedErrorInCall(){
        // TIMER ESGOTAT
        
        dotsTimer.invalidate()
        
        viewFotosOutgoing.isHidden = true
        labelInfo.text =  "\(L10n.callConnection)"

        cannotCallView.isHidden = false
        outgoingView.isHidden = true
        errorImageView.isHidden = false
        
    }
    
    func receivedErrorDuringCall(){
        // TIMER ESGOTAT
        
        dotsTimer.invalidate()
        
        viewFotosOutgoing.isHidden = true
        labelInfo.text =  "\(L10n.callDuringError)"
        
        cannotCallView.isHidden = false
        outgoingView.isHidden = true
        errorImageView.isHidden = false
        
    }
    
    func retryCall(){
        setupUI()
        setupTimers()
        setupProfileImages()
    }
    
    @IBAction func cancelCall(_ sender: Any) {
        delegate?.cancelCall()
    }
    
    @IBAction func retryCall(_ sender: Any) {
        delegate?.retryCall()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        delegate?.sendMessage()
    }
    
    func calleeRejectedCal(){
        if let user = WebRTCCallManager.sharedInstance.calleeId{
            let circlesGroupsModelManager = CirclesGroupsModelManager.shared
            if let callee = circlesGroupsModelManager.contactWithId(id: user){
                labelInfo.text =  "\(callee.name) \(L10n.callNoContesta)"
                
            }
        }
        
        dotsTimer.invalidate()
        
        viewFotosOutgoing.isHidden = true
        
        cannotCallView.isHidden = false
        outgoingView.isHidden = true
        errorImageView.isHidden = false
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
