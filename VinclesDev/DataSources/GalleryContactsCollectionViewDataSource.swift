//
//  GalleryContactsCollectionViewDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit
import RealmSwift
import SVProgressHUD

protocol GalleryContactsCollectionViewDataSourceClickDelegate{
    func selectedShareContacts(indexes: [Int])
    func maxError()
}

class GalleryContactsCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cellSpacing = CGFloat(5.0)
    var columns = 1
    var clickDelegate: GalleryContactsCollectionViewDataSourceClickDelegate?
    var horizontalInsets = CGFloat(10.0)
    var selectedIndexPaths = [Int]()
    var circlesGroupsModelManager: CirclesGroupsModelManagerProtocol!
    lazy var profileModelManager = ProfileModelManager()
    var maxSelectItems = 5

    
    func getItem(indexPath: Int) -> (Any, Bool){
        
        var contactItems = [ContactItem]()
        
        let realm = try! Realm()
        
        let chatManager = ChatModelManager()
        let notificationsModelManager = NotificationsModelManager()

        
        if profileModelManager.userIsVincle{
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
                
                for group in user.groups{
                    let contactItem = ContactItem()
                    contactItem.name = group.name
                    contactItem.surname = "ZZZZZZZZZZZZZZZZ"
                    contactItem.unreadMessagesAndLostCalls = 0
                    contactItem.totalMessages = group.messages.count
                    contactItem.group = group
                    
                    contactItems.append(contactItem)
                }
                
                for dinam in user.dinamizadores{
                    let contactItem = ContactItem()
                    contactItem.name = dinam.name
                    contactItem.surname = dinam.lastname
                    contactItem.unreadMessagesAndLostCalls = 0
                    contactItem.totalMessages = dinam.messages.count
                    contactItem.user = dinam
                    contactItem.isDinam = true
                    
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
        if profileModelManager.userIsVincle{
            return circlesGroupsModelManager.numberOfContacts + circlesGroupsModelManager.numberOfGroups + circlesGroupsModelManager.numberOfDinamizadores
        }
        return circlesGroupsModelManager.numberOfContacts
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! GaleriaContactCollectionViewCell
        
        let (item, removable) = getItem(indexPath: indexPath.row)
        if item is User{
            cell.configWithUser(user: item as! User, selected: selectedIndexPaths.contains(indexPath.row), editMode: true)

        }
        if item is Group{
            cell.configWithGroup(group: item as! Group, selected: selectedIndexPaths.contains(indexPath.row), editMode: true)
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GaleriaContactCollectionViewCell{
                cell.setAvatar()
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
            let cell = collectionView.cellForItem(at: indexPath) as! GaleriaContactCollectionViewCell
            if selectedIndexPaths.contains(indexPath.row){
                cell.checkBox.setOn(false, animated: true)
                selectedIndexPaths.remove(at: selectedIndexPaths.index(of: indexPath.row)!)
            }
            else if selectedIndexPaths.count < maxSelectItems{
                cell.checkBox.setOn(true, animated: true)
                selectedIndexPaths.append(indexPath.row)
            }
            else{
                clickDelegate?.maxError()
//                SVProgressHUD.showError(withStatus: L10n.galeriaMaxContacts)
//                Timer.after(2.second) {
//                    SVProgressHUD.dismiss()
//                }
        }
            clickDelegate?.selectedShareContacts(indexes: selectedIndexPaths)
     
        
    }
    
    func selectedContactsForSelectedIndexPaths() -> [Any]{
        var selectedItems = [Any]()
        for index in selectedIndexPaths{
            
            
            let (item, removable) = getItem(indexPath: index)
            selectedItems.append(item)


        }
        return selectedItems
    }
}


