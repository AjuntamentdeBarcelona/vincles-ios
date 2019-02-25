//
//  DropDownTableViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class DropDownTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.label.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
        self.label.textAlignment  = .center
        
        // Configure the view for the selected state
    }

}
