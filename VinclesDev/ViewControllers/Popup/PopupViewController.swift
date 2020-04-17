//
//  PopupViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol PopUpDelegate{
    func firstButtonClicked(popup: PopupViewController)
    func secondButtonClicked(popup: PopupViewController)
    func closeButtonClicked(popup: PopupViewController)

}

class PopupViewController: UIViewController, ProfileImageManagerDelegate {
    func didDownload(userId: Int) {
        if self.userId > -1 && self.userId == userId{
            if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: self.userId), let image = UIImage(contentsOfFile: url.path){
                circularImageView.image = image
            }
        }

    }
    
    func didError(userId: Int) {
        if self.userId > -1 && self.userId == userId{
                circularImageView.image = UIImage(named: "perfilplaceholder")
        }
    }
    

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var firstButton: HoverButton!
    @IBOutlet weak var secondButton: HoverButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stackWidth: NSLayoutConstraint!
    @IBOutlet weak var button1Height: NSLayoutConstraint!
    @IBOutlet weak var button2Height: NSLayoutConstraint!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var circularImageView: CircularImageView!
    @IBOutlet weak var circularImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var distanceImageDescription: NSLayoutConstraint!

    var data: Data?
    var text: String?
    var videoURL: URL?

    var popupTitle: String = ""{
        didSet {
            if titleLabel != nil{
                titleLabel.text = popupTitle
            }
        }
    }
    var popupDescription : String = ""{
        didSet {
            if descriptionLabel != nil{
                descriptionLabel.text = popupDescription

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
    
    var userId: Int = -1{
        didSet {
            if userId > -1{
                if circularImageView != nil{
                    circularImageView.isHidden = false
                    circularImageViewHeight.constant = 100
                    distanceImageDescription.constant = 15
                    if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: self.userId), let image = UIImage(contentsOfFile: url.path){
                        circularImageView.image = image
                    }
                    else{
                        circularImageView.image = UIImage(named: "perfilplaceholder")
                    }
                }
             
            }
        }
    }
    
    var delegate: PopUpDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            button1Height.constant = 50
            button2Height.constant = 50
        }
        
        titleLabel.text = popupTitle
        descriptionLabel.text = popupDescription
        firstButton.setTitle(button1Title, for: .normal)
        secondButton.setTitle(button2Title, for: .normal)
        
        if userId == -1{
            circularImageViewHeight.constant = 0
            distanceImageDescription.constant = 0
        }
        else{
            circularImageView.isHidden = false
            circularImageViewHeight.constant = 100
            distanceImageDescription.constant = 15
            if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: self.userId), let image = UIImage(contentsOfFile: url.path){
                circularImageView.image = image
            }
            else{
                circularImageView.image = UIImage(named: "perfilplaceholder")
            }
        }
        if button2Title == ""{
            secondButton.isHidden = true
        }
        
        
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileImageManager.sharedInstance.delegate = self

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
        delegate?.closeButtonClicked(popup: self)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
