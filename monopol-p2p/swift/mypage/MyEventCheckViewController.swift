//
//  MyEventCheckViewController.swift
//  swift_skyway
//
//  Created by dev monopol on 2021/09/02.
//  Copyright © 2021 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class MyEventCheckViewController: BaseViewController,UIWebViewDelegate {

    let iconSize: CGFloat = 20.0

    //イベント告知ページをコピーボタン
    @IBOutlet weak var copyEventKokuchiPageBtn: UIButton!
    
    //イベント告知ページを確認ボタン
    @IBOutlet weak var createEventKokuchiPageBtn: UIButton!
    
    //追加
    //@IBOutlet weak var aboutView: UIView!
    
    //先頭に画像をつけるため
    //@IBOutlet weak var aboutLbl: UILabel!

    //@IBOutlet weak var nowRankVIew: UIView!
    //@IBOutlet weak var nowRankLbl: UILabel!

    //イベント確認はWebViewで表示
    @IBOutlet weak var settingWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //コピーボタン
        // 枠線の色
        self.copyEventKokuchiPageBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
        // 枠線の太さ
        self.copyEventKokuchiPageBtn.layer.borderWidth = 1
        // 角丸
        self.copyEventKokuchiPageBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.copyEventKokuchiPageBtn.layer.masksToBounds = true
        //createEventKokuchiPageBtn.setTitleColor(Util.LIVE_WAIT_STRING_COLOR, for: .normal)
        
        //確認ボタン
        // 枠線の色
        self.createEventKokuchiPageBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
        // 枠線の太さ
        self.createEventKokuchiPageBtn.layer.borderWidth = 1
        // 角丸
        self.createEventKokuchiPageBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.createEventKokuchiPageBtn.layer.masksToBounds = true
        //createEventKokuchiPageBtn.setTitleColor(Util.LIVE_WAIT_STRING_COLOR, for: .normal)
        
        //名前をセットする
        //let myName = UserDefaults.standard.string(forKey: "myName")!
        //self.rateLbl01.text = myName + "さんの現在の
        
        self.getMyEventCount(user_id:self.user_id)
        
        // 角丸
        self.settingWebView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.settingWebView.layer.masksToBounds = true
        
        let settingUrl = NSURL(string: Util.MYEVENT_CHECK_WEBVIEW_URL + "?user_id=" + String(self.user_id))
        let settingUrlRequest = NSURLRequest(url: settingUrl! as URL)
        // urlをネットワーク接続が可能な状態にしている（らしい）
        
        self.settingWebView.loadRequest(settingUrlRequest as URLRequest)
        // 実際にwebViewにurlからwebページを引っ張ってくる。
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //イベント告知ページ
    //static let URL_EVENT_URL = "https://test.monopol.jp/event/?id="
    //イベント申込ページ
    //static let URL_EVENT_APPLY_URL = "https://test.monopol.jp/event/apply.html?id="
    
    @IBAction func myEventKokuchiPage(_ sender: Any) {
        //イベント告知ページ
        var event_parent_id = 0
        
        var stringUrl = Util.URL_GET_MY_EVENT_PARENT
        stringUrl.append("?user_id=")
        stringUrl.append(String(self.user_id))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultMyEventParentJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        event_parent_id = Int(obj.my_event_parent_id)!
                        break//先頭だけ取得
                        //UserDefaults.standard.set(obj.my_event_count, forKey: "talkNoreadCount")
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(event_parent_id == 0){
                //作成したイベントがない場合
                //通常は通らない
            }else{
                //外部ブラウザでURLを開く
                var stringUrl = Util.URL_EVENT_URL
                stringUrl.append(String(event_parent_id))
                //print(stringUrl)
                let url = NSURL(string: stringUrl)
                if UIApplication.shared.canOpenURL(url! as URL){
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                }
            }
        }
    }

    @IBAction func copyEventKokuchiPage(_ sender: Any) {
        //イベント告知ページのURLなどをクリップボードにコピーする
        var event_parent_id = 0
        //var from_year = 0
        var from_month = 0
        var from_day = 0
        
        var stringUrl = Util.URL_GET_MY_EVENT_PARENT
        stringUrl.append("?user_id=")
        stringUrl.append(String(self.user_id))
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultMyEventParentJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        event_parent_id = Int(obj.my_event_parent_id)!
                        //from_year = Int(obj.from_year)!
                        from_month = Int(obj.from_month)!
                        from_day = Int(obj.from_day)!
                        break//先頭だけ取得
                        //UserDefaults.standard.set(obj.my_event_count, forKey: "talkNoreadCount")
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(event_parent_id == 0){
                //作成したイベントがない場合
                UtilFunc.showAlert(message:"イベントを作成すると告知内容をクリップボードにコピーできます。", vc:self, sec:2.0)
            }else{
                //URLなどをクリップボードにコピー
                var stringUrl = "#モノポル で1対1のサシライブ配信を楽しもう！"
                    + String(from_month) + "月" + String(from_day) + "日から特別イベントを開催します！ぜひみなさん予約してください。"
                
                stringUrl.append(Util.URL_EVENT_URL)
                stringUrl.append(String(event_parent_id))
                //print(stringUrl)

                UIPasteboard.general.string = stringUrl

                UtilFunc.showAlert(message:"クリップボードにイベント情報リンクをコピーしました！SNS等でリンクを張り付けて告知しよう！", vc:self, sec:2.0)
            }
        }
    }
    
    //マイイベント数取得
    func getMyEventCount(user_id:Int){
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        var event_count = 0
        
        var stringUrl = Util.URL_GET_MY_EVENT_COUNT
        stringUrl.append("?type=2&user_id=")
        stringUrl.append(String(user_id))
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultMyEventCountJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        event_count = Int(obj.my_event_count)!
                        //UserDefaults.standard.set(obj.my_event_count, forKey: "talkNoreadCount")
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(event_count == 0){
                self.createEventKokuchiPageBtn.isEnabled = false
            }else{
                self.createEventKokuchiPageBtn.isEnabled = true
                //エラーメッセージ
                /*
                //アラート表示
                let alert = UIAlertController(title: "イベントを既に作成済みです", message: "イベントの内容は「マイページ」の「イベント確認」メニューから確認することが出来ます。", preferredStyle: .alert)
                //ここから追加
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    //マイページへ
                    //UtilToViewController.toMypageViewController()
                }
                alert.addAction(ok)
                //ここまで追加
                self.present(alert, animated: true, completion: nil)
                 */
            }
        }
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
