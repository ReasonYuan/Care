//
//  ReportViewController.swift
//  Care
//
//  Created by reason on 15/8/24.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

//import Foundation
import UIKit

class ReportDocumentViewController: BaseViewController ,UIWebViewDelegate{

    
    var reportBridge:ReportDocBridge?
    
    
    var medicalItem : ComFqHalcyonEntityCareMedicalItem!
    
    var imagesView : FullScreenImageZoomView!
    
    
    override func getXibName() -> String {
        return "ReportDocumentViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var readColor = Tools.colorWithHexString("#f56f6c")
        leftText.textColor = readColor
        leftBtn.setImage( Tools.image(UIImage(named: "icon_topleft.png") , withTintColor: readColor), forState: UIControlState.Normal)
        self.setRightImage(isHiddenBtn: false, image: UIImage(named:"icon_src_img.png")!)
        self.setTittle(medicalItem.getTypeName())
        topTittle.textColor = readColor
        
        
        var web :UIWebView = UIWebView()
        web.backgroundColor = UIColor.clearColor()
        web.opaque = false
        web.frame = self.view.frame
        BaseViewController.addChildViewFullInParent(web, parent: self.containerView)
        
        reportBridge = ReportDocBridge()
        reportBridge?.bridgeForWebView(web, webViewDelegate: self)
        reportBridge?.initData(self, mediacal: medicalItem!)
        
        web.scalesPageToFit = true;
        
        var res = NSBundle.mainBundle().pathForResource("report_document",ofType: "html")
        web.loadRequest(NSURLRequest(URL: NSURL(string:res!)!))
        
        
        if medicalItem.getPhotos().size() <= 0{
            hiddenRightImage(true)
        }
    }
    
    /**打开原图*/
    override func onRightBtnOnClick(sender: UIButton) {
        if medicalItem?.getPhotos().size() == 0 {
            self.view.makeToast("没有原图")
            return
        }
        
        imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        self.view.addSubview(imagesView)
        
        
        var photoRecords = [ComFqHalcyonEntityPhotoRecord]()
        for var i:Int32 = 0 ; i < medicalItem?.getPhotos()!.size() ; i++ {
            var photoRecord:ComFqHalcyonEntityPhotoRecord = medicalItem!.getPhotos().getWithInt(i) as! ComFqHalcyonEntityPhotoRecord
            photoRecord.setStateWithInt(ComFqHalcyonEntityPhotoRecord_REC_STATE_SUCC)
            photoRecords.append(photoRecord)
        }
        
        imagesView.setDatas(0, pagePhotoRecords: photoRecords)
        imagesView.showOrHiddenView(true)
    }
}
