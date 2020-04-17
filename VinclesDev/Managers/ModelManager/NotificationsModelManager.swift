//
//  NotificationsModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON
class NotificationsModelManager: NSObject {
    
    lazy var chatManager = ChatManager()
    lazy var circlesManager = CirclesManager()
    lazy var notificationManager = NotificationManager()
    lazy var agendaManager = AgendaManager()
    lazy var agendaModelManager = AgendaModelManager()

    var numberOfNotifications: Int{
        let realm = try! Realm()
        return realm.objects(VincleNotification.self).count
    }
    
    var numberOfUnwatchedNotifications: Int{
        let realm = try! Realm()
        return realm.objects(VincleNotification.self).filter("processed = %@", false).count
    }
    
    var numberOfUnremovedNotifications: Int{
        let realm = try! Realm()
        return realm.objects(VincleNotification.self).filter("removed = %@", false).count
    }
    
    
    func newestProcessedNotificationDate() -> Int64?{
        let realm = try! Realm()
        
        let notification = realm.objects(VincleNotification.self).filter("processed = %@", true).sorted(by: { $0.creationTimeInt > $1.creationTimeInt }).first
        return notification?.creationTimeInt
    }
    
    func oldestUnprocessedNotificationDate() -> Int64?{
        let realm = try! Realm()
        
        let notification = realm.objects(VincleNotification.self).filter("processed = %@", false).sorted(by: { $0.creationTimeInt < $1.creationTimeInt }).first
        return notification?.creationTimeInt
    }
    
    func oldestUnprocessedNotification() -> VincleNotification?{
        let realm = try! Realm()
        
        let notification = realm.objects(VincleNotification.self).filter("processed = %@", false).sorted(by: { $0.creationTimeInt < $1.creationTimeInt }).first
        return notification
    }
    
    var getNextFakeNotificationId: Int{
        let realm = try! Realm()

        var value32 = Int32.max
        while realm.objects(VincleNotification.self).filter("id = %i", value32).first != nil{
            value32 -= 1
        }
        return Int(value32)

    }
    
    func removeFakeNotificationForMeeting(meeting: Meeting){
        let realm = try! Realm()
        let notis = realm.objects(VincleNotification.self).filter("idMeeting = %i", meeting.id)
        
        for noti in notis{
            if noti.type == NOTI_FAKE_REMINDER_EVENT{
                try! realm.write {
                    realm.delete(noti)
                }
            }
        }
       
        
        
    }
    
    func addNotifications(array: [[String:Any]]){
        let realm = try! Realm()
        
        
        for dict in array{
            let notificacio = VincleNotification(json: JSON(dict))
            
            if realm.objects(VincleNotification.self).filter("id == %i", notificacio.id).count == 0{
                try! realm.write {
                    realm.add(notificacio, update: true)
                }
            }
        }
        
    }
    
    
    func getNotification(id: Int) -> VincleNotification?{
        let realm = try! Realm()
        return realm.objects(VincleNotification.self).filter("id == %i", id).first
        
    }
    
    func notificationAt(index: Int) -> VincleNotification{
        let realm = try! Realm()
        
        return realm.objects(VincleNotification.self)[index]
    }
    
    func unremovedNotificationAt(index: Int) -> VincleNotification{
        let realm = try! Realm()
        
        return realm.objects(VincleNotification.self).filter("removed = %@", false).sorted(by: { $0.creationTimeInt > $1.creationTimeInt })[index]
    }
    
    func setAllNotificationsWatched(){
        let realm = try! Realm()
        let notifications = realm.objects(VincleNotification.self)
        for noti in notifications{
            try! realm.write {
                noti.processed = true
            }
        }
        
    }
    
    func setNotificationWatched(notification: VincleNotification){
        let realm = try! Realm()

        try! realm.write {
            notification.processed = true
        }
        
        
    }
    
    func manageUnwatchedNotification(notification: VincleNotification, receivedNotification: Int? = nil,  onProcessed: @escaping (VincleNotification?) -> ()){
        let realm = try! Realm()

        switch notification.type{
        case NOTI_NEW_MESSAGE:
            chatManager.getChatUserMessageById(idMessage: notification.idMessage, onSuccess: {message in
                self.setNotificationWatched(notification: notification)
                
                let notDict:[String: Any] = ["idFrom": message.idUserFrom, "idTo": message.idUserTo, "type": NOTI_NEW_MESSAGE]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
            
               
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }
            }
        case NOTI_NEW_CHAT_MESSAGE:
            chatManager.getChatGroupMessageById(idChat: notification.idChat, idMessage: notification.idChatMessage, onSuccess: { (message) in
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idChat": message.idChat, "type": NOTI_NEW_CHAT_MESSAGE]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
     
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }
                
            }
        case NOTI_USER_LINKED:
            
            circlesManager.getUserFullInfo(id: notification.idUser, onSuccess: { (user) in
                let chatManager = ChatManager()
                chatManager.getChatUserMessages(fromUser: notification.idUser, onSuccess: { (hasMoreItems, needsReload) in
                    self.setNotificationWatched(notification: notification)
                    let notDict:[String: Any] = ["idUser": notification.idUser, "type": NOTI_USER_LINKED]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                    
                    onProcessed(notification)
                }) { (error) in
                    self.setNotificationWatched(notification: notification)
                    
                    onProcessed(notification)
                    
                }
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }
               
            }
          
        case NOTI_USER_UNLINKED, NOTI_USER_LEFT_CIRCLE:
            if receivedNotification != nil{
                if receivedNotification == notification.id{
                    notificationManager.showLocalNotificationForRemoveUser(id: notification.idUser)
                }
            }
            
            if CirclesGroupsModelManager.shared.removeContactItem(id: notification.idUser){
                let notDict:[String: Any] = ["idUser": notification.idUser, "type": NOTI_USER_UNLINKED]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
            }
            else{
                try! realm.write {
                    notification.removed = true
                }
            }
            
            self.setNotificationWatched(notification: notification)
          
            
            onProcessed(notification)
            
        case NOTI_ADDED_TO_GROUP:
            circlesManager.getGroupsUser(onSuccess: { needsReload in
                
                if CirclesGroupsModelManager.shared.userGroupWithId(id: notification.idGroup) != nil{
                    self.circlesManager.getGroupParticipants(id: notification.idGroup, onSuccess: { (hasChanges) in
                        let chatManager = ChatManager()
                        
                        if let group = CirclesGroupsModelManager.shared.groupWithId(id: notification.idGroup){
                            chatManager.getChatGroupMessages(fromGroup: group.idChat, onSuccess: { (hasMoreItems, needsReload) in
                                self.setNotificationWatched(notification: notification)
                                let notDict:[String: Any] = ["idGroup": notification.idGroup, "type": NOTI_ADDED_TO_GROUP]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                                onProcessed(notification)
                                
                            }) { (error) in
                                self.setNotificationWatched(notification: notification)
                                let notDict:[String: Any] = ["idGroup": notification.idGroup, "type": NOTI_ADDED_TO_GROUP]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                                onProcessed(notification)
                                
                            }
                        }
                        else{
                            self.setNotificationWatched(notification: notification)
                            let notDict:[String: Any] = ["idGroup": notification.idGroup, "type": NOTI_ADDED_TO_GROUP]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                            onProcessed(notification)
                            
                        }
                        
                        
                        
                        
                    }) { (error, status) in
                        self.setNotificationWatched(notification: notification)
                        onProcessed(notification)
                        
                    }

                }
                else{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                
            }, onError: { (error) in
                onProcessed(nil)

            })
            
        case NOTI_REMOVED_FROM_GROUP:
            if receivedNotification != nil{
                if receivedNotification == notification.id{
                    notificationManager.showLocalNotificationForRemovedFromGroup(id: notification.idGroup)
                }
            }
            
            if CirclesGroupsModelManager.shared.removeGroupItem(id: notification.idGroup){
                let notDict:[String: Any] = ["idGroup": notification.idGroup, "type": NOTI_REMOVED_FROM_GROUP]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
            }
            else{
                try! realm.write {
                    notification.removed = true
                }
            }
            
            self.setNotificationWatched(notification: notification)

            onProcessed(notification)

           
            
        case NOTI_USER_UPDATED:
            circlesManager.getUserBasicInfo(id: notification.idUser, onSuccess: { (user) in
                
                
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idUser": notification.idUser, "type": NOTI_USER_UPDATED]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
                
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }
                

            }
        case NOTI_NEW_USER_GROUP:
            circlesManager.getGroupParticipants(id: notification.idGroup, onSuccess: { (completed) in
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idGroup": notification.idGroup, "idUser": notification.idUser, "type": notification.type]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }

            }
        case  NOTI_REMOVED_USER_GROUP:
            self.setNotificationWatched(notification: notification)

            if CirclesGroupsModelManager.shared.removeUserFromGroup(idGroup: notification.idGroup, idUser: notification.idUser){
                let notDict:[String: Any] = ["idGroup": notification.idGroup, "idUser": notification.idUser, "type": notification.type]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)

            }
            else{
                try! realm.write {
                    notification.removed = true
                }
            }
            
            onProcessed(notification)
        case NOTI_GROUP_UPDATED:
            if CirclesGroupsModelManager.shared.userGroupWithId(id: notification.idGroup) != nil{
                circlesManager.updateGroup(id: notification.idGroup, onSuccess: {
                    
                    
                    self.setNotificationWatched(notification: notification)
                    let notDict:[String: Any] = ["idGroup": notification.idGroup, "type": NOTI_GROUP_UPDATED]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                    
                    onProcessed(notification)
                }) { (error, status) in
                    if status == 403 || status == 409{
                        try! realm.write {
                            notification.removed = true
                        }
                        self.setNotificationWatched(notification: notification)
                        onProcessed(notification)
                    }
                    else{
                        onProcessed(nil)
                    }

                    
                }
            }
            else{
                try! realm.write {
                    notification.removed = true
                }
                self.setNotificationWatched(notification: notification)
                onProcessed(notification)
            }
           
          
            
        case NOTI_MEETING_INVITATION_EVENT:
            
            agendaManager.getMeeting(meetingId: notification.idMeeting, onSuccess: {
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_MEETING_INVITATION_EVENT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }

            }
            
            break
        case NOTI_MEETING_ACCEPTED_EVENT:
            
            agendaManager.getMeeting(meetingId: notification.idMeeting, onSuccess: {
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_MEETING_ACCEPTED_EVENT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }

                
            }
            
            break
        case NOTI_MEETING_REJECTED_EVENT:
            
            agendaManager.getMeeting(meetingId: notification.idMeeting, onSuccess: {
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_MEETING_REJECTED_EVENT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }

                
            }
            
            break
        case NOTI_MEETING_CHANGED_EVENT:
            
            agendaManager.getMeeting(meetingId: notification.idMeeting, onSuccess: {
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_MEETING_CHANGED_EVENT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }

                
            }
            
        case NOTI_MEETING_INVITATION_REVOKE_EVENT:
            self.setNotificationWatched(notification: notification)

            if agendaModelManager.deleteMeeting(id: notification.idMeeting){
                let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_MEETING_INVITATION_REVOKE_EVENT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
            }
            else{
                try! realm.write {
                    notification.removed = true
                }
            }
            
                
            onProcessed(notification)
        case NOTI_MEETING_INVITATION_DELETED_EVENT:
            
            agendaManager.getMeeting(meetingId: notification.idMeeting, onSuccess: {
                self.setNotificationWatched(notification: notification)
                let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_MEETING_INVITATION_DELETED_EVENT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                
                onProcessed(notification)
            }) { (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }

                
            }
        case NOTI_MEETING_DELETED_EVENT:
            self.setNotificationWatched(notification: notification)

            if agendaModelManager.deleteMeeting(id: notification.idMeeting){
                let notDict:[String: Any] = ["idMeeting": notification.idMeeting, "type": NOTI_MEETING_DELETED_EVENT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
            }
            else{
                try! realm.write {
                    notification.removed = true
                }
            }

            onProcessed(notification)
        case NOTI_CONTENT_ADDED_TO_GALLERY:
            let realm = try! Realm()
            try! realm.write {
                notification.removed = true
            }
            
            let galleryManager = GalleryManager()

            galleryManager.getContentLibrary(id: notification.idGalleryContent, onSuccess: {
                self.setNotificationWatched(notification: notification)

                let notDict:[String: Any] = ["type": NOTI_NEW_PHOTO_CHAT]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
                onProcessed(notification)

            }, onError: {  (error, status) in
                if status == 403 || status == 409{
                    try! realm.write {
                        notification.removed = true
                    }
                    self.setNotificationWatched(notification: notification)
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }

            })

        case NOTI_TOKEN_EXPIRED:
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                let alertView = UIAlertController(title: L10n.logoutPopupTitle, message: L10n.logoutPopupTokenExpiration, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: L10n.ok, style: .default, handler: { (action) in
                    alertView.dismiss(animated: true, completion: nil)
                }))
                UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
            }
        default:
            let notDict:[String: Any] = ["type": NOTI_INCOMING_CALL]

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)

            self.setNotificationWatched(notification: notification)
          
            onProcessed(notification)
        }
    }
    
    func manageUnwatchedNotifications(receivedNotification: Int? = nil, onProcessed: @escaping (VincleNotification?) -> ()){
        if let notification = self.oldestUnprocessedNotification(){
            manageUnwatchedNotification(notification: notification, receivedNotification: receivedNotification) { (notification) in
                if notification != nil{
                    onProcessed(notification)
                }
                else{
                    onProcessed(nil)
                }
            }
        }
        else{
            onProcessed(nil)
        }
        
    }
    
    func markAllWatched(){
        let realm = try! Realm()
        
        let notifications = realm.objects(VincleNotification.self).filter("watched = %@", false)
        
        for not in notifications{
            try! realm.write {
                not.watched = true
            }
        }
    }
    
    func markNotificationRemoved(notification: VincleNotification){
        let realm = try! Realm()
        
        switch notification.type {
        case NOTI_NEW_MESSAGE:
            let chatModelManager = ChatModelManager()
            try! realm.write {
                notification.removed = true
            }
            let message = chatModelManager.messageWith(id: notification.idMessage)
            let userFromMain = message?.idUserFrom
            
            let nots = realm.objects(VincleNotification.self).sorted(by: { $0.creationTimeInt > $1.creationTimeInt })
            for not in nots{
                if not.type == NOTI_NEW_MESSAGE{
                    let message = chatModelManager.messageWith(id: not.idMessage)
                    let userFrom = message?.idUserFrom

                    if not.creationTimeInt < notification.creationTimeInt && userFromMain == userFrom{
                        try! realm.write {
                            not.removed = true
                        }
                    }
                }
               
            }
            
        default:
            try! realm.write {
        

                notification.removed = true
            }
            
        }
        
       
        
    }
    
    func getItems() -> [VincleNotification]{
        let realm = try! Realm()
        
        let nots = realm.objects(VincleNotification.self).sorted(by: { $0.creationTimeInt > $1.creationTimeInt })
        
        
        var items = [VincleNotification]()
        for not in nots{
            switch not.type {
            case NOTI_NEW_MESSAGE:
                if not.idMessage != -1{
                    let chatModelManager = ChatModelManager()
                    let message = chatModelManager.messageWith(id: not.idMessage)
                    let userFrom = message?.idUserFrom
                    var add = true
                    if let userFrom = userFrom{
                        let numberMessages = chatModelManager.numberOfUnwatchedMessages(circleId: userFrom)
                        
                        
                        if numberMessages == 0{
                            add = false
                            
                        }
                        
                        for item in items{
                            let messageItem = chatModelManager.messageWith(id: item.idMessage)
                            let userFromItem = messageItem?.idUserFrom
                            
                            
                            
                            if item.type == NOTI_NEW_MESSAGE && userFromItem == userFrom{
                                add = false
                            }
                        }
                        if add{
                            if !not.removed{
                                
                                items.append(not)
                            }
                        }
                    }
                   
              
                }
            case NOTI_NEW_CHAT_MESSAGE:
                var add = true

                if not.idChat != -1{
                    let chatModelManager = ChatModelManager()

                    let numberMessages = chatModelManager.numberOfUnwatchedGroupMessages(idChat: not.idChat)
                    
                    // DONE WATCHED
                    
                    if numberMessages == 0{
                        add = false
                        
                    }
                    
                
                    for item in items{
                        if item.type == NOTI_NEW_CHAT_MESSAGE && item.idChat == not.idChat{
                            add = false
                        }
                    }
                    if add{
                        if !not.removed{
                            
                            items.append(not)
                        }
                    }
                    
                }
            case NOTI_INCOMING_CALL:
                if !not.callStarted {
                    if !not.removed{
                        if (CirclesGroupsModelManager.shared.contactWithId(id: not.idUser) != nil){
                            items.append(not)
                        }else{
                            ApiClient.getUserBasicInfo(id: not.idUser, onSuccess: { (dict) in
                                CirclesGroupsModelManager.shared.addContact(dict: dict)
                                items.append(not)
                            }) { (err, code) in
                                
                            }
                            
                        }
                    }
                }
            case NOTI_NEW_USER_GROUP, NOTI_REMOVED_USER_GROUP, NOTI_USER_UPDATED, NOTI_GROUP_UPDATED, NOTI_MEETING_INVITATION_DELETED_EVENT, NOTI_MEETING_INVITATION_ADDED_EVENT, NOTI_CONTENT_ADDED_TO_GALLERY, NOTI_ERROR_IN_CALL:
                break
            case NOTI_MEETING_ACCEPTED_EVENT, NOTI_MEETING_REJECTED_EVENT:
                let profileModelManager = ProfileModelManager()
                let agendaModelManager = AgendaModelManager()
                if let meeting = agendaModelManager.meetingWithId(id: not.idMeeting){
                    if let host = meeting.hostInfo, host.id == profileModelManager.getUserMe()?.id{
                        if !not.removed{
                            items.append(not)
                        }
                    }
                }
                
               
                
            default:
                if !not.removed{
                    items.append(not)
                }
                
            }
        }
        return items
    }
    
    
    
    func numberOfUnwatchedMissedCall(circleId: Int) -> Int{
        let realm = try! Realm()
        
      
        let notifications = realm.objects(VincleNotification.self).filter("type == %@ && idUser == %i && watched == %@ && callStarted == %@", NOTI_INCOMING_CALL, circleId, false, false)
        return notifications.count
    }
    
    func lastCall(circleId: Int) -> Date?{
        let realm = try! Realm()
        if let notifications = realm.objects(VincleNotification.self).filter("type == %@ && idUser == %i", NOTI_INCOMING_CALL, circleId).sorted(by: { $0.creationTimeInt > $1.creationTimeInt }).first{
            return Date(timeIntervalSince1970: TimeInterval(notifications.creationTimeInt / 1000))
        }
        return nil
    }
    
}
