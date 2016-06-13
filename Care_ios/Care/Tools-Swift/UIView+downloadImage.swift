//
//  s.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


extension UIView  {
    
    func downLoadImageWidthImageId(imageId:Int32!,callback:(view:UIView!,path:NSString!)->Void){
         var photo:ComFqHalcyonEntityPhoto = ComFqHalcyonEntityPhoto(int:imageId,withNSString: "")
        ApiSystem.getImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (obj) -> Void in
             var imagePath:NSString? = obj as? NSString
            callback(view: self, path: imagePath)
        }))
    }
    
    
}