//
//  NewFriendsViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class NewFriendsViewController:BaseViewController,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface,ComFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface{
    
    @IBOutlet weak var freeAccpetbtn: UIButton!
    @IBOutlet weak var moneyAcceptbtn: UIButton!
    @IBOutlet var mAgreeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stateLabel: UILabel!
    var mFriendsListAll:JavaUtilArrayList! = JavaUtilArrayList()
    var friendsListReq:JavaUtilArrayList!
    var friendsListRsp:JavaUtilArrayList!
    var accpetUser:ComFqHalcyonEntityContacts!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("新的朋友")
        hiddenRightImage(true)
        getDataFromServer()
        UITools.setRoundBounds(6.0, view: freeAccpetbtn)
        UITools.setRoundBounds(6.0, view: moneyAcceptbtn)
        
        var index:Int! = self.navigationController?.viewControllers.count
        self.navigationController?.viewControllers.removeRange(Range(start:nextPosition!,end:index - 1))
        
        
        
    }
    func getDataFromServer(){
        ComFqHalcyonLogic2GetAddingFriendsListLogic(comFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        //        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据或操作失败", width: 210, height: 120)
        self.view.makeToast("获取数据或操作失败")
    }
    
    func onDataReturnWithJavaUtilArrayList(mFriendsListReq: JavaUtilArrayList!, withJavaUtilArrayList mFriendsListRsp: JavaUtilArrayList!) {
        friendsListReq = mFriendsListReq
        friendsListRsp = mFriendsListRsp
        mFriendsListAll.clear()
        parseStatusFor4()
        var tempList = JavaUtilArrayList()
        if mFriendsListRsp.size() != 0 {
            for i in 0..<mFriendsListRsp.size() {
                var contact:ComFqHalcyonEntityContacts! = mFriendsListRsp.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
                if contact.getStatus() == 0 {
                    mFriendsListRsp.removeWithInt(Int32(i))
                    mFriendsListRsp.addWithInt(0, withId: contact)
                }
            }
        }
        mFriendsListAll.addAllWithJavaUtilCollection(mFriendsListRsp)
        mFriendsListAll.addAllWithJavaUtilCollection(mFriendsListReq)
        
        tableView.reloadData()
        if mFriendsListAll.size() == 0 {
            stateLabel.hidden = false
            tableView.hidden = true
        }else{
            stateLabel.hidden = true
            tableView.hidden = false
        }
    }
    /**remove state = 4的*/
    func parseStatusFor4() {
        for (var i:Int32 = 0; i < friendsListRsp.size(); i++) {
            var contacts:ComFqHalcyonEntityContacts! = friendsListRsp.getWithInt(i) as! ComFqHalcyonEntityContacts
            if (contacts.getStatus() == 4) {
                friendsListRsp.removeWithInt(i)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //    /**toprihtBtn监听*/
    //    override func onRightBtnOnClick(sender: UIButton) {
    //        var search:ContactSearchViewController = ContactSearchViewController()
    //        search.mTitle = "添加朋友"
    //        self.navigationController?.pushViewController(search, animated: true)
    //    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        receivedMessageCountGlobal = 0
        receivedMessageCountContact = 0
        NSNotificationCenter.defaultCenter().postNotificationName("sendAddFriendMessage", object: self, userInfo: ["sendAddFriendMessage":receivedMessageCountGlobal])
    }
    
    override func getXibName() -> String {
        return "NewFriendsViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("NewFriendsTableViewCell") as? NewFriendsTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NewFriendsTableViewCell", owner: self, options: nil)
            cell = nibs.objectAtIndex(0) as? NewFriendsTableViewCell
        }
        
        
        UITools.setBorderWithHeadKuang(cell!.headKuang)
        var rect:CGRect? = cell?.headImageView.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell!.headImageView)
        UITools.setRoundBounds(9, view: cell!.acceptBtn)
        UITools.setRoundBounds(9, view: cell!.refuseBtn)
        UITools.setRoundBounds(9, view: cell!.otherAccept)
        UITools.setRoundBounds(9, view: cell!.otherRefuse)
        
        
        var contacts:ComFqHalcyonEntityContacts! = mFriendsListAll.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        cell?.nameLabel.text = contacts.getUsername()
        var photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contacts.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            var path:NSString? = data as? NSString
            if(path != nil){
                cell?.headImageView.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        //        cell?.headImageView.downLoadImageWidthImageId(contacts.getImageId(), callback: { (view, path) -> Void in
        //            var imageView:UIImageView = view as UIImageView
        //            imageView.image = UITools.getImageFromFile(path)
        //        })
        
        //        cell?.acceptBtn.addTarget(self, action: "accept:", forControlEvents: UIControlEvents.TouchUpInside)
        //        cell?.refuseBtn.addTarget(self, action: "refuse:", forControlEvents: UIControlEvents.TouchUpInside)
        //        cell?.acceptBtn.tag = indexPath.row
        //        cell?.refuseBtn.tag = indexPath.row
        cell?.otherAccept.addTarget(self, action: "otheraccept:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.otherRefuse.addTarget(self, action: "otherrefuse:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.otherAccept.tag = indexPath.row
        cell?.otherRefuse.tag = indexPath.row
        var reqSize = friendsListRsp.size()
        var status = contacts.getStatus()
        var roletype = contacts.getRole_type()
        //        setAcceptBtnstate(cell?.acceptBtn)
        setAcceptBtnstate(cell?.otherAccept)
        //        setRefuseBtnstate(cell?.refuseBtn)
        setRefuseBtnstate(cell?.otherRefuse)
        cell?.msgLabel.text = contacts.getRequestMsg()
        //        if contacts.getGender() == 2{
        //            cell?.sexImg.image = UIImage(named: "icon_man.png")
        //        }else{
        //            cell?.sexImg.image = UIImage(named: "icon_female.png")
        //        }
        //
        
        if roletype == 1 || roletype == 2{
            if indexPath.row < Int(reqSize)  {//接受好友列表
                if (status == 0) {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(false)
                    cell?.hiddenLabel()
                } else if (status == 4) {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("验证中")
                } else {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("已添加")
                }
            }else{//请求好友列表
                if status == 0 || status == 4{
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("验证中")
                }else{
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("已添加")
                }
            }
        }
        //        if roletype == 3{
        //            if reqSize >= (indexPath.row + 1){// 接受好友列表
        //                if (status == 0) {
        //                    cell?.hiddenBtn(false)
        //                    cell?.hiddenoOtherBtn(true)
        //                    cell?.hiddenLabel()
        //                } else if (status == 4) {
        //                    cell?.hiddenBtn(true)
        //                    cell?.hiddenoOtherBtn(true)
        //                    cell?.setLabelText("验证中")
        //                } else {
        //                    cell?.hiddenBtn(true)
        //                    cell?.hiddenoOtherBtn(true)
        //                    cell?.setLabelText("已添加")
        //                }
        //
        //            }else {// 请求好友列表
        //                if status == 0 || status == 4 {
        //                    cell?.hiddenBtn(true)
        //                    cell?.hiddenoOtherBtn(true)
        //                    cell?.setLabelText("验证中")
        //                }else{
        //                    cell?.hiddenBtn(true)
        //                    cell?.hiddenoOtherBtn(true)
        //                    cell?.setLabelText("已添加")
        //                }
        //            }
        //        }
        
        return cell!
    }
    
    //    /**接受病人添加*/
    //    func accept(sender:UIButton){
    //        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as ComFqHalcyonEntityContacts
    //        self.view.addSubview(mAgreeView)
    //    }
    //    /**免费添加*/
    //    @IBAction func freeAccept(sender: AnyObject) {
    //        ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: true, withBoolean: true, withBoolean: false)
    //    }
    //    /**收费添加*/
    //    @IBAction func moneyAccept(sender: AnyObject) {
    //        ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: true, withBoolean: false, withBoolean: false)
    //
    //    }
    //    /**拒绝病人添加*/
    //    func refuse(sender:UIButton){
    //        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as ComFqHalcyonEntityContacts
    //        ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: false, withBoolean: true, withBoolean: false)
    //    }
    /**接受医生或者医学生添加*/
    func otheraccept(sender:UIButton){
        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: true, withBoolean: true, withBoolean: false)
        
    }
    /**拒绝医生或者医学生添加*/
    func otherrefuse(sender:UIButton){
        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: false, withBoolean: true, withBoolean: false)
    }
    
    func onDataReturn() {
        mAgreeView.removeFromSuperview()
        getDataFromServer()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mFriendsListAll.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    /**接受按钮的点击效果*/
    func setAcceptBtnstate(btn:UIButton!){
        btn.setTitleColor(UIColor(red: 18/255.0, green: 66/255.0, blue: 77/255.0, alpha: 1), forState: UIControlState.Highlighted)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 18/255.0, green: 66/255.0, blue: 77/255.0, alpha: 1)), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Highlighted)
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor(red: CGFloat(18/255.0), green: CGFloat(66/255.0), blue: CGFloat(77/255.0), alpha: CGFloat(1)).CGColor
        
    }
    /**拒绝按钮的点击效果*/
    func setRefuseBtnstate(btn:UIButton!){
        btn.setTitleColor(UIColor(red: 240/255.0, green: 87/255.0, blue: 89/255.0, alpha: 1), forState: UIControlState.Highlighted)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 240/255.0, green: 87/255.0, blue: 89/255.0, alpha: 1)), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Highlighted)
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor(red: 240/255.0, green: 87/255.0, blue: 89/255.0, alpha: 1).CGColor
        
    }
    
    
}
