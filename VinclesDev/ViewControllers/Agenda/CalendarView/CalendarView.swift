//
//  CalendarView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit
import EventKit

struct EventLocation {
    let title: String
    let latitude: Double
    let longitude: Double
}

public struct CalendarEvent {
    let title: String
    let startDate: Date
    let endDate:Date
}

public protocol CalendarViewDataSource {
    func startDate() -> Date
    func endDate() -> Date
}

extension CalendarViewDataSource {
    
    func startDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -30
        
        let today = Date()
        
        let threeMonthsAgo = Calendar.current.date(byAdding: dateComponents, to: today)!
        
        return threeMonthsAgo
    }
    func endDate() -> Date {
        
        var dateComponents = DateComponents()
        
        dateComponents.month = 122;
        let today = Date()
        
        let twoYearsFromNow = Calendar.current.date(byAdding: dateComponents, to: today)!
        
        return twoYearsFromNow
    }
}

public protocol CalendarViewDelegate {
    
    func calendar(_ calendar : CalendarView, didScrollToMonth date : Date) -> Void
    func calendar(_ calendar : CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) -> Void
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void
    func calendar(_ calendar : CalendarView, didSelectDate date : Date) -> Void

}

extension CalendarViewDelegate {
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool { return true }
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void { return }
}

public class CalendarView: UIView {
    
    let cellReuseIdentifier = "CalendarDayCell"
        var collectionView: UICollectionView!
    
    lazy var calendar : Calendar = {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "UTC")!
        return gregorian
    }()
    
    internal var startDateCache     = Date()
    internal var endDateCache       = Date()
    internal var startOfMonthCache  = Date()
    internal var endOfMonthCache    = Date()
    
    internal var todayIndexPath: IndexPath?

    internal(set) var selectedIndexPaths    = [IndexPath]()
    internal(set) var selectedDates         = [Date]()
    
    internal var monthInfoForSection = [Int:(firstDay: Int, daysTotal: Int)]()
    internal var eventsByIndexPath = [IndexPath: [CalendarEvent]]()
    
    var events: [CalendarEvent] = [] {
        didSet {
            self.eventsByIndexPath.removeAll()
            
            for event in events {
                guard let indexPath = self.indexPathForDate(event.startDate) else { continue }
                
                var eventsForIndexPath = eventsByIndexPath[indexPath] ?? []
                eventsForIndexPath.append(event)
                eventsByIndexPath[indexPath] = eventsForIndexPath
            }
            
            DispatchQueue.main.async { self.collectionView.reloadData() }
        }
    }
    
    
    var flowLayout: CalendarColletionViewFlowLayout {
        return self.collectionView.collectionViewLayout as! CalendarColletionViewFlowLayout
    }
    
    // MARK: - public
    
    public var displayDate: Date?
    
    public var delegate: CalendarViewDelegate?
    public var dataSource: CalendarViewDataSource?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    // MARK: Create Subviews
    private func setup() {
        
        self.clipsToBounds = true
        
   
        /* Layout */
        let layout = CalendarColletionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = self.cellSize(in: self.bounds)
        
        /* Collection View */
        self.collectionView                     = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.dataSource          = self
        self.collectionView.delegate            = self
        self.collectionView.isPagingEnabled     = true
        self.collectionView.backgroundColor     = UIColor.clear
        self.collectionView.showsHorizontalScrollIndicator  = true
        self.collectionView.showsVerticalScrollIndicator    = false
        self.collectionView.allowsMultipleSelection         = false
        self.collectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        self.collectionView.semanticContentAttribute = .forceLeftToRight
        self.addSubview(self.collectionView)
    }
    
    override open func layoutSubviews() {
       
        super.layoutSubviews()
       
        
        self.collectionView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.frame.size.width,
            height: self.frame.size.height
        )
        
        flowLayout.itemSize = self.cellSize(in: self.bounds)
        
        self.resetDisplayDate()
    }
    
    private func cellSize(in bounds: CGRect) -> CGSize {
        return CGSize(
            width:   frame.size.width / 7.0,                                    // number of days in week
            height: (frame.size.height) / 6.0 // maximum number of rows
        )
    }
    
    internal func resetDisplayDate() {
        guard let displayDate = self.displayDate else { return }
        
        self.collectionView.setContentOffset(
            self.scrollViewOffset(for: displayDate),
            animated: false
        )
    }
    
    func scrollViewOffset(for date: Date) -> CGPoint {
        var point = CGPoint.zero
        
        guard let sections = self.indexPathForDate(date)?.section else { return point }
       point.x = CGFloat(sections) * self.collectionView.frame.size.width
        
        return point
    }
}

// MARK: Convertion

extension CalendarView {

    func indexPathForDate(_ date : Date) -> IndexPath? {
        
        let distanceFromStartDate = self.calendar.dateComponents([.month, .day], from: self.startOfMonthCache, to: date)
        
        guard
            let day   = distanceFromStartDate.day,
            let month = distanceFromStartDate.month,
            let (firstDayIndex, _) = monthInfoForSection[month] else { return nil }
        
        return IndexPath(item: day + firstDayIndex, section: month)
    }
    
    func dateFromIndexPath(_ indexPath: IndexPath) -> Date? {
        
        let month = indexPath.section
        
        guard let monthInfo = monthInfoForSection[month] else { return nil }
        
        var components      = DateComponents()
        components.month    = month
        components.day      = indexPath.item - monthInfo.firstDay
        
        return self.calendar.date(byAdding: components, to: self.startOfMonthCache)
    }
}

extension CalendarView {

    func goToMonthWithOffet(_ offset: Int) {
        
        guard let displayDate = self.displayDate else { return }
        
        var dateComponents = DateComponents()
        dateComponents.month = offset;
    
        guard let newDate = self.calendar.date(byAdding: dateComponents, to: displayDate) else { return }
        self.setDisplayDate(newDate, animated: true)
    }
}

// MARK: - Public methods
extension CalendarView {
    
    /*
     method: - reloadData
     function: - reload all components in collection view
     */
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
    /*
     method: - setDisplayDate
     params:
     - date: Date to extract month and year to scroll at correct section;
     - animated: to handle animation if want;
     function: - scroll calendar at date (month/year) passed as parameter.
     */
    public func setDisplayDate(_ date : Date, animated: Bool = false) {
        
        guard (date > startDateCache) && (date < endDateCache) else { return }
        self.collectionView.setContentOffset(self.scrollViewOffset(for: date), animated: animated)
        self.displayDate = date
    }
    
    /*
     TODO
     */
    public func selectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        self.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    /*
     TODO
     */
    public func deselectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView.deselectItem(at: indexPath, animated: false)
        self.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    /*
     TODO
     */
    public func goToNextMonth() {
        goToMonthWithOffet(1)
    }
    
    /*
     TODO
     */
    public func goToPreviousMonth() {
        goToMonthWithOffet(-1)
    }
}
