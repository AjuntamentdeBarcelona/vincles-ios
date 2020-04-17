//
//  NotificationsView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.



import UIKit

class NotificationsView: UIView {

    @IBOutlet weak var notificationsBubble: CircularView!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var labelAvisos: UILabel!
    @IBOutlet weak var centerBell: NSLayoutConstraint!
    @IBOutlet weak var alignLeftBell: NSLayoutConstraint!

    var xibView: RoundedView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibView = Bundle.main.loadNibNamed("NotificationsView", owner: self, options: nil)!.first as? RoundedView

        xibView!.backgroundColor = UIColor(named: .darkRed)
        xibView!.options = [.topRight]
        xibView!.radius = 20.0

        notificationsBubble!.backgroundColor = UIColor.white
        notificationsBubble!.layer.borderColor = UIColor(named: .darkRed).cgColor
        notificationsBubble!.layer.borderWidth = 2.0
        notificationsLabel!.baselineAdjustment = .alignCenters

        notificationsLabel.textColor = UIColor(named: .darkRed)
        notificationsLabel.text = "0"
        
        let stringValue = L10n.homeAvisos
        let attrString = NSMutableAttributedString(string: stringValue)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0 // change line spacing between paragraph like 36 or 48
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: stringValue.count))
        labelAvisos.attributedText = attrString
        
        xibView!.frame = self.bounds
        xibView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView!)
    }
    
    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad && (UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown)  {
            return UITraitCollection(traitsFrom:[UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        xibView!.options = [ .topRight]
        xibView!.radius = 20.0
        xibView?.layoutSubviews()
        
        
    }
    
}
