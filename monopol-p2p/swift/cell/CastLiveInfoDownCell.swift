//
//  CastLiveInfoDownCell.swift
//  swift_skyway
//
//  Created by onda on 2018/08/02.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class CastLiveInfoDownCell: UITableViewCell {

    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var userImageView: EnhancedCircleImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    //@IBOutlet weak var timeInfoLbl: UILabel!
    
    //獲得スターのセル
    @IBOutlet weak var rightTypeLbl: UILabel!
    @IBOutlet weak var starLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        //ラベルの枠を自動調節する
        typeLbl.adjustsFontSizeToFitWidth = true
        typeLbl.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        //timeInfoLbl.adjustsFontSizeToFitWidth = true
        //timeInfoLbl.minimumScaleFactor = 0.3
        
        // 角丸
        typeLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        typeLbl.layer.masksToBounds = true
        
        // 角丸
        //timeInfoLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //timeInfoLbl.layer.masksToBounds = true

        //ラベルの枠を自動調節する
        self.rightTypeLbl.adjustsFontSizeToFitWidth = true
        self.rightTypeLbl.minimumScaleFactor = 0.3
        // 角丸
        self.rightTypeLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.rightTypeLbl.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
