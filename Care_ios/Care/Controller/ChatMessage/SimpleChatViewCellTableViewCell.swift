//
//  SimpleChatViewCellTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SimpleChatViewCellTableViewCell: UITableViewCell {

    @IBOutlet weak var head: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var headBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
