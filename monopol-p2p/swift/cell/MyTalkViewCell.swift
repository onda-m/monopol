//
//  MyTalkViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/06/11.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class MyTalkViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.textView.layer.cornerRadius = 10 // 角を丸める
        //self.textView.layer.cornerRadius = 15 // 角を丸める
        //addSubview(MyBalloonView(frame: CGRect(x: Int(frame.size.width+30), y: 0, width: 30, height: 30))) //吹き出しのようにするためにビューを重ねる
        
        // 枠線の色
        //self.textView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.textView.layer.borderWidth = 0
        self.textView.backgroundColor = Util.TALK_MY_BG_COLOR

        //paddingの指定(top,left,bottom,right)
        self.textView.textContainerInset = UIEdgeInsets(top: 7, left: 6, bottom: 2, right: 4)
        
        //ラベルの枠を自動調節する
        self.timeLabel.adjustsFontSizeToFitWidth = true
        self.timeLabel.minimumScaleFactor = 0.3
        
        //既読・未読は使用しない？
        self.readLabel.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension MyTalkViewCell {
    func updateCell(text: String, time: String, isRead: Bool) {
        self.textView?.text = text
        self.timeLabel?.text = time
        self.readLabel?.isHidden = !isRead
        
        let frame = CGSize(width: self.frame.width - 8, height: CGFloat.greatestFiniteMagnitude)
        var rect = self.textView.sizeThatFits(frame)
        if(rect.width<30){
            rect.width=30
        }
        textViewWidthConstraint.constant = rect.width//テキストが短くても最小のビューの幅を30とする
    }
}

