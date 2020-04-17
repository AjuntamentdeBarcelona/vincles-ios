//
//  GroupInfoHeaderCollectionReusableView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class GroupInfoHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // setup "lblTitle":
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping
        headerLabel.sizeToFit()
    }
}
