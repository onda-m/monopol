//
//  WatchRirekiViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/10/29.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class WatchRirekiViewCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var castImageView: UIImageView!
    @IBOutlet weak var castNameLbl: UILabel!
    @IBOutlet weak var castImageBtn: UIButton!
    @IBOutlet weak var liveTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
