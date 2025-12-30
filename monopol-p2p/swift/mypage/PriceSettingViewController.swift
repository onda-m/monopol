//
//  PriceSettingViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class PriceSettingViewController: BaseViewController {

    let iconSize: CGFloat = 20.0
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    //tabアイテム用
    //@IBOutlet weak var castTabBar: UITabBar!
    
    //@IBOutlet weak var rankSSSView: UIView!
    //@IBOutlet weak var rankSSView: UIView!
    //@IBOutlet weak var rankSView: UIView!
    //@IBOutlet weak var rankAplusView: UIView!
    //@IBOutlet weak var rankAView: UIView!
    //@IBOutlet weak var rankBView: UIView!
    //@IBOutlet weak var rankFView: UIView!

    //追加
    @IBOutlet weak var aboutView: UIView!
    
    //先頭に画像をつけるため
    @IBOutlet weak var aboutLbl: UILabel!
    //ランクフリーのところだけ上下のラベルがある
    //@IBOutlet weak var rankFreeLbl01: UILabel!
    //@IBOutlet weak var rankFreeLbl02: UILabel!
    
    //@IBOutlet weak var note01Lbl: UILabel!
    //@IBOutlet weak var note02Lbl: UILabel!
    
    //@IBOutlet weak var level10Lbl: UILabel!
    //@IBOutlet weak var level20Lbl: UILabel!
    
    //@IBOutlet weak var rankHatenaLbl: UILabel!
    //@IBOutlet weak var rankSSSLbl: UILabel!
    //@IBOutlet weak var rankSSLbl: UILabel!
    //@IBOutlet weak var rankSLbl: UILabel!
    //@IBOutlet weak var rankAplusLbl: UILabel!
    //@IBOutlet weak var rankALbl: UILabel!
    //@IBOutlet weak var rankBLbl: UILabel!
    //@IBOutlet weak var rankFLbl: UILabel!
    
    //@IBOutlet weak var rankHatenaBtn: UIButton!
    //@IBOutlet weak var rankSSSBtn: UIButton!
    //@IBOutlet weak var rankSSBtn: UIButton!
    //@IBOutlet weak var rankSBtn: UIButton!
    //@IBOutlet weak var rankAplusBtn: UIButton!
    //@IBOutlet weak var rankABtn: UIButton!
    //@IBOutlet weak var rankBBtn: UIButton!
    //@IBOutlet weak var rankFBtn: UIButton!
    
    //「６０分」のところ
    @IBOutlet weak var hosokuTextLbl: UILabel!
    
    //@IBOutlet weak var rankSSSLblTemp: UILabel!
    //@IBOutlet weak var rankSSLblTemp: UILabel!
    //@IBOutlet weak var rankSLblTemp: UILabel!
    //@IBOutlet weak var rankAplusLblTemp: UILabel!
    //@IBOutlet weak var rankALblTemp: UILabel!
    //@IBOutlet weak var rankBLblTemp: UILabel!
    //@IBOutlet weak var rankFLblTemp: UILabel!
    
    //時給・・・のところ
    //@IBOutlet weak var yenSSSLbl: UILabel!
    //@IBOutlet weak var yenSSLbl: UILabel!
    //@IBOutlet weak var yenSLbl: UILabel!
    //@IBOutlet weak var yenAplusLbl: UILabel!
    //@IBOutlet weak var yenALbl: UILabel!
    //@IBOutlet weak var yenBLbl: UILabel!
    //@IBOutlet weak var yenFLbl: UILabel!
    
    //@IBOutlet weak var nowRankVIew: UIView!
    @IBOutlet weak var nowRankLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        //デリゲート先を自分に設定する。
        //castTabBar.delegate = self
        
        //ストリーマーランクの設定
        //let cast_rank = UserDefaults.standard.integer(forKey: "cast_rank")
        //setRankLabel(rank: cast_rank)
        
        //rankHatenaBtn.isEnabled = false
        //rankSSSBtn.isEnabled = false
        //rankSSBtn.isEnabled = false
        //rankSBtn.isEnabled = false
        //rankAplusBtn.isEnabled = false
        //rankABtn.isEnabled = false
        //rankBBtn.isEnabled = false
        //rankFBtn.isEnabled = false
        
        //選択中のランクの色を変更
        //rankFBtn.backgroundColor = Util.LIVE_LEVEL_SETTING_COLOR
        //rankFreeLbl01.textColor = UIColor.white
        //rankFreeLbl02.textColor = UIColor.white
        
        // RGBA; red: 赤, green: 緑, blue: 青, a: 透明度
        //let rgba = UIColor(red: 0.1, green: 0.7, blue: 0.9, alpha: 1.0)
        //label05.textColor = rgba

        /*
        // 枠線の色
        rankFBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankFBtn.layer.borderWidth = 1
        // 角丸
        rankFBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankFBtn.layer.masksToBounds = true
        
        // 枠線の色
        rankBBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankBBtn.layer.borderWidth = 1
        // 角丸
        rankBBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankBBtn.layer.masksToBounds = true
        
        // 枠線の色
        rankABtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        rankABtn.layer.borderWidth = 1
        // 角丸
        rankABtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankABtn.layer.masksToBounds = true
        
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
        
        //ラベルの枠を自動調節する
        rankFLbl.adjustsFontSizeToFitWidth = true
        rankFLbl.minimumScaleFactor = 0.3
        //yenSSSLbl.sizeToFit()
        
        rankBLbl.adjustsFontSizeToFitWidth = true
        rankBLbl.minimumScaleFactor = 0.3
        //yenSSLbl.sizeToFit()

        rankALbl.adjustsFontSizeToFitWidth = true
        rankALbl.minimumScaleFactor = 0.3
        //yenSLbl.sizeToFit()
        
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
        */
        
        self.hosokuTextLbl.adjustsFontSizeToFitWidth = true
        self.hosokuTextLbl.minimumScaleFactor = 0.3
        
        //1時間の無料ライブをすることにより配信ポイント3000ポイントを取得という意味
        //static let FREE_LIVE_POINT_MAX: Int = 3000//有料サシライブまでの配信ポイント(MAX値)
        //static let FREE_LIVE_POINT_BY_MINUTE: Int = 50//1分あたりの配信ポイント
        //現在の配信ポイント(累計)
        let myLivePoint = UserDefaults.standard.integer(forKey: "myLivePoint")
        //有料サシライブまでの配信ポイント
        let pointZan = Util.FREE_LIVE_POINT_MAX - myLivePoint
        //残りの分数(切り上げ)
        let minuteZan = ceil(Double(pointZan) / Double(Util.FREE_LIVE_POINT_BY_MINUTE))
        //ceil(minuteZan)
        
        self.hosokuTextLbl.text = String(Int(minuteZan)) + "分"
        
        // Do any additional setup after loading the view.

        // スクロールの高さを変更
        //scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 500)
        
        //補足文章のところ（追加）
        aboutView.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
        // 角丸
        aboutView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        aboutView.layer.masksToBounds = true

        self.aboutLbl.adjustsFontSizeToFitWidth = true
        self.aboutLbl.minimumScaleFactor = 0.3
        
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.aboutLbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-5 ,string: "有料サシライブ機能開放まで", iconImage: UIImage(named:"cast_list_onlive")!, iconSize: self.iconSize)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //配信レベル
        //let myLiveLevel = UserDefaults.standard.integer(forKey: "myLiveLevel")
        
        //if(myLiveLevel >= 10){
        //    Util.toPriceSettingUpgradeViewController(animated_flg: false)
        //}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @IBAction func rankFBtn(_ sender: Any) {
        showAlert(rank: 1)
    }
    
    @IBAction func rankBBtn(_ sender: Any) {
        showAlert(rank: 2)
    }
    
    @IBAction func rankABtn(_ sender: Any) {
        showAlert(rank: 3)
    }
    
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

    func setRankLabel(rank: Int){
        if(rank == 0 || rank == 1){
            nowRankLbl.text = "ランクフリー"
        }else if(rank == 2){
            nowRankLbl.text = "ランクB"
        }else if(rank == 3){
            nowRankLbl.text = "ランクA"
        }else if(rank == 4){
            nowRankLbl.text = "ランクA+"
        }else if(rank == 5){
            nowRankLbl.text = "ランクS"
        }else if(rank == 6){
            nowRankLbl.text = "ランクSS"
        }else if(rank == 7){
            nowRankLbl.text = "ランクSSS"
        }
    }
     */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    /*
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
        }
        
        let actionAlert = UIAlertController(title: strRank + "に変更しますか？", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
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
            }
        })

        actionAlert.addAction(modifyAction)
        */
    
        /*
        //UIAlertControllerに***のアクションを追加する
        let ***Action = UIAlertAction(title: "***", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            print("***のシートが選択されました。")
        })
        actionAlert.addAction(***Action)
        */
    
    /*
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
     */
    
    //tabmenuのボタン押下時
    //func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    //    Util.castTabBarTap(tag: item.tag)
    //}
}
