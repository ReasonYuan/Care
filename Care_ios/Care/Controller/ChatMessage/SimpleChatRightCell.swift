//
//  SimpleChatRightCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SimpleChatRightCell: UITableViewCell {

    @IBOutlet weak var head: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var sendTimerLabel: UILabel!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var sendFailBtn:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
    }
    
}
