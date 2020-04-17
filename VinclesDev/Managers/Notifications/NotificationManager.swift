//
//  NotificationManager.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import Foundation
import SwiftyJSON
import EventKit
import CoreData
import UserNotifications
import SlideMenuControllerSwift

class NotificationManager: NSObject, URLSessionDelegate {
    lazy var notificationsModelManager = NotificationsModelManager()
    lazy var chatModelManager = ChatModelManager()
    lazy var circlesGroupsModelManager = CirclesGroupsModelManager.shared
    lazy var agendaModelManager = AgendaModelManager()
    
    func getNotification(id: Int, onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        
        let params = ["id_push": id] as [String : Any]
        
        ApiClient.getNotificationById(params: params, onSuccess: {result in
            onSuccess(true)
        }) { (error) in
            onError(error)
            
        }
    }
    
    func processUnwatchedNotifications(receivedNotification: Int? = nil){
        self.notificationsModelManager.manageUnwatchedNotifications(receivedNotification: receivedNotification) { notification in
            
            if notification != nil{
                self.processUnwatchedNotifications(receivedNotification: receivedNotification)
                
                if notification!.id == receivedNotification{
                    
                    switch notification!.type {
                    case NOTI_NEW_MESSAGE:
                        if let message = self.chatModelManager.messageWith(id: notification!.idMessage), let userFrom = self.circlesGroupsModelManager.contactWithId(id: message.idUserFrom)?.id{
                            if UIApplication.shared.applicationState == .active{
                                var showPush = true
                                if let slideMenuController = UIApplication.shared.keyWindow?.rootViewController as? SlideMenuController, let nav = slideMenuController.mainViewController as? UINavigationController{
                                    if let baseVC = nav.viewControllers.last as? BaseViewController, let chatVC = baseVC.containedViewController as? ChatContainerViewController, chatVC.toUserId == userFrom{
                                        showPush = false
                                    }
                                }
                                if showPush{
                                    self.showLocalNotificationForMessage(id: notification!.idMessage)
                                }
                            }
                            else{
                                self.showLocalNotificationForMessage(id: notification!.idMessage)
                            }
                        }
                        
                    case NOTI_NEW_CHAT_MESSAGE:
                        let circlesModelManager = CirclesGroupsModelManager.shared
                        if circlesModelManager.groupWithChatId(idChat: notification!.idChat) != nil{
                            if self.chatModelManager.groupMessageWith(id: notification!.idChatMessage, idChat: notification!.idChat) != nil{
                                if UIApplication.shared.applicationState == .active{
                                    var showPush = true
                                    if let slideMenuController = UIApplication.shared.keyWindow?.rootViewController as? SlideMenuController, let nav = slideMenuController.mainViewController as? UINavigationController{
                                        if let baseVC = nav.viewControllers.last as? BaseViewController, let chatVC = baseVC.containedViewController as? ChatContainerViewController{
                                            if !chatVC.isDinam{
                                                if chatVC.group != nil{
                                                    if chatVC.group?.idChat == notification!.idChat{
                                                        showPush = false
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                    if showPush{
                                        self.showLocalNotificationForGroupMessage(id: notification!.idChatMessage, idChat: notification!.idChat)
                                    }
                                }
                                else{
                                    self.showLocalNotificationForGroupMessage(id: notification!.idChatMessage, idChat: notification!.idChat)
                                }
                            }
                        }
                        else if circlesModelManager.dinamitzadorWithChatId(idChat: notification!.idChat) != nil{
                            
                            if self.chatModelManager.dinamitzadorMessageWith(id: notification!.idChatMessage, idChat: notification!.idChat) != nil{
                                if UIApplication.shared.applicationState == .active{
                                    var showPush = true
                                    if let slideMenuController = UIApplication.shared.keyWindow?.rootViewController as? SlideMenuController, let nav = slideMenuController.mainViewController as? UINavigationController{
                                        if let baseVC = nav.viewControllers.last as? BaseViewController, let chatVC = baseVC.containedViewController as? ChatContainerViewController{
                                            if chatVC.isDinam{
                                                if chatVC.group != nil{
                                                    if chatVC.group?.idChat == notification!.idChat{
                                                        showPush = false
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                    if showPush{
                                        self.showLocalNotificationForDinam(id: notification!.idChatMessage, idChat: notification!.idChat)
                                    }
                                }
                                else{
                                    self.showLocalNotificationForDinam(id: notification!.idChatMessage, idChat: notification!.idChat)
                                }
                            }
                        }
                        
                    case NOTI_USER_LINKED:
                        if self.circlesGroupsModelManager.contactWithId(id: notification!.idUser) != nil{
                            self.showLocalNotificationForNewUser(id: notification!.idUser)
                        }
                        
                    case NOTI_USER_UNLINKED, NOTI_USER_LEFT_CIRCLE:
                        break
                    case NOTI_ADDED_TO_GROUP:
                        if self.circlesGroupsModelManager.userGroupWithId(id: notification!.idGroup) != nil{
                            self.showLocalNotificationForNewGroup(id: notification!.idGroup)
                        }
                    case NOTI_REMOVED_FROM_GROUP:
                        break
                    case NOTI_USER_UPDATED:
                        break
                    case NOTI_REMOVED_USER_GROUP, NOTI_NEW_USER_GROUP:
                        break
                    case NOTI_GROUP_UPDATED:
                        break
                    case NOTI_MEETING_INVITATION_EVENT:
                        if let meeting = self.agendaModelManager.meetingWithId(id: notification!.idMeeting){
                            self.showLocalNotificationForMeetingInvitation(meeting: meeting)
                        }
                    case NOTI_MEETING_ACCEPTED_EVENT:
                        if let meeting = self.agendaModelManager.meetingWithId(id: notification!.idMeeting){
                            let profileModelManager = ProfileModelManager()
                            if let host = meeting.hostInfo, host.id == profileModelManager.getUserMe()?.id{
                                self.showLocalNotificationForMeetingAccepted(meeting: meeting, user: notification!.idUser)
                            }
                        }
                    case NOTI_MEETING_REJECTED_EVENT:
                        if let meeting = self.agendaModelManager.meetingWithId(id: notification!.idMeeting){
                            let profileModelManager = ProfileModelManager()
                            if let host = meeting.hostInfo, host.id == profileModelManager.getUserMe()?.id{
                                self.showLocalNotificationForMeetingRejected(meeting: meeting, user: notification!.idUser)
                            }
                        }
                    case NOTI_MEETING_CHANGED_EVENT:
                        if let meeting = self.agendaModelManager.meetingWithId(id: notification!.idMeeting){
                            self.showLocalNotificationForMeetingChanged(meeting: meeting)
                        }
                    case NOTI_MEETING_INVITATION_REVOKE_EVENT:
                        if let meeting = self.agendaModelManager.meetingWithId(id: notification!.idMeeting){
                            self.showLocalNotificationForInvitationRevoked(meeting: meeting)

                        }
                    case NOTI_MEETING_DELETED_EVENT:
                        if let meeting = self.agendaModelManager.meetingWithId(id: notification!.idMeeting){
                            self.showLocalNotificationForDeletedEvent(meeting: meeting)
                            
                        }
                        
                    case NOTI_GROUP_USER_INVITATION_CIRCLE:
                        if let group = self.circlesGroupsModelManager.groupWithId(id: notification!.idGroup), let user = group.users.filter("id == %i", notification!.idHost).first{
                            self.showLocalNotificationForUserInvitation(user: user, code: notification!.code)
                        }
                       
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func showLocalNotificationForUserInvitation(user: User, code: String){
        let content = UNMutableNotificationContent()
        content.title = "Vincles BCN"
        content.body = L10n.notificacioUserInvitation(user.name, code)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NOTI_GROUP_USER_INVITATION_CIRCLE
        let request = UNNotificationRequest(identifier: "\(code)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func showLocalNotificationForMissedCall(user: Int, room: String){
       
        let circlesManager = CirclesGroupsModelManager.shared
       
        let content = UNMutableNotificationContent()
        content.title = "Vincles BCN"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NOTI_INCOMING_CALL

        if let userObj = circlesManager.contactWithId(id: user){

            content.body = "\(L10n.lostCall) \(userObj.name)"
            let request = UNNotificationRequest(identifier: "\(user)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        }else if let userObj = circlesManager.dinamitzadorWithId(id: user){
            
            content.body = "\(L10n.lostCall) \(userObj.name)"
            let request = UNNotificationRequest(identifier: "\(user)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        let notDict:[String: Any] = [ "type": NOTI_INCOMING_CALL]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
        CallKitManager.endCall()

    }
    
    func showLocalNotificationForNewCall(user: Int, room: String){
     
        let state = UIApplication.shared.applicationState
        
        let circlesManager = CirclesGroupsModelManager.shared
        if state == .background {
            
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "silence.mp3"))
            content.categoryIdentifier = NOTI_INCOMING_CALL
            
            if let userObj = circlesManager.contactWithId(id: user){
                content.body = "\(L10n.callFrom) \(userObj.name)"
                let request = UNNotificationRequest(identifier: "\(user)", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
            else if let userObj = circlesManager.dinamitzadorWithId(id: user){
                content.body = "\(L10n.callFrom) \(userObj.name)"
                let request = UNNotificationRequest(identifier: "\(user)", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }

        }
        let notDict:[String: Any] = [ "type": NOTI_INCOMING_CALL]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_PROCESSED), object: nil, userInfo: notDict)
       
    }
    
    func showLocalNotificationForDeletedEvent(meeting: Meeting){
        if let name = meeting.hostInfo?.name{
            
            
            let lang = UserDefaults.standard.string(forKey: "i18n_language")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: lang!)
            
            let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateStyle = .long
            dateFormatterGet.timeStyle = .none
            dateFormatterGet.locale = Locale.current
            
            if(lang == "es"){
                dateFormatterGet.locale = Locale(identifier: "es")
            }else{
                dateFormatterGet.locale = Locale(identifier: "ca")
                
            }
            
            
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioInvitationRevokedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
            
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_MEETING_DELETED_EVENT
            
            let request = UNNotificationRequest(identifier: "\(meeting.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func showLocalNotificationForInvitationRevoked(meeting: Meeting){
        if let name = meeting.hostInfo?.name{
            
            
            let lang = UserDefaults.standard.string(forKey: "i18n_language")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: lang!)
            
            let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateStyle = .long
            dateFormatterGet.timeStyle = .none
            dateFormatterGet.locale = Locale.current
            
            if(lang == "es"){
                dateFormatterGet.locale = Locale(identifier: "es")
            }else{
                dateFormatterGet.locale = Locale(identifier: "ca")
                
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioInvitationRevokedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
            
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_MEETING_INVITATION_REVOKE_EVENT
            let request = UNNotificationRequest(identifier: "\(meeting.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func showLocalNotificationForMeetingAccepted(meeting: Meeting, user: Int){
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: lang!)
        
        let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateStyle = .long
        dateFormatterGet.timeStyle = .none
        dateFormatterGet.locale = Locale.current
        
        if(lang == "es"){
            dateFormatterGet.locale = Locale(identifier: "es")
        }else{
            dateFormatterGet.locale = Locale(identifier: "ca")
            
        }
        
        var name = ""
        for guest in meeting.guests{
            if guest.userInfo?.id == user{
                if let firstName = guest.userInfo?.name, let lastName = guest.userInfo?.lastname{
                    name = firstName + " " + lastName

                }
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Vincles BCN"
        content.body = L10n.notificacioIAcceptedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
        
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NOTI_MEETING_ACCEPTED_EVENT
        let request = UNNotificationRequest(identifier: "\(meeting.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    
    func showLocalNotificationForMeetingRejected(meeting: Meeting, user: Int){
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: lang!)
        
        let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateStyle = .long
        dateFormatterGet.timeStyle = .none
        dateFormatterGet.locale = Locale.current
        
        if(lang == "es"){
            dateFormatterGet.locale = Locale(identifier: "es")
        }else{
            dateFormatterGet.locale = Locale(identifier: "ca")
            
        }
        
        var name = ""
        for guest in meeting.guests{
            if guest.userInfo?.id == user{
                if let firstName = guest.userInfo?.name, let lastName = guest.userInfo?.lastname{
                    name = firstName + " " + lastName
                    
                }
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Vincles BCN"
        content.body = L10n.notificacioIDeclinedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
        
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NOTI_MEETING_ACCEPTED_EVENT
        let request = UNNotificationRequest(identifier: "\(meeting.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func showLocalNotificationForMeetingInvitation(meeting: Meeting){
        if let name = meeting.hostInfo?.name{
            
            
            let lang = UserDefaults.standard.string(forKey: "i18n_language")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: lang!)
            
            let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateStyle = .long
            dateFormatterGet.timeStyle = .none
            dateFormatterGet.locale = Locale.current
            
            if(lang == "es"){
                dateFormatterGet.locale = Locale(identifier: "es")
            }else{
                dateFormatterGet.locale = Locale(identifier: "ca")
                
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioInvitedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
            
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_MEETING_INVITATION_EVENT
            let request = UNNotificationRequest(identifier: "\(meeting.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func showLocalNotificationForMeetingChanged(meeting: Meeting){
        if let name = meeting.hostInfo?.name{
            let lang = UserDefaults.standard.string(forKey: "i18n_language")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: lang!)
            
            let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateStyle = .long
            dateFormatterGet.timeStyle = .none
            dateFormatterGet.locale = Locale.current
            
            if(lang == "es"){
                dateFormatterGet.locale = Locale(identifier: "es")
            }
            else{
                dateFormatterGet.locale = Locale(identifier: "ca")
                
            }
            
            
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioChangedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
            
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_MEETING_INVITATION_EVENT
            let request = UNNotificationRequest(identifier: "\(meeting.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    
    func showLocalNotificationForRemoveUser(id: Int){
        if let user = self.circlesGroupsModelManager.contactWithId(id: id){
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioUserUnlinked(user.name)
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_USER_UNLINKED
            let request = UNNotificationRequest(identifier: "\(user.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    
    func showLocalNotificationForNewUser(id: Int){
        if let user = self.circlesGroupsModelManager.contactWithId(id: id){
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioUserLinked(user.name)
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_USER_LINKED
            let request = UNNotificationRequest(identifier: "\(user.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func showLocalNotificationForDinam(id: Int, idChat: Int){
        var message: GroupMessage?
        
        
        if let groupMessage = self.chatModelManager.groupMessageWith(id: id, idChat: idChat){
            message = groupMessage
        }
        else if let dinamMessage = self.chatModelManager.dinamitzadorMessageWith(id: id, idChat: idChat){
            message = dinamMessage
        }
        
        let circlesModelManager = CirclesGroupsModelManager.shared
        
        if let group = circlesModelManager.dinamitzadorWithChatId(idChat: idChat){
            if let message = message{
                let content = UNMutableNotificationContent()
                if let dinam = group.dynamizer{
                    content.title = "\(dinam.name)"
                    if message.text.count > 0{
                        content.body = message.text
                    }
                    else if message.metadataTipus.contains("IMAGE"){
                        content.body = L10n.notificacioNovaImage
                    }
                    else if message.metadataTipus.contains("VIDEO"){
                        content.body = L10n.notificacioNouVideo
                    }
                    else if message.metadataTipus.contains("AUDIO"){
                        content.body = L10n.notificacioNouAudio
                    }
                    
                    content.sound = UNNotificationSound.default
                    content.categoryIdentifier = NOTI_NEW_CHAT_MESSAGE
                    let request = UNNotificationRequest(identifier: "\(message.idChat)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
                
            }
        }
    }
    
    func showLocalNotificationForGroupMessage(id: Int, idChat: Int){
        var message: GroupMessage?
        if let groupMessage = self.chatModelManager.groupMessageWith(id: id, idChat: idChat){
            message = groupMessage
        }
        else if let dinamMessage = self.chatModelManager.dinamitzadorMessageWith(id: id, idChat: idChat){
            message = dinamMessage
        }
        
        let circlesModelManager = CirclesGroupsModelManager.shared
        
        if let group = circlesModelManager.groupWithChatId(idChat: idChat){
            if let message = message{
                let content = UNMutableNotificationContent()
                content.title = "\(group.name) - \(message.fullNameUserSender)"
                if message.text.count > 0{
                    content.body = message.text
                }
                else if message.metadataTipus.contains("IMAGE"){
                    content.body = L10n.notificacioNovaImage
                }
                else if message.metadataTipus.contains("VIDEO"){
                    content.body = L10n.notificacioNouVideo
                }
                else if message.metadataTipus.contains("AUDIO"){
                    content.body = L10n.notificacioNouAudio
                }
                
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = NOTI_NEW_CHAT_MESSAGE
                let request = UNNotificationRequest(identifier: "\(message.idChat)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
        
    }
    
    func showLocalNotificationForMessage(id: Int){
        if let message = chatModelManager.messageWith(id: id), let userFrom = circlesGroupsModelManager.contactWithId(id: message.idUserFrom){
            let content = UNMutableNotificationContent()
            content.title = userFrom.name

            if message.messageText.count > 0{
                content.body = message.messageText
            }
            else if message.metadataTipus.contains("IMAGE"){
                content.body = L10n.notificacioNovaImage
            }
            else if message.metadataTipus.contains("VIDEO"){
                content.body = L10n.notificacioNouVideo
            }
            else if message.metadataTipus.contains("AUDIO"){
                content.body = L10n.notificacioNouAudio
            }
            else if message.metadataTipus.contains("MULTI"){
                content.body = L10n.notificacioNouMulti
            }
            
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_NEW_MESSAGE
            let diceRoll = Int(arc4random_uniform(99999999) + 1)

            let request = UNNotificationRequest(identifier: "\(message.idUserFrom)_\(Date().timeIntervalSince1970)\(diceRoll)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
    }
    
    
    func showLocalNotificationForNewGroup(id: Int){
        if let group = self.circlesGroupsModelManager.groupWithId(id: id){
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioNouGrup(group.name)
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_ADDED_TO_GROUP
            let request = UNNotificationRequest(identifier: "\(group.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
       
        }
        
    }
    
    func showLocalNotificationForRemovedFromGroup(id: Int){
        if let group = self.circlesGroupsModelManager.groupWithId(id: id){
            let content = UNMutableNotificationContent()
            content.title = "Vincles BCN"
            content.body = L10n.notificacioEliminatGrup(group.name)
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = NOTI_REMOVED_FROM_GROUP
            let request = UNNotificationRequest(identifier: "\(group.id)_\(Date().timeIntervalSince1970)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
    }
    
    func setWatchedNotifications(){
        self.notificationsModelManager.setAllNotificationsWatched()
    }
    
   
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.previousFailureCount == 0 else {
            challenge.sender?.cancel(challenge)
            // Inform the user that the user name and password are incorrect
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Within your authentication handler delegate method, you should check to see if the challenge protection space has an authentication type of NSURLAuthenticationMethodServerTrust
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
            // and if so, obtain the serverTrust information from that protection space.
            && challenge.protectionSpace.serverTrust != nil
            && challenge.protectionSpace.host == IP {
            let proposedCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, proposedCredential)
        }
    }
    
    func getNotifications(onSuccess: @escaping (Bool) -> (), onError: @escaping (String) -> ()) {
        
        var newestProcessedNotificationDate: Int64 = -1
        
        if let last = notificationsModelManager.newestProcessedNotificationDate(){
            newestProcessedNotificationDate = last
        }
        else if let lastDefaults = UserDefaults.standard.value(forKey: "loginTime") as? Int64{
            newestProcessedNotificationDate = lastDefaults
        }
        
        var to: Int64? = nil
        
        if let oldestUnprocessedNotificationDate = notificationsModelManager.oldestUnprocessedNotificationDate(){
            to = oldestUnprocessedNotificationDate
        }
        
        ApiClient.getNotifications(from: newestProcessedNotificationDate + 1, to: to, onSuccess: { (array) in
            
            self.notificationsModelManager.addNotifications(array: array)
            
            if array.count == 10{
                onSuccess(true)
            }
            else{
                onSuccess(false)
            }
            
        }) { (error) in
            onError(error)
            
        }
    }
    
    
    func getNotifications(receivedNotification: Int?){
        
        self.getNotifications( onSuccess: { (hasMoreItems) in
            if hasMoreItems{
                self.getNotifications(receivedNotification: receivedNotification)
            }
            else{
                self.processUnwatchedNotifications(receivedNotification: receivedNotification)
            }
        }) { (error) in
            
        }
    }
    
    
    func processNotification(noti: String?) {
        
        guard let notification = noti else{
            return
        }
        
        if let notificationDict = JSON(parseJSON: notification).dictionaryObject{
            
            if let idPush = notificationDict["id_push"] as? Int {
                
                getNotifications(receivedNotification: idPush)
                
            }
           
        }
        
        
    }
    
    func deleteLocalNotifications(){
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

       
    }
    
}
