//
//  SelectPatientTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol SelectPatientTableViewCellDelegate:NSObjectProtocol
{
    func onCheckboxClick(cell:SelectPatientTableViewCell)
}

class SelectPatientTableViewCell: UITableViewCell {

    @IBOutlet weak var iconBtn: UIImageView!


    weak var delegate:SelectPatientTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func onCheckBoxChick(sender: AnyObject) {
        if(delegate != nil) {
           delegate?.onCheckboxClick(self)
        }
    }
}
