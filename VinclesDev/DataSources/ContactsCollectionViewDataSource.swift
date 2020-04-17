//
//  ContactsCollectionViewDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift

protocol ContactsCollectionViewDataSourceClickDelegate{
    func selectedContact(user: User)
    func selectedGroup(group: Group)
    func selectedDinamitzador(group: Group)

}

class ContactsCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cellSpacing = CGFloat(5.0)
    var columns = 0
    var rows = 0
    var clickDelegate: ContactsCollectionViewDataSourceClickDelegate?
    var circlesManager: CirclesGroupsModelManagerProtocol!
    var profileModelManager: ProfileModelManagerProtocol!

    func getItem(indexPath: Int) -> Any{
        
        var contactItems = [ContactItem]()
        
        let realm = try! Realm()
        
        let chatManager = ChatModelManager()
        let notificationsModelManager = NotificationsModelManager()
        let chatModelManager = ChatModelManager()

        if profileModelManager.userIsVincle{
            if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
                for contact in user.circles{
                    print(contact.name)
                    print(contact.username)
                    print(contact.id)
                    let contactItem = ContactItem()
                    contactItem.name = contact.name
                    contactItem.surname = contact.lastname
                    contactItem.unreadMessagesAndLostCalls = chatManager.numberOfUnwatchedMessages(circleId: contact.id) + notificationsModelManager.numberOfUnwatchedMissedCall(circleId: contact.id)
                    contactItem.totalMessages = contact.messages.count
                    contactItem.user = contact
                    
                    var interactionDate = Date(timeIntervalSince1970: 0)
                    if let lastMessageDate = contact.messages.sorted(by: { $0.sendTime > $1.sendTime }).first{
                        interactionDate = lastMessageDate.sendTime
                    }
                    if let lastCallDate = notificationsModelManager.lastCall(circleId: contact.id){
                        if lastCallDate > interactionDate{
                            interactionDate = lastCallDate
                        }
                    }
                    contactItem.lastInteraction = interactionDate

                    contactItems.append(contactItem)
                }
                
                for group in user.groups{
                    // DONE WATCHED
                    let contactItem = ContactItem()
                    contactItem.name = group.name
                    contactItem.surname = "ZZZZZZZZZZZZZZZZ"
                    contactItem.unreadMessagesAndLostCalls = chatManager.numberOfUnwatchedGroupMessages(idChat: group.idChat)
                    contactItem.totalMessages = group.messages.count
                    contactItem.group = group
                    
                    var interactionDate = Date(timeIntervalSince1970: 0)
                    if let lastMessageDate = group.messages.sorted(by: { $0.sendTime > $1.sendTime }).first{
                        interactionDate = lastMessageDate.sendTime
                    }
                    
                    contactItem.lastInteraction = interactionDate
                    
                    contactItems.append(contactItem)
                }
                

                for dinam in user.dinamizadores{
                    // DONE WATCHED
                    
                    let contactItem = ContactItem()
                    contactItem.name = dinam.name
                    contactItem.surname = dinam.lastname
                    contactItem.unreadMessagesAndLostCalls = dinam.messages.filter("watched == %@", false).count
                    contactItem.totalMessages = dinam.messages.count
                    contactItem.user = dinam
                    contactItem.isDinam = true
                    
                    contactItems.append(contactItem)
                }
       
            
               
                contactItems.sort{ //sort(_:) in Swift 3
                    if $0.unreadMessagesAndLostCalls != $1.unreadMessagesAndLostCalls {
                        return $0.unreadMessagesAndLostCalls > $1.unreadMessagesAndLostCalls
                    }
                    else if $0.lastInteraction != $1.lastInteraction {
                         return $0.lastInteraction > $1.lastInteraction
                    }
                    else if $0.name != $1.name {
                        return $0.name < $1.name
                    }
                    else {
                        return $0.surname < $1.surname
                    }
                }
                
                let itemAtIndex = contactItems[indexPath]
                if itemAtIndex.user != nil{
                    return itemAtIndex.user!
                }
                if itemAtIndex.group != nil{
                    return itemAtIndex.group!
                }
            }
        }
        else{
            if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
                for contact in user.circles{
                    let contactItem = ContactItem()
                    contactItem.name = contact.name
                    contactItem.surname = contact.lastname
                    contactItem.unreadMessagesAndLostCalls = chatManager.numberOfUnwatchedMessages(circleId: contact.id) + notificationsModelManager.numberOfUnwatchedMissedCall(circleId: contact.id)
                    contactItem.totalMessages = contact.messages.count
                    contactItem.user = contact
                    
                    contactItems.append(contactItem)
                }
               
                contactItems.sort{
                    if $0.unreadMessagesAndLostCalls != $1.unreadMessagesAndLostCalls {
                        return $0.unreadMessagesAndLostCalls > $1.unreadMessagesAndLostCalls
                    }
                    else if $0.totalMessages != $1.totalMessages {
                        return $0.totalMessages > $1.totalMessages
                    }
                    else if $0.name != $1.name {
                        return $0.name < $1.name
                    }
                    else {
                        return $0.surname < $1.surname
                    }
                }
                
                let itemAtIndex = contactItems[indexPath]
                if itemAtIndex.user != nil{
                    return itemAtIndex.user!
                }
            }
        }
        
        return ""
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        return columns * rows
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ContactCollectionViewCell{
            cell.setAvatar()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! ContactCollectionViewCell
        
      
        
        if profileModelManager.userIsVincle{
            if indexPath.row < circlesManager.numberOfContacts + circlesManager.numberOfGroups + circlesManager.numberOfDinamizadores{
                let item = getItem(indexPath: indexPath.row)
                if item is User{
                    cell.configWithUser(user: item as! User)
                    
                }
                else if item is Group{
                    cell.configWithGroup(group: item as! Group)
                }
                
            }
            else{
                cell.configEmpty()
            }
        }
        else{
            if indexPath.row < circlesManager.numberOfContacts{
                let item = getItem(indexPath: indexPath.row)
                if item is User{
                    cell.configWithUser(user: item as! User)
                    
                }
            }
            else{
                cell.configEmpty()
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/CGFloat(columns) - cellSpacing, height: collectionView.bounds.size.height/CGFloat(rows) - cellSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if profileModelManager.userIsVincle{
            if indexPath.row < circlesManager.numberOfContacts + circlesManager.numberOfGroups + circlesManager.numberOfDinamizadores{
                let item = getItem(indexPath: indexPath.row)
                if item is User{
                    let circlesManager = CirclesManager()
                    if let user = item as? User{
                        if circlesManager.userIsCircle(id: user.id){
                            clickDelegate?.selectedContact(user: item as! User)
                        }
                        else if circlesManager.userIsDinamitzador(id: user.id){
                            if let group = circlesManager.groupForDinamitzador(id: user.id){
                                clickDelegate?.selectedDinamitzador(group: group)
                                
                            }
                        }
                    }
                    
                   // clickDelegate?.selectedContact(user: item as! User)

                }
                else if item is Group{
                    clickDelegate?.selectedGroup(group: item as! Group)
                }
                
            }
          
        }
        else{
            if indexPath.row < circlesManager.numberOfContacts{
                let item = getItem(indexPath: indexPath.row)
                if item is User{
                    clickDelegate?.selectedContact(user: item as! User)

                }
            }
           
        }

    }
}



