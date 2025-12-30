//
//  WaitViewController+CommonEffect.swift
//  swift_skyway
//
//  Created by onda on 2019/01/26.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: setup skyway
extension WaitViewController{

    //ストリーマーのエフェクトのチェック(リスナー側にも同じような処理がある)
    //GET: cast_id
    func effectCheckDoForWait(cast_id:Int){
        
        //if(self.lock_flg == 1){
            //ロック状態の時は動かさない
        //    return
        //}
        
        var effectIdTemp = 0
        var stringUrl = Util.URL_LIVE_EFFECT_CHECK_DO
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //print("aaaa")
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    //let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try self.decoder.decode(UtilStruct.ResultEffectJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        effectIdTemp = Int(obj.effect_flg01)!
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
            //ライブ中のエフェクト用
            //var effect_id: Int = 0//ライブ配信で設定したエフェクトID
            //var effect_id_before: Int = 0//ライブ配信で設定したエフェクトID(直前の比較用)
            self.appDelegate.live_effect_id_before = effectIdTemp
            self.appDelegate.live_effect_id = effectIdTemp

            self.effectDo(effect_id: self.appDelegate.live_effect_id)
            
            //エフェクトを監視する処理(1秒おき)
            //タイマーが停止中だったら実行
            self.startEffectTimer()
        }
    }
    
    //自分自身(ストリーマー)の画面にエフェクトを反映させる処理
    //同時に予約数ラベル、配信ポイントラベルも更新する
    @objc func effectCheck(_ sender: Timer) { //(_ sender: Timer) Timerクラスのインスタンスを受け取る
        //秒数をプラス１する
        effectTimerCount = effectTimerCount + 1
        
        //共通のダイアログを表示(念のため：すでにダイアログがあれば何もしない)
        self.setCommonDialog()

        if(self.appDelegate.live_effect_id_before == self.appDelegate.live_effect_id){
            //直前のFLGから変更がない場合は、何もしない
        }else{
            self.effectDo(effect_id: self.appDelegate.live_effect_id)
            //連続して行われるのを防ぐため
            self.appDelegate.live_effect_id_before = self.appDelegate.live_effect_id
        }

        //配信ポイント(累計)の更新（画面左上）
        let myLivePointTemp = UserDefaults.standard.integer(forKey: "myLivePoint")
        if self.livePointLbl != nil {
            self.livePointLbl.text = String(UtilFunc.numFormatter(num: myLivePointTemp)) + " pt"
        }

        if(self.listenerStatus != 1){
            //if(self.appDelegate.reserveStatus == "1"){
            if(self.appDelegate.live_target_user_id == 0){
                //予約なしの待機中
                print("予約なしの待機中")
                
                if self.nextWaitTimeView != nil {
                    //予約している人の配信までの時間を非表示
                    self.nextWaitTimeView.isHidden = true
                }
                
                //切り替え時のメッセージを表示
                self.castWaitDialog.statusLbl.isHidden = false
                
                //待機中にする
                self.appDelegate.reserveStatus = "1"
            }else{
                //予約なしのライブ中
                if self.nextWaitTimeView != nil {
                    //予約している人の配信までの時間を非表示
                    self.nextWaitTimeView.isHidden = true
                }
            }
        }

        //3秒おきに更新
        //URLはvar stringUrlGetReserveList = Util.URL_RESERVE_INFO_BY_CAST
        if(CGFloat(self.effectTimerCount)
            .truncatingRemainder(dividingBy: 3.0) == 0){
            
            //タイムラインのテーブルをリロードする
            self.castWaitDialog.downLiveInfoTableView.reloadData()
        }//3秒おきはここまで
    }
    
    func effectDo(effect_id: Int){
        if(effect_id == 0){
            //クリア
            self.effectClear()
            
        }else if(effect_id == 1){
            self.effectDo001()

        }else if(effect_id == 2){
            self.effectDo002()
            
        }else if(effect_id == 3){
            self.effectDo003()
            
        }else if(effect_id == 4){
            self.effectDo004()
            
        }else if(effect_id == 5){
            self.effectDo005()
            
        }else if(effect_id == 6){
            self.effectDo006()
            
        }
        /*
        else if(effect_id == 7){
            self.effectDo007()
            
        }else if(effect_id == 8){
            self.effectDo008()
            
        }else if(effect_id == 9){
            self.effectDo009()
        }*/
    }
    
    //共通のクリア処理
    func effectClear(){
        //グラデーションをクリア
        gradientLayer.removeFromSuperlayer()

        //self.view.layer.removeFromSuperlayer()
        
        //下記を使用してぼかした場合
        //https://qiita.com/shirape/items/056719c7a717c1281c6b

        //effectView.isHidden = true
        //gradientLayer.isHidden = true
        //effectImageView.isHidden = false
        
        if effectView == nil {
        }else{
            effectView.removeFromSuperview()
        }
        
        if effectImageView == nil {
        }else{
            effectImageView.removeFromSuperview()
        }
    }
    
    //波エフェクト
    func effectDo001() {
        //共通のクリア処理
        self.effectClear()
        
        //Effect効果009(アニメーションGIF)
        //UIImageを作る.
        //let myImage = UIImage(named: "animation001")!
        //let gif = UIImage(gifName: "animation001")
        do {
            let gif = try UIImage(gifName: "animation001")
            effectImageView = UIImageView(gifImage: gif, loopCount: -1) // Use -1 for infinite loop
            effectImageView.isUserInteractionEnabled = false
            effectImageView.alpha = 0.3
            //imageview.frame = view.bounds
            effectImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        } catch {
            //print("error")
        }
        
        if(effectImageView.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            print("すでに追加(addsubview)済み")
        }else{
            print("addsubviewをする")
            self.view.addSubview(effectImageView)
            //effectImageView.startAnimating()
        }
    }
    
    //パープル
    func effectDo002() {
        //共通のクリア処理
        self.effectClear()
        
        //Effect効果001
        //effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT))
        effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        // coverViewの背景
        effectView.backgroundColor = Util.EFFECT_COLOR_001
        // 透明度を設定
        //effectView.alpha = 0.4
        effectView.isUserInteractionEnabled = false

        if(effectView.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            print("すでに追加(addsubview)済み")
        }else{
            print("addsubviewをする")
            self.view.addSubview(effectView)
        }
    }
    
    //ブルー
    func effectDo003() {
        //共通のクリア処理
        self.effectClear()
        
        //Effect効果002
        //effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT))
        effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        // coverViewの背景
        effectView.backgroundColor = Util.EFFECT_COLOR_002
        // 透明度を設定
        //effectView.alpha = 0.4
        effectView.isUserInteractionEnabled = false
        
        if(effectView.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            print("すでに追加(addsubview)済み")
        }else{
            print("addsubviewをする")
            self.view.addSubview(effectView)
        }
    }

    //スクリーン
    func effectDo004() {
        //共通のクリア処理
        self.effectClear()
        
        //Effect効果008(グラデーションをかける)
        //中央に向けたグラデーションを追加
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.view.layer.addSublayer(gradientLayer)
    }
        
    //ホワイト
    func effectDo005() {
        //共通のクリア処理
        self.effectClear()
        
        //Effect効果004
        effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        // coverViewの背景
        effectView.backgroundColor = Util.EFFECT_COLOR_004
        // 透明度を設定
        //effectView.alpha = 0.4
        effectView.isUserInteractionEnabled = false
        
        if(effectView.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            print("すでに追加(addsubview)済み")
        }else{
            print("addsubviewをする")
            self.view.addSubview(effectView)
        }
    }
    
    //画面をぼかす(未使用)
    func effectDo006() {
        //共通のクリア処理
        self.effectClear()
        
        //Effect効果006(ぼかす)
        // ブラーエフェクトを作成
        let blurEffect = UIBlurEffect(style: .light)
        
        // ブラーエフェクトからエフェクトビューを作成
        effectView = UIVisualEffectView(effect: blurEffect)
        
        // エフェクトビューのサイズを画面に合わせる
        effectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        effectView.isUserInteractionEnabled = false
        
        if(effectView.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            print("すでに追加(addsubview)済み")
        }else{
            print("addsubviewをする")
            self.view.addSubview(effectView)
        }
    }
}
