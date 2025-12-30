//
//  MaintenanceViewController.swift
//  swift_skyway
//
//  Created by onda on 2019/06/28.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

//class MaintenanceViewController: BaseViewController {
class MaintenanceViewController: UIViewController {
    
    //mainte_flg
    //メンテナンスフラグ取得用
    struct MainteFlgResult: Codable {
        let value01: String//
        let value02: String//
        let value03: String//
        let value04: String//
        let value05: String//
    }
    struct ResultMainteFlgJson: Codable {
        let count: Int
        let result: [MainteFlgResult]
    }
    
    //メンテナンスフラグ 1:メンテ中
    var mainte_flg = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        /*
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
         */
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(viewWillEnterForeground(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        notification.addObserver(self, selector: #selector(viewDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //メンテ中かのチェック
        self.maintenanceCheck()
    }
    
    func maintenanceCheck(){
        /***********************************************************/
        //  メンテナンス中かの判断
        /***********************************************************/
        //code_name=mainte_flg 1:メンテ中
        //static let URL_GET_PUBCODE = URL_BASE + "getPubcode.php"//メンテナンスかどうかのチェックetc
        var stringUrl = Util.URL_GET_PUBCODE
        stringUrl.append("?code_name=mainte_flg")
        print(stringUrl)
        
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
                    let json = try decoder.decode(ResultMainteFlgJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //ただしゼロ番目のみ参照可能
                    for obj in json.result {
                        //データが取得できなかった場合を考慮
                        if(obj.value01 == "1"){
                            //メンテ中
                            self.mainte_flg = 1
                        }else{
                            self.mainte_flg = 0
                        }
                        
                        break
                    }
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(self.mainte_flg == 1){
                //メンテ中の場合は何もしない
                //UtilToViewController.toMaintenanceViewController()
            }else{
                //メンテでない場合は前の画面へ
                //UtilToViewController.toMainViewController()
                self.dismiss(animated: true, completion: nil)
            }
        }
        /***********************************************************/
        //  メンテナンス中かの判断(ここまで)
        /***********************************************************/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("フォアグラウンド")
            //メンテ中かのチェック
            self.maintenanceCheck()
        }
    }
    
    @objc func viewDidEnterBackground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("バックグラウンド")
            //メンテ中かのチェック
            self.maintenanceCheck()
        }
    }
}
