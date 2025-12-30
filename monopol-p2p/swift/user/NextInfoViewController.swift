//
//  NextInfoViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/19.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

//monopolアカウントでログインをする
class NextInfoViewController: UIViewController {

    @IBOutlet weak var centerMainView: UIView!
    
    @IBOutlet weak var nextIdTextField: KeyBoard!
    @IBOutlet weak var passwordTextField: KeyBoard!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    /*
    //ユーザー情報取得用
    struct UserResult: Codable {
        let user_id: String
        let next_id: String
        let next_pass: String
        let uuid: String
        let fcm_token: String
        let notify_flg: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let movie_flg: String
        let movie_name: String
        let value01: String//性別
        let value02: String//フォロワー数
        let value03: String//フォロー数
        //let value04: String//未使用
        //let value05: String//未使用
        let mycollection_max: String//マイコレクションのMAX値
        let point: String//所有しているポイント(coin)
        let live_point: String//配信ポイント(リストのトップに表示する配信ポイント、別紙ロジック参照)
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
        let official_read_flg: String//1:未読
        let notice_text: String//
        let live_total_count: String//
        let live_total_sec: String//
        let live_total_star: String//
        let live_now_star: String//
        let payment_request_star: String//
        let login_status: String//
        let live_user_id: String//
        let reserve_user_id: String//
        let reserve_flg: String//
        let max_reserve_count: String//
        let first_flg01: String//
        let first_flg02: String//
        let first_flg03: String//
        //let login_time: String//
        //let ins_time: String//
        let bank_info01: String//
        let bank_info02: String//
        let bank_info03: String//
        let bank_info04: String//
        let bank_info05: String//
        let last_star_get_time: String//
        let pub_rank_name: String//
        let pub_get_live_point: String//
        let pub_ex_get_live_point: String//
        let pub_coin: String//
        let pub_ex_coin: String//
        let pub_min_reserve_coin: String//
        //let cancel_coin: String//
        //let cancel_get_star: String//
        //個別設定用
        let ex_live_sec: String//
        let ex_get_live_point: String//
        let ex_ex_get_live_point: String//
        let ex_coin: String//
        let ex_ex_coin: String//
        let ex_min_reserve_coin: String//
    }
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }
    */
    
    //リストアの結果(カウントを返す)
    struct ResultRestoreJson: Codable {
        let result_count: Int
        //let result: [UserResult]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let fcm_token_temp = UserDefaults.standard.string(forKey: "fcm_token_temp")
        //print("-------------------------")
        //print("-------------------------")
        //print(fcm_token_temp)
        //print("-------------------------")
        //print("-------------------------")
        
        //メンテナンス中かの判断(メンテナンス画面の中では直接記述すること)
        UtilFunc.maintenanceCheck()
        
        //モノポルIDの設定
        //let next_id = UserDefaults.standard.string(forKey: "next_id")
        //self.nextIdTextField.text = next_id
        //self.nextIdTextField.isEnabled = false//編集不可
        
        // 入力された文字を非表示モードにする.
        var password_temp = UserDefaults.standard.string(forKey: "next_pass")
        if(password_temp == "0"){
            password_temp = ""
        }
        self.passwordTextField.text = password_temp
        self.passwordTextField.isSecureTextEntry = true
        
        // 枠線の色
        //centerMainView.layer.borderColor = UIColor.lightGray.cgColor
        centerMainView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        centerMainView.layer.borderWidth = 0.5
        // 角丸
        centerMainView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        centerMainView.layer.masksToBounds = true
        
        // 枠線の色
        //setBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //setBtn.layer.borderWidth = 2
        // 角丸
        setBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        setBtn.layer.masksToBounds = true
        //色指定
        setBtn.backgroundColor = Util.COMMON_BLUE_COLOR
        
        // 枠線の色
        //cancelBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //cancelBtn.layer.borderWidth = 2
        // 角丸
        cancelBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        cancelBtn.layer.masksToBounds = true
        //色指定ffb700
        cancelBtn.backgroundColor = Util.COIN_YEN_BG_COLOR
        
        // Do any additional setup after loading the view.
        //キーボード対応
        self.configureObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapSetBtn(_ sender: Any) {
        //monopolのIDでログイン
        //self.goNext()
        self.restoreDo()
//        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func restoreDo(){
        let strPassword = passwordTextField.text
        let strNextId = nextIdTextField.text
        
        if(strPassword == "" || strNextId == ""){
            //入力されずに、ログインボタンを押した時
            UtilFunc.showAlert(message: "入力内容に誤りがあります。", vc: self, sec: 2.0)
            self.passwordTextField.text = ""
        }else if(strPassword != nil && strPassword != ""){
            
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            let uuid = UserDefaults.standard.string(forKey: "uuid")
            let fcm_token = UserDefaults.standard.string(forKey: "fcm_token_temp")
            
            //リストア
            //GET: user_id,next_id,next_pass,uuid
            var stringUrl = Util.URL_RESTORE_DO
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&next_id=")
            stringUrl.append(strNextId!)
            stringUrl.append("&next_pass=")
            stringUrl.append(strPassword!)
            stringUrl.append("&uuid=")
            stringUrl.append(uuid!)
            stringUrl.append("&fcm_token=")
            stringUrl.append(fcm_token!)
            
            print(stringUrl)
            
            // Swift4からは書き方が変わりました。
            let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            //let decodedString:String = text.removingPercentEncoding!
            let req = URLRequest(url: url)
            
            //非同期処理を行う
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
            var json_result :ResultRestoreJson? = nil
            
            dispatchGroup.enter()
            dispatchQueue.async {
                let task = URLSession.shared.dataTask(with: req, completionHandler: {
                    (data, res, err) in
                    do{
                        //JSONDecoderのインスタンス取得
                        let decoder = JSONDecoder()
                        
                        //受けとったJSONデータをパースして格納
                        json_result = try decoder.decode(ResultRestoreJson.self, from: data!)
                        
                        //print("作成されたID")
                        //print(json.id_temp)
                        dispatchGroup.leave()//サブタスク終了時に記述
                    }catch{
                        //エラー処理
                        //print("エラーが出ました")
                        //print("json convert failed in JSONDecoder", err?.localizedDescription)
                    }
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                
                if(json_result?.result_count == 1){
                    //リストア成功
                    //print("リストア成功!")
                    
                    //ユーザー名が「0」かつuser_idが前のデータの状態を変更する
                    //99:リストア済
                    //UtilFunc.modifyStatusDoByUserName(user_id:user_id, status:99, user_name:"0")
                    
                    //値をセットする
                    self.setMyInfo()
                    
                }else{
                    //リストア失敗
                    self.passwordTextField.text = ""
                    //self.nextIdTextField.text = ""
                    
                    //self.showErrorAlert()
                    UtilFunc.showAlert(message: "入力内容に誤りがあります。", vc: self, sec: 2.0)
                }
            }
        }
    }
    
    /*
    //数秒後に勝手に閉じる
    func showErrorAlert() {
        //入力内容に誤りがあります。
        //UtilFunc.showAlert(message:"", vc:self.parentViewController()!)
        //UtilFunc.showAlert(message:"", vc:self)
        print("エラーこことおる？")
        UtilFunc.showAlert(message: "入力内容に誤りがあります。", vc: self, sec: 2.0)
        // アラート作成
        let alert = UIAlertController(title: nil, message: "モノポルアカウントのログインに失敗しました", preferredStyle: .alert)
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }*/
    
    //自分の情報をアプリ内に記憶する
    func setMyInfo(){
        //いったんクリアしておく
        //userInfo.removeAll()
        var strUserId: String = ""
        var strNextId: String = ""
        var strNextPass: String = ""
        var strFcmToken: String = ""
        var strNotifyFlg: String = ""
        var strUuid: String = ""
        var strUserName: String = ""
        var strPhotoFlg: String = ""
        var strPhotoName: String = ""
        var strPhotoBackgroundFlg: String = ""
        var strPhotoBackgroundName: String = ""
        var strMovieFlg: String = ""
        var strMovieName: String = ""
        var strValue01: String = ""
        var strValue02: String = ""
        var strValue03: String = ""
        var strValue04: String = ""
        //var strValue05: String = ""
        var strMycollectionMax: String = ""
        var strPoint: String = ""
        var strPointPay: String = ""
        var strPointFree: String = ""
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
        var strOfficialReadFlg: String = ""
        var strNoticeText: String = ""
        var strLiveTotalCount: String = ""
        var strLiveTotalSec: String = ""
        var strLiveTotalStar: String = ""
        var strLiveNowStar: String = ""
        var strPaymentRequestStar: String = ""
        var strLoginStatus: String = ""
        var strLiveUserId: String = ""
        var strReserveUserId: String = ""
        var strReserveFlg: String = ""
        var strMaxReserveCount: String = ""
        var strFirstFlg01: String = ""
        var strFirstFlg02: String = ""
        var strFirstFlg03: String = ""
        //var strLoginTime: String = ""
        //var strInsTime: String = ""
        var strBankInfo01: String = ""
        var strBankInfo02: String = ""
        var strBankInfo03: String = ""
        var strBankInfo04: String = ""
        var strBankInfo05: String = ""
        var strLastStarGetTime: String = ""
        var strPubRankName: String = ""
        var strPubGetLivePoint: String = ""
        var strPubExGetLivePoint: String = ""
        var strPubCoin: String = ""
        var strPubExCoin: String = ""
        var strPubMinReserveCoin: String = ""
        //var strCancelCoin: String = ""
        //var strCancelGetStar: String = ""
        //個別設定用
        var strExLiveSec: String = ""
        var strExGetLivePoint: String = ""
        var strExExGetLivePoint: String = ""
        var strExCoin: String = ""
        var strExExCoin: String = ""
        var strExMinReserveCoin: String = ""
        var strExStatus: String = ""//1有効2無効3設定済み無効
        
        //自分の情報取得
        //UUIDを取得
        let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let stringUrl = Util.URL_USER_INFO_BY_UUID + "?uuid=" + String(phonedeviceId);

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
                    let json = try decoder.decode(UtilStruct.ResultJsonTemp.self, from: data!)
                    //self.idCount = json.count
                    
                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                    for obj in json.result {
                        strUserId = obj.user_id
                        strNextId = obj.next_id
                        strNextPass = obj.next_pass
                        strFcmToken = obj.fcm_token
                        strNotifyFlg = obj.notify_flg
                        strUuid = obj.uuid
                        strUserName = obj.user_name.toHtmlString()
                        strPhotoFlg = obj.photo_flg
                        strPhotoName = obj.photo_name
                        strPhotoBackgroundFlg = obj.photo_background_flg
                        strPhotoBackgroundName = obj.photo_background_name
                        strMovieFlg = obj.movie_flg
                        strMovieName = obj.movie_name
                        strValue01 = obj.value01
                        strValue02 = obj.value02
                        strValue03 = obj.value03
                        strValue04 = obj.value04
                        //strValue05 = obj.value05
                        strMycollectionMax = obj.mycollection_max
                        strPoint = obj.point
                        strPointPay = obj.point_pay
                        strPointFree = obj.point_free
                        strLivePoint = obj.live_point
                        strWatchLevel = obj.watch_level
                        strLiveLevel = obj.live_level
                        strCastRank = obj.cast_rank
                        strCastOfficialFlg = obj.cast_official_flg
                        strCastMonthRanking = obj.cast_month_ranking
                        strCastMonthRankingPoint = obj.cast_month_ranking_point
                        strTwitter = obj.twitter.toHtmlString()
                        strFacebook = obj.facebook.toHtmlString()
                        strInstagram = obj.instagram.toHtmlString()
                        strHomepage = obj.homepage.toHtmlString()
                        strFreetext = obj.freetext.toHtmlString()
                        strOfficialReadFlg = obj.official_read_flg
                        strNoticeText = obj.notice_text
                        //strNoticePhotoPath = obj.notice_photo_path
                        strLiveTotalCount = obj.live_total_count
                        strLiveTotalSec = obj.live_total_sec
                        strLiveTotalStar = obj.live_total_star
                        strLiveNowStar = obj.live_now_star
                        strPaymentRequestStar = obj.payment_request_star
                        strLoginStatus = obj.login_status
                        strLiveUserId = obj.live_user_id
                        strReserveUserId = obj.reserve_user_id
                        strReserveFlg = obj.reserve_flg
                        strMaxReserveCount = obj.max_reserve_count
                        strFirstFlg01 = obj.first_flg01
                        strFirstFlg02 = obj.first_flg02
                        strFirstFlg03 = obj.first_flg03
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
                        strBankInfo01 = obj.bank_info01.toHtmlString()
                        strBankInfo02 = obj.bank_info02
                        strBankInfo03 = obj.bank_info03
                        strBankInfo04 = obj.bank_info04
                        strBankInfo05 = obj.bank_info05
                        strLastStarGetTime = obj.last_star_get_time
                        strPubRankName = obj.pub_rank_name
                        strPubGetLivePoint = obj.pub_get_live_point
                        strPubExGetLivePoint = obj.pub_ex_get_live_point
                        strPubCoin = obj.pub_coin
                        strPubExCoin = obj.pub_ex_coin
                        strPubMinReserveCoin = obj.pub_min_reserve_coin
                        //strCancelCoin = obj.cancel_coin
                        //strCancelGetStar = obj.cancel_get_star
                        //個別設定用
                        strExLiveSec = obj.ex_live_sec
                        strExGetLivePoint = obj.ex_get_live_point
                        strExExGetLivePoint = obj.ex_ex_get_live_point
                        strExCoin = obj.ex_coin
                        strExExCoin = obj.ex_ex_coin
                        strExMinReserveCoin = obj.ex_min_reserve_coin
                        strExStatus = obj.ex_status
                        
                        break
                        
                        /*
                         let user = (strUserId,strUuid,strUserName,strValue01,strValue02
                         ,strValue03,strPoint,strLivePoint,strCastRank,strCastOfficialFlg
                         ,strCastMonthRanking,strCastMonthRankingPoint,strTwitter,strFacebook
                         ,strInstagram,strHomepage,strFreetext,strNoticeText,strNoticePhotoPath
                         ,strLoginStatus,strLoginTime)
                         //配列へ追加
                         //userInfo.append(user)
                         */
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
            UserDefaults.standard.set(strUserId, forKey: "user_id")
            UserDefaults.standard.set(strNextId, forKey: "next_id")
            UserDefaults.standard.set(strNextPass, forKey: "next_pass")
            UserDefaults.standard.set(strFcmToken, forKey: "fcm_token")
            UserDefaults.standard.set(strNotifyFlg, forKey: "notify_flg")
            UserDefaults.standard.set(strUuid, forKey: "uuid")
            UserDefaults.standard.set(strUserName, forKey: "myName")
            UserDefaults.standard.set(strPhotoFlg, forKey: "myPhotoFlg")
            UserDefaults.standard.set(strPhotoName, forKey: "myPhotoName")
            UserDefaults.standard.set(strPhotoBackgroundFlg, forKey: "myPhotoBackgroundFlg")
            UserDefaults.standard.set(strPhotoBackgroundName, forKey: "myPhotoBackgroundName")
            UserDefaults.standard.set(strMovieFlg, forKey: "myMovieFlg")
            UserDefaults.standard.set(strMovieName, forKey: "myMovieName")
            UserDefaults.standard.set(strValue01, forKey: "sex_cd")
            UserDefaults.standard.set(strValue02, forKey: "follower_num")
            UserDefaults.standard.set(strValue03, forKey: "follow_num")
            UserDefaults.standard.set(strValue04, forKey: "organizer_webview_flg")
            UserDefaults.standard.set(strMycollectionMax, forKey: "myCollection_max")
            UserDefaults.standard.set(strPoint, forKey: "myPoint")//小数
            UserDefaults.standard.set(strPointPay, forKey: "myPointPay")//小数
            UserDefaults.standard.set(strPointFree, forKey: "myPointFree")//小数
            UserDefaults.standard.set(strLivePoint, forKey: "myLivePoint")
            UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
            UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
            //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
            UserDefaults.standard.set(strCastRank, forKey: "cast_rank")
            UserDefaults.standard.set(strCastOfficialFlg, forKey: "cast_official_flg")//1:公式
            //ストリーマー月間ランキング
            UserDefaults.standard.set(strCastMonthRanking, forKey: "cast_month_ranking")
            //ストリーマー月間ランキングポイント
            UserDefaults.standard.set(strCastMonthRankingPoint, forKey: "cast_month_ranking_point")
            UserDefaults.standard.set(strTwitter, forKey: "twitter")
            UserDefaults.standard.set(strFacebook, forKey: "facebook")
            UserDefaults.standard.set(strInstagram, forKey: "instagram")
            UserDefaults.standard.set(strHomepage, forKey: "homepage")
            UserDefaults.standard.set(strFreetext, forKey: "freetext")
            UserDefaults.standard.set(strOfficialReadFlg, forKey: "official_read_flg")
            UserDefaults.standard.set(strNoticeText, forKey: "notice_text")
            //UserDefaults.standard.set(strNoticePhotoPath, forKey: "notice_photo_path")
            UserDefaults.standard.set(strLiveTotalCount, forKey: "live_total_count")
            UserDefaults.standard.set(strLiveTotalSec, forKey: "live_total_sec")
            UserDefaults.standard.set(strLiveTotalStar, forKey: "live_total_star")
            UserDefaults.standard.set(strLiveNowStar, forKey: "live_now_star")
            UserDefaults.standard.set(strPaymentRequestStar, forKey: "payment_request_star")
            UserDefaults.standard.set(strLoginStatus, forKey: "login_status")
            UserDefaults.standard.set(strLiveUserId, forKey: "live_user_id")
            UserDefaults.standard.set(strReserveUserId, forKey: "reserve_user_id")
            UserDefaults.standard.set(strReserveFlg, forKey: "reserve_flg")
            UserDefaults.standard.set(strMaxReserveCount, forKey: "reserve_flg")
            UserDefaults.standard.set(strFirstFlg01, forKey: "first_flg01")
            UserDefaults.standard.set(strFirstFlg02, forKey: "first_flg02")
            UserDefaults.standard.set(strFirstFlg03, forKey: "first_flg03")
            UserDefaults.standard.set(strBankInfo01, forKey: "bank_info01")
            UserDefaults.standard.set(strBankInfo02, forKey: "bank_info02")
            UserDefaults.standard.set(strBankInfo03, forKey: "bank_info03")
            UserDefaults.standard.set(strBankInfo04, forKey: "bank_info04")
            UserDefaults.standard.set(strBankInfo05, forKey: "bank_info05")
            UserDefaults.standard.set(strLastStarGetTime, forKey: "last_star_get_time")
            UserDefaults.standard.set(strPubRankName, forKey: "rank_name")
            UserDefaults.standard.set(strExStatus, forKey: "ex_status")
            
            //1有効2無効3設定済み無効
            //if(strExStatus == "1" || strExStatus == "3"){
            if(strExStatus == "1"){
                //個別設定がされている
                UserDefaults.standard.set(strExGetLivePoint, forKey: "get_live_point")
                UserDefaults.standard.set(strExExGetLivePoint, forKey: "ex_get_live_point")
                UserDefaults.standard.set(strExCoin, forKey: "coin")
                UserDefaults.standard.set(strExExCoin, forKey: "ex_coin")
                UserDefaults.standard.set(strExMinReserveCoin, forKey: "min_reserve_coin")
                //UserDefaults.standard.set(strCancelCoin, forKey: "cancel_coin")
                //UserDefaults.standard.set(strCancelGetStar, forKey: "cancel_get_star")
                //１枠の秒数を設定
                UserDefaults.standard.set(strExLiveSec, forKey: "live_sec")
                //self.appDelegate.init_seconds = strExLiveSec
                
                //個別設定がされているかのフラグ（１：されている　２：されていない）
                //UserDefaults.standard.set("1", forKey: "streamer_individual_setting_flg")
            }else{
                //個別設定がされてない
                UserDefaults.standard.set(strPubGetLivePoint, forKey: "get_live_point")
                UserDefaults.standard.set(strPubExGetLivePoint, forKey: "ex_get_live_point")
                UserDefaults.standard.set(strPubCoin, forKey: "coin")
                UserDefaults.standard.set(strPubExCoin, forKey: "ex_coin")
                UserDefaults.standard.set(strPubMinReserveCoin, forKey: "min_reserve_coin")
                //UserDefaults.standard.set(strCancelCoin, forKey: "cancel_coin")
                //UserDefaults.standard.set(strCancelGetStar, forKey: "cancel_get_star")
                //１枠の秒数を設定
                UserDefaults.standard.set(Util.INIT_LIVE_SECONDS, forKey: "live_sec")
                //self.appDelegate.init_seconds = Util.INIT_LIVE_SECONDS
                
                //個別設定がされているかのフラグ（１：されている　２：されていない）
                //UserDefaults.standard.set("2", forKey: "streamer_individual_setting_flg")
            }
            
            print("リストア成功")
            
            //ログイン情報を設定
            UserDefaults.standard.set(3, forKey: "login_status")
            
            //ホーム画面へ遷移
            UtilToViewController.toMainViewController()
        }
    }

    /*
    func goNext(){
        let strPassword = passwordTextField.text

        if(strPassword != nil && strPassword != ""){

            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            let next_id = UserDefaults.standard.string(forKey: "next_id")
            
            //パスワードを変更(登録時のみ使用)
            //GET: password, user_id, next_id
            var stringUrl = Util.URL_MODIFY_PASSWORD
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&next_id=")
            stringUrl.append(next_id)
            stringUrl.append("&password=")
            stringUrl.append(strPassword!)
            
            //print(stringUrl)
            
            // Swift4からは書き方が変わりました。
            let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            //let decodedString:String = text.removingPercentEncoding!
            let req = URLRequest(url: url)
            
            //非同期処理を行う
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
            
            dispatchGroup.enter()
            dispatchQueue.async {
                let task = URLSession.shared.dataTask(with: req, completionHandler: {
                    (data, res, err) in
                    //do{
                    
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
                UserDefaults.standard.set(strPassword, forKey: "next_pass")
                //ホーム画面へ遷移
                //Util.toMainViewController()
            }
        }
    }*/
}

//キーボードが隠れてしまう問題の対応
extension NextInfoViewController: UITextFieldDelegate {
    
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        
        //let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            //let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
            //上下の移動はしない
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
            
        })
        
        //self.sexBtn.isEnabled = false
        /*
         if coverView == nil {
         coverView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
         // coverViewの背景
         coverView.backgroundColor = UIColor.black
         // 透明度を設定
         coverView.alpha = 0.1
         coverView.isUserInteractionEnabled = true
         self.view.addSubview(coverView)
         }
         coverView.isHidden = false
         */
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
        
        //self.sexBtn.isEnabled = true
        //coverView.isHidden = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
        return true
    }
}
