//
//  RuleCheckView.swift
//  swift_skyway
//
//  Created by onda on 2019/05/25.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class RuleCheckView: UIView,UIWebViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var ruleWebView: UIWebView!
    
    @IBOutlet weak var ruleOkBtn: UIButton!
    
    @IBOutlet weak var ruleCheckBtn: CheckBox!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //規約同意チェックフラグ：１＝チェック済
        let rule_check_flg = UserDefaults.standard.integer(forKey: "rule_check_flg")
        if(rule_check_flg == 1){
            //ボタンを表示
            self.ruleOkBtn.isHidden = false
        }else{
            self.ruleOkBtn.isHidden = true
        }
        //色指定
        self.ruleOkBtn.backgroundColor = Util.COMMON_BLUE_COLOR
        
        // 枠線の色
        //self.ruleWebView.layer.borderColor = UIColor.lightGray.cgColor
        self.ruleWebView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        self.ruleWebView.layer.borderWidth = 0.5
        // 角丸
        self.ruleWebView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.ruleWebView.layer.masksToBounds = true
        
        // 角丸
        self.ruleOkBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.ruleOkBtn.layer.masksToBounds = true
        
        let ruleUrl = NSURL(string: Util.RULE_URL)
        let urlRequest = NSURLRequest(url: ruleUrl! as URL)
        // urlをネットワーク接続が可能な状態にしている（らしい）
        
        ruleWebView.loadRequest(urlRequest as URLRequest)
        // 実際にwebViewにurlからwebページを引っ張ってくる。
    }
    
    //ページが読み終わったときに呼ばれる関数
    private func webViewDidFinishLoad(webView: UIWebView) {
        print("ページ読み込み完了しました！")
    }
    //ページを読み始めた時に呼ばれる関数
    private func webViewDidStartLoad(webView: UIWebView) {
        print("ページ読み込み開始しました！")
    }
    
    @IBAction func tapOkBtn(_ sender: Any) {
        //規約同意チェックフラグ：１＝チェック済
        let rule_check_flg = UserDefaults.standard.integer(forKey: "rule_check_flg")
        if(rule_check_flg == 1){
            //ダイアログを閉じる
            self.isHidden = true
        }
    }
    
    @IBAction func checkView(_ sender: CheckBox) {
        //チェックボックスをクリックしたときに動作する
        if(sender.isChecked == true){
            //チェックがオフになった場合
            UserDefaults.standard.set(0, forKey: "rule_check_flg")
            
            //ボタンを非表示
            self.ruleOkBtn.isHidden = true
        }else{
            UserDefaults.standard.set(1, forKey: "rule_check_flg")
            
            //ボタンを表示
            self.ruleOkBtn.isHidden = false
        }
    }
}
