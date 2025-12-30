//
//  SubMainViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/04/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import LineSDK
import AuthenticationServices

class SubMainViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // LoginButtonDelegate, UIPickerViewDelegate, UIPickerViewDataSource
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Appleログインボタン
    @IBOutlet weak var appleLoginBtn: ASAuthorizationAppleIDButton!
    
    //新規登録するボタン
    @IBOutlet weak var saveInfoBtn: UIButton!
    
    //区切り線
    @IBOutlet weak var separateView: UIView!
    
    // 選択肢
    //let dataList = ["性別を選択してください", "女性", "男性"]
    //var sexCd: Int = 0
    var lineIdCount: Int = 0//LineID登録件数 0 or 1
    var appleIdCount: Int = 0//AppleID登録件数 0 or 1
    
    @IBOutlet weak var NameFeild: KeyBoard!

    //@IBOutlet weak var sexCdBtn: UIButton!
    //@IBOutlet weak var nextIdLbl: UILabel!
    //引き継ぎボタン
    @IBOutlet weak var nextBtn: UIButton!
    
    //ユーザー情報取得用
    struct UserResult: Codable {
        let user_id: String
        let next_id: String
        let next_pass: String
        let uuid: String
        let fcm_token: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let movie_flg: String
        let movie_name: String
        let sns_userid01: String//LineのユーザーID
        let sns_userid02: String//AppleのユーザーID
        let sns_userid03: String//未使用
        let value01: String//性別
        let value02: String//フォロワー数
        let value03: String//フォロー数
        let value04: String//報酬一覧のWebViewの表示・非表示フラグ
        //let value05: String//未使用
        let mycollection_max: String//マイコレクションのMAX値
        let point: String//所有しているポイント
        let point_pay: String
        let point_free: String
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
        let login_status: String//
        //let login_time: String//
        //let ins_time: String//
    }
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //  メンテナンス中かの判断(メンテナンス画面の中では直接記述すること)
        UtilFunc.maintenanceCheck()
        
        /*
         // 枠線の色
         sexCdBtn.layer.borderColor = UIColor.lightGray.cgColor
         // 枠線の太さ
         sexCdBtn.layer.borderWidth = 2
         // 角丸
         sexCdBtn.layer.cornerRadius = 4
         // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
         sexCdBtn.layer.masksToBounds = true
         */

        // 枠線の色
        //NameFeild.layer.borderColor = UIColor.lightGray.cgColor
        NameFeild.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        NameFeild.layer.borderWidth = 0.5
        // 角丸
        NameFeild.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        NameFeild.layer.masksToBounds = true
        
        // 枠線の色
        //saveInfoBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //saveInfoBtn.layer.borderWidth = 0
        // 角丸
        //saveInfoBtn.layer.cornerRadius = 10
        saveInfoBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        saveInfoBtn.layer.masksToBounds = true
        //色指定
        saveInfoBtn.backgroundColor = Util.COMMON_BLUE_COLOR

        // 区切り線の色
        self.separateView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 区切り線の太さ
        //self.separateView.layer.borderWidth = 0.5
        
        // 角丸
        nextBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        nextBtn.layer.masksToBounds = true
        //色指定ffb700
        nextBtn.backgroundColor = Util.COIN_YEN_BG_COLOR
        
        // 角丸
        appleLoginBtn.cornerRadius = 4.0
        
        self.setMyInfo()
        
        // Do any additional setup after loading the view.
        
        /*
        // Create Line Login Button.
        let loginButton = LoginButton()
        loginButton.delegate = self
        
        // Configuration for permissions and presenting.
        loginButton.permissions = [.profile]
        loginButton.presentingViewController = self
        
        // Add button to view and layout it.
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        // Create Login Button.(ここまで)
        */
        
        //同意確認がされていない場合は、RuleCheckViewを重ねる
        //規約同意チェックフラグ：１＝チェック済
        let rule_check_flg = UserDefaults.standard.integer(forKey: "rule_check_flg")
        if(rule_check_flg != 1){
            let ruleCheckView:RuleCheckView = UINib(nibName: "RuleCheckView", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! RuleCheckView
            //mainToolbarView.toolbarViewSetting()
            //画面サイズに合わせる
            ruleCheckView.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(ruleCheckView)
        }
    }
    
    /*
    //Line login Delegate
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        //hideIndicator()
        print("Login Succeeded.")
        
        if let profile = loginResult.userProfile {
            print("User ID: \(profile.userID)")
            print("User Display Name: \(profile.displayName)")
            print("User Icon: \(String(describing: profile.pictureURL))")
        }
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        //hideIndicator()
        print("Error: \(error)")
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        //showIndicator()
        print("Login Started.")
    }
    //Line login Delegate(ここまで)
    */

    //自分の情報をアプリ内に記憶する
    func setMyInfo(){
        //いったんクリアしておく
        //userInfo.removeAll()
        var strUserId: String = ""
        var strNextId: String = ""
        var strNextPass: String = ""
        var strFcmToken: String = ""
        var strUuid: String = ""
        var strUserName: String = ""
        var strPhotoFlg: String = ""
        var strPhotoName: String = ""
        var strMovieFlg: String = ""
        var strMovieName: String = ""
        var strSnsUserid01: String = ""
        var strSnsUserid02: String = ""
        var strSnsUserid03: String = ""
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
        var strNoticeText: String = ""
        var strLoginStatus: String = ""
        //var strLoginTime: String = ""
        //var strInsTime: String = ""
        
        //自分の情報取得
        //UUIDを取得
        //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let stringUrl = Util.URL_USER_INFO + "?user_id=" + String(user_id);
        
        print(stringUrl)
        
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
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                    for obj in json.result {
                        strUserId = obj.user_id
                        strNextId = obj.next_id
                        strNextPass = obj.next_pass
                        strFcmToken = obj.fcm_token
                        strUuid = obj.uuid
                        strUserName = obj.user_name
                        strPhotoFlg = obj.photo_flg
                        strPhotoName = obj.photo_name
                        strMovieFlg = obj.movie_flg
                        strMovieName = obj.movie_name
                        strSnsUserid01 = obj.sns_userid01
                        strSnsUserid02 = obj.sns_userid02
                        strSnsUserid03 = obj.sns_userid03
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
                        strTwitter = obj.twitter
                        strFacebook = obj.facebook
                        strInstagram = obj.instagram
                        strHomepage = obj.homepage
                        strFreetext = obj.freetext
                        strNoticeText = obj.notice_text
                        //strNoticePhotoPath = obj.notice_photo_path
                        strLoginStatus = obj.login_status
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
                        
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
            UserDefaults.standard.set(strUuid, forKey: "uuid")
            UserDefaults.standard.set(strUserName, forKey: "myName")
            UserDefaults.standard.set(strPhotoFlg, forKey: "myPhotoFlg")
            UserDefaults.standard.set(strPhotoName, forKey: "myPhotoName")
            UserDefaults.standard.set(strMovieFlg, forKey: "myMovieFlg")
            UserDefaults.standard.set(strMovieName, forKey: "myMovieName")
            UserDefaults.standard.set(strSnsUserid01, forKey: "sns_userid01")
            UserDefaults.standard.set(strSnsUserid02, forKey: "sns_userid02")
            UserDefaults.standard.set(strSnsUserid03, forKey: "sns_userid03")
            UserDefaults.standard.set(strValue01, forKey: "sex_cd")
            UserDefaults.standard.set(strValue02, forKey: "follower_num")
            UserDefaults.standard.set(strValue03, forKey: "follow_num")
            UserDefaults.standard.set(strValue04, forKey: "organizer_webview_flg")
            UserDefaults.standard.set(strMycollectionMax, forKey: "myCollection_max")
            UserDefaults.standard.set(strPoint, forKey: "myPoint")
            UserDefaults.standard.set(strPointPay, forKey: "myPointPay")
            UserDefaults.standard.set(strPointFree, forKey: "myPointFree")
            UserDefaults.standard.set(strLivePoint, forKey: "myLivePoint")
            
            UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
            UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
            //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
            UserDefaults.standard.set(strCastRank, forKey: "cast_rank")
            UserDefaults.standard.set(strCastOfficialFlg, forKey: "cast_official_flg")//1:公式
            //キャスト月間ランキング
            UserDefaults.standard.set(strCastMonthRanking, forKey: "cast_month_ranking")
            //キャスト月間ランキングポイント
            UserDefaults.standard.set(strCastMonthRankingPoint, forKey: "cast_month_ranking_point")
            UserDefaults.standard.set(strTwitter, forKey: "twitter")
            UserDefaults.standard.set(strFacebook, forKey: "facebook")
            UserDefaults.standard.set(strInstagram, forKey: "instagram")
            UserDefaults.standard.set(strHomepage, forKey: "homepage")
            UserDefaults.standard.set(strFreetext, forKey: "freetext")
            UserDefaults.standard.set(strNoticeText, forKey: "notice_text")
            //UserDefaults.standard.set(strNoticePhotoPath, forKey: "notice_photo_path")
            UserDefaults.standard.set(strLoginStatus, forKey: "login_status")

            //引継ぎIDを設定
            //self.nextIdLbl.text = "ユーザID:" + strNextId
        }
    }

    //自分の情報をアプリ内に記憶する
    func setMyInfoByLineId(line_id:String){
        //いったんクリアしておく
        //userInfo.removeAll()
        var strUserId: String = ""
        var strNextId: String = ""
        var strNextPass: String = ""
        var strFcmToken: String = ""
        //var strUuid: String = ""
        var strUserName: String = ""
        var strPhotoFlg: String = ""
        var strPhotoName: String = ""
        var strMovieFlg: String = ""
        var strMovieName: String = ""
        var strSnsUserid01: String = ""
        var strSnsUserid02: String = ""
        var strSnsUserid03: String = ""
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
        var strNoticeText: String = ""
        var strLoginStatus: String = ""
        //var strLoginTime: String = ""
        //var strInsTime: String = ""
        
        //自分の情報取得(LineIdをキー)
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let stringUrl = Util.URL_USER_INFO_BY_LINEID + "?lineid=" + line_id;
        
        //print(stringUrl)
        
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
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultJson.self, from: data!)
                    self.lineIdCount = json.count
                    
                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                    for obj in json.result {
                        strUserId = obj.user_id
                        strNextId = obj.next_id
                        strNextPass = obj.next_pass
                        strFcmToken = obj.fcm_token
                        //strUuid = obj.uuid
                        strUserName = obj.user_name
                        strPhotoFlg = obj.photo_flg
                        strPhotoName = obj.photo_name
                        strMovieFlg = obj.movie_flg
                        strMovieName = obj.movie_name
                        strSnsUserid01 = obj.sns_userid01
                        strSnsUserid02 = obj.sns_userid02
                        strSnsUserid03 = obj.sns_userid03
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
                        strTwitter = obj.twitter
                        strFacebook = obj.facebook
                        strInstagram = obj.instagram
                        strHomepage = obj.homepage
                        strFreetext = obj.freetext
                        strNoticeText = obj.notice_text
                        //strNoticePhotoPath = obj.notice_photo_path
                        strLoginStatus = obj.login_status
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
                        
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
            if(self.lineIdCount == 1){
                UserDefaults.standard.set(strUserId, forKey: "user_id")
                UserDefaults.standard.set(strNextId, forKey: "next_id")
                UserDefaults.standard.set(strNextPass, forKey: "next_pass")
                UserDefaults.standard.set(strFcmToken, forKey: "fcm_token")
                //この時点でuuid取得しアプリ内保存
                let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
                UserDefaults.standard.set(phonedeviceId, forKey: "uuid")
                UserDefaults.standard.set(strUserName, forKey: "myName")
                UserDefaults.standard.set(strPhotoFlg, forKey: "myPhotoFlg")
                UserDefaults.standard.set(strPhotoName, forKey: "myPhotoName")
                UserDefaults.standard.set(strMovieFlg, forKey: "myMovieFlg")
                UserDefaults.standard.set(strMovieName, forKey: "myMovieName")
                UserDefaults.standard.set(strSnsUserid01, forKey: "sns_userid01")
                UserDefaults.standard.set(strSnsUserid02, forKey: "sns_userid02")
                UserDefaults.standard.set(strSnsUserid03, forKey: "sns_userid03")
                UserDefaults.standard.set(strValue01, forKey: "sex_cd")
                UserDefaults.standard.set(strValue02, forKey: "follower_num")
                UserDefaults.standard.set(strValue03, forKey: "follow_num")
                UserDefaults.standard.set(strValue04, forKey: "organizer_webview_flg")
                UserDefaults.standard.set(strMycollectionMax, forKey: "myCollection_max")
                UserDefaults.standard.set(strPoint, forKey: "myPoint")
                UserDefaults.standard.set(strPointPay, forKey: "myPointPay")
                UserDefaults.standard.set(strPointFree, forKey: "myPointFree")
                UserDefaults.standard.set(strLivePoint, forKey: "myLivePoint")
                
                UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
                UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
                //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                UserDefaults.standard.set(strCastRank, forKey: "cast_rank")
                UserDefaults.standard.set(strCastOfficialFlg, forKey: "cast_official_flg")//1:公式
                //キャスト月間ランキング
                UserDefaults.standard.set(strCastMonthRanking, forKey: "cast_month_ranking")
                //キャスト月間ランキングポイント
                UserDefaults.standard.set(strCastMonthRankingPoint, forKey: "cast_month_ranking_point")
                UserDefaults.standard.set(strTwitter, forKey: "twitter")
                UserDefaults.standard.set(strFacebook, forKey: "facebook")
                UserDefaults.standard.set(strInstagram, forKey: "instagram")
                UserDefaults.standard.set(strHomepage, forKey: "homepage")
                UserDefaults.standard.set(strFreetext, forKey: "freetext")
                UserDefaults.standard.set(strNoticeText, forKey: "notice_text")
                //UserDefaults.standard.set(strNoticePhotoPath, forKey: "notice_photo_path")
                UserDefaults.standard.set(strLoginStatus, forKey: "login_status")

                //print("---------------")
                //print(String(phonedeviceId))
                //UUIDについてDB更新
                UtilFunc.modifyUuidByUserId(user_id:Int(strUserId)!, uuid:String(phonedeviceId))
                //ipや機種情報などを保存
                UtilFunc.logIpRirekiDo(type: 1, user_id: Int(strUserId)!)
                //ホーム画面へ遷移
                UtilToViewController.toMainViewController()
            }else{
                //print("---------------" + String(self.lineIdCount))
                //メッセージ出力
                UtilFunc.showAlert(message:UtilStr.ERROR_LINE_LOGIN_001, vc:self, sec:4.0)
            }
        }
    }
    
    //自分の情報をアプリ内に記憶する
    func setMyInfoByAppleId(apple_id:String){
        //いったんクリアしておく
        //userInfo.removeAll()
        var strUserId: String = ""
        var strNextId: String = ""
        var strNextPass: String = ""
        var strFcmToken: String = ""
        //var strUuid: String = ""
        var strUserName: String = ""
        var strPhotoFlg: String = ""
        var strPhotoName: String = ""
        var strMovieFlg: String = ""
        var strMovieName: String = ""
        var strSnsUserid01: String = ""
        var strSnsUserid02: String = ""
        var strSnsUserid03: String = ""
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
        var strNoticeText: String = ""
        var strLoginStatus: String = ""
        //var strLoginTime: String = ""
        //var strInsTime: String = ""
        
        //自分の情報取得(LineIdをキー)
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let stringUrl = Util.URL_USER_INFO_BY_APPLEID + "?appleid=" + apple_id;
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
                    let json = try decoder.decode(ResultJson.self, from: data!)
                    self.appleIdCount = json.count
                    
                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                    for obj in json.result {
                        strUserId = obj.user_id
                        strNextId = obj.next_id
                        strNextPass = obj.next_pass
                        strFcmToken = obj.fcm_token
                        //strUuid = obj.uuid
                        strUserName = obj.user_name
                        strPhotoFlg = obj.photo_flg
                        strPhotoName = obj.photo_name
                        strMovieFlg = obj.movie_flg
                        strMovieName = obj.movie_name
                        strSnsUserid01 = obj.sns_userid01
                        strSnsUserid02 = obj.sns_userid02
                        strSnsUserid03 = obj.sns_userid03
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
                        strTwitter = obj.twitter
                        strFacebook = obj.facebook
                        strInstagram = obj.instagram
                        strHomepage = obj.homepage
                        strFreetext = obj.freetext
                        strNoticeText = obj.notice_text
                        //strNoticePhotoPath = obj.notice_photo_path
                        strLoginStatus = obj.login_status
                        //strLoginTime = obj.login_time
                        //strInsTime = obj.ins_time
                        
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
            if(self.appleIdCount == 1){
                UserDefaults.standard.set(strUserId, forKey: "user_id")
                UserDefaults.standard.set(strNextId, forKey: "next_id")
                UserDefaults.standard.set(strNextPass, forKey: "next_pass")
                UserDefaults.standard.set(strFcmToken, forKey: "fcm_token")
                //この時点でuuid取得しアプリ内保存
                let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
                UserDefaults.standard.set(phonedeviceId, forKey: "uuid")
                UserDefaults.standard.set(strUserName, forKey: "myName")
                UserDefaults.standard.set(strPhotoFlg, forKey: "myPhotoFlg")
                UserDefaults.standard.set(strPhotoName, forKey: "myPhotoName")
                UserDefaults.standard.set(strMovieFlg, forKey: "myMovieFlg")
                UserDefaults.standard.set(strMovieName, forKey: "myMovieName")
                UserDefaults.standard.set(strSnsUserid01, forKey: "sns_userid01")
                UserDefaults.standard.set(strSnsUserid02, forKey: "sns_userid02")
                UserDefaults.standard.set(strSnsUserid03, forKey: "sns_userid03")
                UserDefaults.standard.set(strValue01, forKey: "sex_cd")
                UserDefaults.standard.set(strValue02, forKey: "follower_num")
                UserDefaults.standard.set(strValue03, forKey: "follow_num")
                UserDefaults.standard.set(strValue04, forKey: "organizer_webview_flg")
                UserDefaults.standard.set(strMycollectionMax, forKey: "myCollection_max")
                UserDefaults.standard.set(strPoint, forKey: "myPoint")
                UserDefaults.standard.set(strPointPay, forKey: "myPointPay")
                UserDefaults.standard.set(strPointFree, forKey: "myPointFree")
                UserDefaults.standard.set(strLivePoint, forKey: "myLivePoint")
                
                UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
                UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
                //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                UserDefaults.standard.set(strCastRank, forKey: "cast_rank")
                UserDefaults.standard.set(strCastOfficialFlg, forKey: "cast_official_flg")//1:公式
                //キャスト月間ランキング
                UserDefaults.standard.set(strCastMonthRanking, forKey: "cast_month_ranking")
                //キャスト月間ランキングポイント
                UserDefaults.standard.set(strCastMonthRankingPoint, forKey: "cast_month_ranking_point")
                UserDefaults.standard.set(strTwitter, forKey: "twitter")
                UserDefaults.standard.set(strFacebook, forKey: "facebook")
                UserDefaults.standard.set(strInstagram, forKey: "instagram")
                UserDefaults.standard.set(strHomepage, forKey: "homepage")
                UserDefaults.standard.set(strFreetext, forKey: "freetext")
                UserDefaults.standard.set(strNoticeText, forKey: "notice_text")
                //UserDefaults.standard.set(strNoticePhotoPath, forKey: "notice_photo_path")
                UserDefaults.standard.set(strLoginStatus, forKey: "login_status")

                //print("---------------")
                //print(String(phonedeviceId))
                //UUIDについてDB更新
                UtilFunc.modifyUuidByUserId(user_id:Int(strUserId)!, uuid:String(phonedeviceId))
                //ipや機種情報などを保存
                UtilFunc.logIpRirekiDo(type: 1, user_id: Int(strUserId)!)
                //ホーム画面へ遷移
                UtilToViewController.toMainViewController()
            }else{
                //AppleIDの登録がないユーザー
                //名前を入力する画面へ遷移
                UtilToViewController.toAppleLoginStartViewController()
            }
        }
    }
    
    //monopolIDでログインボタン
    @IBAction func tapNextBtn(_ sender: Any) {
        //もう一度トークンなどの情報をセットしておく
        self.setMyInfo()
        
        UtilToViewController.toNextInfoViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // UUIDがアプリ内に設定されているかの判断
        //if UserDefaults.standard.object(forKey: "uuid") != nil {
        if UserDefaults.standard.integer(forKey: "login_status") > 0
            && UserDefaults.standard.integer(forKey: "user_id") > 0 {
            
            //Mainのストーリーボードへ
            UtilToViewController.toMainViewController()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func saveBtn(_ sender: UIButton) {
        //if inputText1.text != "" && inputText2.text != "" {
        self.goNext()
    }

    @IBAction func tapLineLoginBtn(_ sender: UIButton) {
        LoginManager.shared.login(permissions: [.profile], in: self) {
            result in
            switch result {
            case .success(let loginResult):
                //print(loginResult.accessToken.value)
                // Do other things you need with the login result
                
                if let profile = loginResult.userProfile {
                    print("User ID: \(profile.userID)")
                    //print("User Display Name: \(profile.displayName)")
                    //print("User Icon: \(String(describing: profile.pictureURL))")
                    
                    //LineのユーザーIDでユーザー情報を検索>ホーム画面へ遷移
                    self.setMyInfoByLineId(line_id: profile.userID)
                }else{
                    //メッセージ出力
                    //UtilFunc.showAlert(message:UtilStr.ERROR_LINE_LOGIN_001, vc:self, sec:4.0)
                }
            case .failure(let error):
                //メッセージ出力
                print(error)
                //UtilFunc.showAlert(message:UtilStr.ERROR_LINE_LOGIN_001, vc:self, sec:4.0)
            }
        }
    }
    
    @IBAction func tapAppleLoginBtn(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            //let fullName = appleIDCredential.fullName
            //let email = appleIDCredential.email!
            
            //print("User ID: \(userIdentifier)")
            //print("userIdentifier:\(appleIDCredential.user)")
            //print("fullName:\(String(describing: appleIDCredential.fullName))")
            //print("email:\(String(describing: appleIDCredential.email))")
            //print("authorizationCode:\(String(describing: appleIDCredential.authorizationCode))")
            
            //print("ここでログイン処理を呼び出す")
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            //self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            //self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        
            //アプリ内に保存
            UserDefaults.standard.set(userIdentifier, forKey: "sns_userid02")
            
            //AppleのユーザーIDでユーザー情報を検索>ユーザ情報があればホーム画面へ遷移
            self.setMyInfoByAppleId(apple_id: userIdentifier)
            
        /*
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                //self.showPasswordCredentialAlert(username: username, password: password)
            }
        */
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    /*
    @IBAction func tapSexCdBtn(_ sender: Any) {
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        
        // プロトコルの設定
        picker.delegate = self
        picker.dataSource = self
        
        // はじめに表示する項目を指定
        if(self.sexCd == 0){
            picker.selectRow(0, inComponent: 0, animated: true)
        }else if(self.sexCd == 1){
            //男性を選択時
            picker.selectRow(2, inComponent: 0, animated: true)
        }else if(self.sexCd == 2){
            //女性を選択時
            picker.selectRow(1, inComponent: 0, animated: true)
        }
        
        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        nextBtn.isEnabled = false
        saveInfoBtn.isEnabled = false
    }
    */
    
    /*
    // UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 表示する列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // アイテム表示個数を返す
        return dataList.count
    }
    
    // UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        //画面上のボタンを有効にする
        nextBtn.isEnabled = true
        saveInfoBtn.isEnabled = true
        
        pickerView.removeFromSuperview()
        print(dataList[row])
        
        if(row == 0){
            //未選択
            self.sexCdBtn.setTitle("▼性別", for: .normal)
            self.sexCd = 0
        }else if(row == 1){
            //女性を選択
            self.sexCdBtn.setTitle("女性", for: .normal)
            self.sexCd = 2
        }else if(row == 2){
            //男性を選択
            self.sexCdBtn.setTitle("男性", for: .normal)
            self.sexCd = 1
        }
    }
    */
    
    //() -> ()の部分は　(引数) -> (返り値)を指定
    func goNext(){
        let strName = NameFeild.text
        
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //if(strName != nil && strName != "" && sexCd > 0){
        if(strName != nil && strName != ""){
            //UUIDを取得
            //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
            //let phonedeviceId = UUID().uuidString

            //ユーザーの情報を変更(登録時のみ使用)
            //GET: user_id, name, sex
            var stringUrl = Util.URL_SAVE_FIRST
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&name=")
            stringUrl.append(strName!)
            stringUrl.append("&sex=0")
            //stringUrl.append("&sex=")
            //stringUrl.append(String(sexCd))
            
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
                // 名前を保存
                UserDefaults.standard.set(strName, forKey: "myName")
                //UserDefaults.standard.set(self.sexCd, forKey: "sex_cd")
                //ログイン情報を設定
                UserDefaults.standard.set(3, forKey: "login_status")
                
                //let fcm_token = UserDefaults.standard.string(forKey: "fcm_token_temp")
                let fcm_token = UserDefaults.standard.string(forKey: "fcm_token_temp")
                //print("----------------------------")
                //print("****************************")
                //print(fcm_token)
                //print("****************************")
                //print("----------------------------")
                
                UtilFunc.modifyFcmToken(user_id:user_id, token:fcm_token!)
                
                //ホーム画面へ遷移
                UtilToViewController.toMainViewController()
            }
        }
    }
    
    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
