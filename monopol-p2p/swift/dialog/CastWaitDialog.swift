//
//  CastWaitDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/05/17.
//  Copyright © 2018年 worldtrip. All rights reserved.
//
import UIKit
import Firebase
import FirebaseDatabase
//import UserNotifications

class CastWaitDialog: UIView {
    let iconSize: CGFloat = 16.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //復帰関連のラベル[現在通信が不安定です。]的なメッセージ
    //let re_connect_label = UILabel(frame: CGRect(x:0, y:0, width:300, height:0))
    //let re_connect_label = UILabel(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0))
    var re_connect_label: UILabel!
    @IBOutlet weak var allCoverMessage: UIView!//メッセージ用
    @IBOutlet weak var allCoverRequest: UIView!//リクエストダイアログ用
    
    //最上位に配置されるラベル
    @IBOutlet weak var topInfoLabel: UILabel!

    var user_id: Int = 0//自分のID
    var status: Int = 0//status = 1:申請中 2:申請したけど拒否された 3:申請が取り消された 99:接続が承認された
    
    var get_user_name: String!
    var get_user_photo_flg: Int = 0
    var get_user_photo_name: String!
    var get_user_id: Int = 0
    var get_cast_id: Int = 0
    
    // データベースへの参照
    var rootRef = Database.database().reference()
    
    //キャスト側のシェア機能関連
    //@IBOutlet weak var castShareMainView: UIView!
    
    //配信開始・キャンセル
    @IBOutlet weak var liveStartBtn: UIButton!
    @IBOutlet weak var liveDenyBtn: UIButton!
    
    //右上の待機中のところ
    @IBOutlet weak var statusLbl: UILabel!

    //配信待機を解除ボタン
    @IBOutlet weak var cancelWaitBtn: UIButton!
  
    //1枠で配信待機中!!のところ
    @IBOutlet weak var numLabel: UILabel!
    //1枠で配信待機中!!のところのView
    @IBOutlet weak var waitDialogView: UIView!
    
    //**から配信リクエストがありました！のところ
    @IBOutlet weak var requestByUserView: UIView!
    @IBOutlet weak var requestUserLbl: UILabel!
    //リクエストしたユーザーの画像部分
    @IBOutlet weak var userImageView: EnhancedCircleImageView!
    
    //配信開始、配信拒否のところ
    @IBOutlet weak var startDoView: UIView!
    //カウントダウンの数字のところ
    @IBOutlet weak var countDownLbl: UILabel!
    
    /////////////////////////
    //ライブ配信情報関連
    /////////////////////////
    //@IBOutlet weak var rirekiTextView: UITextView!
    
    /*
    let data = ["・ランクアップ！>> R47",
                "・ヤジさんヤジさんヤジさんヤジさんヤジさんヤジさんがライブ",
                "・まつさんからスクショリクエストがありました"
    ]
     */
    
    /*
    //予約申請時のチェック用
    struct ReserveCheckResult: Codable {
        let reserve_user_id: String
        let reserve_peer_id: String
        let reserve_user_name: String
        let reserve_photo_flg: String
        let reserve_photo_name: String
        let reserve_flg: String
        let reserve_status: String
    }
    struct ResultReserveCheckJson: Codable {
        let count: Int
        let result: [ReserveCheckResult]
    }
    */
    
    struct InfoResult: Codable {
        let id: String
        let type: String
        let notes: String
        let ins_time: String
    }
    
    struct ResultJson: Codable {
        let count: Int
        let result: [InfoResult]
    }
    var idCount:Int=0
    var liveInfoList: [(id:String, type:String, notes:String, ins_time:String)] = []

    //予約数の取得用
    struct ReserveCountResult: Codable {
        let reserve_count: String
    }
    struct ResultReserveCountJson: Codable {
        let count: Int
        let result: [ReserveCountResult]
    }
    
    //@IBOutlet weak var liveInfoMainView: UIView!
    @IBOutlet weak var downLiveInfoTableView: UITableView!
    //チャットやりとりのリストの部分
    @IBOutlet weak var messageTableView: UITableView!
    
    //リクエスト申請のタイマー（ストリーマー側）
    var requestTimer = Timer()
    var timerCount = 0
    //1:サシライブ申請時、リスナーの最終応答を待っている状態（タイムアウトタイマーの中でのみ使用）
    var requestWaitFlg = 0
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        print("フォアグラウンド時ここ通る")
        //自分のID = cast_idを取得
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        /////////////////////////
        //シェア関連
        /////////////////////////
        //self.castShareMainView.isHidden = true
        // 角丸
        //self.castShareMainView.layer.cornerRadius = 16
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //self.castShareMainView.layer.masksToBounds = true
        
        /////////////////////////
        //ライブ配信情報関連
        /////////////////////////
        // 角丸
        //liveInfoMainView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //liveInfoMainView.layer.masksToBounds = true
        
        //待機時間のタイマー設定
        //self.countLiveWait = 0
        //let wait_minutes = UserDefaults.standard.integer(forKey: "liveWaitTime")
        //let wait_seconds = wait_minutes * 60
        
        //タイマー表示形式："1:00:01"
        //formatter.unitsStyle = .positional
        //formatter.allowedUnits = [.minute,.hour,.second]
        
        /*
        //もしタイマーが実行中だったらスタートしない
        if self.timerLiveWait?.isValid == true {
            //何も処理しない
        }else{
            //タイマーをスタート
            self.timerLiveWait = Timer.scheduledTimer(timeInterval:1.0,
                                                      target: self,
                                                      selector: #selector(self.timerInterruptWaitLive(_:)),
                                                      userInfo: nil,
                                                      repeats: true)
        }
        */
        
        //ラベルの枠を自動調節する
        //self.backWaitLbl.adjustsFontSizeToFitWidth = true
        //self.backWaitLbl.minimumScaleFactor = 0.3
        
        //データがFirebaseにあるかチェック
        let conditionRefTap = self.rootRef.child(Util.INIT_FIREBASE
            + "/"
            + String(self.user_id))
        conditionRefTap.observeSingleEvent(of: .value, with: { (snapshotTap) in
            if(snapshotTap.exists() == false){
                //データ（リクエストなど）がない場合
                // 枠線の色
                self.liveStartBtn.layer.borderColor = UIColor.lightGray.cgColor
                // 枠線の太さ
                self.liveStartBtn.layer.borderWidth = 1
                // 角丸
                self.liveStartBtn.layer.cornerRadius = 8
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.liveStartBtn.layer.masksToBounds = true
                
                // 枠線の色
                self.liveDenyBtn.layer.borderColor = UIColor.lightGray.cgColor
                // 枠線の太さ
                self.liveDenyBtn.layer.borderWidth = 1
                // 角丸
                self.liveDenyBtn.layer.cornerRadius = 8
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.liveDenyBtn.layer.masksToBounds = true
                
                // 角丸
                //livePointView.layer.cornerRadius = 6
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                //livePointView.layer.masksToBounds = true

                // 角丸
                //waitTimeLbl.layer.cornerRadius = 6
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                //waitTimeLbl.layer.masksToBounds = true
                
                // 角丸
                self.waitDialogView.layer.cornerRadius = 10
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.waitDialogView.layer.masksToBounds = true
                
                // 角丸
                //backDialogView.layer.cornerRadius = 10
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                //backDialogView.layer.masksToBounds = true
                
                // 角丸
                self.requestByUserView.layer.cornerRadius = 10
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.requestByUserView.layer.masksToBounds = true
                
                // 角丸
                self.startDoView.layer.cornerRadius = 10
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.startDoView.layer.masksToBounds = true
                
                // 角丸
                //startDoViewReserve.layer.cornerRadius = 10
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                //startDoViewReserve.layer.masksToBounds = true
                
                // 角丸
                self.statusLbl.layer.cornerRadius = 8
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.statusLbl.layer.masksToBounds = true
                
                // 角丸
                self.cancelWaitBtn.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.cancelWaitBtn.layer.masksToBounds = true
                
                // 角丸
                //backWaitBtn.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                //backWaitBtn.layer.masksToBounds = true
                
                //ラベルの枠を自動調節する
                self.requestUserLbl.adjustsFontSizeToFitWidth = true
                self.requestUserLbl.minimumScaleFactor = 0.3
                
                //配信待機中!!のところ
                //let frame_num:Int = appDelegate.waitWaku!
                //numLabel.text = String(frame_num) + "枠で配信待機中!!"
                
                //リクエストが来た時に表示
                self.allCoverRequest.isHidden = true
                self.requestByUserView.isHidden = false
                self.startDoView.isHidden = false
                //startDoViewReserve.isHidden = true
                self.topInfoLabel.isHidden = true
                
                //配信情報の更新
                //self.getLiveInfoList()
            }
        })
    }

    func requestDialogDo(){
        //自分へのリクエストの場合
        if(self.status == 1 && self.get_user_id > 0){
            //一旦メッセージをクリア
            self.delMessageDo()
            
            //リクエスト申請中の場合のみ実行
            self.requestUserLbl.text = self.get_user_name.toHtmlString() + "さんから配信リクエストがありました！"
            
            self.requestWaitFlg = 0//リスナー応答フラグを初期化
            
            if(self.get_user_photo_flg == 1){
                //写真を設定ずみ
                //let photoUrl = "user_images/" + String(self.get_user_id) + "_profile.jpg"
                let photoUrl = "user_images/" + String(self.get_user_id) + "/" + self.get_user_photo_name + "_profile.jpg"
                //画像キャッシュを使用
                self.userImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            }else{
                // UIImageをUIImageViewのimageとして設定
                self.userImageView.image = UIImage(named:"no_image")
            }
            
            //UtilLog.printf(str:"aaaa-aaaa(キャスト側)")
            // タイマーの設定（1秒間隔でメソッド「timerCall」を呼び出す）
            self.timerCount = 0
            //タイマーを動かす
            if(self.requestTimer.isValid == true){
                //何も処理しない
            }else{
                self.requestTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerCall), userInfo: nil, repeats: true)
            }
            self.countDownLbl.isHidden = true
            
            //画面を操作させないように覆う
            //print("cover 111")
            self.allCoverMessage.isHidden = true
            self.allCoverRequest.isHidden = false
            self.requestByUserView.isHidden = false
            self.startDoView.isHidden = false
            //self.startDoViewReserve.isHidden = true
            self.topInfoLabel.isHidden = true
            
            //ダイアログが最前面へ
            self.bringSubviewCommonDo(type:1)
        }
    }
    
    /****************************************/
    //シェア関連
    /****************************************/
    @IBAction func tapShareBtn(_ sender: Any) {
        //self.castShareMainView.isHidden = false
        //最前面へ
        //self.bringSubview(toFront:self.castShareMainView)
        UtilFunc.shareDo(parentVC: self.parentViewController()!, parentView:self, url:UtilStr.SHARE_URL, str01: UtilStr.SHARE_STR01, str02:UtilStr.SHARE_STR02)
    }
    
    /*
    @IBAction func tapShareCanselBtn(_ sender: Any) {
        //キャンセルボタン
        self.castShareMainView.isHidden = true
    }
    */
    /****************************************/
    //シェア関連(ここまで)
    /****************************************/
    
    @IBAction func liveStart(_ sender: Any) {
        //配信開始ボタンを押した時
        //データがFirebaseにあるかチェック
        let conditionRefTap = self.rootRef.child(Util.INIT_FIREBASE
            + "/"
            + String(self.user_id) + "/" + String(self.get_user_id))
        conditionRefTap.observeSingleEvent(of: .value, with: { (snapshotTap) in

            if(snapshotTap.exists() == false){
                //ない場合＞すでにタイムアウトorリスナーがキャンセル済みのため、何もしない。
                //「リクエスト申請がキャンセルされました。」のメッセージ
                UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_COMMON_004, vc:self.parentViewController()!, sec:3.0)
            }else{
                //リスナー返答待ち時間(最大20秒ほど画面を暗くしてリスナーの応答を待つ)
                let waitSecTemp = 20
                self.timerCount = Util.REQUEST_TIMEOUT_SEC - waitSecTemp
                //self.timerCount = 0
                self.requestWaitFlg = 1//リスナーからの最終応答を待つ状態に
                
                //画面を操作させないように覆う
                self.allCoverMessage.isHidden = false
                self.allCoverRequest.isHidden = true
                //self.re_connect_label.isHidden = false
                self.bringSubviewToFront(self.allCoverMessage)
                
                /***************************/
                //ラベル作成
                /***************************/
                self.topInfoLabel.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                
                self.topInfoLabel.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_006, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
                
                // テキストを中央寄せ
                //self.infoLbl.textAlignment = NSTextAlignment.center
                self.topInfoLabel.font = UIFont.boldSystemFont(ofSize: 16)
                self.topInfoLabel.sizeToFit()
                self.topInfoLabel.center = self.center
                //最前面へ
                self.topInfoLabel.isHidden = false
                self.bringSubviewToFront(self.topInfoLabel)
                /***************************/
                //ラベル作成(ここまで)
                /***************************/
 
                //status 1:申請中 2:申請したけど拒否された 99:接続が承認された
                let conditionRef = self.rootRef.child(Util.INIT_FIREBASE
                    + "/"
                    + String(self.user_id) + "/" + String(self.get_user_id))
                let data = ["status": 99, "effect_id": self.appDelegate.live_effect_id]
                conditionRef.updateChildValues(data)

                //相手の名前を共通変数に格納しておく
                self.appDelegate.live_target_user_name = self.get_user_name
                self.appDelegate.live_target_user_id = self.get_user_id
            }
        })
    }
    
    @IBAction func liveDeny(_ sender: Any) {
        //配信拒否のボタンを押した時
        //データがFirebaseにあるかチェック
        let conditionRefTap = self.rootRef.child(Util.INIT_FIREBASE
            + "/"
            + String(self.user_id))
        conditionRefTap.observeSingleEvent(of: .value, with: { (snapshotTap) in

            if(snapshotTap.exists() == false){
                //ない場合＞すでにタイムアウトorリスナーがキャンセル済みのため、何もしない。
                self.allCoverMessage.isHidden = true
                self.allCoverRequest.isHidden = true
                self.re_connect_label.isHidden = true
                self.topInfoLabel.isHidden = true
            }else{
                self.liveDenyDo()
            }
        })
    }

    func liveDenyDo() {
        //配信拒否のボタンを押した時
        
        // タイマーを無効にする
        self.requestTimer.invalidate()
        self.requestWaitFlg = 0
        
        //リクエスト状態の更新（リクエスト後に配信までしたのかなどの状態>最新の一件のみ更新）
        //GET:user_id, listener_user_id, request_status
        //request_status 1:リクエスト後配信 2:リクエスト後キャストが拒否 3:リクエストしてそのまま
        UtilFunc.modifyLiveRequestStatusByOne(user_id:self.user_id, listener_user_id:self.get_user_id, request_status:2)
        
        self.allCoverMessage.isHidden = true
        self.allCoverRequest.isHidden = true
        self.re_connect_label.isHidden = true
        self.topInfoLabel.isHidden = true

        //いったんキャストのFireBaseのデータを削除する
        self.rootRef.child(Util.INIT_FIREBASE + "/" + String(self.user_id)).removeValue()
    }
    
    // タイマーで呼び出されるメソッド（65秒でタイムアウト）
    @objc func timerCall() {
        timerCount += 1
        print("timerCount: \(timerCount)")
        
        let conditionRefTap = self.rootRef.child(Util.INIT_FIREBASE
            + "/"
            + String(self.user_id))
        
        if(timerCount >= Util.REQUEST_TIMEOUT_SEC){
            // タイマーを無効にする
            self.requestTimer.invalidate()
            
            //配信拒否のボタンを押した時と同じ処理
            
            //20200606追加
            //申請直後リスナーが落ちたときのストリーマーがロックされてしまう問題
            UtilFunc.deleteCastLock(cast_id:self.user_id, user_id:0, type:2)
            
            //データがFirebaseにあるかチェック
            conditionRefTap.observeSingleEvent(of: .value, with: { (snapshotTap) in
                if(snapshotTap.exists() == false){
                    //ない場合＞すでにタイムアウトorリスナーがキャンセル済みのため、何もしない。
                    self.allCoverMessage.isHidden = true
                    self.allCoverRequest.isHidden = true
                    self.topInfoLabel.isHidden = true
                    
                    self.requestWaitFlg = 0
                    
                }else if(self.requestWaitFlg == 0){
                    //リクエストデータがある場合＞リスナーが何らかの異常で終わった

                    /***************************/
                    //ラベル作成(重要)
                    /***************************/
                    self.topInfoLabel.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                    
                    self.topInfoLabel.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_005, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
                    
                    // テキストを中央寄せ
                    //self.infoLbl.textAlignment = NSTextAlignment.center
                    self.topInfoLabel.font = UIFont.boldSystemFont(ofSize: 16)
                    self.topInfoLabel.sizeToFit()
                    self.topInfoLabel.center = self.center
                    //最前面へ
                    self.topInfoLabel.isHidden = false
                    self.bringSubviewToFront(self.topInfoLabel)
                    /***************************/
                    //ラベル作成(ここまで)
                    /***************************/

                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        // 5.0秒後に実行したい処理
                        self.liveDenyDo()
                    }
                }else{
                    //self.requestWaitFlg = 0
                    
                    UtilFunc.logRirekiDo(type:11, user_id:self.user_id, view_name:"CastWaitDialog", value01:"リクエスト申請タイムオーバー時")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 35.0) {
                        // 35.0秒後に実行したい処理
                        if(self.requestWaitFlg == 1){
                            /***************************/
                            //ラベル作成(重要)
                            /***************************/
                            self.topInfoLabel.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                            //タイムアウトのメッセージ出力
                            self.topInfoLabel.attributedText = UtilFunc.getInsertIconString(string: UtilStr.ERROR_SELECT_COMMON_005, iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
                            
                            // テキストを中央寄せ
                            //self.infoLbl.textAlignment = NSTextAlignment.center
                            self.topInfoLabel.font = UIFont.boldSystemFont(ofSize: 16)
                            self.topInfoLabel.sizeToFit()
                            self.topInfoLabel.center = self.center
                            //最前面へ
                            self.topInfoLabel.isHidden = false
                            self.bringSubviewToFront(self.topInfoLabel)
                            /***************************/
                            //ラベル作成(ここまで)
                            /***************************/
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                //リクエスト状態の更新（リクエスト後に配信までしたのかなどの状態>最新の一件のみ更新）
                                //GET:user_id, listener_user_id, request_status
                                //request_status 1:リクエスト後配信 2:リクエスト後キャストが拒否 3:リクエストしてそのまま
                                UtilFunc.modifyLiveRequestStatusByOne(user_id:self.user_id, listener_user_id:self.get_user_id, request_status:3)
                                
                                //いったんキャストのFireBaseのデータを削除する
                                conditionRefTap.removeValue()
                                
                                //クリアする
                                self.requestWaitFlg = 0
                            }
                        }
                    }
                    
                }
            })
            print("Timerは無効になりました。")

        }else{
            //データがFirebaseにあるかチェック
            conditionRefTap.observeSingleEvent(of: .value, with: { (snapshotTap) in
                if(snapshotTap.exists() == false){
                    //ない場合＞リスナーがキャンセル済み
                    // タイマーを無効にする
                    self.requestTimer.invalidate()
                    self.timerCount = 0
                    
                    self.allCoverMessage.isHidden = true
                    self.allCoverRequest.isHidden = true
                    self.topInfoLabel.isHidden = true
                    
                    self.requestWaitFlg = 0
                }
            })
        }
    }

    //「待機状態をキャンセル」ボタンを押した時
    @IBAction func cancelWait(_ sender: Any) {
        //20200606追加
        //申請直後リスナーが落ちたときのストリーマーがロックされてしまう問題
        UtilFunc.deleteCastLock(cast_id:self.user_id, user_id:0, type:2)
        
        //待機解除時のタイムスタンプ
        //1:待機スタート 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）
        UtilFunc.addActionRireki(user_id: self.user_id, listener_id: 0, type: 4, value01:0, value02:0)
        
        //ログオフ状態に変更
        var stringUrl = Util.URL_MOD_STATUS
        stringUrl.append("?user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&status=3")//キャスト-ログオフ状態
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: req, completionHandler: {
            (data, res, err) in
            if data != nil {
                //ステータス変更が成功
            }else{
            }
        })
        task.resume()
        
        //リクエスト履歴の未読数を取得した後に画面遷移
        //配信準備のトップ画面へ
        self.getLiveRequestNoreadCount(type:1, user_id:self.user_id)
    }
    
    //下記はUtilFunc内と同じ関数
    //リクエスト未読数取得 > 配信準備のトップ画面へ(画面遷移した先でメニューのアイコンは即時未読・既読で切り替わる)
    //type = 1:リスナーによる配信リクエスト
    func getLiveRequestNoreadCount(type:Int, user_id:Int){
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        //type=1:リスナーによる配信リクエスト
        var stringUrl = Util.URL_GET_LIVE_REQUEST_NOREAD_COUNT
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=")
        stringUrl.append(String(type))
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
                    let json = try decoder.decode(UtilStruct.ResultLiveRequestNoreadJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        //let strListenerUserId = obj.noread_count
                        //
                        UserDefaults.standard.set(obj.request_noread_count, forKey: "requestRirekiNoreadCount")
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
            //配信準備のトップ画面へ
            UtilToViewController.toWaitTopViewController()
        }
    }
    
    //画面全部を覆い、メッセージを表示する
    func showMessageDo(message: String, font: Int){
        self.re_connect_label.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
        //予約がある場合＞そのまま待機するようにメッセージを出す
        //label.font = UIFont.systemFont(ofSize: 18)
        self.re_connect_label.font = UIFont.boldSystemFont(ofSize: CGFloat(font))
        self.re_connect_label.text = message

        // 最大行まで行数表示できるようにする
        self.re_connect_label.numberOfLines = 0
        self.re_connect_label.textColor = UIColor.white
        // テキストを中央寄せ
        self.re_connect_label.textAlignment = NSTextAlignment.center
        self.re_connect_label.sizeToFit()
        self.re_connect_label.center = self.center
        
        //画面を操作させないように覆う
        self.allCoverMessage.isHidden = false
        //self.allCoverRequest.isHidden = true
        
        self.re_connect_label.isHidden = false
        self.bringSubviewToFront(self.allCoverMessage)
        self.bringSubviewToFront(self.re_connect_label)
    }
    
    //メッセージを画面から消す
    func delMessageDo(){
        //self.re_connect_label.removeFromSuperview()
        print("cover 666")
        self.allCoverMessage.isHidden = true
        //self.allCoverRequest.isHidden = true
        self.re_connect_label.isHidden = true
        self.topInfoLabel.isHidden = true
    }
    
    //type:
    //1=ダイアログが最上位
    //2=再接続用ラベルが最上位
    func bringSubviewCommonDo(type:Int){
        //トップのラベルは非表示
        self.topInfoLabel.isHidden = true
        
        //最前面へ
        if(type == 1){
            //1=ダイアログが最上位
            self.allCoverRequest.isHidden = false
            self.bringSubviewToFront(self.allCoverRequest)//ダイアログ
        }else if(type == 2){
            //2=再接続用ラベルが最上位
            self.allCoverMessage.isHidden = false
            self.bringSubviewToFront(self.allCoverMessage)//全画面を覆う
            self.bringSubviewToFront(self.re_connect_label)
        }else if(type == 4){
            //予約なしの通常の待機状態
            //1=ダイアログが最上位
            print("cover 999")
            self.allCoverMessage.isHidden = true
            self.allCoverRequest.isHidden = true
            self.re_connect_label.isHidden = true

            self.bringSubviewToFront(self.waitDialogView)
            //self.bringSubviewToFront(self.backDialogView)
            
            self.bringSubviewToFront(self.allCoverMessage)//全画面を覆う
            self.bringSubviewToFront(self.re_connect_label)
            self.bringSubviewToFront(self.allCoverRequest)//リクエストダイアログ
        }else if(type == 5){
            //予約ありの切り替えるタイミング（全画面を覆う）
            self.allCoverMessage.isHidden = false
            //self.allCoverRequest.isHidden = true
            
            self.re_connect_label.isHidden = false

            self.bringSubviewToFront(self.allCoverMessage)//全画面を覆う
            self.bringSubviewToFront(self.re_connect_label)
            
            self.bringSubviewToFront(self.allCoverRequest)//リクエストダイアログ
        }else{
            self.allCoverMessage.isHidden = false
            self.allCoverRequest.isHidden = false
            
            self.bringSubviewToFront(self.waitDialogView)
            //self.bringSubviewToFront(self.backDialogView)
            
            self.bringSubviewToFront(self.re_connect_label)
            self.bringSubviewToFront(self.allCoverMessage)//全画面を覆う
            self.bringSubviewToFront(self.allCoverRequest)//全画面を覆う
        }
    }

    //自分自身はサワレナイ(下記を透過したいVIewに記述)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self {
            return nil
        }
        return view
    }
}
