//
//  CalendarDayCell.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.

import UIKit

open class CalendarCollectionViewCell: UICollectionViewCell {

    var eventsCount = 0 {
        didSet {
            self.eventView.isHidden = (eventsCount == 0)
            self.setNeedsLayout()
        }
    }

    var isToday : Bool = false {
        didSet {
            switch isToday {
            case true:
                self.dayLabel.textColor = UIColor(named: .darkRed)
            case false:
                self.dayLabel.textColor = UIColor(named: .darkGray)
            }
        }
    }
    
    override open var isSelected : Bool {
        didSet {
            switch isSelected {
            case true:
                self.selectionView.layer.borderColor = UIColor(named: .darkRed).cgColor
                self.selectionView.layer.borderWidth = 1.0
            case false:
                self.selectionView.layer.borderColor = UIColor.clear.cgColor
                self.selectionView.layer.borderWidth = 0.0
            }
        }
    }

    let dayLabel   = UILabel()
    let eventView    = UIView()
    let selectionView      = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.selectionView)
        self.addSubview(self.dayLabel)
        self.addSubview(self.eventView)
        
        self.dayLabel.textAlignment = NSTextAlignment.center
        self.eventView.backgroundColor = UIColor(named: .darkGray)
        dayLabel.textColor = .black
        dayLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 26.0)
        if UIDevice.current.userInterfaceIdiom == .phone  {
            dayLabel.font = UIFont(font: FontFamily.Akkurat.regular, size: 13.0)

        }
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        var elementsFrame = self.bounds.insetBy(dx: 10.0, dy: 10.0)
        if UIDevice.current.userInterfaceIdiom == .phone  {
            elementsFrame = self.bounds.insetBy(dx: 2.0, dy: 2.0)
        }
        
        let smallestSide = min(elementsFrame.width, elementsFrame.height)
        elementsFrame = elementsFrame.insetBy(
            dx: (elementsFrame.width - smallestSide) / 2.0,
            dy: (elementsFrame.height - smallestSide) / 2.0
        )

        self.selectionView.frame           = elementsFrame
        self.dayLabel.frame        = self.bounds
        
        var size                            = 10.0 // always a percentage of the whole cell
        if UIDevice.current.userInterfaceIdiom == .phone  {
            size = 4.0
        }
        self.eventView.frame                 = CGRect(x: 0, y: 0, width: size, height: size)
        self.eventView.center                = CGPoint(x: self.frame.size.width - 10.0, y: 10)
        if UIDevice.current.userInterfaceIdiom == .phone  {
            self.eventView.center                = CGPoint(x: self.frame.size.width - 5.0, y: 5)

        }
        self.eventView.layer.cornerRadius    = CGFloat(size * 0.5) // round it
        
        self.selectionView.layer.cornerRadius = elementsFrame.width * 0.5
    }
    
}


