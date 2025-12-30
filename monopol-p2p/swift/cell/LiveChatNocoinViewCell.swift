//
//  LiveChatNocoinViewCell.swift
//  swift_skyway
//
//  Created by onda on 2019/11/05.
//  Copyright © 2019 worldtrip. All rights reserved.
//

import UIKit

class LiveChatNocoinViewCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var liveChatImageView: EnhancedCircleImageView!
    //@IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var coinBtn: UIButton!
    //@IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // 角丸
        self.mainView.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainView.layer.masksToBounds = true
        
        // 角丸
        self.coinBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.coinBtn.layer.masksToBounds = true
        
        //ラベルの枠を自動調節する
        self.subLabel.adjustsFontSizeToFitWidth = true
        self.subLabel.minimumScaleFactor = 0.3
        
        // 角丸
        self.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.layer.masksToBounds = true
        
        // backgroundColorを使って透過させる。
        //self.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5).cgColor
        
        //self.layer.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5).cgColor
        self.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
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
 extension LiveChatPhotoViewCell {
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
