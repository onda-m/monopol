//
//  MyTalkPhotoCell.swift
//  swift_skyway
//
//  Created by onda on 2018/07/01.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class MyTalkPhotoCell: UITableViewCell {

    @IBOutlet weak var myTalkPhotoImageVIew: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    
    //@IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 角丸
        self.myTalkPhotoImageVIew.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.myTalkPhotoImageVIew.layer.masksToBounds = true
        
        // 枠線の色
        //self.myTalkPhotoImageVIew.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //self.myTalkPhotoImageVIew.layer.borderWidth = 1
        
        //ラベルの枠を自動調節する
        self.timeLabel.adjustsFontSizeToFitWidth = true
        self.timeLabel.minimumScaleFactor = 0.3
        
        //既読・未読は使用しない？
        self.readLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
