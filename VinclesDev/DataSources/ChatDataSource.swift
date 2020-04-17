//
//  ChatDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift

protocol ChatDataSourceDelegate{
    func tappedImage(imageView: UIImageView)
    func tappedVideo(contentId: Int, isGroup: Bool)
    func reloadTable()
    func tappedError()

}


class ChatDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var toUserId = -1
    var toUser: User?
    var group: Group?
    var isDinam = false
    
    let chatModelManager = ChatModelManager()
    lazy var profileModelManager = ProfileModelManager()
    lazy var chatManager = ChatManager()
    var dsDelegate: ChatDataSourceDelegate?
    var items = [Any]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if items[indexPath.row] is String{
            let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! ChatDayTableViewCell
            cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            cell.transform =  CGAffineTransform(scaleX: 1, y: -1)
            cell.dateLabel.text = items[indexPath.row] as? String
            return cell
        }
            
        else if items[indexPath.row] is Date{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! ChatDayTableViewCell
            cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            cell.transform =  CGAffineTransform(scaleX: 1, y: -1)
            cell.configWithDate(date: items[indexPath.row] as! Date)
            
            return cell
        }
        else if let tuple = items[indexPath.row] as? (Int, String){
            if tuple.1 == "message"{
                
                if let message = chatModelManager.messageWith(id: tuple.0){
                    if message.idUserFrom == profileModelManager.getUserMe()?.id{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingTextCell", for: indexPath) as! OutgoingChatTableViewCell
                        cell.transform =  CGAffineTransform(scaleX: 1, y: -1)
                        var hideAvatar = false
                        if indexPath.row < items.count - 1{
                            if let nextMessage = items[indexPath.row + 1] as? Message{
                                if nextMessage.idUserFrom == profileModelManager.getUserMe()?.id{
                                    hideAvatar = true
                                }
                            }
                        }
                        cell.configWithMessage(messageId: tuple.0, sender: profileModelManager.getUserMe()!, hideAvatar: hideAvatar)
                        cell.delegate = self
                        
                        return cell
                    }
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "incomingTextCell", for: indexPath) as! IncomingChatTableViewCell
                    
                    var hideAvatar = false
                    if indexPath.row < items.count - 1{
                        if let nextMessage = items[indexPath.row + 1] as? Message{
                            if nextMessage.idUserFrom == message.idUserFrom{
                                hideAvatar = true
                            }
                        }
                    }
                    if let toUser = toUser{
                        cell.configWithMessage(messageId: tuple.0, sender: toUser, hideAvatar: hideAvatar)
                    }
                    cell.transform =  CGAffineTransform(scaleX: 1, y: -1)
                    
                    cell.delegate = self
                    return cell
                }
            }
            else if tuple.1 == "groupMessage"{
                if let message = chatModelManager.groupMessageWith(id: tuple.0){
                    
                    if message.idUserSender == profileModelManager.getUserMe()?.id{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingTextCell", for: indexPath) as! OutgoingChatTableViewCell
                        cell.transform =  CGAffineTransform(scaleX: 1, y: -1)
                        var hideAvatar = false
                        if indexPath.row < items.count - 1{
                            if let nextMessage = items[indexPath.row + 1] as? Message{
                                if nextMessage.idUserFrom == profileModelManager.getUserMe()?.id{
                                    hideAvatar = true
                                }
                            }
                        }
                        cell.configWithGroupMessage(messageId: tuple.0, hideAvatar: hideAvatar)
                        cell.delegate = self
                        
                        return cell
                    }
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "incomingTextCell", for: indexPath) as! IncomingChatTableViewCell
                    
                    var hideAvatar = false
                    if indexPath.row < items.count - 1{
                        if let nextMessage = items[indexPath.row + 1] as? GroupMessage{
                            if nextMessage.idUserSender == message.idUserSender{
                                hideAvatar = true
                            }
                        }
                    }
                    cell.configWithGroupMessage(messageId: tuple.0, hideAvatar: hideAvatar)
                    
                    cell.transform =  CGAffineTransform(scaleX: 1, y: -1)
                    
                    cell.delegate = self
                    return cell
                }
            }
            else if tuple.1 == "notification"{
                let realm = try! Realm()
                if let notification = realm.objects(VincleNotification.self).filter("id == %i", tuple.0).first{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! ChatCallTableViewCell
                    cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                    cell.transform =  CGAffineTransform(scaleX: 1, y: -1)
                    cell.configWithNotification(notification: notification)
                    
                    return cell
                }
                
                
            }
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! ChatDayTableViewCell
        return cell
        
    }
    
    
    func loadNext(){
        
        if toUserId != -1{
            if let sendTime = chatModelManager.oldestMessageDate(circleId: toUserId){
                chatManager.lastItemDate = sendTime
                chatManager.loadingItems = true
                chatManager.getChatUserMessages(fromUser: toUserId, onSuccess: { (hasMoreItems, needsReload) in
                    if needsReload{
                        
                        self.dsDelegate?.reloadTable()
                    }
                }) { (error) in
                    
                }
                
            }
        }
        else if group != nil{
            if let sendTime = chatModelManager.oldestGroupMessageDate(idChat: group!.idChat){
                chatManager.lastItemDate = sendTime
                chatManager.loadingItems = true
                chatManager.getChatGroupMessages(fromGroup: group!.idChat, onSuccess: { (hasMoreItems, needsReload) in
                    if needsReload{
                        
                        self.dsDelegate?.reloadTable()
                    }
                }) { (error) in
                    
                }
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 3{
            if !chatManager.loadingItems{
                
                loadNext()
            }
            
        }
        
        if let tuple = items[indexPath.row] as? (Int, String){
            if tuple.1 == "notification"{
                let realm = try! Realm()
                if let not = realm.objects(VincleNotification.self).filter("id == %i", tuple.0).first{
                    if !not.watched{
                        let realm = try! Realm()
                        try! realm.write {
                            not.watched = true
                        }
                    }
                }
                
                
            }
            
        }
        
        
        /*
         let realm = try! Realm()
         
         let notifications = realm.objects(VincleNotification.self).filter("watched = %@", false)
         
         for not in notifications{
         try! realm.write {
         not.watched = true
         }
         }
         */
        
        if let cell = cell as? OutgoingChatTableViewCell{
            cell.setAvatar()
            
            for contentId in cell.contentIds{
                cell.setExistingItem(adjunt: contentId)
            }
          
            
        }
        else if let cell = cell as? IncomingChatTableViewCell{
            cell.setAvatar()
            
            for contentId in cell.contentIds{
                cell.setExistingItem(adjunt: contentId)
            }
        }
        else if let cell = cell as? ChatCallTableViewCell{
            cell.setAvatar()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}

extension ChatDataSource: IncomingChatTableViewCellDelegate{
    func tappedImage(imageView: UIImageView) {
        dsDelegate?.tappedImage(imageView: imageView)
    }
    
    func tappedVideo(contentId: Int, isGroup: Bool) {
        dsDelegate?.tappedVideo(contentId: contentId, isGroup: isGroup)
        
    }
    
    func tappedError() {
        dsDelegate?.tappedError()
    }
    
}

extension ChatDataSource: OutgoingChatTableViewCellDelegate{
    func tappedImageOut(imageView: UIImageView) {
        dsDelegate?.tappedImage(imageView: imageView)
    }
    
    func tappedVideoOut(contentId: Int, isGroup: Bool) {
        dsDelegate?.tappedVideo(contentId: contentId, isGroup: isGroup)
        
    }
    
    func tappedErrorOut() {
        dsDelegate?.tappedError()
    }
    
}

