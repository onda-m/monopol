//
//  NoCoinDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/09/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class NoCoinDialog: UIView {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //プレゼントリスト関連
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coinPurchaseBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //ダイアログ関連
        // 枠線の色
        self.mainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.mainView.layer.borderWidth = 2
        
        // 角丸
        self.mainView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainView.layer.masksToBounds = true
        
        // 角丸
        self.coinPurchaseBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.coinPurchaseBtn.layer.masksToBounds = true
        
        // 角丸
        self.cancelBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.cancelBtn.layer.masksToBounds = true
    }

    @IBAction func tapCoinPurchaseBtn(_ sender: Any) {
        //self.removeFromSuperview()
        self.isHidden = true
        
        //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
        UserDefaults.standard.set(5, forKey: "selectedMenuNum")
        
        //コイン購入画面へ
        UtilToViewController.toPurchaseViewController(animated_flg:false)
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        //self.removeFromSuperview()
        self.isHidden = true
    }
}
