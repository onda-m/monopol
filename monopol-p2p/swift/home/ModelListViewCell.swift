//
//  ModelListViewCell.swift
//  swift_skyway
//
//  Created by onda on 2019/07/24.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class ModelListViewCell:UICollectionViewCell{
    @IBOutlet weak var profileBtn: UIButton!//3行のテキストを設定する
    @IBOutlet weak var triangleBtn: TriangleButton!
    @IBOutlet weak var castImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!//パスワードアイコンのところ
    @IBOutlet weak var statusImageView:UIImageView!//右上の状態アイコンのところ
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var onliveLabel: UILabel!//予約可のところ
    @IBOutlet weak var officialLabel: UILabel!//公式ラベルのところ
    @IBOutlet weak var rankingPointLabel: UILabel!//ランキングポイントのところ
    @IBOutlet weak var liveFreeImageView: UIImageView!//右下無料サシライブのところ
    @IBOutlet weak var eventImageView: UIImageView!//左上のイベントアイコンを表示する箇所
    @IBOutlet weak var prMovieImageView: UIImageView!//左下のPR動画の箇所
    @IBOutlet weak var eventLabel: UILabel!//右下イベントのところ
    @IBOutlet weak var eventNowImageView: UIImageView!
    
    override func prepareForReuse(){
        //print("clear")
        //imageは初期化すること（初期化しないと、スクロール時に同じ画像が出てしまう。）
        self.castImageView.image = nil;
        
        //ラベルの枠を自動調節する
        self.rankingPointLabel.adjustsFontSizeToFitWidth = true
        self.rankingPointLabel.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        self.profileBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        //self.timeLabel.adjustsFontSizeToFitWidth = true
        self.profileBtn.titleLabel?.minimumScaleFactor = 0.1
        
        
        //self.profileBtn.titleLabel!.lineBreakMode = NSLineBreakMode.byCharWrapping
        //self.profileBtn.titleLabel!.numberOfLines = 3
        //self.profileBtn.titleLabel!.textAlignment = NSTextAlignment.center

        //self.statusLabel.text = ""
        //self.profileLabel.text = ""
        //self.onliveLabel.text = ""
        //self.officialLabel.text = ""
        //self.rankingPointLabel.text = ""
    }
}
