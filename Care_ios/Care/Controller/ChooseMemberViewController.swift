//
//  ChooseMemberViewController.swift
//  Care
//
//  Created by AppleBar on 15/8/27.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class ChooseMemberViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ComFqHalcyonLogicPracticeGetMemberListLogic_GetMemberListCallBack, ComFqHalcyonLogic2AddRecordLogic_AddRecordCallBack{
     //MARK:-------------定义变量

    @IBOutlet weak var tableView: UITableView!
    var relationshipArray = [ComFqHalcyonEntityPracticeMyRelationship]()
    var alert:CustomIOS7AlertView?
    var textAlert:(CustomIOS7AlertView?,UITextField?)
    var logic : ComFqHalcyonLogic2AddRecordLogic!
    typealias sendValueClosure = (bool:Bool)->Void
    var myClosure:sendValueClosure?
    var index = -1
    var photoImages:JavaUtilArrayList!
        //MARK:-------------初始化
    func setClosure(closure:sendValueClosure?){
        myClosure = closure
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getMemberListLogic()
        setTittle("选择档案")
        hiddenRightImage(true)
        tableView.registerNib(UINib(nibName: "ChooseMemberTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ChooseMemberTableViewCell")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha:1.0)
        logic = ComFqHalcyonLogic2AddRecordLogic(comFqHalcyonLogic2AddRecordLogic_AddRecordCallBack: self)

       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "ChooseMemberViewController"
    }
    
    // MARK:-------------调用 获取成员列表 接口
     func getMemberListLogic(){
        var logic = ComFqHalcyonLogicPracticeGetMemberListLogic(comFqHalcyonLogicPracticeGetMemberListLogic_GetMemberListCallBack: self)
        logic.getMemberList()
    }
    


    
    // MARK:-------------tableview delegate&datasource method
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ChooseMemberTableViewCell") as? ChooseMemberTableViewCell
        cell?.nameLabel.text = relationshipArray[indexPath.row].getRelName()
        cell?.relationshipLabel.text = relationshipArray[indexPath.row].getRelationship()
                 return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationshipArray.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        index = indexPath.row
        var cell = tableView.cellForRowAtIndexPath(indexPath) as? ChooseMemberTableViewCell
        var str = cell!.nameLabel.text! as String
        println(str)
        
         alert = UIAlertViewTool.getInstance().showNewDelDialog("确认移入\(str)的健康档案中吗？", target: self, actionOk: "sureCollectClick", actionCancle: "cancelCollectClick")

    }
    
    //MARK:-----------cell点击，归档
    
    //点击确认归档
    func sureCollectClick(){
        var selectedItem = relationshipArray[index]
        logic.AddRecordWithNSString(selectedItem.getRelName(), withInt: selectedItem.getPatientId(), withJavaUtilArrayList: photoImages)
        alert?.close()
    }
    
    /**
    归档取消按钮点击事件
    */
    func cancelCollectClick(){
        alert?.close()
    }
    
    //归档成功回调
    func AddRecordSuccessWithInt(code: Int32, withComFqHalcyonEntityPatient medical: ComFqHalcyonEntityPatient!, withNSString msg: String!) {
        self.view.makeToast("归档成功")
        if (myClosure != nil){
            myClosure!(bool: true)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //归档失败回调
    func AddRecordErrorWithInt(code: Int32, withNSString msg: String!) {
        self.view.makeToast("无法创建病案，请连接网络")
    }


    
    //MARK: ----------the call back method of getmemberlistlogic
    func getMemberListErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        self.view.makeToast("获取成员失败")
    }
    
    func getMemberListSuccessWithJavaUtilArrayList(memberList: JavaUtilArrayList!) {
        let count = memberList.size()
        for var i:Int32 = 0 ; i < count ; i++ {
            relationshipArray.append(memberList.getWithInt(i) as! ComFqHalcyonEntityPracticeMyRelationship)
        }
        tableView.reloadData()
    }
  
    
}
