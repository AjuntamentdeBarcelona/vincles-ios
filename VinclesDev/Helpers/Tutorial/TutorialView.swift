//
//  TutorialView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import Foundation
import UIKit

private let defaultDimColor = UIColor.black.withAlphaComponent(0.7).cgColor

@objc public protocol TutorialViewDelegate {
    @objc optional func willInteractWithView(_ view: UIView)
}

@objc open class TutorialView: UIView {
    
    var closeButton: UIButton?
    
    open var availableViews: [TutorialItem] = []
    
    open var dimColor: CGColor = defaultDimColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open weak var delegate: TutorialViewDelegate?
    
    lazy var overlayView: UIView = self.makeOverlay()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        unregisterFromOrientationChanges()
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        superview?.bringSubviewToFront(self)
        
        removeOverlaySublayers()
        
        let overlayPath = UIBezierPath(rect: bounds)
        overlayPath.usesEvenOddFillRule = true
        
        for item in availableViews {
            let currentView = item.sourceView
            let convertedFrame = item.sourceView.superview?.convert(currentView.frame, to: overlayView)
            
            if let cf = convertedFrame {
                let highlightedFrame = cf.insetBy(dx: -item.paddingX, dy: -item.paddingY)
                let transparentPath =  UIBezierPath(roundedRect: highlightedFrame, cornerRadius: item.radius)
                overlayPath.append(transparentPath)
            }
        }
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = dimColor
        
        overlayView.layer.addSublayer(fillLayer)
    }
    
    func addDescriptions(){
        for item in availableViews {
            let globalMenuFrame = item.sourceView.superview?.convert(item.sourceView.frame, to: nil)
            let label = UILabel()
            label.textColor = .white
            label.text = item.tutorialText
            label.numberOfLines = 0
            label.font = UIFont(font: FontFamily.Akkurat.regular, size: 18.0)
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            
            if item.leftAlignment{
                let leadingConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: (globalMenuFrame?.origin.x)!)
                let topConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: (globalMenuFrame?.origin.y)! + 60)
                
               
                self.addConstraints([leadingConstraint, topConstraint])
                
            }
            else{
                label.textAlignment = .right

                let trailing = self.frame.size.width - ((globalMenuFrame?.origin.x)! + (globalMenuFrame?.size.width)!)
                let helpTrailingConstraint = NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -trailing)
                let helpTopConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: (globalMenuFrame?.origin.y)! + 60)
               
                self.addConstraints([helpTrailingConstraint, helpTopConstraint])
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                let labelWidthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (globalMenuFrame?.size.width)! * 2)
                label.addConstraints([labelWidthConstraint])
            }
            else{
                let labelWidthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (globalMenuFrame?.size.width)! * 4)
                label.addConstraints([labelWidthConstraint])
            }
            
        }
    }
    
  
    func setup() {
        setupSubviews()
        setupConstraints()  
        isOpaque = false
        registerForOrientationChanges()
    }
    
    func setupSubviews() {
        addSubview(overlayView)
    }
    
    func addCloseButton(){
        closeButton = UIButton()
        closeButton!.setTitle(L10n.tutorialCerrar, for: .normal)
        closeButton!.backgroundColor = UIColor(named: .clearGrayChat)
        closeButton!.setTitleColor(.black, for: .normal)
        closeButton!.layer.cornerRadius = 6.0
        closeButton!.translatesAutoresizingMaskIntoConstraints = false
        closeButton!.titleLabel?.font = UIFont(font: FontFamily.Akkurat.regular, size: 19.0)
        
        self.addSubview(closeButton!)
        
        let horConstraint = NSLayoutConstraint(item: closeButton!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: closeButton!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -20.0)
        
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: closeButton!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        
        let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: closeButton!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
        
        closeButton!.addConstraints([heightConstraint, widthConstraint])
        
        self.addConstraints([horConstraint, verConstraint])
    }
    
    func setupConstraints() {
        let views = ["overlayView": overlayView]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlayView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func makeOverlay() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }
    
    func registerForOrientationChanges() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(TutorialView.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func unregisterFromOrientationChanges() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func orientationChanged() {
        setNeedsDisplay()
    }
    
    func removeOverlaySublayers() {
        guard let overlaySublayers = overlayView.layer.sublayers else { return }
        
        overlaySublayers.forEach { $0.removeFromSuperlayer() }
    }

    open func cutHolesForViewDescriptors(_ views: [TutorialItem]) {
        availableViews = views
        setNeedsDisplay()
        addDescriptions()
    }
    
}
