//
//  AboutDocPlusViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class AboutDocPlusViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    var isProtocol = false
    @IBOutlet weak var detailTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setTittle("关于医加")
        hiddenRightImage(true)
        if isProtocol == false{
            setTittle("关于HiTales Care")
         titleLabel.text = "关于HiTales Care"
        var path:NSString = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("about_doc_plus.txt")
        var url:NSURL = NSURL.fileURLWithPath(path as String)!
        var data:NSData = NSData(contentsOfURL: url)!
        var str:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        var json:NSMutableDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSMutableDictionary
        var detail:NSString = json.objectForKey("aboutPlus") as! NSString
        detailTextView.text = detail as String
   
        }else{
            titleLabel.text = "HiTales 注册协议"
            var path:NSString = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("register_protocol.txt")
            var url:NSURL = NSURL.fileURLWithPath(path as String)!
            var data:NSData = NSData(contentsOfURL: url)!
            var str:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
            var json:NSMutableDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSMutableDictionary
            var detail:NSString = json.objectForKey("registerProtocol") as! NSString
            detailTextView.text = detail as String
        
        
        
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailTextView.scrollRectToVisible(CGRectMake(0, 0, detailTextView.frame.size.width, detailTextView.frame.size.height), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    override func getXibName() -> String {
        return "AboutDocPlusViewController"
    }


}
