//
//  ChangePasswordViewController.swift
//  DoctorPlus_ios
//
//  Created by liaomin on 15-7-17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController, FQTexfieldDelegate,ComFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback,
    ComFqHalcyonLogic2UserInfoManagerLogic_SuccessCallBack,
ComFqHalcyonLogic2UserInfoManagerLogic_FailCallBack {
    let color:UIColor = UIColor(red: CGFloat(243.0/255.0), green: CGFloat(118.0/255.0), blue: CGFloat(114.0/255.0), alpha: CGFloat(1))
@IBOutlet var btnResetPassword: UIButton!
 
    @IBOutlet var passwordTextF: FQTexfield!
    @IBOutlet var vertificateCodeTextF: FQTexfield!
    @IBOutlet weak var getCodeBtn: UIButton!
    
    @IBOutlet weak var surePasswordTxtf: FQTexfield!
    //@IBOutlet weak var isPhoneRightMark: UIImageView!
    @IBOutlet weak var isPasswordRightMark: UIImageView!
    @IBOutlet weak var isSurePasswordRightMark: UIImageView!
    
    //@IBOutlet weak var isVertificateRightMark: UIImageView!
  
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var mTextCode:String? //服务器返回的验证码
    var phoneNum:String?
    var password:String?
    var secondsCountDown = 60
    var isPhoneNumRight = false
    var isKeyRight = false
    var isVerRight = false
    var isSureRight = false
    var isForgetPwd :Bool! //判断是忘记密码还是修改密码，true:忘记密码, false:修改密码
    var logic :ComFqHalcyonLogic2ResquestIdentfyLogic!
    var resetLogic :ComFqHalcyonLogic2UserInfoManagerLogic!
    var countDownTimer:NSTimer? //验证码的倒计时
    var forgetPhoneText :String?
    var dialog : CustomIOS7AlertView?
    //1---------限制textField输入字数
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
        if(textField == vertificateCodeTextF){
            maxNum = 4
        }else{
            maxNum = 20
        }
        if (proposedNewLength > maxNum)
        {
            return false//限制长度
        }
        if textField == vertificateCodeTextF {
            var isExist = false
            for i in filteredPhone {
                if i == string {
                    isExist = true
                }
            }
            if !isExist {
                return false
            }
        }else
        if  textField == passwordTextF || textField == surePasswordTxtf {
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
    
        //重置密码按钮点击
        @IBAction func ResetPasswordAction(sender: UIButton){
            
                resetPassword(phoneNum!, vertification: mTextCode!, passwords: HMACSHA1_IOS.Repeat20TimesAndSHA1(passwordTextF.text))
    }

    func resetPassword(username:String, vertification:String,
        passwords:String) {

            resetLogic = ComFqHalcyonLogic2UserInfoManagerLogic()
            resetLogic.resetPasswordWithNSString(username, withNSString: vertification, withNSString: passwords, withComFqHalcyonLogic2UserInfoManagerLogic_SuccessCallBack: self, withComFqHalcyonLogic2UserInfoManagerLogic_FailCallBack: self)
            //修改中...
    }
    
        //获取验证码
        @IBAction func getCodeClicked(sender: UIButton) {
//            var phone = ComFqLibToolsConstants.getUser().getPhoneNumber()
            logic = ComFqHalcyonLogic2ResquestIdentfyLogic(comFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback:self)
            logic.reqIdentfyWithNSString(phoneNum, withInt: 2)
            
        }
    
        //获取验证码失败的回调
        func resIdentErrorWithInt(code: Int32, withNSString msg: String!) {
//            UIAlertViewTool.getInstance().showAutoDismisDialog("获取验证码失败，请重新获取", width: 210, height: 120)
            self.view.makeToast("获取验证码失败，请重新获取")
            countDownTimer?.invalidate()
            getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
            getCodeBtn.enabled = true
            secondsCountDown = 60
        }
        
        //获取验证码成功的回调
        func resIdentfyWithNSString(identfy: String!) {
            getCodeBtn.enabled = false
            getCodeCountTimer()
            vertificateCodeTextF.placeholder = "已发送验证码"
            mTextCode = identfy
            if(ComFqLibToolsUriConstants_Conn_PRODUCTION_ENVIRONMENT == 0){
                self.view.endEditing(true)
                var alert = UIAlertView(title:"",message:"获取到的验证码为：\(mTextCode!)",delegate:nil,cancelButtonTitle:"OK")
                alert.alertViewStyle = UIAlertViewStyle.Default
                alert.show()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            hiddenRightImage(true)
            setTittle("重设密码")
            //isPhoneRightMark.hidden = true
            isPasswordRightMark.hidden = true
            isSurePasswordRightMark.hidden = true
            //isVertificateRightMark.hidden = true
            
            if(isForgetPwd == true){
                if(forgetPhoneText != nil && forgetPhoneText != ""){
                    //登陆界面传手机号
                    phoneNum = forgetPhoneText
                }else{
                    phoneNum = ComFqLibToolsConstants.getUser().getPhoneNumber()
                }
            }else{
                phoneNum = ComFqLibToolsConstants.getUser().getPhoneNumber()
            }
            //        phoneNumberTextF.becomeFirstResponder()
            //        phoneNumberTextF.keyboardType = UIKeyboardType.PhonePad
            passwordTextF.becomeFirstResponder()
            vertificateCodeTextF.keyboardType = UIKeyboardType.PhonePad
            btnResetPassword.enabled = false
            UITools.setBtnBackgroundColor(btnResetPassword,selectedColor: Color.darkPink,unSelectedColor: Color.pink,disabledColor: Color.gray)
            UITools.setBtnBackgroundColor(getCodeBtn,selectedColor: Color.darkPink,unSelectedColor: Color.pink,disabledColor: Color.gray)
//            UITools.setRoundBounds(5, view: btnResetPassword)
            //UITools.setButtonWithColor(ColorType.EMERALD, btn: btnResetPassword, isOpposite: false)
            //        phoneNumberTextF.setFQTexfieldDelegate(self)
            surePasswordTxtf.setFQTexfieldDelegate(self)
            passwordTextF.setFQTexfieldDelegate(self)
            vertificateCodeTextF.setFQTexfieldDelegate(self)
            //phoneNumberTextF.setNextTextField(passwordTextF)
            passwordTextF.setNextTextField(surePasswordTxtf)
            surePasswordTxtf.setNextTextField(vertificateCodeTextF)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "vertificateCodeChange:", name: UITextFieldTextDidChangeNotification, object: vertificateCodeTextF)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "surePasswordChange:", name: UITextFieldTextDidChangeNotification, object: surePasswordTxtf)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "passwordChange:", name: UITextFieldTextDidChangeNotification, object: passwordTextF)
            
            
        }
    
   
        
        override func getXibName() -> String {
            return "ChangePasswordViewController"
        }

        
        //确认密码输入框监听
        func surePasswordChange(noti :NSNotification){
//            var psw = passwordTextF.text.trim()
            var surePsw = surePasswordTxtf.text.trim()
//            if(psw != surePsw ){
//                errorLabel.text = "密码不一致"
//                isSureRight = false
//                println(errorLabel.text)
//                isSurePasswordRightMark.image = UIImage(named:"new_icon_wrong.png")
//                isSurePasswordRightMark.hidden = false
//            }else{
//                isSureRight = true
//                password = surePsw
//                isSurePasswordRightMark.image = UIImage(named:"new_icon_right.png")
//                isSurePasswordRightMark.hidden = false
//                errorLabel.text = ""
//                
//            }
//            println("~~~")
            if(ComFqHalcyonUilogicRegisterUILogic.checkPasswordWithNSString(surePsw)){
                isSureRight = true
                password = surePsw
//                isSurePasswordRightMark.image = UIImage(named:"new_icon_right.png")
                isSurePasswordRightMark.hidden = false
                errorLabel.text = ""
            }else{
                isSureRight = false
                isSurePasswordRightMark.image = UIImage(named:"new_icon_wrong.png")
                isSurePasswordRightMark.hidden = false
            }
            isAllOK()
            //        if(countElements(surePasswordTextF.text.trim()) == 11){
            //            judgePhone(phoneNumberTextF.text.trim())
            //        }else{
            //            isPhoneNumRight = false
            
            //            isPhoneRightMark.image = UIImage(named:"icon_wrong.png")
            //            isPhoneRightMark.hidden = false
            //            errorLabel.text = ""
            //        }
            //        isAllOK()
        }
        
        //密码输入框监听
        func passwordChange(noti :NSNotification){
            var pwd = passwordTextF.text.trim()
            if(ComFqHalcyonUilogicRegisterUILogic.checkPasswordWithNSString(pwd)){
                isKeyRight = true
                password = pwd
                isPasswordRightMark.image = UIImage(named:"new_icon_right.png")
                isPasswordRightMark.hidden = false
                errorLabel.text = ""
            }else{
                isKeyRight = false
                isPasswordRightMark.image = UIImage(named:"new_icon_wrong.png")
                isPasswordRightMark.hidden = false
            }
            isAllOK()
        }
        
        //验证码输入框监听
        func vertificateCodeChange(noti :NSNotification){
            if(count(vertificateCodeTextF.text.trim()) == 4){
                if(vertificateCodeTextF.text.trim() == mTextCode){
                    isVerRight = true
                    btnResetPassword.enabled = true
                    errorLabel.text=""
//                    isAllOK()
                    // isVertificateRightMark.image = UIImage(named:"icon_right.png")
                    //isVertificateRightMark.hidden = false
                }else{
                    isVerRight = false
                    btnResetPassword.enabled = false
                    errorLabel.text="验证码错误"
                    //isVertificateRightMark.image = UIImage(named:"icon_wrong.png")
                    //isVertificateRightMark.hidden = false
                }
            }else{
//                errorLabel.text=""
                isVerRight = false
                btnResetPassword.enabled = false
                //isVertificateRightMark.image = UIImage(named:"icon_wrong.png")
                //isVertificateRightMark.hidden = false
            }
//            isAllOK()
        }
        
        //获取验证码的倒计时
        func getCodeCountTimer(){
            countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeFireMethod", userInfo: nil, repeats: true)
        }
        func timeFireMethod(){
            if(secondsCountDown < 1){
                countDownTimer?.invalidate()
                getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
                getCodeBtn.enabled = true
                secondsCountDown = 60
                return
            }
            secondsCountDown--
            getCodeBtn.enabled = false
            getCodeBtn.setTitle("\(secondsCountDown)s后重新发送", forState: UIControlState.Normal)
        }
        
    
        //判断所有的输入是否正确
        func isAllOK() {
            var pwd = passwordTextF.text.trim();
            var surePwd = surePasswordTxtf.text.trim()
            if (isSureRight && isKeyRight) {
                if(pwd != surePwd){
                    errorLabel.text = "请确认两次填写的密码是否相同"
                    getCodeBtn.enabled = false
                }else if(!isVerRight){
                    if(count(vertificateCodeTextF.text.trim()) == 4){
                        errorLabel.text="验证码错误"
                    }else{
                        errorLabel.text=""
                    }
                    isSurePasswordRightMark.image = UIImage(named:"new_icon_right.png")
                    getCodeBtn.enabled = true
                }else {
                    //TODO  这里好像没用
                    getCodeBtn.enabled = false
                    btnResetPassword.enabled = true
                    errorLabel.text = ""
                }
            } else {
                getCodeBtn.enabled = false
                btnResetPassword.enabled = false
                
                if (!isKeyRight && count(pwd) > 0) {
                    errorLabel.text = "请输入6~20位的数字与字母的密码组合"
                }else {
                    errorLabel.text = ""
                }
                
            }
        }
        

        //修改密码成功
        func onSuccessWithInt(responseCode: Int32, withNSString msg: String!, withInt type: Int32, withId results: AnyObject!) {
            if(ComFqLibToolsConstants.getUser() != nil){
                ComFqHalcyonExtendFilesystemFileSystem.getInstance().saveLoginUserWithNSString(ComFqLibToolsConstants.getUser().getPhoneNumber(), withNSString: "", withInt: ComFqLibToolsConstants.getUser().getUserId())
            }
            
            if isForgetPwd! {
                self.view.makeToast("修改成功")
//                self.navigationController?.pushViewController(LoginViewController(nibName:"LoginViewController",bundle:nil), animated: true)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }else{
                dialog = UIAlertViewTool .getInstance().showZbarDialogWith1Btn("修改密码成功，请重新登录！", target: self, actionOk: Selector("succ2Logic"))
            }
        }
    
    func succ2Logic(){
        self.navigationController?.pushViewController(LoginViewController(nibName:"LoginViewController",bundle:nil), animated: true)
        if (dialog != nil){
            dialog?.close()
        }
    }
        
        //修改密码失败
        func onFailWithInt(code: Int32, withNSString msg: String!) {
//            UIAlertViewTool.getInstance().showAutoDismisDialog("修改密码失败\(msg)", width: 210, height: 120)
            self.view.makeToast("修改密码失败\(msg)")
            countDownTimer?.invalidate()
            getCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
            getCodeBtn.enabled = true
            secondsCountDown = 60
            mTextCode = ""
        }

    var backDialog:CustomIOS7AlertView?
    
    override func onLeftBtnOnClick(sender: UIButton) {
        self.view.endEditing(true)
        backDialog = UIAlertViewTool.getInstance().showZbarDialog("确认返回？已经编辑信息将会清除！", target: self, actionOk: "onBackSureClick", actionCancle: "onBackCancelClick")
    }
    
    func onBackSureClick(){
        backDialog?.close()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onBackCancelClick(){
        backDialog?.close()
    }
}

    


