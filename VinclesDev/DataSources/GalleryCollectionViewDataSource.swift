//
//  GalleryCollectionViewDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit


protocol GalleryCollectionViewDataSourceClickDelegate{
    func selectedContent(index: Int)
    func selectedShareFiles(indexes: [Int])
    func loadMoreItems()
}

class GalleryCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var galleryManager: GalleryManager?
    
    var cellSpacing = CGFloat(5.0)
    var columns = 1
    var clickDelegate: GalleryCollectionViewDataSourceClickDelegate?
    var horizontalInsets = CGFloat(10.0)
    var selectedIndexPaths = [Int]()
    var selectionMode = false
    var galleryModelManager: GalleryModelManagerProtocol!

    var galleryFilter: FilterContentType = .all

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! GaleriaItemCollectionViewCell

        switch galleryFilter {
        case .all:
            cell.configWithCont(content: galleryModelManager.contentAt(index: indexPath.row), selectionMode: selectionMode, selected: selectedIndexPaths.contains(indexPath.row))
        case .mine:
            cell.configWithCont(content: galleryModelManager.mineContentAt(index: indexPath.row), selectionMode: selectionMode, selected: selectedIndexPaths.contains(indexPath.row))
        case .sent:
            cell.configWithCont(content: galleryModelManager.sharedContentAt(index: indexPath.row), selectionMode: selectionMode, selected: selectedIndexPaths.contains(indexPath.row))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
                if mediaManager.existingItem(id: content.idContent, mimeType: content.mimeType){
                    if selectedIndexPaths.contains(indexPath.row){
                        cell.checkBox.setOn(false, animated: true)
                        selectedIndexPaths.remove(at: selectedIndexPaths.index(of: indexPath.row)!)
                    }
                    else{
                        cell.checkBox.setOn(true, animated: true)
                        selectedIndexPaths.append(indexPath.row)
                    }
                    clickDelegate?.selectedShareFiles(indexes: selectedItemsForSelectedIndexPaths())
                }
            }
           
           
        }
        else{
            let cell = collectionView.cellForItem(at: indexPath) as! GaleriaItemCollectionViewCell
            if cell.thumbImage.image?.size != CGSize.zero{
                clickDelegate?.selectedContent(index: indexPath.row)
            }
            else{
                switch galleryFilter {
                case .all:
                    cell.downloadContent(content: galleryModelManager.contentAt(index: indexPath.row))
                case .mine:
                    cell.downloadContent(content: galleryModelManager.mineContentAt(index: indexPath.row))
                case .sent:
                    cell.downloadContent(content: galleryModelManager.sharedContentAt(index: indexPath.row))
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
    }
    
    func selectedItemsForSelectedIndexPaths() -> [Int]{
        var selectedItems = [Int]()
        for index in selectedIndexPaths{
            switch galleryFilter {
            case .all:
                selectedItems.append(galleryModelManager.contentAt(index: index).idContent)
            case .mine:
                selectedItems.append(galleryModelManager.mineContentAt(index: index).idContent)
            case .sent:
                selectedItems.append(galleryModelManager.sharedContentAt(index: index).idContent)
            }
        }
        return selectedItems
    }
}

