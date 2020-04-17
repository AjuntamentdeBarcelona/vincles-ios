//
//  LocalViewDelegate.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol LocalViewDelegateChangeSizeDelegate{
    func localChangedSize(size: CGSize)
    
}

class LocalViewDelegate: NSObject {
    
    var sizeDelegate: LocalViewDelegateChangeSizeDelegate?
    
}
