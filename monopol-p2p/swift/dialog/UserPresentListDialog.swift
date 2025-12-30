//
//  UserPresentListDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/08/13.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class UserPresentListDialog: UIView {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //プレゼントリスト関連
    @IBOutlet weak var presentListMainView: UIView!
    @IBOutlet weak var presentListTitleLabel: UILabel!
    @IBOutlet weak var presentListCoinLabel: UILabel!
    @IBOutlet weak var presentCoinPurchaseBtn: UIButton!
    
    @IBOutlet weak var presentListCollectionView: UICollectionView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.presentListCollectionView.register(UINib(nibName: "PresentCell", bundle: nil), forCellWithReuseIdentifier: "PresentCell")
        
        //self.presentListCollectionView.dataSource = (self.parentViewController() as! MediaConnectionViewController) as! UICollectionViewDataSource
        //self.presentListCollectionView.delegate = (self.parentViewController() as! MediaConnectionViewController)
        
        //プレゼントリストのダイアログ関連
        // 角丸
        self.presentListMainView.layer.cornerRadius = 16
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.presentListMainView.layer.masksToBounds = true
        
        // 角丸
        self.presentCoinPurchaseBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.presentCoinPurchaseBtn.layer.masksToBounds = true
        
        //self.getPresentList()
    }

    //コイン購入ボタン
    @IBAction func tapCoinPurchaseBtn(_ sender: Any) {
        //所有しているコインの設定
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        Util.userPurchasePlanDialog.purchasePlanTitleLabel.text = "マイコイン " + UtilFunc.numFormatter(num: Int(myPoint))
        Util.userPurchasePlanDialog.isHidden = false
        Util.userPurchasePlanDialog.productTableView.isHidden = false
        self.bringSubviewToFront(Util.userPurchasePlanDialog)
        //Util.userPurchasePlanDialog.productTableView.reloadData()
    }
    
    @IBAction func tapPresentListCanselBtn(_ sender: Any) {
        //プレゼントリストのキャンセルボタン
        self.isHidden = true
    }
}
