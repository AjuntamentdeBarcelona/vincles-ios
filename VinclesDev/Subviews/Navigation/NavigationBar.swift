//
//  NavigationBar.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class NavigationBar: UIView {

    var xibView: UIView?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var buttonsTop: NSLayoutConstraint!

    var rightTitle: String?{
        didSet{
            setButtonsLayout()
        }
    }
    
    var leftTitle: String?{
        didSet{
            setButtonsLayout()
        }
    }
    
    var leftImage: UIImage?{
        didSet{
            setButtonsLayout()
        }
    }
    var rightImage: UIImage?{
        didSet{
            setButtonsLayout()
        }
    }

    var leftHightlightedImage: UIImage?{
        didSet{
            setButtonsLayout()
        }
    }
    var rightHightlightedImage: UIImage?{
        didSet{
            setButtonsLayout()
        }
    }
    
    var navTitle: String?{
        didSet{
            titleLabel.text = navTitle
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibView = Bundle.main.loadNibNamed("NavigationBar", owner: self, options: nil)!.first as? UIView
        xibView!.frame = self.bounds
        self.addSubview(xibView!)
        
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftButton.imageView?.contentMode = .scaleAspectFit
        rightButton.imageView?.contentMode = .scaleAspectFit
        if UIDevice.current.userInterfaceIdiom == .phone {
            titleLabel.font = UIFont(font: FontFamily.AkkuratBold.bold, size: 16.0)
            buttonsTop.constant = 7
        }
        
        setButtonsLayout()
        xibView?.layoutSubviews() 
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        displayTraitCollection()
    }

    func displayTraitCollection(){
        setButtonsLayout()
    }
    
    func setButtonsLayout(){
        leftButton.isHidden = leftTitle == nil
        rightButton.isHidden = rightTitle == nil

        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular{
            leftButton.setTitle("", for: .normal)
            rightButton.setTitle("", for: .normal)
            rightButton.semanticContentAttribute = .forceLeftToRight
        } else {
            rightButton.semanticContentAttribute = .forceRightToLeft
            
            if let leftButtonTitle = leftTitle{
                leftButton.setTitle(leftButtonTitle, for: .normal)
            }
            if let rightButtonTitle = rightTitle{
                rightButton.setTitle(rightButtonTitle, for: .normal)
            }
            
          
        }
        if let leftButtonImage = leftImage{
            leftButton.setImage(leftButtonImage, for: .normal)
        }
        if let rightButtonImage = rightImage{
            rightButton.setImage(rightButtonImage, for: .normal)
        }
        
        if let leftButtonHightlightImage = leftHightlightedImage{
            leftButton.setImage(leftButtonHightlightImage, for: .highlighted)
        }
        if let rightButtonHightlightImage = rightHightlightedImage{
            rightButton.setImage(rightButtonHightlightImage, for: .highlighted)
        }
    }
    
}
