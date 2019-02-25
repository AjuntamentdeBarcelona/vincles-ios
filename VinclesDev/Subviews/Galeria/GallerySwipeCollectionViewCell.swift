//
//  GallerySwipeCollectionViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class GallerySwipeCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale=1;
        self.scrollView.maximumZoomScale=6.0;
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setContent(content: Content){
        
        self.imageView.tag = content.idContent
        MediaManager().setGalleryPicture(contentId: content.idContent, imageView: self.imageView, onCompletion: { (success, id) in
            if success {
                //self.scrollView.addSubview(self.imageView)
                self.scrollView.contentSize = self.scrollView.frame.size
                self.imageView.frame.size = self.scrollView.contentSize
            }
            
        })
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
