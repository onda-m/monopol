//
//  MainTelViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/04/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {

    let iconSize: CGFloat = 12.0
    let iconSize2: CGFloat = 14.0
    
    //@IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var backBtn: UIButton!
    
    //あなたの＊＊＊＊のところ
    //あなたの視聴回数：15
    //あなたが送ったギフト：1486 pt
    //@IBOutlet weak var yourInfoView: UIView!//今は非表示
    //@IBOutlet weak var yourLiveCount: UILabel!//今は非表示
    //@IBOutlet weak var yourPresentLbl: UILabel!//今は非表示
    
    //上部のVIEW
    @IBOutlet weak var upView: UIView!
    //下部のVIEW
    @IBOutlet weak var downView: UIView!
    
    //フリーテキスト
    @IBOutlet weak var freetextTextView: UITextView!
    
    //@IBOutlet weak var homepageBtn: UIButton!
    //@IBOutlet weak var twitterBtn: UIButton!
    //@IBOutlet weak var facebookBtn: UIButton!
    //@IBOutlet weak var instagramBtn: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

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
    
    //ユーザー情報取得用
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

    // サムネイル画像の名前
    //let photos = ["demo01","demo02","demo03","demo04","demo05","demo06","demo07","demo08","demo09"]
    //var strUserId: [String] = []
    //var strPeerIds: [String] = []
    //var strNames: [String] = []

    //フォロー情報
    //var strFollowId: [String] = []
    //var strFollowModTime: [String] = []

    //通話する直前のモデル詳細ページ
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UILabel!
    //@IBOutlet weak var telBtn: UIButton!
    //@IBOutlet weak var chatBtn: UIButton!
    
    //ランキングポイントのところ
    @IBOutlet weak var rankingPointLbl: UILabel!
    //絆レベルのところ
    @IBOutlet weak var connectLevelLbl: UILabel!
    //累計配信数
    @IBOutlet weak var allLiveCount: UILabel!
    
    //左が視聴レベル、右が配信レベル
    @IBOutlet weak var watchLevelLbl: UILabel!
    @IBOutlet weak var liveLevelLbl: UILabel!
    
    //月間ランキングのラベル
    @IBOutlet weak var monthlyRankingLbl: UILabel!
    
    //リスナーを見るボタン
    @IBOutlet weak var toListenerBtn: UIButton!
    
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var followView: UIView!
    
    @IBOutlet weak var followerCountLbl: UILabel!
    @IBOutlet weak var followCountLbl: UILabel!
    
    //フォローボタン
    @IBOutlet weak var followBtn: UIButton!

    //ダイレクトメールボタン
    @IBOutlet weak var mailBtn: UIButton!
    
    //ブラックリストボタン
    @IBOutlet weak var blacklistBtn: UIButton!
    
    //違反報告ボタン
    @IBOutlet weak var violationReportBtn: UIButton!
    
    var selectedImg:UIImage!
    //var sendText:String = ""
    var user_id: Int = 0//自分のID
    var sendId:String = ""//相手のUSER_IDが入る
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // backgroundColorを使って透過させる。
        //self.backBtn.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)

        /*
        let mainToolbarView:Maintoolbarview = UINib(nibName: "Maintoolbarview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Maintoolbarview
        mainToolbarView.toolbarViewSetting()
        //画面サイズに合わせる
        mainToolbarView.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(mainToolbarView)
        */
        
        //自分のIDを取得
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.sendId = appDelegate.sendId!
        //print(sendId)

        if(self.user_id == Int(self.sendId)){
            //自分自身の場合
            self.mailBtn.isHidden = true
            self.followBtn.isHidden = true
            self.blacklistBtn.isHidden = true
            self.violationReportBtn.isHidden = true
        }else{
            //ブラックリストの配列にない場合はnilが返される
            if(self.appDelegate.array_black_list.index(of: Int(self.sendId)!) == nil) {
                self.mailBtn.isHidden = false
                self.followBtn.isHidden = false
            }else{
                self.mailBtn.isHidden = true
                self.followBtn.isHidden = true
            }
            self.blacklistBtn.isHidden = false
            self.violationReportBtn.isHidden = false
        }

        //ランキングポイントのところ
        // 角丸
        rankingPointLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        rankingPointLbl.layer.masksToBounds = true
        rankingPointLbl.backgroundColor = Util.CAST_INFO_COLOR_RANKING_POINT_LABEL
        //ラベルの枠を自動調節する
        rankingPointLbl.adjustsFontSizeToFitWidth = true
        rankingPointLbl.minimumScaleFactor = 0.3
        
        //絆レベルのところ
        // 角丸
        connectLevelLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        connectLevelLbl.layer.masksToBounds = true
        connectLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
        //ラベルの枠を自動調節する
        connectLevelLbl.adjustsFontSizeToFitWidth = true
        connectLevelLbl.minimumScaleFactor = 0.3
        
        //累計配信数
        // 角丸
        allLiveCount.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        allLiveCount.layer.masksToBounds = true
        allLiveCount.backgroundColor = Util.CAST_INFO_COLOR_ALL_COUNT_LABEL
        //ラベルの枠を自動調節する
        allLiveCount.adjustsFontSizeToFitWidth = true
        allLiveCount.minimumScaleFactor = 0.3
        
        //右が視聴レベル、左が配信レベル
        // 角丸
        watchLevelLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        watchLevelLbl.layer.masksToBounds = true
        watchLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_WATCH_LV_LABEL
        //ラベルの枠を自動調節する
        watchLevelLbl.adjustsFontSizeToFitWidth = true
        watchLevelLbl.minimumScaleFactor = 0.3
        
        // 角丸
        liveLevelLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        liveLevelLbl.layer.masksToBounds = true
        liveLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_LIVE_LV_LABEL
        //ラベルの枠を自動調節する
        liveLevelLbl.adjustsFontSizeToFitWidth = true
        liveLevelLbl.minimumScaleFactor = 0.3
        
        //月間ランキング
        // 角丸
        monthlyRankingLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        monthlyRankingLbl.layer.masksToBounds = true
        monthlyRankingLbl.backgroundColor = Util.CAST_INFO_COLOR_MONTH_RANKING_LABEL
        //ラベルの枠を自動調節する
        monthlyRankingLbl.adjustsFontSizeToFitWidth = true
        monthlyRankingLbl.minimumScaleFactor = 0.3
        
        //リスナーを見るボタン
        // 枠線の色
        //toListenerBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //toListenerBtn.layer.borderWidth = 0
        // 角丸
        toListenerBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        toListenerBtn.layer.masksToBounds = true
        
        // 枠線の色
        followerView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOWER_FRAME.cgColor
        // 枠線の太さ
        followerView.layer.borderWidth = 0.5
        // 角丸
        followerView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        followerView.layer.masksToBounds = true
        
        // 枠線の色
        followView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        followView.layer.borderWidth = 0.5
        // 角丸
        followView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        followView.layer.masksToBounds = true

        //ダイレクトメールボタン
        // 角丸
        mailBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mailBtn.layer.masksToBounds = true
        mailBtn.backgroundColor = Util.CAST_INFO_COLOR_MAIL_BTN
        //ラベルの枠を自動調節する
        mailBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        mailBtn.titleLabel?.minimumScaleFactor = 0.3

        //ブラックリストボタン
        // 角丸
        blacklistBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        blacklistBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        blacklistBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        blacklistBtn.titleLabel?.minimumScaleFactor = 0.3
        
        //違反報告ボタン
        // 角丸
        violationReportBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        violationReportBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        violationReportBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        violationReportBtn.titleLabel?.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        nameField.adjustsFontSizeToFitWidth = true
        nameField.minimumScaleFactor = 0.3

        //ボタンのラベルの枠を自動調節する
        //telBtn.sizeToFit()
        //chatBtn.sizeToFit()

        // 枠線の色
        mainScrollView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        mainScrollView.layer.borderWidth = 1
        // 角丸
        mainScrollView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mainScrollView.layer.masksToBounds = true
        
        //モデル詳細取得
        self.getModelInfo()
        //フォローボタンの変更
        self.getFollowInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    //() -> ()の部分は　(引数) -> (返り値)を指定
    //func getModelInfo(_ after:@escaping () -> Void){
    func getModelInfo(){
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        //モデル詳細取得
        var stringUrl = Util.URL_USER_INFO
        stringUrl.append("?user_id=")
        stringUrl.append(String(sendId))
        stringUrl.append("&my_user_id=")
        stringUrl.append(String(self.user_id))
        
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
                        //特殊文字を変換する
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
            self.nameField.text = self.strUserName
            
            //self.connectLevelLbl.text = "絆Lv:" + self.strConnectLevel
            //let starIcon = FAKFontAwesome.starIcon(withSize: iconSize)
            //starIcon?.addAttribute(NSForegroundColorAttributeName, value: UIColor.red)
            //let starIconImage = (starIcon?.image(with: CGSize(width: iconSize, height: iconSize)))! as UIImage
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.connectLevelLbl.attributedText = UtilFunc.getInsertIconString(string: self.strConnectLevel, iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)

            self.followCountLbl.text = UtilFunc.numFormatter(num:Int(self.strValue03)!)
            self.followerCountLbl.text = UtilFunc.numFormatter(num:Int(self.strValue02)!)
            
            self.allLiveCount.text = "累計配信:" + UtilFunc.numFormatter(num:Int(self.strLiveTotalCount)!)
            
            //左が配信レベル、右が視聴レベル
            //self.liveLevelLbl.text = "Lv:" + Util.numFormatter(num:Int(self.strLiveLevel)!)
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.liveLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(self.strLiveLevel)!), iconImage: UIImage(named:"castinfo_live_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
            
            //self.watchLevelLbl.text = "Lv:" + Util.numFormatter(num:Int(self.strWatchLevel)!)
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.watchLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(self.strWatchLevel)!), iconImage: UIImage(named:"castinfo_viewing_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
            
            //月間ランキングポイント
            //self.rankingPointLbl.text = "R:" + Util.numFormatter(num:Int(self.strCastMonthRankingPoint)!)
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.rankingPointLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(Double(self.strCastMonthRankingPoint)!)), iconImage: UIImage(named:"castinfo_rank_ico")!, iconSize: self.iconSize, lineHeight: 1.0)
            
            //月間ランキング
            if(self.strCastMonthRanking == "0" || self.strCastMonthRanking == ""){
                //self.monthlyRankingLbl.text = "月間ランキング -位"
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.monthlyRankingLbl.attributedText = UtilFunc.getInsertIconString(string: "月間ランキング -位", iconImage: UIImage(named:"castinfo_monthly_rank")!, iconSize: self.iconSize2, lineHeight: 1.0)
            }else{
                //self.monthlyRankingLbl.text = "月間ランキング " + Util.numFormatter(num:Int(self.strCastMonthRanking)!) + "位"
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.monthlyRankingLbl.attributedText = UtilFunc.getInsertIconString(string: "月間ランキング " + UtilFunc.numFormatter(num:Int(self.strCastMonthRanking)!) + "位", iconImage: UIImage(named:"castinfo_monthly_rank")!, iconSize: self.iconSize2, lineHeight: 1.0)
            }
            
            //ブラックリストのところ
            if(self.strBlackListId != "0" && self.strBlackListId != ""){
                //ブラックリストに設定済み
                self.blacklistBtn.isEnabled = false
                self.blacklistBtn.setTitle("ブラックリストに設定済み", for: .normal)
            }
            
            //あなたの視聴回数：15
            //あなたが送ったギフト：1486 pt
            //self.yourLiveCount.text = "あなたの視聴回数:" + UtilFunc.numFormatter(num:Int(self.strConnectLiveCount)!)
            //self.yourPresentLbl.text = "あなたが送ったギフト:" + UtilFunc.numFormatter(num:Int(Double(self.strConnectPresentPoint)!)) + " pt"
            
            //フリーテキストのところ
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
            // リンクを自動的に検出してリンクに変換する
            // 編集不可にする
            self.freetextTextView.isEditable = false
            // textViewのtextにURLの文字列があればリンクとして認識する
            self.freetextTextView.dataDetectorTypes = .link
            // リンクの色を指定する
            //self.freetextTextView.linkTextAttributes = [NSForegroundColorAttributeName:UIColor.blueColor()]
            //self.freetextTextView.dataDetectorTypes = UIDataDetectorTypes.all
            
            if(strFreeTextTemp == ""){
                self.freetextTextView.isHidden = true
                //下に詰める処理
                //self.upView.frame = CGRect(x: self.upView.frame.origin.x, y: self.upView.frame.origin.y, width: self.upView.frame.width, height: self.upView.frame.height)
                //self.mainScrollView.frame = CGRect(x: self.mainScrollView.frame.origin.x, y: self.mainScrollView.frame.origin.y, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
                
                //self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height + 160)
            }else{
                self.freetextTextView.isHidden = false
                
                //self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height + 160)
            }

            //self.infoStackView.removeArrangedSubview(self.homepageBtn)
            //self.infoStackView.removeArrangedSubview(self.twitterBtn)
            //self.infoStackView.removeArrangedSubview(self.facebookBtn)

            if(self.strPhotoFlg == "1"){
                //写真を設定ずみ
                //let photoUrl = "user_images/" + self.strUserId + "_profile.jpg"
                let photoUrl = "user_images/" + self.strUserId + "/" + self.strPhotoName + "_profile.jpg"
                //画像キャッシュを使用
                self.imageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")

            }else{
                self.selectedImg = UIImage(named:"no_image")
                // UIImageをUIImageViewのimageとして設定
                self.imageView.image = self.selectedImg
            }
            
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()

            // スクロールの高さを変更(修正が必要)
            //self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width
            //    , height: 900)
        }
    }

    func getFollowInfo(){
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        //followをしているかの取得
        var stringUrl = Util.URL_GET_FOLLOW_LIST
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(sendId))
        
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
                    let json = try decoder.decode(ResultJsonFollow.self, from: data!)
                    self.followCount = json.count
                    
                    //フォロー情報を配列にする。(ただしゼロ番目のみ参照可能)
                    //for obj in json.result {
                    //    self.strFollowId.append(obj.to_user_id)
                    //    self.strFollowModTime.append(obj.mod_time)
                    //}
                    
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
                // 枠線の色
                //followBtn.layer.borderColor = UIColor.lightGray.cgColor
                // 枠線の太さ
                self.followBtn.layer.borderWidth = 0
                // 角丸
                self.followBtn.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.followBtn.layer.masksToBounds = true
                
                self.followBtn.setTitle("フォロー中", for: .normal)
                self.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                self.followBtn.backgroundColor = Util.CAST_INFO_COLOR_FOLLOW_BTN // 背景色
            }else{
                //この人をフォローしていない場合
                // 枠線の色
                self.followBtn.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
                // 枠線の太さ
                self.followBtn.layer.borderWidth = 1
                // 角丸
                self.followBtn.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.followBtn.layer.masksToBounds = true
                
                self.followBtn.setTitle("+フォロー", for: .normal)
                self.followBtn.setTitleColor(UIColor.gray, for: .normal) // タイトルの色
                self.followBtn.backgroundColor = UIColor.white // 背景色
            }
            
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // Segue を呼び出す
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toMediaConnectionViewController") {
            let subVC: MediaConnectionViewController = (segue.destination as? MediaConnectionViewController)!
            subVC.sendId = sendId
            //subVC.sendId = sender as! String
        }
    }
    */
    
    deinit {
        //画面が閉じられた後に実行
        //print("deinit is called by ViewContoller.")
        
        //self.appDelegate.viewCallFromViewControllerId = ""
        //self.appDelegate.viewReloadFlg = 0
        //var viewCallFromViewControllerId:String?//UserInfoViewControllerの呼び出し元ViewController
        //var viewReloadFlg:Int = 0//1:UserInfoViewControllerを閉じた時にリロードが必要
        
        if(self.appDelegate.viewCallFromViewControllerId == "SashiLiveViewController"
            && self.appDelegate.viewReloadFlg == 1){
            self.appDelegate.viewReloadFlg = 0//カウントだけ初期化
            UtilToViewController.toMainRankingViewController()
        }else if(self.appDelegate.viewCallFromViewControllerId == "CastSearchViewController"
            && self.appDelegate.viewReloadFlg == 1){
            self.appDelegate.viewReloadFlg = 0//カウントだけ初期化
            UtilToViewController.toCastSearchViewController()
        }
    }
    
    //詳細画面を閉じる
    @IBAction func closeBtnTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        /*
        self.dismiss(animated: true, completion: {
            [presentingViewController] () -> Void in
            // 閉じた時に行いたい処理
            presentingViewController?.viewWillAppear(true)
            //presentingViewController?.viewDidAppear(true)
            //self.sashiLiveViewControllerDelegate.getCastRanking()
        })
         */
    }
    
    //リスナーを見るボタン
    @IBAction func tapToListenerBtn(_ sender: Any) {
        appDelegate.sendNameByListenerList = self.strUserName
        appDelegate.sendIdByListenerList = self.strUserId
        UtilToViewController.toMainListenerViewController()
    }
    
    //ペアランキングを見るボタン(廃止)
    /*
    @IBAction func tapPairRankingBtn(_ sender: Any) {
        appDelegate.sendNameByPairRanking = self.strUserName
        appDelegate.sendIdByPairRanking = self.strUserId
        UtilToViewController.toPairRankingViewController()
    }
    */
    
    //ダイレクトメール
    @IBAction func mailDo(_ sender: Any) {
        appDelegate.sendId = self.strUserId
        appDelegate.sendUserName = self.strUserName
        appDelegate.sendPhotoFlg = self.strPhotoFlg
        appDelegate.sendPhotoName = self.strPhotoName
        UtilToViewController.toTalkInfoViewController()
    }
    
    @IBAction func violationReportDo(_ sender: Any) {
        //違反報告ボタンを押した時
        let actionAlert = UIAlertController(title: "このユーザーに対して違反報告をしますか？", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "報告する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //違反通報(3)の時＞通報履歴の保存
            //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
            //UserDefaults.standard.set(1, forKey: "cast_rank")
            //let cast_rank = UserDefaults.standard.integer(forKey: "cast_rank")
            //GET:alert_type, cast_id, user_id, cast_rank, live_time_count, star_temp, coin_temp
            var stringUrl = Util.URL_ALERT_RIREKI
            stringUrl.append("?alert_type=3&cast_id=")
            stringUrl.append(self.sendId)
            stringUrl.append("&user_id=")
            stringUrl.append(String(self.user_id))
            stringUrl.append("&cast_rank=")
            stringUrl.append(self.strCastRank)
            stringUrl.append("&live_time_count=0&star_temp=0&coin_temp=0")
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
                        dispatchGroup.leave()//サブタスク終了時に記述
                    }
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //「違反報告が完了しました」のメッセージ
                //showalert
                UtilFunc.showAlert(message:"違反報告が完了しました", vc:self, sec:2.0)
            }
        })
        actionAlert.addAction(modifyAction)
        
        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            //print("キャンセルのシートが押されました。")
        })
        actionAlert.addAction(cancelAction)
        
        // iPadでは必須！
        actionAlert.popoverPresentationController?.sourceView = self.view
        
        // ここで表示位置を調整。xは画面中央、yは画面下部になる様に指定
        let screenSize = UIScreen.main.bounds
        actionAlert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // 下記を追加する
        actionAlert.modalPresentationStyle = .fullScreen
        
        //アクションを表示する
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    @IBAction func blacklistDo(_ sender: Any) {
        //ブラックリスト（保存）
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)

        var stringUrl = Util.URL_SAVE_BLACKLIST
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(strUserId)
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
            self.blacklistBtn.setTitle("ブラックリストに設定中", for: .normal)

            //ブラックリストの内部配列を更新
            self.getBlackListByUser(user_id:self.user_id)
            
            //メールボタン、フォローボタンは非表示
            self.mailBtn.isHidden = true
            self.followBtn.isHidden = true
            
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
        }
    }
    
    @IBAction func followDo(_ sender: Any) {
        //フォローボタンを押した時
        
        //画面を閉じた時にフォロー数などをリロードするフラグを立てる
        self.appDelegate.viewReloadFlg = 1
        
        //flg=1:追加 2:削除
        if(self.followCount > 0){
            //この人をフォローしている場合
            follow(flg: 2)
        }else{
            //この人をフォローしていない場合
            follow(flg: 1)
        }
    }

    //双方のブラックリストの配列をアプリ内に記憶する
    func getBlackListByUser(user_id:Int){
        //クリアする
        self.appDelegate.array_black_list.removeAll()
        
        //リスト取得
        var stringUrl = Util.URL_GET_BLACKLIST_BOTH
        stringUrl.append("?order=1&user_id=")
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
                    let json = try decoder.decode(UtilStruct.ResultBlackJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        if(Int(obj.from_user_id) != self.user_id){
                            self.appDelegate.array_black_list.append(Int(obj.from_user_id)!)
                        }else if(Int(obj.to_user_id) != self.user_id){
                            self.appDelegate.array_black_list.append(Int(obj.to_user_id)!)
                        }
                    }
                    
                    dispatchGroup.leave()
                    //self.CollectionView.reloadData()
                    //print(json.result)
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //リストの取得を待ってから更新
        }
    }
    
    func follow(flg: Int!){
        //フォローする
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        //フォローの追加・削除 GET:from_user_id,to_user_id,flg
        //flg=1:追加 2:削除
        var stringUrl = Util.URL_FOLLOW_DO
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(self.strUserId)
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
            //var connection_exp: Int = Int(self.strConnectExp)!
            
            //flg=1:追加 2:削除
            if(flg == 1){
                UtilFunc.plusFollow()
                //connection_exp = connection_exp + Util.CONNECTION_POINT_FOLLOW
            }else{
                UtilFunc.minusFollow()
                //connection_exp = connection_exp - Util.CONNECTION_POINT_FOLLOW
            }

            //絆レベルの更新(値プラス or マイナス)
            self.saveConnectLevel(user_id:self.user_id, target_user_id:Int(self.strUserId)!, exp:Util.CONNECTION_POINT_FOLLOW, live_count:0, present_point:0, flg:flg)
        }
    }

    //絆レベルの更新・追加(更新後に処理をする必要があるため、Utilではなくこちらを使用)
    //flg:1:値プラス、2:値マイナス
    //GET: user_id, target_user_id,exp,live_count,present_point,flg
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
    
    /*
    @IBAction func tapHomepageBtn(_ sender: Any) {
        let url = NSURL(string: self.strHomepage)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func tapTwitterBtn(_ sender: Any) {
        let url = NSURL(string: self.strTwitter)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func tapFacebookBtn(_ sender: Any) {
        let url = NSURL(string: self.strFacebook)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func tapInstagramBtn(_ sender: Any) {
        let url = NSURL(string: self.strInstagram)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
     */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
