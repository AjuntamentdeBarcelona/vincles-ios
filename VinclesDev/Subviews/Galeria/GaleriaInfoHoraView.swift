//
//  GaleriaInfoHoraView.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class GaleriaInfoHoraView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    
    func initializeSubviews() {
        // below doesn't work as returned class name is normally in project module scope
        /*let viewName = NSStringFromClass(self.classForCoder)*/
        let viewName = "GaleriaInfoHoraView"
        let view: UIView = Bundle.main.loadNibNamed(viewName,owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        timeLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: 19.0)
        
    }
    
    func configWithContent(content: Content){
        
        var size = 15.0
        
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            size = 19.0
        }
        
        timeLabel.font = UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(size))
        
        let lang = UserDefaults.standard.string(forKey: "i18n_language")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: lang!)
        let day = dateFormatter.string(from: content.inclusionTime)
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let hour = dateFormatter.string(from: content.inclusionTime)
        
        let blackAttribute = [ NSAttributedStringKey.font: UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(size)), NSAttributedStringKey.foregroundColor: UIColor.black ] as [NSAttributedStringKey : Any]
        let grayAttribute = [ NSAttributedStringKey.font: UIFont(font: FontFamily.AkkuratLight.light, size: CGFloat(size)), NSAttributedStringKey.foregroundColor: UIColor(named: .darkGray) ] as [NSAttributedStringKey : Any]
        
        let firstString = NSMutableAttributedString(string: day, attributes: blackAttribute)
        
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            firstString.append(NSAttributedString(string: "\n" , attributes: blackAttribute))
        }
        else{
            firstString.append(NSAttributedString(string: " | " , attributes: blackAttribute))
        }
        
        firstString.append(NSAttributedString(string: hour , attributes: grayAttribute))
        
        timeLabel.attributedText = firstString
 
    }
}

