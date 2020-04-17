//
//  ProfileManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol ProfileImageManagerDelegate: AnyObject {
    func didDownload(userId: Int)
    func didError(userId: Int)
}

class ProfileImageManager: NSObject {
    static let sharedInstance = ProfileImageManager()
    let fileManager = FileManager.default
    weak var delegate:ProfileImageManagerDelegate?
    
    // Galeria
    var downloadingIds = Set<Int>()
    var errorIds = Set<Int>()
    
    func getProfilePicture(userId: Int) -> URL?{
        
        if profilePictureExists(userId: userId){
            let fileURLThumb = getProfileImageUrl(userId: userId)
            
            return fileURLThumb
        }
        else if downloadingIds.contains(userId){
            return nil
        }
        else{
            downloadProfilePicture(userId: userId)
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
    
    func downloadProfilePicture(userId: Int){
        let authManager = AuthModelManager()
        if authManager.hasUser{
            downloadingIds.insert(userId)
        }
        
        
        ApiClient.downloadProfilePicture(id: userId, size: CGFloat(200), onSuccess: { (data) in
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
                self.delegate?.didError(userId: userId)
            }
        }
    }
    
    
    
    func saveProfilePicture(userId: Int, data: Data){
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLThumb = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            try data.write(to: fileURLThumb)
            
            DispatchQueue.main.async {
                self.delegate?.didDownload(userId: userId)
            }
            
        }
        catch{
            print("error")
        }
        
    }
    
    func removeProfilePicture(userId: Int){
        
        let documentDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent("profile\(userId).jpg")
        if fileManager.fileExists(atPath: fileURL.path){
            do {
                try fileManager.removeItem(at: fileURL)
                
            } catch {
                
            }
        }
    }
    
    func saveUserPhotoRegister(userId: String, image: UIImage, onCompletion: @escaping () -> ()){
        
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("profile\(userId).jpg")
            
            do {
                let data = image.jpegData(compressionQuality: 0.8)
                try data?.write(to: fileURL)
                onCompletion()
                
            } catch {

            }
            
        } catch {

        }
        
    }
    
    func getUserPhotoRegister( onCompletion: @escaping (UIImage?) -> ()){
        
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
    
}
