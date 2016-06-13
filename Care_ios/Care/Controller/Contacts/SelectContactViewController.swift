//
//  SelectContactViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectContactViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface,ComFqHalcyonLogicPracticeChatGroupLogic_CreateChatGroupCallBack,ComFqHalcyonLogicPracticeChatGroupLogic_AddGroupContactCallBack {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var status: UILabel!
    var ints:JavaUtilArrayList!//已有的群成员id
    var mDoctorList:JavaUtilArrayList!
    var mPatientList:JavaUtilArrayList!
    var mContactsList:JavaUtilArrayList! =  JavaUtilArrayList()
    var mChkStatus:Dictionary<JavaLangInteger,Bool>? = Dictionary()
    var mSelectContacts:JavaUtilArrayList! = JavaUtilArrayList()
    var isCreatGroup = false
    var chartList:JavaUtilArrayList = JavaUtilArrayList()
    var groupId = ""
    var contacts:ComFqHalcyonEntityContacts?//单人聊天的联系人
    var logic:ComFqHalcyonLogicPracticeChatGroupLogic!
    var loadingDialog:CustomIOS7AlertView?
    var addIds:JavaUtilArrayList = JavaUtilArrayList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("选择联系人")
        setRightBtnTittle("确认")
        
        if contacts != nil {
            mSelectContacts.addWithId(contacts)
        }
        
        logic = ComFqHalcyonLogicPracticeChatGroupLogic()
        if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_DOCTOR)) != nil {
            mDoctorList = ComFqLibToolsConstants_contactsMap_.getWithId( JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList
        }else{
            mDoctorList = JavaUtilArrayList()
        }
        if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_PATIENT)) != nil {
            mPatientList = ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList
        }else{
            mPatientList = JavaUtilArrayList()
        }
        
        
        mContactsList.addAllWithJavaUtilCollection(mDoctorList)
        mContactsList.addAllWithJavaUtilCollection(mPatientList)
        if mContactsList.size() == 0 {
            tableView.reloadData()
            tableView.hidden = true
            status.hidden = false
            status.text = "您还没有好友"
            
            
        }else {
            for var i:Int32 = 0; i < mContactsList.size(); i++ {
                
                mChkStatus?.updateValue(false, forKey: JavaLangInteger(int:(mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId()))
                if ints != nil{
                    for var j:Int32 = 0 ; j < ints.size() ; j++ {
                        if (ints.getWithInt(j) as! JavaLangInteger).intValue() == (mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId(){
                            mChkStatus?.updateValue(true, forKey: JavaLangInteger(int:(mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId()))
                        }
                        
                    }
                    
                }
                
                if contacts?.getUserId() == (mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId() {
                    contacts = mContactsList.getWithInt(i) as? ComFqHalcyonEntityContacts
                }
                
            }
            
            tableView.reloadData()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func onRightBtnOnClick(sender: UIButton) {
        
        /**没选择好友*/
        if mSelectContacts.size() == 0 {
            self.view.makeToast("至少选择一个联系人")
        }else if mSelectContacts.size() == 1 && contacts == nil && isCreatGroup {
            var user:ComFqHalcyonEntityPerson = mSelectContacts.getWithInt(0) as! ComFqHalcyonEntityPerson
            var controller = SimpleChatViewController()
            controller.toUser = user
            self.navigationController?.pushViewController(controller, animated: true)
            var ctrlArray = (self.navigationController?.viewControllers)!
            self.navigationController?.viewControllers.removeAtIndex(ctrlArray.count - 2)
        }else if mSelectContacts.size() == 1 && contacts != nil {/**单聊管理没选择好友*/
            self.view.makeToast("至少选择一个联系人")
        }else{
            loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("");
            
            if isCreatGroup {
//                IMMyselfInstance.createGroupWithName("\(ComFqLibToolsConstants.getUser().getName())发起的群聊", success: { (mGroupId) -> Void in
//                    println("创建群成功 \(mGroupId)")
//                    self.groupId = mGroupId
//                    self.addToGroup()
//                    
//                    }, failure: { (error) -> Void in
//                        println("创建群失败 \(error)")
//                        self.loadingDialog?.close()
//                        if error == "You have already found 100 groups." {
//                            //                        UIAlertViewTool.getInstance().showAutoDismisDialog("您最多只能创建100个群聊哦~", width: 240, height: 80)
//                            self.view.makeToast("您最多只能创建100个群聊哦~")
//                        }else{
//                            self.view.makeToast("服务器出错")
//                        }
//                        
//                })
                
            }else{
                self.addToGroup()
                
            }
            
        }
        
        
    }
    
    var mCurrentIndex:Int32 = 0
    
    func addToGroup(){
        
        /**没选择好友*/
        //        if mSelectContacts.size() == 0 {
        //            if self.isCreatGroup {
        //                self.loadingDialog?.close()
        //                logic.createGroupWithNSString(self.groupId, withJavaUtilArrayList: self.addIds, withComFqHalcyonLogicPracticeChatGroupLogic_CreateChatGroupCallBack: self)
        //                var controller = MoreChatViewController()
        //                controller.mIDCardmessageList = self.chartList
        //                controller.groupId = self.groupId
        //                controller.tittleStr = "\(ComFqLibToolsConstants.getUser().getUsername())发起的群聊"
        //                self.navigationController?.pushViewController(controller, animated: true)
        //                var ctrlArray = (self.navigationController?.viewControllers)!
        //                if self.contacts != nil {
        //                    self.navigationController?.viewControllers.removeRange(Range(start: ctrlArray.count - 4,end:ctrlArray.count - 1))
        //
        //                }else{
        //                    self.navigationController?.viewControllers.removeAtIndex(ctrlArray.count - 2)
        //                }
        //                selcontacts?.clear()
        //
        //
        //            }else{
        //
        //                self.loadingDialog?.close()
        //
        //                logic.addGroupContactWithNSString(self.groupId, withJavaUtilArrayList: self.addIds, withComFqHalcyonLogicPracticeChatGroupLogic_AddGroupContactCallBack: self)
        //
        //                var controller:MoreChatViewController = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count-3] as! MoreChatViewController
        //                controller.mIDCardmessageList = self.chartList
        //                controller.groupId = self.groupId
        //                self.navigationController?.popViewControllerAnimated(true)
        //
        //            }
        //
        //            return
        //        }
        var con = self.mSelectContacts.getWithInt(self.mCurrentIndex) as! ComFqHalcyonEntityContacts
        var myCustomId = "\(con.getUserId())"
//        self.IMMyselfInstance.addMember(myCustomId, toGroup: groupId, success: { () -> Void in
//            println("添加\(myCustomId)进群成功 \(self.groupId)")
//            selcontacts?.addWithId(con)
//            var chartEntity = ComFqHalcyonEntityChartEntity()
//            chartEntity.setUserNameWithNSString(con.getName())
//            chartEntity.setUserIdWithInt(con.getUserId())
//            chartEntity.setUserImageIdWithInt(con.getImageId())
//            chartEntity.setMessageTypeWithInt(6)
//            chartEntity.setHospitalWithNSString(con.getHospital())
//            chartEntity.setDepartmentWithNSString(con.getDepartment())
//            chartEntity.setMessageWithNSString("\(ComFqLibToolsConstants.getUser().getName())邀请\(con.getName())加入群聊")
//            self.addIds.addWithId(JavaLangInteger(int: con.getUserId()))
//            self.chartList.addWithId(chartEntity)
//            self.mCurrentIndex =  self.mCurrentIndex + 1
//            if self.mCurrentIndex == self.mSelectContacts.size() {
//                if self.isCreatGroup {
//                    self.loadingDialog?.close()
//                    self.logic.createGroupWithNSString(self.groupId, withJavaUtilArrayList: self.addIds, withComFqHalcyonLogicPracticeChatGroupLogic_CreateChatGroupCallBack: self)
//                    var controller = MoreChatViewController()
//                    controller.mIDCardmessageList = self.chartList
//                    controller.groupId = self.groupId
//                    controller.tittleStr = "\(ComFqLibToolsConstants.getUser().getName())发起的群聊"
//                    self.navigationController?.pushViewController(controller, animated: true)
//                    var ctrlArray = (self.navigationController?.viewControllers)!
//                    if self.contacts != nil {
//                        self.navigationController?.viewControllers.removeRange(Range(start: ctrlArray.count - 4,end:ctrlArray.count - 1))
//                        
//                    }else{
//                        self.navigationController?.viewControllers.removeAtIndex(ctrlArray.count - 2)
//                    }
//                    selcontacts?.clear()
//                    
//                }else{
//                    self.loadingDialog?.close()
//                    self.logic.addGroupContactWithNSString(self.groupId, withJavaUtilArrayList: self.addIds, withComFqHalcyonLogicPracticeChatGroupLogic_AddGroupContactCallBack: self)
//                    var controller:MoreChatViewController = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count-3] as! MoreChatViewController
//                    controller.mIDCardmessageList = self.chartList
//                    controller.groupId = self.groupId
//                    self.navigationController?.popViewControllerAnimated(true)
//                }
//                self.mCurrentIndex = 0
//            }else{
//                self.addToGroup()
//            }
//            
//            }, failure: { (error) -> Void in
//                println("添加\(myCustomId)进群失败 \(self.groupId)")
//                self.mCurrentIndex =  self.mCurrentIndex + 1
//                if self.mCurrentIndex == self.mSelectContacts.size() {
//                    if self.isCreatGroup {
//                        self.loadingDialog?.close()
//                        
//                        self.logic.createGroupWithNSString(self.groupId, withJavaUtilArrayList: self.addIds, withComFqHalcyonLogicPracticeChatGroupLogic_CreateChatGroupCallBack: self)
//                        
//                        var controller = MoreChatViewController()
//                        controller.mIDCardmessageList = self.chartList
//                        controller.groupId = self.groupId
//                        controller.tittleStr = "\(ComFqLibToolsConstants.getUser().getName())发起的群聊"
//                        self.navigationController?.pushViewController(controller, animated: true)
//                        var ctrlArray = (self.navigationController?.viewControllers)!
//                        if self.contacts != nil {
//                            self.navigationController?.viewControllers.removeRange(Range(start: ctrlArray.count - 4,end:ctrlArray.count - 1))
//                        }else{
//                            self.navigationController?.viewControllers.removeAtIndex(ctrlArray.count - 2)
//                        }
//                        selcontacts?.clear()
//                        
//                    }else{
//                        self.loadingDialog?.close()
//                        
//                        self.logic.addGroupContactWithNSString(self.groupId, withJavaUtilArrayList: self.addIds, withComFqHalcyonLogicPracticeChatGroupLogic_AddGroupContactCallBack: self)
//                        
//                        var controller:MoreChatViewController = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count-3] as! MoreChatViewController
//                        controller.mIDCardmessageList = self.chartList
//                        controller.groupId = self.groupId
//                        self.navigationController?.popViewControllerAnimated(true)
//                        
//                    }
//                    self.mCurrentIndex = 0
//                }else{
//                    self.addToGroup()
//                }
//                
//        })
        
    }
    /**创建成功回调*/
    func createGroupSuccess() {
        
        
    }
    /**创建失败回调*/
    func createGroupErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    /**添加好友入群成功回调*/
    func addGroupContactSuccess() {
        
    }
    
    /**添加好友入群成功失败回调*/
    func addGroupContactErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    
    override func getXibName() -> String {
        return "SelectContactViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SelectContactsTableViewCell") as? SelectContactsTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SelectContactsTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? SelectContactsTableViewCell
        }
        
        cell?.bottomLine.hidden = false
        UITools.setBorderWithHeadKuang(cell!.headKuang)
        var rect:CGRect? = cell?.headImageView.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell!.headImageView)
        
        
        var contact:ComFqHalcyonEntityContacts! = mContactsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        cell?.nameLabel.text = contact.getUsername()
        var photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contact.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            var path:NSString? = data as? NSString
            if(path != nil){
                cell?.headImageView.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        if mChkStatus?[JavaLangInteger(int:contact.getUserId())] == true{
            cell?.selectedImageview.image = UIImage(named: "friend_select.png")
        }else{
            cell?.selectedImageview.image = UIImage(named: "friend_unselect.png")
        }
        return cell!
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectContactsTableViewCell
        var contact:ComFqHalcyonEntityContacts! = mContactsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        if ints != nil {
            for var j:Int32 = 0 ; j < ints.size() ; j++ {
                if (ints.getWithInt(j) as! JavaLangInteger).intValue() == contact.getUserId(){
                    return
                }
            }
        }
        
        if mChkStatus?[JavaLangInteger(int:contact.getUserId())] == true{
            mChkStatus?.updateValue(false, forKey: JavaLangInteger(int:contact.getUserId()))
            mSelectContacts.removeWithId(contact)
            cell.selectedImageview.image = UIImage(named: "friend_unselect.png")
            
        }else{
            mChkStatus?.updateValue(true, forKey: JavaLangInteger(int:contact.getUserId()))
            mSelectContacts.addWithId(contact)
            cell.selectedImageview.image = UIImage(named: "friend_select.png")
            
        }
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mContactsList.size())
    }
    
    /**点击搜索*/
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //        searchBar.endEditing(true)
        //        getSerachResult(searchBar.text,isNewFriend:false)
        //        println("开始搜索\(searchBar.text)")
    }
    
    /**自动搜索*/
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        getSerachResult(searchText,isNewFriend:false)
        println("开始搜索\(searchBar.text)")
    }
    
    
    
    
    func getSerachResult(keyWords:String,isNewFriend:Bool){
        ComFqHalcyonLogic2SearchFriendsLogic(comFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface:self , withInt: ComFqLibToolsConstants.getUser().getUserId(), withNSString: keyWords, withInt: 0, withInt: 20, withBoolean: isNewFriend)
        
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        //        UIAlertViewTool.getInstance().showAutoDismisDialog("获取联系人失败", width: 210, height: 120)
        self.view.makeToast("获取联系人失败")
    }
    
    func onDataReturnWithJavaUtilList(mUserList: JavaUtilList!) {
        mContactsList.clear()
        if mUserList.size() == 0 {
            //            UIAlertViewTool.getInstance().showAutoDismisDialog("没有搜索到相匹配的好友", width: 210, height: 120)
            tableView.reloadData()
            tableView.hidden = true
            status.hidden = false
            status.text = "无此用户！请检查搜索条件是否正确！"
            return
        }
        status.hidden = true
        tableView.hidden = false
        mContactsList.addAllWithJavaUtilCollection(mUserList)
        tableView.reloadData()
    }
    
}
