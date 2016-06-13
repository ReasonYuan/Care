//
//  ChartExploreViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChartExploreViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogicPracticePatientUpdateListLogic_PatientLineListCallback,ComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface,SelectPatientTableViewCellDelegate{
    
    @IBAction func sureClicked(sender: AnyObject) {
        
        if  sharePatient == nil {
            self.view.makeToast("请选择需要分享的病案")
            return
        }
        
            var str = "发送时包含身份信息"
            var tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
            //title
            var titleLabel = UILabel(frame: CGRectMake(0, 10, 250, 30))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.blackColor()
            titleLabel.text = "是否要去身份化？"
            titleLabel.font = UIFont.systemFontOfSize(16)
            //可选择的label
            var label = UILabel(frame: CGRectMake(0, 50, 250, 20))
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.grayColor()
            label.text = str
            label.font = UIFont.systemFontOfSize(11)
            
            //图标
            var lengthOfString: NSInteger = count(str)
            var cg = CGFloat(NSInteger(lengthOfString))
            if didSendInfo{
                imgView.image = UIImage(named: "icon_circle_yes.png")
            }else{
                imgView.image = UIImage(named: "icon_circle_no.png")
            }
            
            imgView.frame = CGRectMake((113-cg*6),54,12,12)
            //供选择的button点击  透明
            var withInfoBtn = UIButton(frame:CGRectMake(50, 40, 150, 40))
            withInfoBtn.addTarget(self,action:Selector("withInfoBtnClick:"),forControlEvents: UIControlEvents.TouchUpInside)
            var clickLabel = UILabel(frame: CGRectMake(15, 75, 220, 35))
            clickLabel.font = UIFont.systemFontOfSize(11)
            clickLabel.textAlignment = NSTextAlignment.Center
            clickLabel.textColor = Color.darkPurple
            clickLabel.text = "请确认发送该记录不会涉及您或者第三方的隐私，详情请查看《隐私条款》"
            clickLabel.numberOfLines = 0
            clickLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
            var makeSize = CGSizeMake(clickLabel.frame.size.width, CGFloat(MAXFLOAT))
            var size = clickLabel.sizeThatFits(makeSize)
            
            var secretProtocol = UIButton(frame:CGRectMake(15, 75, 220, 35))
            secretProtocol.addTarget(self,action:Selector("secretProtocolClick:"),forControlEvents: UIControlEvents.TouchUpInside)
            
            var labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
            labelLine.backgroundColor = UIColor.grayColor()
            //确定btn
            UIButton.buttonWithType(UIButtonType.Custom)
            var btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
            
            btnSure.setTitle("发送", forState: UIControlState.Normal)
            btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
            btnSure.titleLabel?.textColor = UIColor.whiteColor()
            
            btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
            btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
            btnSure.addTarget(self, action: Selector("sendClick:"), forControlEvents: UIControlEvents.TouchUpInside)
            //取消btn
            var btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
            btnCancle.setTitle("取消", forState: UIControlState.Normal)
            btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
            
            btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
            
            btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
            btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
            
            btnCancle.addTarget(self, action: Selector("cancel:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
            UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
            
            
            tmpView.addSubview(titleLabel)
            tmpView.addSubview(label)
            tmpView.addSubview(imgView)
            tmpView.addSubview(withInfoBtn)
            tmpView.addSubview(secretProtocol)
            tmpView.addSubview(clickLabel)
            tmpView.addSubview(labelLine)
            tmpView.addSubview(btnSure)
            tmpView.addSubview(btnCancle)
            dialog1.containerView = tmpView
            dialog1.show()
        

    }
    //取消发送
    func cancel(sender:AnyObject?){
        dialog1.close()
    }
    //供选择的btn点击事件
    func withInfoBtnClick(sender:AnyObject?){
        if didSendInfo{
            didSendInfo = false
            imgView.image = UIImage(named: "icon_circle_no.png")
            println("去身份化")
        }else{
            didSendInfo = true
            imgView.image = UIImage(named: "icon_circle_yes.png")
            println("不去身份化")
        }
    }
    //隐私协议
    func secretProtocolClick(sender:AnyObject?){
        dialog1.close()
        self.navigationController?.pushViewController(ProtocolViewController(),animated:true)
    }
    
    @IBOutlet var subTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var tableview: UITableView!
    var selectedItem = -1
    //loading框
    var loadingDialog:CustomIOS7AlertView?
    
    //去身份化
    var didSendInfo:Bool = true
    var dialog1 = CustomIOS7AlertView()
    var imgView:UIImageView!
    var saveloadingDialog:CustomIOS7AlertView!
    //搜索页数
    var page = 1
    
    //subTableview行数
    var counts:Int32 = 0
    
    //历史关键字列表
    var historyKeys: JavaUtilArrayList! = JavaUtilArrayList()
    
    //搜索关键字
    var searchKey:String! = ""
    
    var alert:CustomIOS7AlertView?
    var textAlert:(CustomIOS7AlertView?,UITextView?)
    var isMenuShow:Bool = false
    var selectedNumber = 0
    var checkedArray:JavaUtilArrayList!
    var index = -1
    var textView:UITextView?
    var dialog:CustomIOS7AlertView?
    var patientListlogic : ComFqHalcyonLogicPracticePatientUpdateListLogic!
    var datas:JavaUtilArrayList! = JavaUtilArrayList()
    var photoImages:JavaUtilArrayList!
    var sharePatient:ComFqHalcyonEntityPracticePatientAbstract?
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView = UIImageView()
//        setTittle("搜索")
        setRightBtnTittle("")
        setLeftTextString("返回")
        tableview.registerNib(UINib(nibName: "SelectPatientTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SelectPatientTableViewCell")
        setTableViewRefresh()
        searchBar.text = searchKey
        checkedArray = JavaUtilArrayList()
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        counts = historyKeys.size() < 5 ? historyKeys.size(): 5
        subTableView.frame = CGRectMake(0, 114, ScreenWidth, (ScreenHeight / 22.5) * CGFloat(counts))
        subTableView.backgroundColor = UIColor.lightGrayColor()
        patientListlogic = ComFqHalcyonLogicPracticePatientUpdateListLogic(comFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback: self)
        patientListlogic.requestPatientListWithInt(Int32(page), withInt: Int32(0), withBoolean:false)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("加载中...")

    }
    

    //点击发送
    func sendClick(sender:AnyObject?){
        dialog1.close()
        
        var isRemoveIdentity:Int32 = 0
        if didSendInfo{
            println("不去身份化")
            isRemoveIdentity = 0
        }else{
            println("去身份化")
            isRemoveIdentity = 1
        }
        saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("发送中,请耐心等待...")
//        if  patientsList.size() == 0 {
//            shareRecord = recordsList.getWithInt(Int32(selectedItem)) as? ComFqHalcyonEntityPracticeRecordAbstract
//            
//            
//            if shareIsGroup {
//                var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
//                sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
//            }else {
//                var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
//                sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
//            }
        
            
//        }else{
//            if selectedSection == 0 {
//                sharePatient = datas.getWithInt(Int32(selectedItem)) as? ComFqHalcyonEntityPracticePatientAbstract
        
                if shareIsGroup {
                    var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                    sendPatientLogic.sendPatientToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withNSString: shareGroupId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
                }else{
                    var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                    sendPatientLogic.sendPatientToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withInt: shareUserId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
                }
                
                
//            }else{
//                shareRecord = recordsList.getWithInt(Int32(selectedItem)) as? ComFqHalcyonEntityPracticeRecordAbstract
//                
//                
//                if shareIsGroup {
//                    var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
//                    sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
//                }else {
//                    var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
//                    sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
//                }
//                
            }
            
//        }
//        
//        
//    }
    /**获取病案share数据失败*/
    func onSendPatientErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
//        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败，请重试。")
        self.view.makeToast("获取数据失败，请重试。")
    }
    /**获取病案share数据成功*/
    func onSendPatientSuccessWithInt(shareMessageId: Int32, withInt sharePatientId: Int32,withComFqHalcyonEntityPracticePatientAbstract obj: ComFqHalcyonEntityPracticePatientAbstract!) {
        
        var chartEntity = ComFqHalcyonEntityChartEntity()
        chartEntity = ComFqHalcyonEntityChartEntity()
        chartEntity.setSharemessageIdWithInt(shareMessageId)
        chartEntity.setSharePatientIdWithInt(sharePatientId)
        chartEntity.setPatientHeadIdWithInt(sharePatient!.getUserImageId())
        chartEntity.setPatientContentWithNSString(sharePatient!.getPatientName())
        chartEntity.setPatientRecordCountWithInt(sharePatient!.getRecordCount())
        chartEntity.setPatientNameWithNSString(obj!.getShowName())
        chartEntity.setPatientSecondWithNSString(obj!.getShowSecond())
        chartEntity.setPatientThirdWithNSString(obj!.getShowThrid())
        chartEntity.setMessageTypeWithInt(2)
        chartEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
        chartEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
        chartEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
        //        shareChatEntity = chartEntity
        shareChatEntityList.addWithId(chartEntity)
        saveloadingDialog?.close()
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    

    
    override func viewWillDisappear(animated: Bool) {
        tableview.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "ChartExploreViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == subTableView {
            var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.textLabel!.text = historyKeys.getWithInt(Int32(indexPath.row)) as? String
            cell.textLabel!.font = UIFont.systemFontOfSize(12.0)
            cell.textLabel!.textColor = UIColor.lightGrayColor()
            cell.textLabel!.textAlignment = NSTextAlignment.Center
            cell.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
            return cell
        }else{
            var cell:SelectPatientTableViewCell = tableView.dequeueReusableCellWithIdentifier("SelectPatientTableViewCell") as! SelectPatientTableViewCell
            if checkedArray.getWithInt(Int32(indexPath.row)) as! Int == 1 {
                ((cell as SelectPatientTableViewCell).iconBtn).image = UIImage(named: "friend_select.png")
            }else{
                ((cell as SelectPatientTableViewCell).iconBtn).image = UIImage(named: "friend_unselect.png")
            }
            var patient:ComFqHalcyonEntityPracticePatientAbstract = datas.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract
            
            cell.tag = indexPath.row
            cell.delegate = self
            return cell
        }
    }
    
    func onCheckboxClick(cell:SelectPatientTableViewCell)
    {
        index = cell.tag
        sharePatient = datas.getWithInt(Int32(index)) as? ComFqHalcyonEntityPracticePatientAbstract
        if checkedArray.getWithInt(Int32(index)) as! Int == 1 {
            checkedArray.setWithInt(Int32(index), withId: 0)
        }else{
            checkedArray.setWithInt(Int32(index), withId: 1)
        }
        tableview.reloadData()
    }
    
    func taped(sender:UIGestureRecognizer){
   
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == subTableView {
            return ScreenHeight/22.5
        }
        return 110
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == subTableView{
            return Int(counts)
        }
        if datas == nil {return 0};
        return Int(datas.size())
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        var patient:ComFqHalcyonEntityPracticePatientAbstract = datas.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract
//        var control = ExplorationRecordListViewController()
//        control.patientItem = patient
//        control.isFromChart = true
//        self.navigationController?.pushViewController(control, animated: true)
    }
    
    //搜索框search事件
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text.isEmpty {
            return
        }
        searchKey = searchBar.text
        page = 1
        datas.clear()
        var controller = SearchViewController()
        controller.searchKey = self.searchKey
        controller.isFromChart = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.view.addSubview(subTableView)
        subTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        subTableView.removeFromSuperview()
    }
    
    /**获取病案列表失败的回调*/
    func loadPatientErrorWithInt(code: Int32, withNSString msg: String!) {
        checkedArray.clear()
        loadingDialog?.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog(msg)
    }
    
    //下载病历列表的回调
    func loadPatientLineListSuccessWithJavaUtilArrayList(list: JavaUtilArrayList!) {
        for var i :Int32 = 0; i < list.size(); i++ {
            datas.addWithId(list.getWithInt(i))
            checkedArray.addWithId(0)
        }
        page++
        loadingDialog?.close()
        tableview.reloadData()
    }
    
    func loadPatientSuccessWithJavaUtilHashMap(map: JavaUtilHashMap!) {}
    
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
        patientListlogic.requestPatientListWithInt(Int32(page), withInt: Int32(0), withBoolean:false)
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        contentTableView.footerEndRefreshing()
    }
    
}
