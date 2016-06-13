//
//  RegisterViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/4/29.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController,FQTexfieldDelegate, ComFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback,ComFqHalcyonLogicRegisterLogic_RegisterLogicListener,ComFqHalcyonLogicGetProviderLogic_getProviderCallback{
    let color:UIColor = UIColor(red: CGFloat(41.0/255.0), green: CGFloat(47.0/255.0), blue: CGFloat(120.0/255.0), alpha: CGFloat(1))
    var dialog:CustomIOS7AlertView!
    @IBOutlet weak var getCodeBtn: UIButton!
    @IBOutlet var errorRemindLabel: UILabel!
    @IBOutlet var phoneNumberTextField: FQTexfield!
    @IBOutlet var passwordTextField: FQTexfield!
    @IBOutlet var vertificateCodeTextField: FQTexfield!
//    @IBOutlet var InvitationCodeTextField: FQTexfield!
    @IBOutlet var phoneNumberValidateMark: UIImageView!
    @IBOutlet var passwordValidateMark: UIImageView!
    @IBOutlet var vertificateCodeValidateMark: UIImageView!
//    @IBOutlet var invitationCodeValidateMark: UIImageView!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    var logic:ComFqHalcyonLogic2ResquestIdentfyLogic!
    var inviteLogic:ComFqHalcyonLogicGetProviderLogic!
    var uilogic:ComFqHalcyonUilogicRegisterUILogic!
    var registerLogic:ComFqHalcyonLogicRegisterLogic!
    var secondsCountDown = 60
    var countDownTimer: NSTimer?
    var mPhoneNumber :String?
    var mPassword :String?
    var mRePassword :String?
    var mCodeText :String?
    var mInviteCode:String?
    let TY_PHN = 0,TY_PWD = 1,TY_VER = 2,TY_INV = 3
    var isPhoneRight:Bool = false
    var isVerRight:Bool = false
    var isKeyRight:Bool = false
    var isInviteRight:Bool = false
    var isPhoneExist = false
    @IBAction func cancelKeyboard(sender: AnyObject) {
        phoneNumberTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        vertificateCodeTextField.resignFirstResponder()
//        InvitationCodeTextField.resignFirstResponder()
    }
    
    //点击获取验证码
    @IBAction func getCodeClicked(sender: UIButton) {
        
        var phone = phoneNumberTextField.text.trim()
        if(!ComFqHalcyonUilogicRegisterUILogic().checkPhoneWithNSString(phone)){
//            UIAlertViewTool.getInstance().showAutoDismisDialog("请输入11位手机号码", width: 210, height: 120)
            return
        }else{
            logic = ComFqHalcyonLogic2ResquestIdentfyLogic(comFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback:self)
            logic.reqIdentfyWithNSString(phone, withInt: 1)
            getCodeBtn.enabled = false
            getCodeCountTimer()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UITools.setBtnBackgroundColor(btnRegister,selectedColor: Color.darkPurple,unSelectedColor: Color.purple,disabledColor: Color.gray)
        UITools.setBtnBackgroundColor(getCodeBtn,selectedColor: Color.darkPink,unSelectedColor: Color.pink,disabledColor: Color.gray)
        contentView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
    }

    
    //获取验证码的倒计时
    func getCodeCountTimer(){
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeFireMethod", userInfo: nil, repeats: true)
    }
    func timeFireMethod(){
        if(secondsCountDown < 1){
            countDownTimer?.invalidate()
            getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
            if isPhoneRight{
            getCodeBtn.enabled = true
            secondsCountDown = 60
//            validatePhone()
            }
            return
        }
        secondsCountDown--
        getCodeBtn.setTitle("\(secondsCountDown)s后重新发送", forState: UIControlState.Normal)
    }
    
    //注册
    func register(){
        if(isPhoneExist){
            return
        }
        if(!(vertificateCodeTextField.text.trim() == mCodeText)){
            self.view.makeToast("验证码错误")
            return
        }
        mPhoneNumber = phoneNumberTextField.text.trim()
        mPassword = passwordTextField.text.trim()
        mRePassword = mPassword
//        mInviteCode = InvitationCodeTextField.text.trim()
        registerLogic = ComFqHalcyonLogicRegisterLogic()
        registerLogic.setListenerWithComFqHalcyonLogicRegisterLogic_RegisterLogicListener(self)
        
        
        var appType = "\(ComFqLibToolsConstants_CLIENT_HEALTH_IOS)"
        registerLogic.register__WithInt(ComFqLibToolsConstants_ClientConstants_ROLE_TYPE, withNSString: mPhoneNumber, withNSString: mPassword, withNSString: mCodeText, withNSString: mInviteCode, withNSString: Tools.getAppVersion(),withNSString:appType)
            
        //"正在注册，请稍后"
        dialog = UIAlertViewTool.getInstance().showLoadingDialog("正在注册...")
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == passwordTextField){
//            self.view.makeToast("请向注册用户索取邀请码")
            passwordTextField.becomeFirstResponder()
        }
    }
    
    //点击进入注册协议
    @IBAction func btnRegisterPotocolClicked(sender: AnyObject) {
        var controller = AboutDocPlusViewController()
        controller.isProtocol = true
        self.navigationController?.pushViewController(controller, animated: true)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        setTittle("注册")
        btnRegister.enabled = false
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSizeMake(ScreenWidth, 600)
        errorRemindLabel.text = ""
//        invitationCodeValidateMark.hidden = true
        vertificateCodeValidateMark.hidden = true
        passwordValidateMark.hidden = true
        phoneNumberValidateMark.hidden = true
        phoneNumberTextField.keyboardType = UIKeyboardType.PhonePad

        
        vertificateCodeTextField.keyboardType = UIKeyboardType.PhonePad
//        UITools.setRoundBounds(5, view: btnRegister)
//        UITools.setButtonWithColor(ColorType.EMERALD, btn: btnRegister, isOpposite: false)
        phoneNumberTextField.setFQTexfieldDelegate(self)
        passwordTextField.setFQTexfieldDelegate(self)
        vertificateCodeTextField.setFQTexfieldDelegate(self)
//        InvitationCodeTextField.setFQTexfieldDelegate(self)
//        phoneNumberTextField.setNextTextField(passwordTextField)
//        passwordTextField.setNextTextField(vertificateCodeTextField)
//        vertificateCodeTextField.setNextTextField(InvitationCodeTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vertificateCodeChange:", name: UITextFieldTextDidChangeNotification, object: vertificateCodeTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "phoneChange:", name: UITextFieldTextDidChangeNotification, object: phoneNumberTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "passwordChange:", name: UITextFieldTextDidChangeNotification, object: passwordTextField)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "inviteChange:", name: UITextFieldTextDidChangeNotification, object: InvitationCodeTextField)
        phoneNumberTextField.becomeFirstResponder()
    }
    
    func validatePhone() {
        var phone = phoneNumberTextField.text
        
        if  phone == "" {
            errorRemindLabel.text = "首位数字为1，有且只有11位数字。"
//            UIAlertViewTool.getInstance().showAutoDismisDialog("首位数字为1，有且只有11位数字。", width: 210, height: 120)
            return;
        }
        if !ComFqHalcyonUilogicRegisterUILogic.isMobileNOWithNSString(phone) {
            errorRemindLabel.text = "首位数字为1，有且只有11位数字。"
//            UIAlertViewTool.getInstance().showAutoDismisDialog("首位数字为1，有且只有11位数字。", width: 210, height: 120)
            return;
        }
        
        var registerLogic:ComFqHalcyonLogicRegisterLogic = ComFqHalcyonLogicRegisterLogic();
        registerLogic.setListenerWithComFqHalcyonLogicRegisterLogic_RegisterLogicListener(self)
        registerLogic.isPhoneExistWithNSString(phone)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //点击注册
    @IBAction func btnRigsterAction(sender: UIButton) {
        register()
        btnRegister.enabled = false
    }
    
    override func getXibName() -> String {
        return "RegisterViewController"
    }
    
    //成功获取到验证码的回调
    func resIdentfyWithNSString(identfy: String!) {

        vertificateCodeTextField.placeholder = "已发送验证码"
        mCodeText = identfy
        if(ComFqLibToolsUriConstants_Conn_PRODUCTION_ENVIRONMENT == 0){
            self.view.endEditing(true)
            var alert = UIAlertView(title:"",message:"获取到的验证码为：\(mCodeText!)",delegate:nil,cancelButtonTitle:"OK")
            alert.alertViewStyle = UIAlertViewStyle.Default
            alert.show()
        }
    }
    
    //获取验证码失败的回调
    func resIdentErrorWithInt(code: Int32, withNSString msg: String!) {
        self.view.makeToast("获取验证码失败,请重新获取")
//        UIAlertViewTool.getInstance().showAutoDismisDialog("获取验证码失败,请重新获取", width: 210.0, height: 120.0)
        countDownTimer?.invalidate()
        getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
        getCodeBtn.enabled = true
        secondsCountDown = 60
    }
    
    //注册成功的回调
    func returnDataWithInt(responseCode: Int32, withFQJSONObject results: FQJSONObject!) {
        dialog.close()
        ComFqLibToolsTool.clearUserData()
        var user = ComFqHalcyonEntityUser()
        user.setAtttributeByjsonWithFQJSONObject(results)
        user.setPhone_numberWithNSString(mPhoneNumber)
        user.setPasswordWithNSString(ComFqLibToolsTool.encryptWithNSString(mPassword))
        ComFqHalcyonExtendFilesystemFileSystem.getInstance().saveUserWithComFqHalcyonEntityUser(user)
        ComFqLibToolsConstants.setUserWithComFqHalcyonEntityUser(user)
//        UIAlertViewTool.getInstance().showAutoDismisDialog("注册成功", width: 210, height: 120)
//        self.view.makeToast("注册成功")
        mIsFirstLoading = true
        var fileSys:ComFqHalcyonExtendFilesystemFileSystem = ComFqHalcyonExtendFilesystemFileSystem.getInstance()
        fileSys.saveUserWithComFqHalcyonEntityUser(user)
        ComFqLibToolsConstants.setUserWithComFqHalcyonEntityUser(user)
        dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("注册成功", target: self, actionOk: "OK")
        //跳到填写个人信息页面
        
    }
    
    func OK(){
        dialog.close()
        ComFqLibToolsConstants.getUser().setImageIdWithInt(0)
        self.navigationController?.pushViewController(UserProfileViewController(), animated: true)
    }
    
    //注册失败的回调
    func errorWithInt(code: Int32, withNSString msg: String!) {
        if (dialog != nil) {
            dialog.close()
            btnRegister.enabled = true
            countDownTimer?.invalidate()
            getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
            getCodeBtn.enabled = true
            secondsCountDown = 60
            if(code == -11){
                return
            }
            //        UIAlertViewTool.getInstance().showAutoDismisDialog("注册失败", width: 210, height: 120)
            self.view.makeToast("注册失败")
        }
    }
    
    //验证手机号是否已注册
    func isPhoneExistWithBoolean(isExist: Bool) {
        if(isExist){
            isPhoneRight = false
            isPhoneExist = true
//            UIAlertViewTool.getInstance().showAutoDismisDialog("该手机号码已经注册过了", width: 200.0, height: 120.0)
            errorRemindLabel.text = "手机号已注册"
//            countDownTimer?.invalidate()
//            getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
            getCodeBtn.enabled = false
//            secondsCountDown = 60
            phoneNumberValidateMark.image = UIImage(named:"icon_wrong.png")
            phoneNumberValidateMark.hidden = false
            if(countDownTimer != nil){
                countDownTimer?.invalidate()
            }
        }else{
            isPhoneRight = true
            passwordTextField.resignFirstResponder()
        }
        isAllOk(TY_PHN)
    }
    
    
    
    //输入验证
    func isAllOk(type:Int){
        if(isPhoneRight && isVerRight && isKeyRight){
            btnRegister.enabled = true
        }else{
            btnRegister.enabled = false
            switch(type){
            case TY_PWD:
                if(!isKeyRight){
                    var password = passwordTextField.text.trim();
                    if(count(password) > 0){
                        errorRemindLabel.text = "6~20位数字与字母组合，无符号、中文以及空格"
                    }
                }else{
                    errorRemindLabel.text = ""
                }
            case TY_VER:
                if(!isVerRight){
                    var code = vertificateCodeTextField.text.trim();
                    if(count(code) == 4){
                        errorRemindLabel.text = "请检查您的验证码是否正确"
                    }
                }else{
                    errorRemindLabel.text = ""
                }
//            case TY_INV:
//                if(!isInviteRight){
//                    var code = InvitationCodeTextField.text.trim();
//                    if(count(code) == 4){
//                        errorRemindLabel.text = "请检查您的邀请码是否正确"
//                        invitationCodeValidateMark.image = UIImage(named:"icon_wrong.png")
//                        invitationCodeValidateMark.hidden = false
//
//                    }
//                }else{
//                    errorRemindLabel.text = ""
//                    invitationCodeValidateMark.hidden = true
//                }
            case TY_PHN:
                if(!isPhoneRight){
                    var phone = phoneNumberTextField.text.trim();
                    getCodeBtn.enabled = false
//                    if(countElements(phone) == 11){
                    if !isPhoneExist{
                        errorRemindLabel.text = "首位数字为1，有且只有11位数字。"
                    }
//                    }
                }else{
                    getCodeBtn.enabled = true
                    getCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
                    passwordTextField.becomeFirstResponder()
                }
            default:
                if(!isPhoneRight){
                    var phone = phoneNumberTextField.text.trim();
                    if(count(phone) == 11){
                        errorRemindLabel.text = "首位数字为1，有且只有11位数字。"
                    }
                }
            }
        }
    }

    //验证码输入框内容变化监听
    func vertificateCodeChange(noti : NSNotification){
        if(count(vertificateCodeTextField.text.trim())==4){
            vertificateCodeValidateMark.hidden = false
        }
        if(vertificateCodeValidateMark.hidden == true){
            errorRemindLabel.text = ""
            return
        }
        if(mCodeText != vertificateCodeTextField.text.trim()){
            isVerRight = false
            errorRemindLabel.text = "请输入正确的验证码"
            vertificateCodeValidateMark.image = UIImage(named:"icon_wrong.png")
        }else{
            isVerRight = true
            errorRemindLabel.text = ""
            vertificateCodeValidateMark.image = UIImage(named:"icon_right.png")
        }
        isAllOk(TY_VER)
    }
    
    //手机号输入框内容变化监听
    func phoneChange(noti : NSNotification){
        mPhoneNumber = phoneNumberTextField.text.trim()
        if(count(phoneNumberTextField.text.trim())==11){
            var isMobile = ComFqHalcyonUilogicRegisterUILogic.isMobileNOWithNSString(mPhoneNumber)
            if (isMobile) {
                if (!Tools.isNetWorkConnect()) {
//                    UIAlertViewTool.getInstance().showAutoDismisDialog("请检查网络连接", width: 210, height: 120)
                    self.view.makeToast("请检查网络连接")
                    return
                }
                isPhoneRight = true;
                errorRemindLabel.text = ""
                phoneNumberValidateMark.image = UIImage(named:"icon_right.png")
                phoneNumberValidateMark.hidden = false
                validatePhone()
                if(countDownTimer != nil){
                    countDownTimer?.invalidate()
                }
            }else {
            isPhoneRight = false
//            UIAlertViewTool.getInstance().showAutoDismisDialog("请输入11位手机号", width: 210, height: 120)
            phoneNumberValidateMark.image = UIImage(named:"icon_wrong.png")
            phoneNumberValidateMark.hidden = false
            mCodeText = "";
            vertificateCodeTextField.text = ""
            }
        }else{
            isPhoneRight = false
            errorRemindLabel.text = ""
            phoneNumberValidateMark.image = UIImage(named:"icon_wrong.png")
            phoneNumberValidateMark.hidden = false
        }
        isAllOk(TY_PHN)
    }
    
    //密码输入框内容变化监听
    func passwordChange(noti : NSNotification){
        var psd = passwordTextField.text.trim()
        if (psd == nil || "" == psd){
            return
        }
        if(ComFqHalcyonUilogicRegisterUILogic.checkPasswordWithNSString(psd)){
            errorRemindLabel.text = ""
            isKeyRight = true;
            passwordValidateMark.image = UIImage(named:"icon_right.png")
            passwordValidateMark.hidden = false
        }else{
            isKeyRight = false;
            passwordValidateMark.image = UIImage(named:"icon_wrong.png")
            passwordValidateMark.hidden = false
        }
        isAllOk(TY_PWD)
    }
    
    //邀请码正确
    func resWithNSString(name:String?){
//        errorRemindLabel.text = "邀请码正确 推荐人：\(name!)"
//        isInviteRight = true
//        invitationCodeValidateMark.image = UIImage(named:"icon_right.png")
//        invitationCodeValidateMark.hidden = false
//        isAllOk(TY_INV)
}
    
    //邀请码错误
    func getProviderErrorWithInt(code: Int32, withNSString msg: String!){
//        isInviteRight = false;
//        errorRemindLabel.text = "请检查您的邀请码是否正确"
//        invitationCodeValidateMark.image = UIImage(named:"icon_wrong.png")
//        invitationCodeValidateMark.hidden = false
//        UIAlertViewTool.getInstance().showAutoDismisDialog("邀请码错误！", width: 210.0, height: 120.0)
    }
    
    //邀请码输入框内容变化监听
//    func inviteChange(noti : NSNotification){
//        var invite = InvitationCodeTextField.text.trim()
//        if count(InvitationCodeTextField.text.trim()) == 4{
//            if(ComFqHalcyonUilogicRegisterUILogic.checkInviteWithNSString(invite)){
//                inviteLogic = ComFqHalcyonLogicGetProviderLogic(comFqHalcyonLogicGetProviderLogic_getProviderCallback:self)
//                inviteLogic.getProviderWithNSString(invite)
//                isInviteRight = false;
//            }else{
//                isInviteRight = false;
//            }
//        }else{
//        isInviteRight = false;
//        errorRemindLabel.text = ""
//        invitationCodeValidateMark.image = UIImage(named:"icon_wrong.png")
//        invitationCodeValidateMark.hidden = false
//        }
//        isAllOk(TY_INV)
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
        if(textField == phoneNumberTextField){
            maxNum = 11
        }else if(textField == vertificateCodeTextField){
            maxNum = 4
        }else{
            maxNum = 20
        }
        if (proposedNewLength > maxNum)
        {
            return false//限制长度
        }
        if textField == phoneNumberTextField || textField == vertificateCodeTextField {
            var isExist = false
            for i in filteredPhone {
                if i == string {
                    isExist = true
                }
            }
            if !isExist {
                return false
            }
        }else if textField == passwordTextField {
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
}