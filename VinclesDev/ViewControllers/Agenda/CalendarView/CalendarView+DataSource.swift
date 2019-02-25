//
//  CalendarView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

extension CalendarView: UICollectionViewDataSource {
    
    var hasLastLine: Bool {
        return false
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard let dateSource = self.dataSource else { return 0 }
        
        self.startDateCache = dateSource.startDate()
        self.endDateCache   = dateSource.endDate()
        
        guard self.startDateCache <= self.endDateCache else { fatalError("Start date cannot be later than end date.") }
        
        var firstDayOfStartMonthComponents = self.calendar.dateComponents([.era, .year, .month], from: self.startDateCache)
        firstDayOfStartMonthComponents.day = 1
        
        let firstDayOfStartMonthDate = self.calendar.date(from: firstDayOfStartMonthComponents)!
        
        self.startOfMonthCache = firstDayOfStartMonthDate
        
        var lastDayOfEndMonthComponents = self.calendar.dateComponents([.era, .year, .month], from: self.endDateCache)
        let range = self.calendar.range(of: .day, in: .month, for: self.endDateCache)!
        lastDayOfEndMonthComponents.day = range.count
        
        self.endOfMonthCache = self.calendar.date(from: lastDayOfEndMonthComponents)!
        
        let today = Date()
        
        if (self.startOfMonthCache ... self.endOfMonthCache).contains(today) {
            
            let distanceFromTodayComponents = self.calendar.dateComponents([.month, .day], from: self.startOfMonthCache, to: today)
            
            self.todayIndexPath = IndexPath(item: distanceFromTodayComponents.day!, section: distanceFromTodayComponents.month!)
        }
        
        // if we are for example on the same month and the difference is 0 we still need 1 to display it
        return self.calendar.dateComponents([.month], from: startOfMonthCache, to: endOfMonthCache).month! + 1
    }
    
    public func getMonthInfo(for date: Date) -> (firstDay: Int, daysTotal: Int)? {
        
        var firstWeekdayOfMonthIndex    = self.calendar.component(.weekday, from: date)
        firstWeekdayOfMonthIndex        = firstWeekdayOfMonthIndex - 1 // firstWeekdayOfMonthIndex should be 0-Indexed
        firstWeekdayOfMonthIndex        = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly to take it back one day where the first day is Monday instead of Sunday
        
        guard let rangeOfDaysInMonth = self.calendar.range(of: .day, in: .month, for: date) else { return nil }
        
        return (firstDay: firstWeekdayOfMonthIndex, daysTotal: rangeOfDaysInMonth.count)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var monthOffsetComponents = DateComponents()
        monthOffsetComponents.month = section;
        
        guard let correctMonthForSectionDate = self.calendar.date(byAdding: monthOffsetComponents, to: startOfMonthCache),
            let info = self.getMonthInfo(for: correctMonthForSectionDate) else { return 0 }
        
        self.monthInfoForSection[section] = info
        
        return 42 // rows:7 x cols:6
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarCollectionViewCell
        
          guard let (firstDayIndex, numberOfDaysTotal) = self.monthInfoForSection[indexPath.section] else { return dayCell }
        
        if indexPath.section % 2 != 0{
            dayCell.backgroundColor = .white
            
            if indexPath.row == 0 || indexPath.row % 2 == 0{
                dayCell.backgroundColor = UIColor(named: .clearGrayChat)
            }
            
        }
        else{
            dayCell.backgroundColor = UIColor(named: .clearGrayChat)
            
            if indexPath.row == 0 || indexPath.row % 2 == 0{
                dayCell.backgroundColor = UIColor.white
            }
        }
        let lastDayIndex = firstDayIndex + numberOfDaysTotal

        if indexPath.row > 34 && lastDayIndex < 36{
            dayCell.backgroundColor = UIColor.white

        }
        
      
        
        let fromStartOfMonthIndexPath = IndexPath(item: indexPath.item - firstDayIndex, section: indexPath.section) // if the first is wednesday, add 2
        
        
        
        if (firstDayIndex..<lastDayIndex).contains(indexPath.item) { // item within range from first to last day
            dayCell.dayLabel.text = String(fromStartOfMonthIndexPath.item + 1)
            
        } else {
            dayCell.dayLabel.text = ""
        }
        
        
      
        
        if indexPath.section == 0 && indexPath.item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        
        if let idx = todayIndexPath {
            dayCell.isToday = (idx.section == indexPath.section && idx.item + firstDayIndex == indexPath.item)
        }
        
        dayCell.isSelected = selectedIndexPaths.contains(indexPath)
 
        if let date = self.dateFromIndexPath(indexPath){
            
            dayCell.dayLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 26.0)
            if UIDevice.current.userInterfaceIdiom == .phone  {
                dayCell.dayLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)
                
            }
            
            if Calendar.current.isDateInWeekend(date){
                dayCell.dayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 26.0)
                if UIDevice.current.userInterfaceIdiom == .phone  {
                    dayCell.dayLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 13.0)
                    
                }
            }
            
            let agendaModelManager = AgendaModelManager()
            
            if agendaModelManager.numberOfMeetingsOn(date: date) > 0 && dayCell.dayLabel.text != ""{
                dayCell.eventsCount = agendaModelManager.numberOfMeetingsOn(date: date)
            } else {
                dayCell.eventsCount = 0
            }
        }

       
        /*
        if let eventsForDay = self.eventsByIndexPath[indexPath] {
            dayCell.eventsCount = eventsForDay.count
        } else {
            dayCell.eventsCount = 0
        }
        */
      
        
        return dayCell
    }
}
