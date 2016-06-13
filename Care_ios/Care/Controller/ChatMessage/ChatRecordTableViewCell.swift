//
//  ChatRecordTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChatRecordTableViewCell: UITableViewCell {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var recordUserName: UILabel!
    @IBOutlet weak var recordType: UILabel!
    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var recordMessage: UILabel!
    @IBOutlet weak var userHead: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var sendTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
