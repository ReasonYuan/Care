//
//  HomeLeftMenuView.swift
//  Care
//
//  Created by niko on 15/8/25.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class HomeLeftMenuView: UIView ,ISSViewDelegate,ISSShareViewDelegate{

    
    @IBOutlet weak var myInfoBtn: UIButton!
    @IBOutlet weak var cacheLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userHeadImg: UIImageView!
    @IBOutlet weak var maskTouchView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var settingMenu: UIView!
    @IBOutlet var menuView: UIView!
    
    @IBOutlet weak var btnLoginPhone: UIButton!
    @IBOutlet weak var btnChangePwd: UIButton!
    @IBOutlet weak var btnNotice: UIButton!
    @IBOutlet weak var btnCleanCache: UIButton!
    @IBOutlet weak var btnMyCode: UIButton!
    @IBOutlet weak var btnAboutHiTales: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnExitLogin: UIButton!
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    var menuBtnArray = [UIButton]()
    
    let cutLineHeight = 2
    let btnHeight = 44
    var settingMenuWidth = CGFloat(270)
    var settingMenuFrame:CGRect?
    
    var menuViewShowFrame:CGRect?
    var menuViewHiddenFrame:CGRect?
    
    let usernameRadius = CGFloat(10)
    
    let normalColor = UIColor(red:50/255.0,green:54/255.0,blue:62/255.0,alpha:1)
    let highlightedColor = UIColor(red:86/255.0,green:90/255.0,blue:99/255.0,alpha:1)
    
    var cleanDialog:CustomIOS7AlertView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("HomeLeftMenuView", owner: self, options: nil)
        let menuView = nibs.lastObject as! UIView
        menuView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        maskTouchView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        self.addSubview(menuView)
        self.addSubview(maskTouchView)
        self.hidden = true
        self.maskTouchView.alpha = 0.0
        setMenu()
        setMenuBtn()
        setTouchViewListener()
        updateCacheLabel()
        setWifi()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMenu(){
        var settingHeight = btnHeight * 6 + cutLineHeight * 5
        settingMenuWidth = ScreenWidth / 4 * 3
        var menuHeight = ScreenHeight - 20
        settingMenuFrame = CGRect(x: 0, y: 0, width: settingMenuWidth, height: CGFloat(settingHeight))
        menuViewShowFrame = CGRect(x: 0, y: 20, width: settingMenuWidth, height: menuHeight)
        menuViewHiddenFrame = CGRect(x: -settingMenuWidth, y: 20, width: settingMenuWidth, height: menuHeight)
        settingMenu.frame = settingMenuFrame!
        scrollView.addSubview(settingMenu)
        scrollView.contentSize = CGSize(width: settingMenuWidth, height: CGFloat(settingHeight))
        menuView.frame = menuViewHiddenFrame!
        menuView.hidden = true
        self.addSubview(menuView)
    }
    
    func setMenuBtn(){
        menuBtnArray = [btnLoginPhone,btnChangePwd,btnNotice,btnCleanCache,btnMyCode,btnAboutHiTales,btnShare,btnExitLogin]
        for btn in menuBtnArray {
            setBtnStyle(btn)
        }
    }
    
    //设置按钮的点击效果
    func setBtnStyle(btn:UIButton){
        btn.setBackgroundImage(UITools.imageWithColor(normalColor), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(highlightedColor), forState: UIControlState.Highlighted)
    }
    
    //设置用户信息
    func setUserInfo(){
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserImagePath()
        var name = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserHeadName()
        var getSuccess = UIImageManager.getImageFromLocal(path, imageName: name)
        let imgHeadRadius = userHeadImg.frame.size.height/2
        UITools.setRoundBounds(usernameRadius, view: usernameLabel)
        usernameLabel.text = ComFqLibToolsConstants.getUser().getName()
        UITools.setRoundBounds(imgHeadRadius, view: userHeadImg)
        UITools.setBorderWithView(2.0, tmpColor: UIColor.whiteColor().CGColor, view: userHeadImg)
        
        if(getSuccess != nil){
            userHeadImg.image = getSuccess
        }else{
            userHeadImg.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                var  head = view as? UIButton
                self.userHeadImg.image = UITools.getImageFromFile(path)
            })
            
        }
    }
    
    //设置wifi选择按钮
    func setWifi(){
        if ComFqLibToolsConstants.getUser().isOnlyWifi() {
            wifiSwitch.setOn(true,animated:true)
        }else{
            wifiSwitch.setOn(false,animated:true)
        }
        wifiSwitch.addTarget(self,action:Selector("stateChanged:"),forControlEvents:UIControlEvents.ValueChanged)
    }
    
    func stateChanged(switchState:UISwitch){
        if switchState.on{
            setUserWifiStatus(true)
            println("仅wifi上传")
        } else {
            setUserWifiStatus(false)
            println("有网情况下可上传")
        }
        
    }
    
    func setUserWifiStatus(onlyWifi:Bool){
        ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(onlyWifi)
        var userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(onlyWifi, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
    }
    
    //显示或隐藏菜单
    func showMenu(operation:Bool){
        if operation {
            setUserInfo()
            self.hidden = false
            menuView.hidden = false
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.maskTouchView.alpha = 0.6
                self.menuView.frame = self.menuViewShowFrame!
            }, completion: { (isFinish) -> Void in
                
            })
        }else{
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.maskTouchView.alpha = 0.0
                self.menuView.frame = self.menuViewHiddenFrame!
            }, completion: { (isFinish) -> Void in
                self.hidden = true
                self.menuView.hidden = true
            })
        }
    }
    
    
    func setTouchViewListener(){
        var tapGesture = UITapGestureRecognizer(target: self, action: "viewTapListener:")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        var recongnizerLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipeClose:")
        recongnizerLeft.direction = UISwipeGestureRecognizerDirection.Left
        maskTouchView.addGestureRecognizer(tapGesture)
        maskTouchView.addGestureRecognizer(recongnizerLeft)
    }
    
    //点击隐藏菜单
    func viewTapListener(gesture:UITapGestureRecognizer){
        showMenu(false)
    }
    
    //滑动隐藏菜单
    func handleSwipeClose(recongizer:UISwipeGestureRecognizer){
        if recongizer.direction == UISwipeGestureRecognizerDirection.Left {
            showMenu(false)
        }
    }
    
    //菜单按钮点击事件
    @IBAction func onMenuBtnClickListener(sender: UIButton) {
        menuBtnArray = [btnLoginPhone,btnChangePwd,btnNotice,btnCleanCache,btnMyCode,btnAboutHiTales,btnShare,btnExitLogin]
        let navigationController = Tools.getCurrentViewController(self).navigationController
        switch sender {
        
        case myInfoBtn:
            navigationController?.pushViewController(UserProfileViewController() , animated: true)
            
        case btnLoginPhone:
            //登录手机
            navigationController?.pushViewController(ChangePhoneNumViewController(), animated: true)
            
        case btnChangePwd:
            //修改密码
            var ChangePassword = ChangePasswordViewController()
            ChangePassword.isForgetPwd = false
            navigationController?.pushViewController(ChangePassword, animated: true)
            
        case btnCleanCache:
            //清除缓存
            cleanDialog = UIAlertViewTool.getInstance().showNewDelDialog("清除缓存，释放手机空间", target: self, actionOk: "sureClean", actionCancle: "cancleClean")
            
        case btnMyCode:
            //我的二维码
            navigationController?.pushViewController(MeViewController(), animated: true)
            
        case btnAboutHiTales:
            //关于HiTales
            var controller = AboutDocPlusViewController()
            controller.isProtocol = false
            navigationController?.pushViewController(controller, animated: true)
            
        case btnShare:
            //分享
            shareApp()
            
        case btnExitLogin:
            //退出登录
            exitApp(navigationController)
            
        default:
            println("out of control")
        }
    }

    //取消清除缓存
    func cancleClean(){
        cleanDialog?.close()
    }
    
    //清除缓存
    func sureClean(){
        var file:JavaIoFile = JavaIoFile(NSString: ComFqHalcyonExtendFilesystemFileSystem.getInstance().getSDCImgRootPath())
        ComFqLibFileHelper.deleteFileWithJavaIoFile(file, withBoolean: false)
        cleanDialog?.close()
        self.makeToast("清除缓存成功")
        updateCacheLabel()
    }
    
    //获取缓存数据大小
    func updateCacheLabel(){
        var file:JavaIoFile = JavaIoFile(NSString: ComFqHalcyonExtendFilesystemFileSystem.getInstance().getSDCImgRootPath())
        var fileSize:Int64 = ComFqLibFileHelper.getFileSizeWithJavaIoFile(file)
        var cache:CGFloat = CGFloat((fileSize/1024)/1024)
        cacheLabel.text = "当前共有缓存\(cache)MB"
    }
    
    //退出登录
    func exitApp(navigationController:UINavigationController?){
        ComFqLibToolsTool.clearUserData()
        MessageTools.exitApp()
        var loginViewController:LoginViewController = LoginViewController(nibName:"LoginViewController",bundle:nil)
        loginViewController.isb = true
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    //分享
    func shareApp(){
        var img = UIImage(named:"appIcon_80")
        let shareImg = ShareSDK.pngImageWithImage(img)
        var shareList = [ShareTypeWeixiSession,ShareTypeWeixiTimeline]
        var url = "\(ComFqLibToolsUriConstants.getInvitationURL())?user_id=\(ComFqLibToolsConstants.getUser().getUserId())"
        var content = ShareSDK.content("HiTales Care为管理您家庭的健康档案，提供健康管家服务，为您和医生之间搭建沟通的桥梁。",
            defaultContent: "默认分享内容，没内容时显示",
            image: shareImg ,
            title: "HiTales Care--Data Driven Health",
            url: url,
            description: nil,
            mediaType: SSPublishContentMediaTypeNews)
        var mAuthOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: self)
        ShareSDK.showShareActionSheet(nil, shareList: nil, content: content, statusBarTips: false, authOptions: mAuthOptions, shareOptions: nil) { (type, state, statusInfo, info, end) -> Void in
            if state.value == SSPublishContentStateSuccess.value {
                
            }else {
                println("分享失败！！！")
            }
        }
    }
}
