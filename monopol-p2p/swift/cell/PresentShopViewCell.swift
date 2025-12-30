//
//  PresentShopViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/09/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class PresentShopViewCell: UITableViewCell {

    @IBOutlet weak var presentBtn: UIButton!//購入するボタン(見えない)
    @IBOutlet weak var presentImageView: UIImageView!
    @IBOutlet weak var presentNameLabel:UILabel!
    @IBOutlet weak var presentCoinLabel:UILabel!//必要なコイン数
    @IBOutlet weak var presentNumLabel:UILabel!//所持数
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //ラベルの枠を自動調節する
        //presentCoinLabel.adjustsFontSizeToFitWidth = true
        //presentCoinLabel.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        presentNumLabel.adjustsFontSizeToFitWidth = true
        presentNumLabel.minimumScaleFactor = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
