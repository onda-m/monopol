//
//  MypageMenuViewCellTableViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/06/03.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class MypageMenuViewCell: UITableViewCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var mypageMenuLbl: UILabel!
    @IBOutlet weak var mypageImageIcon: UIImageView!
    @IBOutlet weak var selectBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lineView.frame.size.height = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
