//
//  GallerySwipeCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class GallerySwipeCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var contentId = -1
    var loadingImage = false
    var isVideo = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale=1;
        self.scrollView.maximumZoomScale=6.0;
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func configWithCont(contentId: Int){
   
        self.contentId = contentId
        self.backgroundColor = UIColor(named: .clearGrayChat)
        self.imageView.backgroundColor = UIColor(named: .clearGrayChat)
        
        downloadButton.addTargetClosure { (sender) in
            self.downloadButton.isHidden = true
            self.setImageWith(contentId: contentId)
        }
        
    
        if ContentManager.sharedInstance.errorIds.contains(contentId){
            setError()
            return
        }
        
        downloadButton.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        if let url = ContentManager.sharedInstance.getGalleryMediaImageUrl(contentId: contentId, isGroup: false, messageType: .image),  let image = UIImage(contentsOfFile: url.path){
            imageView.image = image
            self.backgroundColor = .white
            self.imageView.backgroundColor = .white
          
        }
        else{
            if UserDefaults.standard.bool(forKey: "manualDownload") && !ContentManager.sharedInstance.galleryMediaExists(contentId: contentId, isGroup: false){
                imageView.image = UIImage()
                self.activityIndicator.isHidden = true
                downloadButton.isHidden = false
            }
            else{
                downloadButton.isHidden = true
                self.setImageWith(contentId: contentId)
                
            }
        }
        
        
        
    }
    
    func setImageWith(contentId: Int){
        if let url = ContentManager.sharedInstance.getGalleryMedia(contentId: contentId, isGroup: false, messageType: .image){
            DispatchQueue.main.async {
                if let image = UIImage(contentsOfFile: url.path) {
                    self.backgroundColor = .white
                    self.imageView.backgroundColor = .white
                    self.imageView.image = image
                    self.activityIndicator.isHidden = true
                }
                self.downloadButton.isHidden = true
            }
        }
        else{
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage()
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
                self.downloadButton.isHidden = true
            }
        }
    }
    
    func setError(){
        self.activityIndicator.isHidden = true
        self.downloadButton.isHidden = false
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @objc func tapAction(_sender:UITapGestureRecognizer){
        if self.scrollView.zoomScale > 3 {
            self.scrollView.setZoomScale(1, animated: true)
        } else {
            self.scrollView.setZoomScale(4, animated: true)
        }
        
    }
    
}
