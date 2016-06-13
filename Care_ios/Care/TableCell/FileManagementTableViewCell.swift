//
//  FileManagementTableViewCell.swift
//  Care
//
//  Created by niko on 15/8/24.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class FileManagementTableViewCell: UITableViewCell {

    @IBOutlet weak var relNameLabel: UILabel!
    @IBOutlet weak var relationship: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
