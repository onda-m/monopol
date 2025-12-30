//
//  RankingFanTableViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/07/10.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class RankingFanTableViewCell: UITableViewCell {

    @IBOutlet weak var rankingPointLbl: AutoShrinkLabel!
    @IBOutlet weak var rankingLbl: AutoShrinkLabel!
    //画像のところ
    @IBOutlet weak var userImageView: EnhancedCircleImageView!
    @IBOutlet weak var castImageView: EnhancedCircleImageView!
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var castNameLbl: UILabel!
    
    @IBOutlet weak var userInfoBtn: UIButton!
    @IBOutlet weak var castInfoBtn: UIButton!
    
    //絆レベルのところ
    @IBOutlet weak var connectLevelLbl: AutoShrinkLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //userImageView.layer.borderColor = UIColor.lightGray.cgColor
        //userImageView.layer.borderWidth = 1
        
        //castImageView.layer.borderColor = UIColor.lightGray.cgColor
        //castImageView.layer.borderWidth = 1
        
        //ラベルの枠を自動調節する
        rankingLbl.adjustsFontSizeToFitWidth = true
        rankingLbl.minimumScaleFactor = 0.3
        rankingLbl.textColor = Util.FAN_RANKING_LABEL_COLOR
        
        // 角丸
        rankingPointLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankingPointLbl.layer.masksToBounds = true
        rankingPointLbl.backgroundColor = Util.FAN_RANKING_BG_COLOR_04
        //ラベルの枠を自動調節する
        rankingPointLbl.adjustsFontSizeToFitWidth = true
        rankingPointLbl.minimumScaleFactor = 0.3
        
        // 角丸
        connectLevelLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        connectLevelLbl.layer.masksToBounds = true
        connectLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
        //ラベルの枠を自動調節する
        connectLevelLbl.adjustsFontSizeToFitWidth = true
        connectLevelLbl.minimumScaleFactor = 0.3
        
        /*
        // 角丸
        testCell.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        testCell.layer.masksToBounds = true
        // 枠線の色
        //testCell.layer.borderColor = UIColor.lightGray.cgColor
        testCell.layer.borderColor = Util.SUKOSHIUSUI_GRAY_COLOR.cgColor
        // 枠線の太さ
        testCell.layer.borderWidth = 1
         */
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
