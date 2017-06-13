/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import UIKit

class MsgPagerVC: VinclesVC {
    
    @IBOutlet weak var video: UIButton!
    @IBOutlet weak var photo: UIButton!
    @IBOutlet weak var text: UIButton!

    @IBOutlet weak var container: UIView!
    
    var index = 0
    
    lazy var videoViewController: MgVideoVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewControllerWithIdentifier("MgVideoVC") as! MgVideoVC
        
        // Add View Controller as Child View Controller
        self.addViewControllerAsChildViewController(viewController)
        
        return viewController
    }()
    
    lazy var photoViewController: MgFotoVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewControllerWithIdentifier("MgFotoVC") as! MgFotoVC
        
        // Add View Controller as Child View Controller
        self.addViewControllerAsChildViewController(viewController)
        
        return viewController
    }()
    
    lazy var textViewController: MgTextVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewControllerWithIdentifier("MgTextVC") as! MgTextVC
        
        // Add View Controller as Child View Controller
        self.addViewControllerAsChildViewController(viewController)
        
        return viewController
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = NOUMISSATGE_VC
        setupView()
    }
    
    // MARK: - View Methods
    
    func setupView() {
        updateView()
    }
    
    func updateView() {
        videoViewController.view.hidden = !(index == 0)
        photoViewController.view.hidden = !(index == 1)
        textViewController.view.hidden = !(index == 2)
        
        switch index {
        case 0: // video selected
            video.backgroundColor = UIColor(hexString: "C41018")
            photo.backgroundColor = UIColor(hexString: "626E6E")
            text.backgroundColor = UIColor(hexString: "626E6E")
            break
        case 1: // photo selected
            video.backgroundColor = UIColor(hexString: "626E6E")
            photo.backgroundColor = UIColor(hexString: "C41018")
            text.backgroundColor = UIColor(hexString: "626E6E")
            break
        case 2: // text selected
            video.backgroundColor = UIColor(hexString: "626E6E")
            photo.backgroundColor = UIColor(hexString: "626E6E")
            text.backgroundColor = UIColor(hexString: "C41018")
            break
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @IBAction func videoButtonPressed(sender: AnyObject) {
        if index != 0 {
            index = 0
            updateView()
        }
        
    }
    
    @IBAction func photoButtonPressed(sender: AnyObject) {
        if index != 1 {
            index = 1
            updateView()
        }
    }
    
    @IBAction func textButtonPressed(sender: AnyObject) {
        if index != 2 {
            index = 2
            updateView()
        }
    }
    
    func selectionDidChange(sender: UISegmentedControl) {
        updateView()
    }
    
    // MARK: - Helper Methods
    
    private func addViewControllerAsChildViewController(viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        container.addSubview(viewController.view)
        
        // Configure Child View
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        var views = [String:AnyObject]()
        views["childview"] = viewController.view
        
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(-20)-[childview]-(-20)-|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[childview]-0-|", options: [], metrics: nil, views: views))
        
        // Notify Child View Controller
        viewController.didMoveToParentViewController(self)
    }
    
    private func removeViewControllerAsChildViewController(viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMoveToParentViewController(nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
}
