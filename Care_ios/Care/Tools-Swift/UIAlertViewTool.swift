//
//  UIAlertView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation

class IndetifyDialog:NSObject {
    var alertView:CustomIOS7AlertView?
    var selectBtn:UIButton?
    init(alertView:CustomIOS7AlertView,selectBtn:UIButton) {
        super.init()
        self.alertView = alertView
        self.selectBtn = selectBtn
    }
}


class UIAlertViewTool:NSObject{
    var dia:CustomIOS7AlertView?
    var navi:UINavigationController?
    var loadingDialog:CustomIOS7AlertView!
    class func getInstance()->UIAlertViewTool{
        struct Singleton{
            static var predicate:dispatch_once_t = 0
            static var instance:UIAlertViewTool? = nil
        }
        
        dispatch_once(&Singleton.predicate,{
            Singleton.instance = UIAlertViewTool()
        })
        return Singleton.instance!
    }
    
    /**弹出自动关闭的dialog**/
    func showAutoDismisDialog(str:String,width:CGFloat = 210,height:CGFloat = 120){
        var dialog = CustomIOS7AlertView()
        var label = UILabel()
        label.frame.size = CGSizeMake(width, height)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(15.0)
        label.textColor = UIColor.grayColor()
        label.text = str
        dialog.containerView = label
        dialog.show()
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector:"closeDialog:", userInfo: dialog
            , repeats: false)
        
    }
    
    
    /**弹出扫一扫dialog**/
    func showZbarDialog(str:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector,actionOkStr:String = "确认",actionCancelStr:String = "取消") ->CustomIOS7AlertView {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        var label = UILabel(frame: CGRectMake(10, 0, 230, 109))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = str
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        var size = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 109)
        
        var labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine.backgroundColor = UIColor.grayColor()
        
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(30, 115, 90, 23))
//        var maskPath = UIBezierPath(roundedRect: btnSure.bounds, byRoundingCorners: UIRectCorner.BottomLeft, cornerRadii: CGSizeMake(9, 9))
//        var maskLayer = CAShapeLayer()
//        maskLayer.frame = btnSure.bounds
//        maskLayer.path = maskPath.CGPath
//        btnSure.layer.mask = maskLayer
        btnSure.setTitle(actionOkStr, forState: UIControlState.Normal)
        btnSure.titleLabel?.textColor = UIColor.whiteColor()
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple) ,forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.darkPurple) ,forState: UIControlState.Highlighted)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        var btnCancle = UIButton(frame: CGRectMake(130, 115, 90, 23))
        btnCancle.setTitle(actionCancelStr, forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.pink), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.darkPink), forState: UIControlState.Highlighted)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(14)
//        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
//        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        
        tmpView.addSubview(label)
//        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return dialog
    }
    
    /**弹出只有1个按钮的扫一扫dialog**/
    func showZbarDialogWith1Btn(str:String,target: AnyObject?,actionOk: Selector) ->CustomIOS7AlertView {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        UITools.setRoundBounds(5.0, view: tmpView)
        tmpView.backgroundColor = UIColor(red: 53/255.0, green: 56/255.0, blue: 66/255.0, alpha: 1)
        var label = UILabel(frame: CGRectMake(0, 15, 250, 85))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = str
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        var size = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 109)
        
//        var labelLine = UILabel(frame: CGRectMake(0, 109, 300, 1))
//        labelLine.backgroundColor = Color.color_emerald
        
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(35, 100, 180, 30))
//        var maskPath = UIBezierPath(roundedRect: btnSure.bounds, byRoundingCorners: UIRectCorner.BottomLeft, cornerRadii: CGSizeMake(9, 9))
//        var maskLayer = CAShapeLayer()
//        maskLayer.frame = btnSure.bounds
//        maskLayer.path = maskPath.CGPath
//        btnSure.layer.mask = maskLayer
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.textColor = UIColor.whiteColor()
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple) ,forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.darkPurple) ,forState: UIControlState.Highlighted)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
//        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft | UIRectCorner.BottomRight)
        //        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomRight)
        
        tmpView.addSubview(label)
//        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        dialog.containerView = tmpView
        dialog.show()
        return dialog
    }
    
    var showSelectionRadioBtn = UIImageView()
    
    /**弹出去身份化dialog**/
    func showSelectionDialog(title:String,str:String,target: AnyObject?,actionSwitch:Selector,actionBtn:Selector,imageView:UIImageView,actionOk: Selector,actionCancle: Selector,actionOkStr:String = "发送",actionCancelStr:String = "取消") ->CustomIOS7AlertView {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        var titleLabel = UILabel(frame: CGRectMake(0, 10, 250, 30))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFontOfSize(16)
        
        var label = UILabel(frame: CGRectMake(0, 50, 250, 20))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.grayColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(11)
        
        
        var lengthOfString :NSInteger = count(str)
        var cg = CGFloat(NSInteger(lengthOfString))
        println(cg)
//        var img = UIImage(named:"icon_circle_yes")
        
//        if state{
//            img = UIImage(named:"icon_circle_yes")
//        }else {
//            img = UIImage(named:"icon_circle_no")
//        }
        showSelectionRadioBtn = imageView
        showSelectionRadioBtn.frame = CGRectMake(113-cg*6,54,12,12)
        var withInfoBtn = UIButton(frame:CGRectMake(95-cg*6, 40, cg*12+60, 35))
        withInfoBtn.addTarget(target, action: actionSwitch, forControlEvents: UIControlEvents.TouchUpInside)
//        withInfoBtn.backgroundColor = UIColor.grayColor()
//        withInfoBtn.alpha = 0.3
        var clickLabel = UILabel(frame: CGRectMake(15, 75, 220, 35))
        clickLabel.font = UIFont.systemFontOfSize(11)
        clickLabel.textAlignment = NSTextAlignment.Center
        clickLabel.textColor = Color.darkPurple
        clickLabel.text = "请确认发送该记录不会涉及您或者第三方的隐私，详情请查看《隐私条款》"
        clickLabel.numberOfLines = 0
        clickLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(clickLabel.frame.size.width, CGFloat(MAXFLOAT))
        var size = clickLabel.sizeThatFits(makeSize)
        
        var secretProtocol = UIButton(frame:CGRectMake(15, 75, 220, 35))
        secretProtocol.addTarget(target,action:actionBtn,forControlEvents: UIControlEvents.TouchUpInside)
        //        clickLabel.frame = CGRectMake(clickLabel.frame.origin.x, clickLabel.frame.origin.y, clickLabel.frame.size.width, 109)
        
        var labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine.backgroundColor = UIColor.grayColor()
        
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
        
        btnSure.setTitle(actionOkStr, forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
        btnSure.titleLabel?.textColor = UIColor.whiteColor()
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        var btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
        btnCancle.setTitle(actionCancelStr, forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        
        tmpView.addSubview(titleLabel)
        tmpView.addSubview(label)
        tmpView.addSubview(showSelectionRadioBtn)
        tmpView.addSubview(withInfoBtn)
        tmpView.addSubview(secretProtocol)
        tmpView.addSubview(clickLabel)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return dialog
    }
    
    /**弹出输入框dialog**/
    func showTextFieldDialog(title:String,hint:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textField:UITextField?) {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 300, 130))
        //title
        var label = UILabel(frame: CGRectMake(0, 5, 300, 30))
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        //输入框
        var textField = UITextField(frame: CGRectMake(15 , 40, 270, 30))
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = hint
        //线条
        var labelLine = UILabel(frame: CGRectMake(0, 89, 300, 1))
        labelLine.backgroundColor = Color.color_emerald
        
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(0, 90, 150, 40))
        btnSure.setTitle("确定", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 102/255, green: 186/255, blue: 168/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.color_emerald), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 20/255, green: 144/255, blue: 128/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        var btnCancle = UIButton(frame: CGRectMake(150, 90, 150, 40))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textField)
        tmpView.addSubview(label)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return (dialog,textField)
    }
    
    /**弹出输入框dialog2**/
    func showNewTextFieldDialog(title:String,hint:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textField:UITextField?) {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        //title
        var label = UILabel(frame: CGRectMake(0, 5, 250, 30))
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        //输入框
        var textField = UITextField(frame: CGRectMake(30 , 20, 190, 30))
        textField.text = hint
        textField.font = UIFont.systemFontOfSize(15)
        textField.textAlignment = NSTextAlignment.Center
        var underLine = UILabel(frame: CGRectMake(30, 45, 190, 1))
        underLine.backgroundColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1)
//        //线条
//        var labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
//        labelLine.backgroundColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1)
        
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(30, 115, 90, 23))
        btnSure.setTitle("确定", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        btnSure.setTitleColor(UIColor(red: 102/255, green: 186/255, blue: 168/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.darkPurple), forState: UIControlState.Highlighted)
        
//        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        var btnCancle = UIButton(frame: CGRectMake(130, 115, 90, 23))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.pink), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.darkPink), forState: UIControlState.Highlighted)
        
//        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textField)
        tmpView.addSubview(label)
//        tmpView.addSubview(labelLine)
//        tmpView.addSubview(underLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return (dialog,textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        var lengthOfString :NSInteger = count(string)
        var fieldTextString : String = textField.text
        // Check for total length
        var proposedNewLength : Int = count (fieldTextString) - range.length + lengthOfString;
        var maxNum = 15
        if (proposedNewLength > maxNum)
        {
            return false//限制长度
        }
        return true
    }
    
    /**弹出换行输入框dialog,添加好友使用**/
    func showTextViewdDialog(detail:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextView?) {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 280, 150))
        
        //输入框
        var textview = UITextView(frame: CGRectMake(40 , 20, 200, 70))
        textview.font = UIFont.systemFontOfSize(14)
        textview.textColor = UIColor.darkGrayColor()
        textview.text = detail
        

        
 
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(40, 105, 95, 30))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1)), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 0.8)), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        var btnCancle = UIButton(frame: CGRectMake(145, 105, 95, 30))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnCancle.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 240/255.0, green: 87/255.0, blue: 89/255.0, alpha: 1)), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 240/255.0, green: 87/255.0, blue: 89/255.0, alpha: 0.8)), forState: UIControlState.Highlighted)

        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textview)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return (dialog,textview)
    }
    
    /**弹出不换行输入框dialog，输入控件为textview**/
    func showTextViewdDialog2(detail:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextView?) {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        //输入框
        var textview = UITextView(frame: CGRectMake(0 , 40, 250, 35))
        textview.font = UIFont.systemFontOfSize(15)
        textview.textColor = UIColor.whiteColor()
        textview.textAlignment = NSTextAlignment.Center
        textview.text = detail
        textview.backgroundColor = UIColor(red: 48/255.0, green: 53/255.0, blue: 63/255.0, alpha: 1.0)
        

        
        
        //线条
        var labelLine = UILabel(frame: CGRectMake(35, 67, 180, 1))
        labelLine.backgroundColor = UIColor.lightGrayColor()
        
       // 线条
        var labelLine1 = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine1.backgroundColor = UIColor.lightGrayColor()
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(30, 115, 90, 23))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.darkPurple), forState: UIControlState.Highlighted)
        
//        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        var btnCancle = UIButton(frame: CGRectMake(130, 115, 90, 23))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnCancle.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.pink), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.darkPink), forState: UIControlState.Highlighted)
        
//        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textview)
        tmpView.addSubview(labelLine)
       // tmpView.addSubview(labelLine1)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return (dialog,textview)
    }
 
    
    
    
    /**弹出loading的dialog**/
    func showLoadingDialog(str:String) ->CustomIOS7AlertView{
        if loadingDialog == nil{
            loadingDialog = CustomIOS7AlertView()
        }
        loadingDialog.containerView = LoadingView(frame: CGRectMake(0, 0, 210, 120), msg: str)//300 150
        loadingDialog.show()
        return loadingDialog
    }
    
    /**消息提示dialog**/
    func showDelDialog(str:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->CustomIOS7AlertView {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 280, 150))
        
        var label = UILabel(frame: CGRectMake(0, 0, 280, 109))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.blackColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(20)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        var size = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 99)
        
        var labelLine = UILabel(frame: CGRectMake(0, 99, 280, 1))
        labelLine.backgroundColor = UIColor.lightGrayColor()
        
        UIButton.buttonWithType(UIButtonType.Custom)
        
        var btnSure = UIButton(frame: CGRectMake(0, 100, 140, 50))
        btnSure.setTitle("确定", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.color_violet), forState: UIControlState.Normal)
//        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        var btnCancle = UIButton(frame: CGRectMake(140, 100, 140, 50))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
//        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(label)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return dialog
    }
    
    /**一条label提示dialog*/
    func showNewDelDialog(str:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->CustomIOS7AlertView {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        var label = UILabel(frame: CGRectMake(0, 10, 250, 35))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(15)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        var size = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 99)
        
        UIButton.buttonWithType(UIButtonType.Custom)
        
        
        
        
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(30, 115, 90, 23))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.darkPurple), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        var btnCancle = UIButton(frame: CGRectMake(130, 115, 90, 23))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnCancle.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.pink), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(Color.darkPink), forState: UIControlState.Highlighted)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(label)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return dialog
    }
    
    /**一条label提示dialog*/
    func showAlertDialog(str:String,target: AnyObject?,actionOk: Selector) ->CustomIOS7AlertView {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        var label = UILabel(frame: CGRectMake(0, 10, 250, 35))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(15)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        var size = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 99)
        
        UIButton.buttonWithType(UIButtonType.Custom)
        
        
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(30, 115, 190, 23))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.darkPurple), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(label)
        tmpView.addSubview(btnSure)
        dialog.containerView = tmpView
        dialog.show()
        return dialog
    }

    
    func showRegisterDialog(str:String,nav:UINavigationController) ->CustomIOS7AlertView {
        dia = CustomIOS7AlertView()
        navi = nav
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        var label = UILabel(frame: CGRectMake(0, 10, 250, 35))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.blackColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        var size = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 99)
        
        var labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine.backgroundColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1)
        
        UIButton.buttonWithType(UIButtonType.Custom)
        
        var btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
        btnSure.setTitle("注册", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //        btnSure.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
        //        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(self, action: "registerClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        var btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(self, action: "cancle:", forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(label)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dia!.containerView = tmpView
        dia!.show()
        return dia!
    }
    
    func registerClick(sender:AnyObject){
        dia?.close()
//        ComFqLibToolsTool.clearUserData()
        navi!.pushViewController(RegisterViewController(), animated: true)
    }
    
    func cancle(sender:AnyObject){
        dia?.close()
    }

    
    /**设置标签dialog**/
    func showTagDialog(str:String,target: AnyObject?,actionOk: Selector) ->CustomIOS7AlertView {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 280, 150))
        
        var label = UILabel(frame: CGRectMake(0, 0, 280, 109))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = Color.color_yellow
        label.text = str
        label.font = UIFont.systemFontOfSize(28)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        var size = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 99)
        
        var labelLine = UILabel(frame: CGRectMake(0, 99, 280, 1))
        labelLine.backgroundColor = Color.color_emerald
        
        UIButton.buttonWithType(UIButtonType.Custom)
        
        var btnSure = UIButton(frame: CGRectMake(0, 100, 280, 50))
        btnSure.setTitle("设置标签", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(26)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 102/255, green: 186/255, blue: 168/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 41/255, green: 47/255, blue: 120/255, alpha: 1)), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 20/255, green: 144/255, blue: 128/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setButtonWithBackGroundColor(ColorType.EMERALD, btn: btnSure, isOpposite: false)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomRight | UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(label)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        dialog.containerView = tmpView
        dialog.show()
        return dialog
    }

    /**弹出多行输入框dialog**/
    func showMutiTextViewdDialog(xmName:String,value:String,unit:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextField?,textview1:UITextField?,textview2:UITextField?) {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 300, 160))
        var label = UILabel(frame: CGRectMake(30, 25, 50, 20))
        label.text = "项目:"
        //输入框
        var textview = UITextField(frame: CGRectMake(85 ,25, 180, 20))
        textview.font = UIFont.systemFontOfSize(16)
        textview.textColor = UIColor.lightGrayColor()
        textview.text = xmName
        
        //线条
        var labelLine4 = UILabel(frame: CGRectMake(85, 45, 180, 1))
        labelLine4.backgroundColor = UIColor.lightGrayColor()
        var label1 = UILabel(frame: CGRectMake(30, 50, 50, 20))
        label1.text = "结果:"
        //输入框
        var textview1 = UITextField(frame: CGRectMake(85 , 50, 180, 20))
        textview1.font = UIFont.systemFontOfSize(16)
        textview1.textColor = UIColor.lightGrayColor()
        textview1.text = value
        
        //线条
        var labelLine1 = UILabel(frame: CGRectMake(85, 70, 180, 1))
        labelLine1.backgroundColor = UIColor.lightGrayColor()
        var label2 = UILabel(frame: CGRectMake(30, 75, 50, 20))
        label2.text = "单位:"
        //输入框
        var textview2 = UITextField(frame: CGRectMake(85 ,75, 180, 20))
        textview2.font = UIFont.systemFontOfSize(16)
        textview2.textColor = UIColor.lightGrayColor()
        textview2.text = unit
        
        //线条
        var labelLine2 = UILabel(frame: CGRectMake(85, 95, 180, 1))
        labelLine2.backgroundColor = UIColor.lightGrayColor()
        
        //线条
        var labelLine3 = UILabel(frame: CGRectMake(0, 119, 300, 1))
        labelLine3.backgroundColor = UIColor.lightGrayColor()
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(0, 120, 150, 40))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(20)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.color_violet), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 84/255, green: 89/255, blue: 147/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        var btnCancle = UIButton(frame: CGRectMake(150, 120, 150, 40))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.lightGrayColor()), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(textview)
        tmpView.addSubview(textview1)
        tmpView.addSubview(textview2)
        tmpView.addSubview(labelLine3)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        
        tmpView.addSubview(label)
        tmpView.addSubview(label1)
        tmpView.addSubview(label2)
        tmpView.addSubview(labelLine1)
        tmpView.addSubview(labelLine2)
        tmpView.addSubview(labelLine4)
        dialog.containerView = tmpView
        dialog.show()
        return (dialog,textview,textview1,textview2)
    }
    
    func closeDialog(timer:NSTimer){
        (timer.userInfo as? CustomIOS7AlertView)?.close()
        timer.invalidate()
    }
    
    
    
    func showRemoveIndetifyDialog(didSendInfo:Bool,target: AnyObject?,actionOk: Selector,actionCancle: Selector,actionRemoveIndentify:Selector,selecBtn:Selector) ->IndetifyDialog{
        var dialog = CustomIOS7AlertView()
        var str = "发送时包含身份信息"
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        //title
        var titleLabel = UILabel(frame: CGRectMake(0, 10, 250, 30))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.text = "是否要去身份化？"
        titleLabel.font = UIFont.systemFontOfSize(16)
        //可选择的label
        var label = UILabel(frame: CGRectMake(0, 50, 250, 20))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.grayColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(11)
        
        //图标
        var lengthOfString :NSInteger = count(str)
        var cg = CGFloat(NSInteger(lengthOfString))
        var selectBtn:UIButton = UIButton()
        if didSendInfo{
            selectBtn.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
        }else{
            selectBtn.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
        }
        selectBtn.addTarget(target,action:selecBtn,forControlEvents: UIControlEvents.TouchUpInside)
        selectBtn.frame = CGRectMake((113-cg*6),54,12,12)
        //供选择的button点击  透明
        var withInfoBtn = UIButton(frame:CGRectMake(50, 40, 150, 40))
        withInfoBtn.addTarget(target,action:selecBtn,forControlEvents: UIControlEvents.TouchUpInside)
        var clickLabel = UILabel(frame: CGRectMake(15, 75, 220, 35))
        clickLabel.font = UIFont.systemFontOfSize(11)
        clickLabel.textAlignment = NSTextAlignment.Center
        clickLabel.textColor = Color.darkPurple
        clickLabel.text = "请确认发送该记录不会涉及您或者第三方的隐私，详情请查看《隐私条款》"
        clickLabel.numberOfLines = 0
        clickLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var makeSize = CGSizeMake(clickLabel.frame.size.width, CGFloat(MAXFLOAT))
        var size = clickLabel.sizeThatFits(makeSize)
        
        var secretProtocol = UIButton(frame:CGRectMake(15, 75, 220, 35))
        secretProtocol.addTarget(target,action:actionRemoveIndentify,forControlEvents: UIControlEvents.TouchUpInside)
        
        var labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine.backgroundColor = UIColor.grayColor()
        //确定btn
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
        
        btnSure.setTitle("发送", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
        btnSure.titleLabel?.textColor = UIColor.whiteColor()
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        //取消btn
        var btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        
        
        tmpView.addSubview(titleLabel)
        tmpView.addSubview(label)
        tmpView.addSubview(selectBtn)
        tmpView.addSubview(withInfoBtn)
        tmpView.addSubview(secretProtocol)
        tmpView.addSubview(clickLabel)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.containerView = tmpView
        dialog.show()
        return IndetifyDialog(alertView: dialog,selectBtn: selectBtn)
    }

    /**弹出换行输入框dialog**/
    func showCreateTextViewdDialog(detail:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextField?) {
        var dialog = CustomIOS7AlertView()
        var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        //输入框
        var textview = UITextField(frame: CGRectMake(20 , 40, 210, 30))
        textview.font = UIFont.systemFontOfSize(16)
        textview.textColor = UIColor.lightGrayColor()
        textview.text = detail
        
        //线条
        var labelLine = UILabel(frame: CGRectMake(15, 70, 220, 1))
        labelLine.backgroundColor = UIColor.lightGrayColor()
        
        //线条
        var labelLine1 = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine1.backgroundColor = UIColor.lightGrayColor()
        //确定
        UIButton.buttonWithType(UIButtonType.Custom)
        var btnSure = UIButton(frame: CGRectMake(0, 120, 125, 35))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        var btnCancle = UIButton(frame: CGRectMake(125, 120, 125, 35))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textview)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(labelLine1)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        tmpView.backgroundColor = UIColor.redColor()
        dialog.containerView = tmpView
        dialog.show()
        return (dialog,textview)
    }
    
    
    func showAddViewdDialog(target: AnyObject?,actionChose: Selector,actionOk: Selector,actionCancle: Selector) ->(alertDialog:CustomIOS7AlertView?,addMemberDialog:AddMemberDialog?) {
        var dialog = CustomIOS7AlertView()
        var tmpView = AddMemberDialog(frame: CGRectMake(0 , 0, ScreenWidth/5 * 4, ScreenHeight/4.2))
        tmpView.sureBtn.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        tmpView.cancelBtn.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        tmpView.choseIdentityBtn.addTarget(target, action: actionChose, forControlEvents: UIControlEvents.TouchUpInside)
        dialog.containerView = tmpView
        return (dialog,tmpView)
    }
}