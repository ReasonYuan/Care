//
//  MessageGetRecentContacts.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
var myChatList = NSMutableArray()
var myList = NSMutableArray()
var compareMap = Dictionary<String,AnyObject> ()
class MessageGetRecentContacts: NSObject ,IMGroupInfoUpdateDelegate,IMSDKCustomUserInfoDelegate,IMCustomUserInfoDelegate{
    
//    func initDelegate(){
//        IMMyselfInstance.customUserInfoDelegate = self
//        IMInstance.customUserInfoDelegate = self
//    }
    
    /**获取最近联系人列表**/
    func getRecentContacts(){
        var contactsList = IMMyselfInstance.recentContacts() as NSArray
        
        if  IMMyselfInstance.groupInitialized() {
            var myOwngroupList = IMMyselfInstance.myOwnGroupList() as NSArray
            var tmpgroupList = IMMyselfInstance.myGroupList() as NSArray
            for m in 0..<tmpgroupList.count {
                println((tmpgroupList[m]as NSString))
                var groupId = tmpgroupList[m] as NSString
                getGroupDetailWithGroupId(groupId)
                
            }
        }
        for i in 0..<contactsList.count {
            getUserDetailWithCustomUserId(contactsList[i] as String)
        }
    }
    
    /**获取某个已经存在用户的个人信息（包含自己）**/
    func getUserDetailWithCustomUserId(customUserID:String){
//        IMInstance.requestCustomUserInfoWithCustomUserID(strId)
        IMInstance.requestCustomUserInfoWithCustomUserID(customUserID, success: { (customUserInfo) -> Void in
            var chatUserInfo = ComFqHalcyonEntityChatUserInfo()
            chatUserInfo.setAtttributeByjsonStringWithNSString(customUserInfo)
            chatUserInfo.setCustomUserIdWithNSString(customUserID)
            var messageCount = UITools.getSimplechatList(customUserID).size()
            if messageCount > 0 {
                
                var lastMessage = (UITools.getSimplechatList(customUserID).getWithInt(messageCount - 1) as ComFqHalcyonEntityChartEntity).description()
                var json = FQJSONObject(NSString: lastMessage)
                var lastStr = json.optStringWithNSString("message", withNSString: "")
                var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
                var messageType = json.optIntWithNSString("messageType", withInt: 0)
                if messageType == 2 {
                    chatUserInfo.setLastMessageWithNSString("病案分享")
                }else if  messageType == 3 {
                    chatUserInfo.setLastMessageWithNSString("记录分享")
                }else {
                    chatUserInfo.setLastMessageWithNSString(lastStr)
                }
                chatUserInfo.setmSendTimeWithDouble(lastTimer)
                
                myChatList.addObject(customUserID)
                myList.addObject(chatUserInfo)
                compareMap.updateValue(chatUserInfo, forKey: customUserID)
                self.paixu(myList)
                NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: nil)
                println(myChatList)
                println(myList)
                println(compareMap)
            }
        }) { (error) -> Void in
            if error == "server unconnected" {
                IMMyselfInstance.loginWithTimeoutInterval(10, success: { () -> Void in
                    println("登录成功")
                    myList.removeAllObjects()
                    self.getRecentContacts()
                    }, failure: { (error) -> Void in
                        println("登录失败")
                })
            }
        }
    }
    
     /**获取某个不存在用户的个人信息（包含自己）**/
    func addNewUserDetailWithCustomUserId(customUserID:String,text:String){
        //        IMInstance.requestCustomUserInfoWithCustomUserID(strId)
        IMInstance.requestCustomUserInfoWithCustomUserID(customUserID, success: { (customUserInfo) -> Void in
            var chatUserInfo = ComFqHalcyonEntityChatUserInfo()
            chatUserInfo.setAtttributeByjsonStringWithNSString(customUserInfo)
            chatUserInfo.setCustomUserIdWithNSString(customUserID)
            var messageCount = UITools.getSimplechatList(customUserID).size()
            if messageCount > 0 {
                
               
                var json = FQJSONObject(NSString: text)
                var lastStr = json.optStringWithNSString("message", withNSString: "")
                var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
                var messageType = json.optIntWithNSString("messageType", withInt: 0)
                if messageType == 2 {
                    chatUserInfo.setLastMessageWithNSString("病案分享")
                }else if  messageType == 3 {
                    chatUserInfo.setLastMessageWithNSString("记录分享")
                }else {
                    chatUserInfo.setLastMessageWithNSString(lastStr)
                }
                chatUserInfo.setmSendTimeWithDouble(lastTimer)
                
                myChatList.addObject(customUserID)
                myList.addObject(chatUserInfo)
                compareMap.updateValue(chatUserInfo, forKey: customUserID)
                self.paixu(myList)
                println(myChatList)
                println(myList)
                println(compareMap)
                NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
                NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: nil)
            }
            }) { (error) -> Void in
                if error == "server unconnected" {
                    IMMyselfInstance.loginWithTimeoutInterval(10, success: { () -> Void in
                        println("登录成功")
                        myList.removeAllObjects()
                        self.getRecentContacts()
                        }, failure: { (error) -> Void in
                            println("登录失败")
                    })
                }
        }
    }

    
    /**获取已经存在群的chatuserinfo，并添加至聊天列表中**/
    func getGroupDetailWithGroupId(groupId:String){
        var info = IMInstance.groupInfoWithGroupID(groupId)
        if info != nil {
            var chatUserInfo = ComFqHalcyonEntityChatUserInfo()
            chatUserInfo.setChatTypeWithInt(2)
            chatUserInfo.setGroupIdWithNSString(info.groupID)
            if info.groupName.isEmpty {
                chatUserInfo.setNameWithNSString("\(info.customGroupInfo)发起的群聊")
            }else{
                chatUserInfo.setNameWithNSString(info.groupName)
            }
            
            var count = UITools.getMorechatList(info.groupID).size()
            if count > 0 {
                
                var entity = UITools.getMorechatList(info.groupID).getWithInt(count - 1) as ComFqHalcyonEntityChartEntity
                var lastMessage = entity.description()
                var json = FQJSONObject(NSString: lastMessage)
                var lastStr = json.optStringWithNSString("message", withNSString: "")
                var name = json.optStringWithNSString("userName", withNSString: "")
                var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
                var messageType = json.optIntWithNSString("messageType")
                
                if messageType == 1 {
                    chatUserInfo.setLastMessageWithNSString("\(name):\(lastStr)")
                }else if messageType == 2 {//病案
                    chatUserInfo.setLastMessageWithNSString("病案分享")
                }else if messageType == 3 {//记录
                    chatUserInfo.setLastMessageWithNSString("记录分享")
                }else if messageType == 6 {//名片
                    chatUserInfo.setLastMessageWithNSString("\(lastStr)")
                }
                
                chatUserInfo.setmSendTimeWithDouble(lastTimer)
                println(lastMessage)
            }
            myChatList.addObject(groupId)
            myList.addObject(chatUserInfo)
            compareMap.updateValue(chatUserInfo, forKey: groupId)
            
        }
    }
    
    /**获取一个不存在群的chatuserinfo，并添加至聊天列表中**/
    func addNewGroupDetailWithGroupId(groupId:String,text:String){
        var info = IMInstance.groupInfoWithGroupID(groupId)
        if info != nil {
            var chatUserInfo = ComFqHalcyonEntityChatUserInfo()
            chatUserInfo.setChatTypeWithInt(2)
            chatUserInfo.setGroupIdWithNSString(info.groupID)
            if info.groupName.isEmpty {
                chatUserInfo.setNameWithNSString("\(info.customGroupInfo)发起的群聊")
            }else{
                chatUserInfo.setNameWithNSString(info.groupName)
            }
            
  
            var json = FQJSONObject(NSString: text)
            var lastStr = json.optStringWithNSString("message", withNSString: "")
            var name = json.optStringWithNSString("userName", withNSString: "")
            var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
            var messageType = json.optIntWithNSString("messageType")
            
            if messageType == 1 {
                chatUserInfo.setLastMessageWithNSString("\(name):\(lastStr)")
            }else if messageType == 2 {//病案
                chatUserInfo.setLastMessageWithNSString("病案分享")
            }else if messageType == 3 {//记录
                chatUserInfo.setLastMessageWithNSString("记录分享")
            }else if messageType == 6 {//名片
                chatUserInfo.setLastMessageWithNSString("\(lastStr)")
            }
            
            chatUserInfo.setmSendTimeWithDouble(lastTimer)
            
            myChatList.addObject(groupId)
            myList.addObject(chatUserInfo)
            compareMap.updateValue(chatUserInfo, forKey: groupId)
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: nil)
        }
    }
    
    /**按时间排序**/
    func paixu(list:NSMutableArray){
        var sort = NSSortDescriptor(key: "mSendTime_", ascending: false)
        var sortDescriptions = NSMutableArray(array: [sort])
        var newList = list.sortedArrayUsingDescriptors(sortDescriptions)
        myList.removeAllObjects()
        myList.addObjectsFromArray(newList)

    }
    
    /**判断单个聊天用户或者群是否不存在聊天列表中**/
    func isExist(str:String) ->Bool{
        var exist = false
        for i  in 0..<myChatList.count {
            if str == myChatList[i] as String {
                exist = true
                break
            }else{
                exist = false
            }
        }
        return exist
    }
    
   
    func resetLastMessageForUnExistChatUserInfo(str:String,type:Int,text:String){
        if type == 2 {//群聊
            addNewGroupDetailWithGroupId(str, text: text)
        }else{//单聊
            addNewUserDetailWithCustomUserId(str, text: text)
        }
    }
    
    func resetLastMessageForExistChatUserInfo(str:String,text:String){
        var chatUserInfo =  compareMap[str] as ComFqHalcyonEntityChatUserInfo
        var type =  chatUserInfo.getChatType()
        if type == 2 {//群聊
            
            var json = FQJSONObject(NSString: text)
            var lastStr = json.optStringWithNSString("message", withNSString: "")
            var name = json.optStringWithNSString("userName", withNSString: "")
            var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
            var messageType = json.optIntWithNSString("messageType")
            
            if messageType == 1 {
                chatUserInfo.setLastMessageWithNSString("\(name):\(lastStr)")
            }else if messageType == 2 {//病案
                chatUserInfo.setLastMessageWithNSString("病案分享")
            }else if messageType == 3 {//记录
                chatUserInfo.setLastMessageWithNSString("记录分享")
            }else if messageType == 6 {//名片
                chatUserInfo.setLastMessageWithNSString("\(lastStr)")
            }
            
            chatUserInfo.setmSendTimeWithDouble(lastTimer)
        }else{//单聊
            var customUserID = str
            var json = FQJSONObject(NSString: text)
            var lastStr = json.optStringWithNSString("message", withNSString: "")
            var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
            var messageType = json.optIntWithNSString("messageType", withInt: 0)
            if messageType == 2 {
                chatUserInfo.setLastMessageWithNSString("病案分享")
            }else if  messageType == 3 {
                chatUserInfo.setLastMessageWithNSString("记录分享")
            }else {
                chatUserInfo.setLastMessageWithNSString(lastStr)
            }
            chatUserInfo.setmSendTimeWithDouble(lastTimer)
        }
        println(compareMap[str])
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: nil)

    }
    
    /**判断群聊与单聊是否存在，添加数据**/
    func compareForAllChatList(str:String,text:String,type:Int){
        var exis = isExist(str)
        if exis{
            resetLastMessageForExistChatUserInfo(str,text: text)
        }else{
           resetLastMessageForUnExistChatUserInfo(str, type: type, text: text)
        }
    }
    
    /**群主删除群通知每个群成员删除聊天列表中的该群信息**/
    func exitGroup(groupId:String){

        var chatentity = ComFqHalcyonEntityChartEntity()
        chatentity.setMessageTypeWithInt(8)
        
        IMMyselfInstance.sendText(chatentity.description(), toGroup: groupId)
    }
    
    /**删除本地群聊天列表和信息**/
    func deleteGroupMessage(groupId:String){
        myChatList.removeObject(groupId)
        var chatUserInfo = compareMap[groupId] as? ComFqHalcyonEntityChatUserInfo
        if chatUserInfo != nil {
             myList.removeObject(chatUserInfo!)
        }
       
        compareMap.removeAtIndex(compareMap.indexForKey(groupId)!)
        UITools.removeMorechatList(groupId)
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageController", object: self, userInfo: nil)

    }
    
}
