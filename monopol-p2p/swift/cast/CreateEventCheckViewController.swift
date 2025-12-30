//
//  CreateEventCheckViewController.swift
//  swift_skyway
//
//  Created by dev monopol on 2021/08/23.
//  Copyright © 2021 worldtrip. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CreateEventCheckViewController: BaseViewController {
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let iconSize: CGFloat = 16.0
    
    @IBOutlet weak var detailLabel: UILabel!//画面上の説明のところ
//    @IBOutlet weak var aboutView: UIView!
    
    //イベント告知ページを確認ボタン
    @IBOutlet weak var createEventKokuchiPageBtn: UIButton!
    
    //イベント申込ページを確認ボタン
    //@IBOutlet weak var createEventJoinPageBtn: UIButton!
    
    //イベントを作成するボタン
    @IBOutlet weak var createEventBtn: UIButton!
    //戻るボタン
    @IBOutlet weak var createBackBtn: UIButton!
    
    //@IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //self.createEvent()
        
        //createEventKokuchiPageBtn.titleLabel?.numberOfLines = 0
        //createEventKokuchiPageBtn.setTitle("イベント告知ページを\n確認", for: .normal)
        
        //createEventJoinPageBtn.titleLabel?.numberOfLines = 0
        //createEventJoinPageBtn.setTitle("イベント申込ページを\n確認", for: .normal)
        
        // スクロールの高さを変更
        //mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: 700)
        
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.detailLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-4 ,string: "入力内容からイベントを作成しました！", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize:self.iconSize)//
        
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
        
        //次へボタン
        // 枠線の色
        //self.eventCreateNextBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.createEventBtn.layer.borderWidth = 0
        // 角丸
        self.createEventBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.createEventBtn.layer.masksToBounds = true
        //背景色
        self.createEventBtn.backgroundColor = Util.EVENT_CREATE_NEXT_BTN_BG_COLOR
        //ラベルの枠を自動調節する
        self.createEventBtn.titleLabel!.adjustsFontSizeToFitWidth = true
        self.createEventBtn.titleLabel!.minimumScaleFactor = 0.3
        
        //前へボタン
        // 枠線の色
        //self.createBackBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.createBackBtn.layer.borderWidth = 0
        // 角丸
        self.createBackBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.createBackBtn.layer.masksToBounds = true
        //背景色
        self.createBackBtn.backgroundColor = Util.EVENT_CREATE_NEXT_BTN_BG_COLOR
        //ラベルの枠を自動調節する
        self.createBackBtn.titleLabel!.adjustsFontSizeToFitWidth = true
        self.createBackBtn.titleLabel!.minimumScaleFactor = 0.3
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createEventCheck(_ sender: Any) {
        //イベントの状態を公開・tiktok画面のイベントボタンの遷移先のイベントID（effect_flg02）の更新
        //modifyEventStatus($cast_id, $event_id, $open_status, $status)){
        var stringUrl = Util.URL_MODIFY_EVENT_STATUS
        stringUrl.append("?cast_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&event_id=")
        stringUrl.append(String(self.appDelegate.createEventId))
        stringUrl.append("&open_status=1&status=1")
        
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
                
                dispatchGroup.leave()
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //イベント作成用　値のクリア
            self.appDelegate.createEventId = 0//値渡しするため（作成されたID）
            // 選択肢(1枠のサシライブ時間)
            self.appDelegate.eventOneFrameTimeCd = 0
            self.appDelegate.starPriceRangeCd = 0//値渡しするため（価格）
            //self.appDelegate.starPriceRangeStr = ""//確認画面用
            // 選択肢(価格)
            self.appDelegate.eventPrice = 0//値渡しするため（価格）
            // 選択肢(獲得スター)
            self.appDelegate.eventStar = 0//値渡しするため（価格）
            // 選択肢(1回目イベントの実施日)
            self.appDelegate.event01YearCd = 0
            self.appDelegate.event01MonthCd = 0
            self.appDelegate.event01DayCd = 0
            // 選択肢(2回目イベントの実施日)
            self.appDelegate.event02YearCd = 0
            self.appDelegate.event02MonthCd = 0
            self.appDelegate.event02DayCd = 0
            //1回目イベントの始めたい時間
            self.appDelegate.eventStartTime01FirstFlg = 0
            self.appDelegate.event01StartTimeCd = 0
            //2回目イベントの始めたい時間
            self.appDelegate.eventStartTime02FirstFlg = 0
            self.appDelegate.event02StartTimeCd = 0
            //1回目イベントの枠数
            self.appDelegate.event01SumFrameCd = 0
            //2回目イベントの枠数
            self.appDelegate.event02SumFrameCd = 0
            //1回目イベントのインターバル
            self.appDelegate.event01IntervalCd = 0
            //2回目イベントのインターバル
            self.appDelegate.event02IntervalCd = 0
            //1回目イベントの予約開始日
            self.appDelegate.event01ReserveStartYearCd = 0
            self.appDelegate.event01ReserveStartMonthCd = 0
            self.appDelegate.event01ReserveStartDayCd = 0
            self.appDelegate.event01ReserveStartHourCd = 0//0から23
            self.appDelegate.event01ReserveStartMinuteCd = 0
            //2回目イベントの予約開始日
            self.appDelegate.event02ReserveStartYearCd = 0
            self.appDelegate.event02ReserveStartMonthCd = 0
            self.appDelegate.event02ReserveStartDayCd = 0
            self.appDelegate.event02ReserveStartHourCd = 0//0から23
            self.appDelegate.event02ReserveStartMinuteCd = 0
            //イベント特典
            self.appDelegate.eventNote = ""
            
            //アラート表示
            let alert = UIAlertController(title: "イベントの登録が完了しました！", message: "イベントの内容は「マイページ」の「イベント確認」メニューから確認することが出来ます。", preferredStyle: .alert)
            //ここから追加
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                //マイページへ
                //UtilToViewController.toMypageViewController()
                //マイページ＞確認ページへ
                UtilToViewController.toMyEventCheckViewController(animated_flg: false)
            }
            alert.addAction(ok)
            //ここまで追加
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //イベント告知ページ
    //static let URL_EVENT_URL = "https://test.monopol.jp/event/?id="
    //イベント申込ページ
    //static let URL_EVENT_APPLY_URL = "https://test.monopol.jp/event/apply.html?id="
    
    @IBAction func createEventKokuchiPage(_ sender: Any) {
        //イベント告知ページ
        //外部ブラウザでURLを開く
        var stringUrl = Util.URL_EVENT_URL
        stringUrl.append(String(self.appDelegate.createEventId))
        stringUrl.append("&cast_id=")
        stringUrl.append(String(user_id))
        print(stringUrl)
        let url = NSURL(string: stringUrl)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func createEventBack(_ sender: Any) {
        //前に戻るの処理
        //self.navigationController?.popViewController(animated: true)
        //画面遷移処理
        self.dismiss(animated: false, completion: nil)
    }
    
    /*
    @IBAction func createEventJoinPage(_ sender: Any) {
        //イベント申込ページ
        //外部ブラウザでURLを開く
        var stringUrl = Util.URL_EVENT_APPLY_URL
        stringUrl.append(String(self.appDelegate.createEventId))
        stringUrl.append("&cast_id=")
        stringUrl.append(String(user_id))
        print(stringUrl)
        let url = NSURL(string: stringUrl)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }*/
}
