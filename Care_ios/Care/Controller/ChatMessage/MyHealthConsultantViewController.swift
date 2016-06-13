//
//  MyHealthConsultantViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/8/24.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class MyHealthConsultantViewController: UIViewController {
    var currentController:UIViewController!
    var chatListController = MoreChatListViewController()
    var contacts = ContactsViewController()
    @IBOutlet weak var topBarView: UIView!
    
    @IBOutlet weak var allView: UIView!
    var topView:UIView!
    var add:UIButton!
    var chatLabel:UILabel!
    var contactLabel:UILabel!
    var contactBtn :UIButton!
    var chatBtn :UIButton!
    var dialog:CustomIOS7AlertView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tmp = self
        self.addChildViewController(chatListController)
        self.allView.addSubview(chatListController.view)
        currentController = chatListController
        initTopBtn()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendUnReadMessageController", name: "sendUnReadMessageController", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendAddFriendMessageToContact", name: "sendAddFriendMessageToContact", object: nil)
    }
    
    func sendUnReadMessageController(){
        setMsgNumber(MessageTools.getAllMessageCount(), index: 0)
    }
    
    func sendAddFriendMessageToContact(){
        setMsgNumber(receivedMessageCountGlobal, index: 1)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setMsgNumber(unReadMessageCountGlobal, index: 0)
        setMsgNumber(receivedMessageCountGlobal, index: 1)
    }
    
    func setMsgNumber(number:Int,index:Int){
        if index == 0 {
            if number > 99 {
                chatLabel.text = "99+"
                chatLabel.hidden = false
            }else if number > 0 && number <= 99{
                chatLabel.text = "\(number)"
                chatLabel.hidden = false
            }else if number <= 0 {
                chatLabel.hidden = true
            }
            
        }
        if index == 1 {
            if number > 99 {
                contactLabel.text = "99+"
                contactLabel.hidden = false
            }else if number > 0 && number <= 99{
                contactLabel.text = "\(number)"
                contactLabel.hidden = false
            }else if number <= 0 {
                contactLabel.hidden = true
            }
            
        }
    }
    
    func initTopBtn(){
        topView = UIView(frame: CGRectMake(0, 0, ScreenWidth,70))
        topView.backgroundColor = UIColor(patternImage: UIImage(named: "care_bg.png")!)
        self.view.addSubview(topView)
        
        chatBtn = UIButton(frame: CGRectMake(ScreenWidth/2 - 10 - 70, 35, 70, 22))
        chatBtn.setTitle("聊天", forState: UIControlState.Normal)
        chatBtn.setTitleColor(UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1), forState: UIControlState.Highlighted)
        chatBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        chatBtn.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        UITools.setRoundBounds(10.0, view: chatBtn)
        chatBtn.addTarget(self, action: "chatClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        chatLabel = UILabel(frame: CGRectMake(ScreenWidth/2 - 10 - 18,26,18,18))
        chatLabel.backgroundColor = UIColor.redColor()
        //        chatLabel.text = "99+"
        chatLabel.textColor = UIColor.whiteColor()
        chatLabel.font =  UIFont.systemFontOfSize(10.0)
        chatLabel.textAlignment = NSTextAlignment.Center
        UITools.setRoundBounds(9.0, view: chatLabel)
        chatLabel.hidden = true
        
        contactBtn = UIButton(frame: CGRectMake(ScreenWidth/2 + 10 , 35, 70, 22))
        contactBtn.setTitle("联系人", forState: UIControlState.Normal)
        contactBtn.setTitleColor(UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1), forState: UIControlState.Highlighted)
        contactBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        contactBtn.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        contactBtn.backgroundColor = UIColor.whiteColor()
        UITools.setRoundBounds(10.0, view: contactBtn)
        contactBtn.addTarget(self, action: "contactClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        contactLabel = UILabel(frame: CGRectMake(ScreenWidth/2 + 10 + 70 - 18,26,18,18))
        contactLabel.backgroundColor = UIColor.redColor()
        //        contactLabel.text = "99+"
        contactLabel.textColor = UIColor.whiteColor()
        contactLabel.font =  UIFont.systemFontOfSize(10.0)
        UITools.setRoundBounds(9.0, view: contactLabel)
        contactLabel.textAlignment = NSTextAlignment.Center
        contactLabel.hidden = true
        
        add = UIButton(frame: CGRectMake(ScreenWidth - 32 , 38, 15, 15))
        add.setBackgroundImage(UIImage(named: "icon_topright_add.png"), forState: UIControlState.Normal)
        add.addTarget(self, action: "moreChatClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        topView.addSubview(chatBtn)
        topView.addSubview(contactBtn)
        topView.addSubview(chatLabel)
        topView.addSubview(contactLabel)
        topView.addSubview(add)
        add.hidden = true
        
        chatBtn.setTitleColor(UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1), forState: UIControlState.Normal)
        chatBtn.backgroundColor = UIColor.whiteColor()
        contactBtn.setTitleColor( UIColor.whiteColor(), forState: UIControlState.Normal)
        contactBtn.backgroundColor = UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chatClick(sender: UIButton) {
        if currentController == chatListController {
            return
        }
        
        add.hidden = true
        chatBtn.setTitleColor(UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1), forState: UIControlState.Normal)
        chatBtn.backgroundColor = UIColor.whiteColor()
        contactBtn.setTitleColor( UIColor.whiteColor(), forState: UIControlState.Normal)
        contactBtn.backgroundColor = UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1)
        
        self.addChildViewController(chatListController)
        self.transitionFromViewController(currentController, toViewController: chatListController, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil) { (ok) -> Void in
            if ok {
                self.chatListController.didMoveToParentViewController(self)
                self.currentController.willMoveToParentViewController(nil)
                self.currentController.removeFromParentViewController()
                self.currentController = self.chatListController
            }
        }
        
    }
    
    func contactClick(sender:UIButton) {
        if currentController == contacts {
            return
        }
        add.hidden = false
        chatBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        chatBtn.backgroundColor = UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1)
        contactBtn.setTitleColor(UIColor(red: 51/255.0, green: 84/255.0, blue: 96/255.0, alpha: 1), forState: UIControlState.Normal)
        contactBtn.backgroundColor = UIColor.whiteColor()
        
        contacts.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        self.addChildViewController(contacts)
        self.transitionFromViewController(currentController, toViewController: contacts, duration: 0.1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil) { (ok) -> Void in
            if ok {
                self.contacts.didMoveToParentViewController(self)
                self.currentController.willMoveToParentViewController(nil)
                self.currentController.removeFromParentViewController()
                self.currentController = self.contacts
            }
        }
    }
    
    
    func moreChatClick(sender:UIButton) {
        
        if currentController == contacts {
            contacts.onRightBtnOnClick(sender)
        }else{
            //            var defalut = NSUserDefaults.standardUserDefaults()
            //            var right = defalut.boolForKey("first_create_gourp")
            //            if !right {
            //                dialog = UIAlertViewTool.getInstance().showNewDelDialog("您最多只能创建100个群聊哦~", target: self, actionOk: "dialogOK", actionCancle: "dialogCancle")
            //            }else{
            var controller = SelectContactViewController()
            controller.ints = JavaUtilArrayList()
            controller.isCreatGroup = true
            self.navigationController?.pushViewController(controller, animated: true)
            //            }
            
        }
    }
    
    func dialogOK(){
        dialog?.close()
        var controller = SelectContactViewController()
        controller.ints = JavaUtilArrayList()
        controller.isCreatGroup = true
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "first_create_gourp")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func dialogCancle(){
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "first_create_gourp")
        dialog?.close()
    }
    
}
