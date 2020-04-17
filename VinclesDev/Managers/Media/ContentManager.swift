//
//  ContentManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol ContentManagerDelegate: AnyObject {
    func didDownload(contentId: Int)
    func didError(contentId: Int)
    func didCorrupted(contentId: Int)
    
}

class ContentManager: NSObject {
    static let sharedInstance = ContentManager()
    let fileManager = FileManager.default
    weak var delegate:ContentManagerDelegate?
    
    // Galeria
    var downloadingIds = Set<Int>()
    var errorIds = Set<Int>()
    var corruptedIds = Set<Int>()
    
    func getGalleryMedia(contentId: Int, isGroup: Bool = false, messageType: MessageType, idChat: Int = -1) -> URL?{
        
        if galleryMediaExists(contentId: contentId, isGroup: isGroup){
            let fileURLThumb = getGalleryMediaImageUrl(contentId: contentId, isGroup: isGroup, messageType: messageType)
            
            if messageType == .video{
                if fileURLThumb == nil{
                    self.delegate?.didCorrupted(contentId: contentId)
                    return nil
                }
            }
            return fileURLThumb
        }
        else if downloadingIds.contains(contentId){
            return nil
        }
        else{
            downloadGalleryMedia(contentId: contentId, isGroup: isGroup, messageType: messageType, idChat: idChat)
        }
        return nil
    }
    
    func getVideoLink(contentId: Int, isGroup: Bool) -> URL?{
        do{
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            if galleryMediaExists(contentId: contentId, isGroup: isGroup){
                return isGroup ? documentDirectory.appendingPathComponent("group_gallery\(contentId).mp4") : documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
            }
        }
        catch{
            
        }
        
        return nil
    }
    
    func galleryMediaExists(contentId: Int, isGroup: Bool) -> Bool{
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            if !isGroup{
                let fileURLVideo = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
                let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
                let fileURLAudio = documentDirectory.appendingPathComponent("audio\(contentId).m4a")
                if !fileManager.fileExists(atPath: fileURLVideo.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                    // IS IMAGE
                    return true
                }
                else if fileManager.fileExists(atPath: fileURLVideo.path){
                    // IS VIDEO
                    return true
                    
                }
                else if fileManager.fileExists(atPath: fileURLAudio.path) {
                    // IS AUDIO
                    return true
                    
                }
            }
            else{
                let fileURLVideo = documentDirectory.appendingPathComponent("group_gallery\(contentId).mp4")
                let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(contentId).jpg")
                let fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(contentId).m4a")
                
                
                if !fileManager.fileExists(atPath: fileURLVideo.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                    // IS IMAGE
                    return true
                }
                else if fileManager.fileExists(atPath: fileURLVideo.path) {
                    // IS VIDEO
                    return true
                    
                }
                else if fileManager.fileExists(atPath: fileURLAudio.path) {
                    // IS AUDIO
                    return true
                    
                }
            }
            
            
        } catch {
            
        }
        
        return false
    }
    
    
    
    func getGalleryMediaImageUrl(contentId: Int, isGroup: Bool, messageType: MessageType) -> URL?{
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileUrl = isGroup ? documentDirectory.appendingPathComponent("group_thumb\(contentId).jpg") : documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            
            if fileManager.fileExists(atPath: fileUrl.path){
                return fileUrl
            }
            return nil
        }
        catch{
            print("error")
        }
        return nil
    }
    
    func downloadGalleryMedia(contentId: Int, isGroup: Bool, messageType: MessageType? = nil, idChat: Int = -1){
        if !isGroup{
            let authManager = AuthModelManager()
            if authManager.hasUser{
                downloadingIds.insert(contentId)
            }
            
            
            ApiClient.downloadGalleryPicture(id: contentId, onSuccess: { (mediaData, mType) in
                DispatchQueue.main.async {
                    if(self.downloadingIds.contains(contentId)){
                        self.downloadingIds.remove(contentId)
                    }
                    
                    if(self.errorIds.contains(contentId)){
                        self.errorIds.remove(contentId)
                    }
                }
               

                self.saveGalleryMedia(contentId: contentId, data: mediaData, isGroup: isGroup, messageType: mType)
            
                
                
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if(self.downloadingIds.contains(contentId)){
                        self.downloadingIds.remove(contentId)
                    }
                    
                    let authManager = AuthModelManager()
                    if authManager.hasUser{
                        self.errorIds.insert(contentId)
                        self.delegate?.didError(contentId: contentId)
                    }
                }
                
                
                
                
            })
        }
        else{
            ApiClient.downloadGroupChatMediaItem(idMessage: contentId, idChat: idChat, onSuccess: { (mediaData, mType) in
                if(self.downloadingIds.contains(contentId)){
                    self.downloadingIds.remove(contentId)
                }
                self.saveGalleryMedia(contentId: contentId, data: mediaData, isGroup: isGroup, messageType: mType)
                if(self.errorIds.contains(contentId)){
                    self.errorIds.remove(contentId)
                }
            }) { (errpr) in
                if(self.downloadingIds.contains(contentId)){
                    self.downloadingIds.remove(contentId)
                }
                
                let authManager = AuthModelManager()
                if authManager.hasUser{
                    self.errorIds.insert(contentId)
                    self.delegate?.didError(contentId: contentId)
                }
                
                
            }
        }
        
    }
    
    
    
    func saveGalleryMedia(contentId: Int, data: Data, isGroup: Bool, messageType: MessageType){
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            if messageType == .image{
                
                let fileURLThumb = isGroup ? documentDirectory.appendingPathComponent("group_thumb\(contentId).jpg") : documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
                
                if let imageUI = UIImage(data:data){
                    
                    let newImage = imageUI.resizeImage(newWidth: UIScreen.main.bounds.size.width)
                    
                    let data = newImage.jpegData(compressionQuality: 0.1)
                    do {
                        try data?.write(to: fileURLThumb)
                        DispatchQueue.main.async {
                            self.delegate?.didDownload(contentId: contentId)
                        }
                        
                    }  catch{
                        print("error \(contentId)")
                    }
                    
                 
                    
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
                    Timer.after(1.second) {
                        DispatchQueue.global(qos:.userInteractive).async {
                            let albumSingleton = AlbumSingleton()
                            albumSingleton.downloadImage = fileURLThumb
                            albumSingleton.downloadId = contentId
                            albumSingleton.downloadVideo = nil
                            albumSingleton.startDownloadToCameraRoll()
                        }
                    }
                    */
                }
            }
            else if messageType == .video{
                do {

                    let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                    var fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
                    var fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
                    
                    if isGroup{
                        fileURL = documentDirectory.appendingPathComponent("group_gallery\(contentId).mp4")
                        fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(contentId).jpg")
                    }
                    
                    try data.write(to: fileURL)
                    
                    
                    guard let imageUI = self.getThumbnailImage(url: fileURL) else{

                        let authManager = AuthModelManager()
                        if authManager.hasUser{
                            self.corruptedIds.insert(contentId)
                            self.delegate?.didCorrupted(contentId: contentId)
                        }
                        return
                    }
                    
                    let dataBig = imageUI.jpegData(compressionQuality: 0.1)
                    try dataBig?.write(to: fileURLThumb)
                    
                    DispatchQueue.main.async {
                        self.delegate?.didDownload(contentId: contentId)
                    }
                    
                    let downloadItem = DownloadItem()
                    downloadItem.downloadImage = nil
                    downloadItem.downloadId = contentId
                    downloadItem.downloadVideo = fileURL
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
                    Timer.after(1.second) {
                        DispatchQueue.global(qos:.userInteractive).async {
                            let albumSingleton = AlbumSingleton()
                            albumSingleton.downloadImage = nil
                            albumSingleton.downloadId = contentId
                            albumSingleton.downloadVideo = fileURL
                            albumSingleton.startDownloadToCameraRoll()
                        }
                    }
                    */
                }
                catch{
                    print("error \(contentId)")
                }
                
            }
            else if messageType == .audio{
                let fileURLAudio = isGroup ? documentDirectory.appendingPathComponent("group_audio\(contentId).m4a") : documentDirectory.appendingPathComponent("audio\(contentId).m4a")
                do {
                    try data.write(to: fileURLAudio)
                    DispatchQueue.main.async {
                        self.delegate?.didDownload(contentId: contentId)
                    }
                    
                } catch {
                    print("error \(contentId)")

                }
            }
        }
        catch{
            print("error \(contentId)")
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
    
    func existingItem(id: Int, mimeType: String) -> Bool{
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            if mimeType.contains("image"){
                let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(id).jpg")
                if fileManager.fileExists(atPath: fileURLThumb.path){
                    return true
                }
            }
            else if mimeType.contains("video"){
                let fileURL = documentDirectory.appendingPathComponent("gallery\(id).mp4")
                
                if fileManager.fileExists(atPath: fileURL.path) {
                    
                    return true
                }
            }
        } catch {
            
        }
        return false
    }
    
    
    func getMessageType(adjunt: Int, isGroup: Bool) -> MessageType{
        
        let documentDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        
        if !isGroup{
            let fileURLVideo = documentDirectory.appendingPathComponent("gallery\(adjunt).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(adjunt).jpg")
            let fileURLAudio = documentDirectory.appendingPathComponent("audio\(adjunt).m4a")
            
            if fileManager.fileExists(atPath: fileURLThumb.path) && !fileManager.fileExists(atPath: fileURLVideo.path){
                // IS IMAGE
                return .image
                
            }
            else if fileManager.fileExists(atPath: fileURLVideo.path) {
                return .video
                
            }
            else if fileManager.fileExists(atPath: fileURLAudio.path) {
                return .audio
            }
        }
        else{
            let fileURLVideo = documentDirectory.appendingPathComponent("group_gallery\(adjunt).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(adjunt).jpg")
            let fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(adjunt).m4a")
            
            if fileManager.fileExists(atPath: fileURLThumb.path) && !fileManager.fileExists(atPath: fileURLVideo.path){
                // IS IMAGE
                return .image
                
            }
            else if fileManager.fileExists(atPath: fileURLVideo.path) {
                return .video
                
            }
            else if fileManager.fileExists(atPath: fileURLAudio.path) {
                return .audio
            }
        }
        
        
        return .image
    }
    
    
}
