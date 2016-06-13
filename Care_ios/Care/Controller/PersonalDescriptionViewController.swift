//
//  PersonalDescriptionViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-30.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PersonalDescriptionViewController: BaseViewController,UITextViewDelegate {


    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var conform: UIButton!
    @IBOutlet weak var textView: UITextView!
    var controller:UserProfileViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        setTittle("个人简介")
        textView.delegate = self
        textView.text = ComFqLibToolsConstants.getUser().getDescription()
        var size = 100 - NSString(string: ComFqLibToolsConstants.getUser().getDescription()).length
        var i = self.navigationController!.viewControllers.count-2
        controller =  self.navigationController!.viewControllers[i] as! UserProfileViewController
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        var description = textView.text
        ComFqLibToolsConstants.getUser().setDescriptionWithNSString(description)
        ComFqLibToolsUserProfileManager.instance().reqModyDes()
        
        controller.userDetail.text = description
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "PersonalDescriptionViewController"
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textViewDidChange(textView: UITextView) {
        var size = 100 - NSString(string: textView.text).length
        //when the text is longer than 500
        if (100 - NSString(string: textView.text).length) < 0 {
            var str = textView.text
            let index1 = advance(str.endIndex, 100 - NSString(string: textView.text).length)
            self.textView.text = str.substringToIndex(index1)
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}
