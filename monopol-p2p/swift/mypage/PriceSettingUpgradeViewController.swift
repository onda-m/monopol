//
//  PriceSettingUpgradeViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/07/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class PriceSettingUpgradeViewController: BaseViewController,UIWebViewDelegate {
    
    //レートの箇所のView
    @IBOutlet weak var rateView: UIView!
    //＊さんの現在のレートのところ
    @IBOutlet weak var rateLbl01: UILabel!
    //1スター＝1円のところ
    @IBOutlet weak var rateLbl02: UILabel!
    
    //レート以下のWebView
    @IBOutlet weak var settingWebView: UIWebView!
    
    //配信Lv10から
//    @IBOutlet weak var note01Lbl: UILabel!
//    @IBOutlet weak var note02Lbl: UILabel!
    
    //ランクフリーのところだけ上下のラベルがある
    @IBOutlet weak var rankFreeLbl01: UILabel!
//    @IBOutlet weak var rankFreeLbl02: UILabel!
    
    //ランクフリーの場合は固定で位置をずらして表示する
//    @IBOutlet weak var rankFreeKoteiLbl: UILabel!
    
//    @IBOutlet weak var level10Lbl: UILabel!
//    @IBOutlet weak var level20Lbl: UILabel!
    
//    @IBOutlet weak var rankHatenaLbl: UILabel!
//    @IBOutlet weak var rankSSSLbl: UILabel!
//    @IBOutlet weak var rankSSLbl: UILabel!
//    @IBOutlet weak var rankSLbl: UILabel!
//    @IBOutlet weak var rankAplusLbl: UILabel!
    @IBOutlet weak var rankALbl: UILabel!
//    @IBOutlet weak var rankBLbl: UILabel!
    @IBOutlet weak var rankFLbl: UILabel!
    
//    @IBOutlet weak var rankHatenaBtn: UIButton!
//    @IBOutlet weak var rankSSSBtn: UIButton!
//    @IBOutlet weak var rankSSBtn: UIButton!
//    @IBOutlet weak var rankSBtn: UIButton!
//    @IBOutlet weak var rankAplusBtn: UIButton!
    @IBOutlet weak var rankABtn: UIButton!
//    @IBOutlet weak var rankBBtn: UIButton!
    @IBOutlet weak var rankFBtn: UIButton!
    
    //最下部の補足説明のところ
//    @IBOutlet weak var hosokuTextLbl: UILabel!
    
    //@IBOutlet weak var nowRankVIew: UIView!
    @IBOutlet weak var nowRankLbl: UILabel!
//    @IBOutlet weak var nowRankHosokuLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //有料サシライブ、無料サシライブの文字色の設定
        nowRankLbl.textColor = Util.COMMON_RED_COLOR
        
        //配信レベル
        let myLiveLevel = UserDefaults.standard.integer(forKey: "myLiveLevel")
        //現在の配信ポイント(累計)
        let myLivePoint = UserDefaults.standard.integer(forKey: "myLivePoint")
        //現在のランク（0 or 1が無料サシライブ）
        let cast_rank = UserDefaults.standard.integer(forKey: "cast_rank")
        
        //個別設定の有無
        //個別設定がしてある場合は強制的に「有料サシライブ」の方へ
        //個別設定がされているかのフラグ（１：されている　２：されていない）
        //UserDefaults.standard.set("1", forKey: "streamer_individual_setting_flg")
        //let streamerIndividualSettingFlg = UserDefaults.standard.integer(forKey: "streamer_individual_setting_flg")
        //1個別設定有効2無効3設定済み無効
        //UserDefaults.standard.set(strExStatus, forKey: "ex_status")
        let exStatus = UserDefaults.standard.integer(forKey: "ex_status")
        
        if(exStatus == 3){
            //個別設定されている(無料サシライブ)
            rankABtn.isEnabled = true//有料サシライブボタン
            //rankBBtn.isEnabled = true
            rankFBtn.isEnabled = false//無料サシライブボタン
            
            //ストリーマーランクの設定
            setRankLabel(rank: 1)
            
        }else if(exStatus == 1){
            //個別設定されている(有料サシライブ)
            rankABtn.isEnabled = false//有料サシライブボタン
            //rankBBtn.isEnabled = true
            rankFBtn.isEnabled = true//無料サシライブボタン
            
            //ストリーマーランクの設定(個別設定されている場合は有料サシライブに)
            setRankLabel(rank: 2)

        }else{
            //レベルが１０以上か、配信ポイントが３０００以上
            if(myLiveLevel >= 10 || myLivePoint > Util.FREE_LIVE_POINT_MAX){
                //配信レベルが10以上の場合
                //level10Lbl.isHidden = true
                //level20Lbl.isHidden = false
                
                if(cast_rank == 0 || cast_rank == 1){
                    rankABtn.isEnabled = true//有料サシライブボタン
                    //rankBBtn.isEnabled = true
                    rankFBtn.isEnabled = false//無料サシライブボタン
                }else{
                    rankABtn.isEnabled = false//有料サシライブボタン
                    //rankBBtn.isEnabled = true
                    rankFBtn.isEnabled = true//無料サシライブボタン
                }
            }
            
            //ストリーマーランクの設定
            setRankLabel(rank: cast_rank)
        }
        
        //＊さんの現在のレートのところ
        //名前をセットする
        let myName = UserDefaults.standard.string(forKey: "myName")!
        self.rateLbl01.text = myName + "さんの現在のレート："
        
        /*
        if(myLiveLevel >= 10 && myLiveLevel < 20){
            //配信レベルが10以上で20未満の場合
            level10Lbl.isHidden = true
            level20Lbl.isHidden = false
            
            rankABtn.isEnabled = false
            rankBBtn.isEnabled = true
            rankFBtn.isEnabled = true
        }else if(myLiveLevel >= 20){
            //配信レベルが20以上
            level10Lbl.isHidden = true
            level20Lbl.isHidden = true
            
            rankABtn.isEnabled = true
            rankBBtn.isEnabled = true
            rankFBtn.isEnabled = true
        }
        */

        
        /*
        rankHatenaBtn.isEnabled = false
        rankSSSBtn.isEnabled = false
        rankSSBtn.isEnabled = false
        rankSBtn.isEnabled = false
        rankAplusBtn.isEnabled = false
         */
        //rankABtn.isEnabled = true
        //rankBBtn.isEnabled = true
        //rankFBtn.isEnabled = true
        
        // RGBA; red: 赤, green: 緑, blue: 青, a: 透明度
        //let rgba = UIColor(red: 0.1, green: 0.7, blue: 0.9, alpha: 1.0)
        //label05.textColor = rgba
        
        // 枠線の色
        rankFBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ>記述場所移動
        //rankFBtn.layer.borderWidth = 1
        // 角丸
        rankFBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankFBtn.layer.masksToBounds = true
        
        /*
        // 枠線の色
        rankBBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankBBtn.layer.borderWidth = 1
        // 角丸
        rankBBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankBBtn.layer.masksToBounds = true
        */
        
        // 枠線の色
        rankABtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ>記述場所移動
        //rankABtn.layer.borderWidth = 1
        // 角丸
        rankABtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankABtn.layer.masksToBounds = true
        
        /*
        // 枠線の色
        rankAplusBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankAplusBtn.layer.borderWidth = 1
        // 角丸
        rankAplusBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankAplusBtn.layer.masksToBounds = true
        
        // 枠線の色
        rankSBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankSBtn.layer.borderWidth = 1
        // 角丸
        rankSBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankSBtn.layer.masksToBounds = true
        
        // 枠線の色
        rankSSBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankSSBtn.layer.borderWidth = 1
        // 角丸
        rankSSBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankSSBtn.layer.masksToBounds = true
        
        // 枠線の色
        rankSSSBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankSSSBtn.layer.borderWidth = 1
        // 角丸
        rankSSSBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankSSSBtn.layer.masksToBounds = true
        
        // 枠線の色
        rankHatenaBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankHatenaBtn.layer.borderWidth = 1
        // 角丸
        rankHatenaBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankHatenaBtn.layer.masksToBounds = true
 
        // 角丸
        level10Lbl.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        level10Lbl.layer.masksToBounds = true
        
        // 角丸
        level20Lbl.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        level20Lbl.layer.masksToBounds = true
        */
        
        //ラベルの枠を自動調節する
        rateLbl01.adjustsFontSizeToFitWidth = true
        rateLbl01.minimumScaleFactor = 0.3
        
        rankFLbl.adjustsFontSizeToFitWidth = true
        rankFLbl.minimumScaleFactor = 0.3
        //yenSSSLbl.sizeToFit()
        
//        rankBLbl.adjustsFontSizeToFitWidth = true
//        rankBLbl.minimumScaleFactor = 0.3
        //yenSSLbl.sizeToFit()
        
        rankALbl.adjustsFontSizeToFitWidth = true
        rankALbl.minimumScaleFactor = 0.3
        //yenSLbl.sizeToFit()

        /*
        rankAplusLbl.adjustsFontSizeToFitWidth = true
        rankAplusLbl.minimumScaleFactor = 0.3
        //yenAplusLbl.sizeToFit()
        
        rankSLbl.adjustsFontSizeToFitWidth = true
        rankSLbl.minimumScaleFactor = 0.3
        //yenALbl.sizeToFit()
        
        rankSSLbl.adjustsFontSizeToFitWidth = true
        rankSSLbl.minimumScaleFactor = 0.3
        //yenBLbl.sizeToFit()
        
        rankSSSLbl.adjustsFontSizeToFitWidth = true
        rankSSSLbl.minimumScaleFactor = 0.3
        //yenFLbl.sizeToFit()
        
        rankHatenaLbl.adjustsFontSizeToFitWidth = true
        rankHatenaLbl.minimumScaleFactor = 0.3
        
        //補足のテキスト関連
        note01Lbl.adjustsFontSizeToFitWidth = true
        note01Lbl.minimumScaleFactor = 0.3
        
        note02Lbl.adjustsFontSizeToFitWidth = true
        note02Lbl.minimumScaleFactor = 0.3
        
        hosokuTextLbl.adjustsFontSizeToFitWidth = true
        hosokuTextLbl.minimumScaleFactor = 0.3
         */
        
        // 角丸
        self.settingWebView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.settingWebView.layer.masksToBounds = true
        
        let settingUrl = NSURL(string: Util.SETTING_WEBVIEW_URL + "?user_id=" + String(self.user_id))
        let settingUrlRequest = NSURLRequest(url: settingUrl! as URL)
        // urlをネットワーク接続が可能な状態にしている（らしい）
        
        self.settingWebView.loadRequest(settingUrlRequest as URLRequest)
        // 実際にwebViewにurlからwebページを引っ張ってくる。
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //配信レベル
        //let myLiveLevel = UserDefaults.standard.integer(forKey: "myLiveLevel")
        //if(myLiveLevel < 10){
        //    Util.toPriceSettingViewController(animated_flg: false)
        //}
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
    
    @IBAction func rankFBtn(_ sender: Any) {
        showAlert(rank: 1)
    }
    
    /*
    @IBAction func rankBBtn(_ sender: Any) {
        showAlert(rank: 2)
    }*/
    
    @IBAction func rankABtn(_ sender: Any) {
        showAlert(rank: 2)
    }

    /*
    @IBAction func rankAplusBtn(_ sender: Any) {
        showAlert(rank: 4)
    }
    
    @IBAction func rankSBtn(_ sender: Any) {
        showAlert(rank: 5)
    }
    
    @IBAction func rankSSBtn(_ sender: Any) {
        showAlert(rank: 6)
    }
    
    @IBAction func rankSSSBtn(_ sender: Any) {
        showAlert(rank: 7)
    }
    */
    
    func setRankLabel(rank: Int){
        if(rank == 0 || rank == 1){
            //nowRankLbl.isHidden = true
            //rankFreeKoteiLbl.isHidden = false
            nowRankLbl.text = "無料サシライブ"
            //nowRankHosokuLbl.text = Util.RANK_HOSOKU_FREE_STR
            
            //選択中のランクの色を変更
            rankFBtn.backgroundColor = Util.COMMON_BLUE_COLOR
            rankFreeLbl01.textColor = UIColor.white
            //rankFreeLbl02.textColor = UIColor.white
            
            //選択中のランクの色を変更
            //rankBBtn.backgroundColor = UIColor.groupTableViewBackground
            //rankBLbl.textColor = UIColor.darkGray
            
            //選択中のランクの色を変更
            rankABtn.backgroundColor = UIColor.groupTableViewBackground
            rankALbl.textColor = UIColor.darkGray

            // 枠線の太さ
            rankFBtn.layer.borderWidth = 0
            rankABtn.layer.borderWidth = 1
            
            //レートとその下の報酬リストを非表示
            self.rateView.isHidden = true
            self.settingWebView.isHidden = true
        }else{
            //nowRankLbl.isHidden = true
            //rankFreeKoteiLbl.isHidden = false
            
            nowRankLbl.text = "有料サシライブ"
            //nowRankHosokuLbl.text = Util.RANK_HOSOKU_B_STR
            
            //選択中のランクの色を変更
            rankFBtn.backgroundColor = UIColor.groupTableViewBackground
            rankFreeLbl01.textColor = UIColor.darkGray
            //rankFreeLbl02.textColor = UIColor.darkGray
            
            //選択中のランクの色を変更
            //rankBBtn.backgroundColor = Util.LIVE_LEVEL_SETTING_COLOR
            //rankBLbl.textColor = UIColor.white
            
            //選択中のランクの色を変更
            rankABtn.backgroundColor = Util.COMMON_BLUE_COLOR
            rankALbl.textColor = UIColor.white
            //rankALbl.textColor = UIColor.darkGray
            
            // 枠線の太さ
            rankFBtn.layer.borderWidth = 1
            rankABtn.layer.borderWidth = 0
            
            //レートとその下の報酬リストを表示
            self.rateView.isHidden = false
            
            //報酬リストのWebViewを表示するかどうか(0:表示 1:非表示)
            let organizer_webview_flg = UserDefaults.standard.integer(forKey: "organizer_webview_flg")
            
            if(organizer_webview_flg == 1){
                //非表示
                self.settingWebView.isHidden = true
            }else{
                //表示
                self.settingWebView.isHidden = false
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //ボタンが押されるとこの関数が呼ばれる
    //rank = 1:フリー
    //rank = 2:B
    //rank = 3:A
    //rank = 4:A+
    //rank = 5:S
    //rank = 6:SS
    //rank = 7:SSS
    @objc func showAlert(rank: Int){
        
        //UIAlertControllerを用意する
        var strRank = ""
        /*
        if(rank == 1){
            strRank = "ランクフリー"
        }else if(rank == 2){
            strRank = "ランクB"
        }else if(rank == 3){
            strRank = "ランクA"
        }else if(rank == 4){
            strRank = "ランクA+"
        }else if(rank == 5){
            strRank = "ランクS"
        }else if(rank == 6){
            strRank = "ランクSS"
        }else if(rank == 7){
            strRank = "ランクSSS"
        }*/
        
        if(rank == 1){
            strRank = "無料サシライブ"
        }else if(rank == 2){
            strRank = "有料サシライブ"
        }
        
        let actionAlert = UIAlertController(title: strRank + "に変更しますか?", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "変更する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            //自分のuser_idを指定
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            var stringUrl = Util.URL_MOD_RANK
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&rank=")
            stringUrl.append(String(rank))
            
            // Swift4からは書き方が変わりました。
            let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            //let decodedString:String = text.removingPercentEncoding!
            let req = URLRequest(url: url)
            
            //非同期処理を行う
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue_mod_rank", attributes: .concurrent)
            
            dispatchGroup.enter()
            dispatchQueue.async {
                let task = URLSession.shared.dataTask(with: req, completionHandler: {
                    (data, res, err) in
                    //do{
                    //JSONDecoderのインスタンス取得
                    //let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    //let json = try decoder.decode(ResultJson.self, from: data!)
                    
                    // UserDefaultsを使ってデータを保持する
                    //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                    UserDefaults.standard.set(rank, forKey: "cast_rank")
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                    //}catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print("json convert failed in JSONDecoder", err?.localizedDescription)
                    //}
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //ステータス変更が成功
                //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                self.setRankLabel(rank: rank)
                
                if(rank == 0 || rank == 1){
                    self.rankABtn.isEnabled = true//有料サシライブボタン
                    //rankBBtn.isEnabled = true
                    self.rankFBtn.isEnabled = false//無料サシライブボタン
                }else{
                    self.rankABtn.isEnabled = false//有料サシライブボタン
                    //rankBBtn.isEnabled = true
                    self.rankFBtn.isEnabled = true//無料サシライブボタン
                }
            }
        })
        
        actionAlert.addAction(modifyAction)
        
        /*
         //UIAlertControllerに***のアクションを追加する
         let ***Action = UIAlertAction(title: "***", style: UIAlertActionStyle.default, handler: {
         (action: UIAlertAction!) in
         print("***のシートが選択されました。")
         })
         actionAlert.addAction(***Action)
         */
        
        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            //print("キャンセルのシートが押されました。")
        })
        actionAlert.addAction(cancelAction)
        
        // iPadでは必須！
        actionAlert.popoverPresentationController?.sourceView = self.view
        
        // ここで表示位置を調整。xは画面中央、yは画面下部になる様に指定
        let screenSize = UIScreen.main.bounds
        actionAlert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // 下記を追加する
        actionAlert.modalPresentationStyle = .fullScreen
        
        //アクションを表示する
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    //tabmenuのボタン押下時
    //func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    //    Util.castTabBarTap(tag: item.tag)
    //}
}
