//
//  GalleryManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import SwiftyJSON

class GalleryManager: NSObject {
    lazy var galleryModelManager = GalleryModelManager()

    var lastItemDate = Date()
    var loadingItems = false
    var fromDate: Date?
    
    func getContentsLibrary(onSuccess: @escaping (Bool, Bool) -> (), onError: @escaping (String) -> ()) {
        
        loadingItems = true
       
        var hasChanged = false
        
        ApiClient.getContentsLibrary(to: lastItemDate, onSuccess: { (array) in
            
            if array.count > 0{
                let (date, changes) = self.galleryModelManager.addContents(array: array)
                if date != nil{
                    self.lastItemDate = date!
                }
                hasChanged = changes
                self.loadingItems = false
            }
            
            if self.fromDate != nil{
                if array.count == 10 && self.lastItemDate > self.fromDate!{
                    onSuccess(true, hasChanged)
                }
                else{
                    onSuccess(false, hasChanged)
                }
            }
            else{
                
                if array.count == 10{
                    onSuccess(true, hasChanged)
                }
                else{
                    onSuccess(false, hasChanged)
                }
            }
            
        }) { (error) in
            onError(error )
        }
        
        
    }
    
    func shareContent(contentId: [Int], contactIds: [Any], onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        HUDHelper.sharedInstance.showHud(message: "")

        var usersIds = [Int]()
        var chatIds = [Int]()
        var dinamIds = [Int]()
        var groupIds = [Int]()
        var dinamGroupIds = [Int]()

        let circlesGroupsModelManager = CirclesGroupsModelManager()
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
        
        ApiClient.shareContent(contentId: contentId, usersIds: usersIds, chatIds: chatIds, onSuccess: {
            
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
