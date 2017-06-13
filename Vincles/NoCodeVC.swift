/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class NoCodeVC: UIViewController {
    
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    var comesFrom:comeFromView!
    
    let langBundle:NSBundle = {
        
        return UserPreferences().bundleForLanguageSelected()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.text = langBundle.localizedStringForKey("NO_CODE_INFO_TEXT", value: nil, table: nil)
        backBtn.setTitle(langBundle.localizedStringForKey("BTN_CODE_BACK", value: nil, table: nil), forState: .Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "noCode_IntroCode" {
           let vc = segue.destinationViewController as! IntroCodeViewController
            vc.comesFrom = comesFrom
        }
    }
    
    
    @IBAction func backBtnPressed(sender: UIButton) {
        
        performSegueWithIdentifier("noCode_IntroCode", sender: nil)
    }



}
