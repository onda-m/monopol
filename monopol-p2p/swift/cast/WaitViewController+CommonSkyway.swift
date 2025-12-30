//
//  WaitViewController+CommonSkyway.swift
//  swift_skyway
//
//  Created by onda on 2018/09/01.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import SkyWay
import AVFoundation

// MARK: setup skyway
extension WaitViewController{

    func startConnection() {
        //（一時的異常状態に）初期化する
        self.listenerErrorFlg = 0
        //正常状態に初期化する
        self.listenerStatus = 0//重要
        
        self.castSelectedDialog.isHidden = true

        DispatchQueue.main.async {

            /*******************************/
            //処理するタイミングをここに変更
            /*******************************/
            //念の為、ここでも非表示
            self.castWaitDialog.topInfoLabel.isHidden = true
            
            // タイムアウトのタイマーを無効にする
            self.castWaitDialog.requestTimer.invalidate()
            
            //status 1:申請中 2:申請したけど拒否された 99:接続が承認された
            let myLivePoint = UserDefaults.standard.integer(forKey: "myLivePoint")
            
            //print(self.appDelegate.init_seconds)
            
            if(self.isReconnect == false)
            {
                /***************************************************/
                //スターの追加処理
                /***************************************************/
                //得られるスター数
                let star_num = UserDefaults.standard.integer(forKey: "get_live_point")
                //必要なコイン
                let coin_num = UserDefaults.standard.double(forKey: "coin")
                
                //現在のスター数
                let star_temp = UserDefaults.standard.integer(forKey: "live_now_star")
                UserDefaults.standard.set(star_temp + star_num, forKey: "live_now_star")
                
                //mySQL更新(スター加算)
                //配信時の獲得ポイント1コインにつき1
                //Util.LIVE_POINT_GET: Int = 1
                //1枠の配信成立
                //Util.LIVE_POINT_GET_ONE: Double = 50
                let livePointGet = Util.LIVE_POINT_GET_ONE + (Int(coin_num) * Util.LIVE_POINT_GET)
                
                //重要(リアルタイムデータベースを使用)
                self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE + "/"
                    + String(self.user_id) + "/" + String(self.appDelegate.live_target_user_id))
                let data = ["cast_live_point": myLivePoint + livePointGet, "effect_id": self.appDelegate.live_effect_id]
                self.conditionRef.updateChildValues(data)
                //配信レベルの処理
                //user_infoテーブルの更新（キャスト）
                //flg:1:値プラス、2:値マイナス
                //GET: user_id, point,star,live_count,seconds,flg
                //１枠の秒数を設定
                self.appDelegate.init_seconds = UserDefaults.standard.integer(forKey: "live_sec")
                
                //配信経験値履歴にキャストが得た配信経験値などの履歴を保存する
                UtilFunc.writeLivePointRireki(type:1, cast_id:self.user_id, user_id:self.appDelegate.live_target_user_id, point:livePointGet, star:star_num, seconds:self.appDelegate.init_seconds, re_star:0)
                
                UtilFunc.saveLiveLevelNew(user_id:self.user_id, point:livePointGet, star:star_num, live_count:1, seconds:self.appDelegate.init_seconds, flg:1)
                
                //アプリ内の値を更新
                UtilFunc.setMyInfo()
                
                //配信時間の初期化
                self.appDelegate.count = 0
                
                //接続状態(会話開始状態)へ
                //self.removeFromSuperview()
                self.castWaitDialog.waitDialogView.isHidden = true
                self.castWaitDialog.statusLbl.isHidden = true
                
                self.castWaitDialog.allCoverMessage.isHidden = true
                self.castWaitDialog.allCoverRequest.isHidden = true
                self.castWaitDialog.topInfoLabel.isHidden = true

                //ライブ開始のタイムスタンプ
                //1:待機スタート 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）
                UtilFunc.addActionRireki(user_id: self.user_id, listener_id: self.appDelegate.live_target_user_id, type: 2, value01:0, value02:0)
                
                //リクエスト状態の更新（リクエスト後に配信までしたのかなどの状態>最新の一件のみ更新）
                //GET:user_id, listener_user_id, request_status
                //request_status 1:リクエスト後配信 2:リクエスト後キャストが拒否 3:リクエストしてそのまま
                UtilFunc.modifyLiveRequestStatusByOne(user_id:self.user_id, listener_user_id:self.appDelegate.live_target_user_id, request_status:1)
            }

            self.isReconnect = false
            
        }

        //通信時のSDK内部の処理の影響に依り、STREAMのコールバックで設定するとうまく設定出来ず、
        //STREAMイベントを受けた後に1秒ほどdelayを挟んで上記の設定を行うとスピーカより出力されるかと思います。
        //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 2.0秒後に実行したい処理
            //print("スピーカーから出力させる")
            //スピーカーから出力させる
            //let audioSession = AVAudioSession.sharedInstance()
        //    self.addAudioSessionObservers()
        //}
        //self.addAudioSessionObservers()
    }
    
    func closeMedia() {

        if self.mediaConnection != nil{
            self.mediaConnection!.close()
            self.mediaConnection!.on(.MEDIACONNECTION_EVENT_STREAM, callback: nil)
            self.mediaConnection!.on(.MEDIACONNECTION_EVENT_CLOSE, callback: nil)
            self.mediaConnection!.on(.MEDIACONNECTION_EVENT_ERROR, callback: nil)
            self.mediaConnection = nil
        }
        
        //ローカルストリームを一時停止
        //self.appDelegate.localStream?.setEnableVideoTrack(0, enable: false)
    }
    
    func sessionClose() {
        self.peer!.on(.PEER_EVENT_OPEN, callback: nil)
        self.peer!.on(.PEER_EVENT_CLOSE, callback: nil)
        self.peer!.on(.PEER_EVENT_CALL, callback: nil)
        self.peer!.on(.PEER_EVENT_DISCONNECTED, callback: nil)
        self.peer!.on(.PEER_EVENT_ERROR, callback: nil)

        self.appDelegate.localStream?.close()
        self.appDelegate.localStream = nil
        SKWNavigator.terminate()

        self.peer!.destroy()
        self.peer = nil
    }
    
    //type=0:初期化あり(最初一度だけ実行)
    func setup(){
        //待機状態へ遷移するためロックする
        /******************************/
        //ロック
        /******************************/
        //GET:user_id,type(1:待機状態への遷移ロック)
        UtilFunc.addCastLock(cast_id:self.user_id, user_id:self.user_id, type:1)
        /******************************/
        //ロック(ここまで)
        /******************************/
        
        //くるくる表示開始
        if(self.busyIndicator.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            self.view.bringSubviewToFront(self.busyIndicator)
        }else{
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.busyIndicator)
            self.view.bringSubviewToFront(self.busyIndicator)
        }
        
        if let newPeer = SkywayManager.shared.ensurePeer(id: String(self.user_id), apiKey: Util.skywayAPIKey, domain: Util.skywayDomain) {
            self.peer = newPeer
            self.setupPeerCallBacks(peer: newPeer)
            self.setupStream(peer: newPeer)
        } else {
            print("failed to create peer setup")
        }
        
        self.busyIndicator.removeFromSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            //5秒後にロック解除（念のため）
            //GET:user_id,type(1:待機状態への遷移ロック)
            UtilFunc.deleteCastLock(cast_id:self.user_id, user_id:self.user_id, type:1)
        }
    }

    func setupStream(peer:SKWPeer){
        let constraints = SkywayManager.defaultConstraints()

        if let localStream = SkywayManager.shared.prepareLocalStream(in: localStreamView, constraints: constraints) {
            appDelegate.localStream = localStream
        } else {
            print("failed to create local stream")
        }
    }
    
    //通話の接続
    func call(targetPeerId:String){
        let option = SKWCallOption()
        
        if let mediaConnection = self.peer!.call(withId: targetPeerId, stream: self.appDelegate.localStream, options: option){
            self.mediaConnection = mediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
        }else{
            print("failed to call :\(targetPeerId)")
        }
    }
    
    //チャットの接続
    func connect(targetPeerId:String){
        let options = SKWConnectOption()
        options.serialization = SKWSerializationEnum.SERIALIZATION_BINARY
        
        //接続
        if let dataConnection = self.peer!.connect(withId: targetPeerId, options: options){
            self.dataConnection = dataConnection
            self.setupDataConnectionCallbacks(dataConnection: dataConnection)
        }else{
            print("failed to connect data connection")
        }
    }
}

// MARK: skyway callbacks
extension WaitViewController{
    func setupPeerCallBacks(peer:SKWPeer){
        
        // MARK: PEER_EVENT_ERROR
        //待機がエラーとなった時に呼ばれる(???)
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
            if let error = obj as? SKWPeerError{
                print("\(error)")

                /******************************/
                //アンロック
                /******************************/
                //GET:user_id,type(1:待機状態への遷移ロック)
                UtilFunc.deleteCastLock(cast_id:self.user_id, user_id:self.user_id, type:1)
                //self.lock_flg = 0
                /******************************/
                //アンロック(ここまで)
                /******************************/
                
                //20200606追加
                //申請直後リスナーが落ちたときのストリーマーがロックされてしまう問題
                UtilFunc.deleteCastLock(cast_id:self.user_id, user_id:0, type:2)
            }
        })
        
        // MARK: PEER_EVENT_OPEN
        //待機が完了した時に呼ばれる
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
            if let peerId = obj as? String{
                
                DispatchQueue.main.async {
                    //print("待機完了")
                    
                    //待機時のタイムスタンプ
                    //1:待機スタート 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）
                    UtilFunc.addActionRireki(user_id: self.user_id, listener_id: 0, type: 1, value01:0, value02:0)

                    //通常の待機
                    //注意：下記は必要(予約リスナーの配信が始まる時に下記がないと、メッセージが表示され続けてしまう)
                    self.castWaitDialog.delMessageDo()
                    
                    //切り替え時のメッセージを表示
                    self.castWaitDialog.waitDialogView.isHidden = false//「１枠で配信中」のダイアログ
                    self.castWaitDialog.statusLbl.isHidden = false
                    
                    //待機中にする
                    self.appDelegate.reserveStatus = "1"
                    
                    self.listenerErrorFlg = 0
                    
                    //待機中はオブジェクトを全てhiddenに
                    //messageTextField.isHidden = true
                    if self.countDownLabel != nil {
                        self.countDownLabel.isHidden = true
                    }
                    
                    if self.userIconImageView != nil {
                        self.userIconImageView.isHidden = true
                    }
                    
                    if self.endCallButton != nil {
                        self.endCallButton.isHidden = true
                    }
                    
                    if self.oshiraseView != nil {
                        //お知らせのところ
                        self.oshiraseView.isHidden = true
                    }
                    
                    if self.starGetView != nil {
                        //右上のスター受信のところ
                        self.starGetView.isHidden = true
                    }

                    //待機が完了後、フォアグラウンドにある場合
                    self.castWaitDialog.requestDialogDo()
                    
                    /******************************/
                    //アンロック
                    /******************************/
                    //GET:user_id,type(1:待機状態への遷移ロック)
                    UtilFunc.deleteCastLock(cast_id:self.user_id, user_id:self.user_id, type:1)
                    /******************************/
                    //アンロック(ここまで)
                    /******************************/
                    
                    //20200606追加
                    //申請直後リスナーが落ちたときのストリーマーがロックされてしまう問題
                    UtilFunc.deleteCastLock(cast_id:self.user_id, user_id:0, type:2)
                }
                print("your peerId: \(peerId)")
            }
        })
        
        //接続時に下記の２つが同時に呼ばれるか＞呼ばれる
        
        // MARK: PEER_EVENT_CONNECTION
        //通話コールされた時に呼ばれる
        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL, callback: { (obj) -> Void in

            if let connection = obj as? SKWMediaConnection{
                //カメラなしのリスナーを考慮しコールバック処理はsetupDataConnectionCallbacksへ移動
                //20201120
                //ただし異常終了時のコールバックのみ使用する
                self.setupMediaConnectionCallbacks(mediaConnection: connection)
                self.mediaConnection = connection
                connection.answer(self.appDelegate.localStream)
                
                /*
                //20201118 下記リフレッシュボタンを押した時に通したいが一旦廃止のためコメントアウト
                //リフレッシュボタンを廃止
                if(self.isReconnect == true) {

                    //（一時的異常状態に）初期化する
                    //self.listenerErrorFlg = 0
                    //正常状態(人的操作によるもの)にする
                    self.listenerErrorFlg = 1
                    
                    //正常状態に初期化する
                    self.listenerStatus = 0//重要
                
                    self.castSelectedDialog.isHidden = true

                    DispatchQueue.main.async {
                        //念の為、ここでも非表示
                        self.castWaitDialog.topInfoLabel.isHidden = true
                    
                        // タイムアウトのタイマーを無効にする
                        self.castWaitDialog.requestTimer.invalidate()

                        //接続状態(会話開始状態)へ
                        //self.removeFromSuperview()
                        self.castWaitDialog.waitDialogView.isHidden = true
                        self.castWaitDialog.statusLbl.isHidden = true
                    
                        self.castWaitDialog.allCoverMessage.isHidden = true
                        self.castWaitDialog.allCoverRequest.isHidden = true
                        self.castWaitDialog.topInfoLabel.isHidden = true

                        self.isReconnect = false
                    }
                }
                */
            }
        })
        
        // MARK: PEER_EVENT_CONNECTION
        //チャットコールされた時に呼ばれる
        peer.on(SKWPeerEventEnum.PEER_EVENT_CONNECTION, callback: { (obj) -> Void in
            if let connection = obj as? SKWDataConnection{
                self.dataConnection = connection
                self.setupDataConnectionCallbacks(dataConnection: connection)
            }
        })
    }

    /***************************/
    /***************************/
    // 電話による割り込みと、オーディオルートの変化を監視します
    func addAudioSessionObservers() {
        //UtilLog.printf(str:"オーディオルートの設定（ストリーマー側）")
        
        //let center = NotificationCenter.default
        //self.center.removeObserver(self)
        self.center.addObserver(self, selector: #selector(audioSessionRouteChanged(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        self.center.addObserver(self, selector: #selector(audioSessionRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    // Audio Session Route Change : ルートが変化した(ヘッドフォンが抜き差しされた)
    @objc func audioSessionRouteChanged(_ notification: Notification) {
        //ヘッドフォン端子に何らかの変化があった場合
        //UtilLog.printf(str:"変化あり")
        //self.remoteAudioDefault()
        
        //ヘッドフォン端子に何らかの変化があった場合
        //停止して1秒後に再始動を行う
        self.appDelegate.localStream?.setEnableAudioTrack(0, enable: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            // headphone
            self.appDelegate.localStream?.setEnableAudioTrack(0, enable: true)
        }
    }
    
    /*
    // イヤホン（ヘッドホン出力）の場合
    func remoteAudioDefault() {
        self.appDelegate.localStream?.setEnableAudioTrack(0, enable: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
          // headphone
          do {
              try AVAudioSession.sharedInstance().setActive(true)
              try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
              try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
              self.appDelegate.localStream?.setEnableAudioTrack(0, enable: true)
              UtilLog.printf(str:"イヤホン（ヘッドホン出力）")
          } catch {
            print("AVAudioSessionCategoryPlayAndRecord error")
          }
        }
    }
    
    // 内臓スピーカー出力の場合
    func remoteAudioSpeaker() {
        self.appDelegate.localStream?.setEnableAudioTrack(0, enable: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
          // speaker
          do {
              let audioSession = AVAudioSession.sharedInstance()
              try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
              try audioSession.setMode(AVAudioSession.Mode.videoChat)
              try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
              try audioSession.setActive(true)
              self.appDelegate.localStream?.setEnableAudioTrack(0, enable: true)
              UtilLog.printf(str:"remoteAudioSpeaker:内臓スピーカー出力")
          } catch {
            print("AVAudioSessionCategoryPlayAndRecord error")
          }
        }
    }
     */
    /***************************/
    /***************************/
    
    //通話のコールバック
    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){

        // MARK: MEDIACONNECTION_EVENT_STREAM
        //相手につながった時に呼ばれる(映像が両方で有効の時にしか通らない)
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
            //UtilLog.printf(str:"通話のコールバック")
            self.addAudioSessionObservers()
        })
 
        // MARK: MEDIACONNECTION_EVENT_CLOSE
        //相手と切断された時に呼ばれる＞呼ばれる(チャットの方も呼ばれる)
        //ここではリスナーの異常終了の場合のみ処理を行う
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            
            if let _ = obj as? SKWMediaConnection{

                DispatchQueue.main.async {
                    if(self.listenerErrorFlg == 0){
                        self.listenerStatus = 1//重要
                        //end of 異常終了の場合のみここで処理終わり
                    }
                }
            }
        })
    }

    //チャットのコールバック
    func setupDataConnectionCallbacks(dataConnection:SKWDataConnection){
        // MARK: DATACONNECTION_EVENT_OPEN
        //相手につながった時に呼ばれる＞呼ばれる
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_OPEN, callback: { (obj) -> Void in
            
            //20201118 add
            self.startConnection()
            
            //（一時的異常状態に）初期化する
            self.listenerErrorFlg = 0
            //正常状態に初期化する
            self.listenerStatus = 0//重要
            
            if (obj as? SKWDataConnection) != nil{
                //待機中はオブジェクトを全てhiddenに>接続されると表示
                //messageTextField.isHidden = true
                self.countDownLabel.isHidden = false
                self.userIconImageView.isHidden = false
                self.endCallButton.isHidden = false
                
                //ダイアログ関連を非表示にしておく
                self.castWaitDialog.allCoverMessage.isHidden = true
                self.castWaitDialog.re_connect_label.isHidden = true
                self.castWaitDialog.topInfoLabel.isHidden = true
                
                if(self.appDelegate.reserveStatus == "1"){
                    //配信中の状態へ(待機状態から接続状態になったときのみ、下記を実行)
                    UtilFunc.loginDo(user_id:self.user_id, status:2, live_user_id: self.appDelegate.live_target_user_id, reserve_flg:Int(self.appDelegate.reserveFlg)!, max_reserve_count:Int(self.appDelegate.reserveMaxCount)!, password:"0")
                    
                    //通話状態へ
                    self.appDelegate.reserveStatus = "2"

                    //絆レベル課金ポイントのボーナス比率など相手との情報を取得
                    UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:self.appDelegate.live_target_user_id)

                    //復帰時にここを通るか？
                    //print(self.appDelegate.reserveStatus)
                    self.countDownLabel.isHidden = false
                    self.userIconImageView.isHidden = false
                    self.endCallButton.isHidden = false
                    
                    //お知らせのところ
                    self.oshiraseView.isHidden = true
                    //右上のスター受信のところ
                    self.starGetView.isHidden = true
                    
                    //ユーザーアイコンにアクションの設定
                    self.userIconImageView.isUserInteractionEnabled = true
                    self.userIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userIconImageViewTapped(_:))))

                    //ターゲットユーザーの情報を取得する
                    //情報取得時にユーザーアイコンに画像を設定する
                    self.getTargetInfo(target_id : self.appDelegate.live_target_user_id)
                    
                    //ターゲットユーザーのダイアログを作成しておく
                    self.userInfoDialog = UINib(nibName: "OnLiveUserInfo", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! OnLiveUserInfo
                    //最初は非表示(リスナー情報ダイアログ)
                    //画面サイズに合わせる
                    self.userInfoDialog.frame = self.view.frame
                    // 貼り付ける
                    self.view.addSubview(self.userInfoDialog)
                    self.userInfoDialog.isHidden = true

                    //もしタイマーが実行中だったらスタートしない
                    if(self.timerLive.isValid == true){
                        //何も処理しない
                    }else{
                        //配信時間のクリア
                        self.appDelegate.count = 0
                        
                        //タイマーをスタート
                        self.timerLive = Timer.scheduledTimer(timeInterval:1.0,
                                                              target: self,
                                                              selector: #selector(self.timerInterruptLive(_:)),
                                                              userInfo: nil,
                                                              repeats: true)
                    }
                    
                    //重要(リアルタイムデータベースを使用)
                    self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE + "/"
                        + String(self.user_id) + "/" + String(self.appDelegate.live_target_user_id))

                    //イベント監視
                    self.handle = self.conditionRef.observe(.value, with: { snap in
                        //print("ノードの値が変わりました！: \((snap.value as AnyObject).description)")
                        
                        if(snap.exists() == false){
                            //UtilLog.printf(str:"すでにデータがない(キャスト側)")
                            return
                        }
                        
                        //let dict = snap.value as! [String : AnyObject]
                        let dict = snap.value as! NSDictionary
                        //print(dict.values)

                        //status_listener = 5:異常終了からの復帰(リスナー側)
                        //０：サシライブ中でない、１：待機が完了、２：サシライブ中、３：バツボタンで終了、
                        //４：コインがなく延長ができなくなった時、５：リスナーが異常終了した時(未使用)、
                        //６：リスナーが異常終了から復帰した時、7：復帰完了（一時的）＞リスナー側は現時間を反映し「２：サシライブ中」に状態変更する
                        let status_listener = dict["status_listener"] as! Int
                        
                        if(status_listener == 3 || status_listener == 4){
                            //リスナーがバツボタンを押して終わった(またはリスナーのコインがなくなった場合)
                            //self.commonWaitDo()
                            self.commonWaitDo(status:1)
                        }else if(status_listener == 6){
                            //この時点でリスナーとの接続が復活している
                            if(self.appDelegate.count >= self.appDelegate.init_seconds - 10){
                                //ここは通常処理されないが、念のため
                                //50秒(10秒前は復帰できない)を経過していたら待機状態へ
                                if(self.appDelegate.reserveStatus == "5"){
                                    //予約がある時
                                    self.commonWaitDo(status:8)
                                }else{
                                    self.commonWaitDo(status:1)
                                }

                            }else{
                                //現時点の時間をセットし、リスナーの状態を「復帰完了」にする（リスナーと合わせる）
                                let data = ["live_time": self.appDelegate.count, "status_listener": 7]
                                self.conditionRef.updateChildValues(data)
                                
                                //復帰のメッセージ関連
                                self.castWaitDialog.showMessageDo(message:"リスナーとの通信が回復しました。\nサシライブを続けてください。", font: 15)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castWaitDialog.delMessageDo()
                                }
                            }
                            
                            return
                        }

                        //延長時のスターをゲット
                        let cast_add_star = dict["cast_add_star"] as! Int
                        let cast_add_point = dict["cast_add_point"] as! Int
                        if(cast_add_star > 0 || cast_add_point > 0){
                            //0に戻す
                            let data = ["cast_add_star": 0, "cast_add_point": 0]
                            self.conditionRef.updateChildValues(data)

                            //配信経験値/スターの加算・配信レベルの計算・アプリ内の値を更新・配信ポイント履歴に保存
                            //type:1:配信による経験値 2:プレゼントによる経験値3:延長による経験値99:没収したスター
                            self.getLivePoint(type:3,
                                              cast_id:self.user_id,
                                              user_id:self.appDelegate.live_target_user_id,
                                              point_num:cast_add_point,
                                              star_num:cast_add_star,
                                              live_count:0,
                                              seconds:Util.INIT_EX_UNIT_SECONDS,
                                              re_star:0,
                                              action_flg:1)
                            
                            return
                        }
                        
                        //プレゼントゲット
                        let present_star = dict["present_star"] as! Int
                        let present_point = dict["present_point"] as! Int
                        if(present_star > 0 || present_point > 0){
                            //0に戻す
                            let data = ["present_star": 0, "present_point": 0]
                            self.conditionRef.updateChildValues(data)
                            //配信経験値/スターの加算・配信レベルの計算・アプリ内の値を更新・配信ポイント履歴に保存
                            //type:1:配信による経験値 2:プレゼントによる経験値3:延長による経験値99:没収したスター
                            self.getLivePoint(type:2,
                                              cast_id:self.user_id,
                                              user_id:self.appDelegate.live_target_user_id,
                                              point_num:present_point,
                                              star_num:present_star,
                                              live_count:0,
                                              seconds:0,
                                              re_star:0,
                                              action_flg:1)
                            
                            return
                        }
                        
                        //機能を廃止
                        /*
                        //スクショのリクエスト
                        let request_screenshot_flg = dict["request_screenshot_flg"] as! Int
                        if(request_screenshot_flg == 1){
                            //スクリーンショットのリクエスト
                            //0に戻す
                            let data = ["request_screenshot_flg": 0]
                            self.conditionRef.updateChildValues(data)
                            
                            //重要
                            //お知らせ表示
                            self.oshiraseView.isHidden = false
                            let strLiveInfoTemp = UtilFunc.strMin(str:self.appDelegate.live_target_user_name, num:Util.NAME_MOJI_COUNT_SMALL) + Util.LIVE_RIREKI_STR01
                            self.oshiraseLbl.text = "・" + strLiveInfoTemp
                            self.view.bringSubviewToFront(self.oshiraseView)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                //非表示
                                self.oshiraseView.isHidden = true
                            }
                            
                            //メッセージテーブルのリロード
                            self.castWaitDialog.messageTableView.reloadData()
                            
                            //配信情報の保存＋リアルタイム更新
                            //type=1:まつさんからスクショリクエストがありました
                            UtilFunc.saveLiveRireki(cast_id:self.user_id, type:1, notes:strLiveInfoTemp, listener_id:self.appDelegate.live_target_user_id)
                            
                            return
                            
                        }else if(request_screenshot_flg == 4){
                            let cast_send_screenshot = dict["request_screenshot_name"] as! String
                            if(cast_send_screenshot == "0" || cast_send_screenshot == ""){
                                //スクリーンショットのリクエスト(ユーザーが受け取った時)
                                //0に戻す
                                let data = ["request_screenshot_flg": 0]
                                self.conditionRef.updateChildValues(data)
                                
                                //スクショ中のカメラ画面は一旦閉じて、ダイアログ(スターの加算のダイアログ)を数秒表示
                                //self.onCameraClose()
                                
                                //配信経験値/スターの加算・配信レベルの計算・アプリ内の値を更新・配信ポイント履歴に保存
                                //1:配信による経験値 2:プレゼントによる経験値3:延長による経験値 4:予約キャンセル(スター追加のみ)5スクショによるスター獲得99:スター没収
                                self.getLivePoint(type:5,
                                                  cast_id:self.user_id,
                                                  user_id:self.appDelegate.live_target_user_id,
                                                  point_num:0,
                                                  star_num:Util.SCREENSHOT_GET_STAR,
                                                  live_count:0,
                                                  seconds:0,
                                                  re_star:0,
                                                  action_flg:1)

                                //お知らせ表示
                                //2:まつさんにスクショを送りました
                                self.oshiraseView.isHidden = false
                                let strLiveInfoTemp = UtilFunc.strMin(str:self.appDelegate.live_target_user_name, num:Util.NAME_MOJI_COUNT_SMALL) + Util.LIVE_RIREKI_STR02
                                self.oshiraseLbl.text = "・" + strLiveInfoTemp
                                self.view.bringSubviewToFront(self.oshiraseView)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    //非表示
                                    self.oshiraseView.isHidden = true
                                }
                                
                                //メッセージテーブルのリロード(不要)
                                //self.messageTableView.reloadData()
                                
                                //配信情報の保存＋リアルタイム更新
                                UtilFunc.saveLiveRireki(cast_id:self.user_id, type:2, notes:strLiveInfoTemp, listener_id:self.appDelegate.live_target_user_id)
                            }
                            return
                        }*/
                    })
                }
            }//end of if reserveStatus == 1
        })

        // MARK: DATACONNECTION_EVENT_DATA
        //何かメッセージがきた時に呼ばれる
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_DATA, callback: { (obj) -> Void in
            let strValue:String = obj as! String
            
            if(strValue.contains("画面リフレッシュ"))
            {
                
                self.isReconnect = true
                /***************************/
                //ラベル作成
                /***************************/
                self.castSelectedDialog.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                // テキストを中央寄せ
                self.castSelectedDialog.infoLbl.attributedText = UtilFunc.getInsertIconString(string: "画面をリフレッシュしています。", iconImage: UIImage(), iconSize: self.iconSize, lineHeight: 1.5)
                //self.infoLbl.textAlignment = NSTextAlignment.center
                self.castSelectedDialog.infoLbl.font = UIFont.boldSystemFont(ofSize: 15)
                self.castSelectedDialog.infoLbl.sizeToFit()
                self.castSelectedDialog.infoLbl.center = self.castSelectedDialog.center
                //最前面へ
                self.castSelectedDialog.infoLbl.isHidden = false
                self.castSelectedDialog.bringSubviewToFront(self.castSelectedDialog.infoLbl)
                /***************************/
                //ラベル作成(ここまで)
                /***************************/
                
                self.castSelectedDialog.closeBtn.isHidden = true

                self.castSelectedDialog.isHidden = false
                //self.view.bringSubviewToFront(self.castSelectedDialog)
                self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialog)
                return
            }
            print("get data: \(strValue)")
            let message = Message(sender: Message.SenderType.get, text: strValue)
            //self.messages.insert(message, at: 0)
            self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合
            
            //MediaConnectionViewController.messageTableView.reloadData()
            self.castWaitDialog.messageTableView.reloadData()
            
            if(strValue.hasPrefix("$$$_nocoin_")) {
                //リスナーがコイン不足のとき（強制的にチャット領域を表示）
                self.castWaitDialog.messageTableView.isHidden = false//タイムラインを表示
                self.liveTimelineFlg = 1
                
                //タイムラインアイコンを選択中のアイコンに変更する
                self.timelineBtn.image = UIImage(named: "lm_ico_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
        })
        
        // MARK: DATACONNECTION_EVENT_CLOSE
        //相手と切断された時に呼ばれる＞呼ばれる
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            //print("close data connection")

            //20201118 add
            if let _ = obj as? SKWDataConnection{
                DispatchQueue.main.async {
                    if(self.listenerErrorFlg == 0){
                        self.listenerStatus = 1//重要
                        //end of 異常終了の場合
                    }else{
                        //正常に終了した場合
                        //リスナー異常終了フラグの初期化>接続時のみゼロにする
                        self.refreshBtn.isHidden = true
                        self.listenerErrorFlg = 0
                    }
                }
            }
        })
    }
    
    func send(text: String) {
        //$$$から始まる文字列はスタンプとする
        if(text.contains("画面リフレッシュ"))
        {
            isReconnect = true
            self.dataConnection?.send(text as NSObject)
        }else if (!text.hasPrefix("$$$") && text != "") {
            print("送信した文字列")
            print(text)
            self.dataConnection?.send(text as NSObject)
            let message = Message(sender: Message.SenderType.send, text: text)
            print(message.text as Any)
            //self.messages.insert(message, at: 0)
            self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合
            
            //履歴保存
            UtilFunc.saveChatRireki(type:1, from_user_id:self.user_id, to_user_id:self.appDelegate.live_target_user_id, present_id:0, chat_text:text, status:1)
        }
    }
    
    func sendStamp(text: String) {
        //$$$から始まる文字列はスタンプとする
        if text.hasPrefix("$$$") {
            //print("送信した文字列")
            //print(text)
            
            var send_text = ""
            if(text == "$$$_screenshot_request"){
                //スクショリクエストの送信
                send_text = "スクショをリクエストしました。"
            }else if(text.hasPrefix("$$$_stamp_")){
                //スタンプの送信(そのままの文字列を入れる。画像用のCellを使用するため)
                send_text = text
            }
            self.dataConnection?.send(send_text as NSObject)
            let message = Message(sender: Message.SenderType.send, text: send_text)
            self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合
            
            //履歴保存
            UtilFunc.saveChatRireki(type:2, from_user_id:self.user_id, to_user_id:self.appDelegate.live_target_user_id, present_id:0, chat_text:send_text, status:1)
        }
    }
}
