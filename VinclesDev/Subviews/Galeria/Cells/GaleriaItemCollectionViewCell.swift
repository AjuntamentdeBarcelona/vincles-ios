    //
    //  GaleriaItemCollectionViewCell.swift
    //  Vincles BCN
    //
    //  Copyright © 2018 i2Cat. All rights reserved.
    
    
    import UIKit
    import BEMCheckBox
    import AlamofireImage
    import Alamofire
    
    class GaleriaItemCollectionViewCell: UICollectionViewCell {
        
        @IBOutlet weak var thumbImage: UIImageView!
        @IBOutlet weak var playButton: UIButton!
        @IBOutlet weak var checkBox: BEMCheckBox!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        @IBOutlet weak var downloadButton: UIButton!
        @IBOutlet weak var typeLabel: UILabel!
        @IBOutlet weak var videoCorruptedButton: UIButton!

        var contentId = -1
        var isVideo = false
        
        override func awakeFromNib() {
            checkBox.onAnimationType = .stroke
            self.playButton.isHidden = true
            self.videoCorruptedButton.isHidden = true
        }
        
      
        func configWithCont(contentId: Int, selectionMode: Bool, selected: Bool, isVideo: Bool){
            thumbImage.image = UIImage()

          
            self.contentId = contentId
            self.isVideo = isVideo
            downloadButton.isHidden = true

            typeLabel.isHidden = true
            typeLabel.backgroundColor = .white
            self.videoCorruptedButton.isHidden = true
            self.playButton.isHidden = true
            typeLabel.text = "\(contentId) \(isVideo)"
            activityIndicator.hidesWhenStopped = true
            
            checkBox.isHidden = true
            
            downloadButton.addTargetClosure { (sender) in
                self.downloadButton.isHidden = true
                self.setImageWith(contentId: contentId, selectionMode: selectionMode, selected: selected, isVideo: isVideo)
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
                    thumbImage.image = image

                    if self.isVideo{
                        self.playButton.isHidden = false
                    }
                    checkBox.isHidden = !selectionMode
                    checkBox.on = selected
                    videoCorruptedButton.isHidden = true

                }
                else{
                    if UserDefaults.standard.bool(forKey: "manualDownload") && !ContentManager.sharedInstance.galleryMediaExists(contentId: contentId, isGroup: false){
                        thumbImage.image = UIImage()
                        playButton.isHidden = true
                        self.activityIndicator.isHidden = true
                        downloadButton.isHidden = false
                    }
                    else if isVideo && ContentManager.sharedInstance.corruptedIds.contains(contentId){

                        setVideoCorrupted()
                    }
                    else{
                        downloadButton.isHidden = true

                        self.setImageWith(contentId: contentId, selectionMode: selectionMode, selected: selected, isVideo: isVideo)
                    }
                    
        
             }
        

          
        }
       
        func setImageWith(contentId: Int, selectionMode: Bool, selected: Bool, isVideo: Bool){
            if let url = ContentManager.sharedInstance.getGalleryMedia(contentId: contentId, isGroup: false, messageType: isVideo ? .video : .image){
                DispatchQueue.main.async {
                    self.playButton.isHidden = true
                    if let image = UIImage(contentsOfFile: url.path) {
                        self.thumbImage.image = image
                        self.activityIndicator.isHidden = true
                        if isVideo{
                            self.playButton.isHidden = false
                        }
                    }
                    self.checkBox.isHidden = !selectionMode
                    self.checkBox.on = selected
                    self.videoCorruptedButton.isHidden = true
                    self.downloadButton.isHidden = true

                }
            }
            else{
                
                DispatchQueue.main.async {
                    self.thumbImage.image = UIImage()
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
