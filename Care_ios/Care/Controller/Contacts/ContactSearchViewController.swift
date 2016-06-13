//
//  ContactSearchViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ContactSearchViewController:BaseViewController,UISearchBarDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface,ComFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var statusLabel: UILabel!
    var mTitle:String?
    var mKeyWords:String?
    var mSearchFriendsList:JavaUtilArrayList! = JavaUtilArrayList()
    var page = Int32(0)
    var pagesize = Int32(20)
    var isNewFriend = false
    var contact:ComFqHalcyonEntityContacts!
    var msgTextView:UITextView?
    var msgDialog:CustomIOS7AlertView?
    
    var loadingDialog:CustomIOS7AlertView?
    var pwStr = "\(ComFqLibToolsConstants.getUser().getUserId())"
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle(mTitle!)
        hiddenRightImage(true)
        if mTitle == "添加朋友"{
            isNewFriend = true
        }
        if mTitle == "搜索"{
            isNewFriend = false
        }
        //        setRightBtnTittle("筛选")
        searchOld()
        print(isNewFriend)
    }
    
    func searchOld(){
        if isNewFriend {
            return
        }
        if mKeyWords == nil || mKeyWords == ""{
            return
        }
        searchBar.text = mKeyWords
        getSerachResult(mKeyWords!,isNewFriend:isNewFriend)
    }
    
    
    
    func getSerachResult(keyWords:String,isNewFriend:Bool){
        ComFqHalcyonLogic2SearchFriendsLogic(comFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface:self , withInt: ComFqLibToolsConstants.getUser().getUserId(), withNSString: keyWords, withInt: page, withInt: pagesize, withBoolean: isNewFriend)
        
    }
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
//        UIAlertViewTool.getInstance().showAutoDismisDialog("操作失败", width: 210, height: 120)
        self.view.makeToast("操作失败")
        if loadingDialog != nil {
            loadingDialog?.close()
        }
    }
    
    func onDataReturnWithJavaUtilList(mUserList: JavaUtilList!) {
        mSearchFriendsList.clear()
       
        
        for var i:Int32 = 0 ; i < mUserList.size() ; i++ {
            var contact = mUserList.getWithInt(i) as! ComFqHalcyonEntityContacts
            if contact.getRole_type() == 1 || contact.getRole_type() == 2 {
                mSearchFriendsList.addWithId(contact)
            }
            
        }
        if mSearchFriendsList.size() == 0 {
            //            UIAlertViewTool.getInstance().showAutoDismisDialog("没有搜索到相匹配的好友", width: 210, height: 120)
            tableView.reloadData()
            statusLabel.hidden = false
            tableView.hidden = true
            return
        }
        statusLabel.hidden = true
        tableView.hidden = false
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "ContactSearchViewController"
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ContactSearchTableViewCell") as? ContactSearchTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ContactSearchTableViewCell", owner: self, options: nil)
            cell = nibs.objectAtIndex(0) as? ContactSearchTableViewCell
        }
        
        UITools.setBorderWithHeadKuang(cell!.headKuang)
        var rect:CGRect? = cell?.headImage.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell!.headImage)
        
        var contacts:ComFqHalcyonEntityContacts! = mSearchFriendsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        cell?.nameLabel.text = contacts.getUsername()
        var photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contacts.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            var path:NSString? = data as? NSString
            if(path != nil){
                cell?.headImage.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        if isNewFriend{
            cell?.addBtn.hidden = false
            cell?.addBtn.addTarget(self, action: "addfriend:", forControlEvents: UIControlEvents.TouchUpInside)
            cell?.addBtn.tag = indexPath.row
            if contacts.isFriend()  || contacts.getRole_type() == 3{
                cell?.addBtn.hidden = true
            }
            //            cell?.addBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red:235/255.0,green:97/255.0,blue:0/255.0,alpha:1)), forState: UIControlState.Normal)
            //            cell?.addBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red:240/255.0,green:147/255.0,blue:116/255.0,alpha:1)), forState: UIControlState.Highlighted)
        }else{
            cell?.addBtn.hidden = true
        }
        
        
        cell?.headBtn.tag = indexPath.row
        cell?.headBtn.addTarget(self, action: "headTouch:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell!
    }
    
    /**添加按钮点击事件*/
    func addfriend(sender:UIButton){
        var user = ComFqLibToolsConstants.getUser()
        contact = mSearchFriendsList.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        var result = UIAlertViewTool.getInstance().showTextViewdDialog("你好！我是"+"\(user.getHospital())"+"\(user.getDepartment())"+"的"+"\(user.getName())"+",想添加你为好友！", target: self, actionOk: "send", actionCancle: "cancel")
        msgTextView = result.textview
        msgDialog = result.alertView
        msgTextView?.delegate = self
    }
    var oldtext:String?
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var i = 0
        for temp in textView.text {
            i++
        }
        if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 && i > 30  {
            textView.text = ""
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        var newtext = textView.text
        var i = 0
        for temp in textView.text {
            i++
        }
        println(i)
        
        if i <= 30 {
            oldtext = newtext
        }
        
        if i > 30 {
            textView.text = oldtext
        }

    }
    
    /**dialog发送*/
    func send(){
        ComFqHalcyonLogic2DoctorAddFriendLogic(comFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: contact.getUserId(), withInt: ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_NORMAL,withNSString:msgTextView?.text)
        msgDialog?.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("添加好友，请稍后...")
//        ComFqHalcyonLogic2DoctorAddFriendLogic(comFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: contact.getUserId(), withInt: ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_NORMAL)
    }
    func cancel(){
        msgDialog?.close()
    }
    
    func onDataReturn() {
        //        HalcyonApplication.getInstance().sendMessage(MessageStruct.MESSAGE_TYPE_ADD_NEW_FRIEND, "++++", friend.getUserId());
        print("添加成功")
        var addId = "\(contact.getUserId())"
        var entity = ComFqHalcyonEntityChartEntity()
        entity.setMessageTypeWithInt(7)
        entity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
        MessageTools.sendMessage(entity.description(), payLoad: "", type: 1, customId: addId, callBackTag: "", toUser: contact)
        MessageTools.removeSimplechatList(addId)
        self.navigationController?.pushViewController(NewFriendsViewController(), animated: true)
        //        var actionType = -1
        var roleType = contact.getRole_type();
        loadingDialog?.close()
        //        if(roleType == ComFqLibToolsConstants_ROLE_DOCTOR || roleType == ComFqLibToolsConstants_ROLE_DOCTOR_STUDENT){
        //            actionType = ComFqHalcyonEntityUserAction_ACTION_ADD_DEOCTOR
        //        }else if(roleType == ComFqLibToolsConstants_ROLE_PATIENT){
        //            actionType = ComFqHalcyonEntityUserAction_ACTION_ADD_PATIENT;
        //        }
        //        com.fq.halcyon.entityUserAction action = new UserAction(System.currentTimeMillis(),actionType,contact.getName());
        //        UserActionManger.getInstance().addAction(action);
        //        UserActionManger.getInstance().getActions();
    }
    
    /**头像点击事件*/
    func headTouch(sender:UIButton){
        var controller:UserInfoViewController = UserInfoViewController()
        contact = mSearchFriendsList.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        controller.mUser = contact
        
        if isNewFriend {
            controller.isFriend = false
        }else{
            controller.isFriend = true
            controller.mRelationId = Int(contact.getRelationId())
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mSearchFriendsList.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        getSerachResult(searchBar.text,isNewFriend:isNewFriend)
        println("开始搜索\(searchBar.text)")
        
    }
    
    //    override func onRightBtnOnClick(sender: UIButton) {
    //        self.navigationController?.pushViewController(FilterFriendViewController(), animated: true)
    //    }
    //    
}
