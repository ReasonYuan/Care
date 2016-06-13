//
//  LoadingView.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/8.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    var imageView: UIImageView!
    var msgLabel:UILabel!
    var image1:UIImage!
    var image2:UIImage!
    var image3:UIImage!
    var image4:UIImage!
    init(frame: CGRect,msg:NSString) {
        super.init(frame: frame)
//        image1 = UIImage(named: "loading_bottom_left.png")
//        image2 = UIImage(named: "loading_top_left.png")
//        image3 = UIImage(named: "loading_top_right.png")
//        image4 = UIImage(named: "loading_bottom_right.png")
//        imageView = UIImageView(frame: CGRectMake(frame.size.width/2-20 , frame.size.height/2-20, 40 , 40))
        msgLabel = UILabel(frame: CGRectMake(0 , frame.size.height/2+20, frame.size.width , 40))
        msgLabel.text = msg as String
        msgLabel.textAlignment = NSTextAlignment.Center
        msgLabel.textColor = UIColor.whiteColor()
//        imageView.animationImages = [image1,image2,image3,image4]
//        imageView.animationDuration = 1
//        imageView.startAnimating()
//        self.addSubview(imageView)
        
        var loading = PracticeLoadingView(frame: CGRectMake(0 , 0, frame.size.width , frame.size.height-40));
        self.addSubview(loading)
        
        self.addSubview(msgLabel)
        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
}
