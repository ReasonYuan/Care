//
//  ContactsViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
var nextPosition:Int?
class ContactsViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2ContactLogic_ContactLogicInterface,UISearchBarDelegate,ZBarReaderDelegate,UINavigationControllerDelegate{
    var user:ComFqHalcyonEntityContacts?
    var mIsFirst = true
    var dialog:CustomIOS7AlertView?
    
    @IBOutlet weak var contactTableView: UITableView!
    var contacts = JavaUtilArrayList()
    var hashPeerList :JavaUtilHashMap!
    var contactsLogic :ComFqHalcyonLogic2ContactLogic!
    var cell:ContactsTableViewCell?
    var isAddViewShow = false
    
    @IBOutlet weak var addcountLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var addView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("联系人")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendAddFriendMessageToContact", name: "sendAddFriendMessageToContact", object: nil)
        hiddenLeftImage(true)
        addcountLabel.hidden = true
       
        searchBar.delegate = self
        setRightImage(isHiddenBtn: false, image: UIImage(named: "icon_topright_add.png")!)
        contactTableView.backgroundColor = UIColor(patternImage: UIImage(named: "care_bg.png")!)
        //        //空白处点击
        //        var tapGr = UITapGestureRecognizer(target: self, action: "viewTapped:")
        //        tapGr.cancelsTouchesInView = false
        //        self.view.addGestureRecognizer(tapGr)
        hiddenLeftImage(true)
        UITools.setRoundBounds(10.0,view: addcountLabel)
        contactsLogic = ComFqHalcyonLogic2ContactLogic(comFqHalcyonLogic2ContactLogic_ContactLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
        
        
//         contactTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
        
    }
    
    func sendAddFriendMessageToContact() {
        if receivedMessageCountContact != 0 {
            if receivedMessageCountContact > 99 {
                addcountLabel.text = "99+"
            }else{
                addcountLabel.text = "\(receivedMessageCountContact)"
            }
            addcountLabel.hidden = false
        }else{
            addcountLabel.hidden = true
        }
    }
    
//    func tabViewTap(tapGesture:UITapGestureRecognizer){
//        self.view.endEditing(true)
//        if isAddViewShow {
//            addView.hidden = true
//            isAddViewShow = false
//        }
//    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if isAddViewShow {
            addView.hidden = true
            isAddViewShow = false
        }

    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        super.touchesBegan(touches, withEvent: event)
//        if isAddViewShow {
//            addView.hidden = true
//            isAddViewShow = false
//        }
//    }
    
    override func viewWillAppear(animated: Bool) {
        nextPosition = self.navigationController?.viewControllers.count
        //判断是否第一次进入界面
        if(mIsFirst){
            mIsFirst = false
            return
        }else{
            //刷新数据
            contactsLogic = ComFqHalcyonLogic2ContactLogic(comFqHalcyonLogic2ContactLogic_ContactLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
        }
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        if receivedMessageCountContact != 0 {
            if receivedMessageCountContact > 99 {
                addcountLabel.text = "99+"
            }else{
                addcountLabel.text = "\(receivedMessageCountContact)"
            }
            
            addcountLabel.hidden = false
        }else{
            addcountLabel.hidden = true
        }
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        self.view.endEditing(true)
        if isAddViewShow {
            addView.hidden = true
        }else{
            addView.hidden = false
        }
        isAddViewShow = !isAddViewShow
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func getXibName() -> String {
        return "ContactsViewController"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Int(contacts.size())
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ContactsTableViewCell") as? ContactsTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ContactsTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? ContactsTableViewCell
        }
        if indexPath.row == 0 {
            cell?.topLabel.hidden = false
        }else {
            cell?.topLabel.hidden = true
        }
        UITools.setRoundBounds(20.0, view: cell!.contactsHeadImage)
        UITools.setBorderWithView(1.0, tmpColor: Color.color_grey.CGColor, view:  cell!.contactsHeadImage)
        
        var photo = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contacts.getWithInt(Int32(indexPath.row)).getImageId())
        
        cell?.contactsHeadImage.downLoadImageWidthImageId(photo.getImageId(), callback: { (view, path) -> Void in
            var tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })
        cell?.contactsName.text = contacts.getWithInt(Int32(indexPath.row)).getUsername()
        return cell!
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    //    func setTags(){
    //        dialog?.close()
    //        var control = SetTagsViewController()
    //        control.user = self.user
    //        control.imageId = self.user?.getImageId()
    //        self.navigationController?.pushViewController(control, animated: true)
    //    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if isAddViewShow {
            addView.hidden = true
            isAddViewShow = false
            return
        }
        
        var row = indexPath.row
        var controller = UserInfoViewController()
        //         if(isDoctorView == true){
        //             controller.mUser = mDoctorList[row]
        //             controller.isFriend = true
        //             controller.mRelationId = Int(mDoctorList[row].getRelationId())
        //         }else {
        controller.mUser = contacts.getWithInt(Int32(indexPath.row)) as? ComFqHalcyonEntityPerson
        controller.isFriend = true
        controller.mRelationId = Int(contacts.getWithInt(Int32(indexPath.row)).getRelationId())
        //        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //获取好友列表成功回调
    func onDataReturnWithJavaUtilHashMap(mHashPeerList: JavaUtilHashMap!) {
//        ComFqHalcyonLogic2TagLogic().getListAllTagsWithComFqHalcyonLogic2TagLogic_RequestTagInfCallBack(self)
        self.hashPeerList = mHashPeerList
        contacts.clear()
        contacts.addAllWithJavaUtilCollection(ComFqLibToolsConstants_contactsDoctorList_)
        contacts.addAllWithJavaUtilCollection(ComFqLibToolsConstants_contactsPatientList_)
        contactTableView.reloadData()
        
    }
    
    
//    //获取标签
//    func resTagListWithJavaUtilArrayList(tags: JavaUtilArrayList!) {
//        ComFqLibToolsConstants_tagList_ = tags
//    }
    
    //获取好友列表失败回调
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
//        UIAlertViewTool.getInstance().showAutoDismisDialog("网络异常或不稳定，请稍后再试, width: 240, height: 100)
        self.view.makeToast("网络异常或不稳定，请稍后再试")
    }
    
    
    @IBAction func addFriendClick(sender: AnyObject) {
        if isAddViewShow {
            addView.hidden = true
            isAddViewShow = false
        }
        var search:ContactSearchViewController = ContactSearchViewController()
        search.mTitle = "添加朋友"
        self.navigationController?.pushViewController(search, animated: true)
    }
    
    //新的朋友
    @IBAction func newFriends(sender: AnyObject) {
        self.view.endEditing(true)
        if isAddViewShow {
            addView.hidden = true
            isAddViewShow = false
            return
        }
        
        addcountLabel.text = "\(0)"
        addcountLabel.hidden = true
        receivedMessageCountGlobal = 0
        receivedMessageCountContact = 0

        NSNotificationCenter.defaultCenter().postNotificationName("sendAddFriendMessage", object: self, userInfo: ["sendAddFriendMessage":receivedMessageCountGlobal])
        self.navigationController?.pushViewController(NewFriendsViewController(), animated: true)
    }
    
    
    //搜索
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
        var keyWords = searchBar.text
        var search:ContactSearchViewController = ContactSearchViewController()
        search.mKeyWords = keyWords
        search.mTitle = "搜索"
        self.navigationController?.pushViewController(search, animated: true)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if isAddViewShow {
            addView.hidden = true
            isAddViewShow = false
        }
        return true
    }
    
    
    
    @IBAction func GroupChatClick(sender: AnyObject) {
        var controller = MoreChatListViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    /**扫一扫*/
    @IBAction func scanClick(sender: AnyObject) {
        if isAddViewShow {
            addView.hidden = true
            isAddViewShow = false
        }
        initZbar()
    }
    var zbarReader = ZBarReaderViewController()
    var timer:NSTimer?
    var position = 0
    var imageLine = UIImageView(image: UIImage(named: "erweima_search_line"))
    var selectType:Int = 0
    var mCount:CGFloat = 150
    var message:String?
    
    func initZbar(){
        zbarReader.readerDelegate = self
        zbarReader.tracksSymbols = false
        zbarReader.supportedOrientationsMask = 1
        zbarReader.readerView.frame.origin.y = 70.0
        var scanner = zbarReader.scanner
        zbarReader.readerView.torchMode = 0
        if IOS_STYLE == UIUserInterfaceIdiom.Pad {
            //( Y, 反X, height,width)
            zbarReader.scanCrop = CGRectMake((ScreenWidth*20/128)/(ScreenHeight*3/4), (ScreenWidth*25/128)/ScreenWidth, (ScreenWidth*7/16)/(ScreenHeight*3/4), (ScreenWidth*5/8)/ScreenWidth)
        }else{
            zbarReader.scanCrop = CGRectMake((ScreenWidth*9/64)/(ScreenHeight*3/4), (ScreenWidth*15/64)/ScreenWidth, (ScreenWidth*33/64)/(ScreenHeight*3/4), (ScreenWidth*17/32)/ScreenWidth)
        }
        var scanView = setScanView()
        zbarReader.cameraOverlayView = scanView
        setTopBar()
        
        zbarReader.showsZBarControls = false
        scanner.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
        
        zbarReader.view.addSubview(imageLine)
        if (timer != nil) {
            timer?.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "loop", userInfo: nil, repeats: true)
        self.navigationController?.pushViewController(zbarReader, animated: true)
        //        self.view.addSubview(zbarReader.view)
    }
    
    func setTopBar(){
        var topView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 70))
        topView.backgroundColor = UIColor(patternImage: UIImage(named: "care_bg.png")!)
        zbarReader.view.addSubview(topView)
        
        var leftBtn = UIButton(frame: CGRectMake(10, 39, 7, 10))
        leftBtn.setBackgroundImage(UIImage(named: "icon_topleft.png"), forState: UIControlState.Normal)
        
        topView.addSubview(leftBtn)
        
        var leftText = UILabel(frame: CGRectMake(23, 33, 60, 21))
        leftText.text = "返回"
        leftText.font = UIFont.systemFontOfSize(16.0)
        leftText.textColor = UIColor.whiteColor()
        var leftBigBtn = UIButton(frame: CGRectMake(0, 0, 70, 70))
        leftBigBtn.addTarget(self, action: "leftTopClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        var labelTittle = UILabel(frame: CGRectMake(ScreenWidth/4,29, ScreenWidth/2, 29))
        labelTittle.text = "扫一扫"
        labelTittle.textColor = UIColor.whiteColor()
        labelTittle.textAlignment = NSTextAlignment.Center
        labelTittle.font = UIFont.systemFontOfSize(20.0)
        
        UIButton.buttonWithType(UIButtonType.Custom)
        var fromPhotoBtn = UIButton(frame: CGRectMake(ScreenWidth - 90, 10 , 80, 70))
        fromPhotoBtn.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        fromPhotoBtn.setTitle("从相册选取", forState: UIControlState.Normal)
        fromPhotoBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        fromPhotoBtn.addTarget(self, action: "photoSelectQrcode", forControlEvents: UIControlEvents.TouchUpInside)
        
        topView.addSubview(labelTittle)
        topView.addSubview(leftText)
        topView.addSubview(fromPhotoBtn)
         topView.addSubview(leftBigBtn)
    }
    
    func setScanView() -> UIView{
        var view = UIView(frame: CGRectMake(0, 0 ,ScreenWidth, self.view.frame.size.height*3/4-76))
        var imageview = UIImageView(image: UIImage(named: "erweima_search"))
        imageview.frame = CGRectMake(ScreenWidth*3/16, ScreenWidth*5/32+76, ScreenWidth*5/8, ScreenWidth*5/8)
        view.addSubview(imageview)
        
        var leftWidth = (ScreenWidth - imageview.frame.size.width)/2
        
        var topHeight = ScreenWidth*5/32+76 - 70
        
        var upView = UIView(frame: CGRectMake(leftWidth, 70, imageview.frame.size.width, topHeight))
        upView.backgroundColor = UIColor.whiteColor()
        upView.alpha = 0.5
       
        
        var labelzbar = UILabel(frame: CGRectMake(0, upView.frame.size.height + imageview.frame.size.height + 70 + 10, ScreenWidth, 20))
        labelzbar.text = "将二维码放入框内，即可自动扫描"
        labelzbar.textAlignment = NSTextAlignment.Center
        labelzbar.font = UIFont.systemFontOfSize(13.0)
        
        var BottomHeight = ScreenHeight - imageview.frame.size.height - upView.frame.size.height - 71
        
        var leftView = UIView(frame: CGRectMake(0, 0, leftWidth, ScreenHeight))
        leftView.backgroundColor = UIColor.whiteColor()
        leftView.alpha = 0.5
        
        var rightView = UIView(frame: CGRectMake(leftWidth + imageview.frame.size.width, 0, leftWidth, ScreenHeight))
        rightView.backgroundColor = UIColor.whiteColor()
        rightView.alpha = 0.5
        
        var downView = UIView(frame: CGRectMake(leftWidth,upView.frame.size.height + imageview.frame.size.height + 70, imageview.frame.size.width, BottomHeight ))
        downView.backgroundColor = UIColor.whiteColor()
        downView.alpha = 0.5
        
       
        
        //设置button下划线长度
//        var contentLabel = UILabel(frame: CGRectMake(49, 38, ScreenWidth/2, 17))
//        contentLabel.font = UIFont.systemFontOfSize(15.0)
//        contentLabel.numberOfLines = 0
//        
//        contentLabel.text = fromPhotoBtn.titleLabel?.text!
//        contentLabel.sizeToFit()
//        
//        var paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
//        var attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
//        
//        var height = contentLabel.frame.size.height
//        var contentString:NSString = contentLabel.text!
//        var contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(height, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
//        var contentWidth = contentLableSize.width
//        
//        var line = UILabel(frame: CGRectMake(ScreenWidth/2-contentWidth*5, upView.frame.size.height + imageview.frame.size.height + 70 + 80 + 30 ,contentWidth*10, 1))
        
//        line.backgroundColor = Color.color_emerald
        
        view.addSubview(upView)
        view.addSubview(leftView)
        view.addSubview(rightView)
        view.addSubview(downView)
        view.addSubview(labelzbar)
//        zbarReader.view.addSubview(fromPhotoBtn)
//        zbarReader.view.addSubview(line)
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func loop(){
        if (position == 1) {
            mCount += 1
            imageLine.frame = CGRectMake(ScreenWidth*3/16 + 20, mCount, ScreenWidth*5/8 - 40, 2)
            if (mCount > (ScreenWidth*5/8 + ScreenWidth*5/32 - 32 + 76)) {
                position = 2
            }
        }else
        {
            mCount -= 1
            imageLine.frame = CGRectMake(ScreenWidth*3/16+20, mCount, ScreenWidth*5/8-40, 2)
            if (mCount < ScreenWidth*5/32+32+76) {
                position = 1
            }
        }
    }
    
    func doScanResult(resultString:String){
        if selectType != 1 {
            zbarReader.readerView.stop()
        }
        zbarReader.readerView.stop()
        if resultString == ""  || resultString.isEmpty {
//            UIAlertViewTool.getInstance().showAutoDismisDialog("不是有效的二维码",width:210 ,height:120)
            dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("未发现二维码", target: self, actionOk: "errorSureClick")
            if selectType != 1 {
                zbarReader.readerView.start()
            }
            
        } else {
            if resultString.hasPrefix(ComFqLibToolsUriConstants.getInvitationURL()){
                var str = resultString as NSString
                println("------------------------------\(str)")
                var index = str.indexOfString("?")
                println("------------------------------\(index)")
                var tmpstr = str.substringFromIndex(Int(index))
                
                println("------------------------------\(tmpstr)")
                var url = "\(ComFqLibToolsUriConstants.getUserURL())\(tmpstr)"
                println("------------------------------\(url)")
                var controller = UserInfoViewController()
                controller.scanUrl = url
                self.navigationController?.pushViewController(controller, animated: true)
            }else {
                if !resultString.hasPrefix("http://") && !resultString.hasPrefix("https://") {
                    timer?.fireDate = NSDate.distantFuture() as! NSDate
                    dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("不是有效的二维码,请重新扫描", target: self, actionOk: "errorSureClick")
                    return
                }
                message  = resultString
                dialog = UIAlertViewTool.getInstance().showZbarDialog("打开：\(resultString)?", target: self, actionOk: "sureClick", actionCancle: "cancleClick")
                
            }
        }
    }
    
    
    //    func readerControllerDidFailToRead(reader: ZBarReaderController!, withRetry retry: Bool) {
    //        if retry {
    //            UIAlertViewTool.getInstance().showAutoDismisDialog("不是有效的二维码",width:210 ,height:120)
    //            zbarReader.readerView.start()
    //            reader.dismissViewControllerAnimated(true, completion: nil)
    //        }
    //    }
    
    func errorSureClick(){
        dialog?.close()
        zbarReader.readerView.start()
        timer?.fireDate = NSDate.distantPast() as! NSDate
    }
    
    func sureClick(){
        var url = NSURL(string:message!)
        println("\(url!)")
        UIApplication.sharedApplication().openURL(url!)
        dialog?.close()
        println("确定")
    }
    
    func cancleClick(){
        dialog?.close()
        zbarReader.readerView.start()
        println("取消")
    }
    
    
    func photoSelectQrcode(){
        println("从相册选取二维码")
        selectType = 1
        var pickImageController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
        }
        pickImageController.delegate = self
        pickImageController.allowsEditing = false
        self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册界面
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        switch selectType {
        case 0:
            var results: NSFastEnumeration = info[ZBarReaderControllerResults] as! NSFastEnumeration
            var symbolFound : ZBarSymbol?
            for symbol in results as! ZBarSymbolSet {
                symbolFound = symbol as? ZBarSymbol
                break
            }
            
            var resultString = NSString(string: symbolFound!.data)
            println(resultString)
            doScanResult(resultString as String)
        case 1:
            var image =  info[UIImagePickerControllerOriginalImage] as! UIImage
            var mm =  zbarReader.scanner.scanImage(ZBarImage(CGImage: image.CGImage))
            if mm != 0 {
                var results = zbarReader.scanner.results
                var symbolFound : ZBarSymbol?
                for symbol in results as ZBarSymbolSet {
                    symbolFound = symbol as? ZBarSymbol
                    break
                }
                
                var resultString = NSString(string: symbolFound!.data)
                println(resultString)
                picker.dismissViewControllerAnimated(true, completion: nil)
                doScanResult(resultString as String)
                
            }else{
                picker.dismissViewControllerAnimated(true, completion: nil)
                doScanResult("")
            }
            selectType = 0
        default:
            picker.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        selectType = 0
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func leftTopClick(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
