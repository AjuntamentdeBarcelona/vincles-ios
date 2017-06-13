/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import UIKit

class PageRootViewController: UIViewController,UIPageViewControllerDataSource {
    
    var PageViewController: UIPageViewController!
    var arrPageTitles:[String]!
    var arrPageImgs = ["wizard-phone","wizard-messages","wizard-calendar"]
    
    let bundle:NSBundle = {
        let nsusr = NSUserDefaults.standardUserDefaults()
        let lang = nsusr.valueForKey("language") as! [NSString:Int]
        var langu = ""
        if lang["CatCast"] == 0 {
            langu = "ca-ES"
        }else{
            langu = "es"
        }
        let path = NSBundle.mainBundle().pathForResource(langu, ofType: "lproj")
        let bundl = NSBundle(path: path!)
        
        return bundl!
    }()

    
    @IBOutlet weak var skipTutoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrPageTitles = [bundle.localizedStringForKey("TUTO_TEXT_A", value: nil, table: nil),bundle.localizedStringForKey("TUTO_TEXT_B", value: nil, table: nil),bundle.localizedStringForKey("TUTO_TEXT_C", value: nil, table: nil)]
        
        PageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
        PageViewController?.dataSource = self
        
        let startingViewController = self.viewControllerAtIndex(0)! as UIViewController
        let viewControllers = [startingViewController]
        self.PageViewController?.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        
        self.PageViewController?.view.frame = CGRectMake(0, 0, self.view.frame.size.width,
                                                         self.view.frame.size.height - 100)
        self.addChildViewController(PageViewController!)
        self.view.addSubview((PageViewController.view)!)
        
        self.PageViewController.didMoveToParentViewController(self)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        skipTutoBtn.layer.cornerRadius = 4.0
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        index += 1
        
        if index == arrPageTitles.count {
            return nil
        }
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.arrPageImgs.count == 0) || (index >= self.arrPageImgs.count)) {
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentVC") as! PageContentViewController
        
        pageContentViewController.imgFile = self.arrPageImgs[index]
        pageContentViewController.labelText = self.arrPageTitles[index]
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return arrPageTitles.count
    }
    
    @IBAction func skipTutoBtnPressed(sender: AnyObject) {
        
        
    }
    
}
