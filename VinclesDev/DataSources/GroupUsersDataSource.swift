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
    var descInfo = ""
    
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GroupParticipantCollectionViewCell{
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
        if indexPath.row != 0{
            let me = profileModelManager.getUserMe()

            let user = getItem(indexPath: indexPath.row)
            if user.id != me?.id{
                let circlesGroupsModelManager = CirclesGroupsModelManager.shared
                if circlesGroupsModelManager.contactWithId(id: user.id) == nil{
                    clickDelegate?.selectedContact(user: user)
                }
            }

        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
            // 1
            switch kind {
            // 2
            case UICollectionView.elementKindSectionHeader:
                // 3
                guard
                    let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: "GroupInfoHeaderCollectionReusableView",
                        for: indexPath) as? GroupInfoHeaderCollectionReusableView
                    else {
                        fatalError("Invalid view type")
                }
                
                headerView.headerLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 18.0)
                
                headerView.headerLabel.numberOfLines = 0
                if UIDevice.current.userInterfaceIdiom == .phone {
                    headerView.headerLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 15.0)
                    
                }
                
                headerView.headerLabel.text = descInfo
                return headerView
            default:
                // 4
                return UICollectionReusableView()
            }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
     
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            print(CGSize(width: collectionView.frame.size.width, height: descInfo.heightWithConstrainedWidth(font: UIFont(font: FontFamily.Akkurat.regular, size: 15.0))))
            return CGSize(width: collectionView.frame.size.width, height: 60 + descInfo.heightWithConstrainedWidth(font: UIFont(font: FontFamily.Akkurat.regular, size: 15.0)))
        }
        
        return CGSize(width: collectionView.frame.size.width, height: 60 + descInfo.heightWithConstrainedWidth(font: UIFont(font: FontFamily.Akkurat.regular, size: 18.0)))
    }
}


extension String {
    func heightWithConstrainedWidth(font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: UIScreen.main.bounds.width - 32, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
}



