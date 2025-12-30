//
//  TalkTopViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/06/05.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class TalkTopViewCell: UITableViewCell {

    @IBOutlet weak var talkImageView: EnhancedCircleImageView!
    
    
    @IBOutlet weak var messageLbl: UILabel!
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
        //yenSSSLbl.sizeToFit()
        
        messageLbl.textColor = UIColor.gray
        
        //self.messageLbl.frame.origin = CGPoint(x: 77, y: 30)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

/*
extension TalkTopViewCell {
    func updateCell(text: String, time: String) {
        self.textView?.text = text
        self.nameLabel?.text = time
        
        //let frame = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let frame = CGSize(width: self.frame.width + 8, height: CGFloat.greatestFiniteMagnitude)
        var rect = self.textView.sizeThatFits(frame)
        if(rect.width<30){
            rect.width=30
        }
        textViewWidthConstraint.constant = rect.width//テキストが短くても最小のビューの幅を30とする
    }
}
*/
