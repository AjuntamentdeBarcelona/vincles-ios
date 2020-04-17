//
//  GalleryCollectionViewDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import SVProgressHUD

protocol GalleryCollectionViewDataSourceClickDelegate{
    func selectedContent(index: Int)
    func selectedShareFiles(indexes: [Int])
    func loadMoreItems()
    func reloadCollectionView()
    func showMaxError()
    func showVideoCorruptedError()

}

class GalleryCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var galleryManager: GalleryManager?
    
    var cellSpacing = CGFloat(5.0)
    var columns = 1
    var clickDelegate: GalleryCollectionViewDataSourceClickDelegate?
    var horizontalInsets = CGFloat(10.0)
    var selectedIndexPaths:[Int] = []
    var selectionMode = false
    var galleryModelManager: GalleryModelManagerProtocol!
    
    var galleryFilter: FilterContentType = .all
    
    var maxSelectItems = 10
    
    var deleteMode = false
    var selectAllMode = false
    
    
    func selectAll(){
        self.selectAllMode = true
        for i in 0..<self.getNumberOfItems(){
            selectedIndexPaths.append(i)
        }
      
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  
        return self.getNumberOfItems()
        
    }
    
    func getNumberOfItems() -> Int{
        var loading = 0
        if galleryManager!.loadingItems{
            print("LOADING ITEMS")

            loading = 1
        }
        else{
            print("NOT LOADING ITEMS")

        }
        switch galleryFilter {
        case .all:
            print("COUNT \(galleryModelManager.numberOfContents + loading)")
            return galleryModelManager.numberOfContents + loading
        case .mine:
            return galleryModelManager.numberOfMineContents + loading
        case .sent:
            return galleryModelManager.numberOfSharedContents + loading
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingCell(indexPath: indexPath){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! GaleriaLoadingCollectionViewCell
            cell.actInd.startAnimating()

            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! GaleriaItemCollectionViewCell
        cell.playButton.isHidden = true
       

        
        switch galleryFilter {
        case .all:
            if let content = galleryModelManager.contentAt(index: indexPath.row){
                cell.configWithCont(contentId: content.idContent , selectionMode: selectionMode, selected: selectedIndexPaths.contains(indexPath.row), isVideo: content.mimeType.contains("video"))
                
               
            }
        case .mine:
            if let content = galleryModelManager.mineContentAt(index: indexPath.row){
                cell.configWithCont(contentId: content.idContent , selectionMode: selectionMode, selected: selectedIndexPaths.contains(indexPath.row), isVideo: content.mimeType.contains("video"))
            }
        case .sent:
            if let content = galleryModelManager.sharedContentAt(index: indexPath.row){
                cell.configWithCont(contentId: content.idContent , selectionMode: selectionMode, selected: selectedIndexPaths.contains(indexPath.row), isVideo: content.mimeType.contains("video"))
            }        }
        
        
        
        return cell
    }
    
    func isLoadingCell(indexPath: IndexPath) -> Bool{
        if galleryManager!.loadingItems{
            switch galleryFilter {
            case .all:
                if indexPath.row == galleryModelManager.numberOfContents{
                    return true
                }
            case .mine:
                if indexPath.row == galleryModelManager.numberOfMineContents{
                    return true
                    
                }
            case .sent:
                if indexPath.row == galleryModelManager.numberOfSharedContents{
                    return true
                }
            }
        }
        return false
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isLoadingCell(indexPath: indexPath){
            return CGSize(width: collectionView.frame.size.width, height: 40)
        }
        
        return CGSize(width: collectionView.bounds.size.width/CGFloat(columns) - cellSpacing - (horizontalInsets * 2/CGFloat(columns)), height: collectionView.bounds.size.width/CGFloat(columns) - cellSpacing - (horizontalInsets * 2/CGFloat(columns)))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: horizontalInsets, bottom: 0, right: horizontalInsets)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoadingCell(indexPath: indexPath){
            return
        }
        
        if selectionMode{
            let cell = collectionView.cellForItem(at: indexPath) as! GaleriaItemCollectionViewCell
            
            let mediaManager = MediaManager()
            var content: Content?
            
            switch galleryFilter {
            case .all:
                content = galleryModelManager.contentAt(index: indexPath.row)
            case .mine:
                content = galleryModelManager.mineContentAt(index: indexPath.row)
            case .sent:
                content = galleryModelManager.sharedContentAt(index: indexPath.row)
            }
            
            if let content = content{
                if ContentManager.sharedInstance.existingItem(id: content.idContent, mimeType: content.mimeType){
                    if selectedIndexPaths.contains(indexPath.row){
                        cell.checkBox.setOn(false, animated: true)
                        selectedIndexPaths.remove(at: selectedIndexPaths.index(of: indexPath.row)!)
                        self.selectAllMode = false
                    }else if selectedIndexPaths.count < maxSelectItems || deleteMode{
                        cell.checkBox.setOn(true, animated: true)
                        selectedIndexPaths.append(indexPath.row)
                    }else{
                        clickDelegate?.showMaxError()

                    }
                    clickDelegate?.selectedShareFiles(indexes: selectedItemsForSelectedIndexPaths().0)
                }
            }
            
            
        }
        else{
            let cell = collectionView.cellForItem(at: indexPath) as! GaleriaItemCollectionViewCell
            
            if cell.thumbImage.image?.size != CGSize.zero{
                clickDelegate?.selectedContent(index: indexPath.row)
            }
            else if !cell.videoCorruptedButton.isHidden{
                clickDelegate?.showVideoCorruptedError()
            }
            else{
                switch galleryFilter {
                case .all:
                    if let content = galleryModelManager.contentAt(index: indexPath.row){
                        cell.setImageWith(contentId: content.idContent, selectionMode: false, selected: false, isVideo: content.mimeType.contains("video"))
                    }
                case .mine:
                    if let content = galleryModelManager.mineContentAt(index: indexPath.row){
                        cell.setImageWith(contentId: content.idContent, selectionMode: false, selected: false, isVideo: content.mimeType.contains("video"))
                    }
                case .sent:
                    if let content = galleryModelManager.sharedContentAt(index: indexPath.row){
                        cell.setImageWith(contentId: content.idContent, selectionMode: false, selected: false, isVideo: content.mimeType.contains("video"))
                    }
                    
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*
         if let galleryManagerDate = galleryManager?.lastItemDate, galleryManagerDate == modelManager.contentAt(index: indexPath.row).inclusionTime, let loading = galleryManager?.loadingItems, loading == false{
         clickDelegate?.loadMoreItems()
         }
         */
        if isLoadingCell(indexPath: indexPath){
            return
        }
        else{
            if let cell = cell as? GaleriaItemCollectionViewCell{
                cell.configWithCont(contentId: cell.contentId, selectionMode: selectionMode, selected: selectedIndexPaths.contains(indexPath.row), isVideo: cell.isVideo)
            }
        }
        
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1{
            if !galleryManager!.loadingItems{
                
                loadNext()
            }
            
        }
    }
    
    func loadNext(){

        let prevItemCount = getNumberOfItems()
        
        if !(galleryManager?.reachedEnd)! && getNumberOfItems() >= 10{
         
            DispatchQueue.main.async {
                
                self.clickDelegate?.reloadCollectionView()
            }
            
            galleryManager!.getContentsLibrary(onSuccess: { (hasMoreItems, needsReload) in

                        DispatchQueue.main.async {
                            let newItemCount = self.getNumberOfItems()

                            if self.selectAllMode{
                                for i in prevItemCount..<newItemCount{
                                    self.selectedIndexPaths.append(i)
                                }
                            }
                            self.clickDelegate?.reloadCollectionView()
                        }
                
            }) { (error) in
                
                
            }
            
        }
        
    }
    
    func selectedItemsForSelectedIndexPaths() -> ([Int], [String]){
        var selectedItems = [Int]()
        var selectedMetadataTipus = [String]()
        
        for index in selectedIndexPaths{
            var item: Content?
            switch galleryFilter {
            case .all:
                item = galleryModelManager.contentAt(index: index)
            case .mine:
                item = galleryModelManager.mineContentAt(index: index)
            case .sent:
                item = galleryModelManager.sharedContentAt(index: index)
                
            }
            if item != nil{
                selectedItems.append(item!.idContent)
                if item!.mimeType.contains("video"){
                    selectedMetadataTipus.append("VIDEO_MESSAGE")
                }
                else{
                    selectedMetadataTipus.append("IMAGES_MESSAGE")
                }
            }
            
        }
        return (selectedItems, selectedMetadataTipus)
    }
}




