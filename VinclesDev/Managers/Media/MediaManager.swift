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
    
    lazy var apiClient = ApiClient()
    
    lazy var imageDownloaded = ImageDownloader(sessionManager: sessionManager, maximumActiveDownloads: 1)
    
    
    func saveUserPhotoRegister(userId: String, image: UIImage, onCompletion: @escaping () -> ()){
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            
            do {
                //Image compression is defined in this line. (https://developer.apple.com/documentation/uikit/1624115-uiimagejpegrepresentation)
                let data = UIImageJPEGRepresentation(image, 0.8)
                try data?.write(to: fileURL)
                onCompletion()
                
            } catch {
                print("error")
            }
            
        } catch {
            print("error")
        }
        
    }
    
    func getUserPhotoRegister( onCompletion: @escaping (UIImage?) -> ()){
        let fileManager = FileManager.default
        
        let profileModelManager = ProfileModelManager()
        if let id = profileModelManager.getUserMe()?.email{
            do {
                let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                
                let fileURL = documentDirectory.appendingPathComponent("profile\(id).jpg")
                if fileManager.fileExists(atPath: fileURL.path){
                    if let image = UIImage(contentsOfFile: fileURL.path){
                        onCompletion(image)
                    }
                    else{
                        onCompletion(nil)
                    }
                }
                else{
                    onCompletion(nil)
                }
            } catch {
                onCompletion(nil)
            }
        }
        else{
            onCompletion(nil)
            
        }
        
        
    }
    
    
    func removeProfilePicture(userId: Int){
        let fileManager = FileManager.default

        let documentDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent("profile\(userId).jpg")
        if fileManager.fileExists(atPath: fileURL.path){
            do {
                try fileManager.removeItem(at: fileURL)

            } catch {
                
            }
        }
    }
    
    
    func removeGroupPicture(groupId: Int){
        let fileManager = FileManager.default
        
        let documentDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent("group\(groupId).jpg")
        if fileManager.fileExists(atPath: fileURL.path){
            do {
                try fileManager.removeItem(at: fileURL)
                
            } catch {
                
            }
        }
    }
    
    func setProfilePicture(userId: Int, imageView: UIImageView, onCompletion: @escaping () -> ()){
        
        
        
        imageView.image = UIImage(named: "perfilplaceholder")

        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            if fileManager.fileExists(atPath: fileURL.path){
                if let image = UIImage(contentsOfFile: fileURL.path){
                    //     imageView.image = image.resizeImage(newWidth: imageView.frame.size.width * UIScreen.main.scale)
                    imageView.image = image
                    
                    onCompletion()
                }
            }
                
            else{
                
                ApiClient.downloadProfilePicture(id: userId, size: imageView.bounds.size.width * UIScreen.main.scale, onSuccess: { imageData in

                    if imageView.tag == userId{
                        if let image = UIImage(data:imageData,scale:1.0){
                            print(image.size)
                            DispatchQueue.main.async {
                                //imageView.image = image
                                imageView.image = image
                            }
                            
                        }
                        
                    }
                    
                    do {
                        try imageData.write(to: fileURL)
                        
                    } catch {
                        DispatchQueue.main.async {
                            imageView.image = UIImage(named: "perfilplaceholder")
                        }
                    }
                    
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        imageView.image = UIImage(named: "perfilplaceholder")
                    }

                })
                
                
                
            }
            
        } catch {
            DispatchQueue.main.async {
                imageView.image = UIImage(named: "perfilplaceholder")
            }
        }
        
    }
    
    func setProfilePictureEvent(meetingId: Int, userId: Int, imageView: UIImageView, onCompletion: @escaping () -> ()){
        
        
        
        imageView.image = UIImage(named: "perfilplaceholder")

        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            if fileManager.fileExists(atPath: fileURL.path){
                if let image = UIImage(contentsOfFile: fileURL.path){
                    //     imageView.image = image.resizeImage(newWidth: imageView.frame.size.width * UIScreen.main.scale)
                    imageView.image = image
                    
                    onCompletion()
                }
            }
                
            else{
                
                ApiClient.downloadProfilePictureEvent(meetingId: meetingId, id: userId, size: imageView.bounds.size.width * UIScreen.main.scale, onSuccess: { imageData in
                    
                    if imageView.tag == userId{
                        if let image = UIImage(data:imageData,scale:1.0){
                            DispatchQueue.main.async {
                                //imageView.image = image
                                imageView.image = image
                            }
                            
                        }
                        
                    }
                    
                    do {
                        try imageData.write(to: fileURL)
                        
                    } catch {
                        
                    }
                    
                }, onError: { (error) in
                    
                })
                
                
                
            }
            
        } catch {
        }
        
    }
    
    func setGroupPicture(groupId: Int, imageView: UIImageView, onCompletion: @escaping () -> ()){
        
        
        imageView.image = UIImage()
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("group\(groupId).jpg")
            if fileManager.fileExists(atPath: fileURL.path){
                if let image = UIImage(contentsOfFile: fileURL.path){
                    //  imageView.image = image.resizeImage(newWidth: imageView.frame.size.width * UIScreen.main.scale)
                    imageView.image = image
                    
                    onCompletion()
                }
            }
                
                
            else{
                ApiClient.downloadGroupPicture(id: groupId, size: imageView.bounds.size.width * UIScreen.main.scale, onSuccess: { imageData in
                    
                    if imageView.tag == groupId{
                        if let image = UIImage(data:imageData,scale:1.0){
                            DispatchQueue.main.async {
                                //imageView.image = image
                                imageView.image = image
                            }
                            
                        }
                        
                    }
                    
                    do {
                        try imageData.write(to: fileURL)
                        
                    } catch {
                        
                    }
                    
                }, onError: { (error) in
                    
                })
                
                
            }
            
        } catch {
        }
        
    }
    
    func existingItem(id: Int, mimeType: String) -> Bool{
        let fileManager = FileManager.default

        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            if mimeType.contains("image"){
                let fileURL = documentDirectory.appendingPathComponent("gallery\(id).jpg")
                let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(id).jpg")
                if fileManager.fileExists(atPath: fileURL.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                    return true
                }
            }
            else if mimeType.contains("video"){
         

                let fileURL = documentDirectory.appendingPathComponent("gallery\(id).mp4")
                let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(id).jpg")
                let fileURLThumbSmall = documentDirectory.appendingPathComponent("thumbsmall\(id).jpg")
                
                if fileManager.fileExists(atPath: fileURLThumb.path) && fileManager.fileExists(atPath: fileURL.path) && fileManager.fileExists(atPath: fileURLThumbSmall.path) {

                    return true
                }
            }
          
            
           
        } catch {

        }
        
        return false
    }
    
    func setGalleryPicture(contentId: Int, imageView: UIImageView,  playButton: UIButton? = nil, downloadButton: UIButton? = nil, activityIndicator: UIActivityIndicatorView? = nil, isThumb: Bool = false, isGroup: Bool = false, onCompletion: @escaping (Bool, Int) -> ()){
        
        imageView.image = UIImage()
        
        let fileManager = FileManager.default
  
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            var fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).jpg")
            var fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            
            if isGroup{
                fileURL = documentDirectory.appendingPathComponent("group_gallery\(contentId).jpg")
                fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(contentId).jpg")
            }
            if fileManager.fileExists(atPath: fileURL.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                if let image = isThumb ? (UIImage(contentsOfFile: fileURLThumb.path)) : (UIImage(contentsOfFile: fileURL.path)) {
                    if imageView.tag == contentId{
                        imageView.image = image
                    }
                    if downloadButton != nil{
                        if downloadButton!.tag == contentId{
                            downloadButton!.isHidden = true
                        }
                    }
                    if playButton != nil{
                        if playButton!.tag == contentId{
                            playButton!.isHidden = true
                        }
                    }
                    if activityIndicator != nil{
                        if activityIndicator!.tag == contentId{
                            activityIndicator!.stopAnimating()
                            activityIndicator!.isHidden = true
                        }
                    }
                   
                   
                    onCompletion(true, contentId)
                }
            }
            else{
                
                ApiClient.downloadGalleryPicture(id: contentId, onSuccess: { imageData in
                    
                    if imageView.tag == contentId{
                        
                        DispatchQueue.global(qos:.userInteractive).async {
                            
                            if !isThumb{
                                if let image = UIImage(data:imageData,scale:1.0){
                                    DispatchQueue.main.async {
                                        //imageView.image = image
                                        imageView.image = image

                                        if downloadButton != nil{
                                            if downloadButton!.tag == contentId{
                                                downloadButton!.isHidden = true
                                            }
                                        }
                                        if playButton != nil{
                                            if playButton!.tag == contentId{
                                                playButton!.isHidden = true
                                            }
                                        }
                                        if activityIndicator != nil{
                                            if activityIndicator!.tag == contentId{
                                                activityIndicator!.stopAnimating()
                                                activityIndicator!.isHidden = true
                                            }
                                        }
                                        onCompletion(true, contentId)

                                    }
                                }
                                
                            }
                            
                            do {
                                let albumSingleton = AlbumSingleton()
                                
                                albumSingleton.downloadImage = fileURL
                                albumSingleton.downloadId = contentId
                                albumSingleton.downloadVideo = nil
                                albumSingleton.startDownloadToCameraRoll()
                                try imageData.write(to: fileURL)
                                
                            } catch { }
                            
                            if let imageUI = UIImage(data:imageData){
                                
                                let newImage = imageUI.resizeImage(newWidth: imageView.bounds.size.width)
                                
                                if isThumb{
                                    DispatchQueue.main.async {
                                        imageView.image = newImage
                                        if downloadButton != nil{
                                            if downloadButton!.tag == contentId{
                                                downloadButton!.isHidden = true
                                            }
                                        }
                                        if playButton != nil{
                                            if playButton!.tag == contentId{
                                                playButton!.isHidden = true
                                            }
                                        }
                                        if activityIndicator != nil{
                                            if activityIndicator!.tag == contentId{
                                                activityIndicator!.stopAnimating()
                                                activityIndicator!.isHidden = true
                                            }
                                        }
                                        onCompletion(true, contentId)

                                    }
                                }
                                
                                let data = UIImageJPEGRepresentation(newImage, 0.7)
                                do {
                                    try data?.write(to: fileURLThumb)
                                } catch {}
                            }
                        }
                    }
                    
                }, onError: { (error) in
                    if downloadButton != nil{
                        if downloadButton!.tag == contentId{
                            downloadButton!.isHidden = false
                        }
                    }
                    if playButton != nil{
                        if playButton!.tag == contentId{
                            playButton!.isHidden = true
                        }
                    }
                    if activityIndicator != nil{
                        if activityIndicator!.tag == contentId{
                            activityIndicator!.stopAnimating()
                            activityIndicator!.isHidden = true
                        }
                    }
                    onCompletion(false, contentId)
                })
            }
        } catch {
            onCompletion(false, contentId)
        }
        
    }
    
 
    func setGalleryVideo(contentId: Int, imageView: UIImageView?,  playButton: UIButton? = nil, downloadButton: UIButton? = nil, activityIndicator: UIActivityIndicatorView? = nil, isThumb: Bool = false, isGroup: Bool = false, onCompletion: @escaping (Bool, URL?, Int) -> ()){
        
        imageView?.image = UIImage()
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            var fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
            var fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            var fileURLThumbSmall = documentDirectory.appendingPathComponent("thumbsmall\(contentId).jpg")
            
            if isGroup{
                fileURL = documentDirectory.appendingPathComponent("group_gallery\(contentId).mp4")
                fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(contentId).jpg")
                fileURLThumbSmall = documentDirectory.appendingPathComponent("group_thumbsmall\(contentId).jpg")
            }
            
            if fileManager.fileExists(atPath: fileURLThumb.path) && fileManager.fileExists(atPath: fileURL.path) && fileManager.fileExists(atPath: fileURLThumbSmall.path) {
                if let image = isThumb ? (UIImage(contentsOfFile: fileURLThumbSmall.path)) : (UIImage(contentsOfFile: fileURLThumb.path)) {
                    if imageView?.tag == contentId{
                        if let iv = imageView{
                            iv.image = image
                            // iv.image = image.resizeImage(newWidth: iv.frame.size.width * UIScreen.main.scale)
                            
                        }
                    }
                  
                    if downloadButton != nil{
                        if downloadButton!.tag == contentId{
                            downloadButton!.isHidden = true
                        }
                    }
                    if playButton != nil{
                        if playButton!.tag == contentId{
                            playButton!.isHidden = false
                        }
                    }
                    if activityIndicator != nil{
                        if activityIndicator!.tag == contentId{
                            activityIndicator!.stopAnimating()
                            activityIndicator!.isHidden = true
                        }
                    }
                    
                    onCompletion(true, fileURL, contentId)
                    
                    
                }
            }
            else{
                
                ApiClient.downloadGalleryVideo(id: contentId, onSuccess: { videoData in
                    
                    
                    do {
                        
                        let albumSingleton = AlbumSingleton()
                        
                        albumSingleton.downloadImage = nil
                        albumSingleton.downloadId = contentId
                        albumSingleton.downloadVideo = fileURL
                        albumSingleton.startDownloadToCameraRoll()
                        
                        
                        try videoData.write(to: fileURL)
                        onCompletion(true, fileURL, contentId)

                        if imageView?.tag == contentId{
                            
                            guard let imageView = imageView else{
                                return
                            }
                            
                            if let imageUI = self.getThumbnailImage(url: fileURL){
                                
                                DispatchQueue.global(qos:.userInteractive).async {
                                    
                                    let dataBig = UIImageJPEGRepresentation(imageUI, 0.7)
                                    
                                    do {
                                        try dataBig?.write(to: fileURLThumb)
                                        
                                    } catch {
                                        
                                    }
                                    
                                    
                                    let newImage = imageUI.resizeImage(newWidth: imageView.bounds.size.width * UIScreen.main.scale)
                                    let data = UIImageJPEGRepresentation(newImage, 0.7)
                                    do {
                                        try data?.write(to: fileURLThumbSmall)
                                        
                                    } catch {
                                        
                                    }
                                    DispatchQueue.main.async {
                                        
                                        if downloadButton != nil{
                                            if downloadButton!.tag == contentId{
                                                downloadButton!.isHidden = true
                                            }
                                        }
                                        if playButton != nil{
                                            if playButton!.tag == contentId{
                                                playButton!.isHidden = false
                                            }
                                        }
                                        if activityIndicator != nil{
                                            if activityIndicator!.tag == contentId{
                                                activityIndicator!.stopAnimating()
                                                activityIndicator!.isHidden = true
                                            }
                                        }
                                        
                                        onCompletion(true, fileURL, contentId)

                                        if isThumb{
                                            onCompletion(true, fileURL, contentId)
                                            imageView.image = newImage
                                        }
                                        else {
                                            imageView.image = imageUI
                                        }
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                       
                    } catch {
                        if downloadButton != nil{
                            if downloadButton!.tag == contentId{
                                downloadButton!.isHidden = false
                            }
                        }
                        if playButton != nil{
                            if playButton!.tag == contentId{
                                playButton!.isHidden = true
                            }
                        }
                        if activityIndicator != nil{
                            if activityIndicator!.tag == contentId{
                                activityIndicator!.stopAnimating()
                                activityIndicator!.isHidden = true
                            }
                        }
                        onCompletion(false, nil, contentId)

                    }
                    
                    
                }, onError: { (error) in
                    if downloadButton != nil{
                        if downloadButton!.tag == contentId{
                            downloadButton!.isHidden = false
                        }
                    }
                    if playButton != nil{
                        if playButton!.tag == contentId{
                            playButton!.isHidden = true
                        }
                    }
                    if activityIndicator != nil{
                        if activityIndicator!.tag == contentId{
                            activityIndicator!.stopAnimating()
                            activityIndicator!.isHidden = true
                        }
                    }
                    onCompletion(false, nil, contentId)

                })
                
            }
        } catch {
            if downloadButton != nil{
                if downloadButton!.tag == contentId{
                    downloadButton!.isHidden = false
                }
            }
            if playButton != nil{
                if playButton!.tag == contentId{
                    playButton!.isHidden = true
                }
            }
            if activityIndicator != nil{
                if activityIndicator!.tag == contentId{
                    activityIndicator!.stopAnimating()
                    activityIndicator!.isHidden = true
                }
            }
            onCompletion(false, nil, contentId)

        }
        
    }
    
    
    func chatExistingItem(id: Int) -> Bool{
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            
            let fileURLImage = documentDirectory.appendingPathComponent("gallery\(id).jpg")
            let fileURLVideo = documentDirectory.appendingPathComponent("gallery\(id).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(id).jpg")
            let fileURLThumbSmall = documentDirectory.appendingPathComponent("thumbsmall\(id).jpg")
            let fileURLAudio = documentDirectory.appendingPathComponent("audio\(id).m4a")
            if fileManager.fileExists(atPath: fileURLImage.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                // IS IMAGE
                return true
            }
            else if fileManager.fileExists(atPath: fileURLThumb.path) && fileManager.fileExists(atPath: fileURLVideo.path) && fileManager.fileExists(atPath: fileURLThumbSmall.path) {
                // IS VIDEO
                return true

            }
            else if fileManager.fileExists(atPath: fileURLAudio.path) {
                // IS AUDIO
                return true

            }
            
        } catch {
            
        }
        
        return false
    }
    
    func chatGroupExistingItem(idMessage: Int) -> Bool{
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLImage = documentDirectory.appendingPathComponent("group_gallery\(idMessage).jpg")
            let fileURLVideo = documentDirectory.appendingPathComponent("group_gallery\(idMessage).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(idMessage).jpg")
            let fileURLThumbSmall = documentDirectory.appendingPathComponent("group_thumbsmall\(idMessage).jpg")
            let fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(idMessage).m4a")
            
            
            if fileManager.fileExists(atPath: fileURLImage.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                // IS IMAGE
                return true
            }
            else if fileManager.fileExists(atPath: fileURLThumb.path) && fileManager.fileExists(atPath: fileURLVideo.path) && fileManager.fileExists(atPath: fileURLThumbSmall.path) {
                // IS VIDEO
                return true
                
            }
            else if fileManager.fileExists(atPath: fileURLAudio.path) {
                // IS AUDIO
                return true
                
            }
            
        } catch {
            
        }
        
        return false
    }
    
    func saveChatImage(contentId: Int, imageData: Data){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
        let fileURLImage = documentDirectory.appendingPathComponent("gallery\(contentId).jpg")
        let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            
            do {
                let albumSingleton = AlbumSingleton()
                
                albumSingleton.downloadImage = fileURLImage
                albumSingleton.downloadId = contentId
                albumSingleton.downloadVideo = nil
                albumSingleton.startDownloadToCameraRoll()
                
                try imageData.write(to: fileURLImage)
                
            } catch { }
            
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
            let fileURLThumbSmall = documentDirectory.appendingPathComponent("thumbsmall\(contentId).jpg")
            
            
            do {
                
                let albumSingleton = AlbumSingleton()
                
                albumSingleton.downloadImage = nil
                albumSingleton.downloadId = contentId
                albumSingleton.downloadVideo = fileURLVideo
                albumSingleton.startDownloadToCameraRoll()
                
                
                try videoData.write(to: fileURLVideo)
                
            } catch { }
            
            if let imageUI = self.getThumbnailImage(url: fileURLVideo){
                do {
                    try  UIImageJPEGRepresentation(imageUI, 0.7)?.write(to: fileURLThumbSmall)
                    
                } catch { }
                
                do {
                    try  UIImageJPEGRepresentation(imageUI, 0.7)?.write(to: fileURLThumb)
                    
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
            
            let fileURLImage = documentDirectory.appendingPathComponent("group_gallery\(idMessage).jpg")
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(idMessage).jpg")
         
            do {
                try imageData.write(to: fileURLImage)
                
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
            let fileURLThumbSmall = documentDirectory.appendingPathComponent("group_thumbsmall\(idMessage).jpg")
            
            
            do {
                try videoData.write(to: fileURLVideo)
                
            } catch { }
            
            if let imageUI = self.getThumbnailImage(url: fileURLVideo){
                do {
                    try  UIImageJPEGRepresentation(imageUI, 0.7)?.write(to: fileURLThumbSmall)
                    
                } catch { }
                
                do {
                    try  UIImageJPEGRepresentation(imageUI, 0.7)?.write(to: fileURLThumb)
                    
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
    
    
    func setChatMedia(contentId: Int, imageView: UIImageView?, isThumb: Bool = false, onCompletion: @escaping (Bool, MessageType?) -> ()){
        
        imageView?.image = UIImage()
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLImage = documentDirectory.appendingPathComponent("gallery\(contentId).jpg")
            let fileURLVideo = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
            let fileURLThumbSmall = documentDirectory.appendingPathComponent("thumbsmall\(contentId).jpg")
            let fileURLAudio = documentDirectory.appendingPathComponent("audio\(contentId).m4a")

            if fileManager.fileExists(atPath: fileURLImage.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                // IS IMAGE
                
                if let image = isThumb ? (UIImage(contentsOfFile: fileURLThumb.path)) : (UIImage(contentsOfFile: fileURLImage.path)) {
                    if imageView?.tag == contentId{
                        imageView?.image = image
                    }
                    onCompletion(true, .image)
                }

            }
            else if fileManager.fileExists(atPath: fileURLThumb.path) && fileManager.fileExists(atPath: fileURLVideo.path) && fileManager.fileExists(atPath: fileURLThumbSmall.path) {
                // IS VIDEO
                if let image = UIImage(contentsOfFile: fileURLThumb.path) {
                    if imageView?.tag == contentId{
                        if let iv = imageView{
                            iv.image = image
                        }
                    }
                    onCompletion(true, .video)
                }
            }
            else if fileManager.fileExists(atPath: fileURLAudio.path) {
                // IS AUDIO
                onCompletion(true, .audio)

            }
            else{
                ApiClient.downloadChatMediaItem(id: contentId, onSuccess: { (mediaData, messageType) in
                    if messageType == .image{
                        if imageView?.tag == contentId{
                            
                            DispatchQueue.global(qos:.userInteractive).async {
                                
                                if !isThumb{
                                    if let image = UIImage(data:mediaData,scale:1.0){
                                        DispatchQueue.main.async {
                                            //imageView.image = image
                                            imageView?.image = image
                                            onCompletion(true, .image)
                                            
                                        }
                                    }
                                    
                                }
                                
                                do {
                                    let albumSingleton = AlbumSingleton()
                                    
                                    albumSingleton.downloadImage = fileURLImage
                                    albumSingleton.downloadId = contentId
                                    albumSingleton.downloadVideo = nil
                                    albumSingleton.startDownloadToCameraRoll()
                                    
                                    try mediaData.write(to: fileURLImage)
                                    
                                } catch { }
                                
                                if let imageUI = UIImage(data:mediaData){
                                    
                                    let newImage = imageUI.resizeImage(newWidth: (imageView?.bounds.size.width)!)
                                    
                                    if isThumb{
                                        DispatchQueue.main.async {
                                            imageView?.image = newImage
                                            onCompletion(true, .image)
                                            
                                        }
                                    }
                                    
                                    let data = UIImageJPEGRepresentation(newImage, 0.7)
                                    do {
                                        try data?.write(to: fileURLThumb)
                                    } catch {}
                                }
                            }
                        }
                    }
                    else if messageType == .video{
                        do {
                            
                            let albumSingleton = AlbumSingleton()
                            
                            albumSingleton.downloadImage = nil
                            albumSingleton.downloadId = contentId
                            albumSingleton.downloadVideo = fileURLVideo
                            albumSingleton.startDownloadToCameraRoll()
                            
                            try mediaData.write(to: fileURLVideo)
                            onCompletion(true, .video)
                            
                            if imageView?.tag == contentId{
                                
                                guard let imageView = imageView else{
                                    return
                                }
                                
                                if let imageUI = self.getThumbnailImage(url: fileURLVideo){
                                    
                                    DispatchQueue.global(qos:.userInteractive).async {
                                        
                                        let dataBig = UIImageJPEGRepresentation(imageUI, 0.7)
                                        
                                        do {
                                            try dataBig?.write(to: fileURLThumb)
                                            
                                        } catch {
                                            
                                        }
                                        
                                        
                                        let newImage = imageUI.resizeImage(newWidth: imageView.bounds.size.width * UIScreen.main.scale)
                                        let data = UIImageJPEGRepresentation(newImage, 0.7)
                                        do {
                                            try data?.write(to: fileURLThumbSmall)
                                            
                                        } catch {
                                            
                                        }
                                        DispatchQueue.main.async {
                                            onCompletion(true, .video)
                                            imageView.image = imageUI
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                        } catch {
                            print("error")
                            onCompletion(false, nil)
                            
                        }
                    }
                    else if messageType == .audio{
                        
                        do {
                            try mediaData.write(to: fileURLAudio)
                            onCompletion(true, .audio)
                            
                        } catch {
                            onCompletion(false, nil)

                        }

                    }
                }) { (errpr) in
                    onCompletion(false, nil)

                }
                
              
                
            }
        } catch {
            onCompletion(false, nil)

        }
        
    }
    
    func setGroupChatMedia(idMessage: Int, idChat: Int, imageView: UIImageView?, isThumb: Bool = false, onCompletion: @escaping (Bool, MessageType?) -> ()){
        
        imageView?.image = UIImage()
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLImage = documentDirectory.appendingPathComponent("group_gallery\(idMessage).jpg")
            let fileURLVideo = documentDirectory.appendingPathComponent("group_gallery\(idMessage).mp4")
            let fileURLThumb = documentDirectory.appendingPathComponent("group_thumb\(idMessage).jpg")
            let fileURLThumbSmall = documentDirectory.appendingPathComponent("group_thumbsmall\(idMessage).jpg")
            let fileURLAudio = documentDirectory.appendingPathComponent("group_audio\(idMessage).m4a")
            
            if fileManager.fileExists(atPath: fileURLImage.path) && fileManager.fileExists(atPath: fileURLThumb.path){
                // IS IMAGE
                
                if let image = isThumb ? (UIImage(contentsOfFile: fileURLThumb.path)) : (UIImage(contentsOfFile: fileURLImage.path)) {
                    if imageView?.tag == idMessage{
                        imageView?.image = image
                    }
                    onCompletion(true, .image)
                }
                
            }
            else if fileManager.fileExists(atPath: fileURLThumb.path) && fileManager.fileExists(atPath: fileURLVideo.path) && fileManager.fileExists(atPath: fileURLThumbSmall.path) {
                // IS VIDEO
                if let image = UIImage(contentsOfFile: fileURLThumb.path) {
                    if imageView?.tag == idMessage{
                        if let iv = imageView{
                            iv.image = image
                        }
                    }
                    onCompletion(true,.video)
                }
            }
            else if fileManager.fileExists(atPath: fileURLAudio.path) {
                // IS AUDIO
                onCompletion(true,.audio)
                
            }
            else{
                ApiClient.downloadGroupChatMediaItem(idMessage: idMessage, idChat: idChat, onSuccess: { (mediaData, messageType) in
                    if messageType == .image{
                        if imageView?.tag == idMessage{
                            
                            DispatchQueue.global(qos:.userInteractive).async {
                                
                                if !isThumb{
                                    if let image = UIImage(data:mediaData,scale:1.0){
                                        DispatchQueue.main.async {
                                            //imageView.image = image
                                            imageView?.image = image
                                            onCompletion(true,.image)
                                            
                                        }
                                    }
                                    
                                }
                                
                                do {
                                    try mediaData.write(to: fileURLImage)
                                    
                                } catch { }
                                
                                if let imageUI = UIImage(data:mediaData){
                                    
                                    let newImage = imageUI.resizeImage(newWidth: (imageView?.bounds.size.width)!)
                                    
                                    if isThumb{
                                        DispatchQueue.main.async {
                                            imageView?.image = newImage
                                            onCompletion(true,.image)
                                            
                                        }
                                    }
                                    
                                    let data = UIImageJPEGRepresentation(newImage, 0.7)
                                    do {
                                        try data?.write(to: fileURLThumb)
                                    } catch {}
                                }
                            }
                        }
                    }
                    else if messageType == .video{
                        do {
                            try mediaData.write(to: fileURLVideo)
                            onCompletion(true,.video)
                            
                            if imageView?.tag == idMessage{
                                
                                guard let imageView = imageView else{
                                    return
                                }
                                
                                if let imageUI = self.getThumbnailImage(url: fileURLVideo){
                                    
                                    DispatchQueue.global(qos:.userInteractive).async {
                                        
                                        let dataBig = UIImageJPEGRepresentation(imageUI, 0.7)
                                        
                                        do {
                                            try dataBig?.write(to: fileURLThumb)
                                            
                                        } catch {
                                            
                                        }
                                        
                                        
                                        let newImage = imageUI.resizeImage(newWidth: imageView.bounds.size.width * UIScreen.main.scale)
                                        let data = UIImageJPEGRepresentation(newImage, 0.7)
                                        do {
                                            try data?.write(to: fileURLThumbSmall)
                                            
                                        } catch {
                                            
                                        }
                                        DispatchQueue.main.async {
                                            onCompletion(true,.video)
                                            imageView.image = imageUI
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                        } catch {
                            print("error")
                            
                        }
                    }
                    else if messageType == .audio{
                        
                        do {
                            try mediaData.write(to: fileURLAudio)
                            onCompletion(true,.audio)
                            
                        } catch {
                            onCompletion(false, nil)

                        }
                        
                    }
                }) { (errpr) in
                    onCompletion(false, nil)

                }
                
                
                
            }
        } catch {
            onCompletion(false, nil)

        }
        
    }

    
    func uploadPhoto(imageData: Data, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.uploadImage(imageData: imageData, onSuccess: { (response) in
            if let contentId = response["id"] as? Int{
                
                self.addContentToLibrary(contentId: contentId, onSuccess: {dict in
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                        let fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).jpg")
                        try imageData.write(to: fileURL)
                        
                        HUDHelper.sharedInstance.hideHUD()
                        
                        let galleryModelManager = GalleryModelManager()

                        if let id = dict["id"] as? Int{
                            let galleryModelManager = GalleryModelManager()
                            galleryModelManager.createImageContent(id: id, idContent: contentId)
                            HUDHelper.sharedInstance.hideHUD()
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
            HUDHelper.sharedInstance.hideHUD()
            onError("")
        }
    }
    
    func uploadVideo(videoData: Data, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.uploadVideo(videoData: videoData, onSuccess: { (response) in
            if let contentId = response["id"] as? Int{
                
                self.addContentToLibrary(contentId: contentId, onSuccess: {dict in
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                        let fileURL = documentDirectory.appendingPathComponent("gallery\(contentId).mp4")
                        let fileURLThumb = documentDirectory.appendingPathComponent("thumb\(contentId).jpg")
                        try videoData.write(to: fileURL)
                        
                        if let imageThumb = self.getThumbnailImage(url: fileURL){
                            if let imageData = UIImageJPEGRepresentation(imageThumb, 0.5) {
                                try imageData.write(to: fileURLThumb)
                            }
                        }
                        
                        if let id = dict["id"] as? Int{
                            let galleryModelManager = GalleryModelManager()
                            galleryModelManager.createVideoContent(id: id, idContent: contentId)
                            HUDHelper.sharedInstance.hideHUD()
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
            HUDHelper.sharedInstance.hideHUD()
            onError("")
        }
    }
    
    func uploadAudio(audioData: Data, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        ApiClient.uploadAudio(audioData: audioData, onSuccess: { (response) in
            if let contentId = response["id"] as? Int{
                
                HUDHelper.sharedInstance.hideHUD()
                onSuccess(contentId)
                
            }
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()
            onError("")
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
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60) , actualTime: nil)
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
                    try fileManager.removeItem(atPath: tempFolderPath.path + "/" + filePath)
                }
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        } catch let error {
            print(error)
        }
        
        
    }
    
   
    
}
