//
//  ImageManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import AlamofireImage
import Alamofire
import AVKit

class MediaManager {
    
    
    let sessionManager = SessionManager(
        serverTrustPolicyManager: ServerTrustPolicyManager(
            policies: [IP: .disableEvaluation]
        )
    )
    
    lazy var imageDownloaded = ImageDownloader(sessionManager: sessionManager, maximumActiveDownloads: 1)
    

    func saveChatImage(contentId: Int, imageData: Data){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            
            let downloadItem = DownloadItem()
            downloadItem.downloadImage = fileURLThumb
            downloadItem.downloadId = contentId
            downloadItem.downloadVideo = nil
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            var match = false
            
            for item in appDelegate.pendingToStoreInAlbum{
                if item.downloadId == downloadItem.downloadId{
                    match = true
                }
            }
            
            if !match{
                appDelegate.pendingToStoreInAlbum.append(downloadItem)
            }
            
            /*
            do {
                let albumSingleton = AlbumSingleton()
                
                albumSingleton.downloadImage = fileURLThumb
                albumSingleton.downloadId = contentId
                albumSingleton.downloadVideo = nil
                albumSingleton.startDownloadToCameraRoll()
                
                try imageData.write(to: fileURLThumb)
                
            } catch { }
            */
            do {
                try imageData.write(to: fileURLThumb)
                
            } catch { }
            
        } catch {
            
            
        }
    }
    
    func saveChatVideo(contentId: Int, videoData: Data){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLVideo = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            
            
            let downloadItem = DownloadItem()
            downloadItem.downloadImage = nil
            downloadItem.downloadId = contentId
            downloadItem.downloadVideo = fileURLVideo
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            var match = false
            
            for item in appDelegate.pendingToStoreInAlbum{
                if item.downloadId == downloadItem.downloadId{
                    match = true
                }
            }
            
            if !match{
                appDelegate.pendingToStoreInAlbum.append(downloadItem)
            }
            
            /*
            do {
                
                let albumSingleton = AlbumSingleton()
                
                albumSingleton.downloadImage = nil
                albumSingleton.downloadId = contentId
                albumSingleton.downloadVideo = fileURLVideo
                albumSingleton.startDownloadToCameraRoll()
                
                
                try videoData.write(to: fileURLVideo)
                
            } catch { }
            */
            if let imageUI = self.getThumbnailImage(url: fileURLVideo){
                
                
                do {
                    try  imageUI.jpegData(compressionQuality: 0.7)?.write(to: fileURLThumb)
                    
                } catch { }
            }
            
            
        } catch {
            
            
        }
    }
    
    func saveChatAudio(contentId: Int, audioData: Data){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLAudio = documentDirectory.appendingPathComponent("audio\(contentId).m4a")
            
            
            do {
                try audioData.write(to: fileURLAudio)
                
            } catch { }
            
            
            
        } catch {
            
            
        }
    }
    
    func saveChatImageGroup(idMessage: Int, imageData: Data){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(idMessage).jpg")
            
            do {
                try imageData.write(to: fileURLThumb)
                
            } catch { }
            
            do {
                try imageData.write(to: fileURLThumb)
                
            } catch { }
            
        } catch {
            
            
        }
    }
    
    func saveChatVideoGroup(idMessage: Int, videoData: Data){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLVideo = documentDirectory.appendingPathComponent("group_gallery\(idMessage).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(idMessage).jpg")
            
            
            do {
                try videoData.write(to: fileURLVideo)
                
            } catch { }
            
            if let imageUI = self.getThumbnailImage(url: fileURLVideo){
                
                do {
                    try  imageUI.jpegData(compressionQuality: 0.7)?.write(to: fileURLThumb)
                    
                } catch { }
            }
            
            
        } catch {
            
            
        }
    }
    
    func saveChatAudioGroup(idMessage: Int, audioData: Data){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(idMessage).m4a")
            
            
            do {
                try audioData.write(to: fileURLAudio)
                
            } catch { }
            
            
            
        } catch {
            
            
        }
    }
    
    
    func uploadPhoto(imageData: Data, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        ApiClientURLSession.sharedInstance.uploadImage(imageData: imageData, onSuccess: { (response) in
            if let contentId = response["id"] as? Int{
                
                self.addContentToLibrary(contentId: contentId, onSuccess: {dict in
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                        let fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).jpg")
                        try imageData.write(to: fileURL)
                        
                        
                        if let id = dict["id"] as? Int{
                            let galleryModelManager = GalleryModelManager()
                            galleryModelManager.createImageContent(id: id, idContent: contentId)
                        }
                        
                        
                        onSuccess(contentId)
                        
                    } catch {
                        HUDHelper.sharedInstance.hideHUD()
                        onError("")
                    }
                    
                }, onError: { (error) in
                    HUDHelper.sharedInstance.hideHUD()
                    onError("")
                })
                
                
            }
        }) { (error) in
            if error == TOKEN_FAIL{
                ApiClientURLSession.sharedInstance.refreshToken(onSuccess: {
                    
                    ApiClientURLSession.sharedInstance.uploadImage(imageData: imageData, onSuccess: { (response) in
                        if let contentId = response["id"] as? Int{
                            
                            self.addContentToLibrary(contentId: contentId, onSuccess: {dict in
                                do {
                                    let fileManager = FileManager.default
                                    let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                                    let fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).jpg")
                                    try imageData.write(to: fileURL)
                                    
                                    
                                    if let id = dict["id"] as? Int{
                                        let galleryModelManager = GalleryModelManager()
                                        galleryModelManager.createImageContent(id: id, idContent: contentId)
                                    }
                                    
                                    
                                    onSuccess(contentId)
                                    
                                } catch {
                                    DispatchQueue.main.async {
                                        HUDHelper.sharedInstance.hideHUD()
                                        onError("")
                                    }
                                }
                                
                            }, onError: { (error) in
                                DispatchQueue.main.async {
                                    HUDHelper.sharedInstance.hideHUD()
                                    onError(error)
                                }
                            })
                            
                            
                        }
                    }) { (error) in
                        
                            DispatchQueue.main.async {
                                HUDHelper.sharedInstance.hideHUD()
                                onError(error)
                            }
                           
                        
                    }
                   
                    
                    
                }) { (error) in
                    
                    DispatchQueue.main.async {
                        HUDHelper.sharedInstance.hideHUD()
                        let navigationManager = NavigationManager()
                        navigationManager.showUnauthorizedLogin()
                    }
                    
                }
            }
            else{
                HUDHelper.sharedInstance.hideHUD()
                onError(error)
            }
        }
    }
    
    func uploadVideo(videoData: Data, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        ApiClientURLSession.sharedInstance.uploadVideo(videoData: videoData, onSuccess: { (response) in
            if let contentId = response["id"] as? Int{
                
                self.addContentToLibrary(contentId: contentId, onSuccess: {dict in
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                        let fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
                        let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
                        try videoData.write(to: fileURL)
                        
                        if let imageThumb = self.getThumbnailImage(url: fileURL){
                            if let imageData = imageThumb.jpegData(compressionQuality: 0.5) {
                                try imageData.write(to: fileURLThumb)
                            }
                        }
                        
                        if let id = dict["id"] as? Int{
                            let galleryModelManager = GalleryModelManager()
                            galleryModelManager.createVideoContent(id: id, idContent: contentId)
                        }
                        
                        onSuccess(contentId)
                        
                    } catch {
                        HUDHelper.sharedInstance.hideHUD()
                        onError("")
                    }
                    
                }, onError: { (error) in
                    HUDHelper.sharedInstance.hideHUD()
                    onError("")
                })
                
                
            }
        }) { (error) in
            if error == TOKEN_FAIL{
                ApiClientURLSession.sharedInstance.refreshToken(onSuccess: {
                    
                    ApiClientURLSession.sharedInstance.uploadVideo(videoData: videoData, onSuccess: { (response) in
                        if let contentId = response["id"] as? Int{
                            
                            self.addContentToLibrary(contentId: contentId, onSuccess: {dict in
                                do {
                                    let fileManager = FileManager.default
                                    let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                                    let fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
                                    let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
                                    try videoData.write(to: fileURL)
                                    
                                    if let imageThumb = self.getThumbnailImage(url: fileURL){
                                        if let imageData = imageThumb.jpegData(compressionQuality: 0.5) {
                                            try imageData.write(to: fileURLThumb)
                                        }
                                    }
                                    
                                    if let id = dict["id"] as? Int{
                                        let galleryModelManager = GalleryModelManager()
                                        galleryModelManager.createVideoContent(id: id, idContent: contentId)
                                    }
                                    
                                    onSuccess(contentId)
                                    
                                } catch {
                                    DispatchQueue.main.async {
                                        HUDHelper.sharedInstance.hideHUD()
                                        onError("")
                                    }
                                }
                                
                            }, onError: { (error) in
                                DispatchQueue.main.async {
                                    HUDHelper.sharedInstance.hideHUD()
                                    onError("")
                                }
                                
                                
                            })
                            
                            
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            HUDHelper.sharedInstance.hideHUD()
                            onError(error)
                        }
                        
                        
                    }
                    
                    
                    
                }) { (error) in
                    
                    DispatchQueue.main.async {
                        HUDHelper.sharedInstance.hideHUD()
                        let navigationManager = NavigationManager()
                        navigationManager.showUnauthorizedLogin()
                    }
                    
                }
            }
            else{
                HUDHelper.sharedInstance.hideHUD()
                onError(error)
            }
        }
    }
    
    func uploadAudio(audioData: Data, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        ApiClientURLSession.sharedInstance.uploadAudio(audioData: audioData, onSuccess: { (response) in
            if let contentId = response["id"] as? Int{
                
                onSuccess(contentId)
                
            }
        }) { (error) in

            if error == TOKEN_FAIL{
                ApiClientURLSession.sharedInstance.refreshToken(onSuccess: {
                    ApiClientURLSession.sharedInstance.uploadAudio(audioData: audioData, onSuccess: { (response) in
                        if let contentId = response["id"] as? Int{
                            DispatchQueue.main.async {
                                HUDHelper.sharedInstance.hideHUD()
                                
                                onSuccess(contentId)
                            }
                        
                            
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            HUDHelper.sharedInstance.hideHUD()
                            onError(error)
                        }
                     
                    }
                }) { (error) in
                    
                    DispatchQueue.main.async {
                        HUDHelper.sharedInstance.hideHUD()
                        let navigationManager = NavigationManager()
                        navigationManager.showUnauthorizedLogin()
                    }
                    
                }
            }
            else{
                HUDHelper.sharedInstance.hideHUD()
                onError(error)
            }
            
        }
        
    }
    
    func addContentToLibrary(contentId: Int, onSuccess: @escaping ([String: AnyObject]) -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.addContentToLibrary(contentId: contentId, onSuccess: {dict in
            onSuccess(dict as [String : AnyObject])
        }) { (error) in
            onError("")
        }
    }
    
    func removeFiles(contentId: Int){
        
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).jpg")
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            let fileURLThumbSmall = documentDirectory.appendingPathComponent("thumbsmall\(contentId).jpg")
            let fileURLAudio = documentDirectory.appendingPathComponent("audio\(contentId).m4a")
            
            
            if fileManager.fileExists(atPath: fileURL.path){
                try fileManager.removeItem(atPath: fileURL.path)
            }
            
            if fileManager.fileExists(atPath: fileURLThumb.path){
                try fileManager.removeItem(atPath: fileURLThumb.path)
            }
            
            if fileManager.fileExists(atPath: fileURLThumbSmall.path){
                try fileManager.removeItem(atPath: fileURLThumbSmall.path)
            }
            
            if fileManager.fileExists(atPath: fileURLAudio.path){
                try fileManager.removeItem(atPath: fileURLAudio.path)
            }
            
            
        } catch {
            
        }
        
        
        
    }
    
    func removeFiles(contactId: Int){
        
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURL = documentDirectory.appendingPathComponent("profile\(contactId).jpg")
            
            if fileManager.fileExists(atPath: fileURL.path){
                try fileManager.removeItem(atPath: fileURL.path)
            }
            
            
        } catch {
            
        }
        
        
        
    }
    
    func removeContentFromLibrary(contentId: Int, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        
        HUDHelper.sharedInstance.showHud(message: "")
        ApiClient.removeContentFromLibrary(contentId: contentId, onSuccess: {
            
            self.removeFiles(contentId: contentId)
            let galleryModelManager = GalleryModelManager()
            galleryModelManager.removeContentItem(id: contentId)
            HUDHelper.sharedInstance.hideHUD()

            onSuccess()
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError(error)
        }
    }
    
    func getThumbnailImage(url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func getCacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func clearCacheFolder() {
        do {
            let fileManager = FileManager.default
            let tempFolderPath = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            do {
                let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath.path)
                for filePath in filePaths {
                    let url = URL(fileURLWithPath: filePath)
                    if url.pathExtension == "jpg" || url.pathExtension == "m4a" || url.pathExtension == "mp4"{
                        try fileManager.removeItem(atPath: tempFolderPath.path + "/" + filePath)

                    }
                }
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        } catch let error {
            print(error)
        }
        
        
    }
    
    
    
}



