//
//  TalkTopPhotoCell.swift
//  swift_skyway
//
//  Created by onda on 2018/07/02.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class TalkTopPhotoCell: UITableViewCell {

    @IBOutlet weak var talkImageView: EnhancedCircleImageView!
    
    @IBOutlet weak var photoView: UIImageView!
    //@IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    //@IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //ラベルの枠を自動調節する
        self.dateLbl.adjustsFontSizeToFitWidth = true
        self.dateLbl.minimumScaleFactor = 0.3
        
        //self.nameLabel.adjustsFontSizeToFitWidth = true
        //self.nameLabel.minimumScaleFactor = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
