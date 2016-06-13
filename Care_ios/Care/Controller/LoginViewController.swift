//
//  LoginViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/4/27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController,ComFqHalcyonUilogicUILoginLogic_UILogicCallback,FQTexfieldDelegate,ComFqHalcyonUilogicUILoginLogic_LoginLogicListener {
    
    let RES_INTENT_FOR = 998
    let seriaVersionUID:Int64 = 1
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgetPWD: UIButton!
    @IBOutlet weak var erroRemindLabel: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var mUserNameTextField: FQTexfield!
    @IBOutlet weak var mPassWordTextField: FQTexfield!
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var bgImgV: UIImageView!
//    var registerLogic:ComFqHalcyonUilogicUILoginLogic!
    var mUserName:String!
    var mPassWord:String!
    var mUILoginLogic:ComFqHalcyonUilogicUILoginLogic!
    var isb:Bool?
    var loadingView: LoadingView?
    var mPhoneNumber :String?
    var isPhoneExist :Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        ComFqHalcyonPracticePhotosManager.DestoryInstance()
        //claer stack
        var allControllInStack:[UIViewController] =  self.navigationController!.viewControllers as! [UIViewController]
        var tmp : [UIViewController] = [];
        for controller:UIViewController in allControllInStack {
            if(controller != self){
                tmp.append(controller)
//                controller.removeFromParentViewController()
            }
        }
        for controller:UIViewController in tmp {
            if(controller != self){
               controller.removeFromParentViewController()
            }
        }

        
        
        UITools.setBtnBackgroundColor(loginBtn,selectedColor: Color.darkPurple,unSelectedColor: Color.purple,disabledColor: Color.gray)
        UITools.setBtnBackgroundColor(registerBtn,selectedColor: Color.darkPurple,unSelectedColor: Color.purple,disabledColor: Color.gray)
        mUserNameTextField.setNextTextField(mPassWordTextField)
        mUILoginLogic = ComFqHalcyonUilogicUILoginLogic(comFqHalcyonUilogicUILoginLogic_UILogicCallback: self);
        mUserNameTextField.setFQTexfieldDelegate(self)
        mPassWordTextField.setFQTexfieldDelegate(self)
        var filesystem:ComFqHalcyonExtendFilesystemFileSystem = ComFqHalcyonExtendFilesystemFileSystem.getInstance()
        var keys:JavaUtilArrayList? = filesystem.loadLoginUser()
        
        
        if isb == true {
            keys?.setWithInt(1, withId: "")
        }
        if keys != nil {
            mUserName = keys?.getWithInt(0) as! String
            mPassWord = keys?.getWithInt(1) as! String
            mUserNameTextField.text = mUserName
        }
        
        if keys != nil && mUserName != "" && mPassWord != "" {
            showLoadingView()
            autoLogin(mUserName, passWord: mPassWord)
            ComFqLibToolsConstants_isVisitor_ = false;
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "phoneChange:", name: UITextFieldTextDidChangeNotification, object: mUserNameTextField)
        self.navigationController?.navigationBar.hidden = true
        
//        let img = UIImage(named:"backgroundPic.jpg")
//        bgImgV = UIImageView()
        
//        bgImgV.frame = CGRectMake(0,0,ScreenWidth,ScreenWidth/img.size.width*img.size.height)
//        scrollView.addSubview(bgImgV)
//        scrollView.contentSize = bgImgV.frame.size
//        scrollView.frame = CGRectMake(0,0,ScreenWidth,ScreenHeight+300)
//        self.view.addSubview(scrollView)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.closeLoadingView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
//    override func getXibName() -> String {
//        return "LoginViewController"
//    }
    
    @IBAction func login(sender: AnyObject) {
        //TODO ==YY==不验证登录，直接跳到主页
//        self.navigationController?.pushViewController(MainViewController(), animated: true)
//        return;
        
        mUserName = mUserNameTextField.text
        mPassWord = mPassWordTextField.text
        if mUserName != "" && mPassWord != ""{
            
            showLoadingView()
            var userName:String = mUserName
            var passWord:String = HMACSHA1_IOS.Repeat20TimesAndSHA1(mPassWord)
            autoLogin(userName, passWord: passWord)
            ComFqLibToolsConstants_isVisitor_ = false;
            
        }else if mUserName == ""{
            erroRemindLabel.text = "请输入手机号"
        }else if mUserName != "" && mPassWord == ""{
            erroRemindLabel.text = "请输入密码"
        }else {
            erroRemindLabel.text = "用户名或密码错误"
            return
        }
    }
    
    @IBAction func register(sender: AnyObject) {
        self.navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    @IBAction func forgetPassWord(sender: AnyObject) {
        if(count(mUserNameTextField.text.trim())==11)
        {
            if(isPhoneExist)
            {
                var forgetPasswordViewController = ChangePasswordViewController()
                forgetPasswordViewController.forgetPhoneText = mUserNameTextField.text
                forgetPasswordViewController.isForgetPwd = true
                self.navigationController?.pushViewController(forgetPasswordViewController, animated: true)
            }else{
                erroRemindLabel.text = "该手机号尚未注册"
            }
        }else{
            erroRemindLabel.text = "请输入手机号"
        }
    }
    
    func errorWithInt(code: Int32, withNSString msg: String!) {
        self.view.makeToast("失败")
    }
    //手机号输入框内容变化监听
    func phoneChange(noti : NSNotification){
        
        if(count(mUserNameTextField.text.trim())==11){
            erroRemindLabel.text = ""
            forgetPWD.enabled = true
        }else {
            forgetPWD.enabled = false
        }
        validatePhone()
    }
    
    func validatePhone() {
        var phone = mUserNameTextField.text
        
        if  phone == "" {
            erroRemindLabel.text = "请输入手机号"
            return;
        }
        if !ComFqHalcyonUilogicRegisterUILogic.isMobileNOWithNSString(phone) {
            erroRemindLabel.text = "请输入正确的手机号"
            forgetPWD.enabled = false
            return;
        }
        var loginLogic:ComFqHalcyonUilogicUILoginLogic = ComFqHalcyonUilogicUILoginLogic()
        loginLogic.setListenerWithComFqHalcyonUilogicUILoginLogic_LoginLogicListener(self)
        loginLogic.isPhoneExistWithNSString(phone)
    }

    //验证手机号是否已注册
    func isPhoneExistWithBoolean(isExist: Bool) {
        if(isExist){
            isPhoneExist = true
        }else{
            isPhoneExist = false
            }
    }
    
    func autoLogin(userName:String,passWord:String){
        var appType = "\(ComFqLibToolsConstants_CLIENT_HEALTH_IOS)"
        mUILoginLogic.loginWithBoolean(isNetWorkOK(), withNSString:userName, withNSString: passWord,withNSString: Tools.getAppVersion(), withNSString: appType)
    }
    
    func logicBackWithInt(type: Int32, withInt code: Int32, withNSString msg: String!) {
        if type == 0{
            closeLoadingView()
            mPassWordTextField.text = ""
            var str = "登录失败,网络错误！"
            if code == 1 {
                str = "用户名或密码错误！"
            }
            erroRemindLabel.text = str
            //showAlertView(str)
            
        }
        if type == 1{
            //HalcyonService没加
            //HalcyonApplication.getInstance().onUserLoginIn()
            if (ComFqLibToolsConstants.getUser().getRole_type() == ComFqLibToolsConstants_ROLE_DOCTOR_STUDENT) {
                ComFqLibToolsConstants.getUser().setRole_typeWithInt(ComFqLibToolsConstants_ROLE_DOCTOR)
            }
            if !(ComFqLibToolsTool.isUserInfoFullWithComFqHalcyonEntityUser(ComFqLibToolsConstants.getUser())) {
                //跳到用户界面
                self.navigationController?.pushViewController(UserProfileViewController(), animated: true)
                //mIntent.putExtra("user_regist", true);传参
            } else {
                // 跳到主页
                self.navigationController?.pushViewController(MainViewController(), animated: true)
            }
            
            
            //暂时跳转到用户信息界面
            //self.navigationController?.pushViewController(UserProfileViewController(), animated: true)
            var index:Int! = self.navigationController?.viewControllers.count
            println(index)
            self.navigationController?.viewControllers.removeRange(Range(start: 0,end:index - 1))
            
            
            
            //暂时放着
            //closeLoadingView()
            
            
            
            
            //判断仅wifi上传
            if ComFqLibToolsConstants.getUser() != nil{
                var userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
                if let ob: AnyObject = userDefaults.objectForKey(ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id()){
                    var b:Bool = ob as! Bool
                    ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(b)
                }else{
                    ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(true)
                }
                
//                ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(b!)
            }
            
        }else{
            closeLoadingView()
        }
    }
    func onAlarmCallback() {
        
    }
    
    
    /*!
    * 判断是否有网络连接
    */
    func isNetWorkOK()->Bool{
//        var remoteHostStatus:NetworkStatus = Tools.getNetWorkState()
//        if remoteHostStatus == NetworkStatus.NotReachable {
//            return false
//        }
        return Tools.isNetWorkConnect()
    }
    
    func showLoadingView(){
        if(loadingView == nil){
            loadingView = LoadingView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight), msg: "")
            loadingView?.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(loadingView!)
        }
    }
    func closeLoadingView(){
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
    func showAlertView(massage:String){
        self.view.makeToast(massage)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        self.view.endEditing(true)
////        scrollView.endEditing(true)
//    }
    
    //限制textField输入字数
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        var lengthOfString :NSInteger = count(string)
        var fieldTextString : String = textField.text
        // Check for total length
        var proposedNewLength : Int = count (fieldTextString) - range.length + lengthOfString;
        var maxNum = 0
        var csPhone = NSCharacterSet(charactersInString: "0123456789").invertedSet
        var csPwd = NSCharacterSet(charactersInString: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").invertedSet
        var filteredPhone = string.componentsSeparatedByCharactersInSet(csPhone)
        var filteredPwd = string.componentsSeparatedByCharactersInSet(csPwd)
        if(textField == mUserNameTextField){
            maxNum = 11
        }else{
            maxNum = 20
        }
        if (proposedNewLength > maxNum)
        {
            return false//限制长度
        }
        if textField == mUserNameTextField  {
            var isExist = false
            for i in filteredPhone {
                if i == string {
                    isExist = true
                }
            }
            if !isExist {
                return false
            }
        }else if  textField == mPassWordTextField {
            var isExist = false
            for i in filteredPwd {
                if i == string {
                    isExist = true
                }
            }
            if !isExist {
                return false
            }
        }
        return true
    }
    
    @IBAction func tourist(sender: AnyObject) {
        var userName = "18602106473"
        var passWord:String = HMACSHA1_IOS.Repeat20TimesAndSHA1("lin2992")
        autoLogin(userName, passWord: passWord)
        ComFqLibToolsConstants_isVisitor_ = true;
    }
}
