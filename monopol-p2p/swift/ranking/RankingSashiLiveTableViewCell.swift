//
//  RankingSashiLiveTableViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/07/10.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class RankingSashiLiveTableViewCell: UITableViewCell {

    //ランキング4位のところ
    @IBOutlet weak var rankingLbl: UILabel!
    //ランキングポイント
    @IBOutlet weak var rankingPointLbl: UILabel!
    //配信ポイント
    @IBOutlet weak var livePointLbl: UILabel!
    //画像のところ
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var castNameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var castInfoBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 角丸
        rankingLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankingLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        rankingLbl.adjustsFontSizeToFitWidth = true
        rankingLbl.minimumScaleFactor = 0.3
        rankingLbl.textColor = Util.SASHI_RANKING_LABEL_COLOR
        
        // 角丸
        rankingPointLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankingPointLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        rankingPointLbl.adjustsFontSizeToFitWidth = true
        rankingPointLbl.minimumScaleFactor = 0.3
        
        // 角丸
        livePointLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        livePointLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        livePointLbl.adjustsFontSizeToFitWidth = true
        livePointLbl.minimumScaleFactor = 0.3
        //背景色変更
        livePointLbl.backgroundColor = Util.COMMON_BLUE_COLOR
        
        // 枠線の色
        followBtn.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        followBtn.layer.borderWidth = 1
        // 角丸
        followBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        followBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        followBtn.titleLabel?.minimumScaleFactor = 0.3
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
