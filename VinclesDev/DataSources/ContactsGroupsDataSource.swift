//
//  ContactsGroupsDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import RealmSwift

protocol ContactsGroupsDataSourceClickDelegate{
    func showRemovePopup(item: Any)
    func selectedContact(user: User)
    func selectedGroup(group: Group)
    func selectedDinamitzador(group: Group)

}

class ContactsGroupsDataSource: NSObject , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cellSpacing = CGFloat(5.0)
    var columns = 1
    var horizontalInsets = CGFloat(10.0)
    var selectedIndexPaths = [Int]()
    var contactsFilter: FilterContactsType = .all
    var editMode = false
    var clickDelegate: ContactsGroupsDataSourceClickDelegate?
    var circlesGroupsModelManager: CirclesGroupsModelManagerProtocol!
    var profileModelManager: ProfileModelManagerProtocol!

    func getItem(indexPath: Int) -> (Any, Bool){
        
        var contactItems = [ContactItem]()
        
        let realm = try! Realm()
        
        let chatManager = ChatModelManager()
        let notificationsModelManager = NotificationsModelManager()
        
        
        if profileModelManager.userIsVincle{
            if let auth = realm.objects(AuthResponse.self).first, let user = realm.objects(User.self).filter("id == %i", auth.userId).first{
                if contactsFilter == .all || contactsFilter == .family{
                    for contact in user.circles{
                        let contactItem = ContactItem()
                        contactItem.name = contact.name
                        contactItem.surname = contact.lastname
                        contactItem.unreadMessagesAndLostCalls = chatManager.numberOfUnwatchedMessages(circleId: contact.id) + notificationsModelManager.numberOfUnwatchedMissedCall(circleId: contact.id)
                        contactItem.totalMessages = contact.messages.count
                        contactItem.user = contact
                        
                        contactItems.append(contactItem)
                    }
                }
               
                if contactsFilter == .all || contactsFilter == .groups{
                    for group in user.groups{
                        // DONE WATCHED
                        let contactItem = ContactItem()
                        contactItem.name = group.name
                        contactItem.surname = "ZZZZZZZZZZZZZZZZ"
                        contactItem.unreadMessagesAndLostCalls = chatManager.numberOfUnwatchedGroupMessages(idChat: group.idChat)
                        contactItem.totalMessages = group.messages.count
                        contactItem.group = group
                        
                        contactItems.append(contactItem)
                    }
                }
                
              
                if contactsFilter == .all || contactsFilter == .dinams{
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
                }
                
               
                contactItems.sort{ //sort(_:) in Swift 3
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
                    if itemAtIndex.isDinam{
                        return (itemAtIndex.user!, false)
                    }
                    else{
                        return (itemAtIndex.user!, true)
                    }
                }
                if itemAtIndex.group != nil{
                    return (itemAtIndex.group!, false)
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
                
              
                
                contactItems.sort{ //sort(_:) in Swift 3
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
                    return (itemAtIndex.user!, true)
                }
                
            }
        }
        
      
        return ("", false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch contactsFilter {
        case .all:
            if profileModelManager.userIsVincle{
                return circlesGroupsModelManager.numberOfContacts + circlesGroupsModelManager.numberOfGroups + circlesGroupsModelManager.numberOfDinamizadores
            }
            return circlesGroupsModelManager.numberOfContacts
        case .family:
            return circlesGroupsModelManager.numberOfContacts
        case .groups:
            return circlesGroupsModelManager.numberOfGroups
        case .dinams:
            return circlesGroupsModelManager.numberOfDinamizadores
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! ContactItemCollectionViewCell
        cell.eliminarButton.isHidden = true

        let (item, removable) = getItem(indexPath: indexPath.row)
        if item is User{
            cell.configWithUser(user: item as! User)
            
        }
        else if item is Group{
            cell.configWithGroup(group: item as! Group)
        }
        
        if removable && editMode{
            cell.eliminarButton.isHidden = false
        }
        
        /*
        cell.eliminarButton.addTargetClosure { (sender) in
            self.clickDelegate?.showRemovePopup(item: item)
        }
 */
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ContactItemCollectionViewCell{
            if cell.isUser{
                cell.setAvatar()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/CGFloat(columns) - cellSpacing - (horizontalInsets * 2/CGFloat(columns)), height: collectionView.bounds.size.width/CGFloat(columns) - cellSpacing - (horizontalInsets * 2/CGFloat(columns)))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: horizontalInsets, bottom: 0, right: horizontalInsets)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !editMode{
            let (item, _) = getItem(indexPath: indexPath.row)
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
               
                
            }
            else if item is Group{
                clickDelegate?.selectedGroup(group: item as! Group)
                
            }
        }
        else{
            let (item, _) = getItem(indexPath: indexPath.row)
            self.clickDelegate?.showRemovePopup(item: item)
        }
     
    
    }
}




