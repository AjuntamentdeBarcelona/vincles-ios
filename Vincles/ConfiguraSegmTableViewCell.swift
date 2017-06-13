/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

protocol ConfiguraVCDelegate:class {
    
    func changeLanguageOnTouch(sender:ConfiguraSegmTableViewCell)
    func presentSettingsAlert(sender:ConfiguraSegmTableViewCell)
}

class ConfiguraSegmTableViewCell: UITableViewCell {
    
    weak var delegate:ConfiguraVCDelegate?
    
    @IBOutlet weak var titleLblSetting: UILabel!
    @IBOutlet weak var segmentconfi: UISegmentedControl!
    
    var delegateVC:ConfiguraVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(hexString: HEX_WHITE_BACKGROUND)
        
    }
    
    @IBAction func segmentTouched(sender: UISegmentedControl) {
        
        let nsusrSettings = NSUserDefaults.standardUserDefaults()
        
        switch sender.tag {
        case 0: // language
            var newDic = nsusrSettings.dictionaryForKey("language")
            newDic!["CatCast"] = sender.selectedSegmentIndex
            nsusrSettings.setValue(newDic, forKey: "language")
            nsusrSettings.synchronize()
            
            delegate?.changeLanguageOnTouch(self)
            
        case 1: // download
            var newDic = nsusrSettings.dictionaryForKey("download")
            newDic!["downloadAttach"] = sender.selectedSegmentIndex
            nsusrSettings.setValue(newDic, forKey: "download")
            nsusrSettings.synchronize()
            
        case 2: // calendar
            
            delegate?.presentSettingsAlert(self)
            
        default:
            print(sender.tag)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


