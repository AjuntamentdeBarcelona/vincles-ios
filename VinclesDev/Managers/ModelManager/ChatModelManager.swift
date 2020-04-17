//
//  ChatModelManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift
import SwiftyJSON

class ChatModelManager: NSObject {

    lazy var chatManager = ChatManager()
    
    func numberOfMessages(circleId: Int) -> Int{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{
            return circle.messages.count
        }
        
        return 0
    }
    
    func numberOfUnwatchedMessages(circleId: Int) -> Int{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{
            return circle.messages.filter("idUserFrom == %i && watched == %@", circleId, false).count
        }
        
        return 0
    }
    
    // DONE WATCHED
    func numberOfUnwatchedGroupMessages(idChat: Int) -> Int{
        let realm = try! Realm()
        return realm.objects(GroupMessage.self).filter("idChat == %i && watched == %@", idChat, false).count
    }
    
    // DONE WATCHED
    func numberOfGroupMessages(idChat: Int) -> Int{
        let realm = try! Realm()
        return realm.objects(GroupMessage.self).filter("idChat == %i", idChat).count
    }

    func groupMessages(idChat: Int) -> [GroupMessage]{
        let realm = try! Realm()
        var messages = [GroupMessage]()
        for message in realm.objects(GroupMessage.self).filter("idChat == %i", idChat){
            messages.append(message)
        }
        return messages
    }
    
    
    func buildItemsArray(circleId: Int) -> [Any]{
        var items = [Any]()
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{
            
            let notifications = realm.objects(VincleNotification.self).filter("type == %@ && idUser == %i && callStarted == %@", NOTI_INCOMING_CALL, circle.id, false)

            
            let messages = circle.messages.sorted(by: { $0.sendTime > $1.sendTime })
          
            var chatItems = [ChatItem]()
            
            for notification in notifications{
                let chatItem = ChatItem()
                chatItem.callNotification = notification.id
                chatItem.date = Date(timeIntervalSince1970: TimeInterval(notification.creationTimeInt / 1000))
                chatItems.append(chatItem)
            }
          
            for message in messages{
                let chatItem = ChatItem()
                chatItem.messageId = message.id
                chatItem.date = message.sendTime
                chatItems.append(chatItem)
            }
            
            chatItems = chatItems.sorted(by: { $0.date > $1.date })
            
            let lastUnreadMessage = circle.messages.filter("idUserFrom == %i && watched == %@", circleId, false).sorted(by: { $0.sendTime > $1.sendTime }).last

            
            for (index,chatItem) in chatItems.enumerated(){
                
                items.append(chatItem)

                if let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: chatItem.date)){
                    if chatItems.sorted(by: { $0.date > $1.date }).indices.contains(index + 1){
                        let nextDate = chatItems.sorted(by: { $0.date > $1.date })[index + 1].date
                        if !(date.isInSameDay(date: nextDate)) {
                            items.append(date)
                        }
                    }
                    else{
                        items.append(date)
                        
                    }
                  
                    if let message = chatItem.messageId{
                        if lastUnreadMessage != nil && message == lastUnreadMessage?.id{
                            items.append(L10n.chatNuevosMensajes)
                        }
                    }
                  
                }
               
            }
            
           
            
        }
        
        
        for (index,item) in items.enumerated(){
            if let chatItem = item as? ChatItem{
                if let message = chatItem.messageId{
                    items[index] = (message, "message")
                }
                if let notification = chatItem.callNotification{
                    items[index] = (notification, "notification")
                }
            }
        }
        return items
    }
    
    // DONE WATCHED
    func buildGroupItemsArray(idChat: Int) -> [Any]{
        var items = [Any]()
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            
            let messages = group.messages.sorted(by: { $0.sendTime > $1.sendTime })
            
            
            var chatItems = [ChatItem]()
            
            
            for message in messages{
                let chatItem = ChatItem()
                chatItem.groupMessageId = message.id
                chatItem.date = message.sendTime
                chatItems.append(chatItem)
            }
            
            chatItems = chatItems.sorted(by: { $0.date > $1.date })
            
            let lastUnreadMessage = group.messages.filter("watched == %@", false).sorted(by: { $0.sendTime > $1.sendTime }).last
            
            for (index,chatItem) in chatItems.enumerated(){
                
                items.append(chatItem)
                
                if let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: chatItem.date)){
                    if chatItems.sorted(by: { $0.date > $1.date }).indices.contains(index + 1){
                        let nextDate = chatItems.sorted(by: { $0.date > $1.date })[index + 1].date
                        if !(date.isInSameDay(date: nextDate)) {
                            items.append(date)
                        }
                    }
                    else{
                        items.append(date)
                        
                    }
                    
                    if let message = chatItem.groupMessageId{
                        if lastUnreadMessage != nil && message == lastUnreadMessage?.id{
                            items.append(L10n.chatNuevosMensajes)
                        }
                    }
                    
                }
                
            }
            
        }
        
        for (index,item) in items.enumerated(){
            if let chatItem = item as? ChatItem{
                if let message = chatItem.groupMessageId{
                    items[index] = (message, "groupMessage")
                }
                if let notification = chatItem.callNotification{
                    items[index] = notification
                }
            }
        }
        return items
    }
    
    // DONE WATCHED

    func buildDinamitzadorItemsArray(idChat: Int) -> [Any]{
        var items = [Any]()
        
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            
            let messages = realm.objects(GroupMessage.self).filter("idChat == %i", group.idDynamizerChat).sorted(by: { $0.sendTime > $1.sendTime })
            
            //  let messages = group.dynamizerMessages.sorted(by: { $0.sendTime > $1.sendTime })
            
            var chatItems = [ChatItem]()
            
            
            for message in messages{
                let chatItem = ChatItem()
                chatItem.groupMessageId = message.id
                chatItem.date = message.sendTime
                chatItems.append(chatItem)
            }
            
            chatItems = chatItems.sorted(by: { $0.date > $1.date })
            
            let lastUnreadMessage = realm.objects(GroupMessage.self).filter("idChat == %i && watched == %@", group.idDynamizerChat, false).sorted(by: { $0.sendTime > $1.sendTime }).last
            
            for (index,chatItem) in chatItems.enumerated(){
                
                items.append(chatItem)
                
                if let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: chatItem.date)){
                    if chatItems.sorted(by: { $0.date > $1.date }).indices.contains(index + 1){
                        let nextDate = chatItems.sorted(by: { $0.date > $1.date })[index + 1].date
                        if !(date.isInSameDay(date: nextDate)) {
                            items.append(date)
                        }
                    }
                    else{
                        items.append(date)
                        
                    }
                    
                    if let message = chatItem.groupMessageId{
                        if lastUnreadMessage != nil && message == lastUnreadMessage?.id{
                            items.append(L10n.chatNuevosMensajes)
                        }
                    }
                    
                }
                
            }
            
        }
        
        for (index,item) in items.enumerated(){
            if let chatItem = item as? ChatItem{
                if let message = chatItem.groupMessageId{
                    items[index] = (message, "groupMessage")
                }
                if let notification = chatItem.callNotification{
                    items[index] = (notification, "notification")
                }
            }
        }
        return items
    }
    
    func markAllMessageWatched(circleId: Int){
        
        do {
            let realm = try! Realm()
            if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{
                var ids = [Int]()
                let messages = circle.messages.filter("idUserFrom == %i && watched == %@", circleId, false)
                for message in messages{
                    ids.append(message.id)
                    do {
                        try realm.write {
                            message.watched = true
                        }
                    } catch {
                        print("Could not delete object.\n\(String(describing: error.localizedDescription))")
                        
                    }
                }
                for id in ids{
                   
                    
                    
                    chatManager.markMessage(idMessage: id, onSuccess: { (result) in
                        
                    }) { (error) in
                        
                    }
                }
                
            }
            
            
        } catch {
            print("Could not delete object.\n\(String(describing: error.localizedDescription))")
            
        }
        
      
    }
    
    // DONE WATCHED
    func markAllGroupMessageWatched(idChat: Int){
        

            let realm = try! Realm()
            let messages = realm.objects(GroupMessage.self).filter("idChat == %i", idChat)
            for message in messages{
                do {
                    try realm.write {
                        message.watched = true
                    }
                } catch {
                    print("Could not delete object.\n\(String(describing: error.localizedDescription))")
                    
                }
            }

            // PUT LAST ACCESS
        UserDefaults.standard.set(Int64(Date().timeIntervalSince1970) * 1000, forKey: "\(idChat)")
        ApiClient.putChatLastAccess(params: ["idChat": idChat, "lastAccess": Int64(Date().timeIntervalSince1970) * 1000], onSuccess: { () in
            
        }) { (error) in
            
        }
        
    }
    

    func messageAt(index: Int, circleId: Int) -> Message?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{
            return circle.messages.sorted(by: { $0.sendTime > $1.sendTime })[index]
        }
        
        return nil
    }
    
    func messageWith(id: Int) -> Message?{
        let realm = try! Realm()
        return realm.objects(Message.self).filter("id == %i", id).first
    }
    
    func groupMessageWith(id: Int, idChat: Int) -> GroupMessage?{
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            return group.messages.filter("id == %i", id).first
            
        }
        return nil
    }
    
    func groupMessageWith(id: Int) -> GroupMessage?{
        let realm = try! Realm()
        return realm.objects(GroupMessage.self).filter("id == %i", id).first
    }
    
    func dinamitzadorMessageWith(id: Int, idChat: Int) -> GroupMessage?{
        let realm = try! Realm()
        return realm.objects(GroupMessage.self).filter("id == %i", id).first
    }
    
    
    func oldestMessageDate(circleId: Int) -> Date?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{
            
            return circle.messages.sorted(by: { $0.sendTime < $1.sendTime }).first?.sendTime
            
        }
        
        return nil
        
    }
    
    func newestMessageDate(circleId: Int) -> Date?{
        let realm = try! Realm()

        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{

            return circle.messages.sorted(by: { $0.sendTime > $1.sendTime }).first?.sendTime

        }
        
        return nil
        
    }
    
    func addMessages(circleId: Int, array: [[String:Any]]) -> (Date?, Bool){
        let realm = try! Realm()
        var lastItemDate: Date?
        var firstItemDate: Date?
        
        var changes = false
        

        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{

            
            var ids = [Int]()
            
            for (index,dict) in array.enumerated(){
                let message = Message(json: JSON(dict))
                ids.append(message.id)
                if index == 0{
                    firstItemDate = message.sendTime
                }
                if index == array.count - 1{
                    lastItemDate = message.sendTime
                }
                
                if circle.messages.filter("id == %i", message.id).count == 0{
                    changes = true
                    try! realm.write {
                        realm.add(message, update: true)
                        
                        if circle.messages.index(of: message) == nil{
                            circle.messages.append(message)
                        }
                        
                    }
                    
                   
                }
            }
            
            if let firstDate = firstItemDate, let lastDate = lastItemDate{
                if(self.removeUnexistingContentItems(from: lastDate, to: firstDate, apiItems: ids, circleId: circleId)){
                    changes = true
                }
            }
            
        }
        return (lastItemDate,changes)
    }
    
    func addMessage(dict: [String:AnyObject]) -> Message{
        let realm = try! Realm()

        let message = Message(json: JSON(dict))
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", message.idUserFrom).first{

            if circle.messages.filter("id == %i", message.id).count == 0{
                try! realm.write {
                    realm.add(message, update: true)
                    
                    if circle.messages.index(of: message) == nil{
                        circle.messages.append(message)
                    }
                    
                }
                
            }
        }
        else if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", message.idUserTo).first{
            
            if circle.messages.filter("id == %i", message.id).count == 0{
                try! realm.write {
                    realm.add(message, update: true)
                    
                    if circle.messages.index(of: message) == nil{
                        circle.messages.append(message)
                    }
                    
                }
                
            }
        }
        
        return message
    }
    
    func removeUnexistingContentItems(from: Date, to: Date, apiItems: [Int], circleId: Int) -> Bool{
        var changes = false
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let circle = user.circles.filter("id == %i", circleId).first{
            if apiItems.count == 10{
                
                let messages = circle.messages.filter("sendTime <= %@ && sendTime >= %@", to, from)

                for message in messages{
                    var remove = true
                    for id in apiItems{
                        if message.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        try! realm.write {
                            circle.messages.remove(at: circle.messages.index(of: message)!)
                            realm.delete(message)
                            
                        }
                        
                    }
                }
            }
            else{
                

                let messages = circle.messages.filter("sendTime <= %@", to)

                for message in messages{
                    var remove = true
                    for id in apiItems{
                        if message.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        try! realm.write {
                            circle.messages.remove(at: circle.messages.index(of: message)!)
                            realm.delete(message)
                            
                        }
                        
                    }
                }
            }
            
        }
        
        return changes
        
    }
    
    func addGroupMessages(chatId: Int, array: [[String:Any]]) -> (Date?, Bool){
        let realm = try! Realm()
        var lastItemDate: Date?
        var firstItemDate: Date?
        
        var changes = false
        
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", chatId).first{
            
            
            var ids = [Int]()
            
            for (index,dict) in array.enumerated(){
                let message = GroupMessage(json: JSON(dict))
                ids.append(message.id)
                if index == 0{
                    firstItemDate = message.sendTime
                }
                if index == array.count - 1{
                    lastItemDate = message.sendTime
                }
                
                if group.messages.filter("id == %i", message.id).count == 0{
                    changes = true
                    try! realm.write {
                        realm.add(message, update: true)
                        
                        if group.messages.index(of: message) == nil{
                            group.messages.append(message)
                        }
                        
                    }
                    
                    
                }
            }
            
            if let firstDate = firstItemDate, let lastDate = lastItemDate{
                //   if(self.removeUnexistingGroupContentItems(from: lastDate, to: firstDate, apiItems: ids, idChat: chatId)){
                    changes = true
              //     }
            }
            
        }
        return (lastItemDate,changes)
    }
    
    func oldestGroupMessageDate(idChat: Int) -> Date?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            
            return group.messages.sorted(by: { $0.sendTime < $1.sendTime }).first?.sendTime
            
        }
        
        return nil
        
    }
    
    func newestGroupMessageDate(idChat: Int) -> Date?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{

            return group.messages.sorted(by: { $0.sendTime > $1.sendTime }).first?.sendTime

        }
        
        return nil
        
    }
    
    func addGroupMessage(dict: [String:AnyObject]) -> GroupMessage{
        let realm = try! Realm()
        
        let message = GroupMessage(json: JSON(dict))
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", message.idChat).first{
            
            if group.messages.filter("id == %i", message.id).count == 0{
                try! realm.write {
                    realm.add(message, update: true)
                    
                    if group.messages.index(of: message) == nil{
                        group.messages.append(message)
                    }
                    
                }
                
            }
        }
       
        return message
    }
    


    func removeUnexistingGroupContentItems(from: Date, to: Date, apiItems: [Int], idChat: Int) -> Bool{
        var changes = false
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            if apiItems.count == 10{

                let messages = group.messages.filter("sendTime <= %@ && sendTime >= %@", to, from)

                for message in messages{
                    var remove = true
                    for id in apiItems{
                        if message.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        try! realm.write {
                            group.messages.remove(at: group.messages.index(of: message)!)
                            realm.delete(message)
                            
                        }
                        
                    }
                }
            }
            else{
                
                
                let messages = group.messages.filter("sendTime <= %@", to)
                
                for message in messages{
                    var remove = true

                    for id in apiItems{
                        if message.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        try! realm.write {
                            group.messages.remove(at: group.messages.index(of: message)!)
                            realm.delete(message)
                            
                        }
                        
                    }
                }
            }
            
        }
        
        return changes
        
    }
    
    
    
    func addDinamitzadorMessages(chatId: Int, array: [[String:Any]]) -> (Date?, Bool){
        let realm = try! Realm()
        var lastItemDate: Date?
        var firstItemDate: Date?
        
        var changes = false
        
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", chatId).first{
            
            
            var ids = [Int]()
            
            for (index,dict) in array.enumerated(){
                let message = GroupMessage(json: JSON(dict))
                ids.append(message.id)
                if index == 0{
                    firstItemDate = message.sendTime
                }
                if index == array.count - 1{
                    lastItemDate = message.sendTime
                }
                
                if group.dynamizerMessages.filter("id == %i", message.id).count == 0{
                    changes = true
                    try! realm.write {
                        realm.add(message, update: true)
                        
                        if group.dynamizerMessages.index(of: message) == nil{
                            group.dynamizerMessages.append(message)
                        }
                        
                    }
                    
                    
                }
            }
            
            if let firstDate = firstItemDate, let lastDate = lastItemDate{
             //   if(self.removeUnexistingGroupContentItems(from: lastDate, to: firstDate, apiItems: ids, idChat: chatId)){
                    changes = true
               //    }
            }
            
        }
        return (lastItemDate,changes)
    }
    
    func removeUnexistingDinamitzadorContentItems(from: Date, to: Date, apiItems: [Int], idChat: Int) -> Bool{
        var changes = false
        let realm = try! Realm()
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            if apiItems.count == 10{
                
                let messages = group.dynamizerMessages.filter("sendTime <= %@ && sendTime >= %@", to, from)
                
                for message in messages{
                    var remove = true
                    for id in apiItems{
                        if message.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        try! realm.write {
                            group.dynamizerMessages.remove(at: group.dynamizerMessages.index(of: message)!)
                            realm.delete(message)
                            
                        }
                        
                    }
                }
            }
            else{
                
                
                let messages = group.dynamizerMessages.filter("sendTime <= %@", to)
                
                for message in messages{
                    var remove = true
                    for id in apiItems{
                        if message.id == id{
                            remove = false
                        }
                    }
                    if remove{
                        changes = true
                        try! realm.write {
                            group.dynamizerMessages.remove(at: group.dynamizerMessages.index(of: message)!)
                            realm.delete(message)
                            
                        }
                        
                    }
                }
            }
            
        }
        
        return changes
        
    }
    
    func addDinamitzadorMessage(dict: [String:AnyObject]) -> GroupMessage{
        let realm = try! Realm()
        
        let message = GroupMessage(json: JSON(dict))
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idDynamizerChat == %i", message.idChat).first{
            
            if group.dynamizerMessages.filter("id == %i", message.id).count == 0{
                try! realm.write {
                    realm.add(message, update: true)
                    
                    if group.dynamizerMessages.index(of: message) == nil{
                        group.dynamizerMessages.append(message)
                    }
                    
                }
                
            }
        }
        
        return message
    }
    
    
    
    func oldestDinamitzadorMessageDate(idChat: Int) -> Date?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            
            return group.dynamizerMessages.sorted(by: { $0.sendTime < $1.sendTime }).first?.sendTime
            
        }
        
        return nil
        
    }
    
    func newestDinamitzadorMessageDate(idChat: Int) -> Date?{
        let realm = try! Realm()
        
        if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first, let group = user.groups.filter("idChat == %i", idChat).first{
            
            return group.dynamizerMessages.sorted(by: { $0.sendTime > $1.sendTime }).first?.sendTime
            
        }
        
        return nil
        
    }
    
}
