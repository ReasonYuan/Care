//
//  MessageInit.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
import RealmSwift
var receivedMessageCountGlobal:Int = 0
var receivedMessageCountContact:Int = 0

var unReadMessageCountGlobal:Int = 0

class MessageInit: NSObject,ComFqHalcyonLogic2ContactLogic_ContactLogicInterface,HIMSelfDelegate, HIMGroupDelegate{
    /*IMSDK初始化注册登录*/
    
    var timer:NSTimer?
    var request = HTTPTask()
    var pwStr = "\(ComFqLibToolsConstants.getUser().getUserId())"
    func testIMSDK(){
        
        if !MessageTools.isExperienceMode() {
            MessageTools.changeAppState(true, customUserId: "\(ComFqLibToolsConstants.getUser().getUserId())")
            
            //初始化消息SDK \(ComFqLibToolsConstants.getUser().getUserId())
            HitalesIMSDK.sharedInstance.login("authorization...", uuid: myDeviceToke, expires: "234234234", userid: "\(ComFqLibToolsConstants.getUser().getUserId())", success: { () -> Void in
                println("Test Login to socket server success!")
                }, failure: { (error:String) -> Void in
                    println("Test Login to socket server success!")
            })
            
            HitalesIMSDK.sharedInstance.himSelfDelegate = self
            HitalesIMSDK.sharedInstance.himGroupDelegate = self
            
            var contactLogic =  ComFqHalcyonLogic2ContactLogic(comFqHalcyonLogic2ContactLogic_ContactLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
            unReadMessageCountGlobal = MessageTools.getAllMessageCount()
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
            createTimer()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendImageSuccess:", name: ComFqHalcyonLogicPracticeUpLoadChatImageManager_IMAGE_SEND_SUCCESS_, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendImageFailed:", name: ComFqHalcyonLogicPracticeUpLoadChatImageManager_IMAGE_SEND_FAILD_, object: nil)
        }
    }
    
    func sendImageSuccess(notify:NSNotification){
        var obj = notify.object as! String
        var json = FQJSONObject(NSString: obj)
        var type = json.optIntWithNSString("type")
        var imageId = json.optIntWithNSString("imageId")
        var messageIndex = json.optIntWithNSString("messageIndex")
        var customId = json.optStringWithNSString("customId")
        
        if type == 1 {//群
            var date = NSDate().timeIntervalSince1970
            var entity = MessageTools.GetOneMessageContentForMessageIndex(Int(messageIndex), customId: customId)
            if entity != nil {
                entity!.setMessageImageIdWithInt(imageId)
                entity!.setSendImageTypeWithInt(0)
                MessageTools.getCurrentMessageEntityForMoreImage(entity!.description(), groupId: customId)
                entity!.setmSendTimeWithDouble(date)
                MessageTools.sendMessage(entity!.description(), payLoad: "", type: 2, customId: customId, callBackTag: "", toUser: nil)
                println(imageId)
            }
        }
        if type == 2 {//单人
            var toUserImageId = json.optIntWithNSString("toUserImageId")
            var toUserName = json.optStringWithNSString("toUserName")
            var toUser = ComFqHalcyonEntityPerson()
            toUser.setImageIdWithInt(toUserImageId)
            toUser.setNameWithNSString(toUserName)
            var date = NSDate().timeIntervalSince1970
            var entity = MessageTools.GetOneMessageContentForMessageIndex(Int(messageIndex), customId: customId)
            if entity != nil {
                entity!.setMessageImageIdWithInt(imageId)
                entity!.setSendImageTypeWithInt(0)
                MessageTools.getCurrentMessageEntityForSimpleImage(entity!.description(),customId:customId)
                entity!.setmSendTimeWithDouble(date)
                MessageTools.sendMessage(entity!.description(), payLoad: "", type: 1, customId: customId, callBackTag: "", toUser: toUser)
                println(imageId)
            }
            
        }
        
    }
    
    func sendImageFailed(notify:NSNotification){
        var obj = notify.object as! String
        var json = FQJSONObject(NSString: obj)
        var type = json.optIntWithNSString("type")
        var messageIndex = json.optIntWithNSString("messageIndex")
        var customId = json.optStringWithNSString("customId")
        if type == 1 {//群
            var entity = MessageTools.GetOneMessageContentForMessageIndex(Int(messageIndex), customId: customId)
            if entity != nil {
                MessageTools.getCurrentMessageEntityForMore(entity!.description(), groupId: customId)
            }
        }
        
        if type == 2 {//单人
            var entity = MessageTools.GetOneMessageContentForMessageIndex(Int(messageIndex), customId: customId)
            if entity != nil {
                MessageTools.getCurrentMessageEntityForSimple(entity!.description(), customId:customId)
            }
        }
    }
    
    /**生成一个timer检测userid和deviceToken**/
    func createTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "allIsExist", userInfo: nil, repeats: true)
    }
    
    func allIsExist(){
        if !myDeviceToke.isEmpty && ComFqLibToolsConstants.getUser().getUserId() != 0 {
            var customUserId = "\(ComFqLibToolsConstants.getUser().getUserId())"
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                let params: Dictionary<String,AnyObject> = ["user_id": customUserId, "token": myDeviceToke]
                self.request.POST("http://121.40.193.89:3000/users/uploadToken", parameters: params, completionHandler: {(response: HTTPResponse) in
                    if let err = response.error {
                        println("error: \(err.localizedDescription)")
                        return
                    }else{
                        
                    }
                    
                })
                
            }
            
            timer?.invalidate()
        }
    }
    
    func test(){
        
    }
    
    func onUpLoadSuccess() {
        println("调用注册推送的接口成功")
    }
    
    func onUpLoadFailWithInt(errorCode: Int32, withNSString msg: String!) {
        println("调用注册推送的接口失败\(msg)")
    }
    
    
    //获取好友列表成功回调
    func onDataReturnWithJavaUtilHashMap(mHashPeerList: JavaUtilHashMap!) {
        
    }
    
    
    //获取好友列表失败回调
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        
    }
    
    /**消息SDK接受群消息**/
    func didReceiveGroupText(text: String, payload: String, fromGroupId: String, fromUser: String, serverSendTime: UInt32) {
        println("收到消息----\(text)")
        MessageTools.setReceiveRecentContact(fromGroupId, text: text, chatType: 2)
        var type = FQJSONObject(NSString: text).optIntWithNSString("messageType")
        MessageTools.saveMorechatList(fromGroupId, text: text,success:true)
        if type != 7 && type != 8 {
            /**保存离线获取的消息条数**/
            var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
            var savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
            var messageCountList = FQJSONObject()
            
            if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
                var str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
                messageCountList = FQJSONObject(NSString: str)
            }
            
            messageCountList.putWithNSString(fromGroupId, withInt: messageCountList.optIntWithNSString(fromGroupId) + 1)
            ComFqLibFileHelper.saveFileWithNSString(messageCountList.description, withNSString: savePath, withBoolean: false)
            
            unReadMessageCountGlobal++
            
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: nil)
            
            
        }
    }
    
    /**消息SDK接受单个人消息**/
    func didReceiveText(fromUser: String, message: String, payload: String) {
        println("收到消息----\(message)")
        MessageTools.setReceiveRecentContact(fromUser, text: message, chatType: 1)
        MessageTools.saveSimplechatList(fromUser,text: message,success:true)
        var type = FQJSONObject(NSString: message).optIntWithNSString("messageType")
        if type != 7 && type != 8{
            var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
            var savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
            var messageCountList = FQJSONObject()
            
            if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
                var str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
                messageCountList = FQJSONObject(NSString: str)
            }
            
            unReadMessageCountGlobal++
            messageCountList.putWithNSString(fromUser, withInt: messageCountList.optIntWithNSString(fromUser) + 1)
            ComFqLibFileHelper.saveFileWithNSString(messageCountList.description, withNSString: savePath, withBoolean: false)
            
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: nil)
            
        }
        
    }
    
    /**消息SDK发送群消息成功的回调**/
    func didSendGroupText(text: String, toGroupId: String, clientSendTime: UInt32, callbackTag: String) {
        
        MessageTools.setSendRecentContact(toGroupId, text: text, chatType: 2, imageId: 0, name: "")
        var messageJson = FQJSONObject(NSString: text)
        var type = messageJson.optIntWithNSString("messageType")
        if type != 7 && type != 8{
            var message = messageJson.optStringWithNSString("message")
            if type == 2 {
                message = "您有新的病案分享"
            }else if type == 3 {
                message = "您有新的记录分享"
            }else if type == 4 {
                message = "您有新的图片分享"
            }
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                var json = FQJSONObject()
                json.putWithNSString("alert", withId: message)
                var jsonPayLoad = FQJSONObject()
                jsonPayLoad.putOptWithNSString("m", withId: "")
                json.putOptWithNSString("payload", withId: jsonPayLoad)
                let params: Dictionary<String,AnyObject> = ["user_id": self.getGroupMemberList(toGroupId), "msg": json.description()]
                self.request.POST("http://121.40.193.89:3000/users/pushNotification", parameters: params, completionHandler: {(response: HTTPResponse) in
                    
                    if let err = response.error {
                        println("error: \(err.localizedDescription)")
                        return
                    }else{
                        println("--------------------\(response.description)")
                    }
                    
                })
            }
            
        }
    }
    
    /**
    组装群成员信息给推送使用
    :param: groupId 群ID
    
    :returns: 群成员信息
    */
    func getGroupMemberList(groupId:String) ->String {
        var groupInfo = HitalesIMSDK.sharedInstance.getOneGroupDetail(groupId,mRealm:Realm(path: MessageTools.getHIMRootPath()))
        if let info = groupInfo {
            var members =  info.members
            var memberlist = NSMutableArray()
            for m in members {
                memberlist.addObject(m.memberUserId)
            }
            
            var str = "["
            for i in 0..<memberlist.count {
                
                if i == memberlist.count - 1 {
                    str = str + "\"" + (memberlist[i] as! String) + "\""
                }else{
                    str = str + "\"" + (memberlist[i] as! String) + "\"" + ","
                }
                
            }
            str = str + "]"
            return str
        }
        return ""
    }
    
    /**消息SDK发送群消息失败的回调**/
    func failedToSendGroupText(text: String, toGroupId: String, clientSendTime: UInt32, error: String, callbackTag: String) {
        MessageTools.setSendRecentContact(toGroupId, text: text, chatType: 2, imageId: 0, name: "")
        MessageTools.getCurrentMessageEntityForMore(text, groupId: toGroupId)
    }
    
    /**消息SDK发送单人消息成功的回调**/
    func didSendText(text: String, toUser: String, clientSendTime: UInt32, callbackTag: String) {
        var tagJson = FQJSONObject(NSString: callbackTag)
        var imageId = tagJson.optIntWithNSString("imageId")
        var name = tagJson.optStringWithNSString("name")
        MessageTools.setSendRecentContact(toUser, text: text, chatType: 1, imageId: Int(imageId), name: name)
        
        var messageJson = FQJSONObject(NSString: text)
        var type = messageJson.optIntWithNSString("messageType")
        if type != 7 && type != 8{
            var message = messageJson.optStringWithNSString("message")
            if type == 2 {
                message = "您有新的病案分享"
            }else if type == 3 {
                message = "您有新的记录分享"
            }else if type == 4 {
                message = "您有新的图片分享"
            }
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                var json = FQJSONObject()
                json.putWithNSString("alert", withId: message)
                var jsonPayLoad = FQJSONObject()
                jsonPayLoad.putOptWithNSString("m", withId: "")
                json.putOptWithNSString("payload", withId: jsonPayLoad)
                let params: Dictionary<String,AnyObject> = ["user_id":toUser, "msg": json.description()]
                println(params)
                self.request.POST("http://121.40.193.89:3000/users/pushNotification", parameters: params, completionHandler: {(response: HTTPResponse) in
                    
                    if let err = response.error {
                        println("error: \(err.localizedDescription)")
                        return
                    }else{
                        println("--------------------\(response.description)")
                    }
                    
                })
            }
            
        }
        
    }
    
    /**消息SDK发送单人消息失败的回调**/
    func failedToSendText(text: String, toUser: String, clientSendTime: UInt32, error: String, callbackTag: String) {
        var tagJson = FQJSONObject(NSString: callbackTag)
        var imageId = tagJson.optIntWithNSString("imageId")
        var name = tagJson.optStringWithNSString("name")
        MessageTools.setSendRecentContact(toUser, text: text, chatType: 1, imageId: Int(imageId), name: name)
        MessageTools.getCurrentMessageEntityForSimple(text, customId: toUser)
    }
    
    ////*本地数据：当发起刷新组信息时，每收到一个组信息就通知一次*/
    func didOneGroupUpdated(groupId:String) -> Void {
        println("didOneGroupUpdated: " + groupId)
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: ["sendUnReadMessageController":unReadMessageCountGlobal])
    }
    
    ////*本地数据：每当一个组被解散后，收到一次通知*/
    func didOneGroupDelete(groupId:String) -> Void {
        println("didOneGroupDelete: " + groupId)
        MessageTools.removeMorechatList(groupId)
        MessageTools.clearMessageCount(groupId)
        unReadMessageCountGlobal = MessageTools.getAllMessageCount()
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: ["sendUnReadMessageController":unReadMessageCountGlobal])
        
    }
    
    ////*本地数据：每当一个组被创建后，收到一次通知*/
    func didOneGroupCreate(groupId:String) -> Void {
        println("didOneGroupCreate: " + groupId)
        
    }
    
    ////*本地数据：当所有组信息同步完成后，收到一次通知，两种情况：1. app启动时会主动发起一次同步请求，2. 手动调用requestUpdateGroupInfo（）*/
    func didAllGroupsUpdateFinish() -> Void {
        println("didAllGroupsUpdateFinish")
        HitalesIMSDK.sharedInstance.getGroups()
    }
    
}
