//
//  MediaConnectionViewController+CommonSkyway.swift
//  swift_skyway
//
//  Created by onda on 2018/09/02.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import SkyWay
import SkyWayRoom
import AVFoundation

// MARK: setup skyway
extension MediaConnectionViewController{
    
    func closeMedia() {
        roomClosed = true
        roomTask?.cancel()
        roomTask = nil
        roomSubscriptions.removeAll()
        roomPublications.forEach { publication in
            publication.cancel()
        }
        roomPublications.removeAll()
        localDataStream = nil
        localAudioStream = nil
        localVideoStream = nil
        remoteVideoStream = nil
        remoteAudioStream = nil
        remoteDataStream = nil
        detachLocalVideo()
        detachRemoteVideo()
    }
    
    func sessionClose() {
        Task { @MainActor in
            await leaveRoomIfNeeded()
        }
    }
    
    func setup(){
        roomClosed = false
        roomTask?.cancel()
        roomTask = Task { @MainActor in
            await joinRoomIfNeeded(roomName: liveCastId, memberName: String(self.user_id))
        }
    }

    private func attachLocalVideo() {
        if localVideoView == nil {
            localVideoView = VideoView(frame: localStreamView.bounds)
            if let localVideoView = localVideoView {
                localVideoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                localStreamView.addSubview(localVideoView)
            }
        }
        if let localVideoStream = localVideoStream, let localVideoView = localVideoView {
            localVideoStream.addRenderer(localVideoView)
        }
    }

    private func attachRemoteVideo() {
        if remoteVideoView == nil {
            remoteVideoView = VideoView(frame: remoteStreamView.bounds)
            if let remoteVideoView = remoteVideoView {
                remoteVideoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                remoteStreamView.addSubview(remoteVideoView)
            }
        }
        if let remoteVideoStream = remoteVideoStream, let remoteVideoView = remoteVideoView {
            remoteVideoStream.addRenderer(remoteVideoView)
        }
    }

    func detachLocalVideo() {
        localVideoStream?.removeRenderer(localVideoView)
        localVideoView?.removeFromSuperview()
        localVideoView = nil
    }

    func detachRemoteVideo() {
        remoteVideoStream?.removeRenderer(remoteVideoView)
        remoteVideoView?.removeFromSuperview()
        remoteVideoView = nil
    }
}

// MARK: skyway callbacks
extension MediaConnectionViewController{
    @MainActor
    private func joinRoomIfNeeded(roomName: String, memberName: String) async {
        guard roomClosed == false else { return }

        do {
            try await SkyWayRoom.SkyWayContext.setup(withToken: Util.skywayRoomToken)
            let roomConfig = SkyWayRoom.RoomConfig(name: roomName, type: .p2p)
            let room = try await Room.findOrCreate(with: roomConfig)
            self.room = room

            let memberConfig = MemberConfig(name: memberName)
            let localMember = try await room.join(with: memberConfig)
            self.localMember = localMember

            if room.members.count > 2 {
                await leaveRoomIfNeeded()
                return
            }

            attachRoomCallbacks(room: room, localMember: localMember)
            try await publishLocalStreams(localMember: localMember)
        } catch {
            print("SkyWayRoom join error: \(error)")
        }
    }

    @MainActor
    private func attachRoomCallbacks(room: Room, localMember: LocalRoomMember) {
        room.onMemberJoined { [weak self] _ in
            guard let self = self else { return }
            if room.members.count > 2 {
                Task { @MainActor in
                    await self.leaveRoomIfNeeded()
                }
            }
        }

        room.onStreamPublished { [weak self] publication in
            guard let self = self else { return }
            if publication.publisher.id == localMember.id {
                return
            }
            Task { @MainActor in
                await self.subscribeToPublication(publication, localMember: localMember)
            }
        }

        room.onMemberLeft { [weak self] member in
            guard let self = self else { return }
            if member.id != localMember.id {
                self.handleRemoteMediaDisconnected()
            }
        }
    }

    @MainActor
    private func publishLocalStreams(localMember: LocalRoomMember) async throws {
        let audioStream = try await LocalAudioStream.create()
        let videoStream = try await LocalVideoStream.create()
        let dataStream = LocalDataStream()
        localAudioStream = audioStream
        localVideoStream = videoStream
        localDataStream = dataStream

        attachLocalVideo()

        roomPublications.append(try await localMember.publish(audioStream))
        roomPublications.append(try await localMember.publish(videoStream))
        roomPublications.append(try await localMember.publish(dataStream))
    }

    @MainActor
    private func subscribeToPublication(_ publication: RoomPublication, localMember: LocalRoomMember) async {
        do {
            let subscription = try await localMember.subscribe(publication)
            roomSubscriptions.append(subscription)
            if let stream = subscription.stream as? RemoteVideoStream {
                remoteVideoStream = stream
                attachRemoteVideo()
                handleRemoteMediaConnected()
            } else if let stream = subscription.stream as? RemoteAudioStream {
                remoteAudioStream = stream
            } else if let stream = subscription.stream as? RemoteDataStream {
                remoteDataStream = stream
                setupRemoteDataCallbacks()
                setupDataConnectionCallbacks()
            }
        } catch {
            print("SkyWayRoom subscribe error: \(error)")
        }
    }

    @MainActor
    private func setupRemoteDataCallbacks() {
        remoteDataStream?.onData { [weak self] data in
            guard let self = self else { return }
            self.handleReceivedData(data)
        }
    }

    @MainActor
    private func leaveRoomIfNeeded() async {
        if let localMember = localMember {
            await localMember.leave()
        }
        room = nil
        localMember = nil
        roomClosed = true
    }

    /***************************/
    /***************************/
    // 電話による割り込みと、オーディオルートの変化を監視します
    func addAudioSessionObservers() {
        AVAudioSession.sharedInstance()
        //UtilLog.printf(str:"オーディオルートの設定（通る？）")
        
        //let center = NotificationCenter.default
        //self.center.removeObserver(self)
        self.center.addObserver(self, selector: #selector(audioSessionRouteChanged(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        self.center.addObserver(self, selector: #selector(audioSessionRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    func addAudioSessionObserversAuto() {
        AVAudioSession.sharedInstance()

        //let center = NotificationCenter.default
        //self.center.removeObserver(self)
        self.center.addObserver(self, selector: #selector(audioSessionRouteChanged(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        self.center.addObserver(self, selector: #selector(audioSessionRouteChangedAuto(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    /// Audio Session Route Change : ルートが変化した(ヘッドフォンが抜き差しされた)
    @objc func audioSessionRouteChanged(_ notification: Notification) {
        //ヘッドフォン端子に何らかの変化があった場合
        //現在の配信を停止して1秒後に再始動を行う
        self.remoteAudioStream?.setEnabled(false)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            // headphone
            self.remoteAudioStream?.setEnabled(true)
        }
    }
    
    /// Audio Session Route Change : ルートが変化した(ヘッドフォンが抜き差しされた)
    @objc func audioSessionRouteChangedAuto(_ notification: Notification) {
        //ヘッドフォン端子に何らかの変化があった場合
        //現在の動画を停止して２秒後に再始動を行う
        self.player.pause()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            // headphone
            self.player.play()
            //self.remoteStream?.setEnableAudioTrack(0, enable: true)
        }
    }
    
        /*
        guard let desc = notification.userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
                    else { return }
        let outputs = desc.outputs
        for component in outputs {
            if component.portType == AVAudioSession.Port.headphones ||
                component.portType == AVAudioSession.Port.bluetoothA2DP ||
                component.portType == AVAudioSession.Port.bluetoothLE ||
                component.portType == AVAudioSession.Port.bluetoothHFP {
                // イヤホン(Bluetooth含む)が抜かれた時の処理
                UtilLog.printf(str:"111333")
                //self.remoteAudioDefault()
                return
            }
        }
        // イヤホン(Bluetooth含む)が差された時の処理
        //self.remoteAudioSpeaker()
         */
        
        /*
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                //print("Interrupption not reason.");
                return
        }
        
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs {
                
                if output.portType == AVAudioSession.Port.lineIn {
                    UtilLog.printf(str:"1")
                    break
                } else if output.portType == AVAudioSession.Port.builtInMic {
                    UtilLog.printf(str:"2")
                    break
                } else if output.portType == AVAudioSession.Port.headsetMic {
                    UtilLog.printf(str:"3")
                    break
                } else if output.portType == AVAudioSession.Port.lineOut {
                    UtilLog.printf(str:"4")
                    break
                } else if output.portType == AVAudioSession.Port.headphones {
                    UtilLog.printf(str:"5")
                    break
                } else if output.portType == AVAudioSession.Port.bluetoothA2DP {
                    UtilLog.printf(str:"6")
                    break
                } else if output.portType == AVAudioSession.Port.builtInReceiver {
                    UtilLog.printf(str:"7")
                    break
                } else if output.portType == AVAudioSession.Port.builtInSpeaker {
                    UtilLog.printf(str:"8")
                    break
                } else if output.portType == AVAudioSession.Port.HDMI {
                    UtilLog.printf(str:"9")
                    break
                } else if output.portType == AVAudioSession.Port.airPlay {
                    UtilLog.printf(str:"10")
                    break
                } else if output.portType == AVAudioSession.Port.bluetoothLE {
                    UtilLog.printf(str:"11")
                    break
                } else if output.portType == AVAudioSession.Port.bluetoothHFP {
                    UtilLog.printf(str:"12")
                    break
                } else if output.portType == AVAudioSession.Port.usbAudio {
                    UtilLog.printf(str:"13")
                    // ヘッドフォンがつながった
                    //self.remoteAudioSpeaker()
                    break
                } else if output.portType == AVAudioSession.Port.carAudio {
                    UtilLog.printf(str:"14")
                    break
                } else if #available(iOS 14.0, *) {
                    if output.portType == AVAudioSession.Port.virtual {
                        UtilLog.printf(str:"15")
                    } else if output.portType == AVAudioSession.Port.PCI {
                        UtilLog.printf(str:"16")
                    } else if output.portType == AVAudioSession.Port.fireWire {
                        UtilLog.printf(str:"17")
                    } else if output.portType == AVAudioSession.Port.displayPort {
                        UtilLog.printf(str:"18")
                    } else if output.portType == AVAudioSession.Port.AVB {
                        UtilLog.printf(str:"19")
                    } else if output.portType == AVAudioSession.Port.thunderbolt {
                        UtilLog.printf(str:"20")
                    }
                    break
                } else {
                    UtilLog.printf(str:"21")
                    break
                }
            }//end of for

        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs {
                    if output.portType == AVAudioSession.Port.lineIn {
                        UtilLog.printf(str:"out_1")
                        break
                    } else if output.portType == AVAudioSession.Port.builtInMic {
                        UtilLog.printf(str:"out_2")
                        break
                    } else if output.portType == AVAudioSession.Port.headsetMic {
                        UtilLog.printf(str:"out_3")
                        break
                    } else if output.portType == AVAudioSession.Port.lineOut {
                        UtilLog.printf(str:"out_4")
                        break
                    } else if output.portType == AVAudioSession.Port.headphones {
                        UtilLog.printf(str:"out_5")
                        break
                    } else if output.portType == AVAudioSession.Port.bluetoothA2DP {
                        UtilLog.printf(str:"out_6")
                        break
                    } else if output.portType == AVAudioSession.Port.builtInReceiver {
                        UtilLog.printf(str:"out_7")
                        break
                    } else if output.portType == AVAudioSession.Port.builtInSpeaker {
                        UtilLog.printf(str:"out_8")
                        break
                    } else if output.portType == AVAudioSession.Port.HDMI {
                        UtilLog.printf(str:"out_9")
                        break
                    } else if output.portType == AVAudioSession.Port.airPlay {
                        UtilLog.printf(str:"out_10")
                        break
                    } else if output.portType == AVAudioSession.Port.bluetoothLE {
                        UtilLog.printf(str:"out_11")
                        break
                    } else if output.portType == AVAudioSession.Port.bluetoothHFP {
                        UtilLog.printf(str:"out_12")
                        break
                    } else if output.portType == AVAudioSession.Port.usbAudio {
                        UtilLog.printf(str:"out_13")
                        // ヘッドフォンが外れた
                        self.remoteAudioDefault()
                        break
                    } else if output.portType == AVAudioSession.Port.carAudio {
                        UtilLog.printf(str:"out_14")
                        break
                    } else if #available(iOS 14.0, *) {
                        if output.portType == AVAudioSession.Port.virtual {
                            UtilLog.printf(str:"out_15")
                        } else if output.portType == AVAudioSession.Port.PCI {
                            UtilLog.printf(str:"out_16")
                        } else if output.portType == AVAudioSession.Port.fireWire {
                            UtilLog.printf(str:"out_17")
                        } else if output.portType == AVAudioSession.Port.displayPort {
                            UtilLog.printf(str:"out_18")
                        } else if output.portType == AVAudioSession.Port.AVB {
                            UtilLog.printf(str:"out_19")
                        } else if output.portType == AVAudioSession.Port.thunderbolt {
                            UtilLog.printf(str:"out_20")
                        }
                        break
                    } else {
                        UtilLog.printf(str:"out_21")
                        break
                    }
                }//end of for
                        
                        /*
                where(output.portType == AVAudioSession.Port.headphones ||
                    output.portType == AVAudioSession.Port.bluetoothA2DP ||
                    output.portType == AVAudioSession.Port.bluetoothLE ||
                    output.portType == AVAudioSession.Port.bluetoothHFP) {
                    // ヘッドフォンが外れた
                    //self.remoteAudioDefault()
                    //print("ヘッドフォンが外れた")
                    UtilLog.printf(str:"リスナー：ヘッドフォンが外れた")
                    break
                }
                UtilLog.printf(str:"リスナー：bbb")
                         */
            }
        default:
            UtilLog.printf(str:"333")
        }
     }
    
    // サウンドの停止はオーディオトラックを無効にすることで実装
    func remoteAudioOff() {
        self.remoteAudioStream?.setEnabled(false)
    }
    
    // イヤホンを抜き差しした場合は一旦止め、２秒後に再度プレイする
    func remoteAudioDefault() {
        self.remoteAudioOff()
        //self.remoteStream?.setEnableAudioTrack(0, enable: false)
        //UtilLog.printf(str:"外した1")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            // headphone
            self.player.play()
            self.remoteAudioStream?.setEnabled(true)
        }
    }
        
    // 外部スピーカー出力の場合
    func remoteAudioSpeaker() {
        self.remoteAudioStream?.setEnabled(false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            // speaker
            do {
                //try AVAudioSession.sharedInstance().setActive(true)
                //try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                self.remoteAudioStream?.setEnabled(true)
            } catch {
                print("AVAudioSessionCategoryPlayAndRecord error")
            }
        }
    }
     */
    /***************************/
    /***************************/

    //通話のコールバック
    func handleRemoteMediaConnected() {

        // MARK: MEDIACONNECTION_EVENT_STREAM
        //相手につながった時に呼ばれる
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in

            if let msStream = obj as? SKWMediaStream{
                
                self.isReconnect = false
                self.remoteStream = msStream
                
                DispatchQueue.main.async {
                    //self.targetPeerIdLabel.text = self.remoteStream?.peerId
                    //self.targetPeerIdLabel.textColor = UIColor.darkGray
                    
                    //20201118 comment out
                    //self.castSelectedDialog.isHidden = true
                    self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                    
                    //20201118追加
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                        self.castSelectedDialog.isHidden = true
                    }
                    
                }
                //self.changeConnectionStatusUI(connected: true)
            }
            
            //イヤホンの抜き差し対応
            self.addAudioSessionObservers()
            
        })
        
        // MARK: MEDIACONNECTION_EVENT_CLOSE
        //相手と切断された時に呼ばれる＞呼ばれる
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            if let _ = obj as? SKWMediaConnection{
                if(self.isReconnect == true)
                {
                    return
                }
                DispatchQueue.main.async {
                    //ストリーマーの方の切断時処理はストリーマーの異常終了したときの処理と、ポイント関連の計算のみ
                    if(self.appDelegate.listener_live_close_btn_tap_flg == 1){
                        UserDefaults.standard.set(0, forKey: "live_cast_id")
                        UserDefaults.standard.set("", forKey: "live_cast_name")
                        self.endLiveDo()//これ重要（SKYWAYの接続を完全にクリア）
                    }else{
                        //ストリーマーの状態を取得
                        var stringUrl = Util.URL_GET_LIVE_CAST_STATUS
                        stringUrl.append("?user_id=")
                        stringUrl.append(self.liveCastId)
                        
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
                                    let json = try decoder.decode(UtilStruct.ResultCastInfoJson.self, from: data!)
                                    //self.idCount = json.count

                                    //ただしゼロ番目のみ参照可能
                                    for obj in json.result {
                                        self.cast_login_status_check = obj.login_status
                                        self.cast_live_user_id_check = obj.live_user_id
                                        self.cast_reserve_user_id_check = obj.reserve_user_id
                                        self.cast_reserve_peer_id_check = obj.reserve_peer_id
                                        self.cast_reserve_flg_check = obj.reserve_flg

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
                            //ストリーマーの状態が1と８以外の場合（＝異常終了）
                            if(self.cast_login_status_check != "1"
                                && self.cast_login_status_check != "8"){
                                //ストリーマーの異常終了に関してのみここで処理
                                //１分以内の場合：コインの返却・スターの返却＞「返却はしない」に変更
                                //延長時の場合：返却はしない
                                if(self.appDelegate.count < self.appDelegate.init_seconds){
                                    //１分以内の場合
                                    //アラート履歴に保存する
                                    //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                                    //GET:alert_type, cast_id, user_id, cast_rank, live_time_count, star_temp, coin_temp
                                    var stringUrl = Util.URL_ALERT_RIREKI
                                    stringUrl.append("?alert_type=2&cast_id=")
                                    stringUrl.append(String(self.appDelegate.request_cast_id))
                                    stringUrl.append("&user_id=")
                                    stringUrl.append(String(self.user_id))
                                    stringUrl.append("&cast_rank=")
                                    stringUrl.append(self.strCastRank)
                                    stringUrl.append("&live_time_count=")
                                    stringUrl.append(String(self.appDelegate.count))
                                    stringUrl.append("&star_temp=")
                                    stringUrl.append("0")//可能であれば入れたいが必須でない
                                    stringUrl.append("&coin_temp=")
                                    stringUrl.append("0")//可能であれば入れたいが必須でない
                                    
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
                                                //ここまでに処理を記述
                                                dispatchGroup.leave()
                                            }
                                        })
                                        task.resume()
                                    }
                                    // 全ての非同期処理完了後にメインスレッドで処理
                                    dispatchGroup.notify(queue: .main) {
                                        //処理が終わった後に実行する処理
                                        //firebaseのデータをリスナー側でクリア
                                        self.rootRef.child(Util.INIT_FIREBASE
                                            + "/" + String(self.appDelegate.request_cast_id)).removeValue()
                                        
                                        UserDefaults.standard.set(0, forKey: "live_cast_id")
                                        UserDefaults.standard.set("", forKey: "live_cast_name")
                                        
                                        self.endLiveDo()
                                    }
                                }else{
                                    //延長時の場合
                                    //自分のuser_idを指定
                                    //let user_id = UserDefaults.standard.integer(forKey: "user_id")
                                    //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                                    //GET:alert_type, cast_id, user_id, cast_rank, live_time_count, star_temp, coin_temp
                                    var stringUrl = Util.URL_ALERT_RIREKI
                                    stringUrl.append("?alert_type=2&cast_id=")
                                    stringUrl.append(String(self.appDelegate.request_cast_id))
                                    stringUrl.append("&user_id=")
                                    stringUrl.append(String(self.user_id))
                                    stringUrl.append("&cast_rank=")
                                    stringUrl.append(self.strCastRank)
                                    stringUrl.append("&live_time_count=")
                                    stringUrl.append(String(self.appDelegate.count))
                                    stringUrl.append("&star_temp=")
                                    stringUrl.append("0")//可能であれば入れたいが必須でない
                                    stringUrl.append("&coin_temp=")
                                    stringUrl.append("0")//可能であれば入れたいが必須でない
                                    
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
                                                //ここまでに処理を記述
                                                dispatchGroup.leave()
                                            }
                                        })
                                        task.resume()
                                    }
                                    // 全ての非同期処理完了後にメインスレッドで処理
                                    dispatchGroup.notify(queue: .main) {
                                        print("処理が終わった後に実行する処理")
                                        //延長時にストリーマーが異常終了した場合
                                        // >コインなどは特に返却しない
                                        UserDefaults.standard.set(0, forKey: "live_cast_id")
                                        UserDefaults.standard.set("", forKey: "live_cast_name")
                                        self.endLiveDo()
                                    }
                                }
                            }else{
                                //正常終了の場合
                                //サシライブが終了しましたのメッセージを出力
                                UserDefaults.standard.set(0, forKey: "live_cast_id")
                                UserDefaults.standard.set("", forKey: "live_cast_name")
                                
                                self.endLiveDo()
                            }
                        }
                    }
                }
                //self.changeConnectionStatusUI(connected: false)
            }
        })
    }
    
    private func handleDataConnectionOpen() {
        //ライブ中
        //Util.loginDo(user_id:self.user_id, status:2)
        
        //ゼロでなければ、直前にライブ配信を行っていたことになる
        let liveCastIdTemp = UserDefaults.standard.integer(forKey: "live_cast_id")
        //UserDefaults.standard.set(0, forKey: "live_cast_id")

        if(liveCastIdTemp > 0){
            //復帰処理の場合はポイントなどの計算は行わない
        }else{
            //復帰処理を行うため、userDefaultsに保存
            UserDefaults.standard.set(self.liveCastId, forKey: "live_cast_id")
            UserDefaults.standard.set(self.strUserName, forKey: "live_cast_name")
            
            /**********************************************/
            //ポイントなどの計算
            /**********************************************/
            //let point = Util.INIT_POINT_BY_ONE
            let point = self.appDelegate.live_pay_coin
            
            //スターの追加はストリーマー側で処理する
            //リスナー側は何もしない（FireBaseにも何もしない）

            //コイン消費履歴に履歴を保存する
            UtilFunc.writePointUseRirekiType58(type:5,
                                         point:point,
                                         user_id:self.user_id,
                                         target_user_id:self.appDelegate.request_cast_id)

            //1枠分のコインを消費(加えて現在のコイン数も取得)
            //(writePointUseRirekiType58に処理が含まれるためコメントアウト)
            //UtilFunc.pointUseD(type:0, userId:self.user_id, point:point)

            //絆レベルの更新
            //connect_levelの更新、pair_month_rankingの更新が必要
            //1回の配信で加算される経験値
            let live_connection_point_temp: Int = Util.CONNECTION_POINT_LIVE * Int(point)
            let live_add_point:Int = Util.CONNECTION_POINT_LIVE_ONE + live_connection_point_temp
            
            //絆レベルの更新(値プラス or マイナス)
            UtilFunc.saveConnectLevelNew(user_id:self.user_id, target_user_id:Int(self.liveCastId)!, exp:live_add_point, live_count:1, present_point:0, flg:1)

            //iphone Xでは接続時にここで落ちる
            let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")

            //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
            UtilFunc.savePairMonthRanking(user_id:self.user_id, cast_id:Int(self.liveCastId)!, exp:Int(Double(point)*strConnectBonusRate))
            
            //絆レベルなど相手との情報を取得
            UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:Int(self.liveCastId)!)
            //self.getConnectInfo()
            /**********************************************/
            //ポイントなどの計算(ここまで)
            /**********************************************/
            
            /**********************************************/
            //下記を追加(2018/12/29)
            //サシライブに参加しました！というメッセージをタイムラインに流す
            //少し遅れて流さないと、ストリーマー側にアイコンが表示されないことがある
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // 3.0秒後に実行したい処理
                self.send(text: "サシライブに参加しました！")
                self.messageTableView.reloadData()
                //self.messageTextField.text = nil
                self.sendTextEditView.text = nil
            }
            /**********************************************/
        }

        //ストリーマーのダイアログを作成しておく
        self.castInfoDialog = UINib(nibName: "OnLiveCastInfo", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! OnLiveCastInfo
        //最初は非表示(ストリーマー情報ダイアログ)
        //画面サイズに合わせる
        self.castInfoDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.castInfoDialog)
        self.castInfoDialog.isHidden = true

        //経過時間を初期化
        self.appDelegate.count = 0

        //タイマーを動かす
        if(self.timerUser.isValid == true){
            //何も処理しない
        }else{
            //タイマーをスタート
            self.timerUser = Timer.scheduledTimer(timeInterval:1.0,
                                                  target: self,
                                                  selector: #selector(self.timerInterruptUser(_:)),
                                                  userInfo: nil,
                                                  repeats: true)
        }
        
        //自分のIDを取得
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.my_photo_flg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
        self.my_photo_name = UserDefaults.standard.string(forKey: "myPhotoName")!

        //重要(リアルタイムデータベースを使用)
        self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE
            + "/"
            + self.liveCastId + "/" + String(self.user_id))
        
        //イベント監視
        // クラウド上で、ノード Util.INIT_FIREBASE に変更があった場合のコールバック処理
        self.handle = self.conditionRef.observe(.value, with: { snap in
            
            if(snap.exists() == false){
                //print("すでにデータがないMediaConnectionViewController+CommonSkyway")
                //ストリーマー側が通報の場合にのみここを通る（？）
                UserDefaults.standard.set(0, forKey: "live_cast_id")
                UserDefaults.standard.set("", forKey: "live_cast_name")
                self.endLiveDo()
                
                return
            }

            //print("ノードの値が変わりました！: \((snap.value as AnyObject).description)")
            self.temp_dict = snap.value as! [String : AnyObject]

            //配信時間の同期
            let live_time_temp = self.temp_dict["live_time"] as! Int
            if(live_time_temp > 0){
                self.appDelegate.count = live_time_temp
                
                //ゼロに戻す
                let data = ["live_time": 0, "status_listener": 2]
                self.conditionRef.updateChildValues(data)

                return
            }
            
            //必ず下記の処理は実行されるようにする
            //配信ポイントの更新
            //let cast_live_point = dict["cast_live_point"] as! Int
            self.temp_cast_live_point = self.temp_dict["cast_live_point"] as! Int
            self.livePointLbl.text = UtilFunc.numFormatter(num: self.temp_cast_live_point) + " pt"

        })
    }

    private func handleReceivedData(_ data: Data) {
        guard let strValue = String(data: data, encoding: .utf8) else {
            return
        }
        handleReceivedText(strValue)
    }

    private func handleReceivedText(_ strValue: String) {
        if(strValue.contains("画面リフレッシュ"))
        {
            self.refreshAction()
            return
        }
        print("get data: \(strValue)")
        let message = Message(sender: Message.SenderType.get, text: strValue)
        //self.messages.insert(message, at: 0)
        self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合
        
        //MediaConnectionViewController.messageTableView.reloadData()
        self.messageTableView.reloadData()
    }

    //チャットのコールバック
    func setupDataConnectionCallbacks(dataConnection:SKWDataConnection){
        
        // MARK: DATACONNECTION_EVENT_OPEN
        //相手につながった時に呼ばれる
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_OPEN, callback: { (obj) -> Void in

            //if let dataConnection = obj as? SKWDataConnection{
            if (obj as? SKWDataConnection) != nil{
                self.handleDataConnectionOpen()
            }
        })
        
        // MARK: DATACONNECTION_EVENT_DATA
        //何かメッセージがきた時に呼ばれる（自分からのメッセージは含まない）
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_DATA, callback: { (obj) -> Void in
            
            let strValue:String = obj as! String
            self.handleReceivedText(strValue)
        })
        
        // MARK: DATACONNECTION_EVENT_CLOSE
        //相手と切断された時に呼ばれる＞呼ばれる
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            print("close data connection")
            //self.dataConnection = nil>通話の終了処理の方へ移動
            //self.changeConnectionStatusUI(connected: false)
            
            //onda add 2020/11/09
            //サシライブが終了しましたのメッセージを出力
            UserDefaults.standard.set(0, forKey: "live_cast_id")
            UserDefaults.standard.set("", forKey: "live_cast_name")
            self.endLiveDo()
            
        })
    }

    func setupDataConnectionCallbacks() {
        self.handleDataConnectionOpen()
    }
    
    func refreshAction(){
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
        self.castSelectedDialog.closeBtn.isHidden = true
        //最前面へ
        self.castSelectedDialog.infoLbl.isHidden = false
        self.castSelectedDialog.bringSubviewToFront(self.castSelectedDialog.infoLbl)
        /***************************/
        //ラベル作成(ここまで)
        /***************************/
        self.castSelectedDialog.isHidden = false
        //self.view.bringSubviewToFront(self.castSelectedDialog)
        self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialog)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print(self.liveCastId)
            self.sessionClose()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print(self.liveCastId)
            self.setup()
        }
        
        self.send(text: "画面リフレッシュ")
    }
    
    func effectClear(){
        //グラデーションをクリア
        self.gradientLayer.removeFromSuperlayer()
        
        if self.effectView == nil {
        }else{
            //エフェクト効果をクリア
            self.effectView.removeFromSuperview()
        }
        
        if self.effectImageView == nil {
        }else{
            //エフェクト効果をクリア
            self.effectImageView.removeFromSuperview()
        }
    }
    
    func effectDo(effect_id: Int){
        if(effect_id == 0){
            //クリア
            self.effectClear()
            
        }else if(effect_id == 1){
            //クリア
            self.effectClear()
            
            //Effect効果009(アニメーションGIF)
            //UIImageを作る.
            //let myImage = UIImage(named: "animation001")!

            do {
                let gif = try UIImage(gifName: "animation001")
                self.effectImageView = UIImageView(gifImage: gif, loopCount: -1) // Use -1 for infinite loop
                self.effectImageView.isUserInteractionEnabled = false
                self.effectImageView.alpha = 0.3
                //imageview.frame = view.bounds
                self.effectImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.view.addSubview(self.effectImageView)
            } catch {
                // error handling
            }
        }else if(effect_id == 2){
            //クリア
            self.effectClear()
            
            //Effect効果001
            //self.effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT))
            self.effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            
            // coverViewの背景
            self.effectView.backgroundColor = Util.EFFECT_COLOR_001
            // 透明度を設定
            //effectView.alpha = 0.4
            self.effectView.isUserInteractionEnabled = false
            self.view.addSubview(self.effectView)

        }else if(effect_id == 3){
            //クリア
            self.effectClear()
            
            //Effect効果002
            self.effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            // coverViewの背景
            self.effectView.backgroundColor = Util.EFFECT_COLOR_002
            // 透明度を設定
            //effectView.alpha = 0.4
            self.effectView.isUserInteractionEnabled = false
            self.view.addSubview(self.effectView)

        }else if(effect_id == 4){
            //クリア
            self.effectClear()
            
            //Effect効果008(グラデーションをかける)
            //中央に向けたグラデーションを追加
            self.gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.view.layer.addSublayer(self.gradientLayer)

        }else if(effect_id == 5){
            //クリア
            self.effectClear()
            
            //Effect効果004
            self.effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            // coverViewの背景
            self.effectView.backgroundColor = Util.EFFECT_COLOR_004
            // 透明度を設定
            //effectView.alpha = 0.4
            self.effectView.isUserInteractionEnabled = false
            self.view.addSubview(self.effectView)
            
        }else if(effect_id == 6){
            //クリア
            self.effectClear()
            
            //Effect効果006(ぼかす)
            // ブラーエフェクトを作成
            let blurEffect = UIBlurEffect(style: .light)
            
            // ブラーエフェクトからエフェクトビューを作成
            self.effectView = UIVisualEffectView(effect: blurEffect)
            
            // エフェクトビューのサイズを画面に合わせる
            self.effectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            self.effectView.isUserInteractionEnabled = false
            self.view.addSubview(self.effectView)
        }
    }
    
    //自動応答専用
    //$$$_auto_から始まる文字列は運営からとする
    /*
     モノポル公式
     $$$_auto_01:このサシライブはテスト用の自動映像です。サシライブの機能を試してみることができます。
     ▼▼▼5秒後に以下を表示
     モノポル公式
     $$$_auto_02:サシライブでは、あなたの映像は映りません。映像が映るのはストリーマーのみです。
     */
    private func sendDataMessage(_ text: String) {
        if let localDataStream = localDataStream {
            let data = Data(text.utf8)
            localDataStream.write(data)
        } else {
            self.dataConnection?.send(text as NSObject)
        }
    }

    func sendAuto(text: String) {
        //print("送信した文字列")
        //print(text)
        self.sendDataMessage(text)
        let message = Message(sender: Message.SenderType.send, text: text)
        //print(message.text as Any)
        //self.messages.insert(message, at: 0)
        self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // 0.3秒後に実行したい処理
            self.messageTableView.reloadData()
            //self.messageTextField.text = nil
        }
        
        //履歴保存(運営からリスナーへ送信)
        UtilFunc.saveChatRireki(type:1, from_user_id:0, to_user_id:self.user_id, present_id:0, chat_text:text, status:1)
    }
    
    func send(text: String) {
        //$$$から始まる文字列はスタンプとする
        //guard let text = self.messageTextField.text else{
        //    return
        //}
        //self.view.endEditing(true)
        if(text.contains("画面リフレッシュ"))
        {
            isReconnect = true
            self.sendDataMessage(text)
        } else if(!text.hasPrefix("$$$") && text != "") {
            //print("送信した文字列")
            //print(text)
            self.sendDataMessage(text)
            let message = Message(sender: Message.SenderType.send, text: text)
            //print(message.text as Any)
            //self.messages.insert(message, at: 0)
            self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 0.3秒後に実行したい処理
                self.messageTableView.reloadData()
                //self.messageTextField.text = nil
            }
            
            //履歴保存
            UtilFunc.saveChatRireki(type:1, from_user_id:self.user_id, to_user_id:Int(self.liveCastId)!, present_id:0, chat_text:text, status:1)
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
                //プレゼントの送信(そのままの文字列を入れる。画像用のCellを使用するため)
                send_text = text
            }
            self.sendDataMessage(send_text)
            let message = Message(sender: Message.SenderType.send, text: send_text)
            //print(message.text as Any)
            //self.messages.insert(message, at: 0)
            self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 0.3秒後に実行したい処理
                self.messageTableView.reloadData()
                //self.messageTextField.text = nil
            }
            
            //履歴保存
            UtilFunc.saveChatRireki(type:2, from_user_id:self.user_id, to_user_id:Int(self.liveCastId)!, present_id:0, chat_text:send_text, status:1)
        }
    }
    
    /*
    ログを出すタイミングは、
    コイン残りが
    104（約8分）
    65（約5）
    26（約2分）
    このメッセージを出すときは、チャットを強制オンに。
     */
    func sendNocoin(coin: Int) {
        var send_text = ""

        send_text = "$$$_nocoin_" + String(coin)
        
        self.sendDataMessage(send_text)
        let message = Message(sender: Message.SenderType.send, text: send_text)
        //print(message.text as Any)
        //self.messages.insert(message, at: 0)
        self.messages.insert(message, at: self.messages.count)//下から上に投稿を流す場合
        //self.messageTableView.reloadData()
        //self.messageTextField.text = nil
        
        //履歴保存
        UtilFunc.saveChatRireki(type:3, from_user_id:0, to_user_id:self.user_id, present_id:0, chat_text:send_text, status:1)
    }
}
