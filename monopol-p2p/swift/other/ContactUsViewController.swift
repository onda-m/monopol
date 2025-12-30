//
//  ContactUsViewController.swift
//  swift_skyway
//
//  Created by onda on 2020/01/14.
//  Copyright © 2020 worldtrip. All rights reserved.
//

import UIKit
import WebKit

class ContactUsViewController: BaseViewController, WKUIDelegate {

    //@IBOutlet weak var contactUsWebView: WKWebView!
    var contactUsWebView: WKWebView!
    
    /*
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        self.contactUsWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        //self.contactUsWebView = WKWebView(frame: CGRect(x: 0, y: 60, width: view.bounds.size.width, height: 400), configuration: webConfiguration)

        //self.contactUsWebView.frame = CGRect(x: 0, y: -60, width: 200, height: 400)
        
        self.contactUsWebView.uiDelegate = self
        self.view = contactUsWebView
        
        self.contactUsWebView.frame.
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // 枠線の色
        //self.ruleWebView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //self.ruleWebView.layer.borderWidth = 1
        
        // 角丸
        //self.ruleWebView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //self.ruleWebView.layer.masksToBounds = true
        
        //self.contactUsWebView.translatesAutoresizingMaskIntoConstraints = false
        
        /*
        //let ruleUrl = NSURL(string: Util.CONTACTUS_URL + "?user_id=" + String(self.user_id))
        let ruleUrl = NSURL(string: Util.CONTACTUS_URL)
        let urlRequest = NSURLRequest(url: ruleUrl! as URL)
        // urlをネットワーク接続が可能な状態にしている（らしい）
        
        self.contactUsWebView.loadRequest(urlRequest as URLRequest)
        // 実際にwebViewにurlからwebページを引っ張ってくる。
         */
        
        // WKWebViewを生成
        contactUsWebView = WKWebView(frame:CGRect(x:0, y:100, width:self.view.bounds.size.width, height:440))
        
        
        let myURL = URL(string: Util.CONTACTUS_URL + "?user_id=" + String(self.user_id))
        let myRequest = URLRequest(url: myURL!)
        contactUsWebView.load(myRequest)
        
        self.view.addSubview(contactUsWebView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    //ページが読み終わったときに呼ばれる関数
    private func webViewDidFinishLoad(webView: UIWebView) {
        print("ページ読み込み完了しました！")
    }
    //ページを読み始めた時に呼ばれる関数
    private func webViewDidStartLoad(webView: UIWebView) {
        print("ページ読み込み開始しました！")
    }*/
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("遷移開始")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("読み込み完了")
        print(webView.title as Any)
    }
    
}
