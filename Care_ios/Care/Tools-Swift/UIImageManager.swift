//
//  UIImageManager.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation
import UIKit
class UIImageManager {
    
    /**保存图片到本地**/
    class func saveImageToLocal(image:UIImage,path:String,imageName name:String) -> Bool{
        var fileManager = NSFileManager.defaultManager()
        fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        var filePath = path + name
        var  successful = fileManager.createFileAtPath(filePath, contents:UIImageJPEGRepresentation(image,1) , attributes: nil)
        if successful {
            if Debug {
                println("------------------------------------------------")
                println("保存本地图片成功\n\(filePath)")
                println("------------------------------------------------")
            }
           return successful
        }
        return false
    }
    
    /**从本地获取图片**/
    class func getImageFromLocal(path:String,imageName name:String) -> UIImage? {
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
            var imageData = NSData.dataWithContentsOfMappedFile(imagePath) as! NSData
            var image = UIImage(data: imageData)
            if Debug {
                println("------------------------------------------------")
                println("获取本地图片成功\(image!)")
                println("------------------------------------------------")
            }
           
            return image
        }
        return nil
    }
}