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
    @IBOutlet weak var videoCorruptedButton: UIButton!
    @IBOutlet weak var contentVideoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!

    var loadingImage = false
    var contentId = -1
    var isVideo = true
    
    override func awakeFromNib() {
        self.photoImage.image = UIImage()
        self.activityIndicator.isHidden = true
        if self.activityIndicator != nil{
            self.activityIndicator.stopAnimating()
            activityIndicator.hidesWhenStopped = true
            
        }
        videoCorruptedButton.isHidden = true
        self.backgroundColor = UIColor(named: .clearGrayChat)
        self.photoImage.backgroundColor = UIColor(named: .clearGrayChat)
    }
    
    func configWithCont(contentId: Int){
       
        typeLabel.text = "\(contentId)"
        typeLabel.isHidden = true
        photoImage.image = UIImage()
        self.backgroundColor = UIColor(named: .clearGrayChat)
        self.photoImage.backgroundColor = UIColor(named: .clearGrayChat)
        
        self.contentId = contentId
        downloadButton.isHidden = true
        self.videoCorruptedButton.isHidden = true
        self.playButton.isHidden = true

        activityIndicator.hidesWhenStopped = true
        
        downloadButton.addTargetClosure { (sender) in
            self.downloadButton.isHidden = true
            self.setImageWith(contentId: contentId)
        }
        
        if ContentManager.sharedInstance.corruptedIds.contains(contentId){
            setVideoCorrupted()
            return
        }
        
        if ContentManager.sharedInstance.errorIds.contains(contentId){
            setError()
            return
        }
        
        if let url = ContentManager.sharedInstance.getGalleryMediaImageUrl(contentId: contentId, isGroup: false, messageType: isVideo ? .video : .image),  let image = UIImage(contentsOfFile: url.path){
            photoImage.image = image
      
            if self.isVideo{
                self.playButton.isHidden = false
            }
            videoCorruptedButton.isHidden = true
            self.backgroundColor = .white
            self.photoImage.backgroundColor = .white
        }
        else{
            if UserDefaults.standard.bool(forKey: "manualDownload") && !ContentManager.sharedInstance.galleryMediaExists(contentId: contentId, isGroup: false){
                photoImage.image = UIImage()
                playButton.isHidden = true
                self.activityIndicator.isHidden = true
                downloadButton.isHidden = false
            }
            else if isVideo && ContentManager.sharedInstance.corruptedIds.contains(contentId){
                setVideoCorrupted()
            }
            else{

                downloadButton.isHidden = true
                self.setImageWith(contentId: contentId)
            }
            
        }
        
        
       
    }
    
    func setImageWith(contentId: Int){
        if let url = ContentManager.sharedInstance.getGalleryMedia(contentId: contentId, isGroup: false,  messageType: isVideo ? .video : .image){
            DispatchQueue.main.async {
                self.playButton.isHidden = true
                if let image = UIImage(contentsOfFile: url.path) {
                    self.backgroundColor = .white
                    self.photoImage.backgroundColor = .white
                    self.photoImage.image = image
                    self.activityIndicator.isHidden = true
                    if self.isVideo{
                        self.playButton.isHidden = false
                    }
                }
                self.videoCorruptedButton.isHidden = true
                self.downloadButton.isHidden = true
                
            }
        }
        else{
            
            DispatchQueue.main.async {
                self.photoImage.image = UIImage()
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
                self.videoCorruptedButton.isHidden = true
                self.downloadButton.isHidden = true
                
            }
            
        }
    }
    
    func setError(){
        self.activityIndicator.isHidden = true
        self.playButton.isHidden = true
        self.downloadButton.isHidden = false
        self.videoCorruptedButton.isHidden = true
        
    }
    
    func setVideoCorrupted(){
        self.activityIndicator.isHidden = true
        self.playButton.isHidden = true
        self.downloadButton.isHidden = true
        self.videoCorruptedButton.isHidden = false
        
    }
}
