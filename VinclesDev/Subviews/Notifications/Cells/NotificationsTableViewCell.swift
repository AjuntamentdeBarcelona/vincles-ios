//
//  NotificationsTableViewCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol NotificationsTableViewCellDelegate{
    
}

class NotificationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eliminarButton: UIButton!
    @IBOutlet weak var actionButton: HoverButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var userImage: CircularImageView!
    var delegate: NotificationsTableViewCellDelegate?

    var notification: VincleNotification!
    var userId = -1
    var groupId = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        eliminarButton.semanticContentAttribute = .forceRightToLeft
        if UIDevice.current.userInterfaceIdiom == .phone
        {
           eliminarButton.setTitle("", for: .normal)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configWithNotification(notification: VincleNotification){
        self.notification = notification
        userImage.image = UIImage()
        contentLabel.text = ""
        actionButton.setTitle("", for: .normal)

        if notification.watched{
            self.backgroundColor = UIColor(named: .clearGrayChat)
        }
        else{
            self.backgroundColor = UIColor(named: .clearPink)
        }
        
        let dateFormatter = DateFormatter()
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        if(lang == "es"){
            dateFormatter.locale = Locale(identifier: "es")
        }
        else{
            dateFormatter.locale = Locale(identifier: "ca")
        }
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        let date = Date(timeIntervalSince1970: TimeInterval(notification.creationTimeInt / 1000))
      
        
        actionButton.isHidden = false

        dateLabel.text = dateFormatter.string(from: date).capitalizingFirstLetter()
        switch notification.type {
        case NOTI_NEW_MESSAGE:
            actionButton.isHidden = true

            let chatModelManager = ChatModelManager()
            let message = chatModelManager.messageWith(id: notification.idMessage)

            if let from = message?.idUserFrom{
                userId = from
                groupId = -1
                
                setAvatar()
              
                
                let numberMessages = chatModelManager.numberOfUnwatchedMessages(circleId: from)
                let circlesModelManager = CirclesGroupsModelManager.shared
                if let user = circlesModelManager.userWithId(id: from){
                    if numberMessages == 1{
                        contentLabel.text = L10n.notificacioNousMissatge(numberMessages, user.name)
                    }
                    else{
                        contentLabel.text = L10n.notificacioNousMissatges(numberMessages, user.name)
                    }

                }
                if circlesModelManager.contactWithId(id:  from) != nil{
                    actionButton.setTitle(L10n.notificacioButtonChat, for: .normal)
                    actionButton.setImage(UIImage(asset: Asset.Icons.Call.chat), for: .normal)
                    actionButton.isHidden = false
                }
              
            }
          
        case NOTI_NEW_CHAT_MESSAGE:
            // DONE WATCHED
            actionButton.isHidden = true
            let chatModelManager = ChatModelManager()

            let circlesModelManager = CirclesGroupsModelManager.shared
            if circlesModelManager.groupWithChatId(idChat: notification.idChat) != nil{
             
                if let group = circlesModelManager.groupWithChatId(idChat: notification.idChat){
                    let numberMessages = chatModelManager.numberOfUnwatchedGroupMessages(idChat: group.idChat)
                    if numberMessages == 1{
                        contentLabel.text = L10n.notificacioNousMissatgesGrupUn(numberMessages, group.name)
                    }
                    else{
                        contentLabel.text = L10n.notificacioNousMissatgesGrup(numberMessages, group.name)
                    }

                    groupId = group.id
                    userId = -1
                    
                    setAvatar()

                }
               
                if circlesModelManager.userGroupWithIdChat(idChat: notification.idChat) != nil{
                    actionButton.setTitle(L10n.notificacioButtonChat, for: .normal)
                    actionButton.isHidden = false
                    actionButton.setImage(UIImage(asset: Asset.Icons.Call.chat), for: .normal)

                    
                }
            }
            else if let dinamitzadorGroup = circlesModelManager.dinamitzadorWithChatIdInDB(idChat: notification.idChat){
                let chatModelManager = ChatModelManager()
                let numberMessages = chatModelManager.numberOfUnwatchedGroupMessages(idChat: notification.idChat)

                if let name = dinamitzadorGroup.dynamizer?.name{
                
                    if numberMessages == 1{
                        contentLabel.text = L10n.notificacioNousMissatgesDinamUn(numberMessages, name)
                    }
                    else{
                        contentLabel.text = L10n.notificacioNousMissatgesDinam(numberMessages, name)
                    }

                }
                
                
                if let id = dinamitzadorGroup.dynamizer?.id{
                    self.userId = id
                    groupId = -1

                    setAvatar()
                }
                
                actionButton.isHidden = true
                if circlesModelManager.dinamitzadorWithChatId(idChat: notification.idChat) != nil{
                    actionButton.setTitle(L10n.notificacioButtonChat, for: .normal)
                    actionButton.isHidden = false
                    actionButton.setImage(UIImage(asset: Asset.Icons.Call.chat), for: .normal)

                }
            }
            
            
     
        case NOTI_USER_LINKED:
            actionButton.isHidden = true

            self.userId = notification.idUser
            groupId = -1
            
           setAvatar()
            
           
                
                let circlesModelManager = CirclesGroupsModelManager.shared
                if let user = circlesModelManager.userWithId(id:  notification.idUser){
                    contentLabel.text = L10n.notificacioUserLinked(user.name)
                }
            
            if circlesModelManager.contactWithId(id:  notification.idUser) != nil{
                actionButton.setTitle(L10n.notificacioButtonChat, for: .normal)
                actionButton.setImage(UIImage(asset: Asset.Icons.Call.chat), for: .normal)
                actionButton.isHidden = false

            }
            

        case NOTI_ADDED_TO_GROUP:
            actionButton.isHidden = true

            let circlesModelManager = CirclesGroupsModelManager.shared

            if let group = circlesModelManager.groupWithId(id: notification.idGroup){
                self.userId = -1
                groupId = group.id
                
                setAvatar()
                contentLabel.text = L10n.notificacioNouGrup(group.name)

            }
            actionButton.isHidden = true

            if circlesModelManager.userGroupWithId(id: notification.idGroup) != nil{
                actionButton.setTitle(L10n.notificacioButtonChat, for: .normal)
                actionButton.setImage(UIImage(asset: Asset.Icons.Call.chat), for: .normal)

                actionButton.isHidden = false

            }

        case NOTI_MEETING_INVITATION_EVENT:
            actionButton.isHidden = true

            let agendaModelManager = AgendaModelManager()

            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){

                 if let host = meeting.hostInfo{
                    self.userId = host.id
                    self.groupId = -1
                    setAvatar()
                }
                
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
                    
                    contentLabel.text = L10n.notificacioInvitedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
                    actionButton.setImage(UIImage(asset: Asset.Icons.Agenda.crearCita), for: .normal)
     
                    actionButton.setTitle(L10n.notificacioButtonCita, for: .normal)
                }

              
                
            }
            
            if agendaModelManager.userMeetingWithId(id: notification.idMeeting) != nil{
                actionButton.isHidden = false
            }
        
        case NOTI_MEETING_CHANGED_EVENT:
            actionButton.isHidden = true

            let agendaModelManager = AgendaModelManager()
            
            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){
                if let host = meeting.hostInfo{
                    self.userId = host.id
                    self.groupId = -1
                    setAvatar()
                }
                
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
                    
                    contentLabel.text = L10n.notificacioChangedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
                    
                    actionButton.setImage(UIImage(asset: Asset.Icons.Agenda.crearCita), for: .normal)

                    actionButton.setTitle(L10n.notificacioButtonCita, for: .normal)
                    
                    
                }
                
            }
            if agendaModelManager.userMeetingWithId(id: notification.idMeeting) != nil{
                actionButton.isHidden = false
            }
        case NOTI_MEETING_ACCEPTED_EVENT:
            actionButton.isHidden = true

            let agendaModelManager = AgendaModelManager()
            
            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){
                
                self.userId = notification.idUser
                self.groupId = -1
               setAvatar()
                
                
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
                
                var name = ""
                for guest in meeting.guests{
                    if guest.userInfo?.id == notification.idUser{
                        if let firstName = guest.userInfo?.name, let lastName = guest.userInfo?.lastname{
                            name = firstName + " " + lastName
                            
                        }
                    }
                }
                
                contentLabel.text = L10n.notificacioIAcceptedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
                
                actionButton.setImage(UIImage(asset: Asset.Icons.Agenda.crearCita), for: .normal)
                actionButton.setTitle(L10n.notificacioButtonCita, for: .normal)
            }
            if agendaModelManager.userMeetingWithId(id: notification.idMeeting) != nil{
                actionButton.isHidden = false
            }
        case NOTI_MEETING_REJECTED_EVENT:
            actionButton.isHidden = true

            let agendaModelManager = AgendaModelManager()
            
            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){
                
                self.userId = notification.idUser
                self.groupId = -1
                setAvatar()
                
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
                
                var name = ""
                for guest in meeting.guests{
                    if guest.userInfo?.id == notification.idUser{
                        if let firstName = guest.userInfo?.name, let lastName = guest.userInfo?.lastname{
                            name = firstName + " " + lastName
                            
                        }
                    }
                }
                
                contentLabel.text = L10n.notificacioIDeclinedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
                
                actionButton.setImage(UIImage(asset: Asset.Icons.Agenda.crearCita), for: .normal)
                actionButton.setTitle(L10n.notificacioButtonCita, for: .normal)
            }
            if agendaModelManager.userMeetingWithId(id: notification.idMeeting) != nil{
                actionButton.isHidden = false
            }
            
        case NOTI_MEETING_INVITATION_REVOKE_EVENT, NOTI_MEETING_DELETED_EVENT:

            
            let agendaModelManager = AgendaModelManager()
            
            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){
                if let host = meeting.hostInfo{
                    self.userId = host.id
                    self.groupId = -1
                   setAvatar()
                }
                
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
                    
                    contentLabel.text = L10n.notificacioInvitationRevokedMeeting(name, dateFormatterGet.string(from: initDate), dateFormatter.string(from: initDate))
                    
                    actionButton.setImage(UIImage(asset: Asset.Icons.Agenda.crearCita), for: .normal)

                    actionButton.setTitle(L10n.notificacioButtonCalendari, for: .normal)
                    
                    
                }
                
            }
            
            
        case NOTI_USER_LEFT_CIRCLE, NOTI_USER_UNLINKED:
            self.userId = notification.idUser
            self.groupId = -1
            setAvatar()
            
            let circlesModelManager = CirclesGroupsModelManager.shared
            
            if let user = circlesModelManager.userWithId(id:  notification.idUser){
                contentLabel.text = L10n.notificacioUserUnlinked(user.name)
            }
            actionButton.setImage(UIImage(asset: Asset.Icons.contactesnot), for: .normal)

            actionButton.setTitle(L10n.notificacioButtonContacts, for: .normal)

        case NOTI_USER_UPDATED:
            contentLabel.text = NOTI_USER_UPDATED
        case NOTI_GROUP_UPDATED:
            contentLabel.text = NOTI_GROUP_UPDATED
        case NOTI_NEW_USER_GROUP:
            contentLabel.text = NOTI_NEW_USER_GROUP
        case NOTI_REMOVED_FROM_GROUP:
            let circlesModelManager = CirclesGroupsModelManager.shared
            
            if let group = circlesModelManager.groupWithId(id: notification.idGroup){
                self.userId = -1
                groupId = group.id
                
               
                setAvatar()
                contentLabel.text = L10n.notificacioEliminatGrup(group.name)
                
            }
            actionButton.isHidden = true
            
            if circlesModelManager.groupWithId(id: notification.idGroup) != nil{
                actionButton.setTitle(L10n.notificacioButtonGroups, for: .normal)
                actionButton.isHidden = false
                actionButton.setImage(UIImage(asset: Asset.Icons.grupsnot), for: .normal)

            }
        case NOTI_REMOVED_USER_GROUP:
            contentLabel.text = NOTI_REMOVED_USER_GROUP
        case NOTI_FAKE_REMINDER_EVENT:
            contentLabel.text = NOTI_FAKE_REMINDER_EVENT
            actionButton.setTitle(L10n.notificacioButtonCita, for: .normal)
            actionButton.setImage(UIImage(asset: Asset.Icons.Agenda.crearCita), for: .normal)

            let agendaModelManager = AgendaModelManager()
            
            if let meeting = agendaModelManager.meetingWithId(id: notification.idMeeting){
                if let host = meeting.hostInfo{
                    self.userId = host.id
                    self.groupId = -1
                   setAvatar()
                }
                let lang = UserDefaults.standard.string(forKey: "i18n_language")
                
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateStyle = .long
                dateFormatterGet.timeStyle = .short
                dateFormatterGet.locale = Locale(identifier: lang!)
                
                let initDate = Date(timeIntervalSince1970: TimeInterval(meeting.date / 1000))
             
                var stringDur = ""
                
                switch meeting.duration{
                case 30:
                    stringDur = L10n.duracionMediaHora
                case 60:
                    stringDur = L10n.duracionUnaHora
                case 90:
                    stringDur = L10n.duracionHoraMedia
                case 120:
                    stringDur = L10n.duracionDosHoras
                default:
                    break
                }
                var stringDesc = "\(L10n.citaRecordatori):\n\(meeting.descrip)\n\(dateFormatterGet.string(from: initDate))\n\(L10n.citaPopUpDurada): \(stringDur)"
                let profileModelManager = ProfileModelManager()

                if meeting.guests.count > 0{
                    var noms = [String]()
                    for part in meeting.guests{
                        if let name = part.userInfo?.name, let surname = part.userInfo?.lastname{
                            if part.userInfo?.id == profileModelManager.getUserMe()?.id{
                                noms.append(L10n.chatTu)
                                
                            }
                            else{
                                noms.append("\(name) \(surname)")
                            }
                            
                        }
                    }
                    
                    stringDesc = "\(L10n.citaRecordatori):\n\(meeting.descrip)\n\(dateFormatterGet.string(from: initDate))\n\(L10n.citaPopUpDurada): \(meeting.duration) \(L10n.citaPopUpMinutos)\n\(L10n.citaParticipants)\(noms.joined(separator: ", "))"
                    
                    
                }
                contentLabel.text = stringDesc
            }
                
        case NOTI_INCOMING_CALL:
            
            actionButton.isHidden = true

            let circlesModelManager = CirclesGroupsModelManager.shared

            if let user = circlesModelManager.contactWithId(id: notification.idUser){
                print(user.id)
                print(user.username)

                self.userId = user.id
                self.groupId = -1
               setAvatar()
                
                contentLabel.text =  "\(L10n.lostCall) \(user.name)"
                
            }
            
            if circlesModelManager.contactWithId(id:  notification.idUser) != nil{
                actionButton.setImage(UIImage(asset: Asset.Icons.Call.calling), for: .normal)
                actionButton.setTitle(L10n.notificacioButtonTrucar, for: .normal)
                actionButton.isHidden = false
                
                
            }
            
            
        case NOTI_GROUP_USER_INVITATION_CIRCLE:
            actionButton.isHidden = true
            
            self.userId = notification.idHost
            self.groupId = -1
            setAvatar()
         
            let circlesModelManager = CirclesGroupsModelManager.shared

            if let group = circlesModelManager.groupWithId(id: notification.idGroup), let user = group.users.filter("id == %i", notification.idHost).first{
                contentLabel.text = L10n.notificacioUserInvitation(user.name, notification.code)
            }
            
            if circlesModelManager.contactWithId(id:  notification.idHost) == nil{
                actionButton.setTitle(L10n.notificacioButtonUserInvitation, for: .normal)
                actionButton.setImage(UIImage(asset: Asset.Icons.contactesnot), for: .normal)
                actionButton.isHidden = false
                
            }
            
        default:
            break
        }
    }
    
    func setAvatar(){
        if userId != -1{
            if let url = ProfileImageManager.sharedInstance.getProfilePicture(userId: userId), let image = UIImage(contentsOfFile: url.path){
                userImage.image = image
            }
            else{
                userImage.image = UIImage(named: "perfilplaceholder")
            }
        }
        else if groupId != -1{
            if let url = GroupImageManager.sharedInstance.getGroupPicture(groupId: groupId), let image = UIImage(contentsOfFile: url.path){
                userImage.image = image
            }
            else{
                userImage.image = UIImage(named: "perfilplaceholder")
            }
        }
    }
}
