//
//  OnLiveCastInfo.swift
//  swift_skyway
//
//  Created by onda on 2018/06/26.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class OnLiveCastInfo: UIView {
    
    let iconSize: CGFloat = 12.0
    let iconSize2: CGFloat = 14.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var user_id: Int = 0//自分のID
    var cast_id: Int = 0
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var downView: UIView!
    
    //フリーテキスト
    @IBOutlet weak var freetextTextView: UITextView!
    
    @IBOutlet weak var imageView: EnhancedCircleImageView!
    @IBOutlet weak var nameField: UILabel!

    //ストリーマーの情報
    var strUserId: String = ""
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
    var strLiveTotalCount: String = ""
    //var strLoginStatus: String = ""
    //var strLoginTime: String = ""
    //var strInsTime: String = ""
    var strConnectLevel: String = ""
    var strConnectExp: String = ""
    var strConnectLiveCount: String = ""
    var strConnectPresentPoint: String = ""
    var strBlackListId: String = ""
    
    //ストリーマー情報取得用
    struct UserResult: Codable {
        let user_id: String
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
        let cast_month_ranking: String//ストリーマー月間ランキング
        let cast_month_ranking_point: String//ストリーマー月間ランキングポイント
        let twitter: String//
        let facebook: String//
        let instagram: String//
        let homepage: String//
        let freetext: String//
        let notice_text: String//
        let live_total_count: String//累計配信数
        //let login_status: String//
        //let login_time: String//
        //let ins_time: String//
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
    
    struct UserResultFollow: Codable {
        let to_user_id: String
        let mod_time: String
    }
    struct ResultJsonFollow: Codable {
        let count: Int
        let result: [UserResultFollow]
    }
    var followCount: Int = 0
    
    //絆レベルの情報の格納用
    var strLevelId: String = ""
    var strLevel: String = ""
    var strMinExp: String = ""
    var strMaxExp: String = ""
    var strBonusRate: String = ""
    var strStatus: String = ""
    
    struct UserResultConnectLevel: Codable {
        let level_id: String
        let level: String
        let min_exp: String
        let max_exp: String
        let bonus_rate: String
        let status: String
    }
    struct ResultJsonConnectLevel: Codable {
        let count: Int
        let result: [UserResultConnectLevel]
    }
    
    //あなたの＊＊＊＊のところ
    //あなたの視聴回数：15
    //あなたが送ったギフト：1486 pt
    @IBOutlet weak var yourInfoView: UIView!
    @IBOutlet weak var yourLiveCount: UILabel!
    @IBOutlet weak var yourPresentLbl: UILabel!
    
    //ランキングポイントのところ
    @IBOutlet weak var rankingPointLbl: UILabel!
    //絆レベルのところ
    @IBOutlet weak var connectLevelLbl: UILabel!
    //累計配信数
    @IBOutlet weak var allLiveCount: UILabel!
    
    //月間ランキングのラベル
    @IBOutlet weak var monthlyRankingLbl: UILabel!
    @IBOutlet weak var monthlyRankingView: UIView!
    
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var followView: UIView!
    
    @IBOutlet weak var followerCountLbl: UILabel!
    @IBOutlet weak var followCountLbl: UILabel!
    
    //フォローボタン
    @IBOutlet weak var followBtn: UIButton!
    
    //ブラックリストボタン
    @IBOutlet weak var blacklistBtn: UIButton!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // 枠線の色
        self.mainScrollView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.mainScrollView.layer.borderWidth = 2
        // 角丸
        self.mainScrollView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainScrollView.layer.masksToBounds = true
        
        //月間ランキング
        // 角丸
        self.monthlyRankingView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.monthlyRankingView.layer.masksToBounds = true
        self.monthlyRankingView.backgroundColor = Util.CAST_INFO_COLOR_MONTH_RANKING_LABEL
        
        //ランキングポイントのところ
        // 角丸
        self.rankingPointLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.rankingPointLbl.layer.masksToBounds = true

        self.rankingPointLbl.backgroundColor = Util.CAST_INFO_COLOR_RANKING_POINT_LABEL
        //ラベルの枠を自動調節する
        self.rankingPointLbl.adjustsFontSizeToFitWidth = true
        self.rankingPointLbl.minimumScaleFactor = 0.3
        
        //絆レベルのところ
        // 角丸
        self.connectLevelLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.connectLevelLbl.layer.masksToBounds = true
        self.connectLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
        //ラベルの枠を自動調節する
        self.connectLevelLbl.adjustsFontSizeToFitWidth = true
        self.connectLevelLbl.minimumScaleFactor = 0.3
        
        //累計配信数
        // 角丸
        self.allLiveCount.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.allLiveCount.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        self.allLiveCount.adjustsFontSizeToFitWidth = true
        self.allLiveCount.minimumScaleFactor = 0.3
        
        // 角丸
        //self.monthlyRankingLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //self.monthlyRankingLbl.layer.masksToBounds = true
        
        /*
        //リスナーを見るボタン
        // 枠線の色
        toListenerBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        toListenerBtn.layer.borderWidth = 1
        // 角丸
        toListenerBtn.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        toListenerBtn.layer.masksToBounds = true
        */
        
        // 枠線の色
        self.followerView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOWER_FRAME.cgColor
        // 枠線の太さ
        self.followerView.layer.borderWidth = 0.5
        // 角丸
        self.followerView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.followerView.layer.masksToBounds = true
        
        // 枠線の色
        self.followView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOWER_FRAME.cgColor
        // 枠線の太さ
        self.followView.layer.borderWidth = 0.5
        // 角丸
        self.followView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.followView.layer.masksToBounds = true
        
        // 枠線の色
        self.followBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.followBtn.layer.borderWidth = 1
        // 角丸
        self.followBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.followBtn.layer.masksToBounds = true
        
        /*
        //ダイレクトメールボタン
        // 角丸
        mailBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mailBtn.layer.masksToBounds = true
        */
        
        //ブラックリストボタン
        // 角丸
        self.blacklistBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.blacklistBtn.layer.masksToBounds = true
        // 枠線の色
        self.blacklistBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.blacklistBtn.layer.borderWidth = 1
        
        //self.noteLbl.text = "1回" + String(Util.INIT_MINUTES) + "分（" + String(Util.INIT_POINT_BY_ONE) + "ポイント消費）"
        
        //ラベルの枠を自動調節する
        self.nameField.adjustsFontSizeToFitWidth = true
        self.nameField.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        self.blacklistBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.blacklistBtn.titleLabel?.minimumScaleFactor = 0.3
    }
    
    func setValue(){
        //self.cast_id = Int(self.appDelegate.sendId!)!
        self.cast_id = self.appDelegate.request_cast_id
        //キャストのUUIDを取得
        //self.cast_uid = self.appDelegate.liveCastId!
        //自分のIDを取得
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //モデル詳細取得
        self.getModelInfo()
        //フォローボタンの変更
        self.getFollowInfo()
    }
    
    @IBAction func closeBtnBig(_ sender: Any) {
        self.isHidden = true
    }
    
    @IBAction func blacklistDo(_ sender: Any) {
        //ブラックリスト（保存）
        
        //くるくる表示開始
        //画面サイズに合わせる
        //self.busyIndicator.frame = self.frame
        // 貼り付ける
        //self.addSubview(self.busyIndicator)
        
        var stringUrl = Util.URL_SAVE_BLACKLIST
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(self.cast_id))
        stringUrl.append("&flg=1")
        //stringUrl.append(String(flg))
        
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
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            self.blacklistBtn.isEnabled = false
            self.blacklistBtn.setTitle("ブラックリストに設定済み", for: .normal)
            
            //くるくる表示終了
            //self.busyIndicator.removeFromSuperview()
        }
    }
    
    @IBAction func followDo(_ sender: Any) {
        //フォローボタンを押した時
        //flg=1:追加 2:削除
        if(self.followCount > 0){
            //この人をフォローしている場合
            follow(flg: 2)
        }else{
            //この人をフォローしていない場合
            follow(flg: 1)
        }
    }
    
    func follow(flg: Int!){
        //フォローする
        //フォローの追加・削除 GET:from_user_id,to_user_id,flg
        //flg=1:追加 2:削除
        var stringUrl = Util.URL_FOLLOW_DO
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(self.cast_id))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        
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
                    
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //self.CollectionView.reloadData()
            //self.nameField.text = "モデル名："+self.strNames[0]
            
            //現在の絆レベルの経験値
            var connection_exp: Int = Int(self.strConnectExp)!
            
            //flg=1:追加 2:削除
            if(flg == 1){
                UtilFunc.plusFollow()
                connection_exp = connection_exp + Util.CONNECTION_POINT_FOLLOW
            }else{
                UtilFunc.minusFollow()
                connection_exp = connection_exp - Util.CONNECTION_POINT_FOLLOW
            }
            
            //絆レベルの更新(値プラス or マイナス)
            self.saveConnectLevel(user_id:self.user_id, target_user_id:self.cast_id, exp:Util.CONNECTION_POINT_FOLLOW, live_count:0, present_point:0, flg:flg)
        }
    }
    
    func getModelInfo(){
        //モデル詳細取得
        var stringUrl = Util.URL_USER_INFO
        stringUrl.append("?user_id=")
        stringUrl.append(String(self.cast_id))
        stringUrl.append("&my_user_id=")
        stringUrl.append(String(self.user_id))
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
                        //strLoginStatus = obj.login_status
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
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
            //self.CollectionView.reloadData()
            
            //self.CollectionView.reloadData()
            if(self.strPhotoFlg == "1"){
                //写真を設定ずみ
                //let photoUrl = "user_images/" + String(self.cast_id) + "_profile.jpg"
                let photoUrl = "user_images/" + String(self.cast_id) + "/" + self.strPhotoName + "_profile.jpg"
                
                //画像キャッシュを使用
                self.imageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            }else{
                // UIImageをUIImageViewのimageとして設定
                self.imageView.image = UIImage(named:"no_image")
            }
            
            self.nameField.text = self.strUserName
            //self.connectLevelLbl.text = "絆Lv:" + self.strConnectLevel
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.connectLevelLbl.attributedText = UtilFunc.getInsertIconString(string: self.strConnectLevel, iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
            self.followCountLbl.text =  UtilFunc.numFormatter(num:Int(self.strValue03)!)
            self.followerCountLbl.text = UtilFunc.numFormatter(num:Int(self.strValue02)!)
            self.allLiveCount.text = "累計配信:" + UtilFunc.numFormatter(num:Int(self.strLiveTotalCount)!)
            
            //月間ランキングポイント
            //self.rankingPointLbl.text = "R:" + UtilFunc.numFormatter(num:Int(self.strCastMonthRankingPoint)!)
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.rankingPointLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(Double(self.strCastMonthRankingPoint)!)), iconImage: UIImage(named:"castinfo_rank_ico")!, iconSize: self.iconSize, lineHeight: 1.0)
            
            //月間ランキング
            if(self.strCastMonthRanking == "0" || self.strCastMonthRanking == ""){
                self.monthlyRankingLbl.text = "-位"
            }else{
                self.monthlyRankingLbl.text = UtilFunc.numFormatter(num:Int(self.strCastMonthRanking)!) + "位"
            }
            
            //ブラックリストのところ
            if(self.strBlackListId != "0" && self.strBlackListId != ""){
                //ブラックリストに設定済み
                self.blacklistBtn.isEnabled = false
                self.blacklistBtn.setTitle("ブラックリストに設定済み", for: .normal)
            }
            
            //あなたの視聴回数：15
            //あなたが送ったギフト：1486 pt
            self.yourLiveCount.text = "あなたの視聴回数:" + UtilFunc.numFormatter(num:Int(self.strConnectLiveCount)!)
            self.yourPresentLbl.text = "あなたが送ったギフト:" + UtilFunc.numFormatter(num:Int(self.strConnectPresentPoint)!) + " pt"
            
            //フリーテキストのところ
            //フリーテキスト
            var strFreeTextTemp = ""
            if(self.strFreetext != "" && self.strFreetext != "0" && self.strFreetext != "'0'"){
                strFreeTextTemp = self.strFreetext
            }
            if(self.strHomepage != "" && self.strHomepage != "0"){
                strFreeTextTemp.append("\n")
                strFreeTextTemp.append(self.strHomepage)
            }
            if(self.strTwitter != "" && self.strTwitter != "0"){
                strFreeTextTemp.append("\n")
                strFreeTextTemp.append(self.strTwitter)
            }
            if(self.strFacebook != "" && self.strFacebook != "0"){
                strFreeTextTemp.append("\n")
                strFreeTextTemp.append(self.strFacebook)
            }
            if(self.strInstagram != "" && self.strInstagram != "0"){
                strFreeTextTemp.append("\n")
                strFreeTextTemp.append(self.strInstagram)
            }
            
            self.freetextTextView.text = strFreeTextTemp
            //self.freetextTextView.backgroundColor = Util.USUI_GRAY_COLOR
            
            //キャスト情報のダイアログのY座標と高さを保存しておく。
            var castInfoDialogY = UserDefaults.standard.integer(forKey: "castInfoDialogY")
            var castInfoDialogHeight = UserDefaults.standard.integer(forKey: "castInfoDialogHeight")
            
            if(castInfoDialogHeight == 0){
                if(strFreeTextTemp == ""){
                    //下に詰める処理
                    castInfoDialogY = Int(self.mainScrollView.frame.origin.y) + 50
                    castInfoDialogHeight = Int(self.mainScrollView.frame.height) - 50
                }else{
                    castInfoDialogY = Int(self.mainScrollView.frame.origin.y)
                    castInfoDialogHeight = Int(self.mainScrollView.frame.height)
                }
                
                //ユーザー情報のダイアログのY座標と高さを保存しておく。
                UserDefaults.standard.set(castInfoDialogY, forKey: "castInfoDialogY")
                UserDefaults.standard.set(castInfoDialogHeight, forKey: "castInfoDialogHeight")
            }
            
            if(strFreeTextTemp == ""){
                self.freetextTextView.isHidden = true
                //下に詰める処理
                self.upView.frame = CGRect(x: self.upView.frame.origin.x, y: self.upView.frame.origin.y, width: self.upView.frame.width, height: self.upView.frame.height)
                self.mainScrollView.frame = CGRect(x: self.mainScrollView.frame.origin.x, y: CGFloat(castInfoDialogY), width: self.mainScrollView.frame.width, height: CGFloat(castInfoDialogHeight))
            }else{
                self.freetextTextView.isHidden = false
            }
            
            // スクロールの高さを変更(修正が必要)
            //self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width
            //    , height: 900)
        }
    }
    
    func getFollowInfo(){
        //followをしているかの取得
        var stringUrl = Util.URL_GET_FOLLOW_LIST
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(self.cast_id))
        
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
                    let json = try decoder.decode(ResultJsonFollow.self, from: data!)
                    self.followCount = json.count
                    
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
            //self.CollectionView.reloadData()
            //self.nameField.text = "モデル名："+self.strNames[0]
            if(self.followCount > 0){
                //この人をフォローしている場合
                self.followBtn.setTitle("フォロー中!", for: .normal)
                self.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                self.followBtn.backgroundColor = Util.CAST_INFO_COLOR_FOLLOW_BTN // 背景色
                // 枠線の色
                //followBtn.layer.borderColor = UIColor.lightGray.cgColor
                // 枠線の太さ
                self.followBtn.layer.borderWidth = 0
            }else{
                //この人をフォローしていない場合
                self.followBtn.setTitle("+フォロー", for: .normal)
                self.followBtn.setTitleColor(UIColor.darkGray, for: .normal) // タイトルの色
                self.followBtn.backgroundColor = UIColor.white // 背景色
                // 枠線の色
                self.followBtn.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
                // 枠線の太さ
                self.followBtn.layer.borderWidth = 1
            }

            //くるくる表示終了
            //self.busyIndicator.removeFromSuperview()
        }
    }
    
    //絆レベルの更新・追加(更新後に処理をする必要があるため、Utilではなくこちらを使用)
    //flg:1:値プラス、2:値マイナス
    //GET: user_id, target_user_id,level,exp,live_count,present_point,flg
    func saveConnectLevel(user_id:Int, target_user_id:Int, exp:Int, live_count:Int, present_point:Int, flg:Int){
        var stringUrl = Util.URL_SAVE_CONNECT_LEVEL_NEW
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&target_user_id=")
        stringUrl.append(String(target_user_id))
        stringUrl.append("&exp=")
        stringUrl.append(String(exp))
        stringUrl.append("&live_count=")
        stringUrl.append(String(live_count))
        stringUrl.append("&present_point=")
        stringUrl.append(String(present_point))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        
        //print(stringUrl)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //フォローボタンの変更
            self.getFollowInfo()
            self.getModelInfo()
        }
    }
}
