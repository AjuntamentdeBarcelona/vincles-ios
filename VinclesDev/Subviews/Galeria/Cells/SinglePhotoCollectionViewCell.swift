//
//  SinglePhotoCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class SinglePhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImage: UIImageView!
    var loadingImage = false
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        self.photoImage.image = UIImage()
        
    }
    
    func configWithContent(content: Content){
        let mediaManager = MediaManager()
        photoImage.image = UIImage()
        self.photoImage.backgroundColor = UIColor(named: .clearGrayChat)
        print(content.id)
        if activityIndicator != nil{
            activityIndicator.hidesWhenStopped = true
        }

        
        if UserDefaults.standard.bool(forKey: "manualDownload") && !mediaManager.existingItem(id: content.id, mimeType: content.mimeType){
            self.backgroundColor = UIColor(named: .clearGrayChat)
            downloadButton.isHidden = false
            if activityIndicator != nil{

              self.activityIndicator.isHidden = true
            }
        }
        else{

            downloadContent(content: content)
        }
      
        downloadButton.addTargetClosure { (sender) in
            self.downloadContent(content: content)
            
        }
        
  
    }
    
    func downloadContent(content: Content){
        self.backgroundColor = UIColor.white
        if self.activityIndicator != nil{
            activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
        }
 
        
        print(content.id)
        let mediaManager = MediaManager()

        downloadButton.isHidden = true
        
        photoImage.tag = content.idContent
        
        mediaManager.setGalleryPicture(contentId: content.idContent, imageView: photoImage,  playButton: nil, downloadButton: downloadButton, activityIndicator: activityIndicator, onCompletion: { (success, id) in
            DispatchQueue.main.async {
                if success{
                    self.downloadButton.isHidden = true
                    if self.activityIndicator != nil{
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.removeFromSuperview()
                    }
                    self.photoImage.backgroundColor = .white

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
