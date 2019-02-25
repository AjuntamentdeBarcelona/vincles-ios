//
//  MeetingGuestsDataSource.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class MeetingGuestsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var cellSpacing = CGFloat(5.0)
    var columns = 1
    var horizontalInsets = CGFloat(0.0)
    lazy var agendaModelManager = AgendaModelManager()
    var meeting: Meeting!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return agendaModelManager.numberOfGuests(meeting: meeting)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contactCell", for: indexPath) as! EventGuestCollectionViewCell
        cell.configWithGuest(guest: agendaModelManager.guestAtIndex(meeting: meeting, index: indexPath.row), meetingId: meeting.id)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.bounds.size.width)
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
     
    }
    
    
}

