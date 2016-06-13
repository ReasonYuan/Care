//
//  SettingViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController, UIAlertViewDelegate, FQSwitchViewDelegate{
    
    //@IBOutlet weak var docPlusId: UILabel!
    //@IBOutlet weak var phonNum: UILabel!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var docIDBtn: UIButton!
   
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var cacheLabel: UILabel!
    @IBOutlet weak var wifiSwitch: UISwitch!
    var dialog:CustomIOS7AlertView!
    
    var switchView:FQSwitchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("设置")
        hiddenRightImage(true)
        UITools.setBtnBackgroundColor(exitBtn,selectedColor: Color.purple,unSelectedColor: Color.lightPurple,disabledColor: Color.gray)
        
        for i in 1000..<1004{
            var btn = self.view.viewWithTag(i) as! UIButton
            UITools.setBtnBackgroundColor(btn,selectedColor: UIColor.lightGrayColor(),unSelectedColor: UIColor.clearColor(),disabledColor: UIColor.clearColor())
            btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
//        switchView = FQSwitchView(frame: CGRectMake(ScreenWidth-80, 176 , 80 , 20), switchViewType: FQSwitchViewTypeNoLabel, switchBaseType: SwitchBaseTypeChangeImage, switchButtonType: SwitchButtonTypeDefault, baseImageL: "wifi_btn_checked.png", baseImageR: "wifi_btn_unchecked.png", btnImageL: "", btnImageR: "")
//        switchView.switchDelegate = self
//                self.view.addSubview(switchView)
        if ComFqLibToolsConstants.getUser().isOnlyWifi() {
//            switchView.selectedButton = SwitchButtonSelectedLeft
            wifiSwitch.setOn(true,animated:true)
        }else{
//            switchView.selectedButton = SwitchButtonSelectedRight
            wifiSwitch.setOn(false,animated:true)
        }
    
        wifiSwitch.addTarget(self,action:Selector("stateChanged:"),forControlEvents:UIControlEvents.ValueChanged)
        //UITools.setButtonWithColor(ColorType.EMERALD, btn: exitBtn, isOpposite: false)
        //phonNum.text = ComFqLibToolsConstants.getUser().getPhoneNumber()
        updateCacheLabel()
        
        
    }

    func stateChanged(switchState:UISwitch){
        if switchState.on{
            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(true)
            var userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
            println("仅wifi上传")
        } else {
            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(false)
            var userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(false, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
            println("不是仅wifi上传")
        }
        
    }
    
    class func setOnlyWifi(onlyWifi:Bool){
        ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(onlyWifi)
        var userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(onlyWifi, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())

    }
    
    func selectLeftButton() {
        
        ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(true)
        var userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
        println("仅wifi上传")
    }
    
    func selectRightButton() {
        ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(false)
        var userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(false, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
        println("不是仅wifi上传")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
//    override func viewWillAppear(animated: Bool) {
//        docPlusId.text = ComFqLibToolsConstants.getUser().getDPName()
//    }
    
    override func getXibName() -> String {
        return "SettingViewController"
    }
    
    @IBAction func changephoneNum(sender: AnyObject) {
        self.navigationController?.pushViewController(ChangePhoneNumViewController(), animated: true)
    }
    

    
    @IBAction func changePassWord(sender: AnyObject) {
        var ChangePassword = ChangePasswordViewController()
        ChangePassword.isForgetPwd = false
        self.navigationController?.pushViewController(ChangePassword, animated: true)
    }
    
    @IBAction func myTwoCode(sender: AnyObject) {
        self.navigationController?.pushViewController(MyQrCodeViewController(), animated: true)
    }
    
    @IBAction func wifiUpload(sender: AnyObject) {
        if ComFqLibToolsConstants.getUser().isOnlyWifi() {
            println("off")
//            switchView.selectedButton = SwitchButtonSelectedRight
            wifiSwitch.setOn(false,animated:true)
            
        }else{
            println("on")
//            switchView.selectedButton = SwitchButtonSelectedLeft
            wifiSwitch.setOn(true,animated:true)
        }
        
    }
    
    @IBAction func cleanCatch(sender: AnyObject) {
        dialog = UIAlertViewTool.getInstance().showNewDelDialog("清除缓存，释放手机空间", target: self, actionOk: "sureClean", actionCancle: "cancleClean")
    }
    
    func cancleClean(){
        dialog.close()
    }
    //清除缓存
    func sureClean(){
        var file:JavaIoFile = JavaIoFile(NSString: ComFqHalcyonExtendFilesystemFileSystem.getInstance().getSDCImgRootPath())
        ComFqLibFileHelper.deleteFileWithJavaIoFile(file, withBoolean: false)
        dialog.close()
//        (UIAlertViewTool.getInstance() as UIAlertViewTool).showAutoDismisDialog("清除缓存成功", width: 210, height: 120)
        self.view.makeToast("清除缓存成功")
        updateCacheLabel()
    }
    

    
    @IBAction func aboutDocPlus(sender: AnyObject) {
        var controller = AboutDocPlusViewController()
        controller.isProtocol = false
        self.navigationController?.pushViewController(controller, animated: true)

    }
    
 
    
    @IBAction func exitApp(sender: AnyObject) {
        ComFqLibToolsTool.clearUserData()
        MessageTools.exitApp()
        var loginViewController:LoginViewController = LoginViewController(nibName:"LoginViewController",bundle:nil)
        loginViewController.isb = true
        self.navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    func updateCacheLabel(){
    var file:JavaIoFile = JavaIoFile(NSString: ComFqHalcyonExtendFilesystemFileSystem.getInstance().getSDCImgRootPath())
    var fileSize:Int64 = ComFqLibFileHelper.getFileSizeWithJavaIoFile(file)
    var cache:CGFloat = CGFloat((fileSize/1024)/1024)
    cacheLabel.text = "当前共有缓存\(cache)MB"
    }
}
