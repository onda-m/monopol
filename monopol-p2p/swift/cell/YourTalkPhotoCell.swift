//
//  YourTalkPhotoCell.swift
//  swift_skyway
//
//  Created by onda on 2018/07/01.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class YourTalkPhotoCell: UITableViewCell {

    @IBOutlet weak var talkImageView: UIImageView!
    
    @IBOutlet weak var yourImageView: EnhancedCircleImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    //@IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //ラベルの枠を自動調節する
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.3

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
