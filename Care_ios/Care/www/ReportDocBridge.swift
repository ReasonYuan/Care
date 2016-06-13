//
//  ReportDocBridge.swift
//  Care
//
//  Created by reason on 15/8/27.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation

class ReportDocBridge:WebViewJsBridge ,ComFqHalcyonUilogicReportDocumentUILogic_ReportDocumentUICallBack{
    
    var uiLogic : ComFqHalcyonUilogicReportDocumentUILogic!
    
    var isLoaded : Bool! = false
    
    weak var viewController : ReportDocumentViewController!
    
    func initData(controller : ReportDocumentViewController,mediacal : ComFqHalcyonEntityCareMedicalItem){
        viewController = controller
        uiLogic = ComFqHalcyonUilogicReportDocumentUILogic(comFqHalcyonEntityCareMedicalItem: mediacal, withComFqHalcyonUilogicReportDocumentUILogic_ReportDocumentUICallBack: self)
    }
    
    override func webViewDidFinishLoad(webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
        if !isLoaded{
            isLoaded = true
            self.uiLogic.loadRecordItem()
        }
    }
    
    /**用数据填充界面*/
    func fillWeb(){
        var head = uiLogic.getChartHead()
        webView.stringByEvaluatingJavaScriptFromString("fillChartHead(\(head))")

        var body = uiLogic.getChartBody()
        webView.stringByEvaluatingJavaScriptFromString("fillChartBody(\(body))")
        
        var doc = uiLogic.getDocument()
        webView.stringByEvaluatingJavaScriptFromString("fillDocument(\(doc))")
    }
    
    func log(msg:String) -> String{
        println("~~~~~:\(msg)")
        return "dsb"
    }
    
    /**获取数据结果的回调*/
    func loadRecordCallbackWithBoolean(isb: Bool) {
        if isb {
            fillWeb()
        }else{
            viewController!.view.makeToast("网络异常，获取数据失败")
        }
    }
    
}