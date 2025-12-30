//
//  UserPurchasePlanDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/08/13.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class UserPurchasePlanDialog: UIView {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ノーコイン関連
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coinPurchaseBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    //購入注意事項関連
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesTextLbl: UILabel!
    @IBOutlet weak var titleTextLbl: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var productTableView: UITableView!
    
    //購入プラン関連
    @IBOutlet weak var purchasePlanMainView: UIView!
    @IBOutlet weak var purchasePlanTitleLabel: UILabel!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //コイン購入の規約関連
        //self.notesTextLbl.text = UtilStr.COIN_PAY_STR
        self.notesView.isHidden = true
        self.titleTextLbl.text = UtilStr.COIN_PAY_TITLE_STR
        var mainText = UtilStr.COIN_PAY_STR_00
        mainText.append(UtilStr.COIN_PAY_STR_01)
        mainText.append(UtilStr.COIN_PAY_STR_02)
        mainText.append(UtilStr.COIN_PAY_STR_03)
        mainText.append(UtilStr.COIN_PAY_STR_04)
        mainText.append(UtilStr.COIN_PAY_STR_05)
        mainText.append(UtilStr.COIN_PAY_STR_06)
        mainText.append(UtilStr.COIN_PAY_STR_07)
        mainText.append(UtilStr.COIN_PAY_STR_08)
        mainText.append(UtilStr.COIN_PAY_STR_09)
        mainText.append(UtilStr.COIN_PAY_STR_10)
        mainText.append(UtilStr.COIN_PAY_STR_11)
        mainText.append(UtilStr.COIN_PAY_STR_12)
        mainText.append(UtilStr.COIN_PAY_STR_13)
        mainText.append(UtilStr.COIN_PAY_STR_99)
        self.notesTextLbl.text = mainText
        
        // セットした文字からUILabelの幅と高さを算出
        let rect: CGSize = notesTextLbl.sizeThatFits(CGSize(width: self.notesTextLbl.frame.width, height: CGFloat.greatestFiniteMagnitude))
        // 算出された幅と高さをセット
        self.notesTextLbl.frame = CGRect(x: notesTextLbl.frame.minX, y: 0, width: rect.width, height: rect.height)
        self.mainScrollView.contentSize = CGSize(width: self.notesTextLbl.frame.width, height: self.notesTextLbl.frame.height + 10)
        
        //テーブルの区切り線を非表示
        self.productTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.productTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.productTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.productTableView.allowsSelection = false // 選択を不可にする
        self.productTableView.isScrollEnabled = true
        self.productTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        self.productTableView.sectionFooterHeight = 0.0
        
        // 角丸
        self.purchasePlanMainView.layer.cornerRadius = 16
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.purchasePlanMainView.layer.masksToBounds = true
        
        //所有しているコインの設定
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        self.purchasePlanTitleLabel.text = "マイコイン " + UtilFunc.numFormatter(num: Int(myPoint))

        /********************/
        //ノーコイン関連
        /********************/
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
        
        self.mainView.isHidden = true
        /********************/
        //ノーコイン関連(ここまで)
        /********************/
        
        //self.productTableView.reloadData()
    }

    //購入プラン関連
    @IBAction func tapPurchasePlanCanselBtn(_ sender: Any) {
        //購入プランのキャンセル
        //self.purchasePlanMainView.isHidden = true
        self.isHidden = true
        //self.presentListMainView.isHidden = false
    }
    
    //購入注意事項のリンク
    @IBAction func tapPurchasePlanAlertBtn(_ sender: Any) {
        //購入注意事項画面へ
        //let notes: NotesViewController = self.storyboard!.instantiateViewController(withIdentifier: "toNotesViewController") as! NotesViewController
        // 下記を追加する
        //notes.modalPresentationStyle = .fullScreen
        //present(notes, animated: true, completion: nil)
        self.notesView.isHidden = false
    }
    
    @IBAction func tapNoticeCloseBtn(_ sender: Any) {
        self.notesView.isHidden = true
    }
    
    /***********************/
    //ノーコイン関連
    /***********************/
    @IBAction func tapCoinPurchaseBtn(_ sender: Any) {
        //self.removeFromSuperview()
        //コイン購入画面へ
        //Util.toPurchaseViewController()
        self.mainView.isHidden = true
        self.purchasePlanMainView.isHidden = false
        self.notesView.isHidden = true
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        //self.removeFromSuperview()
        self.isHidden = true
    }
    /***********************/
    //ノーコイン関連(ここまで)
    /***********************/
}
