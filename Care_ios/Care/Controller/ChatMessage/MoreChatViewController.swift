//
//  MoreChatViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
var shareGroupId:String = ""
var currentControllerIndex:Int = 0
var shareChatEntityList = JavaUtilArrayList()
var shareIsGroup = false
var isMe = false
var moreChatViewControllers = NSMutableArray()
var MoreChatViewControllerInstance:MoreChatViewController?
class MoreChatViewController: BaseViewController,UITextFieldDelegate,ComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface,ComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack{
    var groupId:String = ""
    var messageList = JavaUtilArrayList()
    
    var tittleStr:String = ""
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet var messageView: UIView!
    @IBOutlet weak var testTe: UITextField!
    var mIDCardmessageList = JavaUtilArrayList()
    var memberList = JavaUtilArrayList()
    
    
    var patientList = JavaUtilArrayList()
    var recordList = JavaUtilArrayList()
    
    var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
    var loadingDialog:CustomIOS7AlertView!
    var position:Int = 0
    var errorSendCount:Int = 0
    var actionSheet:UIActionSheet!
    
    var upLoadImageLogic:ComFqHalcyonLogicPracticeUpLoadChatImageLogic!
    
    var messageImageEntity:ComFqHalcyonEntityChartEntity!
    var imageList = JavaUtilArrayList()
    var imagesView:FullScreenImageZoomView!
    var userImageIdList = Dictionary<Int,Int>()
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle(tittleStr)
        setRightBtnTittle("管理")
        
        shareGroupId = groupId
        currentControllerIndex = self.navigationController!.viewControllers.count - 1
        
        messageTextField.delegate = self
        //        messageList = getMessageListFromLocalFile()
        userImageIdList = MessageTools.getGroupUserImageIdList(groupId)
        messageList = MessageTools.getMorechatList(groupId)
        self.tabView.registerNib(UINib(nibName: "SimpleChatViewCellTableViewCell", bundle:nil), forCellReuseIdentifier: "SimpleChatViewCellTableViewCell")
        self.tabView.registerNib(UINib(nibName: "SimpleChatRightCell", bundle:nil), forCellReuseIdentifier: "SimpleChatRightCell")
        
        self.messageView.frame = CGRectMake(0, ScreenHeight - 42, ScreenWidth, 117)
        self.view.addSubview(self.messageView)
        
        initAllTablewNib()
        self.tabView.reloadData()
        if (self.tabView.contentSize.height - self.tabView.bounds.size.height) > 0 {
            self.tabView.setContentOffset(CGPointMake(0,self.tabView.contentSize.height - self.tabView.bounds.size.height), animated: true)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendMoreMessageNotification:", name: "sendMoreMessage", object: nil)
        
        tabView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
        
        //标记当前界面位置、加好友使用
        nextPosition = self.navigationController?.viewControllers.count
        
         ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(groupId).checkWithComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack(self)
    }
    
    func initAllTablewNib(){
        tabView.registerNib(UINib(nibName: "SimpleChatViewCellTableViewCell", bundle:nil), forCellReuseIdentifier: "SimpleChatViewCellTableViewCell")
        tabView.registerNib(UINib(nibName: "SimpleChatRightCell", bundle:nil), forCellReuseIdentifier: "SimpleChatRightCell")
        tabView.registerNib(UINib(nibName: "ChatAddTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatAddTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatAnalysisRightTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatAnalysisRightTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatRecordRightTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatRecordRightTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatAnalysisTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatAnalysisTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatRecordTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatRecordTableViewCell")
        
        
        //注册通知,监听键盘弹出事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardWillShowNotification, object: nil)
        //注册通知,监听键盘消失事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**键盘出现后view上移*/
    func keyboardDidShow(notification:NSNotification){
        var d:NSDictionary! = notification.userInfo
        var kbSize:CGSize! = d.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue().size
        var height = ScreenHeight - 42
        messageView.frame = CGRectMake(0,height - kbSize.height, ScreenWidth, 117)
        tabView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 43 - 70 - kbSize.height)
        if (tabView.contentSize.height - tabView.bounds.size.height) > 0 {
            tabView.setContentOffset(CGPointMake(0,tabView.contentSize.height - tabView.bounds.size.height), animated: true)
        }
        
    }
    
    func keyboardDidHidden(notification:NSNotification){
        messageView.frame = CGRectMake(0, ScreenHeight - 42, ScreenWidth, 117)
        tabView.frame = CGRectMake(0,0, ScreenWidth, ScreenHeight - 43 - 70)
        if (tabView.contentSize.height - tabView.bounds.size.height) > 0 {
            tabView.setContentOffset(CGPointMake(0,tabView.contentSize.height - tabView.bounds.size.height), animated: true)
        }
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        MoreChatViewControllerInstance = nil
        MessageTools.clearMessageCount(groupId)
        unReadMessageCountGlobal = MessageTools.getAllMessageCount()
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
        shareGroupId = ""
        isMe = false
    }
    
    func tabViewTap(tapGesture:UITapGestureRecognizer){
        showOrHidenView(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var text = textField.text
        if !text.isEmpty {
            submitText()
        }
        textField.becomeFirstResponder()
        return false
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        isMe = false
        MoreChatViewControllerInstance = nil
        var controller = ManageGroupViewController()
        
        controller.mGroupId = groupId
        controller.mOldGroupName = tittleStr
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func sendMoreMessageNotification(notification:NSNotification) {
        messageList = MessageTools.getMorechatList(groupId)
        tabView.reloadData()
        if (tabView.contentSize.height - tabView.bounds.size.height) > 0 {
            tabView.setContentOffset(CGPointMake(0,tabView.contentSize.height - tabView.bounds.size.height), animated: true)
            
        }
    }
    
    @IBAction func sendOtherOnClick(sender: AnyObject) {
        showOrHidenView(false)
    }
    
    func showOrHidenView(yes:Bool){
        self.view.endEditing(true)
        if yes {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.messageView.frame = CGRectMake(0, ScreenHeight - 42, ScreenWidth, 117)
                self.tabView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight  - 70 - 43)
                if (self.tabView.contentSize.height - self.tabView.bounds.size.height) > 0 {
                    self.tabView.setContentOffset(CGPointMake(0,self.tabView.contentSize.height - self.tabView.bounds.size.height), animated: true)
                }
            })
            
        }else{

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.messageView.frame = CGRectMake(0, ScreenHeight - 116, ScreenWidth, 117)
                self.tabView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight -  70 - 116)
                if (self.tabView.contentSize.height - self.tabView.bounds.size.height) > 0 {
                    self.tabView.setContentOffset(CGPointMake(0,self.tabView.contentSize.height - self.tabView.bounds.size.height), animated: true)
                }
            })
        }
        
        
    }
    
    /*发送群文本消息*/
    func submitText(){
        var str =  messageTextField.text
        if count(str) > 0 {
            var messageEntity = ComFqHalcyonEntityChartEntity()
            messageEntity.setMessageTypeWithInt(1)
            messageEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
            messageEntity.setMessageWithNSString(str)
            messageEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            messageEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
            messageEntity.setMessageIndexWithInt(messageList.size())
            
            var date = NSDate().timeIntervalSince1970
            messageEntity.setmSendTimeWithDouble(date)
            messageList.addWithId(messageEntity)
            MessageTools.saveMorechatList(groupId,text: messageEntity.description(),success:true)
            
            sendMessageForEntity(messageEntity)
        }
        
        messageTextField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func getXibName() -> String {
        return "MoreChatViewController"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MoreChatViewControllerInstance = self
        if mIDCardmessageList.size() != 0 {
            sendIDCard(mIDCardmessageList)
        }
        
        if shareChatEntityList.size() != 0 {
            for i in 0..<shareChatEntityList.size() {
                var shareChatEntity:ComFqHalcyonEntityChartEntity! = shareChatEntityList.getWithInt(Int32(i)) as! ComFqHalcyonEntityChartEntity
                var date = NSDate().timeIntervalSince1970
                shareChatEntity.setmSendTimeWithDouble(date)
                shareChatEntity!.setMessageIndexWithInt(messageList.size())
                MessageTools.saveMorechatList(groupId,text: shareChatEntity!.description(),success:true)
                
                MessageTools.sendMessage(shareChatEntity.description(), payLoad: "", type: 2, customId: groupId, callBackTag: "", toUser: nil)
            }
            shareChatEntityList.clear()
        }
        
        if patientList.size() != 0 {
            sendPatientList()
        }
        
        if recordList.size() != 0 {
            sendReocordList()
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var row = indexPath.row
        var entity = (messageList.getWithInt(Int32(row))  as? ComFqHalcyonEntityChartEntity)
        var userId = entity?.getUserId()
        var messageType = entity?.getMessageType()
        var imageId:Int32 = 0
        if userImageIdList[Int(userId!)] != nil {
            imageId = Int32(userImageIdList[Int(userId!)]!)
        }
        if userId != ComFqLibToolsConstants.getUser().getUserId() {
            if messageType == 2 {
                let cellIdentifier: String = "ChatAnalysisTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAnalysisTableViewCell
                if cell == nil{
                    cell = ChatAnalysisTableViewCell()
                }
                cell?.sendTime.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                UITools.setRoundBounds(20.0, view: cell!.userHead)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.userHead)
                UITools.setRoundBounds(15.0, view: cell!.recordUserId)
                cell?.recordUserId.downLoadImageWidthImageId(entity?.getPatientHeadId(), callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                    
                })
                
                cell?.userHead.downLoadImageWidthImageId(imageId, callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                })
                
                cell?.recordCount.text = "\(entity!.getPatientRecordCount())记录"
                cell?.patientDetail.text =  entity?.getPatientName()
                cell?.patientDetail2.text = entity?.getPatientSecond()
                cell?.patientDetail3.text = entity?.getPatientThird()
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                cell?.bgBtn.tag = Int(indexPath.row)
                cell?.bgBtn.addTarget(self, action: "patientClick:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell!
            }else if messageType == 3 {
                let cellIdentifier: String = "ChatRecordTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatRecordTableViewCell
                if cell == nil{
                    cell = ChatRecordTableViewCell()
                }
                
                UITools.setRoundBounds(20.0, view: cell!.userHead)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.userHead)
                cell?.userHead.downLoadImageWidthImageId(imageId, callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                })
                cell?.sendTime.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                cell?.recordTime.text =  entity?.getRecordTime()
                cell?.recordMessage.text = entity?.getRecordContent()
                cell?.recordUserName.text = entity?.getRecordBelongName()
                cell?.recordType.text =  ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(entity!.getRecordType())
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                cell?.bgBtn.tag = Int(indexPath.row)
                cell?.bgBtn.addTarget(self, action: "recordClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                return cell!
                
            }else if messageType == 6 {
                let cellIdentifier: String = "ChatAddTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAddTableViewCell
                if cell == nil{
                    cell = ChatAddTableViewCell()
                }
                
                cell?.head.downLoadImageWidthImageId(imageId, callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                })
                cell?.inviteMessage.text = entity?.getMessage()
                cell?.name.text =  entity?.getUserName()
                cell?.hospital.text = entity?.getHospital()
                cell?.department.text = entity?.getDepartment()
                UITools.setRoundBounds(15.0, view: cell!.head)
                
                cell?.tag = Int(entity!.getUserId())
                cell?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "idCardTap:"))
                
                return cell!
                
            }else if messageType == 4 {
                let cellIdentifier: String = "SimpleChatViewCellTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? SimpleChatViewCellTableViewCell
                if cell == nil{
                    cell = SimpleChatViewCellTableViewCell()
                }
                var removeView:UIView?
                for views in cell!.subviews {
                    if (views as! UIView).tag == 1 {
                        removeView = (views as! UIView)
                    }
                }
                removeView?.removeFromSuperview()
                
                UITools.setRoundBounds(20.0, view: cell!.head)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.head)
                cell!.name.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                cell!.content.subviews.map{$0.removeFromSuperview()}
                cell!.head.downLoadImageWidthImageId(imageId, callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                    
                })
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                cell!.content.subviews.map{$0.removeFromSuperview()}
                
                var tmpView = UIView(frame: CGRectMake(56 + 9, 38,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
                var imageView = UIImageView(frame: CGRectMake(0, 0,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
                imageView.backgroundColor = Color.color_chat_left_color
                
                var imageBtn = UIButton(frame: imageView.frame)
                imageBtn.tag = indexPath.row
                imageBtn.addTarget(self, action: "imageBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
                var chatImage = UIImageView(frame: CGRectMake(5, 5, imageView.frame.size.width - 10, imageView.frame.size.height - 10))
                
                if entity!.getMessageImageId() != 0 {
                    chatImage.downLoadImageWidthImageId(entity?.getMessageImageId(), callback: { (view, path) -> Void in
                        var tmpView = view as! UIImageView
                        UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                            tmpView.image = image
                        })
                        
                    })
                    
                }
                imageView.addSubview(chatImage)
                tmpView.addSubview(imageView)
                tmpView.addSubview(imageBtn)
                cell!.addSubview(tmpView)
                tmpView.tag = 1
                UITools.setRoundBounds(3.0, view: imageView)
                return cell!
            }else{
                let cellIdentifier: String = "SimpleChatViewCellTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? SimpleChatViewCellTableViewCell
                if cell == nil{
                    cell = SimpleChatViewCellTableViewCell()
                }
                var removeView:UIView?
                for views in cell!.subviews {
                    if (views as! UIView).tag == 1 {
                        removeView = (views as! UIView)
                    }
                }
                removeView?.removeFromSuperview()
                
                UITools.setRoundBounds(20.0, view: cell!.head)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.head)
                cell!.name.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                cell!.content.subviews.map{$0.removeFromSuperview()}
                cell!.head.downLoadImageWidthImageId(imageId, callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                    
                })
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                if calculateHeightForCell(indexPath) < 18 {
                    
                    cell!.content.textAlignment = NSTextAlignment.Left
                    var width = calculateWidthForCell(indexPath)
                    
                    var textLabel = UILabel(frame: CGRectMake(5, 5, width, 18))
                    textLabel.text = entity?.getMessage()
                    textLabel.font = UIFont.systemFontOfSize(13.0)
                    textLabel.textColor = UIColor.blackColor()
                    
                    var imageView = UIImageView(frame: CGRectMake(0, 0,width + 10, 28))
                    imageView.backgroundColor = Color.color_chat_left_color
                    
                    imageView.addSubview(textLabel)
                    cell!.content.addSubview(imageView)
                    UITools.setRoundBounds(3.0, view: imageView)
                    
                }else{
                    
                    var textLabel =  UILabel(frame: CGRectMake(5, 5,ScreenWidth - 112 - 10, calculateHeightForCell(indexPath)))
                    textLabel.numberOfLines = 0
                    textLabel.font = UIFont.systemFontOfSize(13.0)
                    textLabel.text = entity?.getMessage()
                    textLabel.sizeToFit()
                    textLabel.textAlignment = NSTextAlignment.Left
                    textLabel.textColor = UIColor.blackColor()
                    
                    
                    var imageView = UIImageView(frame: CGRectMake(0, 0,ScreenWidth - 112, textLabel.frame.size.height + 10))
                    imageView.backgroundColor = Color.color_chat_left_color
                    
                    imageView.addSubview(textLabel)
                    cell!.content.addSubview(imageView)
                    UITools.setRoundBounds(3.0, view: imageView)
                    println("ccccccccccccccccccccc\(textLabel.frame.size.height)-----\(indexPath.row)")
                    
                }
                return cell!
            }
            
            
        }else{
            if messageType == 2{
                let cellIdentifier: String = "ChatAnalysisRightTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAnalysisRightTableViewCell
                if cell == nil{
                    cell = ChatAnalysisRightTableViewCell()
                }
                if !entity!.isSendSuccess() {
                    cell?.sendFailBtn.hidden = false
                }else{
                    cell?.sendFailBtn.hidden = true
                }
                cell?.sendTime.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                UITools.setRoundBounds(20.0, view: cell!.userHead)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.userHead)
                UITools.setRoundBounds(15.0, view: cell!.recordUserId)
                cell?.recordUserId.downLoadImageWidthImageId(entity?.getPatientHeadId(), callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                    
                })
                
                cell?.userHead.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                })
                
                cell?.recordCount.text = "\(entity!.getPatientRecordCount())记录"
                cell?.patientDetail.text =  entity?.getPatientName()
                cell?.patientDetail2.text = entity?.getPatientSecond()
                cell?.patientDetail3.text = entity?.getPatientThird()
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                cell?.bgBtn.tag = Int(indexPath.row)
                cell?.bgBtn.addTarget(self, action: "patientClick:", forControlEvents: UIControlEvents.TouchUpInside)
                return cell!
            }else if messageType == 3 {
                let cellIdentifier: String = "ChatRecordRightTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatRecordRightTableViewCell
                if cell == nil{
                    cell = ChatRecordRightTableViewCell()
                }
                if !entity!.isSendSuccess() {
                    cell?.sendFailBtn.hidden = false
                }else{
                    cell?.sendFailBtn.hidden = true
                }
                cell?.sendTime.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                UITools.setRoundBounds(20.0, view: cell!.userHead)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.userHead)
                cell?.userHead.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                })
                
                cell?.recordTime.text =  entity?.getRecordTime()
                cell?.recordMessage.text = entity?.getRecordContent()
                cell?.recordUserName.text = entity?.getRecordBelongName()
                cell?.recordType.text =  ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(entity!.getRecordType())
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                cell?.bgBtn.tag = Int(indexPath.row)
                cell?.bgBtn.addTarget(self, action: "recordClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                return cell!
                
            }else if messageType == 6 {
                let cellIdentifier: String = "ChatAddTableViewCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAddTableViewCell
                if cell == nil{
                    cell = ChatAddTableViewCell()
                }
                if !entity!.isSendSuccess() {
                    cell?.sendFailBtn.hidden = false
                }else{
                    cell?.sendFailBtn.hidden = true
                }
                cell?.head.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                })
                cell?.inviteMessage.text = entity?.getMessage()
                cell?.name.text =  entity?.getUserName()
                cell?.hospital.text = entity?.getHospital()
                cell?.department.text = entity?.getDepartment()
                UITools.setRoundBounds(15.0, view: cell!.head)
                cell?.tag = Int(entity!.getUserId())
                cell?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "idCardTap:"))
                return cell!
            }else if messageType == 4 {
                let cellIdentifier: String = "SimpleChatRightCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? SimpleChatRightCell
                if cell == nil{
                    cell = SimpleChatRightCell()
                }
                
                var removeView:UIView?
                var progressView:UIView?
                for views in cell!.subviews {
                    if (views as! UIView).tag == 1{
                        removeView = (views as! UIView)
                    }
                    if (views as! UIView).tag == 10 {
                        progressView = (views as! UIView)
                    }
                }
                removeView?.removeFromSuperview()
                progressView?.removeFromSuperview()
                
                cell?.sendTimerLabel.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                UITools.setRoundBounds(20.0, view: cell!.head)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.head)
                cell!.head.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                    
                })
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                cell!.content.subviews.map{$0.removeFromSuperview()}
                var tmpView = UIView(frame: CGRectMake(ScreenWidth - 65 - CGFloat(entity!.getImageWidth()), 38,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
                var imageView = UIImageView(frame: CGRectMake(0,0,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
                var imageBtn = UIButton(frame: imageView.frame)
                imageBtn.tag = indexPath.row
                //                imageBtn.backgroundColor = UIColor.redColor()
                imageBtn.addTarget(self, action: "imageBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
                imageView.backgroundColor = Color.color_chat_right_color
                if !entity!.isSendSuccess() {
                    var btnFailed = UIButton(frame: CGRectMake(-20,tmpView.frame.size.height/2 - 8, 15, 15))
                    btnFailed.setBackgroundImage(UIImage(named: "IM_chat_failed.png"), forState: UIControlState.Normal)
                    tmpView.addSubview(btnFailed)
                }
                
                var chatImage = UIImageView(frame: CGRectMake(5, 5, imageView.frame.size.width - 10, imageView.frame.size.height - 10))
                
                var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
                chatImage.image = UITools.getImageFromFile(path + entity!.getImagePath())
                
                if chatImage.image == nil {
                    chatImage.downLoadImageWidthImageId(entity?.getMessageImageId(), callback: { (view, path) -> Void in
                        var tmpView = view as! UIImageView
                        UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                            tmpView.image = image
                        })
                        
                    })
                    
                }
                imageView.addSubview(chatImage)
                tmpView.addSubview(imageView)
                tmpView.addSubview(imageBtn)
                cell!.addSubview(tmpView)
                tmpView.tag = 1
                UITools.setRoundBounds(3.0, view: imageView)
                tmpView.setTranslatesAutoresizingMaskIntoConstraints(false)
                cell!.addConstraint(NSLayoutConstraint(item: tmpView, attribute:
                    NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: cell!.content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: tmpView, attribute:
                    NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: cell!.content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
                cell!.addConstraint(NSLayoutConstraint(item: tmpView, attribute:
                    NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageWidth())))
                cell!.addConstraint(NSLayoutConstraint(item: tmpView, attribute:
                    NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageHeight())))
                if entity!.getSendImageType() == 1 {
                    var progress = UIProgressView(frame: CGRectMake(tmpView.frame.origin.x, tmpView.frame.origin.y + tmpView.frame.size.height, tmpView.frame.size.width, 2.0))
                    progress.tag = 10
                    cell!.addSubview(progress)
                }
                return cell!
            }else{
                let cellIdentifier: String = "SimpleChatRightCell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? SimpleChatRightCell
                if cell == nil{
                    cell = SimpleChatRightCell()
                }
                
                var removeView:UIView?
                var progressView:UIView?
                for views in cell!.subviews {
                    if (views as! UIView).tag == 1{
                        removeView = (views as! UIView)
                    }
                    if (views as! UIView).tag == 10 {
                        progressView = (views as! UIView)
                    }
                }
                removeView?.removeFromSuperview()
                progressView?.removeFromSuperview()
                
                cell?.sendTimerLabel.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
                UITools.setRoundBounds(20.0, view: cell!.head)
                UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.head)
                cell!.head.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                    var tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                    
                })
                
                cell?.headBtn.tag = Int(entity!.getUserId())
                cell?.headBtn.addTarget(self, action: "userHeadClick:", forControlEvents: UIControlEvents.TouchUpInside)
                
                cell!.content.subviews.map{$0.removeFromSuperview()}
                
                
                if calculateHeightForCell(indexPath) < 18 {
                    cell!.content.textAlignment = NSTextAlignment.Right
                    var width = calculateWidthForCell(indexPath)
                    
                    var textLabel = UILabel(frame: CGRectMake(5, 5, width, 18))
                    textLabel.text = entity?.getMessage()
                    textLabel.font = UIFont.systemFontOfSize(13.0)
                    textLabel.textColor = UIColor.whiteColor()
                    
                    var imageView = UIImageView(frame: CGRectMake(ScreenWidth - 112 - width  - 10, 0,width + 10, 28))
                    imageView.backgroundColor = Color.color_chat_right_color
                    if !entity!.isSendSuccess() {
                        var btnFailed = UIButton(frame: CGRectMake(imageView.frame.origin.x - 40, imageView.frame.origin.y + imageView.frame.size.height/2 - 8, 15, 15))
                        btnFailed.setBackgroundImage(UIImage(named: "IM_chat_failed.png"), forState: UIControlState.Normal)
                        cell!.content.addSubview(btnFailed)
                    }
                    
                    imageView.addSubview(textLabel)
                    cell!.content.addSubview(imageView)
                    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: cell!.content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: cell!.content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: (width + 10)))
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 28))
                    

                    UITools.setRoundBounds(3.0, view: imageView)
                }else{
                    
                    var textLabel =  UILabel(frame: CGRectMake(5, 5,ScreenWidth - 112 - 10, calculateHeightForCell(indexPath)))
                    textLabel.numberOfLines = 0
                    textLabel.font = UIFont.systemFontOfSize(13.0)
                    textLabel.text = entity?.getMessage()
                    textLabel.sizeToFit()
                    textLabel.textColor = UIColor.whiteColor()
                    
                    textLabel.textAlignment = NSTextAlignment.Left
                    var imageView = UIImageView(frame: CGRectMake(0, 0,ScreenWidth - 112 , textLabel.frame.size.height + 10))
                    imageView.backgroundColor = Color.color_chat_right_color
                    if !entity!.isSendSuccess() {
                        var btnFailed = UIButton(frame: CGRectMake(imageView.frame.origin.x - 40, imageView.frame.origin.y + imageView.frame.size.height/2 - 8, 15, 15))
                        btnFailed.setBackgroundImage(UIImage(named: "IM_chat_failed.png"), forState: UIControlState.Normal)
                        cell!.content.addSubview(btnFailed)
                    }
                    
                    imageView.addSubview(textLabel)
                    cell!.content.addSubview(imageView)
                    UITools.setRoundBounds(3.0, view: imageView)
                    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: cell!.content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: cell!.content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: ScreenWidth - 112))
                    cell!.content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                        NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: textLabel.frame.size.height + 10))
                    println("ccccccccccccccccccccc\(textLabel.frame.size.height)-----\(indexPath.row)")
                }
                return cell!
            }
            
            
        }
  
    }
    
    /**图片点击事件**/
    func imageBtnClick(sender:UIButton){
        var row = sender.tag
        var entity = (messageList.getWithInt(Int32(row))  as? ComFqHalcyonEntityChartEntity)
        var imageId = entity!.getMessageImageId()
        var imageList = [ComFqHalcyonEntityPhotoRecord]()
        var photoRecord = ComFqHalcyonEntityPhotoRecord()
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
        photoRecord.setImageIdWithInt(imageId)
        photoRecord.setLocalPathWithNSString(path + entity!.getImagePath())
        imageList.append(photoRecord)
        println(imageId)
        println(path + entity!.getImagePath())
        showImages(imageList)
    }
    
    func showImages(imageList:Array<ComFqHalcyonEntityPhotoRecord>){
        if imagesView != nil {
            imagesView.removeFromSuperview()
            imagesView = nil
        }
        if imagesView == nil {
            imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
            self.view.addSubview(imagesView)
        }
        
        var pagePhotoRecords = imageList
        if pagePhotoRecords.count > 0 {
            imagesView.setDatas(0, pagePhotoRecords: pagePhotoRecords)
            imagesView.showOrHiddenView(true)
        }
        
    }
    
    /**名片的tap点击事件**/
    func idCardTap(idCardTap:UITapGestureRecognizer){
        var userId = idCardTap.view!.tag
        var controller:UserInfoViewController = UserInfoViewController()
        var contact = ComFqHalcyonEntityContacts()
        contact.setUserIdWithInt(Int32(userId))
        controller.mUser = contact
        self.navigationController?.pushViewController(controller, animated: true)
        println(userId)
        println(userId)
    }
    
    /**普通对话头像点击事件**/
    func userHeadClick(sender:UIButton){
        var userId = sender.tag
        var controller:UserInfoViewController = UserInfoViewController()
        var contact = ComFqHalcyonEntityContacts()
        contact.setUserIdWithInt(Int32(userId))
        controller.mUser = contact
        self.navigationController?.pushViewController(controller, animated: true)
        println(userId)
    }
    
    /**病案点击事件**/
    func patientClick(sender:UIButton){
        return
    }
    
    /**记录点击事件**/
    func recordClick(sender:UIButton){
        return
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        showOrHidenView(true)
        var entity = (messageList.getWithInt(Int32(indexPath.row))  as? ComFqHalcyonEntityChartEntity)
        var messageType = entity?.getMessageType()
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var row =  indexPath.row
        var entity = (messageList.getWithInt(Int32(row))  as? ComFqHalcyonEntityChartEntity)
        var userId = entity?.getUserId()
        var messageType = entity?.getMessageType()
        
        if messageType == 2 || messageType == 3 {
            return 120
        }else if messageType == 6 {
            return 105
        }else if messageType == 4 {
            return CGFloat(entity!.getImageHeight() + 38 + 26)
        }else{
            if calculateHeightForCell(indexPath) <= 32 {
                return (70 + 10)
            }else{
                println("hhhhhhhhhhhhhh\(calculateHeightForCell(indexPath))-----\(indexPath.row)")
                return (calculateHeightForCell(indexPath) + 38 + 26)
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(messageList.size())
    }
    
    func calculateHeightForCell(indexPath:NSIndexPath) -> CGFloat{
        var row =  indexPath.row
        var contentLabel = UILabel(frame: CGRectMake(0, 0, ScreenWidth - 112 - 10, 17.95))
        contentLabel.font = UIFont.systemFontOfSize(13.0)
        contentLabel.numberOfLines = 0
        
        var entity = (messageList.getWithInt(Int32(row))  as? ComFqHalcyonEntityChartEntity)
        contentLabel.text = entity?.getMessage()
        contentLabel.sizeToFit()
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        var width = contentLabel.frame.size.width
        var contentString:NSString = contentLabel.text!
        var contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(width, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        var contentHeight = contentLableSize.height
        
        var textLabel =  UILabel(frame: CGRectMake(5, 5,ScreenWidth - 112 - 10, contentHeight))
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFontOfSize(13.0)
        textLabel.text = entity?.getMessage()
        textLabel.sizeToFit()
        
        return textLabel.frame.size.height
    }
    
    func calculateWidthForCell(indexPath:NSIndexPath) -> CGFloat{
        var row =  indexPath.row
        var contentLabel = UILabel(frame: CGRectMake(0, 0, ScreenWidth - 112 - 10, 17.95))
        contentLabel.font = UIFont.systemFontOfSize(13.0)
        contentLabel.numberOfLines = 0
        
        var entity = (messageList.getWithInt(Int32(row))  as? ComFqHalcyonEntityChartEntity)
        contentLabel.text = entity?.getMessage()
        contentLabel.sizeToFit()
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        var attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        var height = contentLabel.frame.size.height
        var contentString:NSString = contentLabel.text!
        var contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(CGFloat(MAXFLOAT),height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        var contentWidth = contentLableSize.width
        
        return contentWidth
    }
    /**选择病案**/
    @IBAction func patientOnclick(sender: AnyObject) {
        shareIsGroup = true
        var controller = ChartExploreViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func sendMessageForEntity(messageEntity:ComFqHalcyonEntityChartEntity){
         MessageTools.sendMessage(messageEntity.description(), payLoad: "", type: 2, customId: groupId, callBackTag: "", toUser: nil)
    }
    
    var IdcardCount = 0
    /**发送名片**/
    func sendIDCard(cardList:JavaUtilArrayList){
        var countSize = cardList.size()
        for i in 0..<countSize {
            var messageEntity = cardList.getWithInt(i) as! ComFqHalcyonEntityChartEntity
            var date = NSDate().timeIntervalSince1970
            messageEntity.setmSendTimeWithDouble(date)
            messageEntity.setMessageIndexWithInt(messageList.size())
            
            MessageTools.saveMorechatList(groupId,text: messageEntity.description(),success:true)
            MessageTools.sendMessage(messageEntity.description(), payLoad: "", type: 2, customId: groupId, callBackTag: "", toUser: nil)
        }
        mIDCardmessageList.clear()
    }
    
    /**发送病案列表**/
    func sendPatientList(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("病案发送中...")
        var isSend:Int32 = 0
        if allDidSendInfo {
            isSend = 0
        }else{
            isSend = 1
        }
        for i in 0..<patientList.size() {
            var patientabstract =  patientList.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract
            sendPatientLogic.sendPatientToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withNSString: groupId, withInt: patientabstract.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:patientabstract,withInt:isSend)
            
            
        }
        patientList.clear()
    }
    
    /**发送记录列表**/
    func sendReocordList(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("记录发送中...")
        var isSend:Int32 = 0
        if allDidSendInfo {
            isSend = 0
        }else{
            isSend = 1
        }
        for i in 0..<recordList.size() {
            var recordabstract =  recordList.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordAbstract
            sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: groupId, withInt: recordabstract.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:recordabstract,withInt:isSend)
        }
        recordList.clear()
    }
    
    func onSendPatientErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        if position == Int(patientList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                self.view.makeToast("您有\(errorSendCount)份病案分享失败！")
            }
        }else{
            position++
            errorSendCount++
        }
        
        
    }
    
    
    func onSendPatientSuccessWithInt(shareMessageId: Int32, withInt sharePatientId: Int32,withComFqHalcyonEntityPracticePatientAbstract obj: ComFqHalcyonEntityPracticePatientAbstract!) {
        var date = NSDate().timeIntervalSince1970
        var chatEntity = ComFqHalcyonEntityChartEntity()
        chatEntity.setmSendTimeWithDouble(date)
        chatEntity.setSharemessageIdWithInt(shareMessageId)
        chatEntity.setSharePatientIdWithInt(sharePatientId)
        chatEntity.setPatientHeadIdWithInt(obj!.getUserImageId())
        chatEntity.setPatientNameWithNSString(obj!.getShowName())
        chatEntity.setPatientSecondWithNSString(obj!.getShowSecond())
        chatEntity.setPatientThirdWithNSString(obj!.getShowThrid())
        chatEntity.setPatientRecordCountWithInt(obj!.getRecordCount())
        chatEntity.setMessageTypeWithInt(2)
        chatEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
        chatEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
        chatEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
        chatEntity.setMessageIndexWithInt(messageList.size())
        
        MessageTools.saveMorechatList(groupId,text: chatEntity.description(),success:true)
        MessageTools.sendMessage(chatEntity.description(), payLoad: "", type: 2, customId: groupId, callBackTag: "", toUser: nil)
        if position == Int(patientList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                self.view.makeToast("您有\(errorSendCount)份病案分享失败！")
            }
        }else{
            position++
        }
        
        
    }
    
    func onSendRecordErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        if position == Int(recordList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                self.view.makeToast("您有\(errorSendCount)份记录分享失败！")
            }
        }else{
            position++
            errorSendCount++
        }
        
    }
    
    
    
    
    func onSendRecordSuccessWithInt(shareMessageId: Int32, withInt shareRecordItemId: Int32, withFQJSONArray shareRecordInfIds: FQJSONArray!, withComFqHalcyonEntityPracticeRecordAbstract obj: ComFqHalcyonEntityPracticeRecordAbstract!) {
        for m in 0..<shareRecordInfIds.length() {
            var date = NSDate().timeIntervalSince1970
            var chatEntity = ComFqHalcyonEntityChartEntity()
            chatEntity.setmSendTimeWithDouble(date)
            chatEntity.setSharemessageIdWithInt(shareMessageId)
            chatEntity.setShareRecordItemIdWithInt(shareRecordItemId)
            chatEntity.setRecordInfoIdWithInt(shareRecordInfIds.optIntWithInt(m))
            chatEntity.setRecordTypeWithInt(obj.getRecordType())
            chatEntity.setRecordTimeWithNSString(obj.getDealTime())
            chatEntity.setRecordBelongNameWithNSString(obj.getRecordItemName())
            chatEntity.setRecordContentWithNSString(obj.getInfoAbstract())
            chatEntity.setMessageTypeWithInt(3)
            chatEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
            chatEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            chatEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
            
            chatEntity.setMessageIndexWithInt(messageList.size())
            
            MessageTools.saveMorechatList(groupId,text: chatEntity.description(),success:true)
            MessageTools.sendMessage(chatEntity.description(), payLoad: "", type: 2, customId: groupId, callBackTag: "", toUser: nil)
        }
        if position == Int(recordList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                self.view.makeToast("您有\(errorSendCount)份记录分享失败！")
            }
        }else{
            position++
        }
    }
    
    /**选择照片**/
    @IBAction func sendPicture(sender: AnyObject) {
        actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍摄", "从本地相册选择")
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            println("点击拍照")
            Tools.Post({ () -> Void in
                self.cameraClick()
                }, delay: 0.5)
            
        }
        if buttonIndex == 2 {
            println("点击从相册选择")
            Tools.Post({ () -> Void in
                self.photoClick()
                }, delay: 0.5)
            
        }
        actionSheet.dismissWithClickedButtonIndex(buttonIndex, animated: true)
    }
    
    /**进入系统拍照界面**/
    func cameraClick() {
        var sourcetype = UIImagePickerControllerSourceType.Camera
        var controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false//设置可编辑
        controller.sourceType = sourcetype
        self.presentViewController(controller, animated: true, completion: nil)//进入照相界面
    }
    
    /**进入系统选择照片界面**/
    func photoClick() {
        var pickImageController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
        }
        pickImageController.delegate = self
        pickImageController.allowsEditing = false
        self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册界面
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image =  info[UIImagePickerControllerOriginalImage] as! UIImage
        var data = UIImageJPEGRepresentation(image, 0.5)
        var height:CGFloat = 0
        var width:CGFloat = 0
        if (image.size.width/image.size.height) > (ScreenWidth/ScreenHeight) {
            width = ScreenWidth / 4
            height = width * image.size.height / image.size.width
        }else{
            height = ScreenHeight / 4
            width = height * image.size.width / image.size.height
        }
        
        println("hhhhhhhhhhhhhhhhhhhh---\(height)---wwwwwwwwwww---\(width)")
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
        var date = NSDate().timeIntervalSince1970
        var name = "\(date)"
        var success =  UIImageManager.saveImageToLocal(image, path:path, imageName: name)
        
        messageImageEntity = ComFqHalcyonEntityChartEntity()
        messageImageEntity.setMessageTypeWithInt(4)
        messageImageEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
        messageImageEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
        messageImageEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
        messageImageEntity.setMessageIndexWithInt(messageList.size())
        messageImageEntity.setImagePathWithNSString(name)
        messageImageEntity.setImageWidthWithFloat(Float(width))
        messageImageEntity.setImageHeightWithFloat(Float(height))
        messageImageEntity.setSendImageTypeWithInt(1)
        messageImageEntity.setmSendTimeWithDouble(date)
        
        messageList.addWithId(messageImageEntity)
        
        MessageTools.saveMorechatList(groupId,text: messageImageEntity.description(),success:true)
        MessageTools.setSendRecentContact(groupId, text: messageImageEntity.description(), chatType: 2, imageId: 0, name: "")
        
         ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(groupId).upLoadImageWithNSString(path + name, withInt: messageImageEntity.getMessageIndex(), withComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack: self, withNSString: groupId,withInt:1,withInt:0,withNSString:"")
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onUpLoadChatImageSuccessWithInt(imageId: Int32, withInt messageIndex: Int32) {
        
    }
    
    func onProcessWithFloat(process: Float, withInt messageIndex: Int32) {
        var row = messageIndex
        if  tabView.cellForRowAtIndexPath(NSIndexPath(forRow: Int(row), inSection: 0)) != nil {
            var cell =  tabView.cellForRowAtIndexPath(NSIndexPath(forRow: Int(row), inSection: 0)) as! SimpleChatRightCell
            (cell.subviews.last as! UIProgressView).progress = process
            println(process)
            if process == 1.0 {
                (cell.subviews.last as! UIProgressView).removeFromSuperview()
            }
            
        }
    }
    
    func onUpLoadChatImageFailedWithInt(errorCode: Int32, withNSString msg: String!, withInt messageIndex: Int32) {
        
    }

    
    
    
}
