//
//  NewGuideViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15-7-31.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class NewGuideViewController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollV:UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
//        pageControl.numberOfPages = 2
//        pageControl.currentPage = 0
        var rect = UIApplication.sharedApplication().statusBarFrame
        scrollV.contentSize = CGSizeMake(ScreenWidth*2, ScreenHeight-rect.height)
        var imgV1 = UIImageView(image: UIImage(named: "photo1"))
        imgV1.frame = CGRectMake(0, -rect.height, ScreenWidth, ScreenHeight)
        var imgV2 = UIImageView(image: UIImage(named: "photo2"))
        imgV2.frame = CGRectMake(ScreenWidth, -rect.height, ScreenWidth, ScreenHeight)
//        var imgV3 = UIImageView(image: UIImage(named: "photo3"))
//        imgV3.frame = CGRectMake(ScreenWidth*2, -rect.height, ScreenWidth, ScreenHeight)
//        var imgV4 = UIImageView(image: UIImage(named: "photo4"))
//        imgV4.frame = CGRectMake(ScreenWidth*3, -rect.height, ScreenWidth, ScreenHeight)
        
//        var btn = UIButton(frame: CGRectMake(ScreenWidth*3.833, (ScreenHeight-rect.height)*0.912, ScreenWidth*0.167, (ScreenHeight-rect.height)*0.088))
        var btn = UIButton(frame: CGRectMake(ScreenWidth + 40,ScreenHeight - 100,ScreenWidth - 80,35))
        btn.setTitle("立即体验", forState: UIControlState.Normal)
        
        btn.titleLabel!.textColor = UIColor.whiteColor()
        btn.titleLabel!.textAlignment = NSTextAlignment.Center
        btn.setBackgroundImage(UITools.imageWithColor(Color.purple) ,forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(Color.darkPurple) ,forState: UIControlState.Highlighted)
        btn.addTarget(self, action: Selector("click:"), forControlEvents: UIControlEvents.TouchUpInside)
        scrollV.delegate = self
        scrollV.pagingEnabled = true
        scrollV.addSubview(imgV1)
        scrollV.addSubview(imgV2)
        UITools.setBtnWithOneRound(btn, corners: UIRectCorner.AllCorners)
//        scrollV.addSubview(imgV3)
//        scrollV.addSubview(imgV4)
        scrollV.addSubview(btn)
    }

    func click(sender:AnyObject){
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "everLaunched")
        self.navigationController?.pushViewController(LoginViewController(nibName:"LoginViewController",bundle:nil), animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        self.scrollV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth = ScreenWidth
        currentPage = Int(floor((self.scrollV.contentOffset.x - pageWidth/2) / pageWidth)) + 1
        pageControl.currentPage = currentPage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
