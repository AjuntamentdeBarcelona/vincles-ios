/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class NotasViewController: VinclesVC,UITextViewDelegate {

    
    @IBOutlet weak var notasTextView: UITextView!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    let langBundle:NSBundle = {
        
        return UserPreferences().bundleForLanguageSelected()
    }()
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!

    var vincle:UserVincle!
    var textNotes = ""
    var textHasBeenSet = false
    
    var xarxaImgView:UIImageView = {
        return UIImageView(frame: CGRectMake(0, 0, 40, 40))
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = NOTAS_VC
        if (userCercle.vincleSelected != nil) {
            vincle = UserVincle.loadUserVincleWithID(userCercle.vincleSelected!)
        }
        
        getVinclePhoto()
        
        notasTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        addDoneButtonToKeyboard(notasTextView)

        if NSUserDefaults.standardUserDefaults().objectForKey("NotasString") != nil  {
            let savedNotes = NSUserDefaults.standardUserDefaults().objectForKey("NotasString") as! String
            textNotes = savedNotes
            notasTextView.text = textNotes
            textHasBeenSet = true
        }else{
            notasTextView.text = langBundle.localizedStringForKey("TEXT_VIEW_PLACEHOLDER", value: nil, table: nil)
            textHasBeenSet = false
        }
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        setNavBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotasViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotasViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func addDoneButtonToKeyboard(txtView:UITextView) {
        
        let doneToolBar = UIToolbar(frame: CGRectMake(0,0,320,50))
        doneToolBar.barStyle = .Default
        doneToolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
         UIBarButtonItem.init(title:langBundle.localizedStringForKey("KEYBOARD_DONE_BTN", value: nil, table: nil), style: .Done, target: self, action: #selector(doneButtonClickedDismissKeyboard))]
        doneToolBar.sizeToFit()
        notasTextView.inputAccessoryView = doneToolBar
    }
    
    func doneButtonClickedDismissKeyboard() {
        notasTextView .resignFirstResponder()
    }
    
    
    func getVinclePhoto() {
        if (vincle != nil){
            if let _ = vincle.photo
            {
                let imgData = Utils().imageFromBase64ToData(self.vincle.photo!)
                let xarxaImg = UIImage(data:imgData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.xarxaImgView.image = xarxaImg
                    print("IMAGE ADDED")
                })
            }
            else
            {
                Utils().retrieveUserVinclesProfilePhoto(vincle, completion: { (result, imgB64) in
                    
                    let imgData = Utils().imageFromBase64ToData(imgB64)
                    let xarxaImg = UIImage(data:imgData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.xarxaImgView.image = xarxaImg
                    })
                })
            }
        }
        else{
            
            let xarxaImg = UIImage(named: DEFAULT_PROFILE_IMAGE)
            self.xarxaImgView.image = xarxaImg
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
        
        let viewNameLbl = UILabel(frame:CGRectMake(0,0,150,70))
        viewNameLbl.text = langBundle.localizedStringForKey("NOTAS_NAVBAR_TITLE", value: nil, table: nil)
        viewNameLbl.textColor = UIColor.whiteColor()
        viewNameLbl.font = viewNameLbl.font.fontWithSize(21)
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
        
        
        xarxaImgView.contentMode = .ScaleAspectFill
        navBar?.addSubview(xarxaImgView)
        
        xarxaImgView.layer.borderColor = UIColor.whiteColor().CGColor
        xarxaImgView.layer.borderWidth = 0.0
        xarxaImgView.layer.masksToBounds = false
        xarxaImgView.layer.cornerRadius = xarxaImgView.frame.size.height/2
        xarxaImgView.clipsToBounds = true
        
        let pinRight = NSLayoutConstraint(item: xarxaImgView, attribute: .Right,
                                          relatedBy: .Equal, toItem: navBar, attribute: .RightMargin,
                                          multiplier: 1.0, constant: -57)
        let pinTop = NSLayoutConstraint(item: xarxaImgView, attribute: .Top,
                                        relatedBy: .Equal, toItem: navBar, attribute: .TopMargin,
                                        multiplier: 1.0, constant: -9)
        let heightConst = NSLayoutConstraint(item: xarxaImgView, attribute: .Height,
                                             relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                             multiplier: 1, constant: 40)
        let widthConst = NSLayoutConstraint(item: xarxaImgView, attribute: .Width,
                                            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                                            multiplier: 1, constant: 40)
        
        xarxaImgView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([pinRight,pinTop,heightConst,widthConst])

    }
    
    func textViewDidBeginEditing(textView: UITextView) {
      
        if textHasBeenSet {
            
        }else{
            notasTextView.text = ""
            textHasBeenSet = true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if notasTextView.text != "" {
           NSUserDefaults.standardUserDefaults().setObject(notasTextView.text, forKey:"NotasString")
            NSUserDefaults.standardUserDefaults().synchronize()
            textHasBeenSet = true
        }else{
           notasTextView.text = langBundle.localizedStringForKey("TEXT_VIEW_PLACEHOLDER", value: nil, table: nil)
            textHasBeenSet = false
        }
    }
    
    @IBAction func navCallBtnPress(sender: UIBarButtonItem) {
        
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
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        let dict = notification.userInfo
        let kbSize = dict![UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let windowFrame = self.view.window?.convertRect(self.view.frame, fromView: self.view)
        let keybFrame = CGRectIntersection(windowFrame!, kbSize!)
        let coveredFrame = self.view.window?.convertRect(keybFrame, toView: self.view)
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, (coveredFrame?.size.height)!, 0.0)
        self.notasTextView.contentInset = contentInsets
        self.notasTextView.scrollIndicatorInsets = contentInsets
        
        notasTextView.scrollRectToVisible((self.notasTextView.superview?.frame)!, animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let contentInsets = UIEdgeInsetsZero
        self.notasTextView.contentInset = contentInsets
        self.notasTextView.scrollIndicatorInsets = contentInsets
        
    }

}
