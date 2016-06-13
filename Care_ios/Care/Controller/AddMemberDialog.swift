//
//  AddMemberDialog.swift
//  Care
//
//  Created by niko on 15/8/24.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit
import QuartzCore

class AddMemberDialog: UIView,UITextFieldDelegate {
    
    
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var choseIdentityBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var identityText: UITextFieldEx!
    @IBOutlet weak var nameText: UITextFieldEx!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        var view = NSBundle.mainBundle().loadNibNamed("AddMemberDialog", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        nameText.delegate = self
        sureBtn.titleLabel?.sizeToFit()
        identityText.setPadding(true, top: 3, right: 3, bottom: 5, left: 13)
        nameText.setPadding(true, top: 3, right: 3, bottom: 5, left: 13)
        cancelBtn.backgroundColor = UIColor(red: 216/255.0, green: 110/255.0, blue: 106/255.0, alpha: 1)
        sureBtn.titleLabel?.textColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        cancelBtn.titleLabel?.textColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        identityText.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        nameText.textColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        nameLabel.textColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        identityLabel.textColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
        nameText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func selectBtnClicked(sender: AnyObject) {
        nameText.resignFirstResponder()
    }
    
    @IBAction func viewTouched(sender: AnyObject) {
        nameText.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(textField: UITextField) {
        if textField == nameText {
            if count(textField.text) > 10 {
                textField.text = (textField.text as NSString).substringToIndex(10)
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var bChange = true
        if string == "\n" {
            return true
        }
        if count(textField.text) > 9 {
            bChange = false
        }
        if range.length == 1 {
            bChange = true
        }
        return bChange
    }
}

class UITextFieldEx :UITextField {
    var isEnablePadding = true
    var paddingLeft:CGFloat?
    var paddingRight:CGFloat?
    var paddingTop:CGFloat?
    var paddingBottom:CGFloat?
    
    func setPadding(enable:Bool,top:CGFloat,right:CGFloat,bottom:CGFloat,left:CGFloat){
        isEnablePadding = enable
        paddingTop = top
        paddingRight = right
        paddingBottom = bottom
        paddingLeft = left
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        if isEnablePadding {
            return CGRectMake(bounds.origin.x + paddingLeft!, bounds.origin.y + paddingTop!, bounds.size.width - paddingRight!, bounds.size.height - paddingBottom!)
        }else{
            return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height)
        }
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }
}


