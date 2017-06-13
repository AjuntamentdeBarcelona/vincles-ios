/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class PageContentViewController: UIViewController {

    var pageIndex = 0
    var imgFile = ""
    var labelText = ""
    
    
    @IBOutlet weak var imagePageContent: UIImageView!
    
    @IBOutlet weak var labelPageContent: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePageContent.image = UIImage(named:imgFile)
        labelPageContent.text = labelText
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
