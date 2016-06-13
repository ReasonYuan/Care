//
//  ExplorationRecView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationRecView: UIView,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogicPracticeRecognitionLogic_RecognitionCallBack,ComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack,RecordPatientEvent,ComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack,ComFqHalcyonLogicPracticeRecordListLogic_RecordListCallBack,ComFqHalcyonLogicPracticeRecognitionLogic_ApplyRecognizeCallBack,ComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface{
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var activityIndView: UIActivityIndicatorView!
    @IBOutlet weak var refurbishBtn: UIButton!
    @IBOutlet weak var scrollToUpBtn: UIButton!
    @IBOutlet weak var scrollToBottomBtn: UIButton!
    
    var countOfTable = 0
    var tableKeys = Array<String>()
    var tableDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordAbstract>>()
    var trashDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordData>>()
    
    var isEditStatus = false //判断当前是否是编辑状态
    
    var isTrash = false //判断当前是否是回收站
    
    var recgnizeStatus:Int32 = 0 //识别状态，用于接口请求不同状态的数据
    
    var page = 1
    var pageSize = 20
    
    var patientItem:ComFqHalcyonEntityPracticePatientAbstract!
    var recordType:Int32 = 0 //当获取记录列表时判断当前选中的记录类型是什么
    
    var isPatientRecordList = false //判断是否是查看病例记录列表
    
    var isAddToHistory = false//判读是否在浏览记录时将这个病案添加进浏览历史记录
    var isShare = false //判断是否是分享界面过来的
    var isFromChart = false //判断是否是聊天界面点击分享过来的
    var SHOW_TABLE = 0;
    var SHOW_ACTIVITY_IND_VIEW = 1;
    var SHOW_REFURBISH_BUTTON = 2;
    
    
    var indetifyDialog:IndetifyDialog!
    var didSendInfo = true //是否发送身份信息
    
    var saveloadingDialog:CustomIOS7AlertView!
    var shareRecord:ComFqHalcyonEntityPracticeRecordAbstract?
    
    var isTop = true
    
    var isGetPatientName = false //判断是否已经获取过了病案的名字
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ExplorationRecView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
        contentTableView.registerNib(UINib(nibName: "RecordViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RecordViewCell")
        contentTableView.registerNib(UINib(nibName: "PatientViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientViewCell")
        timeTableView.registerNib(UINib(nibName: "CheckboxTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CheckboxTableViewCell")
        
        timeTableView.scrollEnabled = false
        setTableViewRefresh()
        scrollToUpBtn.setBackgroundImage(UIImage(named: "pull_up_pressed_btn.png"), forState: UIControlState.Selected)
        scrollToUpBtn.setBackgroundImage(UIImage(named: "pull_up_unpressed_btn.png"), forState: UIControlState.Normal)
        scrollToBottomBtn.setBackgroundImage(UIImage(named: "pull_down_pressed_btn.png"), forState: UIControlState.Selected)
        scrollToBottomBtn.setBackgroundImage(UIImage(named: "pull_down_unpressed_btn.png"), forState: UIControlState.Normal)
        scrollToUpBtn.hidden = true
        scrollToBottomBtn.hidden = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewShowOrHidden(ctrlStyle:Int){
        switch ctrlStyle {
        case SHOW_TABLE:
            timeTableView.hidden = false
            contentTableView.hidden = false
            activityIndView.hidden = true
            refurbishBtn.hidden = true
            activityIndView.stopAnimating()
        case SHOW_ACTIVITY_IND_VIEW:
            timeTableView.hidden = true
            contentTableView.hidden = true
            activityIndView.hidden = false
            refurbishBtn.hidden = true
            activityIndView.startAnimating()
        case SHOW_REFURBISH_BUTTON:
            timeTableView.hidden = true
            contentTableView.hidden = true
            activityIndView.hidden = true
            refurbishBtn.hidden = false
            activityIndView.stopAnimating()
        default:
            activityIndView.stopAnimating()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == contentTableView {
            if isTrash {
                
                var item = trashDatas[tableKeys[indexPath.section]]![indexPath.row] as ComFqHalcyonEntityPracticeRecordData
                if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD {
                    var contentCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
                    contentCell.initDataForRecycle(item as! ComFqHalcyonEntityPracticeRecordAbstract, indexPath: indexPath, event: self)
                    contentCell.setCanSliding(!isEditStatus)
                    return contentCell
                }else if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_PATIENT {
                    var cell = tableView.dequeueReusableCellWithIdentifier("PatientViewCell") as! PatientViewCell
                    cell.initDataForRecycle(item as! ComFqHalcyonEntityPracticePatientAbstract, indexPath: indexPath, event: self)
                    cell.setCanSliding(!isEditStatus)
                    return cell
                }
                var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
                return cell
            }else{
                
                var contentCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
                contentCell.initData(tableDatas[tableKeys[indexPath.section]]![indexPath.row], indexPath: indexPath, event: self,isCanSliding:!isShare)
                if isEditStatus {
                    contentCell.setCanSliding(false)
                }else if !isEditStatus && !isShare {
                    contentCell.setCanSliding(true)
                }
                return contentCell
            }
            
        }else if tableView == timeTableView{
            var cell = tableView.dequeueReusableCellWithIdentifier("CheckboxTableViewCell") as! CheckboxTableViewCell
            
            if isEditStatus {
                cell.checkboxImage.hidden = false
                if isTrash {
                    var item = trashDatas[tableKeys[indexPath.section]]![indexPath.row]
                    setCheckBoxStyle(item.isSelected(), cell: cell)
                }else{
                    var item = tableDatas[tableKeys[indexPath.section]]![indexPath.row]
                    setCheckBoxStyle(item.isSelected(), cell: cell)
                }
            }else{
                cell.checkboxImage.hidden = true
            }
            
            return cell
        }
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        return cell
    }
    
    //设置checkboxCell选中和未选中时的显示
    func setCheckBoxStyle(isSelected:Bool,cell:CheckboxTableViewCell){
        
        if isSelected {
            if isFromChart {
                cell.checkboxImage.image = UIImage(named: "select_dot.png")
            }else{
                cell.checkboxImage.image = UIImage(named: "friend_select.png")
            }
            
        }else{
            if isFromChart {
                cell.checkboxImage.image = UIImage(named: "unselect_dot.png")
            }else{
                cell.checkboxImage.image = UIImage(named: "friend_unselect.png")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTrash {
            countOfTable = trashDatas[tableKeys[section]]!.count
            return trashDatas[tableKeys[section]]!.count
        }else{
            countOfTable = tableDatas[tableKeys[section]]!.count
            return tableDatas[tableKeys[section]]!.count
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == timeTableView {
            if tableView.headerViewForSection(section) == nil {
                var view = ExplorationRecTimeCellHeadView(frame: CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight))
                var timeStr = tableKeys[section]
                if (timeStr as NSString).length >= 8 {
                    var year = timeStr.substringToIndex(advance(timeStr.startIndex, 4))
                    var month = (timeStr as NSString).substringWithRange(NSMakeRange(4, 2))
                    var day = (timeStr as NSString).substringWithRange(NSMakeRange(6, 2))
                    view.yearLabel.text = year
                    view.dayLabel.text = "\(month)/\(day)"
                }
                tableView.headerViewForSection(section)
                return view
            }else{
                return tableView.headerViewForSection(section)
            }
        }
        
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableKeys.count
    }
    
    /**tableview滑动处理*/
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == contentTableView {
            self.timeTableView.setContentOffset(self.contentTableView.contentOffset, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == timeTableView {
            if isEditStatus {
                var cell = tableView.dequeueReusableCellWithIdentifier("CheckboxTableViewCell") as! CheckboxTableViewCell
                if isTrash {
                    var item = trashDatas[tableKeys[indexPath.section]]![indexPath.row]
                    setItemStatus(item.isSelected(), item: item)
                }else{
                    var item = tableDatas[tableKeys[indexPath.section]]![indexPath.row]
                    setItemStatus(item.isSelected(), item: item)
                }
                timeTableView.reloadData()
            }
        }
    }
    
    /**设置是否选中的状态*/
    func setItemStatus(isSelected:Bool,item:AnyObject){
        if isFromChart {
            cleanAllSelectedStatus()
        }
        if isSelected {
            item.setSelectedWithBoolean(false)
        }else{
            item.setSelectedWithBoolean(true)
        }
    }
    
    func cleanDatas(){
        page = 1
        tableKeys = Array<String>()
        tableDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordAbstract>>()
        trashDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordData>>()
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    func setDataKeys(keys:JavaUtilArrayList){
        for var i:Int32 = 0 ; i < keys.size() ; i++ {
            var isExist = false
            for item in tableKeys {
                if item == keys.getWithInt(i) as! String {
                    isExist = true
                    break
                }
            }
            if !isExist {
                tableKeys.append(keys.getWithInt(i) as! String)
            }
        }
    }
    
    /**设置非回收站数据*/
    func setDatas(keys:JavaUtilArrayList,datas:JavaUtilHashMap){
        
        setDataKeys(keys)
        
        for item in tableKeys {
            if datas.containsKeyWithId(item) {
                var array = datas.getWithId(item) as! JavaUtilArrayList
                var tmpArray = Array<ComFqHalcyonEntityPracticeRecordAbstract>()
                for var i:Int32 = 0 ; i < array.size() ; i++ {
                    tmpArray.append(array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordAbstract)
                }
                if tableDatas[item] == nil {
                    tableDatas[item] = tmpArray
                }else{
                    tableDatas[item] = tableDatas[item]! + tmpArray
                }
            }
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**设置回收站数据*/
    func setTrashDatas(keys: JavaUtilArrayList!, withJavaUtilHashMap datas: JavaUtilHashMap!){
        
        setDataKeys(keys)
        
        for item in tableKeys {
            if datas.containsKeyWithId(item) {
                var array = datas.getWithId(item) as! JavaUtilArrayList
                var tmpArray = Array<ComFqHalcyonEntityPracticeRecordData>()
                for var i:Int32 = 0 ; i < array.size() ; i++ {
                    tmpArray.append(array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordData)
                }
                if trashDatas[item] == nil {
                    trashDatas[item] = tmpArray
                }else{
                    trashDatas[item] = trashDatas[item]! + tmpArray
                }
            }
        }
        
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    
    /**得到选中的记录*/
    func getSelectedDatas() -> JavaUtilArrayList {
        
        var selectedArray = JavaUtilArrayList()
        if isTrash {
            for (key,itemList) in trashDatas {
                for item in itemList {
                    if item.isSelected() {
                        selectedArray.addWithId(item)
                    }
                }
            }
        }else{
            
            for (key,itemList) in tableDatas {
                for item in itemList {
                    if item.isSelected() {
                        selectedArray.addWithId(item)
                    }
                }
            }
        }
        return selectedArray
    }
    
    /**清除所有的选中状态*/
    func cleanAllSelectedStatus(){
        for (key,itemList) in tableDatas {
            for item in itemList {
                if item.isSelected() {
                    item.setSelectedWithBoolean(false)
                }
            }
        }
    }
    
    /**批量删除数据*/
    func delDatas(){
        if getSelectedDatas().size() == 0 {
            return
        }
        if isTrash {
            var logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
            logic.clearDataWithJavaUtilArrayList(getSelectedDatas())
        }else{
            var logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack: self)
            logic.removeRecordDataWithJavaUtilArrayList(getSelectedDatas())
        }
    }
    
    /**批量分享数据*/
    func shareDatas(){
        
        if getSelectedDatas().size() == 0 {
            self.makeToast("请选择需要分享的记录")
            return
        }
        
        if isFromChart {
            indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "sendClick", actionCancle: "dialogCancle", actionRemoveIndentify: "xieyi", selecBtn: "click")
        }else{
            indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "dialogOk", actionCancle: "dialogCancle", actionRemoveIndentify: "xieyi", selecBtn: "click")
        }
        
        
    }
    
    func sendClick(){
        
        indetifyDialog.alertView?.close()
        var isRemoveIdentity:Int32 = 0
        if didSendInfo{
            println("不去身份化")
            isRemoveIdentity = 0
        }else{
            println("去身份化")
            isRemoveIdentity = 1
        }
        saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("发送中,请耐心等待...")
        var shareRecordList = getSelectedDatas()
        if shareRecordList.size() > 0 {
            shareRecord = shareRecordList.getWithInt(Int32(0)) as? ComFqHalcyonEntityPracticeRecordAbstract
            var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
            if !shareIsGroup {
                sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
            }else {
                sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: shareRecord!.getRecordItemId(), withComFqHalcyonEntityPracticeRecordAbstract: shareRecord, withInt: isRemoveIdentity)
            }
        }
    }
    
    
    //确认分享
    func dialogOk(){
        var controller = MoreChatListViewController()
        controller.type = 3
        controller.recordList = getSelectedDatas()
        controller.didSendInfo = didSendInfo;
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
        indetifyDialog.alertView?.close()
        didSendInfo = true
    }
    //取消分享
    func dialogCancle(){
        indetifyDialog.alertView?.close()
    }
    //查看协议
    func xieyi(){
        indetifyDialog.alertView?.close()
        Tools.getCurrentViewController(self).navigationController?.pushViewController(ProtocolViewController() , animated: true)
    }
    //是否包含身份信息
    func click(){
        didSendInfo = !didSendInfo;
        if didSendInfo{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
        }else{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
        }
        
    }
    
    
    
    /**批量云识别数据*/
    func ocrDatas(){
        var logic = ComFqHalcyonLogicPracticeRecognitionLogic(comFqHalcyonLogicPracticeRecognitionLogic_ApplyRecognizeCallBack: self)
        logic.applyRecognizeWithJavaUtilArrayList(getSelectedDatas())
    }
    
    /**批量恢复数据*/
    func huifuDatas(){
        if getSelectedDatas().size() == 0 {
            return
        }
        var logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
        logic.retoreDataWithJavaUtilArrayList(getSelectedDatas())
    }
    
    /**获取云识别或者等待云识别的数据
    recgnizeStatus:
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_END：识别完成
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_ING：识别中
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_WAIT：等待识别
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_ALL:请求全部
    isTrash:
    判断是否是回收站
    */
    func getRecRecordLogic(recgnizeStatus:Int32,isTrash:Bool){
        self.isTrash = isTrash
        if isTrash {
            getTrashItemLogic()
        }else{
            self.recgnizeStatus = recgnizeStatus
            getrecordItemLogic()
        }
        
    }
    
    /**获取非回收站的数据逻辑*/
    func getrecordItemLogic(){
        var logic = ComFqHalcyonLogicPracticeRecognitionLogic(comFqHalcyonLogicPracticeRecognitionLogic_RecognitionCallBack: self)
        logic.loadRecognitionListWithInt(recgnizeStatus, withInt: Int32(page), withInt: Int32(pageSize))
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
    }
    
    /**获取回收站的数据逻辑*/
    func getTrashItemLogic(){
        var logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
        logic.loadRecyleListWithInt(Int32(page), withInt: Int32(pageSize))
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
    }
    
    /**获取云识别数据错误的回调*/
    func recognzeErrorWithInt(code: Int32, withNSString msg: String!) {
        if page == 1 {
            setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
            refurbishBtn.setTitle("获取失败，点击刷新", forState: UIControlState.Normal)
        }
    }
    
    /**获取非回收站数据成功的回调*/
    func recognzeReturnDataWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap recordMap: JavaUtilHashMap!) {
        
        if page == 1 {
            if recordMap.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
            
        }
        if keys.size() > 0 {
            setDatas(keys,datas: recordMap)
            page += 1
        }
        
    }
    
    /**回收站item被删除*/
    func onRPItemClear(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**点击某个item的回调*/
    func onRPItemClick(indexPath: NSIndexPath!) {
        var item = tableDatas[tableKeys[indexPath.section]]![indexPath.row]
        //现在不用历史记录了，所以注销掉
        //        if(isPatientRecordList && !isAddToHistory){
        //            isAddToHistory = true
        //            var history = ComFqHalcyonPracticeReadHistoryManager.getInstance()
        //            history.addPatientAbsWithComFqHalcyonEntityPracticePatientAbstract(patientItem)
        //        }
        println("\(item.getRecordInfoId())")
    }
    
    /**回收站item被恢复*/
    func onRPItemRecover(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**删除某个item的回调*/
    func onRPItemRemove(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**分享某个item的回调*/
    func onRPItemShare(indexPath: NSIndexPath!) {
        
    }
    
    /**结构化某个item的回调*/
    func onRPItemStruct(indexPath: NSIndexPath!) {
        
    }
    
    /**云识别某个ITEM的回调*/
    func onRPItemCloud(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**获取回收站数据成功的回调*/
    func recycleDatasWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap recyDataMap: JavaUtilHashMap!) {
        if page == 1 {
            if recyDataMap.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
        }
        if keys.size() > 0 {
            setTrashDatas(keys,withJavaUtilHashMap: recyDataMap)
            page = page + 1
        }
    }
    
    /**
    * 从回收站清除数据成功后的回调方法
    */
    func recycelClearDataSuccess() {
        delTableDatas()
    }
    
    /**
    * 从回收站恢复数据成功后的回调方法
    */
    func recycelRestoreDataSuccess() {
        delTableDatas()
    }
    
    /**请求回收站操作服务器出错的回调*/
    func recycleErrorWithInt(code: Int32, withNSString msg: String!) {
        self.makeToast("操作失败")
    }
    
    /**删除记录到回收站成功的回调*/
    func removeSuccess() {
        delTableDatas()
    }
    
    /**删除记录到回收站失败的回调*/
    func removeErrorWithInt(code: Int32, withNSString msg: String!) {
        self.makeToast("删除失败")
    }
    
    /**从array中删除选中的数据并跟新UI*/
    func delTableDatas(){
        if getSelectedDatas().size() == 0 {
            return
        }
        let selectedCount = getSelectedDatas().size()
        let array = getSelectedDatas()
        for var i:Int32 = 0 ; i < selectedCount; i++ {
            var tmp: ComFqHalcyonEntityPracticeRecordData! = array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordData
            for key in tableKeys {
                if isTrash {
                    var itemArray = trashDatas[key]!
                    for (index,item) in enumerate(itemArray) {
                        if tmp.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD{
                            var tmp = array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordAbstract
                            if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD {
                                if (item as! ComFqHalcyonEntityPracticeRecordAbstract).getRecordItemId() == tmp.getRecordItemId(){
                                    trashDatas[key]?.removeAtIndex(index)
                                    setKeyAndDatas(key)
                                    break
                                }
                            }
                        }else if tmp.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_PATIENT{
                            var tmp = array.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract
                            if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_PATIENT {
                                if (item as! ComFqHalcyonEntityPracticePatientAbstract).getPatientId() == tmp.getPatientId(){
                                    trashDatas[key]?.removeAtIndex(index)
                                    setKeyAndDatas(key)
                                    break
                                }
                            }
                        }
                    }
                }else{
                    var itemArray = tableDatas[key]!
                    for (index,item) in enumerate(itemArray) {
                        if (tmp as! ComFqHalcyonEntityPracticeRecordAbstract).getRecordItemId() == item.getRecordItemId() {
                            tableDatas[key]!.removeAtIndex(index)
                            setKeyAndDatas(key)
                            break
                        }
                    }
                }
            }
            
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**当某个array数据删除到0时，从字典中清除*/
    func setKeyAndDatas(key:String){
        if isTrash {
            if trashDatas[key]!.count == 0 {
                self.trashDatas[key] = nil
                for (index,item) in enumerate(tableKeys) {
                    if item == key {
                        tableKeys.removeAtIndex(index)
                        break
                    }
                }
            }
        }else{
            if tableDatas[key]!.count == 0 {
                self.tableDatas[key] = nil
                for (index,item) in enumerate(tableKeys) {
                    if item == key {
                        tableKeys.removeAtIndex(index)
                        break
                    }
                }
            }
        }
        
    }
    
    /**删除某个一数据*/
    func delOneData(indexPath: NSIndexPath!){
        var key = tableKeys[indexPath.section]
        var index = indexPath.row
        if isTrash {
            trashDatas[key]!.removeAtIndex(index)
        }else{
            tableDatas[key]!.removeAtIndex(index)
        }
        setKeyAndDatas(key)
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**设置tabview 上拉下拉**/
    func setTableViewRefresh(){
        contentTableView.headerBeginRefreshing()
        //        patientTableView.addHeaderWithTarget(self, action: "headerRereshing")
        contentTableView.addFooterWithTarget(self, action: "footerRereshing")
    }
    
    /**下拉事件处理**/
    /*  func headerRereshing(){
    // 刷新表格
    patientTableView.reloadData()
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    patientTableView.headerEndRefreshing()
    }*/
    
    /**上拉事件处理**/
    func footerRereshing(){
        // 刷新表格
        if isTrash {
            getTrashItemLogic()
        }else{
            if isPatientRecordList {
                getRecordList(recordType)
            }else{
                getrecordItemLogic()
            }
        }
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        contentTableView.footerEndRefreshing()
    }
    
    /**
    获取病案下的记录列表的逻辑
    */
    func getRecordList(recordType:Int32){
        self.recordType = recordType
        var logic = ComFqHalcyonLogicPracticeRecordListLogic(comFqHalcyonLogicPracticeRecordListLogic_RecordListCallBack: self)
        
        //对于care的记录列表，只需要下载普通的（除体检报告）类型的
        logic.loadRecordListWithInt(patientItem.getPatientId(), withInt: recordType, withInt: Int32(page), withInt: Int32(pageSize),withInt: ComFqHalcyonLogicPracticeRecordListLogic_RECORD_KIND_NORMAL)
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
    }
    
    /**获取病案下记录列表成功的回调*/
    func recordListCallbackWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        var dataHeight:CGFloat = 0.0
        
        if recordType == 0 && !isGetPatientName {
            isGetPatientName = true
            if map.size() > 0 {
                var array = map.getWithId(keys.getWithInt(0)) as! JavaUtilArrayList
                var record = array.getWithInt(0) as! ComFqHalcyonEntityPracticeRecordAbstract;
                NSNotificationCenter.defaultCenter().postNotificationName("GetPatientName", object: record.getPatientName())
            }
        }
        
        if page == 1 {
            if map.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
                
                for var i:Int32 = 0; i < keys.size();i++ {
                    dataHeight += 50
                    dataHeight += CGFloat(((map.getWithId(keys.getWithInt(i)) as! JavaUtilArrayList).size()) * 110)
                }
                
                //判断是否让置顶置底按钮消失
                if dataHeight < contentTableView.frame.height {
                    scrollToUpBtn.hidden = true
                    scrollToBottomBtn.hidden = true
                }else{
                    scrollToUpBtn.hidden = false
                    scrollToBottomBtn.hidden = false
                }
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                scrollToUpBtn.hidden = true
                scrollToBottomBtn.hidden = true
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
        }
        if keys.size() > 0 {
            setDatas(keys, datas: map)
            page = page + 1
        }

    }
    
    
    /**获取病案下记录列表失败的回调*/
    func errorWithInt(code: Int32, withNSString msg: String!) {
        if page == 1 {
            setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
            refurbishBtn.setTitle("获取失败，点击刷新", forState: UIControlState.Normal)
        }
    }
    
    /**
    * 接口访问成功的回调方法。
    */
    func applyRecognizeSuccess() {
        delTableDatas()
    }
    
    /**
    * 请求错误的回调(包括访问出错和服务器出错)。
    */
    func applyErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("分享失败！")
    }
    
    @IBAction func refurbishBtnClick(sender: AnyObject) {
        if isTrash {
            getTrashItemLogic()
        }else{
            if isPatientRecordList {
                getRecordList(recordType)
            }else{
                getrecordItemLogic()
            }
        }
    }
    
    /**设置是否是分享状态*/
    func setShareStatus(isShare:Bool){
        self.isShare = isShare
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    func reloadTable(){
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    func onSendRecordErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
//        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败，请重试。")
         Tools.getCurrentViewController(self).view.makeToast("获取数据失败，请重试。")
    }
    
    func onSendRecordSuccessWithInt(shareMessageId: Int32, withInt shareRecordItemId: Int32, withFQJSONArray shareRecordInfIds: FQJSONArray!, withComFqHalcyonEntityPracticeRecordAbstract obj: ComFqHalcyonEntityPracticeRecordAbstract!) {
        for m in 0..<shareRecordInfIds.length() {
            var chartEntity = ComFqHalcyonEntityChartEntity()
            chartEntity.setSharemessageIdWithInt(shareMessageId)
            chartEntity.setShareRecordItemIdWithInt(shareRecordItemId)
//            chartEntity.setRecStatusWithInt(shareRecord!.getRecStatus())
            chartEntity.setRecordInfoIdWithInt(shareRecordInfIds.optIntWithInt(m))
            chartEntity.setRecordTypeWithInt(shareRecord!.getRecordType())
            chartEntity.setRecordTimeWithNSString(shareRecord!.getDealTime())
            chartEntity.setRecordBelongNameWithNSString(shareRecord!.getRecordItemName())
            chartEntity.setRecordContentWithNSString(shareRecord!.getInfoAbstract())
            chartEntity.setMessageTypeWithInt(3)
            chartEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
            chartEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            chartEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
            //            shareChatEntity = chartEntity
            shareChatEntityList.addWithId(chartEntity)
        }
        saveloadingDialog?.close()
        if shareIsGroup && MoreChatViewControllerInstance != nil {
            Tools.getCurrentViewController(self).navigationController?.popToViewController(MoreChatViewControllerInstance!, animated: true)
        }else if !shareIsGroup && SimpleChatViewControllerInstance != nil {
            Tools.getCurrentViewController(self).navigationController?.popToViewController(SimpleChatViewControllerInstance!, animated: true)
        }
        //        var navc = Tools.getCurrentViewController(self).navigationController
        //        if(navc != nil){
        //            let controllers :[AnyObject] = Tools.getCurrentViewController(self).navigationController!.viewControllers
        //            let index = controllers.count
        //            Tools.getCurrentViewController(self).navigationController?.viewControllers.removeAtIndex( index - 2 )
        //            Tools.getCurrentViewController(self).navigationController?.popViewControllerAnimated(true)
        //        }
        
    }
    
    @IBAction func scrollToUpClicked(sender: AnyObject) {
        scrollToUpBtn.selected = true
        scrollToBottomBtn.selected = false
        var topRow = NSIndexPath(forRow: 0, inSection: 0)
        self.contentTableView.scrollToRowAtIndexPath(topRow, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    @IBAction func scrollToBottomClicked(sender: AnyObject) {
        scrollToUpBtn.selected = false
        scrollToBottomBtn.selected = true
        self.contentTableView.setContentOffset(CGPointMake(0, self.contentTableView.contentSize.height - self.contentTableView.bounds.size.height), animated: true)
    }

    
}
