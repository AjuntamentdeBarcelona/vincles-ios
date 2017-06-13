/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit
import SVProgressHUD

class MgTextVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    
    enum State {
        case NoPhotosOrText,MsgReady,Sending,UploadFailed,SendingFailed,Success
    }
    
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var btnGray: UIButton!
    @IBOutlet weak var btnRed: UIButton!
    @IBOutlet weak var imgViewPhoto1: UIImageView!
    @IBOutlet weak var imgViewPhoto2: UIImageView!
    @IBOutlet weak var imgViewPhoto3: UIImageView!
    @IBOutlet weak var imgViewPhoto4: UIImageView!
    @IBOutlet weak var btnDeletePhoto1: UIButton!
    @IBOutlet weak var btnDeletePhoto2: UIButton!
    @IBOutlet weak var btnDeletePhoto3: UIButton!
    @IBOutlet weak var btnDeletePhoto4: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!
    
    var userVincle:UserVincle!
    
    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    var state = State.NoPhotosOrText
    var photosToAttachIdx = 0
    var photosArray:[UIImage] = []
    var imageViewsArray:[UIImageView] = []
    var deleteButnsArray:[UIButton] = []
    
    var xPosition: CGFloat = 0
    var yPosition: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (userCercle.vincleSelected != nil) {
            userVincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        setUI()
        initialSetupButtons()
        self.hideKeyboardWhenTappedAround()
        addDoneButtonToKeyboard(msgTextView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func shouldAutorotate() -> Bool {
        
        return true
    }
    
    func setUI() {
        
        imgViewPhoto1.clipsToBounds = true
        imgViewPhoto2.clipsToBounds = true
        imgViewPhoto3.clipsToBounds = true
        imgViewPhoto4.clipsToBounds = true
        
        msgTextView.delegate = self
        imageViewsArray = [imgViewPhoto1,imgViewPhoto2,imgViewPhoto3,imgViewPhoto4]
        deleteButnsArray = [btnDeletePhoto1,btnDeletePhoto2,btnDeletePhoto3,btnDeletePhoto4]
        
        
    }
    
    func initialSetupButtons() {
        
        btnRed.layer.cornerRadius = 4.0
        btnRed.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        btnRed.addTarget(self, action: #selector(MgTextVC.btnRedPress(_:)),
                         forControlEvents:.TouchUpInside)
        btnRed.setTitle(langBundle.localizedStringForKey("BTN_SEND_TITLE", value: nil, table: nil), forState: .Normal)
        btnRed.setImage(UIImage(named: "icon-aceptar"), forState: UIControlState.Normal)
        
        btnGray.layer.cornerRadius = 4.0
        btnGray.backgroundColor = UIColor(hexString: HEX_GRAY_BTN)
        btnGray.addTarget(self, action: #selector(MgTextVC.btnGrayPress(_:)),
                          forControlEvents:.TouchUpInside)
        btnGray.setTitle(langBundle.localizedStringForKey("BTN_ADD_IMAGE_TITLE", value: nil, table: nil), forState: .Normal)
        btnGray.setImage(UIImage(named: "icon-attach-galeria"), forState: UIControlState.Normal)
        
        
        
        
    }
    
    func openPhotoLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        photosArray.append(image)
        setupPhotos()
    }
    
    func btnRedPress(sender: UIButton) {
        if state == .MsgReady || state == .UploadFailed ||
            state == .SendingFailed {
            
            if photosArray.count > 0 || msgTextView.text != "" {
                state = .Sending
                setupButtons()
                sendMessage()
            }else{
                let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_ATTACH_PHOTO_OR_WRITE_MESSAGE", value: nil, table: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                state = State.NoPhotosOrText
            }
        }
    }
    
    func btnGrayPress(sender: UIButton) {
        
        if photosArray.count < 4 {
            openPhotoLibrary()
        }else{
            let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ALERT_ATENCION_TITLE", value: nil, table: nil), message: self.langBundle.localizedStringForKey("ALERT_CANT_ADD_MORE_IMAGE", value: nil, table: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func sendMessage() {
        
        var contentsID:[String] = []
        
        if photosArray.count > 0 {
            for photo in photosArray {
                
                let dataIMG = UIImageJPEGRepresentation(photo, 0.6)
                
                VinclesApiManager.sharedInstance.uploadContent(dataIMG!, usrFrom: userCercle.id!, usrTo: userVincle.id!, mime:PHOTO_MIME_JPG, msgType: MESSAGE_TYPE_TEXT,text: "",completion: { response,contentID in
                    
                    if response == "Upload completed" {
                        
                        contentsID.append(contentID)
                        print("ARRY ID == \(contentsID)")
                        
                        if contentsID.count == self.photosArray.count {
                            
                            let parameters:[String: AnyObject] =
                                ["idUserFrom":self.userCercle.id!,
                                    "idUserTo":self.userVincle.id!,
                                    "text":self.msgTextView.text,
                                    "idAdjuntContents":contentsID,
                                    "metadataTipus":MESSAGE_TYPE_TEXT]
                            
                            
                            VinclesApiManager.sharedInstance.sendMessage(parameters, completion: { sendResponse,msgID in
                                
                                if sendResponse == "Message Send" {
                                    
                                    print("SEND SUCCESSFULL MESSAGE ID == \(msgID)")
                                    
                                    SVProgressHUD.dismiss()
                                    self.performSegueWithIdentifier("msgTextFoto_missatgesFeed", sender: nil)
                                }
                                if sendResponse == "Error sending Message" {
                                    let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil),
                                        message: self.langBundle.localizedStringForKey("ERROR_MESSAGE_SEND", value: nil, table: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    
                                    contentsID = []
                                    // delete uploaded content
                                }
                            })
                        }
                    }
                    
                    if response == "Upload failed" {
                        let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil),
                            message: self.langBundle.localizedStringForKey("ERROR_MESSAGE_SEND", value: nil, table: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.state = .UploadFailed
                        self.setupButtons()
                        // delete uploaded content
                    }
                    if response == "Upload failed/No Wifi" {
                        let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil),
                            message: self.langBundle.localizedStringForKey("ALERT_NO_WIFI_MESSAGE", value: nil, table: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.state = .UploadFailed
                        self.setupButtons()
                        // delete uploaded content
                    }
                })
            }
            
        }else{
            let emptyContentarry:[String] = []
            let parameters:[String: AnyObject] =
                ["idUserFrom":userCercle.id!,
                 "idUserTo":userVincle.id!,
                 "text":msgTextView.text,
                 "idAdjuntContents":emptyContentarry,
                 "metadataTipus":MESSAGE_TYPE_TEXT]
            
            print(parameters)
            
            VinclesApiManager.sharedInstance.sendMessage(parameters, completion: { sendResponse,msgID in
                
                if sendResponse == "Message Send" {
                    
                    print("SEND SUCCESSFULL MESSAGE ID == \(msgID)")
                    self.performSegueWithIdentifier("msgTextFoto_missatgesFeed", sender: nil)
                }
                if sendResponse == "Error sending Message" {
                    let alert = Utils().postAlert(self.langBundle.localizedStringForKey("ERROR_TITLE", value: nil, table: nil),
                        message: self.langBundle.localizedStringForKey("ERROR_MESSAGE_SEND", value: nil, table: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.state = .SendingFailed
                    self.setupButtons()
                    // delete uploaded content
                    contentsID = []
                }
            })
        }
    }
    
    func setupButtons() {
        
        if state == .Sending {
            btnRed.alpha = 0.5
            btnRed.enabled = false
            btnGray.enabled = false
            btnGray.alpha = 0.5
        }else{
            btnRed.alpha = 1
            btnRed.enabled = true
            btnGray.enabled = true
            btnGray.alpha = 1
        }
    }
    
    func setupPhotos() {
        
        if photosArray.count > 0 {
            state = State.MsgReady
        }
        
        for _ in photosArray {
            switch photosArray.count {
            case 1:
                imgViewPhoto1.image = photosArray[0]
                btnDeletePhoto1.hidden = false
            case 2:
                imgViewPhoto1.image = photosArray[0]
                imgViewPhoto2.image = photosArray[1]
                btnDeletePhoto1.hidden = false
                btnDeletePhoto2.hidden = false
            case 3:
                imgViewPhoto1.image = photosArray[0]
                imgViewPhoto2.image = photosArray[1]
                imgViewPhoto3.image = photosArray[2]
                btnDeletePhoto1.hidden = false
                btnDeletePhoto2.hidden = false
                btnDeletePhoto3.hidden = false
            case 4:
                imgViewPhoto1.image = photosArray[0]
                imgViewPhoto2.image = photosArray[1]
                imgViewPhoto3.image = photosArray[2]
                imgViewPhoto4.image = photosArray[3]
                btnDeletePhoto1.hidden = false
                btnDeletePhoto2.hidden = false
                btnDeletePhoto3.hidden = false
                btnDeletePhoto4.hidden = false
                
            default:
                print("default")
            }
        }
        
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
    }
    
    @IBAction func deletePhotoPress(sender: UIButton) {
        
        switch sender.tag {
        case 0:
            imgViewPhoto1.image = nil
            photosArray.removeAtIndex(0)
            btnDeletePhoto1.hidden = true
        case 1:
            imgViewPhoto2.image = nil
            photosArray.removeAtIndex(1)
            btnDeletePhoto2.hidden = true
        case 2:
            imgViewPhoto3.image = nil
            photosArray.removeAtIndex(2)
            btnDeletePhoto3.hidden = true
        case 3:
            imgViewPhoto4.image = nil
            photosArray.removeAtIndex(3)
            btnDeletePhoto4.hidden = true
        default:
            print("default")
        }
        clearImageViews()
    }
    
    func clearImageViews() {
        
        for imgView in imageViewsArray {
            imgView.image = nil
        }
        for btns in deleteButnsArray {
            btns.hidden = true
        }
        setupPhotos()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if msgTextView.text != "" {
            state = State.MsgReady
            
        }else{
            if photosArray.count == 0 {
                state = State.NoPhotosOrText
            }
        }
    }
    
    func addDoneButtonToKeyboard(txtView:UITextView) {
        
        let doneToolBar = UIToolbar(frame: CGRectMake(0,0,320,50))
        doneToolBar.barStyle = .Default
        doneToolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
                             UIBarButtonItem.init(title:langBundle.localizedStringForKey("KEYBOARD_DONE_BTN", value: nil, table: nil), style: .Done, target: self, action: #selector(doneButtonClickedDismissKeyboard))]
        doneToolBar.sizeToFit()
        msgTextView.inputAccessoryView = doneToolBar
    }
    
    func doneButtonClickedDismissKeyboard() {
        msgTextView .resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "msgTextFoto_missatgesFeed" {
            
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Mensajes
            
        }
    }
}
