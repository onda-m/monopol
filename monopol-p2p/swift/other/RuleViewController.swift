//
//  RuleViewController.swift
//  swift_skyway
//
//  Created by onda on 2019/05/27.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import UIKit

class RuleViewController: BaseViewController {

    @IBOutlet weak var ruleWebView: UIWebView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // 枠線の色
        self.ruleWebView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.ruleWebView.layer.borderWidth = 1
        
        // 角丸
        self.ruleWebView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.ruleWebView.layer.masksToBounds = true
        
        let ruleUrl = NSURL(string: Util.RULE_URL)
        let urlRequest = NSURLRequest(url: ruleUrl! as URL)
        // urlをネットワーク接続が可能な状態にしている（らしい）
        
        ruleWebView.loadRequest(urlRequest as URLRequest)
        // 実際にwebViewにurlからwebページを引っ張ってくる。
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ページが読み終わったときに呼ばれる関数
    private func webViewDidFinishLoad(webView: UIWebView) {
        print("ページ読み込み完了しました！")
    }
    //ページを読み始めた時に呼ばれる関数
    private func webViewDidStartLoad(webView: UIWebView) {
        print("ページ読み込み開始しました！")
    }
}
