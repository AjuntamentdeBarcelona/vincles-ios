/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class NouMissatgeVC: UIViewController {
    
    @IBOutlet weak var pagesView: SwiftPages!
    @IBOutlet weak var newMsgLabelTitle: UILabel!
    
    var VCIDs = ["MsgVideoVC","MsgFotoVC","MsgTextFotoVC"]
    var VCIDimgs:[UIImage] = []
    
    let userCercle:UserCercle = {
        UserCercle.loadUserCercleCoreData()
        }()!

    let langBundle:NSBundle = {
        return UserPreferences().bundleForLanguageSelected()
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setPages()
        
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return false
    }

    override func viewWillAppear(animated: Bool) {
        
        
    }

    func setUI() {
        
        let imgVideo = UIImage(named: "icon-video-white")
        let imgFoto = UIImage(named: "icon-image-white")
        let imgTextFoto = UIImage(named: "mensaje-texto-blanco")
        
        VCIDimgs = [imgVideo!,imgFoto!,imgTextFoto!]
        
        self.view.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        self.navigationController?.navigationBar.translucent = false
    }
    
    
    func setPages() {
        
        automaticallyAdjustsScrollViewInsets = false
        pagesView.setOriginY(0.0)
        pagesView.setOriginX(0.0)
        pagesView.setAnimatedBarColor(UIColor(hexString: HEX_RED_BTN))
        pagesView.setContainerViewBackground(UIColor.darkGrayColor())
        pagesView.setButtonsTextColor(UIColor.whiteColor())
        pagesView.setTopBarBackground(UIColor(hexString: HEX_GRAY_BTN))
        pagesView.setAnimatedBarHeight(5)
        pagesView.initializeWithVCIDsArrayAndButtonImagesArray(VCIDs, buttonImagesArray: VCIDimgs)
        
    }
    
    @IBAction func backBtnPress(sender: UIButton) {
        
        
    }
    
    
    @IBAction func videoCallBtnPress(sender: UIBarButtonItem) {
        if let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as? SWRevealViewController {
            SingletonVars.sharedInstance.initMenuHasToChange = true
            SingletonVars.sharedInstance.initDestination = .Trucant
            SingletonVars.sharedInstance.idUserCall = self.userCercle.id!
            self.presentViewController(secondViewController, animated: true, completion:nil)
        }
    }
    
}
