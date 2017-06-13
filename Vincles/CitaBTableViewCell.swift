/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class CitaBTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var ocupatTitle: UILabel!
    
    var cellCita:Cita!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setupCell() {
        
        let langBundle = UserPreferences().bundleForLanguageSelected()
        
        let hourFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "H:mm"
        
        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        
        let toDate = calendar.dateByAddingUnit(.Minute, value: Int(cellCita.duration!)!, toDate: cellCita.date!, options: [])

        
        
        fromTimeLabel.text = hourFormatter.stringFromDate(cellCita.date!)
        toTimeLabel.text = hourFormatter.stringFromDate(toDate!)
        
        ocupatTitle.text = langBundle.localizedStringForKey("CELL_TITLE_OCCUPIED", value: nil, table: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
