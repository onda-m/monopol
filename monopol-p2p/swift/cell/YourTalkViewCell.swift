//
//  YourTalkViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/06/11.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class YourTalkViewCell: UITableViewCell {

    @IBOutlet weak var yourImageView: EnhancedCircleImageView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.textView.layer.cornerRadius = 10// 角を丸める
        //self.textView.layer.cornerRadius = 15// 角を丸める
        //self.addSubview(YourBalloonView(frame: CGRect(x: textView.frame.minX-10, y: textView.frame.minY-10, width: 50, height: 50)))//吹き出しのようにするためにビューを重ねる
        
        // 枠線の色
        //self.textView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.textView.layer.borderWidth = 0
        self.textView.backgroundColor = Util.TALK_YOUR_BG_COLOR
        
        //paddingの指定(top,left,bottom,right)
        self.textView.textContainerInset = UIEdgeInsets(top: 7, left: 7, bottom: 8, right: 6)
        
        //ラベルの枠を自動調節する
        self.timeLabel.adjustsFontSizeToFitWidth = true
        self.timeLabel.minimumScaleFactor = 0.3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

extension YourTalkViewCell {
    func updateCell(text: String, time: String, yourimage: UIImage) {
        self.textView?.text = text
        self.timeLabel?.text = time
        self.yourImageView.image = yourimage

        let frame = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        var rect = self.textView.sizeThatFits(frame)
        if(rect.width<30){
            rect.width=30
        }
        textViewWidthConstraint.constant = rect.width//テキストが短くても最小のビューの幅を30とする
    }
}
