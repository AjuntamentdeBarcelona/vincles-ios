//
//  SinglePhotoCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class SinglePhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var videoCorruptedButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!

    var contentId = -1
    var loadingImage = false
    var isVideo = false
    
    override func awakeFromNib() {
        self.photoImage.image = UIImage()
        videoCorruptedButton.isHidden = true
        self.backgroundColor = UIColor(named: .clearGrayChat)
        self.photoImage.backgroundColor = UIColor(named: .clearGrayChat)
    }
    
    func configWithCont(contentId: Int){
        typeLabel.text = "\(contentId)"
        typeLabel.isHidden = true
        self.contentId = contentId
        self.backgroundColor = UIColor(named: .clearGrayChat)
        self.photoImage.backgroundColor = UIColor(named: .clearGrayChat)
        
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
        
        downloadButton.isHidden = true
        self.videoCorruptedButton.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        if let url = ContentManager.sharedInstance.getGalleryMediaImageUrl(contentId: contentId, isGroup: false, messageType: .image),  let image = UIImage(contentsOfFile: url.path){
            photoImage.image = image
            self.backgroundColor = .white
            self.photoImage.backgroundColor = .white
            videoCorruptedButton.isHidden = true
            typeLabel.text = "\(contentId) existing"

        }
        else{
            if UserDefaults.standard.bool(forKey: "manualDownload") && !ContentManager.sharedInstance.galleryMediaExists(contentId: contentId, isGroup: false){
                photoImage.image = UIImage()
                self.activityIndicator.isHidden = true
                downloadButton.isHidden = false
                typeLabel.text = "\(contentId) here"
            }
            else{
                downloadButton.isHidden = true
                self.setImageWith(contentId: contentId)
                typeLabel.text = "\(contentId) download"

            }
        }

      
  
    }
    
    func setImageWith(contentId: Int){
        if let url = ContentManager.sharedInstance.getGalleryMedia(contentId: contentId, isGroup: false, messageType: .image){
            DispatchQueue.main.async {
                if let image = UIImage(contentsOfFile: url.path) {
                    self.backgroundColor = .white
                    self.photoImage.backgroundColor = .white
                    self.photoImage.image = image
                    self.activityIndicator.isHidden = true
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
        self.downloadButton.isHidden = false
        self.videoCorruptedButton.isHidden = true
    }
    
    func setVideoCorrupted(){
        self.activityIndicator.isHidden = true
        self.downloadButton.isHidden = true
        self.videoCorruptedButton.isHidden = false
    }
    
}
