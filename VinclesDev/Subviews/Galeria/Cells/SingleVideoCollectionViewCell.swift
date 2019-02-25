//
//  SingleVideoCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import AVKit

class SingleVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //  var avPlayer: AVPlayer!
    
    @IBOutlet weak var contentVideoView: UIView!
    @IBOutlet weak var playButton: UIButton?
    var loadingImage = false
    
    override func awakeFromNib() {
        self.photoImage.image = UIImage()
        self.activityIndicator.isHidden = true
        if self.activityIndicator != nil{
            self.activityIndicator.stopAnimating()
            activityIndicator.hidesWhenStopped = true
            
        }
        
    }
    
    func configWithContent(content: Content){
        self.photoImage.image = UIImage()
        self.backgroundColor = UIColor(named: .clearGrayChat)
        let mediaManager = MediaManager()
        
        print(content.userName)
        
        if UserDefaults.standard.bool(forKey: "manualDownload") && !mediaManager.existingItem(id: content.id, mimeType: content.mimeType){
            self.backgroundColor = UIColor(named: .clearGrayChat)
            downloadButton.isHidden = false
            self.photoImage.backgroundColor = UIColor(named: .clearGrayChat)
            playButton?.isHidden = true
            if self.activityIndicator != nil{
                self.activityIndicator.isHidden = true
            }
            
        }
        else{
            self.photoImage.backgroundColor = UIColor.clear
            playButton?.isHidden = false
            
            downloadContent(content: content)
        }
        
        downloadButton.addTargetClosure { (sender) in
            self.downloadContent(content: content)
            
        }
    }
    
    func downloadContent(content: Content){
        
        if self.activityIndicator != nil{
            
            activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
        
        downloadButton.isHidden = true
        
        let mediaManager = MediaManager()
        
        photoImage.tag = content.idContent
        downloadButton.tag = content.idContent
        playButton?.tag = content.idContent

        mediaManager.setGalleryVideo(contentId: content.idContent, imageView: photoImage,  onCompletion: { (success, fileUrl, id) in
            DispatchQueue.main.async {
                if success{
                    self.downloadButton.isHidden = true
                    if self.activityIndicator != nil{
                        self.activityIndicator.isHidden = true
                    }
                    self.photoImage.backgroundColor = .white
                    self.playButton?.isHidden = false
                    if self.activityIndicator != nil{
                        
                        
                        self.activityIndicator.removeFromSuperview()
                    }
                }
                else{
                    if self.activityIndicator != nil{
                        self.activityIndicator.isHidden = true
                        
                    }
                    self.downloadButton.isHidden = false
                }
            }
        })
    }
}
