/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class TermsConditionsVC: VinclesVC {
    
    @IBOutlet weak var btnCancelar: UIButton!
    @IBOutlet weak var btnAceptar: UIButton!
    @IBOutlet weak var txtTerms: UITextView!
    @IBOutlet weak var txtTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = TERMSCONDITIONS_VC
        UserPreferences().createPrefDictsWithDefault()

        setUI()
    }
    
    func setUI() {
        btnAceptar.backgroundColor = UIColor(hexString: HEX_RED_BTN)
        
        txtTerms.text = (self.nibBundle?.localizedStringForKey("TERMS_AND_CONDITIONS", value: nil, table: nil))!
        
        txtTitle.text = (self.nibBundle?.localizedStringForKey("TERMS_AND_CONDITIONS_TITLE", value: nil, table: nil))!
        
        btnCancelar.setTitle(self.nibBundle?.localizedStringForKey("BTN_CANCEL_SEND_TITLE", value: nil, table: nil), forState: .Normal)
        btnAceptar.setTitle(self.nibBundle?.localizedStringForKey("BTN_ACCEPT_TITLE", value: nil, table: nil), forState: .Normal)
    }

    override func viewDidAppear(animated: Bool) {
        
        btnCancelar.layer.cornerRadius = 4.0

        btnAceptar.layer.cornerRadius = 4.0
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        
        let alert = UIAlertController(title: self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_CAMPS_TITLE", value: nil, table: nil), message: self.nibBundle?.localizedStringForKey("ALERT_MUST_ACCEPT_TERMS", value: nil, table: nil), preferredStyle: .Alert)
        let action = UIAlertAction(title: self.nibBundle?.localizedStringForKey("ALERT_INTROCODE_CAMPS_ACTION", value: nil, table: nil), style: .Default) { _ in
            
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true){}
        
    }
}
