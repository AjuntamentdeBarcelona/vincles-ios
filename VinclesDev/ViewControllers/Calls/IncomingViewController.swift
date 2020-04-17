//
//  IncomingViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol IncomingViewControllerDelegate: AnyObject {
    func acceptCall()
    func rejectCall(dismiss: Bool)
    
}

class IncomingViewController: UIViewController, ProfileImageManagerDelegate {
    @IBOutlet weak var emisorIncomingImageView: UIImageView!
    @IBOutlet weak var cancelarButton: HoverButton!
    @IBOutlet weak var agafarButton: HoverButton!
    @IBOutlet weak var labelInfo: UILabel!

    weak var delegate:IncomingViewControllerDelegate?

    var clientConn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImages()
        setUI()
      
    }
    
    func clientConnected(){
        clientConn = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ProfileImageManager.sharedInstance.delegate = self
    }
    func setupProfileImages(){
  
        if let user = WebRTCCallManager.sharedInstance.callerId{
            let circlesGroupsModelManager = CirclesGroupsModelManager.shared
            if let callee = circlesGroupsModelManager.userWithId(id: user){
                labelInfo.text =  "\(L10n.callFrom) \(callee.name)"
                                
                if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: callee.id), let image = UIImage(contentsOfFile: url.path){
                    emisorIncomingImageView.image = image
                }
                else{
                    emisorIncomingImageView.image = UIImage(named: "perfilplaceholder")
                }
         
            }
        }
    }
    
    func didError(userId: Int) {
        setupProfileImages()
    }
    
    func didDownload(userId: Int) {
        setupProfileImages()

    }
    
    func setUI(){
        
        cancelarButton.setTitle(L10n.callCancel, for: .normal)
        agafarButton.setTitle(L10n.callGet, for: .normal)
        agafarButton.greenMode = true
        
       
    }
    
    
    @IBAction func acceptCall(_ sender: Any) {
        delegate?.acceptCall()
        labelInfo.text =  "\(L10n.callConnecting)"
        cancelarButton.isHidden = true
        agafarButton.isHidden = true
    }
    
    @IBAction func rejectCall(_ sender: Any) {
        delegate?.rejectCall(dismiss: true)
    }
    
    func receivedErrorInCall(){
        labelInfo.text =  "\(L10n.callConnection)"
        cancelarButton.isHidden = true
        agafarButton.isHidden = true
    }
    
    func receivedErrorDuringCall(){
        labelInfo.text =  "\(L10n.callDuringError)"
        cancelarButton.isHidden = true
        agafarButton.isHidden = true
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
