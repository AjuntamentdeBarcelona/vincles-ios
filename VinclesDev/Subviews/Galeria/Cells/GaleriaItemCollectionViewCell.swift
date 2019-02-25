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

        var loadingImage = false
        var loadingVideo = false
        
        var index = -1
        var contentId = -1
        
        override func awakeFromNib() {
            self.thumbImage.image = UIImage()
            checkBox.onAnimationType = .stroke
            
        }
        
        func configWithCont(content: Content, selectionMode: Bool, selected: Bool){
            let mediaManager = MediaManager()
            typeLabel.isHidden = true
            activityIndicator.hidesWhenStopped = true
            thumbImage.image = UIImage()
            
            checkBox.isHidden = !selectionMode
            checkBox.on = selected
            
            typeLabel.text = "\(content.id) \(content.mimeType)"
            if UserDefaults.standard.bool(forKey: "manualDownload") && !mediaManager.existingItem(id: content.id, mimeType: content.mimeType){
                playButton.isHidden = true
                self.activityIndicator.isHidden = true
                downloadButton.isHidden = false
            }
            else{
                downloadButton.isHidden = true
                
                self.downloadContent(content: content)
            }
            
            downloadButton.addTargetClosure { (sender) in
                self.downloadContent(content: content)
            }
        }
        
        func downloadContent(content: Content){
            let mediaManager = MediaManager()
            
            downloadButton.isHidden = true
            
            activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false

            if content.mimeType.contains("image"){
                playButton.isHidden = true
                thumbImage.tag = content.idContent
                downloadButton.tag = content.idContent
                playButton.tag = content.idContent
                activityIndicator.tag = content.idContent

                mediaManager.setGalleryPicture(contentId: content.idContent, imageView: thumbImage, playButton: playButton, downloadButton: downloadButton, activityIndicator: activityIndicator, isThumb: true, onCompletion: { (success, id) in
                    /*
                    DispatchQueue.main.async {
                        if success && id == content.id{
                            self.downloadButton.isHidden = true
                            self.playButton.isHidden = true

                        }
                        else{
                            self.playButton.isHidden = true
                            self.activityIndicator.isHidden = true
                            self.downloadButton.isHidden = false
                        }
                    }
     */
                   
                   
                })
            }
            else if content.mimeType.contains("video"){
                
                thumbImage.tag = content.idContent
                self.playButton.isHidden = true
                
                downloadButton.tag = content.idContent
                playButton.tag = content.idContent
                activityIndicator.tag = content.idContent

                
                mediaManager.setGalleryVideo(contentId: content.idContent, imageView: thumbImage,playButton: playButton, downloadButton: downloadButton, activityIndicator: activityIndicator, isThumb: true, onCompletion: { (success, fileUrl, id) in
                  
                    /*
                    DispatchQueue.main.async {
                        if success && id == content.id{
                            self.downloadButton.isHidden = true
                            self.playButton.isHidden = false

                        }
                        else{
                            self.playButton.isHidden = true
                            self.activityIndicator.isHidden = true
                            self.downloadButton.isHidden = false
                        }
                    }
     */
                    
                })
            }
        }
        
    }
    
    
    
