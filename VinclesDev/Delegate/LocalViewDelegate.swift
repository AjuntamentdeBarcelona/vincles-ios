//
//  LocalViewDelegate.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import webrtcat4

protocol LocalViewDelegateChangeSizeDelegate{
    func localChangedSize(size: CGSize)
    
}

class LocalViewDelegate: NSObject, RTCEAGLVideoViewDelegate {
    
    var sizeDelegate: LocalViewDelegateChangeSizeDelegate?
    
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        print("changed LocalViewDelegate")

        sizeDelegate?.localChangedSize(size: size)

    }
    
}
