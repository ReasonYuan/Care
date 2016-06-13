//
//  MeViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15-7-17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MeViewController: BaseViewController,ISSViewDelegate,ISSShareViewDelegate{

   // @IBOutlet weak var backgrdView: UIView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var QrCode: UIImageView!
    var url:String?
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var genderIcon: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //backgrdView.backgroundColor = UIColor(red: 24/255.0, green: 83/255.0, blue: 96/255.0, alpha: 1.0)
        setTittle("详细资料")
        hiddenRightImage(true)
        //hiddenLeftImage(true)
        url = "\(ComFqLibToolsUriConstants.getInvitationURL())?user_id=\(ComFqLibToolsConstants.getUser().getUserId())"
        var QrCodeImage = UITools.createQrCode(url!, imageview: QrCode)
        UITools.setRoundBounds(10, view: nameView)
        UITools.setBorderWithView(1.0, tmpColor: UIColor.grayColor().CGColor, view: headBtn)
        UITools.setRoundBounds(45.0, view: headBtn)
//        UITools.setRoundBounds(12.0, view: doctorName)
        QrCode.image = QrCodeImage

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserImagePath()
        var name = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserHeadName()
        var getSuccess = UIImageManager.getImageFromLocal(path, imageName: name)
        if(getSuccess != nil){
            headBtn.setBackgroundImage(getSuccess, forState: UIControlState.Normal)
        }else{
            headBtn.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                var  head = view as? UIButton
                head?.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
            })
            
        }
//        var gender = ComFqLibToolsConstants.getUser().getGenderStr() == "男" ? "1" : "2"
        doctorName.text = ComFqLibToolsConstants.getUser().getName()
        if (ComFqLibToolsConstants.getUser().getGenderStr() == "男")
        {
            genderIcon.image =  UIImage(named: "icon_man.png")
        }else {
            genderIcon.image = UIImage(named: "icon_female.png")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "MeViewController"
    }
    
    @IBAction func shareClick(sender: AnyObject) {
//        self.navigationController?.pushViewController(ShareViewController() , animated: true)
//    [ComFqLibToolsConstants.getShareTextWithInt(<#type: Int32#>)]
        var img = UIImage(named:"appIcon_80")
        let shareImg = ShareSDK.pngImageWithImage(img)
        var shareList = [ShareTypeWeixiSession,ShareTypeWeixiTimeline]
        var content = ShareSDK.content("HiTales Practice致力于整合医疗数据，提升医生临床和研究效率，为病人提供更好的治疗。",
            defaultContent: "默认分享内容，没内容时显示",
            image: shareImg ,
            title: "HiTales Practice--Data Driven Health",
            url: url,
            description: nil,
            mediaType: SSPublishContentMediaTypeNews)
        var mAuthOptions = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: self)
        ShareSDK.showShareActionSheet(nil, shareList: nil, content: content, statusBarTips: false, authOptions: mAuthOptions, shareOptions: nil) { (type, state, statusInfo, info, end) -> Void in
            if state.value == SSPublishContentStateSuccess.value {
                
            }else {
                println("分享失败！！！")
            }
        }
    }
    
    func shareView(sender: AnyObject) {
        
    }

    @IBAction func settingClick(sender: AnyObject) {
        self.navigationController?.pushViewController(SettingViewController() , animated: true)
    }

    @IBAction func myInfoClick(sender: AnyObject) {
        self.navigationController?.pushViewController(UserProfileViewController() , animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
