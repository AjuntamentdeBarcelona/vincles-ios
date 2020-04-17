//
//  GalleryManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SwiftyJSON

class GalleryManager: NSObject {
    lazy var galleryModelManager = GalleryModelManager()

    var lastItemDate: Int64 = 0
    var loadingItems = false
    var fromDate: Int64?
    var reachedEnd = false

    func getContentsLibrary(onSuccess: @escaping (Bool, Bool) -> (), onError: @escaping (String) -> ()) {
        
        loadingItems = true
       
        var hasChanged = false
  
        lastItemDate = galleryModelManager.oldestContentDateInt() ?? Int64(Date().timeIntervalSince1970 * 1000)
        

        ApiClientURLSession.sharedInstance.getContentsLibrary(to: lastItemDate, onSuccess: { (array) in
            print("FINISH LOADING")

            DispatchQueue.main.async {
                print("LOADING ITEMS FALSE")
                self.loadingItems = false
                
                if array.count > 0{
                    let (date, changes) = self.galleryModelManager.addContents(array: array)
                    if date != nil{
                        self.lastItemDate = date!
                    }
                    hasChanged = changes
                    print("LOADING ITEMS FALSE")
                    self.loadingItems = false
                }
                
                if self.fromDate != nil{
                    if array.count == 10 && self.lastItemDate > self.fromDate!{
                        onSuccess(true, hasChanged)
                    }
                    else{
                        self.reachedEnd = true
                        onSuccess(false, hasChanged)
                    }
                }
                else{
                    
                    if array.count == 10{
                        onSuccess(true, hasChanged)
                    }
                    else{
                        self.reachedEnd = true
                        onSuccess(false, hasChanged)
                    }
                }
            }
           
            
        }) { (error) in
            if error == TOKEN_FAIL{
                ApiClientURLSession.sharedInstance.refreshToken(onSuccess: {
                    print("token refreshed")
                    ApiClientURLSession.sharedInstance.getContentsLibrary(to: self.lastItemDate, onSuccess: { (array) in
                        DispatchQueue.main.async {
                            print("REFRESHED \(self.lastItemDate) \(array)")
                            print("LOADING ITEMS FALSE")

                            self.loadingItems = false
                            
                            if array.count > 0{
                                let (date, changes) = self.galleryModelManager.addContents(array: array)
                                print(" REFRESHED reload get contents \(self.galleryModelManager.numberOfGalleryContents)")
                                if date != nil{
                                    self.lastItemDate = date!
                                }
                                hasChanged = changes
                                print("LOADING ITEMS FALSE")
                                self.loadingItems = false
                            }
                            
                            if self.fromDate != nil{
                                if array.count == 10 && self.lastItemDate > self.fromDate!{
                                    print("REFRESHED reload get contents 2 \(self.galleryModelManager.numberOfGalleryContents)")
                                    onSuccess(true, hasChanged)
                                }
                                else{
                                    self.reachedEnd = true
                                    onSuccess(false, hasChanged)
                                }
                            }
                            else{
                                
                                if array.count == 10{
                                    print("REFRESHED reload get contents 3 \(self.galleryModelManager.numberOfGalleryContents)")
                                    onSuccess(true, hasChanged)
                                }
                                else{
                                    self.reachedEnd = true
                                    onSuccess(false, hasChanged)
                                }
                            }
                        }
                        
                        
                    }) { (error) in
                            onError(error)

                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        let navigationManager = NavigationManager()
                        navigationManager.showUnauthorizedLogin()
                    }
                    
                }
            }
            else{
                onError(error)
            }

        }
        
        
    }
    
    func shareContent(contentId: [Int], contactIds: [Any], metadataTipus: [String], onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        HUDHelper.sharedInstance.showHud(message: "")

        var usersIds = [Int]()
        var chatIds = [Int]()
        var dinamIds = [Int]()
        var groupIds = [Int]()
        var dinamGroupIds = [Int]()

        let circlesGroupsModelManager = CirclesGroupsModelManager.shared
        for item in contactIds{
            if let user = item as? User{
                var isDinam = false
                if let groups = circlesGroupsModelManager.groups{
                    for group in groups{
                        if group.dynamizer?.id == user.id{
                            isDinam = true
                            dinamIds.append(group.idDynamizerChat)
                            dinamGroupIds.append(group.idChat)

                        }
                    }
                }
                if !isDinam{
                    usersIds.append(user.id)
                }
            }
            if let group = item as? Group{
                groupIds.append(group.idChat)
            }
        }
        
        chatIds = groupIds + dinamIds
        
        let chatsToLoad = usersIds.count + chatIds.count
        var completed = 0
        
        
        ApiClient.shareContent(contentId: contentId, usersIds: usersIds, chatIds: chatIds, metadataTipus: metadataTipus,  onSuccess: {
            
            let chatManager = ChatManager()
            
            for userId in usersIds{
                chatManager.getChatUserMessages(fromUser: userId, onSuccess: { (hasMoreItems, needsReload) in
                    completed += 1
                    if completed == chatsToLoad{
                        HUDHelper.sharedInstance.hideHUD()
                        onSuccess()
                        
                    }
                }) { (error) in
                    onError(L10n.errorGenerico)
                    HUDHelper.sharedInstance.hideHUD()

                }
            }
         
            for idChat in groupIds{
                chatManager.getChatGroupMessages(fromGroup: idChat, onSuccess: { (hasMoreItems, needsReload) in
                    completed += 1
                    if completed == chatsToLoad{
                        onSuccess()
                        HUDHelper.sharedInstance.hideHUD()

                    }
                }) { (error) in
                    onError(L10n.errorGenerico)
                    HUDHelper.sharedInstance.hideHUD()

                }
            }
            
            for idChat in dinamGroupIds{
                chatManager.getChatDinamitzadorMessages(fromGroup: idChat, onSuccess: { (hasMoreItems, needsReload) in
                    completed += 1
                    if completed == chatsToLoad{
                        onSuccess()
                        HUDHelper.sharedInstance.hideHUD()

                    }
                }) { (error) in
                    
                    HUDHelper.sharedInstance.hideHUD()

                    onError(L10n.errorGenerico)
                }
            }
            
          
        }) { (error) in
            HUDHelper.sharedInstance.hideHUD()

            onError(error )

        }
    }
    
    func getContentLibrary(id: Int, onSuccess: @escaping () -> (), onError: @escaping (String, Int) -> ()) {
        let params = ["id": id]
        
        ApiClient.getSpecificContent(params: params, onSuccess: { (dict) in
            self.galleryModelManager.addContent(dict: dict)

            onSuccess()

        }) { (error, status) in
            onError(error, status )

        }
        
        
    }
}
