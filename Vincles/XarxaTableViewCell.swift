/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class XarxaTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userXarxaName: UILabel!
    @IBOutlet weak var userXarxaImg: UIImageView!
    @IBOutlet weak var imgViewXarxaSelected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
