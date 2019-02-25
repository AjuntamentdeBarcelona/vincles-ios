//
//  GalleryDetailCollectionViewDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit


protocol GalleryDetailCollectionViewDataSourceClickDelegate{
    func selectedContent(content: Content)
    func didScrollTo(content: Content, index: Int)
    func selectedImageView(imageView: UIImageView)
    func loadMoreItems()
}

class GalleryDetailCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cellSpacing = CGFloat(0.0)
    var clickDelegate: GalleryDetailCollectionViewDataSourceClickDelegate?
    var galleryManager: GalleryManager?
    var galleryFilter: FilterContentType = .all
    var galleryModelManager: GalleryModelManagerProtocol!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        switch galleryFilter {
        case .all:
            return galleryModelManager.numberOfContents
        case .mine:
            return galleryModelManager.numberOfMineContents
        case .sent:
            return galleryModelManager.numberOfSharedContents
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var content: Content?
        switch galleryFilter {
        case .all:
            content = galleryModelManager.contentAt(index: indexPath.row)
        case .mine:
            content = galleryModelManager.mineContentAt(index: indexPath.row)
        case .sent:
            content = galleryModelManager.sharedContentAt(index: indexPath.row)
        }
        
        if (content?.mimeType.contains("image"))!{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! SinglePhotoCollectionViewCell
            switch galleryFilter {
            case .all:
                cell.configWithContent(content: galleryModelManager.contentAt(index: indexPath.row))
            case .mine:
                cell.configWithContent(content: galleryModelManager.mineContentAt(index: indexPath.row))
            case .sent:
                cell.configWithContent(content: galleryModelManager.sharedContentAt(index: indexPath.row))
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! SingleVideoCollectionViewCell
        switch galleryFilter {
        case .all:
            cell.configWithContent(content: galleryModelManager.contentAt(index: indexPath.row))
        case .mine:
            cell.configWithContent(content: galleryModelManager.mineContentAt(index: indexPath.row))
        case .sent:
            cell.configWithContent(content: galleryModelManager.sharedContentAt(index: indexPath.row))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch galleryFilter {
        case .all:
            if galleryModelManager.contentAt(index: indexPath.row).mimeType.contains("video"){
                let cell = collectionView.cellForItem(at: indexPath) as! SingleVideoCollectionViewCell  

                if cell.photoImage.image?.size != CGSize.zero{
                    clickDelegate?.selectedContent(content: galleryModelManager.contentAt(index: indexPath.row))
                    if cell.activityIndicator != nil{
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }
                   
                }
                else{
                    cell.downloadContent(content: galleryModelManager.contentAt(index: indexPath.row))
                }
            }
            else if galleryModelManager.contentAt(index: indexPath.row).mimeType.contains("image"){
                let cell = collectionView.cellForItem(at: indexPath) as! SinglePhotoCollectionViewCell
                if cell.photoImage.image?.size != CGSize.zero{
                    clickDelegate?.selectedImageView(imageView: cell.photoImage)
                    if cell.activityIndicator != nil{
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }
                }
                else{
                    cell.downloadContent(content: galleryModelManager.contentAt(index: indexPath.row))
                }
            }
        case .mine:
            if galleryModelManager.mineContentAt(index: indexPath.row).mimeType.contains("video"){
                let cell = collectionView.cellForItem(at: indexPath) as! SingleVideoCollectionViewCell
                
                if cell.photoImage.image?.size != CGSize.zero{
                    clickDelegate?.selectedContent(content: galleryModelManager.mineContentAt(index: indexPath.row))
                    if cell.activityIndicator != nil{
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }

                }
                else{
                    cell.downloadContent(content: galleryModelManager.mineContentAt(index: indexPath.row))
                }
            }
            else if galleryModelManager.mineContentAt(index: indexPath.row).mimeType.contains("image"){
                let cell = collectionView.cellForItem(at: indexPath) as! SinglePhotoCollectionViewCell
                if cell.photoImage.image?.size != CGSize.zero{
                    clickDelegate?.selectedImageView(imageView: cell.photoImage)
                    if cell.activityIndicator != nil{
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }
                }
                else{
                    cell.downloadContent(content: galleryModelManager.mineContentAt(index: indexPath.row))
                }
            }
        case .sent:
            if galleryModelManager.sharedContentAt(index: indexPath.row).mimeType.contains("video"){
                let cell = collectionView.cellForItem(at: indexPath) as! SingleVideoCollectionViewCell
                
                if cell.photoImage.image?.size != CGSize.zero{
                    clickDelegate?.selectedContent(content: galleryModelManager.sharedContentAt(index: indexPath.row))
                    if cell.activityIndicator != nil{
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }
                }
                else{
                    cell.downloadContent(content: galleryModelManager.sharedContentAt(index: indexPath.row))
                }
            }
            else if galleryModelManager.sharedContentAt(index: indexPath.row).mimeType.contains("image"){
                let cell = collectionView.cellForItem(at: indexPath) as! SinglePhotoCollectionViewCell
                if cell.photoImage.image?.size != CGSize.zero{
                    clickDelegate?.selectedImageView(imageView: cell.photoImage)
                    if cell.activityIndicator != nil{
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }
                }
                else{
                    cell.downloadContent(content: galleryModelManager.sharedContentAt(index: indexPath.row))
                }
            }
        }
        
       
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        
        switch galleryFilter {
        case .all:
            if currentPage >= 0 && currentPage < galleryModelManager.numberOfContents{
                
                clickDelegate?.didScrollTo(content: galleryModelManager.contentAt(index: currentPage), index: currentPage)
            }
        case .mine:
            if currentPage >= 0 && currentPage < galleryModelManager.numberOfMineContents{
                
                clickDelegate?.didScrollTo(content: galleryModelManager.mineContentAt(index: currentPage), index: currentPage)
            }
        case .sent:
            if currentPage >= 0 && currentPage < galleryModelManager.numberOfSharedContents{
                
                clickDelegate?.didScrollTo(content: galleryModelManager.sharedContentAt(index: currentPage), index: currentPage)
            }
            
        }
        
      
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*
        if let galleryManagerDate = galleryManager?.lastItemDate, galleryManagerDate == modelManager.contentAt(index: indexPath.row).inclusionTime, let loading = galleryManager?.loadingItems, loading == false{
            clickDelegate?.loadMoreItems()
        }
       */
    }
}


