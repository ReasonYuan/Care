//
//  UserInfoViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-8.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class UserInfoViewController: BaseViewController,ComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback,UITextViewDelegate,ComFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface,ComFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var genderYiJiaHao: UILabel!
    @IBOutlet weak var addFriendBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    var deleteDialog:CustomIOS7AlertView?
    
    /**一下为一堆传递数据 烦啊！！！**/
    var mDepartmentMap = Dictionary<String,NSMutableArray> ()
    var mDepNameString:String = ""
    var mUser:ComFqHalcyonEntityPerson?
    var isFriend:Bool = false
    var mRelationId:Int = -1
    var scanUrl:String = ""
    var mFromZbar = false
    var addfriendLogic:ComFqHalcyonLogic2DoctorAddFriendLogic?
    var addOrRefuseLogic:ComFqHalcyonLogic2AddOrRefuseFriendLogic?
    
    var msgTextView:UITextView?
    var msgDialog:CustomIOS7AlertView?
    var loadingDialog:CustomIOS7AlertView?
   
    @IBOutlet weak var sendMessage: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameBg: UIView!
    @IBOutlet weak var hospital: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var zhiwu: UILabel!
    @IBOutlet weak var jianjie: UITextView!
    @IBOutlet weak var genderIcon: UIImageView!

    
    var detailList = JavaUtilArrayList()
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("详细资料")
        hiddenRightImage(true)
        addFriendBtn.hidden = true
        deleteBtn.hidden = true
        sendMessage.hidden = true
        
        addFriendBtn.setBackgroundImage(UITools.imageWithColor(Color.pink), forState: UIControlState.Normal)
        addFriendBtn.setBackgroundImage(UITools.imageWithColor(Color.darkPink), forState: UIControlState.Highlighted)
        deleteBtn.setBackgroundImage(UITools.imageWithColor(Color.pink), forState: UIControlState.Normal)
        deleteBtn.setBackgroundImage(UITools.imageWithColor(Color.darkPink), forState: UIControlState.Highlighted)
        sendMessage.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Normal)
        sendMessage.setBackgroundImage(UITools.imageWithColor(Color.darkPurple), forState: UIControlState.Highlighted)
        
        UITools.setBorderWithView(1.0, tmpColor: UIColor.grayColor().CGColor, view: headImageView)
        UITools.setRoundBounds(40.0, view: headImageView)
        UITools.setRoundBounds(12.0, view: nameBg)

        initDatas()
    }

    func initDatas(){
       var  mLogic = ComFqHalcyonLogic2ReadUserInfoLogic()
        if (mUser != nil) {
            initInfo(mUser!)
            mLogic.readUserInfoByPostWithInt(mUser!.getUserId(), withComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback: self)
        }else {
            var url:NSString = scanUrl
            mFromZbar = true
            var startId = url.indexOfString("user_id=")
            var strId = url.substringFromIndex(Int(startId) + 8)
            var userId = strId.toInt()
            if userId! == Int(ComFqLibToolsConstants.getUser().getUserId()) {
                mUser = ComFqLibToolsConstants.getUser()
                initInfo(mUser!)
                mLogic.readUserInfoByPostWithInt(mUser!.getUserId(), withComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback: self)
            }else {
                if !url.isEmpty() && url != ""{
                    println("----------------------------------------------------------")
                    mLogic.readUserInfoByGetWithNSString(url as String, withComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback: self)
                }
            }
            
        }
    }
    
    func initInfo(person:ComFqHalcyonEntityPerson){
        name.text = person.getName()
        var gender = person.getGenderStr()
        if gender == "男" {
            genderIcon.image = UIImage(named: "icon_man.png")
        }else {
             genderIcon.image = UIImage(named: "icon_female.png")
        }
        
        headImageView.downLoadImageWidthImageId(person.getImageId(), callback: { (view, path) -> Void in
            var tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })

    }
  
    func initAddOrDelFriendBtn(user:ComFqHalcyonEntityContacts!){
        if user.getRole_type() == 1 {
            if user.isFriend() {
                deleteBtn.hidden = false
                sendMessage.hidden = false
                addFriendBtn.hidden = true
            }else {
                deleteBtn.hidden = true
                sendMessage.hidden = true
                addFriendBtn.hidden = false
            }
            
        }
       
        /**病人客户端目前限制病人不能添加病人好友**/
        if user.getRole_type() == 3 {
            deleteBtn.hidden = true
            sendMessage.hidden = true
            addFriendBtn.hidden = true
        }
    }
    
    func feedUserWithComFqHalcyonEntityContacts(user: ComFqHalcyonEntityContacts!) {
         println("2222----------------------------------------------------------")
        if mUser == nil {
//            initInfo(user)
            if user.getUserId() != ComFqLibToolsConstants.getUser().getUserId() {
                mUser = user
               
            }
        }
        if user.isFriend() == true || user.getUserId() != ComFqLibToolsConstants.getUser().getUserId() {
            mRelationId = Int(user.getRelationId())
            isFriend = user.isFriend()
        }
        initInfo(user)
        if user.getUserId() == ComFqLibToolsConstants.getUser().getUserId() {
            deleteBtn.hidden = true
            sendMessage.hidden = true
            addFriendBtn.hidden = true
        }else{
           initAddOrDelFriendBtn(user)
        }
        
        
        mUser = user
        initDetail()
        
    }
    
    func initDetail(){
        if  mUser?.getRole_type() == 1 {
            detailList.addWithId(mUser?.getHospital())
            detailList.addWithId(mUser?.getDepartment())
            detailList.addWithId(mUser?.getTitleStr())
            detailList.addWithId(mUser?.getDescription())
        }
        
        if mUser?.getRole_type() == 3 {
            detailList.addWithId(mUser?.getName())
            detailList.addWithId(mUser?.getGenderStr())
            detailList.addWithId(mUser?.getDescription())
        }
        tableView.reloadData()
        
    }
    
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
//        UIAlertViewTool.getInstance().showAutoDismisDialog("操作失败！", width: 210, height: 120)
        if loadingDialog != nil {
            loadingDialog?.close()
        }
        self.view.makeToast("操作失败！")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func getXibName() -> String {
        return "UserInfoViewController"
    }

    
    
    /**添加好友**/
    @IBAction func addClick(sender: AnyObject) {
        
        var user = ComFqLibToolsConstants.getUser()
        
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
        msgDialog?.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("添加好友，请稍后...")
        var type = mFromZbar ? ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_ZXING : ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_NORMAL
        var userId = mUser?.getUserId().value
        addfriendLogic = ComFqHalcyonLogic2DoctorAddFriendLogic(comFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: Int32(userId!), withInt: type, withNSString:msgTextView?.text)
    }
    
    func cancel(){
        msgDialog?.close()
    }

    
    
    @IBAction func deleteClick(sender: AnyObject) {
        deleteDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认删除？", target: self, actionOk: "deleteFriendOk", actionCancle: "deleteFriendCancle")
        deleteDialog?.setCanCelOnTouchOutSide(true)

    }
    
    /**删除、添加好友的回调**/
    func onDataReturn() {
        var deleteBtnText = deleteBtn.titleLabel?.text
        if isFriend {
            
            if ComFqLibToolsConstants_contactsList_ != nil && mUser != nil {
                var size = ComFqLibToolsConstants_contactsList_.size()
                for var i = 0 ; i < Int(size); i++ {
                    var tmpUser = ComFqLibToolsConstants_contactsList_.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        ComFqLibToolsConstants_contactsList_.removeWithInt(Int32(i))
                        break
                    }
                }
            }
            
            if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) != nil{
                  var size = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList).size()
                 for var i = 0 ; i < Int(size); i++ {
                    var tmpUser: ComFqHalcyonEntityContacts! = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList).getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList).removeWithInt(Int32(i))
                         break
                    }
                 }
            }
            
            if ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) != nil{
                var size = (ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) as! JavaUtilArrayList).size()
                for var i = 0 ; i < Int(size); i++ {
                    var tmpUser: ComFqHalcyonEntityContacts! = (ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) as! JavaUtilArrayList).getWithInt(Int32(i))  as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        (ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) as! JavaUtilArrayList).removeWithInt(Int32(i))
                        break
                    }
                }
            }
            
            if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) != nil{
                var size = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList).size()
                for var i = 0 ; i < Int(size); i++ {
                    var tmpUser: ComFqHalcyonEntityContacts! = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList).getWithInt(Int32(i))  as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList).removeWithInt(Int32(i))
                         break
                    }
                }
            }
            
            if !mDepNameString.isEmpty {
                var size = mDepartmentMap[mDepNameString]?.count
                for var i = 0 ;i < size; i++ {
                    if mDepartmentMap[mDepNameString]?.objectAtIndex(i).getUserId() == mUser?.getUserId() {
                        mDepartmentMap[mDepNameString]?.removeObjectAtIndex(i)
                        break
                    }
                }
                
                /**跳转到DepartmentController,并传参数**/
            }
            var addId = "\(mUser!.getUserId())"
            var entity = ComFqHalcyonEntityChartEntity()
            entity.setMessageTypeWithInt(8)
            entity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            MessageTools.sendMessage(entity.description(), payLoad: "", type: 1, customId: addId, callBackTag: "", toUser: mUser)
            MessageTools.removeSimplechatList(addId)
            MessageTools.clearMessageCount(addId)
            self.navigationController?.popViewControllerAnimated(true)
            
        }else {
            loadingDialog?.close()
             /**发送message通知,跳到新朋友界面**/
            var addId = "\(mUser!.getUserId())"
            var entity = ComFqHalcyonEntityChartEntity()
            entity.setMessageTypeWithInt(7)
            entity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            MessageTools.sendMessage(entity.description(), payLoad: "", type: 1, customId: addId, callBackTag: "", toUser: mUser)
            MessageTools.removeSimplechatList(addId)
            self.navigationController?.pushViewController(NewFriendsViewController(), animated: true)
        }
    }
    
    /**设置随访**/
    @IBAction func settingFollowUp(sender: AnyObject) {
        var tmpUser = mUser as! ComFqHalcyonEntityContacts
        var isContacts = tmpUser.isKindOfClass(ComFqHalcyonEntityContacts)
        var misFriend = tmpUser.isFriend()
        if isContacts && misFriend {
             var patient = mUser as! ComFqHalcyonEntityContacts
            /**跳转到SelectFollowUpTemplate界面,并传参数**/
            var controller = SelectFollowUpTemplateViewController()
            controller.mPatient = patient
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    /**确定删除好友**/
    func deleteFriendOk() {
        deleteDialog?.close()
        addOrRefuseLogic = ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: Int32((mUser?.getUserId())!), withInt: (mUser?.getRole_type())!, withInt: Int32(mRelationId), withBoolean: false, withBoolean: true, withBoolean: true)
    }
    
    func deleteFriendCancle() {
        deleteDialog?.close()
    }
    
    @IBAction func sendMessageClick(sender: AnyObject) {
        var controller = SimpleChatViewController()
        controller.toUser = mUser
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("UserInfoCell") as? UserInfoCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("UserInfoCell", owner: self, options: nil)
            cell = nibs.lastObject as? UserInfoCell
        }
        var row = indexPath.row
        
        
        if  mUser?.getRole_type() == 1 {
            if row == 0 {
                cell?.tittle.text = "医院："
                 cell?.detail.text = mUser?.getHospital()
            }
            if row == 1 {
                cell?.tittle.text = "学科："
                cell?.detail.text = mUser?.getDepartment()
            }
            if row == 2 {
                cell?.tittle.text = "职务："
                cell?.detail.text = mUser?.getTitleStr()
            }
            if row == 3 {
                cell?.tittle.text = "简介："
                cell?.detail.text = mUser?.getDescription()
            }

        }
        
        if mUser?.getRole_type() == 3 {
            if row == 0 {
                cell?.tittle.text = "姓名："
                cell?.detail.text = mUser?.getName()
            }
            if row == 1 {
                cell?.tittle.text = "性别："
                cell?.detail.text = mUser?.getGenderStr()
            }
            if row == 2 {
                cell?.tittle.text = "简介："
                cell?.detail.text = mUser?.getDescription()
            }
        }

  
        return cell!

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == detailList.size() - 1 {
            return 100
        }
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Int(detailList.size())
    }
    
    
}
