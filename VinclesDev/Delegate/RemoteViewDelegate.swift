//
//  RemoteViewDelegate.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol RemoteViewDelegateChangeSizeDelegate{
    func remoteChangedSize(size: CGSize)
    
}

class RemoteViewDelegate: NSObject {
    
    var sizeDelegate: RemoteViewDelegateChangeSizeDelegate?
    
    /*
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        print("changed RemoteViewDelegate")
        sizeDelegate?.remoteChangedSize(size: size)
    }
*/
}
