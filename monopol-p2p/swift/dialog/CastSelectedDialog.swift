//
//  CastSelectedDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/08/13.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SkyWaySupport

class CastSelectedDialog: UIView,UIGestureRecognizerDelegate {
    let iconSize: CGFloat = 16.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //キャストの異常終了があった場合に1となる（キャストがタイムアウト時間になる前に返事があればゼロのまま）
    var requestTimer = Timer()
    var timerCount = 0
    
    var errorFlg = 0//1:ストリーマーからの拒否 2:リスナーがバツボタンでリクエスト取り消し 3:リスナーがタイムアウトでリクエスト取り消し
    
    //２重タップを防止する
    //var doubleClickFlg = 0//1:ロック中
    
    // データベースへの参照
    var rootRef = Database.database().reference()
    var conditionRef = DatabaseReference()
    var handle_status = DatabaseHandle()//キャストへのリクエスト結果用

    //共通で使用
    var infoLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //待ち時間カウントダウンの時間の表示形式（2:46:40）
        //self.formatter.unitsStyle = .positional
        //self.formatter.allowedUnits = [.minute,.hour,.second]

        //self.mainViewTapFlg = 0//デフォルトはタップできる
        //self.doubleClickFlg = 0//デフォルトはタップできる
        
        // backgroundColorを使って透過させる。
        mainView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        //mainView.backgroundColor = UIColor.clear
 //       notouchView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        
        mainView.isUserInteractionEnabled = true

        //共通ラベルの初期化
        self.infoLbl = UILabel(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0))
        // 最大行まで行数表示できるようにする
        self.infoLbl.numberOfLines = 0
        self.infoLbl.textColor = UIColor.white
        self.infoLbl.isHidden = true
        if(self.infoLbl.isDescendant(of: self)){
            //すでに追加(addsubview)済み
            //初期化しない
        }else{
            self.addSubview(self.infoLbl)
        }
    }

    //（リクエスト申請中の状態で）リクエストがタイムアウトしてダイアログを閉じるとき
    //type:0=下記以外
    //type:1=ストリーマーからの拒否
    //type:2=リスナーがバツボタンでリクエスト取り消し
    //type:3=リスナーがタイムアウトでリクエスト取り消し
    func timeoutCloseDialog(){
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        if(self.appDelegate.request_cast_id > 0){
            //let live_user_id:Int = appDelegate.request_live_user_id//現在ライブ中のユーザーID

            //リクエストの情報を更新する（バックグラウンドでのタイムアウト対策）
            //status = 1:待機中
            //自分のuser_idをゼロに更新
            UtilFunc.liveModifyStatusDoForTimeout(user_id:self.appDelegate.request_cast_id, status:1, target_live_user_id:user_id, live_user_id: 0)

            //ストリーマーのFireBaseのデータを削除する
            self.rootRef.child(Util.INIT_FIREBASE + "/"
                + String(self.appDelegate.request_cast_id) + "/" + String(user_id)).removeValue()
        }
        
        self.cancelRequestFromCast()
        
        //監視を解除すること
        self.conditionRef.child("status").removeObserver(withHandle: self.handle_status)

        //labelなどを削除
        for subview in self.subviews {
            if(subview.isMember(of: UILabel.self)){
                subview.removeFromSuperview()
            }
        }
    }
    
    //２回目の表示（リクエストを実際に送信する処理）
    //トータル待ち人数
    //トータル待ち時間
    func setDialogNext(cast_id:Int, user_id:Int, cast_name:String){
        //２回目のタップ

        //キャストのロック情報の件数を取得する（ロック情報の件数が返却される）
        //１回目と２回目で0.5秒おいて取得する。どちらもゼロの時だけ２回目は自分以外にロックがあるかを確認する
        var lock_count_check = 0
        
        //キャストのロック情報の件数を取得する（ロック情報の自分以外の件数が返却される）
        //GET:lock_type(1:配信リクエストロック),cast_id,user_id
        var stringUrl = Util.URL_GET_CAST_LOCK
        stringUrl.append("?lock_type=1&cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&user_id=")
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
                    let json = try decoder.decode(UtilStruct.ResultLockJson.self, from: data!)
                    //self.idCount = json.count

                    for obj in json.result {
                        lock_count_check = Int(obj.lock_count)!
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
            if(lock_count_check == 0){
                //ロックされていない場合のみ実行
                //ロックする
                UtilFunc.addCastLock(cast_id:cast_id, user_id:user_id, type:1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    //2.0秒後にさらにロック確認
                    //GET:lock_type(1:配信リクエストロック),cast_id,user_id
                    var stringUrl = Util.URL_GET_CAST_LOCK
                    stringUrl.append("?lock_type=1&cast_id=")
                    stringUrl.append(String(cast_id))
                    stringUrl.append("&user_id=")
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
                                let json = try decoder.decode(UtilStruct.ResultLockJson.self, from: data!)
                                //self.idCount = json.count
                                
                                for obj in json.result {
                                    lock_count_check = Int(obj.lock_count)!
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
                        if(lock_count_check == 0){
                            //ロックされていない場合のみ実行
                            //ロックの解除もlockCheckOkで行う
                            self.lockCheckOk(cast_id:cast_id, user_id:user_id)
                        }else{
                            //ロックされている場合(自分のロック情報削除)
                            //UtilFunc.deleteCastLock(cast_id:cast_id, user_id:user_id, type:1)
                            
                            //何か出力する？
                            self.cancelRequestFromCast()
                            //監視を解除すること(念のため)
                            self.conditionRef.child("status").removeObserver(withHandle: self.handle_status)
                        }
                    }
                }
            }else{
                //ロックされている場合(自分のロック情報削除)
                //UtilFunc.deleteCastLock(cast_id:cast_id, user_id:user_id, type:1)
                
                //何か出力する？
                self.cancelRequestFromCast()
                //監視を解除すること(念のため)
                self.conditionRef.child("status").removeObserver(withHandle: self.handle_status)
            }
        }
    }
    
    //ロックのチェックがOKだった場合に実行する（通常のリクエスト申請処理）
    func lockCheckOk(cast_id:Int, user_id:Int){
        //ロックされている場合(自分のロック情報削除)
        //UtilFunc.deleteCastLock(cast_id:cast_id, user_id:user_id, type:1)
        UtilFunc.deleteCastLock(cast_id:0, user_id:user_id, type:1)
        
        //予約数がMAX値より大きい場合は、予約できないこととする
        //キャストのランクを取得
        //let cast_rank = self.appDelegate.request_cast_rank
        
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //1度目のタップで配信までの時間を初期化しておく
        //self.appDelegate.reserve_wait_time = Util.INIT_RESERVE_WAIT_SECONDS
        
        //self.normalDelPointLbl.text = "消費コイン:" + String(self.live_coin)
        //let strDelPoint = "消費コイン:" + String(Int(self.appDelegate.live_pay_coin))
        
        /*
         //配信ランクに関する必要なコイン、得られる配信ポイントを保存しておく
         //キャストが得られるポイント(最初の5分枠で得られるポイント)
         self.appDelegate.get_live_point = self.appDelegate.get_live_point
         //延長時キャストが得られるポイント
         self.appDelegate.ex_get_live_point = self.appDelegate.ex_get_live_point
         //消費するコイン
         self.appDelegate.live_pay_coin = self.appDelegate.live_pay_coin
         //消費するコイン(延長時)
         self.appDelegate.live_pay_ex_coin = self.appDelegate.live_pay_ex_coin
         */
        //復帰時のために必要
        UserDefaults.standard.set(self.appDelegate.init_seconds, forKey: "live_sec")
        UserDefaults.standard.set(self.appDelegate.get_live_point, forKey: "get_live_point")
        UserDefaults.standard.set(self.appDelegate.ex_get_live_point, forKey: "ex_get_live_point")
        UserDefaults.standard.set(self.appDelegate.live_pay_coin, forKey: "live_pay_coin")
        UserDefaults.standard.set(self.appDelegate.live_pay_ex_coin, forKey: "live_pay_ex_coin")
        UserDefaults.standard.set(self.appDelegate.min_reserve_coin, forKey: "min_reserve_coin")
        //UserDefaults.standard.set(self.appDelegate.cancel_coin, forKey: "cancel_coin")
        //UserDefaults.standard.set(self.appDelegate.cancel_get_star, forKey: "cancel_get_star")
        
        if(self.appDelegate.request_password == "0" || self.appDelegate.request_password == ""){
            //パスワードなしの場合
            //通常リクエストの場合
            self.requestDo(cast_id:cast_id)
            
            /*
            //2度目のタップ
            if(temp_reserve_last_count == 0){
                //通常リクエストの場合
                self.requestDo(cast_id:cast_id)
            }else{
                //予約が廃止になったので、通常リクエストの失敗ダイアログを表示
                //直前ですでに配信中だった時
                /***************************/
                //ラベル作成(重要)
                /***************************/
                self.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                
                self.infoLbl.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_001, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
                
                // テキストを中央寄せ
                //self.infoLbl.textAlignment = NSTextAlignment.center
                self.infoLbl.font = UIFont.boldSystemFont(ofSize: 15)
                self.infoLbl.sizeToFit()
                self.infoLbl.center = self.center
                //最前面へ
                self.infoLbl.isHidden = false
                self.bringSubviewToFront(self.infoLbl)
                /***************************/
                //ラベル作成(ここまで)
                /***************************/
                
                //3秒後くらいに画面を閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    //self.closeDialog()
                    //共通ラベルを非表示
                    self.infoLbl.isHidden = true
                    
                    //右上のバツボタンを表示に戻しておく
                    self.closeBtn.isHidden = false
                    
                    //このダイアログ(画面)を閉じる
                    //                            self.mainViewTapFlg = 0
                    //                            self.doubleClickFlg = 0
                    
                    //self.appDelegate.request_count_num = 0
                    self.appDelegate.request_password = "0"
                    self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
                    //self.dismiss(animated: false, completion: nil)
                    self.isHidden = true
                })
            }*/
        }
    }
    
    //画面を閉じる
    @IBAction func closeBtnTap(_ sender: Any) {
        //self.closeDialog()
        //type:2=リスナーがバツボタンでリクエスト取り消し
        if(self.errorFlg == 0){
            self.errorFlg = 2
        }
        self.timeoutCloseDialog()
    }

    //この画面から離れた場合(このダイアログを呼び出しているUIViewControllerから離れた場合)
    // 通知の解除
    deinit {
        print("この画面から離れた?")
        
        // （タイムアウト用の）タイマーを無効にする
        UtilFunc.stopTimer(timer:self.requestTimer)
        //self.timerCount = 0
        
        //待ち時間のタイマーストップ
        //UtilFunc.stopTimer(timer:self.reserveWaitTimer)
        //self.appDelegate.reserve_wait_time = Util.INIT_RESERVE_WAIT_SECONDS
        //self.appDelegate.reserve_wait_time = 0
        
        //ここでも念の為、監視を解放
        //self.conditionRef.removeObserver(withHandle: self.handle_alert)////キャストの異常終了・通報で終了の取得用
        //self.conditionRef.removeObserver(withHandle: self.handle_alert_password)//キャストの異常終了・通報で終了の取得用(パスワードつきの場合)
        //self.conditionRef.removeObserver(withHandle: self.handle_request)
        //監視を解除すること
        self.conditionRef.child("status").removeObserver(withHandle: self.handle_status)
        
        //self.conditionRef.removeObserver(withHandle: self.handle_reserve_wait_time)
        //self.conditionRef.removeObserver(withHandle: self.handle_reserve_wait_time_password)
        
//        NotificationCenter.default.removeObserver(self)
/*
        //SKYWAYから切断
        if(self.peer != nil){
            //if(self.app_Delegate.peer!.isDisconnected == false){
            self.peer!.disconnect()
            self.peer!.destroy()
            //self.app_Delegate.peer = nil
            //}
        }
 */
    }
    
    //通常の配信リクエスト
    func requestDo(cast_id:Int){
        //エラーフラグの初期化
        self.errorFlg = 0
        
        //すでにFireBaseにデータが存在するかをチェック
        //Firebaseにすでにリクエストデータがあるということは、リクエスト申請中か、または配信中である。
        let conditionRef = self.rootRef.child(Util.INIT_FIREBASE
                    + "/" + String(cast_id))
                conditionRef.observeSingleEvent(of: .value, with: { (snapshot) in

                    if(snapshot.exists() == true){
                        //UtilLog.printf(str:"すでにデータがある(キャスト側)")
                        //右上のバツボタンを非表示(重要)
                        //self.closeBtn.isHidden = true
                        
                        /***************************/
                        //ラベル作成(重要)
                        /***************************/
                        self.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                        
                        self.infoLbl.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_001, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
                        
                        // テキストを中央寄せ
                        //self.infoLbl.textAlignment = NSTextAlignment.center
                        self.infoLbl.font = UIFont.boldSystemFont(ofSize: 15)
                        self.infoLbl.sizeToFit()
                        self.infoLbl.center = self.center
                        
                        if(self.infoLbl.isDescendant(of: self)){
                            //すでに追加(addsubview)済み
                            //初期化しない
                        }else{
                            self.addSubview(self.infoLbl)
                        }
                        
                        //最前面へ
                        self.infoLbl.isHidden = false
                        self.bringSubviewToFront(self.infoLbl)
                        /***************************/
                        //ラベル作成(ここまで)
                        /***************************/
                        
                        //3秒後くらいに画面を閉じる
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                            //self.closeDialog()
                            //共通ラベルを非表示
                            self.infoLbl.isHidden = true
                            
                            //右上のバツボタンを表示に戻しておく
                            self.closeBtn.isHidden = false
                            
                            self.appDelegate.request_password = "0"
                            self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
                            //self.dismiss(animated: false, completion: nil)
                            self.isHidden = true
                        })
                        
                        return
                    }else{
                        //データがまだない場合
                        //選択したキャストへリクエストを送る

                        //自分のuser_idを取得
                        let user_id = UserDefaults.standard.integer(forKey: "user_id")
                        let myName = UserDefaults.standard.string(forKey: "myName")
                        let user_photo_flg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
                        let user_photo_name = UserDefaults.standard.string(forKey: "myPhotoName")
                        
                        //20200606追加
                        //申請直後リスナーが落ちたときのストリーマーがロックされてしまう問題
                        UtilFunc.addCastLock(cast_id:cast_id, user_id:user_id, type:2)
                        
                        //リクエストの情報を更新する（バックグラウンドでのタイムアウト対策）
                        //status = 1:待機中
                        UtilFunc.liveModifyStatusDoForTimeout(user_id:cast_id, status:1, target_live_user_id:0, live_user_id: user_id)
                        
                        //リクエスト履歴に追加
                        //GET:user_id, listener_user_id, type, request_status, status
                        //type=1:リスナーによる配信リクエスト
                        //status=3:未読
                        //request_status=3:リクエストしてそのまま
                        UtilFunc.liveRequestRirekiDo(type:1, user_id:cast_id, listener_user_id: user_id, request_status: 3, status: 3)
                        
                        //待機時/リクエスト送信のタイムスタンプ
                        //1:待機スタート 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）
                        UtilFunc.addActionRireki(user_id: cast_id, listener_id: user_id, type: 6, value01:0, value02:0)
                        
                        //キャストへリアルタイム通知(キャストがリアルタイム通知をオンにしているときに処理)
                        //UtilFunc.liveRequestDo(type:Int, from_user_id:Int, to_user_id: Int, token: String)
                        UtilFunc.liveRequestDo(type:1
                            , from_user_id: user_id
                            , to_user_id: cast_id
                            , token: Util.serverKey)
                        
                        self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE + "/"
                            + String(cast_id) + "/" + String(user_id))
                        
                        self.conditionRef.setValue(["frame_count": 1,
                                                    "live_time": 0,
                                                    "status": 1,
                                                    "status_listener":0,
                                                    "status_streamer":0,
                                                    "user_name": myName!,
                                                    "user_id": user_id,
                                                    "user_photo_flg": user_photo_flg,
                                                    "user_photo_name": user_photo_name!,
                                                    "request_screenshot_name": "0",
                                                    "request_screenshot_flg": 0,
                                                    "cast_id": cast_id,
                                                    "cast_live_point": 0,
                                                    "date": UtilFunc.getNowDate(pattern:1),
                                                    "reserve_wait_time":self.appDelegate.init_seconds,
                                                    "present_star":0,
                                                    "present_point":0,
                                                    "cast_add_star":0,
                                                    "cast_add_point":0])
                        
                        /***************************/
                        //ラベル作成
                        /***************************/
                        self.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                        // テキストを中央寄せ
                        self.infoLbl.attributedText = UtilFunc.getInsertIconString(string: "サシライブ申請中...", iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
                        //self.infoLbl.textAlignment = NSTextAlignment.center
                        self.infoLbl.font = UIFont.boldSystemFont(ofSize: 15)
                        self.infoLbl.sizeToFit()
                        self.infoLbl.center = self.center
                        
                        if(self.infoLbl.isDescendant(of: self)){
                            //すでに追加(addsubview)済み
                            //初期化しない
                        }else{
                            self.addSubview(self.infoLbl)
                        }
                        
                        //最前面へ
                        self.infoLbl.isHidden = false
                        self.bringSubviewToFront(self.infoLbl)
                        /***************************/
                        //ラベル作成(ここまで)
                        /***************************/
                        
                        // タイマーの設定（1秒間隔でメソッド「timerCall」を呼び出す）
                        self.timerCount = 0
                        self.requestTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerCall), userInfo: nil, repeats: true)
                        
                        //右上のクローズボタンをここで表示
                        self.closeBtn.isHidden = false
                        
                        //経過時間を初期化
                        self.appDelegate.count = 0
                        
                        /*************************/
                        //statusだけを監視
                        /*************************/
                        //elf.conditionRef.child("status").observeSingleEvent(of: .value, with: { snap in
                        self.handle_status = self.conditionRef.child("status").observe(.value) { (snap: DataSnapshot) in
                            
                            if(snap.exists() == false){
                                //UtilLog.printf(str:"すでにデータがない(キャスト側)")
                                //拒否された場合
        
                                //監視を解除すること
                                self.conditionRef.child("status").removeObserver(withHandle: self.handle_status)
                                       
                                //type:1=ストリーマーからの拒否
                                if(self.errorFlg == 0){
                                    self.errorFlg = 1
                                }
                                self.cancelRequestFromCast()
                                
                                //20200606追加
                                //申請直後リスナーが落ちたときのストリーマーがロックされてしまう問題
                                UtilFunc.deleteCastLock(cast_id:cast_id, user_id:user_id, type:2)
                                
                                return
                            }

                            let status = snap.value as! Int
                            
                            if(status == 99){
                                //承認された(キャストと繋がりました!と1秒ほど表示)
                                self.conditionRef.removeObserver(withHandle: self.handle_status)
                               
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    // 1.0秒後に実行したい処理
                                    print("キャストと繋がりました!")
                                    //print(self.appDelegate.request_count_num)
                                    // タイマーを無効にする
                                    self.timerCount = 0
                                    self.requestTimer.invalidate()
                                    
                                    //20200606追加
                                    //申請直後リスナーが落ちたときのストリーマーがロックされてしまう問題
                                    UtilFunc.deleteCastLock(cast_id:cast_id, user_id:user_id, type:2)
                                    
                                    UtilToViewController.toMediaConnectionViewController()
                                }
                                //この時点で監視を解除すること
                                self.conditionRef.child("status").removeObserver(withHandle: self.handle_status)
                            }
                        }
            }
        })
    }
    
    // タイマーで呼び出されるメソッド（65秒でタイムアウト）
    @objc func timerCall() {
        timerCount += 1
        print("timerCount: \(timerCount)")
        if(timerCount >= Util.REQUEST_TIMEOUT_SEC){
            // タイマーを無効にする
            self.requestTimer.invalidate()
            
            //type:1=ストリーマーからの拒否
            //type:2=リスナーがバツボタンでリクエスト取り消し
            //type:3=リスナーがタイムアウトでリクエスト取り消し
            if(self.errorFlg == 0){
                self.errorFlg = 3
            }
            self.timeoutCloseDialog()
            
            //ラベルの非表示
            self.infoLbl.isHidden = true
            print("Timerは無効になりました。")
        }else if(timerCount == Util.REQUEST_TIMEOUT_SEC - 5){
            //labelなどを削除
            for subview in self.subviews {
                if(subview.isMember(of: UILabel.self)){
                    subview.removeFromSuperview()
                }
            }
            
            self.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
            
            self.infoLbl.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_002, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
            
            // テキストを中央寄せ
            //self.infoLbl.textAlignment = NSTextAlignment.center
            self.infoLbl.font = UIFont.boldSystemFont(ofSize: 15)
            self.infoLbl.sizeToFit()
            self.infoLbl.center = self.center
            
            if(self.infoLbl.isDescendant(of: self)){
                //すでに追加(addsubview)済み
                //初期化しない
            }else{
                self.addSubview(self.infoLbl)
            }
            
            //最前面へ
            self.infoLbl.isHidden = false
            self.bringSubviewToFront(self.infoLbl)
        }else{
        }
    }
    
    //ストリーマーから拒否・またはキャストが落ちた時などに呼ぶ
    //type:0=下記以外
    //type:1=ストリーマーからの拒否
    //type:2=リスナーがバツボタンでリクエスト取り消し
    //type:3=リスナーがタイムアウトでリクエスト取り消し
    func cancelRequestFromCast(){
        // （タイムアウト用の）タイマーを無効にする
        UtilFunc.stopTimer(timer:self.requestTimer)

        //自分のロック情報削除
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        UtilFunc.deleteCastLock(cast_id:0, user_id:user_id, type:1)
        
        /***************************/
        //ラベル作成(重要)
        /***************************/
        self.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
        
        if(self.errorFlg == 0 || self.errorFlg == 1){
            //ストリーマーからの拒否
            self.infoLbl.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_001, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
        }else if(self.errorFlg == 2){
            //type:2=リスナーがバツボタンでリクエスト取り消し
            self.infoLbl.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_007, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
        }else if(self.errorFlg == 3){
            //type:3=リスナーがタイムアウトでリクエスト取り消し
            self.infoLbl.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_002, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
        }
        
        // テキストを中央寄せ
        //self.infoLbl.textAlignment = NSTextAlignment.center
        self.infoLbl.font = UIFont.boldSystemFont(ofSize: 15)
        self.infoLbl.sizeToFit()
        self.infoLbl.center = self.center
        
        if(self.infoLbl.isDescendant(of: self)){
            //すでに追加(addsubview)済み
            //初期化しない
        }else{
            self.addSubview(self.infoLbl)
        }
        
        //最前面へ
        self.infoLbl.isHidden = false
        self.bringSubviewToFront(self.infoLbl)
        /***************************/
        //ラベル作成(ここまで)
        /***************************/
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // 3.0秒後に実行したい処理
            //ラベルの非表示
            self.infoLbl.isHidden = true
            
            //右上のバツボタンを表示に戻しておく
            self.closeBtn.isHidden = false
            
            //タップの回数クリア
            //UserDefaults.standard.set(0, forKey: "selectedIndexCount")
            //self.appDelegate.request_count_num = 0
            self.appDelegate.request_password = "0"
            self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
            self.isHidden = true
            //self.removeFromSuperview()
         }
    }
}
