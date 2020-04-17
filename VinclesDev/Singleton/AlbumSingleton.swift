//
//  AlbumSingleton.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import Photos

class DownloadItem: NSObject{
    var downloadImage: URL?
    var downloadId: Int?
    var downloadVideo: URL?
}

class AlbumSingleton: NSObject {

    let albumName = "Vincles"
    var assetCollection: PHAssetCollection!
    
    var downloadImage: URL?
    var downloadId: Int?
    var downloadVideo: URL?
    
    
    func createAlbum() {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            if let assetCollection = fetchAssetCollectionForAlbum() {
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    
                } else {
                    print("error \(error)")
                }
            }
        }
        else{
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
        
     
    }
    
    func save() {
        if UserDefaults.standard.bool(forKey: "saveToCameraRoll"){

        if assetCollection == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        if !photoExists(id: self.downloadId!){
            PHPhotoLibrary.shared().performChanges({
                if self.downloadImage != nil{
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.originalFilename = "\(self.downloadId!)"
                    creationRequest.addResource(with: .photo, fileURL: self.downloadImage!, options: options)
                    if let assetPlaceholder = creationRequest.placeholderForCreatedAsset{
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                        let enumeration: NSArray = [assetPlaceholder]
                        albumChangeRequest!.addAssets(enumeration)
                    }
                    
               
                    
                }
                else if self.downloadVideo != nil{
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.originalFilename = "\(self.downloadId!)"
                    creationRequest.addResource(with: .video, fileURL: self.downloadVideo!, options: options)
                    if let assetPlaceholder = creationRequest.placeholderForCreatedAsset{
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                        let enumeration: NSArray = [assetPlaceholder]
                        albumChangeRequest!.addAssets(enumeration)
                    }
                    
      
                    
                }
                
            }, completionHandler: nil)
        }
        
       
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func photoExists(id: Int) -> Bool{
        var exists = false

        if self.assetCollection != nil{
            let photoAssets = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
            photoAssets.enumerateObjects{(object: AnyObject!,
                count: Int,
                stop: UnsafeMutablePointer<ObjCBool>) in
                
               if let obj =  object as? PHAsset{
                let resources = PHAssetResource.assetResources(for: obj)
                    let filename = resources[0].originalFilename
                
                    if let intFilename = Int(filename){
                        if intFilename == id{
                            exists = true
                        }
                    }
                    
                }
            }
        }
        
        return exists

    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func startDownloadToCameraRoll(){
        if UserDefaults.standard.bool(forKey: "saveToCameraRoll"){
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                if let assetCollection = fetchAssetCollectionForAlbum() {

                    self.assetCollection = assetCollection
                    save()
                }
                else{

                    createAlbum()
                }
            }
            else{
                PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
            }
            
        }
       
        
    }
    
}
