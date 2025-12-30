//
//  CastLiveInfoDownGetCell.swift
//  swift_skyway
//
//  Created by onda on 2018/08/03.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class CastLiveInfoDownGetCell: UITableViewCell {

    //獲得スターのセル(未使用)
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var starLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //ラベルの枠を自動調節する
        typeLbl.adjustsFontSizeToFitWidth = true
        typeLbl.minimumScaleFactor = 0.3
        
        // 角丸
        typeLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        typeLbl.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
