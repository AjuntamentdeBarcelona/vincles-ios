//
//  AgendaContactsDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

protocol AgendaContactsDataSourceClickDelegate{
    func selectedShareContacts(users: [User])
}

class AgendaContactsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cellSpacing = CGFloat(5.0)
    var columns = 1
    var clickDelegate: AgendaContactsDataSourceClickDelegate?
    var horizontalInsets = CGFloat(10.0)
    var circlesGroupsModelManager: CirclesGroupsModelManagerProtocol!
    var selectedUsers = [User]()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return circlesGroupsModelManager.numberOfContacts
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! GaleriaContactCollectionViewCell
        cell.configWithUser(user: circlesGroupsModelManager.contactAt(index: indexPath.row), selected: selectedUsers.contains(circlesGroupsModelManager.contactAt(index: indexPath.row)), editMode: true)
        
        return cell
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
        let user = circlesGroupsModelManager.contactAt(index: indexPath.row)
        if selectedUsers.contains(user){
            cell.checkBox.setOn(false, animated: true)
            if let index = selectedUsers.index(of: user){
                selectedUsers.remove(at: index)
            }
        }
        else{
            cell.checkBox.setOn(true, animated: true)
            selectedUsers.append(user)
        }
        clickDelegate?.selectedShareContacts(users: selectedUsers)
        
        
    }
    
  
}


