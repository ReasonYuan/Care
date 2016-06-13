//
//  AppDelegate.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/4/24.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
var currentLocationCity:String?
var currentLocationHospital:String?

var myDeviceToke:String = ""
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ComFqLibCallbackICallback,UIAlertViewDelegate{

    var window: UIWindow?
    var _alertView: UIAlertView?
    var dialog:CustomIOS7AlertView?

   
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        InstallUncaughtExceptionHandler()
        self.initNavagationControllerBar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNetWorkChange", name: "kNetworkReachabilityChangedNotification", object: nil)
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        var paths =  NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var documentsDirectory = paths[0] as! String
        var rootPath = documentsDirectory + "/cache/"
        var imagePath = rootPath + "image/"
        ComFqHalcyonExtendFilesystemFileSystem.initWithRootPathWithNSString(rootPath, withNSString: imagePath)
        
        ComFqLibPlatformPlatform.setInstanceWithComFqLibPlatformPlatform(ComFqHttpAsyncPlatform_IOS())
        ComFqHttpPotocolHttpClientPotocol.getInstance().setOnSessionExpiredCallbackWithComFqLibCallbackICallback(self)
        var rootController:UINavigationController? = self.window?.rootViewController as? UINavigationController;

        //判断是否第一次启动app
        if(!NSUserDefaults.standardUserDefaults().boolForKey("everLaunched")){
            rootController?.pushViewController(NewGuideViewController(nibName:"NewGuideViewController",bundle:nil) , animated: true)
        }else{
              rootController?.pushViewController(LoginViewController(nibName:"LoginViewController",bundle:nil), animated: false)

        }
        
        /**初始FIR崩溃SDK**/
        FIR.handleCrashWithKey("bf3fb26f479f148d0730e55b3e8ad821")
        
        
         /**初始化ShareSDK**/
        initShareSdk()
        
        /**初始化HIMSDK**/
        initHIMSDK()
        
        /**注册消息推送**/
        var sysVersion = (UIDevice.currentDevice().systemVersion as NSString).floatValue
        if (sysVersion > 7.9) {
            var types = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound)
        }
        
     //UIApplication.shareApplication().setStatusBarStyle(UIStatusBarStyleLightContent);
        CrashReporter.sharedInstance().installWithAppId("900006863")
        return true
    }
    
    func doCallbackWithId(obj: AnyObject!) {
        var json :FQJSONObject? = obj as? FQJSONObject
        if(json == nil){
            return;
        }
        
        var responseCode = json?.optIntWithNSString("response_code")
        if(responseCode == 20001){
            if(dialog == nil){
                dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("当前版本过低，请更新至最新版本！", target: self, actionOk: "update")
            }
        }else{
            var rootController:UINavigationController? = self.window?.rootViewController as? UINavigationController;
            if (rootController != nil && !rootController!.topViewController.isKindOfClass(LoginViewController)) {
                if(_alertView == nil){
                    _alertView = UIAlertView(title: nil, message: json?.optStringWithNSString("msg"), delegate: self, cancelButtonTitle: nil)
                    _alertView?.addButtonWithTitle("确定")
                    _alertView?.show()
                }
            }
        }
    }
    
    func update(){
        var path = "";
        if(ComFqLibToolsConstants_isInhouse_){
            path = "http://www.fir.im/cares"
            
            let url:NSURL! = NSURL(string: path)
            if  UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }else{
            path = "appStore"
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        _alertView = nil
        var rootController:UINavigationController? = self.window?.rootViewController as? UINavigationController;
        if (rootController != nil && !rootController!.topViewController.isKindOfClass(LoginViewController)) {
            ComFqLibToolsTool.clearUserData()
            MessageTools.exitApp()
            rootController?.pushViewController(LoginViewController(nibName:"LoginViewController",bundle:nil), animated: false)
        }
        
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
       var str =  deviceToken.description as NSString
       var tmpTokenString = ((str.stringByReplacingOccurrencesOfString("<", withString: "") as NSString).stringByReplacingOccurrencesOfString(">", withString: "") as NSString).stringByReplacingOccurrencesOfString(" ", withString: "")
        myDeviceToke = tmpTokenString
        println("注册推送成功")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("注册推送失败---------------\(error)")
    }
    
    func initShareSdk(){
        ShareSDK.registerApp("9da4d0f54ce0")
        initializePlat()
    }
    
    
    func initializePlat(){
        /**
        连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
        http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
        **/
//        ShareSDK.connectSinaWeiboWithAppKey("568898243", appSecret: "38a4f8204cc784f81f9f0daaf31e02e3", redirectUri: "http://www.sharesdk.cn")
        
        //连接短信分享
//        ShareSDK.connectSMS()
        
        /**
        连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
        http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
        **/
        
        //app store正式版时的key
        var wxKey = "wxe1acd00385c3ac0f"
        var wxSecret = "0cf4bbe1576692dea3615a070255a2ee";
        
        if(ComFqLibToolsConstants_isInhouse_){
            wxKey = "wxf83595c704d41be6"
            wxSecret = "ea3da9518465c21a9660bc561131e265"
        }
        
        ShareSDK.connectWeChatSessionWithAppId(wxKey, appSecret: wxSecret, wechatCls: WXApi.classForCoder())
    
        ShareSDK.connectWeChatTimelineWithAppId(wxKey,
        appSecret: wxSecret,
        wechatCls: WXApi.classForCoder())
    }
    
    
     func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        ComFqHalcyonPracticeTrash.getInstance().save()
        MessageTools.changeAppState(false, customUserId: "\(ComFqLibToolsConstants.getUser().getUserId())")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        ComFqLibPlatformPlatform.getInstance().checkNetwork()
        if ComFqLibToolsConstants.getUser().getUserId() != 0 {
           MessageTools.changeAppState(true, customUserId: "\(ComFqLibToolsConstants.getUser().getUserId())")
        }
    }
    
    
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return ShareSDK.handleOpenURL(url, wxDelegate: self)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return ShareSDK.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation, wxDelegate: self)
    }

    func initNavagationControllerBar(){
        let rootController : UINavigationController  = self.window?.rootViewController as! UINavigationController;
        rootController.navigationBarHidden = true;
        
        if  (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0 {
            rootController.navigationBar.translucent = false;
        }
    }
    
    /*初始化IMSDK即时通讯*/
    func initHIMSDK(){
        HitalesIMSDK.sharedInstance.initSDK(HitalesIMSDKURI.PRODUCTION, envirment: HitalesIMSDKEnviroment.TEST,reelmFilePath:MessageTools.getHIMRootPath())
    }
    
   
}

