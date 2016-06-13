//
//  ChatAnalysisRightTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChatAnalysisRightTableViewCell: UITableViewCell {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var userHead: UIImageView!
    @IBOutlet weak var recordCount: UILabel!
    @IBOutlet weak var patientDetail: UILabel!
    @IBOutlet weak var patientDetail2: UILabel!
    @IBOutlet weak var patientDetail3: UILabel!
    @IBOutlet weak var recordUserId: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var sendFailBtn:UIButton!
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
