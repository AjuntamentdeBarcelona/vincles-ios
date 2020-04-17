//
//  ProfileManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol ProfileEventImageManagerDelegate: AnyObject {
    func didDownloadEvent(userId: Int)
    func didErrorEvent(userId: Int)
}

class ProfileEventImageManager: NSObject {
    static let sharedInstance = ProfileEventImageManager()
    let fileManager = FileManager.default
    weak var delegate:ProfileEventImageManagerDelegate?
    
    // Galeria
    var downloadingIds = Set<Int>()
    var errorIds = Set<Int>()
    
    func getProfilePicture(userId: Int, meetingId: Int) -> URL?{
        
        if profilePictureExists(userId: userId){
            let fileURLThumb = getProfileImageUrl(userId: userId)
            
            return fileURLThumb
        }
        else if downloadingIds.contains(userId){
            return nil
        }
        else{
            downloadProfilePicture(userId: userId, meetingId: meetingId)
        }
        return nil
    }
    
    func profilePictureExists(userId: Int) -> Bool{
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLThumb = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            
            if fileManager.fileExists(atPath: fileURLThumb.path){
                return true
            }
            
        }
        catch{
            print("error")
        }
        
        return false
    }
    
    func getProfileImageUrl(userId: Int) -> URL?{
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLThumb = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            
            if fileManager.fileExists(atPath: fileURLThumb.path){
                return fileURLThumb
            }
            return nil
        }
        catch{
            print("error")
        }
        return nil
    }
    
    func downloadProfilePicture(userId: Int, meetingId: Int){
        let authManager = AuthModelManager()
        if authManager.hasUser{
            downloadingIds.insert(userId)
        }
        
        
        ApiClient.downloadProfilePictureEvent(meetingId: meetingId, id: userId, size: CGFloat(200), onSuccess: { data in
            DispatchQueue.main.async {
                if(self.downloadingIds.contains(userId)){
                    self.downloadingIds.remove(userId)
                }
                if(self.errorIds.contains(userId)){
                    self.errorIds.remove(userId)
                }
            }
            
            self.saveProfilePicture(userId: userId, data: data)
            
            
        }) { (error) in
            if(self.downloadingIds.contains(userId)){
                self.downloadingIds.remove(userId)
            }
            
            let authManager = AuthModelManager()
            if authManager.hasUser{
                self.errorIds.insert(userId)
                self.delegate?.didErrorEvent(userId: userId)
            }
        }
    }
    
    
    
    func saveProfilePicture(userId: Int, data: Data){
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLThumb = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            try data.write(to: fileURLThumb)
            
            DispatchQueue.main.async {
                self.delegate?.didDownloadEvent(userId: userId)
            }
            
        }
        catch{
            print("error")
        }
        
    }

    
}

