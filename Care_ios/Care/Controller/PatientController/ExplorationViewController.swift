//
//  ExplorationViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationViewController: BaseViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource{

    
    @IBOutlet var historyKeyTable: UITableView! //搜索历史关键字
    @IBOutlet weak var leftMenu: UIView!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var ctrlView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet var waitRecCtrlView: UIView!
    @IBOutlet var trashCtrlView: UIView!
    
    @IBOutlet weak var zuijinBtn: UIButton!
    @IBOutlet weak var waitRecBtn: UIButton!
    @IBOutlet weak var recingBtn: UIButton!
    @IBOutlet weak var recOverBtn: UIButton!
    @IBOutlet weak var trashBtn: UIButton!
    
    var menuBtnArray = [UIButton]()
    
    var touchView:UIView!
    var verLine:UILabel!
    
    var isCtrlViewShow = false
    var isLeftMenuShow = false
    
    var explorationView:ExplorationView! //我的病例库
    var recOverView:ExplorationRecView! //云识别
    var trashView:ExplorationRecView! //回收站
    
    var pageViews = [UIView]()
    
    var explorationViewY:CGFloat!
    var leftMenuCGPointY:CGFloat!
    var leftMenuWidth:CGFloat!
    var leftMenuHeight:CGFloat!
    
    var leftMenuShowFrame:CGRect!
    var leftMenuHiddenFrame:CGRect!
    
    var contentFrame:CGRect!
    var contentShowCtrlFrame:CGRect!
    var verLineShowFrame:CGRect!
    var verLineHiddenFrame:CGRect!
    var ctrlViewShowFrame:CGRect!
    var ctrlViewHiddenFrame:CGRect!
    
    var historyKeyFrame:CGRect!
    
    var showViewPosition = 0
    
    var isExperience = false //判断是否是体验账号
    
    var titleLabels = ["我的病例库","云识别完成","回收站"]
    
    //历史关键字列表
    var historyKeys: JavaUtilArrayList! = JavaUtilArrayList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("行医生涯")
        setRightBtnTittle("编辑")
        
        isExperience = MessageTools.isExperienceMode()
        
        searchView.delegate = self
        explorationViewY = lineLabel.frame.size.height + searchView.frame.size.height + titleLabel.frame.size.height + 70
        contentFrame = CGRectMake(0 , explorationViewY , ScreenWidth , ScreenHeight - explorationViewY)
        contentShowCtrlFrame = CGRectMake(0 , explorationViewY , ScreenWidth , ScreenHeight - explorationViewY - 70)
        explorationView = ExplorationView(frame: contentFrame)
        recOverView = ExplorationRecView(frame: contentFrame)
        trashView = ExplorationRecView(frame: contentFrame)
        
        verLineShowFrame = CGRectMake(60 , explorationViewY , 1 , ScreenHeight - explorationViewY - 68)
        verLineHiddenFrame = CGRectMake(60 , explorationViewY , 1 , ScreenHeight - explorationViewY)
        
        verLine = UILabel(frame: CGRectMake(60 , explorationViewY , 1 , ScreenHeight - explorationViewY))
        verLine.backgroundColor = Color.color_verline
        
        explorationView.setDatas(false)
        recOverView.hidden = true
        trashView.hidden = true
        
        explorationView.navigationController = self.navigationController
        
        self.view.addSubview(explorationView)
        self.view.addSubview(recOverView)
        self.view.addSubview(trashView)
        self.view.addSubview(verLine)
        
        pageViews = [explorationView,recOverView,trashView]
        
        leftMenuCGPointY = 70
        leftMenuWidth = 80
        leftMenuHeight = ScreenHeight - leftMenuCGPointY
        leftMenuShowFrame = CGRectMake(0, leftMenuCGPointY, leftMenuWidth, leftMenuHeight)
        leftMenuHiddenFrame = CGRectMake(-leftMenuWidth, leftMenuCGPointY, leftMenuWidth, leftMenuHeight)
        leftMenu.frame = leftMenuHiddenFrame
        leftMenu.hidden = true
        self.view.addSubview(leftMenu)
        
        touchView = UIView(frame: CGRectMake(80, 70, ScreenWidth, ScreenHeight - 70))
        var recongnizerRight = UISwipeGestureRecognizer(target: self, action: "handleSwipeFrom:")
        self.view.addGestureRecognizer(recongnizerRight)
        var tapGesture = UITapGestureRecognizer(target: self, action: "viewTapListener:")
        var recongnizerLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipeClose:")
        recongnizerLeft.direction = UISwipeGestureRecognizerDirection.Left
        touchView.addGestureRecognizer(tapGesture)
        touchView.addGestureRecognizer(recongnizerLeft)
        
        self.view.addSubview(touchView)
        touchView.userInteractionEnabled = false
        
        setCtrlViewFrame()
        setBtnArray()
        historyKeyTable.hidden = true
        self.view.addSubview(historyKeyTable)
    }

    override func getXibName() -> String {
        return "ExplorationViewController"
    }
    
    func setBtnArray(){
        
        menuBtnArray.append(zuijinBtn)
        menuBtnArray.append(recOverBtn)
        menuBtnArray.append(trashBtn)
        
        menuBtnArray[0].backgroundColor = Color.color_violet
    }
    
    //设置历史搜索记录的tableview
    func setHistoryKeyTable(){
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        let keysCount = Int(historyKeys.size())
        let height = keysCount * 30 > 150 ? 150 : keysCount * 30
        historyKeyFrame = CGRectMake(0 , explorationViewY - titleLabel.frame.size.height, ScreenWidth ,CGFloat(height))
        historyKeyTable.frame = historyKeyFrame
        historyKeyTable.reloadData()
    }
    
    //添加控制菜单
    func setCtrlViewFrame(){
        ctrlViewShowFrame = CGRectMake(0, ScreenHeight - 70, ScreenWidth, 70)
        ctrlViewHiddenFrame = CGRectMake(0, ScreenHeight, ScreenWidth, 70)
        ctrlView.frame = ctrlViewHiddenFrame
        waitRecCtrlView.frame = ctrlViewHiddenFrame
        trashCtrlView.frame = ctrlViewHiddenFrame
        self.view.addSubview(ctrlView)
        self.view.addSubview(trashCtrlView)
    }
    
    func handleSwipeFrom(recongizer:UISwipeGestureRecognizer){
        if recongizer.direction == UISwipeGestureRecognizerDirection.Right {
            if !isCtrlViewShow {
                showLeftMenu()
            }
        }
    }
    
    func handleSwipeClose(recongizer:UISwipeGestureRecognizer){
        if recongizer.direction == UISwipeGestureRecognizerDirection.Left {
            showLeftMenu()
        }
    }
    
    func viewTapListener(gesture:UITapGestureRecognizer){
        if isLeftMenuShow {
            showLeftMenu()
        }
    }
    
    func showOrHiddenCtrlView(){
        
        if isCtrlViewShow {
            isCtrlViewShow = false
            setRightBtnTittle("编辑")
            self.setCtrlViewFrame(self.isCtrlViewShow)
            var view = pageViews[showViewPosition]
            if showViewPosition == 0 {
                (view as! ExplorationView).cleanAllSelectedStatus()
            }else{
                (view as! ExplorationRecView).cleanAllSelectedStatus()
            }
        }else{
            isCtrlViewShow = true
            setRightBtnTittle("完成")
            self.setCtrlViewFrame(self.isCtrlViewShow)
            
        }
        
    }
    
    func ctrlViewAnimate(isShow:Bool, contentView:UIView,ctrlView:UIView){
        if isShow {
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                
                ctrlView.frame = self.ctrlViewShowFrame
                }, completion: { (isFinish) -> Void in
                    contentView.frame = self.contentShowCtrlFrame
            })
            
        }else{
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                contentView.frame = self.contentFrame
                ctrlView.frame = self.ctrlViewHiddenFrame
                }, completion: { (isFinish) -> Void in
                    
            })
        }
    }
    
    /**设置底部控制菜单弹出和消失时内容区域的位置*/
    func setCtrlViewFrame(isShow:Bool){
        
        var view = pageViews[showViewPosition]
        
        if showViewPosition == 0 {
            (view as! ExplorationView ).isEditStatus = isShow
            (view as! ExplorationView ).timeTableView.reloadData()
            ctrlViewAnimate(isShow, contentView: view, ctrlView: ctrlView)
        }else if showViewPosition == 1 {
            (view as! ExplorationRecView ).isEditStatus = isShow
            (view as! ExplorationRecView ).timeTableView.reloadData()
            ctrlViewAnimate(isShow, contentView: view, ctrlView: ctrlView)
        }else if showViewPosition == 2 {
            (view as! ExplorationRecView ).isEditStatus = isShow
            (view as! ExplorationRecView ).timeTableView.reloadData()
            ctrlViewAnimate(isShow, contentView: view, ctrlView: trashCtrlView)
        }
    }
    
    /**左侧菜单出现或者隐藏*/
    func showLeftMenu(){
        
        if leftMenu.hidden {
            leftMenu.hidden = false
        }
        
        if isLeftMenuShow {
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.leftMenu.frame = self.leftMenuHiddenFrame
            }, completion: { (isFinish) -> Void in
                self.isLeftMenuShow = false
                self.touchView.userInteractionEnabled = false
            })
            
        }else{
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.leftMenu.frame = self.leftMenuShowFrame
                }, completion: { (isFinish) -> Void in
                    self.touchView.userInteractionEnabled = true
                    self.isLeftMenuShow = true
            })
            
        }
    }
    
    
    /**顶部右侧按钮点击事件*/
    override func onRightBtnOnClick(sender: UIButton) {
        
        if isLeftMenuShow {
            showLeftMenu()
        }
        if isExperience {
            MessageTools.experienceDialog(self.navigationController!)
            return
        }
        showOrHiddenCtrlView()
        if showViewPosition == 0 {
            explorationView.reloadTable()
        }else if showViewPosition == 1 {
            recOverView.reloadTable()
        }else if showViewPosition == 2 {
            trashView.reloadTable()
        }
    }
    
    /**顶部左侧按钮点击事件*/
    override func onLeftBtnOnClick(sender: UIButton) {
        leftMenu.hidden = true
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var controller = SearchViewController()
        controller.searchKey = searchBar.text
        println("\(searchBar.text)")
        self.navigationController?.pushViewController(controller, animated: true)
        searchBar.resignFirstResponder()
    }
    
    /**左侧菜单按钮点击事件*/
    @IBAction func leftmenuBtnClick(sender: AnyObject) {
        
        var btn = sender as! UIButton
        showViewPosition = btn.tag
        
        for (index,item) in enumerate(menuBtnArray){
            if index == showViewPosition {
                item.backgroundColor = Color.color_violet
            }else{
                item.backgroundColor = UIColor.clearColor()
            }
        }
        
        titleLabel.text = titleLabels[showViewPosition]
        
        for (position,item) in enumerate(pageViews) {
            if position == btn.tag {
                if item.hidden {
                    item.hidden = false
                }
            }else{
                item.hidden = true
            }
        }
        if showViewPosition == 0 {
            explorationView.cleanDatas()
            explorationView.setDatas(false)
        }else if showViewPosition == 1 {
            recOverView.cleanDatas()
            recOverView.getRecRecordLogic(ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_ALL,isTrash: false)
        }else if showViewPosition == 2 {
            trashView.cleanDatas()
            trashView.getRecRecordLogic(ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_END,isTrash: true)
        }
    }
    
    /**分享数据（最近查看列表或者云识别完成列表，根据当前选中的viewpa判断）*/
    @IBAction func sharePatientsClick() {
        if showViewPosition == 0 {
            explorationView.shareDatas()
        }else if showViewPosition == 1 {
            recOverView.shareDatas()
        }
    }
    
    /**删除数据（最近查看列表或者云识别完成列表，根据当前选中的viewpa判断）*/
    @IBAction func delPatientsClick(sender: AnyObject) {
        if showViewPosition == 0 {
            explorationView.delDatas()
        }else if showViewPosition == 1 {
            recOverView.delDatas()
        }
    }
    
    /**批量恢复垃圾箱中的记录*/
    @IBAction func huifuTrashClick() {
        trashView.huifuDatas()
    }
    
    /**批量删除垃圾箱中的记录*/
    @IBAction func delTrashClick() {
        trashView.delDatas()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.textLabel!.text = historyKeys.getWithInt(Int32(indexPath.row)) as? String
        cell.textLabel!.font = UIFont.systemFontOfSize(12.0)
        cell.textLabel!.textColor = UIColor.lightGrayColor()
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(historyKeys.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        setHistoryKeyTable()
        historyKeyTable.hidden = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        historyKeyTable.hidden = true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        historyKeyTable.hidden = true
        var controller = SearchViewController()
        searchView.text = historyKeys.getWithInt(Int32(indexPath.row)) as! String
        controller.searchKey = searchView.text
        self.navigationController?.pushViewController(controller, animated: true)
        searchView.resignFirstResponder()
    }
}
