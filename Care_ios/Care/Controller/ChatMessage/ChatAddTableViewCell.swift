//
//  ChatAddTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChatAddTableViewCell: UITableViewCell {
    
    @IBOutlet weak var inviteMessage: UILabel!
    @IBOutlet weak var head: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var hospital: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var sendFailBtn:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
