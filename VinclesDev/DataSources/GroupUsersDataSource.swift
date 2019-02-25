//
//  GroupUsersDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit


protocol GroupUsersDataSourceClickDelegate{
    func selectedContact(user: User)
    
}

class GroupUsersDataSource: NSObject , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cellSpacing = CGFloat(5.0)
    var columns = 1
    var horizontalInsets = CGFloat(10.0)
    var selectedIndexPaths = [Int]()
    var contactsFilter: FilterContactsType = .all
    var editMode = false
    var clickDelegate: GroupUsersDataSourceClickDelegate?
    var circlesGroupsModelManager: CirclesGroupsModelManagerProtocol!
    var profileModelManager: ProfileModelManagerProtocol!
    var group: Group!
    
    func getItem(indexPath: Int) -> User{
        
        if indexPath == 0{
            return group.dynamizer!
        }
        else {
            let user = circlesGroupsModelManager.groupParticipantAt(index: indexPath - 1, id: group.id)
            return user!
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(group.users.count)
        let me = profileModelManager.getUserMe()
       // return 1 + group.users.filter("id != %i", me?.id ?? -1).count
        return 1 + group.users.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! GroupParticipantCollectionViewCell
        
        let item = getItem(indexPath: indexPath.row)
        cell.configWithUser(user: item, isDinam: indexPath.row == 0)

       
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
        if indexPath.row != 0{
            
            let user = getItem(indexPath: indexPath.row)
            let circlesGroupsModelManager = CirclesGroupsModelManager()
            if circlesGroupsModelManager.contactWithId(id: user.id) == nil{
                clickDelegate?.selectedContact(user: user)
            }

        }
        
        
        
    }
}



