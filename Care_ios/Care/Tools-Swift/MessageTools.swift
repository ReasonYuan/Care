//
//  MessageTools.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/9/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation
import UIKit
import HitalesSDK
import RealmSwift
class MessageTools:NSObject{
    /**格式化时间戳**/
    class func dateFormatTimer(time:Double) -> String{
        var date:NSDate = NSDate(timeIntervalSince1970: time)
        var formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        var dateString = formatter.stringFromDate(date)
        return dateString
    }
    
    /**只适用于聊天列表界面**/
    class func compareTimeWithToday(time:String) -> String{
        if count(time) > 8 {
            var date:NSDate = NSDate()
            var formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            var dateString = formatter.stringFromDate(date)
            var strDate = (dateString as NSString).substringToIndex(10)
            var curDate = (time as NSString).substringToIndex(10)
            var timeStr = (time as NSString).substringFromIndex(10)
            if strDate != curDate {
                return curDate
            }else{
                return timeStr
            }
            
        }else{
            return ""
        }
        
    }
    
    /**清楚某个群或者单人未读消息数字**/
    class func clearMessageCount(strId:String) ->FQJSONObject {
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageCountList = FQJSONObject()
        
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            var str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageCountList = FQJSONObject(NSString: str)
        }
        
        messageCountList.putWithNSString(strId, withInt: 0)
        ComFqLibFileHelper.saveFileWithNSString(messageCountList.description(), withNSString: savePath, withBoolean: false)
        return messageCountList
    }
    
    /**获取未读消息数目json**/
    class func getMessageJson() ->FQJSONObject {
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageJson = FQJSONObject()
        
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            var str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageJson = FQJSONObject(NSString: str)
        }
        
        return messageJson
    }
    
    /**获取某个聊天未读消息数**/
    class func getOneMessageCount(strId:String) ->Int {
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageCountList = FQJSONObject()
        
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            var str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageCountList = FQJSONObject(NSString: str)
        }
        var count = Int(messageCountList.optIntWithNSString(strId))
        return count
    }
    
    /**保存未读消息数目json文件**/
    class func saveAllMessageJson(json:FQJSONObject){
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        ComFqLibFileHelper.saveFileWithNSString(json.description, withNSString: savePath, withBoolean: false)
    }
    
    /**获取所有未读消息数目**/
    class func getAllMessageCount() ->Int {
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageCountList = FQJSONObject()
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            var str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageCountList = FQJSONObject(NSString: str)
        }
        var iterator = messageCountList.keys()
        var count = 0
        while(iterator.hasNext()){
            var key = iterator.next() as! String
            count += Int(messageCountList.optIntWithNSString(key))
        }
        return count
    }
    
    /**保存一条群消息记录**/
    class func saveMorechatList(groupID:String,text:String,success:Bool){
        var messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        messageEntity.setSendSuccessWithBoolean(success)
        var type = messageEntity.getMessageType()
        insertMessage(groupID, content: text, type: Int(type), messageIndex: Int(messageEntity.getMessageIndex()))
        NSNotificationCenter.defaultCenter().postNotificationName("sendMoreMessage", object: self, userInfo: ["sendMoreMessage":text])
    }
    
    /**保存一条单人聊天消息记录**/
    class func saveSimplechatList(customId:String,text:String,success:Bool){
        var messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        messageEntity.setSendSuccessWithBoolean(success)
        var type = messageEntity.getMessageType()
        
        if type != 7 && type != 8 {
            insertMessage(customId, content: text, type: Int(type), messageIndex: Int(messageEntity.getMessageIndex()))
            NSNotificationCenter.defaultCenter().postNotificationName("sendSimpleMessage", object: self, userInfo: ["sendSimpleMessage":text])
            
        }else{
            if type == 7 {
                if messageEntity.getUserId() != ComFqLibToolsConstants.getUser().getUserId() {
                    receivedMessageCountGlobal++
                    receivedMessageCountContact++
                    NSNotificationCenter.defaultCenter().postNotificationName("sendAddFriendMessage", object: self, userInfo: ["sendAddFriendMessage":receivedMessageCountGlobal])
                    NSNotificationCenter.defaultCenter().postNotificationName("sendAddFriendMessageToContact", object: self, userInfo: ["sendAddFriendMessageToContact":receivedMessageCountContact])
                    MessageTools.removeSimplechatList(customId)
                }
            }else if type == 8 {
                //删除本地对方的最近联系人、聊天记录
                
                var entity = ComFqHalcyonEntityChartEntity()
                entity.setAtttributeByjsonStringWithNSString(text)
                clearMessageCount(customId)
                removeSimplechatList(customId)
                
            }
            
            
        }
        
        
    }
    
    /**获取单人聊天的每个聊天实体类,并将发送状态置为false，即失败**/
    class func getCurrentMessageEntityForSimple(text:String,customId:String){
        var messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        var currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(false)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: customId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendSimpleMessage", object: self, userInfo: ["sendSimpleMessage":text])
        
    }
    
    /**获取单人聊天的每个聊天实体类,将图片发送状态置为progress隐藏**/
    class func getCurrentMessageEntityForSimpleImage(text:String,customId:String){
        var messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        var currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(true)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: customId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendSimpleMessage", object: self, userInfo: ["sendSimpleMessage":text])
    }
    
    
    /**获取群聊的每个聊天实体类**/
    class func getCurrentMessageEntityForMore(text:String,groupId:String){
        var messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        var currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(false)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: groupId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendMoreMessage", object: self, userInfo: ["sendMoreMessage":text])
        
    }
    
    /**获取群聊的每个聊天实体类,将发送图片的progress隐藏**/
    class func getCurrentMessageEntityForMoreImage(text:String,groupId:String){
        var messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        var currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(true)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: groupId, content: messageEntity.description())
        
        NSNotificationCenter.defaultCenter().postNotificationName("sendMoreMessage", object: self, userInfo: ["sendMoreMessage":text])
        
    }
    
    /**获取群聊天记录**/
    class func getMorechatList(groupID:String) ->JavaUtilArrayList {
        var list = JavaUtilArrayList()
        list = getMessageList(groupID)
        
        return list
    }
    
    /**获取单人聊天记录**/
    class func getSimplechatList(customId:String) ->JavaUtilArrayList {
        var list = JavaUtilArrayList()
        list = getMessageList(customId)
        return list
    }
    
    /**删除单人聊天记录**/
    class func removeSimplechatList(customId:String) {
        deleteMessageTab(customId)
        deleteRecentContact(customId)
    }
    
    /**删除群聊天记录**/
    class func removeMorechatList(groupId:String){
        deleteMessageTab(groupId)
        deleteRecentContact(groupId)
    }
    
    /**清楚聊天列表缓存**/
    class func clearMessageCatch(){
        mydictionary.removeAll(keepCapacity: true)
        groupList.removeAllObjects()
        mTmpcontactsList.removeAllObjects()
        mTmpgroupList.removeAllObjects()
        mTmpMessageList.removeAllObjects()
        
    }
    
    /**是否为体验模式，根据登录手机号进行的判断**/
    class func isExperienceMode(nav:UINavigationController) ->Bool {
        
        if ComFqLibToolsConstants_isVisitor_ {
            UIAlertViewTool.getInstance().showRegisterDialog("要体验更多功能请先注册",nav:nav)
            return true
        }else{
            return false
        }
    }
    
    /**是否为体验模式，根据登录手机号进行的判断**/
    class func isExperienceMode() ->Bool {
        if ComFqLibToolsConstants_isVisitor_ {
            return true
        }else{
            return false
        }
    }
    
    /**体验模式提醒注册的dialog*/
    class func experienceDialog(nav:UINavigationController) {
        UIAlertViewTool.getInstance().showRegisterDialog("要体验更多功能请先注册",nav:nav)
    }
    
    
    /**改变app在服务器的状态，前台还是后台**/
    class func changeAppState(isActive:Bool,customUserId:String){
        var request = HTTPTask()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let params: Dictionary<String,AnyObject> = ["user_id": customUserId, "is_active": isActive]
            request.POST("http://121.40.193.89:3000/users/changeAppRunningStatus", parameters: params, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    println("error: \(err.localizedDescription)")
                    return
                }else{
                    
                }
                
            })
            
        }
    }
    
    /**退出app,清楚聊天列表缓存，注销deviceToken，IMSDK——logout**/
    class func exitApp(){
        MessageTools.clearMessageCatch()
        MessageTools.himSDKLogout()
        var request = HTTPTask()
        var customUserId = "\(ComFqLibToolsConstants.getUser().getUserId())"
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let params: Dictionary<String,AnyObject> = ["user_id": customUserId, "token": "xiwang"]
            request.POST("http://121.40.193.89:3000/users/uploadToken", parameters: params, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    println("error: \(err.localizedDescription)")
                    return
                }else{
                    
                }
                
            })
            
        }
        
    }
    /**获取最新的群聊天头像id列表**/
    class func getGroupUserImageIdList(grouId:String) ->Dictionary<Int,Int> {
        var dictionAry = Dictionary<Int,Int>()
        var messageList = getMorechatList(grouId)
        if messageList.size() > 0 {
            for i in 0..<messageList.size() {
                var chatEntity = messageList.getWithInt(messageList.size() - i - 1) as! ComFqHalcyonEntityChartEntity
                var userId = chatEntity.getUserId()
                var imageId = chatEntity.getUserImageId()
                if dictionAry[Int(userId)] == nil {
                    dictionAry[Int(userId)] = Int(imageId)
                }
            }
            
        }
        return dictionAry
    }
    
    /**获取最新的单聊头像id**/
    class func getCustomUserImageId(customUserId:String) ->Int {
        var tmpImageId:Int = 0
        var messageList = getSimplechatList(customUserId)
        if messageList.size() > 0 {
            for i in 0..<messageList.size() {
                var chatEntity = messageList.getWithInt(messageList.size() - i - 1) as! ComFqHalcyonEntityChartEntity
                var userId = chatEntity.getUserId()
                var imageId = chatEntity.getUserImageId()
                if userId != ComFqLibToolsConstants.getUser().getUserId() {
                    tmpImageId = Int(imageId)
                    return tmpImageId
                }
            }
            
        }
        return tmpImageId
    }
    
    /**获取单聊指定条数聊天记录**/
    class func getChatSimpleList(currenIndex:Int,customId:String) ->JavaUtilArrayList {
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var saveMessageListPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/\(customId)"
        
        var list = JavaUtilArrayList()
        if ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) != nil{
            list = ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) as! JavaUtilArrayList
        }
        
        if list.size() > 10 {
            var tmpList = JavaUtilArrayList()
            for i in 0..<list.size(){
                if Int(i) >= currenIndex {
                    tmpList.addWithId(list.getWithInt(i) as! ComFqHalcyonEntityChartEntity)
                }
            }
            
            return tmpList
        }else{
            return list
        }
    }
    
    /**获取群聊指定条数聊天记录**/
    class func getChatMoreList(currenIndex:Int,groupId:String) ->JavaUtilArrayList {
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var saveMessageListPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/\(groupId)"
        
        var list = JavaUtilArrayList()
        if ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) != nil{
            list = ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) as! JavaUtilArrayList
        }
        
        if list.size() > 10 {
            var tmpList = JavaUtilArrayList()
            for i in 0..<list.size(){
                if Int(i) >= currenIndex {
                    tmpList.addWithId(list.getWithInt(i) as! ComFqHalcyonEntityChartEntity)
                }
            }
            
            return tmpList
        }else{
            return list
        }
    }
    
    class func getUnreadMessageCountWithAddFriend() ->Int {
        return MessageTools.getAllMessageCount() + receivedMessageCountGlobal
    }
    
    
    /**
    创建聊天数据库
    */
    class func createTestDB(){
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        var tmpPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())"
        ComFqHalcyonExtendFilesystemFileSystem.getInstance().initMessageRootPathWithNSString(tmpPath)
        var saveMessageListPath = "\(tmpPath)/message.db"
        db = FMDatabase(path: saveMessageListPath)
        if !db.open() {
            println("数据库打开失败！")
        }else{
            println("数据库打开成功！")
        }
    }
    
    /**
    插入一条消息
    
    :param: customId 对话的自定义ID
    :param: content  聊天信息
    :param: type     聊天信息类型
    :param: messageIndex     聊天信息在UI上的位置
    */
    class func insertMessage(customId:String,content:String,type:Int,messageIndex:Int){
        var tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            var entity = ComFqHalcyonEntityChartEntity()
            entity.setAtttributeByjsonStringWithNSString(content)
            var insert:Bool = false
            if entity.getUserId() == ComFqLibToolsConstants.getUser().getUserId() {
                insert = db.executeUpdate("INSERT INTO \(tabName) (messageType,content,messageIndex) VALUES (?,?,?)", withArgumentsInArray: [type,content,messageIndex])
            }else{
                insert = db.executeUpdate("INSERT INTO \(tabName) (messageType,content) VALUES (?,?)", withArgumentsInArray: [type,content])
            }
            
            if insert {
                println("插入数据成功！")
            }else{
                println("插入数据失败！")
            }
            
        }else{
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
    }
    
    /**
    更新单条消息的发送状态
    
    :param: messageIndex 聊天信息在UI上的位置
    :param: customId     对话的自定义ID
    :param: content      修改后的聊天信息
    */
    class func updateMessage(messageIndex:Int,customId:String,content:String){
        var tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            var update = db.executeUpdate("UPDATE \(tabName) SET content = ? WHERE messageIndex = ?", withArgumentsInArray: [content,messageIndex])
            if update {
                println("更新数据成功！")
            }else{
                println("更新数据失败！")
            }
            
        }else{
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
    }
    
    /**
    删除对话
    
    :param: customId 对话的自定义ID
    */
    class func deleteMessageTab(customId:String){
        var tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        var delete = db.executeUpdate("DROP TABLE IF EXISTS \(tabName)", withArgumentsInArray: nil)
    }
    
    /**
    获取聊天对话信息列表
    
    :param: customId 对话的自定义ID
    
    :returns: 聊天实体类的列表list
    */
    class func getMessageList(customId:String) ->JavaUtilArrayList {
        var tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        var messageList = JavaUtilArrayList()
        if isSuccess {
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            var tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
            var resultsSet = db.executeQuery("SELECT * FROM \(tabName)", withArgumentsInArray: nil) as FMResultSet
            while(resultsSet.next()){
                var message = resultsSet.stringForColumn("content")
                var entity = ComFqHalcyonEntityChartEntity()
                entity.setAtttributeByjsonStringWithNSString(message)
                messageList.addWithId(entity)
            }
        }else{
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
        
        return messageList
    }
    
    /// 获取数据库中某个MessageIndex中的content
    class func GetOneMessageContentForMessageIndex(messageIndex:Int,customId:String) ->ComFqHalcyonEntityChartEntity? {
        var tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        var entity = ComFqHalcyonEntityChartEntity()
        if isSuccess {
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            var resultsSet = db.executeQuery("SELECT * FROM \(tabName) WHERE messageIndex = ?", withArgumentsInArray: [messageIndex]) as FMResultSet
            if resultsSet.next() {
                var message = resultsSet.stringForColumn("content")
                entity.setAtttributeByjsonStringWithNSString(message)
                return entity
            }else{
                entity = nil
            }
            
        }else{
            println("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
        return entity
    }
    
    
    /**
    插入一个最近联系人
    
    :param: chartId 对话的自定义ID
    :param: name  聊天名字
    :param: headId  头像
    :param: lasetMessage     最后一条消息
    :param: date     时间戳
    :param: messageCount     未读消息数
    :param: messagetype     对话类型 2 群聊 1 单聊
    */
    class func insertRecentContact(chartId:String,name:String,headId:Int,lasetMessage:String,date:Double,messageCount:Int,messagetype:Int){
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表\(tabName)成功！")
            var entity = ComFqHalcyonEntityChartEntity()
            
            var insert:Bool = false
            insert = db.executeUpdate("INSERT INTO \(tabName) (chartId,name,headid,lastmessage,date,messagecount,messagetype) VALUES (?,?,?,?,?,?,?)", withArgumentsInArray: [chartId,name,headId,lasetMessage,date,messageCount,messagetype])
            if insert {
                println("插入数据成功！")
            }else{
                println("插入数据失败！")
            }
            
        }else{
            println("创建表\(tabName)失败！")
        }
    }
    
    /**
    判断id在表中是否存在
    
    :param: chartId 对话的自定义ID
    */
    class func queryChartId(chartId:String)->Bool{
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表\(tabName)成功！")
            var resultSet = db.executeQuery("SELECT * FROM \(tabName) WHERE chartId = ?", withArgumentsInArray: [chartId]) as FMResultSet
            if resultSet.next() {
                return true
            }else {
                return false
            }
            
        }else{
            println("创建表\(tabName)失败！")
        }
        return false
    }
    
    
    /**
    更新单个最近联系人
    
    :param: chartId 对话的自定义ID
    :param: name  聊天名字
    :param: headId  头像
    :param: lasetMessage     最后一条消息
    :param: date     时间戳
    :param: messageCount     未读消息数
    */
    class func updateRecentContact(chartId:String,name:String,headId:Int,lasetMessage:String,date:Double){
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表\(tabName)成功！")
            var update = db.executeUpdate("UPDATE \(tabName) SET name = ?,headid = ?,lastmessage = ?,date = ?  WHERE chartId = ?", withArgumentsInArray: [name,headId,lasetMessage,date,chartId])
            if update {
                println("更新数据成功！")
            }else{
                println("更新数据失败！")
            }
            
        }else{
            println("创建表\(tabName)失败！")
        }
    }
    
    /**
    更新单个最近联系人
    
    :param: chartId 对话的自定义ID
    :param: lasetMessage     最后一条消息
    :param: date     时间戳
    :param: messageCount     未读消息数
    */
    class func updateRecentContact(chartId:String,lasetMessage:String,date:Double){
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表\(tabName)成功！")
            var update = db.executeUpdate("UPDATE \(tabName) SET lastmessage = ?,date = ?  WHERE chartId = ?", withArgumentsInArray: [lasetMessage,date,chartId])
            if update {
                println("更新数据成功！")
            }else{
                println("更新数据失败！")
            }
            
        }else{
            println("创建表\(tabName)失败！")
        }
    }
    
    /**
    更新单个最近联系人未读条数
    
    :param: chartId 对话的自定义ID
    :param: messageCount     未读消息数
    */
    class func updateRecentContact(chartId:String,messageCount:Int){
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表\(tabName)成功！")
            var update = db.executeUpdate("UPDATE \(tabName) SET messagecount = ?  WHERE chartId = ?", withArgumentsInArray: [messageCount,chartId])
            if update {
                println("更新数据成功！")
            }else{
                println("更新数据失败！")
            }
            
        }else{
            println("创建表\(tabName)失败！")
        }
    }
    
    
    /**
    更新单个最近联系人名字
    
    :param: chartId 对话的自定义ID
    :param: name  聊天名字
    */
    class func updateRecentContact(chartId:String,name:String){
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表\(tabName)成功！")
            var update = db.executeUpdate("UPDATE \(tabName) SET name = ?  WHERE chartId = ?", withArgumentsInArray: [name,chartId])
            if update {
                println("更新数据成功！")
            }else{
                println("更新数据失败！")
            }
            
        }else{
            println("创建表\(tabName)失败！")
        }
    }
    
    
    /**
    删除单个最近联系人消息
    
    :param: chartId 聊天Id
    */
    class func deleteRecentContact(chartId:String){
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            println("创建表\(tabName)成功！")
            var delete = db.executeUpdate("DELETE FROM \(tabName) WHERE chartId = ?", withArgumentsInArray: [chartId])
            if delete {
                println("更新数据成功！")
            }else{
                println("更新数据失败！")
            }
        }else{
            println("创建表\(tabName)失败！")
        }
        
    }
    
    
    /**
    获取最近联系人列表 并按时间顺序
    
    :returns: 聊天实体类的列表list
    */
    class func getRecentContactList() ->NSMutableArray {
        var tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        var isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        var infoList = NSMutableArray()
        if isSuccess {
            println("创建表\(tabName)成功！")
            var resultsSet = db.executeQuery("SELECT * FROM \(tabName) ORDER BY date DESC", withArgumentsInArray: nil) as FMResultSet
            while(resultsSet.next()){
                var messagetype = resultsSet.intForColumn("messagetype")
                var date = resultsSet.longLongIntForColumn("date")
                var messagecount = resultsSet.intForColumn("messagecount")
                var headid = resultsSet.intForColumn("headid")
                var chartId = resultsSet.stringForColumn("chartId")
                var name = resultsSet.stringForColumn("name")
                var lastmessage = resultsSet.stringForColumn("lastmessage")
                var info = ComFqHalcyonEntityChatUserInfo()
                info.setChatTypeWithInt(messagetype)
                info.setImageIdWithInt(headid)
                info.setmSendTimeWithDouble(Double(date))
                info.setNameWithNSString(name)
                info.setLastMessageWithNSString(lastmessage)
                if messagetype == 1 {
                    info.setCustomUserIdWithNSString(chartId)
                }else{
                    info.setGroupIdWithNSString(chartId)
                }
                infoList.addObject(info)
            }
        }else{
            println("创建表\(tabName)失败！")
        }
        
        return infoList
    }
    
    /**
    设置接收最近联系人最后一条消息
    
    :param: strId    自定义ID
    :param: text     聊天信息
    :param: chatType 聊天类型
    */
    class func setReceiveRecentContact(strId:String,text:String,chatType:Int){
        var json = FQJSONObject(NSString: text)
        var lastStr = json.optStringWithNSString("message", withNSString: "")
        var name = json.optStringWithNSString("userName", withNSString: "")
        var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
        var messageType = json.optIntWithNSString("messageType")
        var imageId = json.optIntWithNSString("userImageId")
        
        if messageType == 1 {
            if chatType == 2 {
                lastStr = "\(name):\(lastStr)"
            }
        }else if messageType == 2 {//病案
            lastStr = "病案分享"
        }else if messageType == 3 {//记录
            lastStr = "记录分享"
        }else if messageType == 6 {//名片
            lastStr = "\(lastStr)"
        }else if messageType == 4 {//图片
            lastStr = "图片分享"
        }
        
        if !MessageTools.queryChartId(strId) {
            if chatType == 1 {//单聊
                MessageTools.insertRecentContact(strId, name: name, headId: Int(imageId), lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
            }else{//群聊
                var groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:Realm(path: MessageTools.getHIMRootPath()))
                if let info = groupInfo {
                    MessageTools.insertRecentContact(strId, name: info.name , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }else{//刚建群得不到groupinfo
                    MessageTools.insertRecentContact(strId, name: "\(name)发起的群聊" , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }
                
            }
            
        }else{
            if chatType == 1 {//单聊
                MessageTools.updateRecentContact(strId, name: name, headId: Int(imageId), lasetMessage: lastStr, date: lastTimer)
            }else{//群聊
                var groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:Realm(path: MessageTools.getHIMRootPath()))
                if let info = groupInfo {
                    MessageTools.updateRecentContact(strId, name: info.name, headId: 0, lasetMessage: lastStr, date: lastTimer)
                }
                
            }
            
        }
        
    }
    
    /**
    设置发送最近联系人最后一条消息
    
    :param: strId    自定义ID
    :param: text     聊天信息
    :param: chatType 聊天类型
    */
    class func setSendRecentContact(strId:String,text:String,chatType:Int,imageId:Int,name:String){
        var json = FQJSONObject(NSString: text)
        var lastStr = json.optStringWithNSString("message", withNSString: "")
        var sendName = json.optStringWithNSString("userName", withNSString: "")
        var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
        var messageType = json.optIntWithNSString("messageType")
        
        if messageType == 1 {
            if chatType == 2 {
                lastStr = "\(sendName):\(lastStr)"
            }
        }else if messageType == 2 {//病案
            lastStr = "病案分享"
        }else if messageType == 3 {//记录
            lastStr = "记录分享"
        }else if messageType == 6 {//名片
            lastStr = "\(lastStr)"
        }else if messageType == 4 {//图片
            lastStr = "图片分享"
        }
        
        if !MessageTools.queryChartId(strId) {
            if chatType == 1 {//单聊
                MessageTools.insertRecentContact(strId, name: name, headId: imageId, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
            }else{//群聊
                var groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:Realm())
                if let info = groupInfo {
                    MessageTools.insertRecentContact(strId, name: info.name , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }else{//刚建群得不到groupinfo
                    MessageTools.insertRecentContact(strId, name: "\(sendName)发起的群聊" , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }
                
            }
            
        }else{
            if chatType == 1 {//单聊
                MessageTools.updateRecentContact(strId, name: name, headId: imageId, lasetMessage: lastStr, date: lastTimer)
            }else{//群聊
                var groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:Realm(path: MessageTools.getHIMRootPath()))
                if let info = groupInfo {
                    MessageTools.updateRecentContact(strId, name: info.name, headId: 0, lasetMessage: lastStr, date: lastTimer)
                }
                
            }
            
        }
        
    }
    
    
    /**
    消息sdk发送消息
    
    :param: payLoad   负载信息
    :param: text     聊天信息
    :param: type 聊天类型
    :param: customId 自定义ID
    :param: callBackTag 附加信息
    :param: toUser 单聊user 群聊不传
    */
    class func sendMessage(text:String,payLoad:String,type:Int,customId:String,callBackTag:String,toUser:ComFqHalcyonEntityPerson?){
        if type == 1 {//单聊
            var tagJson = FQJSONObject()
            tagJson.putWithNSString("imageId", withInt: toUser!.getImageId())
            tagJson.putOptWithNSString("name", withId: toUser!.getName())
            HitalesIMSDK.sharedInstance.sendMessage(text, payload: payLoad, toUser: customId, callbackTag: tagJson.description())
        }else{//群聊
            HitalesIMSDK.sharedInstance.sendGroupMessage(text, payload: payLoad, toGroupId: customId, callbackTag: callBackTag)
        }
    }
    /// 获取文件存放根目录
    class func getDocumentPath() ->String{
        var paths =  NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return (paths[0] as! String)
    }
    
    /// 获取HIM文件存放根目录
    class func getHIMRootPath() ->String {
        return "\(MessageTools.getDocumentPath())/im_doc.realm"
    }
    
    /// HIMSDK logout
    class func himSDKLogout(){
        HitalesIMSDK.sharedInstance.logout()
    }
}