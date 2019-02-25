//
//  CalendarView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

extension CalendarView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell

        guard let date = self.dateFromIndexPath(indexPath) else { return }
        
        if let index = selectedIndexPaths.index(of: indexPath) {
            
            delegate?.calendar(self, didDeselectDate: date)
            
            selectedIndexPaths.remove(at: index)
            selectedDates.remove(at: index)
            
        } else {
            
            if cell.dayLabel.text != ""{
                selectedIndexPaths.removeAll()
                selectedDates.removeAll()
                selectedIndexPaths.append(indexPath)
                selectedDates.append(date)
                
                let agendaModelManager = AgendaModelManager()
                
                // if agendaModelManager.numberOfMeetingsOn(date: date) > 0 {
                
                
                delegate?.calendar(self, didSelectDate: date)
                
                //   }
            }
            else{
                
            }
           
            
         //   let eventsForDaySelected = eventsByIndexPath[indexPath] ?? []
         //    delegate?.calendar(self, didSelectDate: date, withEvents: eventsForDaySelected)
        }
        
        self.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        guard let dateBeingSelected = self.dateFromIndexPath(indexPath) else { return false }
        
        if let delegate = self.delegate {
            return delegate.calendar(self, canSelectDate: dateBeingSelected)
        }
        
        return true // default
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateAndNotifyScrolling()
        
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updateAndNotifyScrolling()
    }
    
    func updateAndNotifyScrolling() {
        
        guard let date = self.dateFromScrollViewPosition() else { return }
        
        self.displayDate = date
        self.delegate?.calendar(self, didScrollToMonth: date)
        
    }
    
    @discardableResult
    func dateFromScrollViewPosition() -> Date? {
        var page: Int = 0
        
        page = Int(floor(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width))
        
        page = page > 0 ? page : 0
        
        var monthsOffsetComponents = DateComponents()
        monthsOffsetComponents.month = page
        
        return self.calendar.date(byAdding: monthsOffsetComponents, to: self.startOfMonthCache);
    }
   
}

