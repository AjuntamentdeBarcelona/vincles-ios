//
//  PopupViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AVFoundation

protocol PopUpAudioDelegate{
    func firstButtonClicked(popup: PopupAudioViewController)
    func secondButtonClicked(popup: PopupAudioViewController)
    
}

class PopupAudioViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var firstButton: HoverButton!
    @IBOutlet weak var secondButton: HoverButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    @IBOutlet weak var button1Height: NSLayoutConstraint!
    @IBOutlet weak var button2Height: NSLayoutConstraint!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sliderAudio: UISlider!
    @IBOutlet weak var buttonPlay: UIButton!
    var isPlaying = false
    
    var audioData: Data!{
        didSet {
            if timeLabel != nil{
               
                
            }
        }
    }
    
    
    var popupTitle: String = ""{
        didSet {
            if titleLabel != nil{
                titleLabel.text = popupTitle
            }
        }
    }
   
    var button1Title : String = ""{
        didSet {
            if firstButton != nil{
                firstButton.setTitle(button1Title, for: .normal)
                
            }
        }
    }
    
    var button2Title : String = ""{
        didSet {
            if secondButton != nil{
                secondButton.setTitle(button2Title, for: .normal)
                if button2Title.count > 0{
                    secondButton.isHidden = false
                }
            }
            
            
        }
    }
    
   
    var delegate: PopUpAudioDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            button1Height.constant = 50
            button2Height.constant = 50
        }
        
        titleLabel.text = popupTitle
        firstButton.setTitle(button1Title, for: .normal)
        secondButton.setTitle(button2Title, for: .normal)
        
     
        if button2Title == ""{
            secondButton.isHidden = true
        }
        
        do {
            let player = try AVAudioPlayer(data: audioData)
            self.timeLabel.text = self.stringFromTimeInterval(interval: player.duration) as String
            self.sliderAudio.maximumValue = Float(player.duration)
            
             Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            
            
            
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    
    func stringFromTimeInterval(interval: Double) -> NSString {
        
        let hours = (Int(interval) / 3600)
        let minutes = Int(interval / 60) - Int(hours * 60)
        let seconds = Int(interval) - (Int(interval / 60) * 60)
        
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.alphaView.alpha = 1
            
        }, completion: { (completed) in
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screenWidth  = self.view.bounds.size.width
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact) {
            if  (UIDevice.current.userInterfaceIdiom == .pad){
                stackWidth.constant = screenWidth * 0.6
                
            }
            else{
                stackWidth.constant = screenWidth * 0.7
                
            }
            stackView.axis = .vertical
        }
        else{
            stackView.axis = .horizontal
            if  (UIDevice.current.userInterfaceIdiom == .pad){
                stackWidth.constant = screenWidth * 0.5
                if button2Title == ""{
                    stackWidth.constant = screenWidth * 0.35
                }
            }
            else{
                stackWidth.constant = screenWidth * 0.6
                if button2Title == ""{
                    stackWidth.constant = screenWidth * 0.4
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismissPopup {
            
        }
        
    }
    
    @IBAction func button1Clicked(_ sender: Any) {
        delegate?.firstButtonClicked(popup: self)
        
    }
    
    @IBAction func button2Clicked(_ sender: Any) {
        delegate?.secondButtonClicked(popup: self)
        
    }
    func dismissPopup(dismissCompletion: @escaping () -> Void) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alphaView.alpha = 0
        }, completion: { (completed) in
            self.dismiss(animated: true, completion: {
                dismissCompletion()
            })
            
        })
    }
    
    @IBAction func slide(_ slider: UISlider) {
        
        if let player = AudioManager.sharedInstance.player{
            player.currentTime = TimeInterval(slider.value)
            if player.currentTime == 0.0{
                self.timeLabel.text = self.stringFromTimeInterval(interval: Double(sliderAudio.maximumValue)) as String
                
            }
            else{
                self.timeLabel.text = self.stringFromTimeInterval(interval: player.currentTime) as String
            }
            
        }
        
    }
    
    @objc func updateSlider(){
     
            
            if let player = AudioManager.sharedInstance.player{
                if player.isPlaying{
                    buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.pause), for: .normal)
                }
                else{
                    buttonPlay.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)
                }
                
                if isPlaying{
                    sliderAudio.value = Float(player.currentTime)
                }
                if player.currentTime == 0.0{
                    self.timeLabel.text = self.stringFromTimeInterval(interval: Double(sliderAudio.maximumValue)) as String
                    
                }
                else{
                    self.timeLabel.text = self.stringFromTimeInterval(interval: player.currentTime) as String
                }
            }
        
    }
    
    
    @IBAction func playAudio(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.recordingAudio{
            return
        }
        
     AudioManager.sharedInstance.playingContent = -1
        
            do {
                
                
                if isPlaying &&  AudioManager.sharedInstance.player != nil &&  (AudioManager.sharedInstance.player?.isPlaying)!{
                    AudioManager.sharedInstance.player?.pause()
                    
                    sender.setImage(UIImage(asset: Asset.Icons.Chat.play), for: .normal)
                }
                else if isPlaying &&  AudioManager.sharedInstance.player != nil &&  AudioManager.sharedInstance.player?.currentTime != TimeInterval(0.0){
                    AudioManager.sharedInstance.player?.play()
                    
                    sender.setImage(UIImage(asset: Asset.Icons.Chat.pause), for: .normal)
                }
                else{
                    AudioManager.sharedInstance.player?.currentTime = TimeInterval(0.0)
                    AudioManager.sharedInstance.player?.stop()
                    AudioManager.sharedInstance.player = try AVAudioPlayer(data: audioData)
                    AudioManager.sharedInstance.player?.delegate = AudioManager.sharedInstance
                    AudioManager.sharedInstance.audioStop()
                    AudioManager.sharedInstance.player?.prepareToPlay()
                    sender.setImage(UIImage(asset: Asset.Icons.Chat.pause), for: .normal)
                    AudioManager.sharedInstance.player?.play()
                    isPlaying = true
                }
                
                
            } catch let error as NSError {
                AudioManager.sharedInstance.player?.currentTime = TimeInterval(0.0)
                AudioManager.sharedInstance.player?.stop()
                AudioManager.sharedInstance.audioStop()
            }
        
        
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

