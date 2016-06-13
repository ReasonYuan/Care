//
//  Const.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation
import UIKit

let ScreenHeight = UIScreen.mainScreen().bounds.size.height
let ScreenWidth = UIScreen.mainScreen().bounds.size.width
let IOS_VERSION  = (UIDevice.currentDevice().systemVersion as NSString).doubleValue
let IOS_STYLE = UIDevice.currentDevice().userInterfaceIdiom
let Debug = true
let PracticeDemo = true


let ApiSystem = ComFqHalcyonApiApiSystem.getInstance()
let FileSystem = ComFqHalcyonExtendFilesystemFileSystem.getInstance()

let STATUE_BAR_HEIGHT  = UIApplication.sharedApplication().statusBarFrame.height

enum Color {
    static let pink = UIColor(red:245/255.0,green:111/255.0,blue:108/255.0,alpha:1)
    static let darkPink = UIColor(red:252/255.0,green:144/255.0,blue:141/255.0,alpha:1)
    static let gray = UIColor(red:193/255.0,green:193/255.0,blue:193/255.0,alpha:1)
    static let lightPurple = UIColor(red:25/255.0,green:105/255.0,blue:118/255.0,alpha:1)
    static let darkPurple = UIColor(red:16/255.0,green:83/255.0,blue:95/255.0,alpha:1)
    static let purple = UIColor(red:31/255.0,green:95/255.0,blue:105/255.0,alpha:1)
    static let color_emerald = UIColor(red:98/255.0,green:192/255.0,blue:180/255.0,alpha:1)
    static let color_grey = UIColor(red:148/255.0,green:148/255.0,blue:148/255.0,alpha:1)
    static let color_yellow = UIColor(red:247/255.0,green:229/255.0,blue:205/255.0,alpha:1)
    static let color_ligth_green = UIColor(red:244/255.0,green:250/255.0,blue:249/255.0,alpha:1)
    static let color_orange = UIColor(red: 232/255.0, green: 96/255.0, blue: 0, alpha: 1)
    static let color_violet = UIColor(red: 41/255.0, green: 47/255.0, blue: 121/255.0, alpha: 1)
    static let color_care_pink = UIColor(red: 245/255.0, green: 111/255.0, blue: 108/255.0, alpha: 1)
    static let color_verline = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1)
    static let color_time_label = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    static let color_chat_left_color = UIColor.whiteColor()
    static let color_chat_right_color = UIColor(red: 19/255.0, green: 83/255.0, blue: 96/255.0, alpha: 1)
}

let kCSPickerViewBackTopTableTag        = 10001
let kCSPickerViewBackBottomTableTag     = 10002
let kCSPickerViewFrontTableTag          = 10003
let kCSPickerViewBackCellIdentifier     = "kCSPickerViewBackCellIdentifier"
let kCSPickerViewFrontCellIdentifier    = "kCSPickerViewFrontCellIdentifier"

/// 消息sdk的uri
enum HitalesIMSDKURI {
    static let PRODUCTION = "218.244.150.28:9092"
}

/// 消息sdk所在环境
enum HitalesIMSDKEnviroment {
    //测试环境
    static let TEST = "test"
    //开发环境
    static let DEVELOPMENT = "development"
    //生产环境
    static let PRODUCTION = "release"
    //预生产环境
    static let PREPRODUCTION = "prerelease"
    //APPSTORE环境
    static let APPSTORE = "release"
}
