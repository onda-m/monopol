//
//  YourTalkNoreadViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/06/13.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class YourTalkNoreadViewCell: UITableViewCell {

    @IBOutlet weak var yourImageView: EnhancedCircleImageView!
    
    //このメッセージを開封するのところ
    @IBOutlet weak var messageOpenLbl: UILabel!
    @IBOutlet weak var useCoinLbl: UILabel!
    @IBOutlet weak var textStrView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    //コインがない場合のView
    @IBOutlet weak var noCoinView: UIView!
    @IBOutlet weak var warningLbl: UILabel!
    //コインを購入するのところ
    @IBOutlet weak var coinBuyLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.textStrView.layer.cornerRadius = 10// 角を丸める
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.textStrView.layer.masksToBounds = true
        //self.textView.layer.cornerRadius = 15// 角を丸める
        //self.addSubview(YourBalloonView(frame: CGRect(x: textView.frame.minX-10, y: textView.frame.minY-10, width: 50, height: 50)))//吹き出しのようにするためにビューを重ねる
        
        // 枠線の色
        //self.textStrView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.textStrView.layer.borderWidth = 0
        self.textStrView.backgroundColor = Util.TALK_YOUR_BG_COLOR
        
        self.noCoinView.layer.cornerRadius = 10// 角を丸める
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.noCoinView.layer.masksToBounds = true

        self.useCoinLbl.text = "消費コイン:" + String(Int(Util.READ_TALK_COIN))

        //ラベルの枠を自動調節する
        self.timeLabel.adjustsFontSizeToFitWidth = true
        self.timeLabel.minimumScaleFactor = 0.3
        
        self.warningLbl.adjustsFontSizeToFitWidth = true
        self.warningLbl.minimumScaleFactor = 0.3
        
        self.coinBuyLbl.adjustsFontSizeToFitWidth = true
        self.coinBuyLbl.minimumScaleFactor = 0.3

        self.messageOpenLbl.adjustsFontSizeToFitWidth = true
        self.messageOpenLbl.minimumScaleFactor = 0.3
        
        self.useCoinLbl.adjustsFontSizeToFitWidth = true
        self.useCoinLbl.minimumScaleFactor = 0.3

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension YourTalkNoreadViewCell {
    func updateCell(text: String, time: String, yourimage: UIImage) {
        self.useCoinLbl?.text = text
        self.timeLabel?.text = time
        self.yourImageView.image = yourimage
        
        let frame = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        var rect = self.textStrView.sizeThatFits(frame)
        if(rect.width<30){
            rect.width=30
        }
        //textViewWidthConstraint.constant = rect.width//テキストが短くても最小のビューの幅を30とする
    }
}
