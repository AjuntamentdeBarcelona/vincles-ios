//
//  TutorialViewController.swift
//  Vincles BCN
//
//  Copyright © 2018 i2Cat. All rights reserved.


import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var fourthImage: UIImageView!
    @IBOutlet weak var fifthImage: UIImageView!

    override func viewWillAppear(_ animated: Bool)
{
    super.viewWillAppear(animated)

        UIApplication.shared.isStatusBarHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.isStatusBarHidden = false

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        closeButton.setTitle(L10n.tancar, for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(TutorialViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

       
        setImages()
        // Do any additional setup after loading the view.
    }
    
    func setImages(){
        
        var orientation = ""
        var platform = ""
        var lang = ""
        


        orientation = "portrait"

        if view.frame.width > view.frame.height{
            orientation = "landscape"
        }
        
        if (UIDevice.current.userInterfaceIdiom == .phone){
            platform = "Mobile"
        }
        else{
            platform = "Tablet"
        }
        
        
            if(UserDefaults.standard.string(forKey: "i18n_language") == "es"){
                lang = "cast"
            }
            else{
                lang = "cat"
            }
        
        print("\(platform)_1_\(orientation)_\(lang)")
        firstImage.image = UIImage(named: "\(platform)_1_\(orientation)_\(lang)")
        secondImage.image = UIImage(named: "\(platform)_2_\(orientation)_\(lang)")
        thirdImage.image = UIImage(named: "\(platform)_3_\(orientation)_\(lang)")
        fourthImage.image = UIImage(named: "\(platform)_4_\(orientation)_\(lang)")
        fifthImage.image = UIImage(named: "\(platform)_5_\(orientation)_\(lang)")
    }
    
    
    @objc func rotated() {

        Timer.after(0.2.seconds) {
            self.setImages()
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.size.width * CGFloat(self.pageControl.currentPage), y: 0), animated: false)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
