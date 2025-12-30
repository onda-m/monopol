//
//  LiveReturnDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/11/02.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit
//import Firebase

class LiveReturnDialog: UIView {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // データベースへの参照
    //var rootRef = Database.database().reference()
    //var conditionRef = DatabaseReference()
    //var handle = DatabaseHandle()
    
    //プレゼントリスト関連
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var strUserId: String = ""
    var strNotifyFlg: String = ""
    var strUuid: String = ""
    var strUserName: String = ""
    var strPhotoFlg: String = ""
    var strPhotoName: String = ""
    var strValue01: String = ""
    var strValue02: String = ""
    var strValue03: String = ""
    //var strValue04: String = ""
    //var strValue05: String = ""
    var strPoint: String = ""
    var strLivePoint: String = ""
    var strWatchLevel: String = ""
    var strLiveLevel: String = ""
    var strCastRank: String = ""
    var strCastOfficialFlg: String = ""
    var strCastMonthRanking: String = ""
    var strCastMonthRankingPoint: String = ""
    var strTwitter: String = ""
    var strFacebook: String = ""
    var strInstagram: String = ""
    var strHomepage: String = ""
    var strFreetext: String = ""
    var strNoticeText: String = ""
    var strLivePassword: String = ""
    var strLiveTotalCount: String = ""
    var strLoginStatus: String = ""
    var strLiveUserId: String = ""
    //var strLoginTime: String = ""
    //var strInsTime: String = ""
    var strReserveUserId: String = ""
    var strConnectLevel: String = ""
    var strConnectExp: String = ""
    var strConnectLiveCount: String = ""
    var strConnectPresentPoint: String = ""
    var strBlackListId: String = ""
    
    //ユーザー情報取得用
    struct UserResult: Codable {
        let user_id: String
        let notify_flg: String
        let uuid: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let value01: String//性別
        let value02: String//フォロワー数
        let value03: String//フォロー数
        //let value04: String//未使用
        //let value05: String//未使用
        let point: String//所有しているポイント
        let live_point: String//配信ポイント
        let watch_level: String//視聴レベル
        let live_level: String//配信レベル
        let cast_rank: String//1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
        let cast_official_flg: String//1:公式
        let cast_month_ranking: String//キャスト月間ランキング
        let cast_month_ranking_point: String//キャスト月間ランキングポイント
        let twitter: String//
        let facebook: String//
        let instagram: String//
        let homepage: String//
        let freetext: String//
        let notice_text: String//
        let live_password: String//
        let live_total_count: String//累計配信数
        let login_status: String//
        let live_user_id: String//ライブ中のID
        //let login_time: String//
        //let ins_time: String//
        let reserve_user_id: String//
        let connect_level: String//
        let connect_exp: String//
        let connect_live_count: String//
        let connect_present_point: String//
        let black_list_id: String//ブラックリストに入っている場合はゼロ以外が入る
    }
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // backgroundColorを使って透過させる。
        self.baseView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)

        //ダイアログ関連
        // 枠線の色
        self.mainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.mainView.layer.borderWidth = 2
        
        // 角丸
        self.mainView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainView.layer.masksToBounds = true
        
        // 角丸
        self.okBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.okBtn.layer.masksToBounds = true
        
        // 角丸
        self.cancelBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.cancelBtn.layer.masksToBounds = true
        
        //フォントの自動調整
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.3

    }
    
    func setLabel(){
        let liveCastNameTemp = UserDefaults.standard.string(forKey: "live_cast_name")
        
        if(liveCastNameTemp != ""){
            self.titleLabel.text = liveCastNameTemp! + "さんのライブ配信の途中です。配信を続けますか？"
        }else{
            self.titleLabel.text = "ライブ配信の途中です。配信を続けますか？"
        }
    }
    
    @IBAction func tapOkBtn(_ sender: Any) {
        
        //self.removeFromSuperview()
        self.isHidden = true
        
        //ライブ配信の復帰処理
        //ゼロでなければ、直前にライブ配信を行っていたことになる
        //UserDefaults.standard.set(self.liveCastId, forKey: "live_cast_id")
        let liveCastIdTemp = UserDefaults.standard.integer(forKey: "live_cast_id")
        //UserDefaults.standard.set(0, forKey: "live_cast_id")
        
        //ランクごとのポイント関連の取得をここで行う。（本来はCastSelectedDialogで行っている）
        //UserDefaults.standard.set(self.get_live_point, forKey: "get_live_point")
        //UserDefaults.standard.set(self.live_coin, forKey: "live_pay_coin")
        //UserDefaults.standard.set(self.live_ex_coin, forKey: "live_pay_ex_coin")

        //1枠の秒数
        self.appDelegate.init_seconds = UserDefaults.standard.integer(forKey: "live_sec")
        
        //配信ランクに関する必要なコイン、得られる配信ポイントを保存しておく
        //キャストが得られるポイント(最初の5分枠で得られるポイント)
        self.appDelegate.get_live_point = UserDefaults.standard.integer(forKey: "get_live_point")
        //延長時キャストが得られるポイント
        self.appDelegate.ex_get_live_point = UserDefaults.standard.integer(forKey: "ex_get_live_point")
        //消費するコイン
        self.appDelegate.live_pay_coin = UserDefaults.standard.double(forKey: "live_pay_coin")
        //消費するコイン(延長時)
        self.appDelegate.live_pay_ex_coin = UserDefaults.standard.double(forKey: "live_pay_ex_coin")
        self.appDelegate.min_reserve_coin = UserDefaults.standard.integer(forKey: "min_reserve_coin")
        //self.appDelegate.cancel_coin = UserDefaults.standard.integer(forKey: "cancel_coin")
        //self.appDelegate.cancel_get_star = UserDefaults.standard.integer(forKey: "cancel_get_star")
        
        //下記を実行する前に他に準備が必要かも
        //タップの回数を接続状態に
        //UserDefaults.standard.set(99, forKey: "selectedIndexCount")
        //self.appDelegate.request_count_num = 99
        //相手のキャストIDを設定
        self.appDelegate.request_cast_id = liveCastIdTemp
        self.appDelegate.sendId = String(liveCastIdTemp)
        
        //直前のライブ配信のキャストIDをクリアする
        //UserDefaults.standard.set(0, forKey: "live_cast_id")
        //UserDefaults.standard.set("", forKey: "live_cast_name")
        
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        self.getModelInfo(castId:liveCastIdTemp, userId:user_id)
        //UtilToViewController.toMediaConnectionViewController()
    }
    
    //下記は未使用
    @IBAction func tapCancelBtn(_ sender: Any) {
        /*
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let cast_id = UserDefaults.standard.integer(forKey: "live_cast_id")
        
        conditionRef = self.rootRef.child(Util.INIT_FIREBASE + "/" + Util.INIT_PEER_PREF + String(cast_id) + "/" + String(user_id))
        let data = ["connection_flg":-2]
        self.conditionRef.updateChildValues(data)
        
        //直前のライブ配信のキャストIDをクリアする
        UserDefaults.standard.set(0, forKey: "live_cast_id")
        UserDefaults.standard.set("", forKey: "live_cast_name")
        self.isHidden = true
         */
    }

    func getModelInfo(castId:Int, userId:Int){
        //モデル詳細取得
        var stringUrl = Util.URL_USER_INFO
        stringUrl.append("?user_id=")
        stringUrl.append(String(castId))
        stringUrl.append("&my_user_id=")
        stringUrl.append(String(userId))
        
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
                    let json = try decoder.decode(ResultJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                    for obj in json.result {
                        self.strUserId = obj.user_id
                        self.strUuid = obj.uuid
                        self.strUserName = obj.user_name.toHtmlString()
                        self.strPhotoFlg = obj.photo_flg
                        self.strPhotoName = obj.photo_name
                        self.strValue01 = obj.value01
                        self.strValue02 = obj.value02
                        self.strValue03 = obj.value03
                        //strValue04 = obj.value04
                        //strValue05 = obj.value05
                        self.strPoint = obj.point
                        self.strLivePoint = obj.live_point
                        self.strWatchLevel = obj.watch_level
                        self.strLiveLevel = obj.live_level
                        self.strCastRank = obj.cast_rank
                        self.strCastOfficialFlg = obj.cast_official_flg
                        self.strCastMonthRanking = obj.cast_month_ranking
                        self.strCastMonthRankingPoint = obj.cast_month_ranking_point
                        self.strTwitter = obj.twitter.toHtmlString()
                        self.strFacebook = obj.facebook.toHtmlString()
                        self.strInstagram = obj.instagram.toHtmlString()
                        self.strHomepage = obj.homepage.toHtmlString()
                        self.strFreetext = obj.freetext.toHtmlString()
                        self.strNoticeText = obj.notice_text
                        self.strLiveTotalCount = obj.live_total_count
                        //strNoticePhotoPath = obj.notice_photo_path
                        self.strLoginStatus = obj.login_status
                        self.strLiveUserId = obj.live_user_id
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
                        self.strReserveUserId = obj.reserve_user_id
                        self.strConnectLevel = obj.connect_level//絆レベル
                        self.strConnectExp = obj.connect_exp//絆レベルの経験値
                        self.strConnectLiveCount = obj.connect_live_count//視聴回数
                        self.strConnectPresentPoint = obj.connect_present_point//プレゼントしたポイント
                        self.strBlackListId = obj.black_list_id
                        
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
            //ライブ配信中の状態(login_status=2、４、５、6)で、ライブ中のID(live_user_id)が自分の場合
            if((self.strLoginStatus == "2" || self.strLoginStatus == "4" || self.strLoginStatus == "5" || self.strLoginStatus == "6" || self.strLoginStatus == "7")
                && self.strLiveUserId == String(userId)){
                self.appDelegate.request_cast_id = Int(self.strUserId)!
                self.appDelegate.request_notify_flg = Int(self.strNotifyFlg)
                self.appDelegate.request_cast_uuid = self.strUuid
                self.appDelegate.request_cast_name = self.strUserName
                self.appDelegate.request_cast_rank = self.strCastRank
                self.appDelegate.request_password = self.strLivePassword
                //self.appDelegate.request_reserve_user_id = Int(self.strReserveUserId)!
                //self.appDelegate.request_frame_count = 1//枠数
                //self.appDelegate.request_count_num = 99//99:ライブ中
                //self.appDelegate.request_cast_login_status = 2//通話中
                self.appDelegate.request_live_user_id = userId
                
                UtilToViewController.toMediaConnectionViewController()
            }else{
                //直前のライブ配信のキャストIDをクリアする
                UserDefaults.standard.set(0, forKey: "live_cast_id")
                UserDefaults.standard.set("", forKey: "live_cast_name")
                //self.showAlert()
                
                //showalert
                UtilFunc.showAlert(message:"すでにライブ配信が終了しています", vc:self.parentViewController()!, sec:2.0)
            }
        }
    }

    /*
    //数秒後に勝手に閉じる
    func showAlert() {
        // アラート作成
        let alert = UIAlertController(title: nil, message: "すでにライブ配信が終了しています", preferredStyle: .alert)
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
     
        // アラート表示
        self.parentViewController()!.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                alert.dismiss(animated: true, completion: nil)
                
                //トップに戻す
                //UtilToViewController.toMainViewController()
            })
        })
    }*/
}
