//
//  GaleriaLoadingCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class GaleriaLoadingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    override func awakeFromNib() {
        actInd.startAnimating()
        
    }
}
