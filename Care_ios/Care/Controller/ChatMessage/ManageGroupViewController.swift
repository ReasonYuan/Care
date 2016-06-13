//
//  ManageGroupViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
import RealmSwift

var selcontacts = JavaUtilArrayList()
class ManageGroupViewController:BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate{
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var collevtionView: UICollectionView!
    @IBOutlet weak var tuichuBtn: UIButton!
    
    var mCreaterId:Int?//群主id
    var mGroupId:String?//群id
    var mIsGroupManager = true//是否是群主
    var mIsRemove = false//是否点了删除
    var mOldGroupName = ""//群名字
    var mNewGroupName = ""
    var mOldContacts:JavaUtilArrayList! = JavaUtilArrayList()//群成员
    var mSelContacts:JavaUtilArrayList! = JavaUtilArrayList() //添加或者删除过后的好友list
    
    
    
    
    var loadingDialog:CustomIOS7AlertView!
    var delDialog:CustomIOS7AlertView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle(mOldGroupName)
        hiddenRightImage(true)
        
        var groupInfo = HitalesIMSDK.sharedInstance.getOneGroupDetail(mGroupId!,mRealm:Realm(path: MessageTools.getHIMRootPath()))
        var ownerId = groupInfo!.createrId
        mCreaterId = ownerId.toInt()!
        var membersList = groupInfo?.members
        if Int32(ownerId.toInt()!) == ComFqLibToolsConstants.getUser().getUserId() {
            mIsGroupManager = true
        }else{
            mIsGroupManager = false
        }
        
        
        if mIsGroupManager {
            tuichuBtn.setTitle("删除并退出", forState: UIControlState.Normal)
            groupNameTextField.enabled = true
        }else{
            tuichuBtn.setTitle("退出该群", forState: UIControlState.Normal)
            groupNameTextField.enabled = false
        }
        
        tuichuBtn.setTitleColor(UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1), forState: UIControlState.Normal)
        tuichuBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 240/255, green: 87/255, blue: 89/255, alpha: 1)), forState: UIControlState.Normal)
        tuichuBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 240/255, green: 87/255, blue: 89/255, alpha: 0.8)), forState: UIControlState.Highlighted)
        
        groupNameTextField.text = mOldGroupName
        mNewGroupName = mOldGroupName
        
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSizeMake(45, 50)
        
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical//设置垂直显示
        
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1)//设置边距
        
        flowLayout.minimumLineSpacing = 0.0;//每个相邻layout的上下
        
        flowLayout.minimumInteritemSpacing = 0.0;//每个相邻layout的左右
        
        flowLayout.headerReferenceSize = CGSizeMake(0, 0);
        self.collevtionView.collectionViewLayout = flowLayout
        collevtionView.registerNib(UINib(nibName: "ManagerGroupCollectionViewCell", bundle:nil) ,forCellWithReuseIdentifier: "ManagerGroupCollectionViewCell")
        collevtionView.backgroundColor = UIColor.whiteColor()
        
        
        groupNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        
        for m in membersList! {
            var contact = ComFqHalcyonEntityContacts()
            var imageId:Int32?
            if m.imageId == "null" {
                imageId = 0
            }else{
                imageId = Int32(m.imageId.toInt()!)
            }
            
            var name = m.username
            var id = Int32(m.memberUserId.toInt()!)
            contact.setNameWithNSString(name)
            contact.setUserIdWithInt(id)
            contact.setImageIdWithInt(imageId!)
            
            if Int32(mCreaterId!) == id {
                mOldContacts.addWithInt(0, withId: contact)
            }else{
                mOldContacts.addWithId(contact)
                
            }
            
            
        }
        mSelContacts.addAllWithJavaUtilCollection(mOldContacts)
        collevtionView.reloadData()
        
        
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        groupNameTextField.resignFirstResponder()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldDidChange(textField:UITextField){
        mNewGroupName = textField.text
    }
    
    
    /**退出删除*/
    @IBAction func tuichu(sender: AnyObject) {
        println("退出群组")
        delDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认退出群组？", target: self, actionOk: "tuichu", actionCancle: "quxiao")
    }
    
    
    
    func tuichu(){
        self.delDialog.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("退出中...")
        
        HitalesIMSDK.sharedInstance.quitGroup(mGroupId!, success: { () -> Void in
            self.loadingDialog.close()
            
            var index:Int! = self.navigationController?.viewControllers.count
            self.navigationController?.viewControllers.removeAtIndex(index - 2)
            self.navigationController?.popViewControllerAnimated(true)
            }) { (error) -> Void in
                self.loadingDialog.close()
                self.view.makeToast("退出讨论组失败")
                
        }
    }
    
    func quxiao(){
        delDialog.close()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if selcontacts.size() != 0 {
            mSelContacts.addAllWithJavaUtilCollection(selcontacts)
            selcontacts.clear()
            collevtionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "ManageGroupViewController"
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ManagerGroupCollectionViewCell", forIndexPath: indexPath) as!
        ManagerGroupCollectionViewCell
        
        UITools.setBorderWithHeadKuang(cell.headKuang)
        var rect:CGRect? = cell.headImage.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell.headImage)

        cell.delCastans.hidden = true
        cell.removeState.hidden = true
        
        cell.addCastans.hidden = true
        cell.headKuang.hidden = false
        cell.headImage.hidden = false
        var contacts:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        var photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contacts.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            var path:NSString? = data as? NSString
            if(path != nil){
                cell.headImage.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        if !mIsRemove || indexPath.row == Int(mSelContacts.size()) || indexPath.row == Int(mSelContacts.size()+1) || indexPath.row == 0 {
        //            return
        //        }
        //        var loading = UIAlertViewTool.getInstance().showLoadingDialog("删除中...")
        //        var contact:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        
        //        IMMyselfInstance.removeMember("\(contact.getUserId())", fromGroup: mGroupId, success: { () -> Void in
        //            self.mSelContacts.removeWithInt(Int32(indexPath.row))
        //            loading.close()
        //            var logic = ComFqHalcyonLogicPracticeChatGroupLogic()
        //            var ids = JavaUtilArrayList()
        //            ids.addWithId(JavaLangInteger(int: contact.getUserId()))
        //            logic.createrDelGroupContactWithNSString(self.mGroupId, withJavaUtilArrayList: ids, withComFqHalcyonLogicPracticeChatGroupLogic_DelGroupContactCallBack: self)
        //
        //
        //            if self.mSelContacts.size() == 1 {
        //                self.mIsRemove = false
        //            }
        //            self.collevtionView.reloadData()
        //            loading.close()
        //            }, failure: { (error) -> Void in
        //
        //        })
        
    }
    
    /**添加群成员*/
    func addCastans(){
        if mIsRemove {
            mIsRemove = false
            collevtionView.reloadData()
            return
        }
        println("添加成员")
        var controller:SelectContactViewController! = SelectContactViewController()
        
        
        var ints = JavaUtilArrayList()
        for var i = 0 ; i < Int(mSelContacts.size()) ; i++ {
            var user:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
            ints.addWithId(JavaLangInteger(int: user.getUserId()))
        }
        controller.ints = ints
        controller.isCreatGroup = false
        controller.groupId = mGroupId!
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /**删除群成员*/
    func delCastans(){
        println("删除成员")
        if mSelContacts.size() == 1{
            return
        }
        mIsRemove = !mIsRemove
        collevtionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(mSelContacts.size())
        
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
    
    //    /**添加成员按钮的点击效果*/
    //    func setaddCastansstate(btn:UIButton!){
    //
    //
    //        btn.setTitleColor(UIColor(red:181/255.0,green:181/255.0,blue:181/255.0,alpha:1), forState: UIControlState.Normal)
    //        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
    //        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red:235/255.0,green:97/255.0,blue:0/255.0,alpha:1)), forState: UIControlState.Normal)
    //        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red:240/255.0,green:147/255.0,blue:116/255.0,alpha:1)), forState: UIControlState.Highlighted)
    //
    //
    //    }
    //    /**删除成员按钮的点击效果*/
    //    func setdelCastansstate(btn:UIButton!){
    //        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
    //        btn.setTitleColor(UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1), forState: UIControlState.Normal)
    //        btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
    //        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)), forState: UIControlState.Highlighted)
    //        btn.layer.borderWidth = 1.0
    //        btn.layer.borderColor = UIColor(red: CGFloat(140.0/255.0), green: CGFloat(205.0/255.0), blue: CGFloat(197.0/255.0), alpha: CGFloat(1)).CGColor
    //
    //    }
    
}