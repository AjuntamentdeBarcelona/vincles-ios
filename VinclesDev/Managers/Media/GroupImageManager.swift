//
//  GroupImageManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

import UIKit

protocol GroupImageManagerDelegate: AnyObject {
    func didDownload(groupId: Int)
    func didError(groupId: Int)
}

class GroupImageManager: NSObject {
    static let sharedInstance = GroupImageManager()
    let fileManager = FileManager.default
    weak var delegate:GroupImageManagerDelegate?
    
    // Galeria
    var downloadingIds = Set<Int>()
    var errorIds = Set<Int>()
    
    func getGroupPicture(groupId: Int) -> URL?{
        
        if groupPictureExists(groupId: groupId){
            let fileURLThumb = getGroupImageUrl(groupId: groupId)
            
            return fileURLThumb
        }
        else if downloadingIds.contains(groupId){
            return nil
        }
        else{
            downloadGroupPicture(groupId: groupId)
        }
        return nil
    }
    
    func groupPictureExists(groupId: Int) -> Bool{
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLThumb = documentDirectory.appendingPathComponent("group\(groupId).jpg")
            
            if fileManager.fileExists(atPath: fileURLThumb.path){
                return true
            }
            
        }
        catch{
            print("error")
        }
        
        return false
    }
    
    func getGroupImageUrl(groupId: Int) -> URL?{
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            
            let fileURLThumb = documentDirectory.appendingPathComponent("group\(groupId).jpg")
            
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
    
    func downloadGroupPicture(groupId: Int){
        let authManager = AuthModelManager()
        if authManager.hasUser{
            downloadingIds.insert(groupId)
        }
        

        ApiClient.downloadGroupPicture(id: groupId, size: CGFloat(200), onSuccess: { (data) in
            DispatchQueue.main.async {
                if(self.downloadingIds.contains(groupId)){
                    self.downloadingIds.remove(groupId)
                }
                if(self.errorIds.contains(groupId)){
                    self.errorIds.remove(groupId)
                }
            }
            self.saveGroupPicture(groupId: groupId, data: data)
            
            
        }) { (error) in

            if(self.downloadingIds.contains(groupId)){
                self.downloadingIds.remove(groupId)
            }
            
            let authManager = AuthModelManager()
            if authManager.hasUser{
                self.errorIds.insert(groupId)
                self.delegate?.didError(groupId: groupId)
            }
        }
    }
    
    
    
    func saveGroupPicture(groupId: Int, data: Data){
        do {
            let documentDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURLThumb = documentDirectory.appendingPathComponent("group\(groupId).jpg")
            try data.write(to: fileURLThumb)
            
            DispatchQueue.main.async {
                self.delegate?.didDownload(groupId: groupId)
            }
            
        }
        catch{

        }
        
    }
    
    func removeGroupPicture(groupId: Int){
        
        let documentDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent("group\(groupId).jpg")
        if fileManager.fileExists(atPath: fileURL.path){
            do {
                try fileManager.removeItem(at: fileURL)
                
            } catch {
                
            }
        }
    }
    
    
}
