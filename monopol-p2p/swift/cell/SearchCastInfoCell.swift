//
//  SearchCastInfoCell.swift
//  swift_skyway
//
//  Created by onda on 2018/09/20.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class SearchCastInfoCell: UITableViewCell {

    @IBOutlet weak var castImageView: EnhancedCircleImageView!
    @IBOutlet weak var castNameLbl: UILabel!
    @IBOutlet weak var castFreetextLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var castInfoBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //ラベルの枠を自動調節する
        //presentCoinLabel.adjustsFontSizeToFitWidth = true
        //presentCoinLabel.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        //presentNumLabel.adjustsFontSizeToFitWidth = true
        //presentNumLabel.minimumScaleFactor = 0.3
        
        // 枠線の色
        self.followBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.followBtn.layer.borderWidth = 1
        // 角丸
        self.followBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.followBtn.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
