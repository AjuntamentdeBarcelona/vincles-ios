//
//  HoverButton.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class HoverButton: UIButton {
    
    var greenMode: Bool = false{
        didSet{
            if greenMode == true{
                self.layer.borderColor = UIColor(named: .acceptGreen).cgColor
                self.tintColor = UIColor(named: .acceptGreen)
                self.setTitleColor(UIColor(named: .acceptGreen), for: .normal)
            }
            else{
                self.layer.borderColor = UIColor(named: .darkRed).cgColor
                self.tintColor = UIColor(named: .darkRed)
                self.setTitleColor(UIColor(named: .darkRed), for: .normal)

            }
          
        }
    }
    
    override func awakeFromNib() {
        self.backgroundColor = .white
        
        self.layer.borderColor = UIColor(named: .darkRed).cgColor
        
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 12
        self.tintColor = UIColor(named: .darkRed)
        self.setTitleColor(UIColor(named: .darkRed), for: .normal)
        self.setTitleColor(.white, for: .highlighted)
        self.imageView?.contentMode = .scaleAspectFit
        self.adjustsImageWhenHighlighted = false
        
        if (self.title(for: .normal)?.isEmpty) != nil{
            if (self.title(for: .normal)?.isEmpty)! || self.imageView?.image == nil{
                self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                
            }
            else{
                self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
                self.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
            }
        }
        if greenMode{
            self.layer.borderColor = UIColor(named: .acceptGreen).cgColor
            self.tintColor = UIColor(named: .acceptGreen)
            self.setTitleColor(UIColor(named: .acceptGreen), for: .normal)
        }
        
    }
    
    override var isHighlighted: Bool{
        didSet{
            isHighlighted ? (self.backgroundColor = UIColor(named: .darkRed)) : (self.backgroundColor = .white)
            isHighlighted ? (self.tintColor = .white) : (self.tintColor = UIColor(named: .darkRed))
            if greenMode{
                isHighlighted ? (self.backgroundColor = UIColor(named: .acceptGreen)) : (self.backgroundColor = .white)
                isHighlighted ? (self.tintColor = .white) : (self.tintColor = UIColor(named: .acceptGreen))
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()


        if (self.title(for: .normal)?.isEmpty) != nil{
            if (self.title(for: .normal)?.isEmpty)! || self.imageView?.image == nil{
                self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                
            }
            else{
                self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
                self.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
            }
        }


    }

}
