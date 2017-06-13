/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SwiftyJSON
import SVProgressHUD

class MgFotoVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    enum State {
        case NoPhoto,PhotoReady,Sending,UploadFailed,SendingFailed,Success
    }
    
    @IBOutlet weak var redBtn: UIButton!
    @IBOutlet weak var grayBtn: UIButton!
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var btnDeletePhoto: UIButton!
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var userVincle:UserVincle!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var fotoURL:NSURL!
    var isPhotoSelected = false
    var contentID:String?
    
    var state:State!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = State.NoPhoto
        
        if (userCercle.vincleSelected != nil) {
            userVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        redBtn.addTarget(self, action: #selector(MgFotoVC.redBtnPress(_:)),
                         forControlEvents:.TouchUpInside)
        
        grayBtn.addTarget(self, action: #selector(MgFotoVC.grayBtnPress(_:)),
                          forControlEvents:.TouchUpInside)
        imagePicked.hidden = true
        
        setUI()
        setupButtons()
    }
    
    func setUI() {
        redBtn.layer.cornerRadius = 4.0
        grayBtn.layer.cornerRadius = 4.0
        redBtn.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        grayBtn.backgroundColor = UIColor(hexString: HEX_GRAY_BTN)
    }
    
    func setupButtons() {
        
        switch state! {
        case .NoPhoto:
            print("NO PHOTO")
            
            redBtn.enabled = true
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_TAKE_PHOTO_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "icon-image-white"), forState: UIControlState.Normal)
            
            grayBtn.enabled = true
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_OPEN_GALLERY_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-attach-galeria"), forState: UIControlState.Normal)
            
        case .PhotoReady:
            print("VIDEO READY")
            
            redBtn.enabled = true
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "icon-aceptar"), forState: UIControlState.Normal)
            
            grayBtn.enabled = true
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_ERASE_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: UIControlState.Normal)
            
        case .Sending:
            print("SENDING")
            redBtn.alpha = 0.5
            redBtn.enabled = false
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_SENDING_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            
            grayBtn.enabled = false
            grayBtn.hidden = true
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_CANCEL_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: UIControlState.Normal)
            
        case .UploadFailed:
            print("UPLOAD FAILED RESEND!!!")
            
            redBtn.enabled = true
            redBtn.alpha = 1
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_RESEND_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "icon-aceptar"), forState: UIControlState.Normal)
            
            grayBtn.enabled = true
            grayBtn.hidden = false
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_REASE_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: UIControlState.Normal)
            
        case .SendingFailed:
            print("SENDING FAILED RESEND")
            redBtn.enabled = true
            redBtn.alpha = 1
            redBtn.enabled = true
            redBtn.setTitle(langBundle.localizedStringForKey("BTN_RESEND_SEND_TITLE", value: nil, table: nil), forState: .Normal)
            redBtn.setImage(UIImage(named: "icon-aceptar"), forState: UIControlState.Normal)
            
            grayBtn.enabled = true
            grayBtn.hidden = false
            grayBtn.setTitle(langBundle.localizedStringForKey("BTN_ERASE_TITLE", value: nil, table: nil), forState: .Normal)
            grayBtn.setImage(UIImage(named: "icon-cancelar"), forState: UIControlState.Normal)
            
            
        case .Success:
            print("SUCCESS ")
            SVProgressHUD.dismiss()
            performSegueWithIdentifier("mgFoto_missatgesFeed", sender: nil)
        }
    }
    
    
    func redBtnPress(sender: UIButton) {
        
        switch state! {
        case .NoPhoto:
            print("NO PHOTO")
            
            openCamera()
            
        case .PhotoReady:
            print("PHOTO READY")
            
            state = State.Sending
            setupButtons()
            sendPhoto()
            
        case .Sending:
            print("SENDING")
            
            
        case .UploadFailed:
            print("UPLOAD FAILED RESEND!!!")
            
            state = State.Sending
            setupButtons()
            sendPhoto()
            
        case .SendingFailed:
            print("SENDING FAILED RESEND")
            
            state = State.Sending
            setupButtons()
            sendPhoto()
            
        case .Success:
            print("SUCCESS ")
        }
        
    }
    
    func grayBtnPress(sender: UIButton) {
        
        switch state! {
        case .NoPhoto:
            print("NO PHOTO")
            
            openPhotoLibrary()
            
        case .PhotoReady:
            print("PHOTO READY")
            
            deletePhoto()
            
        case .Sending:
            print("SENDING")
            
            
        case .UploadFailed:
            print("UPLOAD FAILED RESEND!!!")
            
            deletePhoto()
            
        case .SendingFailed:
            print("SENDING FAILED RESEND")
            
            deletePhoto()
            
        case .Success:
            print("SUCCESS ")
        }
    }
    
    func presentPhoto(img:UIImage) {
        
        imagePicked.image = img
        imagePicked.hidden = false
        btnDeletePhoto.hidden = false
        imagePicked.clipsToBounds = true
        
        isPhotoSelected = true
        state = State.PhotoReady
        setupButtons()
    }
    
    func deletePhoto() {
        imagePicked.hidden = true
        isPhotoSelected = false
        btnDeletePhoto.hidden = true
        state = State.NoPhoto
        setupButtons()
    }
    
    
    @IBAction func deletePhotoBtnPress(sender: UIButton) {
        
        deletePhoto()
    }
    
    func sendPhoto() {
        
        if (imagePicked.image != nil) {
            let dataIMG = UIImageJPEGRepresentation(imagePicked.image!, 0.6)
            
            VinclesApiManager.sharedInstance.loginSelfUser(userCercle.username!, pwd: userCercle.password!, usrId: userCercle.id!)
            
            VinclesApiManager.sharedInstance.sendMessageWithBinary(dataIMG!, usrFrom: userCercle.id!, usrTo: userVincle.id!, mime: VIDEO_MIME_MP4, msgType: MESSAGE_TYPE_IMAGE, text: "",completion: { uploadResponse in
                
                switch uploadResponse {
                case "Upload failed":
                    print(uploadResponse)
                    
                    self.state = State.UploadFailed
                    self.setupButtons()
                    
                case "Upload failed/No Wifi":
                    print(uploadResponse)
                    
                    self.postAlert(self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_NO_WIFI_BODY", value: nil, table: nil))
                    self.state = State.UploadFailed
                    self.setupButtons()
                    
                case "Upload completed":
                    print(uploadResponse)
                    
                case "Message Sent":
                    print(uploadResponse)
                    
                    self.state = State.Success
                    self.setupButtons()
                    
                case "Error sending Message":
                    print(uploadResponse)
                    
                    self.state = State.SendingFailed
                    self.setupButtons()
                    
                default:
                    print(uploadResponse)
                    
                }
            })
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if let _ = info[UIImagePickerControllerReferenceURL] as? NSURL {
            // image from library
        }else{
            // image from camera
            let imageData = UIImageJPEGRepresentation(image, 0.6)
            let compressedJPGImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
        }
        
        presentPhoto(image)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mgFoto_missatgesFeed" {
            
            SingletonVars.sharedInstance.initMenuHasToChange = true
            
            SingletonVars.sharedInstance.initDestination = .Mensajes
        }
    }
    
    // Utility method to display an alert to the user.
    func postAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: self.langBundle.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil), style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}



