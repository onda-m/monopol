//
//  AutoUserTabDialog.swift
//  swift_skyway
//
//  Created by onda on 2020/02/27.
//  Copyright © 2020 worldtrip. All rights reserved.
//

import UIKit

class AutoUserTabDialog: UIView {
    /*
    //自動応答ユーザー配信中の下部メニューから呼び出されるダイアログ
    //基本的にImage1つのみ
    @IBOutlet weak var presentListMainView: UIView!
    @IBOutlet weak var presentListTitleLabel: UILabel!
    @IBOutlet weak var presentListCoinLabel: UILabel!
    @IBOutlet weak var presentCoinPurchaseBtn: UIButton!
    @IBOutlet weak var presentListCollectionView: UICollectionView!
    */
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code

        //ダイアログ関連
        // 角丸
        self.mainView.layer.cornerRadius = 16
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainView.layer.masksToBounds = true
        
        self.mainImageView.layer.cornerRadius = 16
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainImageView.layer.masksToBounds = true
        
        //self.getPresentList()
    }
    
    @IBAction func tapCanselBtn(_ sender: Any) {
        //プレゼントリストのキャンセルボタン
        self.isHidden = true
    }
}
