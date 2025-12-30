//
//  LiveChatViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/05/22.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class LiveChatViewCell: UITableViewCell {

    @IBOutlet weak var liveChatImageView: EnhancedCircleImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        //self.backgroundColor = UIColor.clear
        //self.textView.layer.cornerRadius = 10// 角を丸める
        //self.addSubview(YourBalloonView(frame: CGRect(x: textView.frame.minX-10, y: textView.frame.minY-10, width: 50, height: 50)))//吹き出しのようにするためにビューを重ねる
        
        // MARK: ↓これが足りなかった
        //self.contentView.autoresizingMask = autoresizingMask
        // MARK: ↑これが足りなかった
        
        // 角丸
        self.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.layer.masksToBounds = true
        
        // backgroundColorを使って透過させる。
        self.layer.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //自分自身はサワレナイ(下記を透過したいVIewに記述)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self {
            return nil
        }
        return view
    }
}

/*
extension LiveChatViewCell {
    func updateCell(text: String, name: String) {
        self.textView?.text = text
        self.nameLabel?.text = name
        
        //ラベルの枠を自動調節する
        self.nameLabel?.adjustsFontSizeToFitWidth = true
        self.nameLabel?.minimumScaleFactor = 0.3
        
        
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
