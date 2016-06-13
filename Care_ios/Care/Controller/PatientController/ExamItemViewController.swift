//
//  ExamItemViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
var isFromSearch :Bool?

class ExamItemViewController: BaseViewController ,ComFqHalcyonUilogicRecordDTLogic_RecordDTCallBack,UITextFieldDelegate,ComFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack,NormalExamItemViewDelegate,UnnormalExamUIViewDelegate {
    var dialog:CustomIOS7AlertView!
    var textView:UITextField!
    var textView1:UITextField!
    var textView2:UITextField!
    var recordAbstract:ComFqHalcyonEntityPracticeRecordAbstract!
    var recordDTExamLogic:ComFqHalcyonUilogicRecordDTExamLogic?
    var isNormal:Bool = false
    var isShared:Bool = false
    var isEdit:Bool = true
    var normalExamItemView:NormalExamItemView!
    
    var shareMessageId:Int32!
    var saveloadingDialog:CustomIOS7AlertView?
    
    var unnormalExamItemView:UnnormalExamUIView?
    var imagesView:FullScreenImageZoomView!

    var imgList:JavaUtilArrayList?
    var isFromChart :Bool? = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if isShared {
            if isMe {
                setRightBtnTittle("")
            }else{
//                setRightBtnTittle("保存")
            }
        }else {
//            setRightBtnTittle("编辑")
            setRightBtnTittle("")
            setRightBtnClickable(false)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onExamItemChanged:", name: "OnExamItemChanged", object: nil)
        //        recordDTExamLogic = ComFqHalcyonUilogicRecordDTExamLogic(comFqHalcyonUilogicRecordDTLogic_RecordDTCallBack: self)
        //        recordDTExamLogic?.resquestRecordDetailDataWithInt(recordAbstract.getRecordInfoId())
    }
    
    override func viewWillAppear(animated: Bool) {
        recordDTExamLogic = ComFqHalcyonUilogicRecordDTExamLogic(comFqHalcyonUilogicRecordDTLogic_RecordDTCallBack: self)
        recordDTExamLogic?.resquestRecordDetailDataWithInt(recordAbstract.getRecordInfoId())
    }
    
    func loadDataSuccess() {
        if((recordDTExamLogic?.isOtherExam()) != nil && (recordDTExamLogic?.isOtherExam()) == true){
            unnormalExamItemView = UnnormalExamUIView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight))
            if isShared {
                if isMe {
                    isFromSearch = true
                    unnormalExamItemView!.backToPatientBtn.hidden = false
                }else{
                    unnormalExamItemView!.backToPatientBtn.hidden = true
                }
            }
            imgList = recordDTExamLogic?.getImgIds()
            unnormalExamItemView?.delegate = self
            unnormalExamItemView!.recordDTExamLogic = recordDTExamLogic
            unnormalExamItemView!.setDatas(recordDTExamLogic)
            setRightBtnTittle("")//先不要编辑按钮
            setRightBtnClickable(false)
            self.view.addSubview(unnormalExamItemView!)
        }else{
            normalExamItemView = NormalExamItemView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight - 70))
            if isShared {
                if isMe {
                    isFromSearch = true
                    normalExamItemView.backToPatientBtn.hidden = false
                }else{
                    normalExamItemView.backToPatientBtn.hidden = true
                }
            }
            normalExamItemView!.recordDTExamLogic = recordDTExamLogic
            normalExamItemView!.recordAbstract = self.recordAbstract
            imgList = recordDTExamLogic?.getImgIds()
            normalExamItemView.delegate = self
//            normalExamItemView!.showImages()
            normalExamItemView!.startGetPatientItemExamLogic(1)
            self.view.addSubview(normalExamItemView!)
        }
    }
    
    func loadDataErrorWithNSString(msg: String!) {
        
    }
    
    func modifyStatusWithBoolean(isb: Bool) {
        if isb {
            
        }else{
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "ExamItemViewController"
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        
        if normalExamItemView != nil {
            if imagesView != nil && !(imagesView.hidden) {
                imagesView.showOrHiddenView(false)
                imagesView.removeFromSuperview()
                imagesView = nil
            }else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else{
            unnormalExamItemView?.editTableView.hidden = true
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func okClick(){
        normalExamItemView.xmName = textView.text
        normalExamItemView.value = textView1.text
        normalExamItemView.unit = textView2.text
        normalExamItemView.editConfirm()
        setRightBtnTittle("编辑")
        isEdit = true
        normalExamItemView.unit = ""
        normalExamItemView.value = ""
        normalExamItemView.xmName = ""
        dialog.close()
    }
    
    func cancelClick(){
        setRightBtnTittle("编辑")
        isEdit = !isEdit
        dialog.close()
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        if isShared {
            if isMe {
                
            }else{
                saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("保存中，请耐心等待...")
                var saveShare = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack: self)
                saveShare.saveSharedRecordWithInt(shareMessageId, withInt:recordAbstract.getRecordItemId())
            }
            
        }else{
            
//            if(isEdit){
//                if((recordDTExamLogic?.isOtherExam()) != true){
//                    setRightBtnTittle("完成")
//                    if(normalExamItemView != nil){
//                        var mutiDialog = UIAlertViewTool.getInstance().showMutiTextViewdDialog(normalExamItemView.xmName,value: normalExamItemView.value,unit: normalExamItemView.unit, target: self, actionOk: "okClick", actionCancle: "cancelClick")
//                        dialog = mutiDialog.alertView
//                        textView = mutiDialog.textview
//                        textView1 = mutiDialog.textview1
//                        textView2 = mutiDialog.textview2
//                        textView.text = normalExamItemView.xmName
//                        textView1.text = normalExamItemView.value
//                        textView2.text = normalExamItemView.unit
//                        textView.delegate = self
//                        textView1.delegate = self
//                        textView2.delegate = self
//                    }
//                }else{
//                    setRightBtnTittle("")
//                    unnormalExamItemView?.setEditTableViewShowOrHidden(isEdit)
//                }
//            }else{
////                unnormalExamItemView?.setEditTableViewShowOrHidden(isEdit)
////                setRightBtnTittle("编辑")
//            }
//            isEdit = !isEdit
            
        }
    }
    
    /**保存失败回调*/
    func shareErrorWithInt(code: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
        dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("保存失败", target: self, actionOk: "cancel")
    }
    /**保存成功回调*/
    func shareSaveRecordSuccessWithInt(newRecordId: Int32) {
        saveloadingDialog?.close()
        dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("保存成功", target: self, actionOk: "sure")
        
    }
    
    func sure(){
        dialog?.close()
        self.navigationController?.popViewControllerAnimated(true)
    }
    func cancel(){
        dialog?.close()
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == textView {
            normalExamItemView.xmName = textView.text
        }else if textField == textView1 {
            normalExamItemView.value = textView1.text
        }else {
            normalExamItemView.unit = textView2.text
        }
    }
    
    func onImgClick() {
        showImages()
//        if imagesView != nil {
//            imagesView.showOrHiddenView(true)
//        }
    
    }
    
    func onBackClick() {
        if isFromSearch! {
            var control = ExplorationRecordListViewController()
            control.patientItem = recordDTExamLogic?.getPatientAbstract()
            control.isShared = !isMe
            self.navigationController?.pushViewController(control, animated: true)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func onLookImgClick() {
        showImages()
    }
    
    func onToPatientClick() {
        if isFromSearch! {
            var control = ExplorationRecordListViewController()
            control.patientItem = recordDTExamLogic?.getPatientAbstract()
            self.navigationController?.pushViewController(control, animated: true)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func showImages(){
        if imgList?.size() == 0 {
            self.view.makeToast("没有原图")
            return
        }
        imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        self.view.addSubview(imagesView)
        
        var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
        if imgList != nil {
            for var i:Int32 = 0 ; i < imgList!.size() ; i++ {
                var photoRecord = ComFqHalcyonEntityPhotoRecord()
                var imageId = imgList!.getWithInt(i) as! NSNumber
                photoRecord.setImageIdWithInt(imageId.intValue)
                photoRecord.setStateWithInt(ComFqHalcyonEntityPhotoRecord_REC_STATE_SUCC)
                pagePhotoRecords.append(photoRecord)
            }
        }
        
        if pagePhotoRecords.count > 0 {
            imagesView.setDatas(0, pagePhotoRecords: pagePhotoRecords)
            imagesView.showOrHiddenView(true)
        }
        
    }
    
    func onExamItemChanged(notification:NSNotification){
        imgList = notification.object as? JavaUtilArrayList
    }
}
