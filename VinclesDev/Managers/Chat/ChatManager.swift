//
//  ChatManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import SwiftyJSON

class ChatManager: NSObject {
    
    lazy var chatModelManager = ChatModelManager()
    var lastItemDate = Date()
    var loadingItems = false
    var fromDate: Date?
    lazy var circlesManager = CirclesManager()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager()

    func sendUserTextMessage(toUser: Int, message: String, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {

        let profileModelManager = ProfileModelManager()
        guard let id = profileModelManager.getUserMe()?.id else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["idUserTo": toUser, "idUserFrom": id, "text": message, "metadataTipus": "TEXT_MESSAGE"] as [String : Any]
        
        ApiClient.sendUserMessage(params: params, onSuccess: {dict in
           
            
            if let id = dict["id"] as? Int{
                onSuccess(id)

            }
            else{
                onError(L10n.errorGenerico)
            }
            
        }) { (error) in
            onError(error)

        }
    }
    
    func sendUserImageMessage(toUser: Int, contentId: Int, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        let profileModelManager = ProfileModelManager()
        guard let id = profileModelManager.getUserMe()?.id else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["idUserTo": toUser, "idUserFrom": id, "idAdjuntContents": [contentId], "metadataTipus": "IMAGES_MESSAGE"] as [String : Any]
        
        ApiClient.sendUserMessage(params: params, onSuccess: {dict in 
            if let id = dict["id"] as? Int{
                onSuccess(id)
                
            }
            else{
                onError(L10n.errorGenerico)
            }
        }) { (error) in
            
        }
    }
    
    func sendUserVideoMessage(toUser: Int, contentId: Int, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        let profileModelManager = ProfileModelManager()
        guard let id = profileModelManager.getUserMe()?.id else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["idUserTo": toUser, "idUserFrom": id, "idAdjuntContents": [contentId], "metadataTipus": "VIDEO_MESSAGE"] as [String : Any]
        
        ApiClient.sendUserMessage(params: params, onSuccess: {dict in
            if let id = dict["id"] as? Int{
                onSuccess(id)
                
            }
            else{
                onError(L10n.errorGenerico)
            }
        }) { (error) in
            
        }
    }
    
    func sendAudioMessage(toUser: Int, contentId: Int, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        let profileModelManager = ProfileModelManager()
        guard let id = profileModelManager.getUserMe()?.id else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["idUserTo": toUser, "idUserFrom": id, "idAdjuntContents": [contentId], "metadataTipus": "AUDIO_MESSAGE"] as [String : Any]
        
        ApiClient.sendUserMessage(params: params, onSuccess: {dict in
            if let id = dict["id"] as? Int{
                onSuccess(id)
                
            }
            else{
                onError(L10n.errorGenerico)
            }
        }) { (error) in
            
        }
    }
    
    func getAllChatUserMessages(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        let numberOfCircles = circlesGroupsModelManager.numberOfContacts
        var completed = 0
        if let circles = circlesGroupsModelManager.circles{
            if circles.count == 0{
                onSuccess()

            }
            else{
                for user in circles{
                    self.getChatUserMessages(fromUser: user.id, onSuccess: { (hasMoreItems, needsReload) in
                        completed += 1
                        if completed == numberOfCircles{
                            onSuccess()
                        }
                    }) { (error) in
                        onError("")
                    }
                }
            }
            
            
        }
        else{
            onSuccess()
        }
        
    }
    
    func getAllChatGroupMessages(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        let numberOfGroups = circlesGroupsModelManager.numberOfGroups
        var completed = 0
        if let groups = circlesGroupsModelManager.groups{
            if groups.count == 0{
                onSuccess()
                
            }
            else{
                for group in groups{
                    ApiClient.getChatLastAccess(params: ["idChat": group.idChat], onSuccess: { (respDict) in
                        if let lastAccess = respDict["lastAccess"] as? Int64{
                            UserDefaults.standard.set(lastAccess, forKey: "\(group.idChat)")
                        }
                        self.getChatGroupMessages(fromGroup: group.idChat, onSuccess: { (hasMoreItems, needsReload) in
                            completed += 1
                            if completed == numberOfGroups{
                                onSuccess()
                            }
                        }) { (error) in
                            onError("")
                        }
                    }) { (error) in
                        onError("")
                    }
                   
                }
            }
            
            
        }
        else{
            onSuccess()
        }
        
    }
    
    func getAllChatDinamitzadorsMessages(onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        let numberOfGroups = circlesGroupsModelManager.numberOfGroups
        var completed = 0
        if let groups = circlesGroupsModelManager.groups{
            if groups.count == 0{
                onSuccess()
                
            }
            else{
                for group in groups{
                    
                    ApiClient.getChatLastAccess(params: ["idChat": group.idDynamizerChat], onSuccess: { (respDict) in
                        if let lastAccess = respDict["lastAccess"] as? Int64{
                            UserDefaults.standard.set(lastAccess, forKey: "\(group.idDynamizerChat)")
                        }
                        self.getChatDinamitzadorMessages(fromGroup: group.idChat, onSuccess: { (hasMoreItems, needsReload) in
                            completed += 1
                            if completed == numberOfGroups{
                                onSuccess()
                            }
                        }) { (error) in
                            onError("")
                        }
                    }) { (error) in
                        onError("")
                    }
                    
                    
                   
                }
            }
            
            
        }
        else{
            onSuccess()
        }
        
    }
    
    
    func getChatUserMessages(fromUser: Int, onSuccess: @escaping (Bool, Bool) -> (), onError: @escaping (String) -> ()) {

        loadingItems = true
        
        let params = ["idUser": fromUser, "to": Int64(lastItemDate.timeIntervalSince1970 * 1000)] as [String : Any]
        
        loadingItems = true
        
        var hasChanged = false
        
        ApiClient.getChatUserMessages(params: params, onSuccess: { (array) in
            
            if array.count > 0{
                let (date, changes) = self.chatModelManager.addMessages(circleId: fromUser, array: array)
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
            
            self.loadingItems = false

        }) { (error) in
            onError(error )
        }
        
    }
    
    func getChatUserMessageById(idMessage: Int, onSuccess: @escaping (Message) -> (), onError: @escaping (String, Int) -> ()) {
        
        let params = ["idMessage": idMessage] as [String : Any]
        
        ApiClient.getMessageById(params: params, onSuccess: { (dict) in
            print(dict)
            let message = self.chatModelManager.addMessage(dict: dict as [String : AnyObject])
            onSuccess(message)

        }) { (error, status) in
            onError(error, status)
        }
        
    }
    
    func markMessage(idMessage: Int, onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        
        let params = ["idMessage": idMessage] as [String : Any]
        
        ApiClient.markMessageWatched(params: params, onSuccess: { (dict) in
            onSuccess(true)
            
        }) { (error) in
            onError(error )
        }
        
        // TODO WATCHED
    }
    
    
    func getBubbleSizeForMessage(message: Message, width: CGFloat, font: UIFont) -> CGSize{
  
        print(message.messageText)
        if message.idAdjuntContents.count > 0{
            // TODO MEDIA MESSAGE
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = message.messageText.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            
            var height = boundingBox.height
           
            if message.messageText.count == 0{
                height = 0
            }
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: width * 2/4, height: height * 2/4)
            }
            return CGSize(width: width, height: height)
        }
        else{
           
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = message.messageText.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)

            return CGSize(width: boundingBox.width, height: boundingBox.height + 10)
            
        }
        
    }
    
  
    func estimatedHeightOfLabel(width: CGFloat, text: String, font: UIFont) -> CGFloat {
        
        let size = CGSize(width: width, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedStringKey.font: font]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    
    func getChatGroupMessages(fromGroup: Int, onSuccess: @escaping (Bool, Bool) -> (), onError: @escaping (String) -> ()) {
        
        loadingItems = true
        
        let params = ["idChat": fromGroup, "to": Int64(lastItemDate.timeIntervalSince1970 * 1000)] as [String : Any]
        
        loadingItems = true
        
        var hasChanged = false
        
        ApiClient.getChatGroupMessages(params: params, onSuccess: { (array) in
            
            
            if array.count > 0{
                let (date, changes) = self.chatModelManager.addGroupMessages(chatId: fromGroup, array: array)
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
            
            self.loadingItems = false
            
        }) { (error) in
            onError(error )
        }
        
    }
    
    func getChatDinamitzadorMessages(fromGroup: Int, onSuccess: @escaping (Bool, Bool) -> (), onError: @escaping (String) -> ()) {
        
      //    let group = circlesGroupsModelManager.groupWithId(id: fromGroup)
      let group = circlesGroupsModelManager.groupWithChatId(idChat: fromGroup)

        loadingItems = true
        
        let params = ["idChat": group?.idDynamizerChat ?? -1, "to": Int64(lastItemDate.timeIntervalSince1970 * 1000)] as [String : Any]
        
        loadingItems = true
        
        var hasChanged = false
        
        ApiClient.getChatGroupMessages(params: params, onSuccess: { (array) in
            
            
            if array.count > 0{
                let (date, changes) = self.chatModelManager.addDinamitzadorMessages(chatId: fromGroup, array: array)
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
            
            self.loadingItems = false
            
        }) { (error) in
            onError(error )
        }
        
    }
    
    func getBubbleSizeForGroupMessage(message: GroupMessage, width: CGFloat, font: UIFont) -> CGSize{
        
        if message.idContent != -1{
            // TODO MEDIA MESSAGE
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = message.text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            
            var height = boundingBox.height
            
            if message.text.count == 0{
                height = 0
            }
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: width * 2/4, height: height * 2/4)
            }
            return CGSize(width: width, height: height)
        }
        else{
            
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = message.text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
            
            let height = boundingBox.height
            
            return CGSize(width: boundingBox.width + 5, height: height)
            
        }
        
    }
    
    func sendGroupTextMessage(idChat: Int, message: String, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["text": message, "metadataTipus": "TEXT_MESSAGE", "idChat": idChat] as [String : Any]
        
        ApiClient.sendGroupMessage(params: params, onSuccess: {dict in

            if let id = dict["id"] as? Int{
                onSuccess(id)
                
            }
            else{
                onError(L10n.errorGenerico)
            }
            
        }) { (error) in
            onError(error)
            
        }
    }
    
    func sendGroupVideoMessage(idChat: Int, contentId: Int, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["idContent": contentId, "metadataTipus": "VIDEO_MESSAGE", "idChat": idChat] as [String : Any]

        
        ApiClient.sendGroupMessage(params: params, onSuccess: {dict in
            if let id = dict["id"] as? Int{
                onSuccess(id)
                
            }
            else{
                onError(L10n.errorGenerico)
            }
        }) { (error) in
            
        }
    }
    
    func sendGroupImageMessage(idChat: Int, contentId: Int, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["idContent": contentId, "metadataTipus": "IMAGES_MESSAGE", "idChat": idChat] as [String : Any]
        
        
        ApiClient.sendGroupMessage(params: params, onSuccess: {dict in
            if let id = dict["id"] as? Int{
                onSuccess(id)
                
            }
            else{
                onError(L10n.errorGenerico)
            }
        }) { (error) in
            
        }
    }
    
    func sendGroupAudioMessage(idChat: Int, contentId: Int, onSuccess: @escaping (Int) -> (), onError: @escaping (String) -> ()) {
        
        let profileModelManager = ProfileModelManager()
        guard (profileModelManager.getUserMe()?.id) != nil else{
            onError(L10n.errorGenerico)
            return
        }
        
        let params = ["idContent": contentId, "metadataTipus": "AUDIO_MESSAGE", "idChat": idChat] as [String : Any]
        
        
        ApiClient.sendGroupMessage(params: params, onSuccess: {dict in
            if let id = dict["id"] as? Int{
                onSuccess(id)
                
            }
            else{
                onError(L10n.errorGenerico)
            }
        }) { (error) in
            
        }
    }
    
    func getChatGroupMessageById(idChat: Int, idMessage: Int, onSuccess: @escaping (GroupMessage) -> (), onError: @escaping (String, Int) -> ()) {
        
        let params = ["idMessage": idMessage, "idChat": idChat] as [String : Any]
        
        ApiClient.getGroupMessageById(params: params, onSuccess: { (dict) in
            let circlesModelManager = CirclesGroupsModelManager()
            
            if circlesModelManager.groupWithChatId(idChat: idChat) != nil{
                let message = self.chatModelManager.addGroupMessage(dict: dict as [String : AnyObject])
                onSuccess(message)
                
            }
            else if circlesModelManager.dinamitzadorWithChatId(idChat: idChat) != nil{
                let message = self.chatModelManager.addDinamitzadorMessage(dict: dict as [String : AnyObject])
                onSuccess(message)
            }
            else{
                onError("error", 403 )
            }
            
           
            
        }) { (error, status) in
            onError(error, status )
        }
        
    }
    
    func getChatDinamitzadorMessageById(idChat: Int, idMessage: Int, onSuccess: @escaping (GroupMessage) -> (), onError: @escaping (String) -> ()) {
        
        let params = ["idMessage": idMessage, "idChat": idChat] as [String : Any]
        
        ApiClient.getGroupMessageById(params: params, onSuccess: { (dict) in
            
            let message = self.chatModelManager.addDinamitzadorMessage(dict: dict as [String : AnyObject])
            onSuccess(message)
            
        }) { (error, status) in
            onError(error )
        }
        
    }
}
