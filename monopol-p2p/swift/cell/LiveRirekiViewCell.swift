//
//  LiveRirekiViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/10/14.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class LiveRirekiViewCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var listenerImageView: UIImageView!
    @IBOutlet weak var listenerNameLbl: UILabel!
    @IBOutlet weak var listenerImageBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //ラベルの枠を自動調節する
        listenerNameLbl.adjustsFontSizeToFitWidth = true
        listenerNameLbl.minimumScaleFactor = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
