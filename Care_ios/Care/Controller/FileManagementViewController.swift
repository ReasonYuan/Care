//
//  FileManagementViewController.swift
//  Care
//
//  Created by niko on 15/8/24.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class FileManagementViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,ComFqHalcyonLogicPracticeGetMemberListLogic_GetMemberListCallBack,ComFqHalcyonLogicPracticeAddMemberLogic_AddMemberCallBack,ComFqHalcyonLogicPracticeDelMemberLogic_DelMemberCallBack{

    
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var imgHead: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var patient_relation:Int = 0
    
    let imgHeadRadius = CGFloat(48)
    let usernameRadius = CGFloat(10)
    
    var relationshipArray = [ComFqHalcyonEntityPracticeMyRelationship]()
    
    var leftMenu:HomeLeftMenuView?
    var leftMenuFrame:CGRect?
    
    var relationActionSheet:UIActionSheet?
    
    var addMemberDialog:AddMemberDialog?
    var alertDialog:CustomIOS7AlertView?
    var delDialog:CustomIOS7AlertView?
    var addMemberAlert:(CustomIOS7AlertView?,AddMemberDialog?)
    
    var relationTitleArray = [String]()
    
    var delItemIndex = -1 //需要删除的item的位置
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setUsername()
        settingHead()
        setRelationArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    init() {
        super.init(nibName: "FileManagementViewController", bundle:nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        settingHead()
        setUsername()
    }
    
    //设置用户头像
    func settingHead(){
        UITools.setRoundBounds(imgHeadRadius, view: imgHead)
        UITools.setBorderWithView(2.0, tmpColor: UIColor.whiteColor().CGColor, view: imgHead)
        imgHead.layer.backgroundColor = UIColor.clearColor().CGColor
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserImagePath()
        var name = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserHeadName()
        var getSuccess = UIImageManager.getImageFromLocal(path, imageName: name)
        if(getSuccess != nil){
            imgHead.image = getSuccess
        }else{
            imgHead.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                self.imgHead.image = UITools.getImageFromFile(path)
            })
            
        }
    }
    
    //设置用户名字
    func setUsername(){
        UITools.setRoundBounds(usernameRadius, view: usernameLabel)
        usernameLabel.text = ComFqLibToolsConstants.getUser().getName()
    }

    //设置菜单
    func setMenu(){
        leftMenuFrame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        leftMenu = HomeLeftMenuView(frame: leftMenuFrame!)
        self.view.addSubview(leftMenu!)
    }
    
    //设置tableview
    func setTableView(){
        tableView.registerNib(UINib(nibName: "FileManagementTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FileManagementTableViewCell")
        tableView.registerNib(UINib(nibName: "FileManagementFooterTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FileManagementFooterTableViewCell")
        getMemberListLogic()
    }
    
    //设置关系的列表
    func setRelationArray(){
        let array = ComFqLibToolsCareConstants.getRelationArray()
        let count = array.size()
        
        for var i:Int32 = 0 ; i < count ; i++ {
            relationTitleArray.append(array.getWithInt(i) as! String)
        }
        relationTitleArray.append("取消")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == relationshipArray.count{
            var cell = tableView.dequeueReusableCellWithIdentifier("FileManagementFooterTableViewCell") as! FileManagementFooterTableViewCell
            return cell
        }else{
            var cell = tableView.dequeueReusableCellWithIdentifier("FileManagementTableViewCell") as! FileManagementTableViewCell
            cell.relNameLabel.text = relationshipArray[indexPath.row].getRelName()
            cell.relationship.text = relationshipArray[indexPath.row].getRelationship()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationshipArray.count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == relationshipArray.count {
            addMember()
        }else{
            var controller = ReportChartViewController()
            controller.relationShip = relationshipArray[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == relationshipArray.count {
            return false
        }else{
            return true
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    //cell中删除按钮的点击事件处理
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        delItemIndex = indexPath.row
        delDialog = UIAlertViewTool.getInstance().showZbarDialog("是否删除当前档案", target: self, actionOk: "delSure", actionCancle: "delCancel")
    }
    
    //确认删除
    func delSure(){
        delMember(delItemIndex)
        closeDelDialog()
    }

    //取消删除
    func delCancel(){
        closeDelDialog()
    }
    
    func closeDelDialog(){
        delDialog?.close()
        delItemIndex = -1
    }
    
    //添加成员
    func addMember(){
        addMemberAlert = UIAlertViewTool.getInstance().showAddViewdDialog(self, actionChose: "showRelationActionSheet", actionOk: "sureAddMember", actionCancle: "cancelAddMember")
        alertDialog = addMemberAlert.0
        addMemberDialog = addMemberAlert.1
        alertDialog?.show()
    }
    
    //确定添加成员的操作
    func sureAddMember(){
        addMemberAction()
    }
    
    //取消添加成员的操作
    func cancelAddMember(){
        closeDialog()
    }
    
    //关闭添加成员的dialog
    func closeDialog(){
        alertDialog?.close()
        alertDialog = nil
        addMemberDialog = nil
    }
    
    func addMemberAction(){
        var relName = addMemberDialog?.nameText.text ?? ""
        var relationship = addMemberDialog?.identityText.text ?? ""
        
        if relName == "" {
            self.view.makeToast("请输入姓名")
            return
        }
        
        if relationship == "" {
            self.view.makeToast("请选择身份")
            return
        }
        
        addMemberLogic(relName, identityId: patient_relation)
        closeDialog()
    }
    
    //显示关系弹框
    func showRelationActionSheet(){
        if relationActionSheet == nil{
            relationActionSheet = UIActionSheet()
            
            for item in relationTitleArray {
                relationActionSheet?.addButtonWithTitle(item)
            }
            
            relationActionSheet?.cancelButtonIndex = relationTitleArray.count - 1
            relationActionSheet?.delegate = self
        }
        relationActionSheet?.showInView(self.view)
    }
    
    //点击弹框后的回调
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int){
        var title = relationActionSheet?.buttonTitleAtIndex(buttonIndex) as String?
        let cancelButtonIndex = relationTitleArray.count - 1
        if buttonIndex != cancelButtonIndex {
            addMemberDialog?.identityText.text = title
        }
        patient_relation = buttonIndex+1
    }
    
    
    //删除成员
    func delMember(position:Int){
        var member = relationshipArray[position]
        delMemberLogic(member.getPatientId())
    }
    
    //菜单按钮点击事件
    @IBAction func settingBtnOnClick() {
        NSNotificationCenter.defaultCenter().postNotificationName("SettingBtnOnClickListener", object: nil)
    }
    
    //获取成员列表的逻辑
    func getMemberListLogic(){
        var logic = ComFqHalcyonLogicPracticeGetMemberListLogic(comFqHalcyonLogicPracticeGetMemberListLogic_GetMemberListCallBack: self)
        logic.getMemberList()
    }
    
    //获取成员列表失败
    func getMemberListErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        self.view.makeToast("获取成员失败")
    }
    
    //获取成员列表成功
    func getMemberListSuccessWithJavaUtilArrayList(memberList: JavaUtilArrayList!) {
        let count = memberList.size()
        for var i:Int32 = 0 ; i < count ; i++ {
            relationshipArray.append(memberList.getWithInt(i) as! ComFqHalcyonEntityPracticeMyRelationship)
        }
        tableView.reloadData()
    }
    
    //添加成员的逻辑
    func addMemberLogic(name:String,identityId:Int){
        var logic = ComFqHalcyonLogicPracticeAddMemberLogic(comFqHalcyonLogicPracticeAddMemberLogic_AddMemberCallBack:self)
        logic.addMemberLogicWithNSString(name, withInt: Int32(identityId))
    }
    
    //添加成员成功
    func addMemberErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        self.view.makeToast("添加成员失败")
    }
    
    //添加成员失败
    func addMemberSuccessWithComFqHalcyonEntityPracticeMyRelationship(member: ComFqHalcyonEntityPracticeMyRelationship!) {
        relationshipArray.append(member)
        tableView.reloadData()
    }
    
    //删除成员的逻辑
    func delMemberLogic(patientId:Int32){
        var logic = ComFqHalcyonLogicPracticeDelMemberLogic(comFqHalcyonLogicPracticeDelMemberLogic_DelMemberCallBack: self)
        logic.delMemberLogicWithInt(patientId)
    }
    
    //删除成员失败的回调
    func delMemberErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        self.view.makeToast("删除成员失败")
    }
    
    //删除成员成功的回调
    func delMemberSuccessWithInt(patientId: Int32, withNSString msg: String!) {
        for (index,item) in enumerate(relationshipArray) {
            if item.getPatientId() == patientId {
                relationshipArray.removeAtIndex(index)
                tableView.reloadData()
                return
            }
        }
    }
}
