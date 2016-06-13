//
//  UITools.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-29.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation
import UIKit
var db:FMDatabase!
class UITools : NSObject {
    
    /**
    设置btn的颜色，两种不同的点击状态
    isOpposite 表示按钮两种状态是否是相反的  （false 表示默认normal是填充满的 按下是空的）（true 表示默认normal是空的 按下是填充满的）
    
    **/
    class func setButtonWithColor(colorType:ColorType,btn:UIButton,isOpposite yes:Bool) {
        switch colorType {
        case .EMERALD:
            btn.titleLabel?.font = UIFont.systemFontOfSize(23)
            if !yes {
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Highlighted)
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                //                Tools.createNinePathImageForImage(UIImage(named: "btn_gray_pressed.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5)
                btn.setBackgroundImage( Tools.createNinePathImageForImage(UIImage(named: "btn_green_normal.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Normal)
                btn.setBackgroundImage(Tools.createNinePathImageForImage(UIImage(named: "btn_gray_pressed.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Highlighted)
            }else {
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Normal)
                btn.setBackgroundImage(Tools.createNinePathImageForImage(UIImage(named: "btn_gray_pressed.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Normal)
                btn.setBackgroundImage(Tools.createNinePathImageForImage(UIImage(named: "btn_green_normal.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Highlighted)
            }
            
        default:
            return
        }
    }
    
    /**
    设置btn的颜色，两种不同的点击状态  btn的背景色为医加绿
    isOpposite 表示按钮两种状态是否是相反的  （false 表示默认normal是填充满的 按下是空的）（true 表示默认normal是空的 按下是填充满的）
    
    **/
    class func setButtonWithBackGroundColor(colorType:ColorType,btn:UIButton,isOpposite yes:Bool) {
        switch colorType {
        case .EMERALD:
            btn.titleLabel?.font = UIFont.systemFontOfSize(23)
            if !yes {
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Highlighted)
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(Color.color_emerald), forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Highlighted)
                btn.layer.borderWidth = 1.0
                btn.layer.borderColor = Color.color_emerald.CGColor
            }else {
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(Color.color_emerald), forState: UIControlState.Highlighted)
            }
            
        default:
            return
        }
    }
    
    /**
    设置Button的样式
    btn:要设置的UIButton;
    buttonColor:Button的颜色;
    textSize:Button的文字大小;
    textColor:Button的文字颜色;
    isOpposite:表示按钮两种状态是否是相反的  （false 表示默认normal是填充满的 按下是空的）（true 表示默认normal是空的 按下是填充满的）如果不传入该参数，则默认是填充的
    radius:设置Button的圆角（如果不传入该参数，则默认是直角）
    */
    class func setButtonStyle(btn:UIButton,buttonColor:UIColor,textSize:CGFloat,textColor:UIColor,isOpposite:Bool = false, radius:CGFloat = 0){
        btn.titleLabel?.font = UIFont.systemFontOfSize(textSize)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = radius
        if !isOpposite {
            /**常态是只有边框的，点击有填充色*/
            btn.setTitleColor(textColor, forState: UIControlState.Highlighted)
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(buttonColor), forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Highlighted)
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = buttonColor.CGColor
        } else {
            /**常态是有填充色的，点击只有边框*/
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
            btn.setTitleColor(textColor, forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(buttonColor), forState: UIControlState.Highlighted)
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = buttonColor.CGColor
        }
    }
    
    /**为view设置圆角**/
    class func setRoundBounds(radius:CGFloat,view:UIView) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    /**根据url生成相应的二维码**/
    class func createQrCode(url:String,imageview:UIImageView) -> UIImage{
        return QRCodeGenerator.qrImageForString(url, imageSize: imageview.bounds.size.width)
    }
    
    /**为UIVIew设置某个颜色的边框**/
    class func setBorderWithView(width:CGFloat,tmpColor:CGColorRef,view:UIView){
        view.layer.borderColor = tmpColor
        view.layer.borderWidth = width
        view.layer.backgroundColor = UIColor(red:220/255.0,green:220/255.0,blue:220/255.0,alpha:1).CGColor
    }
    
    class func setBtnWithOneRound(btn:UIButton,corners: UIRectCorner){
        var maskPath = UIBezierPath(roundedRect: btn.bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(9, 9))
        var maskLayer = CAShapeLayer()
        maskLayer.frame = btn.bounds
        maskLayer.path = maskPath.CGPath
        btn.layer.mask = maskLayer
    }
    
    /**
    设置按钮选中和未选中的样式
    btn:按钮
    selectedColor:选中的显示颜色
    unSelectedColor:未选中的颜色
    */
    class func setSelectBtnStyle(btn:UIButton,selectedColor:UIColor,unSelectedColor:UIColor){
        /**常态是只有边框的，选中时有填充色*/
        btn.setTitleColor(unSelectedColor, forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(selectedColor), forState: UIControlState.Selected)
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = unSelectedColor.CGColor
    }
    
    /**
    设置按钮选中、未选中、不可点的样式
    btn:按钮
    selectedColor:选中的显示颜色
    unSelectedColor:未选中的颜色
    disabledColor:不可点时颜色
    */
    class func setBtnBackgroundColor(btn:UIButton,selectedColor:UIColor,unSelectedColor:UIColor,disabledColor:UIColor){
        /**常态是只有边框的，选中时有填充色*/
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
//        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btn.setBackgroundImage(UITools.imageWithColor(unSelectedColor), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(selectedColor), forState: UIControlState.Selected)
        btn.setBackgroundImage(UITools.imageWithColor(selectedColor), forState: UIControlState.Highlighted)
        btn.setBackgroundImage(UITools.imageWithColor(disabledColor), forState: UIControlState.Disabled)
//        btn.layer.borderWidth = 1.0
//        btn.layer.borderColor = unSelectedColor.CGColor
    }
    
    /**
    为UIVIew设置某个颜色的边框
    width:边框宽度
    borderColor:边框颜色
    backgroundColor:背景填充色
    view:需要设置边框的view
    **/
    class func setViewBorder(width:CGFloat,borderColor:UIColor,backgroundColor:UIColor,view:UIView){
        view.layer.borderColor = borderColor.CGColor
        view.layer.borderWidth = width
        view.layer.backgroundColor = backgroundColor.CGColor
    }
    
    /**设置头像背景为灰框淡红色的View**/
    class func setBorderWithHeadKuang(headKuang:UIView){
        headKuang.layer.masksToBounds = true
        var headKuangrect:CGRect? = headKuang.bounds
        headKuang.layer.cornerRadius = CGRectGetHeight(headKuangrect!)/2
        headKuang.layer.borderWidth = 1.0
        headKuang.layer.borderColor = UIColor.lightGrayColor().CGColor
        headKuang.backgroundColor = UIColor(red: 253/255, green: 237/255, blue: 240/255, alpha: 1.0)
    }
    
    class func getImageFromFile(filePath:NSString) -> UIImage?{
        var cache = Tools.getObjectForKey(filePath)
        if(cache != nil && cache.isKindOfClass(UIImage)){
            return cache as? UIImage
        }
        var fileData:NSData? = NSData(contentsOfFile:filePath as String)
        if fileData != nil {
            var image =  UIImage(data: fileData!)
            Tools.cacheObject(image, forKey: filePath)
            return image
        }
        return nil
    }
    
    class func getImageFromFile(filePath:NSString,callback:(image:UIImage?)->Void){
        Tools.runOnOtherThread({ () -> AnyObject! in
            return UITools.getImageFromFile(filePath)
            }, callback: { (obj) -> Void in
                callback(image: obj as? UIImage)
        })
    }
    
    class func getThumbnailImageFromFile(filePath:NSString,width:CGFloat,cache:Bool = true,callback:(image:UIImage?)->Void){
        Tools.runOnOtherThread({ () -> AnyObject! in
            return UIImage.createThumbnailImageFromFile(filePath as String, maxWidth: width, useCache: cache)
            }, callback: { (obj) -> Void in
                callback(image: obj as? UIImage)
        })
    }
    
    class func imageWithColor(color:UIColor) -> UIImage {
        var rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context,color.CGColor)
        CGContextFillRect(context, rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**保存图片到本地**/
    class func saveFileToLocal(data:NSData,path:String,fileName name:String) -> Bool{
        var fileManager = NSFileManager.defaultManager()
        fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        var filePath = path + name
        var  successful = fileManager.createFileAtPath(filePath, contents:data , attributes: nil)
        if successful {
            if Debug {
                println("------------------------------------------------")
                println("保存文件成功\n\(filePath)")
                println("------------------------------------------------")
            }
            return successful
        }
        return false
    }
    
    /**从本地获取图片**/
    class func getFileFromLocal(path:String,fileName name:String) -> NSData? {
        var fileManager = NSFileManager.defaultManager()
        var isDir:ObjCBool = false
        var directory = path
        fileManager.fileExistsAtPath(path, isDirectory:&isDir)
        var dirExsisted = fileManager.fileExistsAtPath(path)
        if isDir && dirExsisted {
            var imagePath =  path + "/" + name
            var fileExsited = fileManager.fileExistsAtPath(imagePath)
            if !fileExsited {
                return nil
            }
            var data = NSData.dataWithContentsOfMappedFile(imagePath) as! NSData
            
            if Debug {
                println("------------------------------------------------")
                println("获取本地文件成功\(data)")
                println("------------------------------------------------")
            }
            
            return data
        }
        return nil
    }
    
    
    
}
enum ColorType {
    case EMERALD
    case GREEN
    case GRAY
    case BLUE
}

