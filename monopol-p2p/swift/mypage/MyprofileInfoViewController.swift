//
//  MyprofileInfoViewController.swift
//  swift_skyway
//
//  Created by onda on 2019/12/04.
//  Copyright © 2019 worldtrip. All rights reserved.
//

import UIKit
//import FirebaseStorage
import AVFoundation
//import FirebaseDatabase

class MyprofileInfoViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //safearea取得用
    var topSafeAreaHeight: CGFloat = 0
    var bottomSafeAreaHeight: CGFloat = 0
    
    //自分のuser_idを指定
    var user_id:Int = 0
    //アップロードする画像
    var uploadImage = UIImage()
    
    //監視関連
    let center = NotificationCenter.default
    
    let iconSize: CGFloat = 12.0
    //let iconSize2: CGFloat = 14.0
    
    let menuStr = "1"
    var nowPage:Int = 0//現在のページ番号(0から)
    private var observers00: (player: NSObjectProtocol,willEnterForeground: NSObjectProtocol)?

    //動画のURLの配列
    //    var player = AVPlayer()
    var player00 = AVPlayer()
    //    var playerLayer = AVPlayerLayer()
    var playerLayer00 = AVPlayerLayer()
    
    @IBOutlet var mainView: UIView!//大元のVIEW
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    //リスト表示のボタン
    @IBOutlet weak var myprofileListBtn: UIButton!
    
    @IBOutlet weak var imgUploadBtn: UIButton!
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    //選択した時に重ねるView
    //var castSelectedDialog = UINib(nibName: "CastSelectedDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastSelectedDialog
    //let selectedView:ListSelectedview = UINib(nibName: "ListSelectedview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! ListSelectedview
    
/*
    //予約情報取得用(New)
    struct ReserveInfoResult: Codable {
        let id: String//
        let cast_id: String//
        let user_id: String//
        let user_peer_id: String//
        let check_timestamp: String//
        let wait_count: String//
        let wait_sec: String//
        let live_sec: String//
        let status: String//
    }
    struct ResultReserveInfoJson: Codable {
        let count: Int
        let result: [ReserveInfoResult]
    }
    
    struct UserResult: Codable {
        let user_id: String
        let notify_flg: String
        let uuid: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let movie_flg: String
        let movie_name: String
        let value02: String//フォロワー数
        let value03: String//フォロー数
        let watch_level: String
        let live_level: String
        let cast_rank: String//配信ランク(重要)
        let cast_official_flg: String//1:公式
        let cast_month_ranking_point: String//月間ランキングポイント
        let live_password: String
        let login_status: String
        let live_user_id: String
        let reserve_user_id: String
        let reserve_flg: String
        let max_reserve_count: String
        let ins_time: String
        //個別設定用
        let ex_live_sec: String
        let ex_get_live_point: String
        let ex_ex_get_live_point: String
        let ex_coin: String
        let ex_ex_coin: String
        let ex_min_reserve_coin: String
    }
    
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }
    var idCount:Int=0
    
    var castList: [(user_id:String, notify_flg:String, uuid:String, user_name:String, photo_flg:String, photo_name:String, movie_flg:String, movie_name:String, value02:String, value03:String, watch_level:String, live_level:String, cast_rank:String, cast_official_flg:String, cast_month_ranking_point:String, live_password:String, login_status:String, live_user_id:String, reserve_user_id:String, reserve_flg:String, max_reserve_count:String, ins_time:String, ex_live_sec:String, ex_get_live_point:String, ex_ex_get_live_point:String, ex_coin:String, ex_ex_coin:String, ex_min_reserve_coin:String)] = []
    var castListTemp: [(user_id:String, notify_flg:String, uuid:String, user_name:String, photo_flg:String, photo_name:String, movie_flg:String, movie_name:String, value02:String, value03:String, watch_level:String, live_level:String, cast_rank:String, cast_official_flg:String, cast_month_ranking_point:String, live_password:String, login_status:String, live_user_id:String, reserve_user_id:String, reserve_flg:String, max_reserve_count:String, ins_time:String, ex_live_sec:String, ex_get_live_point:String, ex_ex_get_live_point:String, ex_coin:String, ex_ex_coin:String, ex_min_reserve_coin:String)] = []
*/
    var castList: [(user_id:String, user_name:String, photo_flg:String, photo_name:String, photo_background_flg:String, photo_background_name:String, movie_flg:String, movie_name:String, value02:String, value03:String, watch_level:String, live_level:String, cast_rank:String, cast_official_flg:String)] = []
    
    //実際に表示したいセル達のWidthをいれておく変数
    var cellItemsHeight: CGFloat = 0.0

    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ダイアログを閉じる
        self.baseView.isHidden = true
        
        //iphone Xのみテーブルのズレが生じる場合があるので、その対応
        if #available(iOS 11.0, *) {
            //self.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior
            self.mainCollectionView.contentInsetAdjustmentBehavior = .never
        }
        
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        self.nowPage = 0
        
        self.appDelegate.request_password = "0"
        self.appDelegate.request_cast_name = ""
        self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
        /*
         if(self.appDelegate.request_count_num != 99){
         //接続状態でなければクリアする
         self.appDelegate.request_count_num = 0
         self.appDelegate.request_password = "0"
         self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
         }*/
        //クリアする(ここまで)
        
        if #available(iOS 11.0, *) {
            //safeareaの調整
            self.topSafeAreaHeight = CGFloat(UserDefaults.standard.float(forKey: "topSafeAreaHeight"))
            self.bottomSafeAreaHeight = CGFloat(UserDefaults.standard.float(forKey: "bottomSafeAreaHeight"))
            
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            //self.topSafeAreaHeight = self.view.safeAreaInsets.top
            //self.bottomSafeAreaHeight = self.view.safeAreaInsets.bottom
            print("in viewDidLayoutSubviews")
            print(self.topSafeAreaHeight)    // iPhoneXなら44, その他は20.0
            print(self.bottomSafeAreaHeight) // iPhoneXなら34,  その他は0
            
            //safeareaを考慮
            let width = self.view.frame.width
            //let height = self.view.frame.height
            
            self.mainView.frame = CGRect(x:0,y:self.topSafeAreaHeight,width:width,height:self.mainView.frame.height)
            
            //self.containerView.frame = CGRect(x:0,y:topSafeAreaHeight - 20,width:width,height:height - bottomSafeAreaHeight)
            
            //最前面に
            self.view.bringSubviewToFront(self.mainView)
        }

        // Do any additional setup after loading the view.
        /*****************************/
        //グラデーション(画面の上部分)
        /*****************************/
        //画面のサイズを取得
        //let width = UIScreen.main.bounds.size.width
        //let height = UIScreen.main.bounds.size.height
        //frame boundsを試してみる
        //グラデーションの開始色
        //let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
        let topColorUp = Util.CAST_SELECT_GRAD_START
        //グラデーションの開始色
        //let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        let bottomColorUp = Util.CAST_SELECT_GRAD_END
        //グラデーションの色を配列で管理
        let gradientColorsUp: [CGColor] = [topColorUp.cgColor, bottomColorUp.cgColor]
        //グラデーションレイヤーを作成
        let gradientLayerUp: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayerUp.colors = gradientColorsUp
        //グラデーションレイヤーをスクリーンサイズにする
        //gradientLayer.frame = self.view.bounds
        gradientLayerUp.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:80)
        
        //グラデーションレイヤー配置
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        self.view.layer.addSublayer(gradientLayerUp)
        
        /*****************************/
        //グラデーション(画面の下部分)
        /*****************************/
        //グラデーションの開始色
        //let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
        let topColorDown = Util.CAST_SELECT_GRAD_END
        //グラデーションの開始色
        //let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        let bottomColorDown = Util.CAST_SELECT_GRAD_START
        //グラデーションの色を配列で管理
        let gradientColorsDown: [CGColor] = [topColorDown.cgColor, bottomColorDown.cgColor]
        //グラデーションレイヤーを作成
        let gradientLayerDown: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayerDown.colors = gradientColorsDown
        //グラデーションレイヤーをスクリーンサイズにする
        //gradientLayer.frame = self.view.bounds
        gradientLayerDown.frame = CGRect(x:0, y:self.view.frame.height - 80, width:self.view.frame.width, height:80)
        
        //グラデーションレイヤー配置
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        self.view.layer.addSublayer(gradientLayerDown)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.player00.play()

        //初期状態に戻す
        //self.appDelegate.castMoviePlayerNum = 0
        
        //自分の情報取得
        self.getModelList()
    }
    
    /*
    //Viewが表示された直後に呼ばれる。
    //Viewが表示されたたびに呼ばれる。
    override func viewDidAppear(_ animated: Bool) {
        print("************************")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.mainCollectionView.reloadData()
        }
    }
     */
    
    override func viewDidDisappear(_ animated: Bool) {
        //完全に遷移が行われ、スクリーン上からViewControllerが表示されなくなったときに呼ばれる。
        super.viewDidDisappear(animated)
        
        //一旦全て停止
        if(self.player00.rate != 0 && self.player00.error == nil){
            self.player00.pause()
            //self.appDelegate.castMoviePlayerNum = 1
        }
        
        self.player00.replaceCurrentItem(with: nil)
    }
    
    @IBAction func tapCloseBtn(_ sender: Any) {
        UtilToViewController.toMypageViewController()
    }

    //() -> ()の部分は　(引数) -> (返り値)を指定
    //func getModelList(_ after:@escaping () -> Void){
    func getModelList(){
        /*
        UserDefaults.standard.set(strUserId, forKey: "user_id")
        UserDefaults.standard.set(strNextId, forKey: "next_id")
        UserDefaults.standard.set(strNextPass, forKey: "next_pass")
        UserDefaults.standard.set(strFcmToken, forKey: "fcm_token")
        UserDefaults.standard.set(strNotifyFlg, forKey: "notify_flg")
        UserDefaults.standard.set(strUuid, forKey: "uuid")
        UserDefaults.standard.set(strUserName, forKey: "myName")
        UserDefaults.standard.set(strPhotoFlg, forKey: "myPhotoFlg")
        UserDefaults.standard.set(strPhotoName, forKey: "myPhotoName")
        UserDefaults.standard.set(strMovieFlg, forKey: "myMovieFlg")
        UserDefaults.standard.set(strMovieName, forKey: "myMovieName")
        UserDefaults.standard.set(strValue01, forKey: "sex_cd")
        UserDefaults.standard.set(strValue02, forKey: "follower_num")
        UserDefaults.standard.set(strValue03, forKey: "follow_num")
        UserDefaults.standard.set(strValue04, forKey: "organizer_webview_flg")
        UserDefaults.standard.set(strMycollectionMax, forKey: "myCollection_max")
        UserDefaults.standard.set(strPoint, forKey: "myPoint")//小数
        UserDefaults.standard.set(strLivePoint, forKey: "myLivePoint")
        UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
        UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
        */
        
        //let watch_level: Int = UserDefaults.standard.integer(forKey: "myWatchLevel")
        //let live_level: Int = UserDefaults.standard.integer(forKey: "myLiveLevel")
        
        
        let castInfo = (String(UserDefaults.standard.integer(forKey: "user_id")),
                        UserDefaults.standard.string(forKey: "myName")!.toHtmlString(),
                        String(UserDefaults.standard.integer(forKey: "myPhotoFlg")),
                        UserDefaults.standard.string(forKey: "myPhotoName")!,
                        String(UserDefaults.standard.integer(forKey: "myPhotoBackgroundFlg")),
                        UserDefaults.standard.string(forKey: "myPhotoBackgroundName")!,
                        String(UserDefaults.standard.integer(forKey: "myMovieFlg")),
                        UserDefaults.standard.string(forKey: "myMovieName")!,
                        String(UserDefaults.standard.integer(forKey: "follower_num")),
                        String(UserDefaults.standard.integer(forKey: "follow_num")),
                        String(UserDefaults.standard.integer(forKey: "myWatchLevel")),
                        String(UserDefaults.standard.integer(forKey: "myLiveLevel")),
                        String(UserDefaults.standard.integer(forKey: "cast_rank")),
                        String(UserDefaults.standard.integer(forKey: "cast_official_flg")))
     
        self.castList.append(castInfo)
        
        print(castInfo)
        
        //一つ目の要素だけここで動画かどうかを判断する(この時点では、スクロールがされていないため)
        if(self.castList[0].movie_flg == "1"){
            //動画の場合
            self.appDelegate.castMoviePlayerNumSubMenu01 = 1
        }
        
        //リストの取得を待ってから更新
        self.mainCollectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:CastSelectCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath) as! CastSelectCollectionViewCell

        //予約可のところ
        //testCell.reserveLabel.backgroundColor = Util.CAST_LIST_RESERVE_BG
        // 角丸
        //testCell.reserveLabel.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //testCell.reserveLabel.layer.masksToBounds = true
        
        // 角丸
        testCell.officialLabel.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        testCell.officialLabel.layer.masksToBounds = true
        
        //右が視聴レベル、左が配信レベル
        // 角丸
        testCell.watchLevelLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        testCell.watchLevelLbl.layer.masksToBounds = true
        testCell.watchLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_WATCH_LV_LABEL
        //ラベルの枠を自動調節する
        testCell.watchLevelLbl.adjustsFontSizeToFitWidth = true
        testCell.watchLevelLbl.minimumScaleFactor = 0.3
        
        // 角丸
        testCell.liveLevelLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        testCell.liveLevelLbl.layer.masksToBounds = true
        testCell.liveLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_LIVE_LV_LABEL
        //ラベルの枠を自動調節する
        testCell.liveLevelLbl.adjustsFontSizeToFitWidth = true
        testCell.liveLevelLbl.minimumScaleFactor = 0.3
        
        // Tag番号を使ってLabelのインスタンス生成
        //キャスト名
        let label = testCell.contentView.viewWithTag(3) as! UILabel
        label.text = castList[indexPath.row].user_name
        //ラベルの枠を自動調節する
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3

        /*
        // Tag番号を使ってLabelのインスタンス生成
        if(castList[indexPath.row].login_status == "1"
            && self.array_request_do_user_id.contains(castList[indexPath.row].user_id) == true){
            //待機状態で、かつ、すでに通常リクエストデータがある場合（重複のリクエストを避けるための対策）
            //リクエスト・予約をできないように
            
            //パスワードアイコン
            if(castList[indexPath.row].live_password == "0"){
                //通常
                testCell.passwordView.isHidden = true
            }else{
                //パスワード付き
                testCell.passwordView.isHidden = false
            }
            
            //予約はできない
            testCell.reserveLabel.isHidden = true
            
            //ライブ配信ボタン表示
            testCell.liveStartBtn.isUserInteractionEnabled = false
            testCell.liveStartBtn.isHidden = false
            let picture = UIImage(named: "live_on_btn")
            testCell.liveStartBtn.setImage(picture, for: .normal)
            
            //右上のステータスアイコン
            let cellImageStatus = UIImage(named:"cast_list_onlive")
            testCell.statusImage.image = cellImageStatus
            testCell.statusImage.isHidden = false
            
        }else{
            //0:会員登録中 1:待機中 2:通話中 3:ログオフ状態 4:通話中(予約申請) 5:通話中(予約済) 6:通話中(予約キャンセル) 7:キャストによる予約拒否 98:削除 99:リストア済み
            //0:まだ通常リクエストデータがない場合
            if(castList[indexPath.row].login_status == "1"){
                //待機状態の帯
                //testCell.statusLabel.isHidden = false
                //testCell.statusLabel.text = Util.WAIT_WELCOME_STR
                //testCell.statusLabel.backgroundColor = Util.WELCOME_LABEL_COLOR
                
                //右上のステータスアイコン
                let cellImageStatus = UIImage(named:"cast_list_welcome")
                testCell.statusImage.image = cellImageStatus
                testCell.statusImage.isHidden = false
                
                //パスワードアイコン
                if(castList[indexPath.row].live_password == "0"){
                    //通常
                    testCell.passwordView.isHidden = true
                }else{
                    //パスワード付き
                    testCell.passwordView.isHidden = false
                }
                
                //予約可のところ
                testCell.reserveLabel.isHidden = true
                
                //ライブ配信ボタン表示
                testCell.liveStartBtn.isUserInteractionEnabled = true//押せるようにする
                testCell.liveStartBtn.isHidden = false
                let picture = UIImage(named: "live_start_btn")
                testCell.liveStartBtn.setImage(picture, for: .normal)
                
            }else if(castList[indexPath.row].login_status == "2"
                || castList[indexPath.row].login_status == "4"
                || castList[indexPath.row].login_status == "6"
                || castList[indexPath.row].login_status == "7"
                ){
                //通話中
                //待機状態の帯
                //testCell.statusLabel.isHidden = false
                //testCell.statusLabel.text = "On Live"
                //testCell.statusLabel.backgroundColor = Util.ON_LIVE_LABEL_COLOR
                
                //パスワードアイコン
                if(castList[indexPath.row].live_password == "0"){
                    //通常
                    testCell.passwordView.isHidden = true
                }else{
                    //パスワード付き
                    testCell.passwordView.isHidden = false
                }
                
                /***************************************/
                /*初期リリース時は予約不可*/
                /***************************************/
                //予約不可
                testCell.reserveLabel.isHidden = true
                
                //ライブ配信ボタン表示
                testCell.liveStartBtn.isUserInteractionEnabled = false
                testCell.liveStartBtn.isHidden = false
                let picture = UIImage(named: "live_on_btn")
                testCell.liveStartBtn.setImage(picture, for: .normal)
                
                //右上のステータスアイコン
                //let cellImageStatus = UIImage(named:"cast_list_reserve")
                let cellImageStatus = UIImage(named:"cast_list_onlive")
                testCell.statusImage.image = cellImageStatus
                testCell.statusImage.isHidden = false

            }else if(castList[indexPath.row].login_status == "3"){
                //ログオフ状態
                
                //待機状態の帯
                //testCell.statusLabel.isHidden = true
                //右上のステータスアイコン
                testCell.statusImage.isHidden = true
                //パスワードアイコン
                testCell.passwordView.isHidden = true
                //予約可のところ
                testCell.reserveLabel.isHidden = true
                //ライブ配信ボタン表示
                testCell.liveStartBtn.isHidden = true
            }else{
                //待機状態の帯
                //testCell.statusLabel.isHidden = true
                //右上のステータスアイコン
                testCell.statusImage.isHidden = true
                //パスワードアイコン
                testCell.passwordView.isHidden = true
                //予約可のところ
                testCell.reserveLabel.isHidden = true
                //ライブ配信ボタン表示
                testCell.liveStartBtn.isHidden = true
            }
        }
        */

        // Tag番号を使ってImageViewのインスタンス生成
        //let imageCircleView = testCell.contentView.viewWithTag(2) as! EnhancedCircleImageView
        let imageCircleView = testCell.castProfileImageView
        //ユーザー画像の表示
        let photoFlg = castList[indexPath.row].photo_flg
        let photoName = castList[indexPath.row].photo_name
        let user_id = castList[indexPath.row].user_id
        if(photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + user_id + "_profile.jpg"
            let photoUrl = "user_images/" + user_id + "/" + photoName + "_profile.jpg"
            
            //画像キャッシュを使用
            imageCircleView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            imageCircleView?.image = cellImage
        }
        imageCircleView?.backgroundColor = UIColor.white
        
        //公式のところ
        let officialFlg = castList[indexPath.row].cast_official_flg
        if(officialFlg == "1"){
            //公式
            testCell.officialLabel.isHidden = false
        }else{
            testCell.officialLabel.isHidden = true
        }
        
        //左が配信レベル、右が視聴レベル
        //self.liveLevelLbl.text = "Lv:" + Util.numFormatter(num:Int(self.strLiveLevel)!)
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        testCell.liveLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(castList[indexPath.row].live_level)!), iconImage: UIImage(named:"castinfo_live_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
        
        //self.watchLevelLbl.text = "Lv:" + Util.numFormatter(num:Int(self.strWatchLevel)!)
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        testCell.watchLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(castList[indexPath.row].watch_level)!), iconImage: UIImage(named:"castinfo_viewing_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
        
        //プロフィールボタンを押した時の処理
        testCell.profileBtnImage.tag = indexPath.row
        testCell.profileBtnImage.isUserInteractionEnabled = true
        testCell.profileBtnImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:))))
        
        testCell.profileBtn.tag = indexPath.row
        testCell.profileBtn.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        
        //下記は動かない
        //自分のプロフィールリストを見るを押した時の処理
        //testCell.liveStartBtn.tag = indexPath.row
        //testCell.liveStartBtn.addTarget(self, action: #selector(toMyprofileList(sender: )), for: .touchUpInside)
        
        //動画を再生
        //https://qiita.com/tattn/items/499b5f49fb11f55b3df7
        // Bundle Resourcesからsample.mp4を読み込んで再生
        //let path = Bundle.main.path(forResource: "sample", ofType: "mp4")!
        
        //let photoUrl: String = Util.URL_FIREBASE + "/cast_movies/"
        //    + castList[indexPath.row].user_id
        //    + ".mp4"
        
        // Tag番号を使ってImageViewのインスタンス生成
        //let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        let imageView = testCell.castImageView
        let movieFlg = castList[indexPath.row].movie_flg
        let movieName = castList[indexPath.row].movie_name
        
        //背景画像
        let photoBackgroundFlg = castList[indexPath.row].photo_background_flg
        let photoBackgroundName = castList[indexPath.row].photo_background_name
        
        if(movieFlg == "0"){
            //動画の設定なし
            //画像のレイヤーを表示
            imageView?.isHidden = false
            
            if(photoBackgroundFlg == "1"){
                //背景画像の設定あり
                //写真設定済み
                //let photoUrl = "user_images/" + user_id + ".jpg"
                let photoBackgroundUrl = "user_background_images/" + user_id + "/" + photoBackgroundName + ".jpg"
                
                //画像キャッシュを使用
                imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoBackgroundUrl, no_image_named:"no_image")
                
                //キャッシュサーバーに画像キャッシュを作成
                UtilFunc.createCachePhotoBackgroundByUrl(user_id:Int(user_id)!, file_name:photoBackgroundName)
            }else{
                //背景画像の設定なし
                if(photoFlg == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + user_id + ".jpg"
                    let photoUrl = "user_images/" + user_id + "/" + photoName + ".jpg"
                    
                    //画像キャッシュを使用
                    imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                    
                    //キャッシュサーバーに画像キャッシュを作成
                    UtilFunc.createCachePhotoByUrl(user_id:Int(user_id)!, file_name:photoName)
                }
            }
            
        }else if(movieFlg == "1"){
            //画像のレイヤーを表示
            imageView?.isHidden = false
            
            if(photoBackgroundFlg == "1"){
                //背景画像の設定あり
                //写真設定済み
                //let photoUrl = "user_images/" + user_id + ".jpg"
                let photoBackgroundUrl = "user_background_images/" + user_id + "/" + photoBackgroundName + ".jpg"
                
                //画像キャッシュを使用
                imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoBackgroundUrl, no_image_named:"no_image")
                
                //キャッシュサーバーに画像キャッシュを作成
                UtilFunc.createCachePhotoBackgroundByUrl(user_id:Int(user_id)!, file_name:photoBackgroundName)
            }else{
                //背景画像の設定なし
                if(photoFlg == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + user_id + ".jpg"
                    let photoUrl = "user_images/" + user_id + "/" + photoName + ".jpg"
                    
                    //画像キャッシュを使用
                    imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                    
                    //キャッシュサーバーに画像キャッシュを作成
                    UtilFunc.createCachePhotoByUrl(user_id:Int(user_id)!, file_name:photoName)
                }
            }
            
            // アイテム取得
            //let playerItem = AVPlayerItem.init(url: url)
            // 生成
            //player = AVPlayer(playerItem: playerItem)
            //player = AVPlayer(playerItem: playerItemArray[indexPath.row])
            //self.playerArray[indexPath.row].automaticallyWaitsToMinimizeStalling = false//速く再生開始となる
            
            let movieUrl = Util.URL_USER_MOVIE_BASE + user_id + "/" + movieName + ".mp4"
            let url = URL(string: movieUrl)!
            let playerItem = AVPlayerItem.init(url: url)
            
            //let boundary = CMTimeMake(20, 100)//0.2sごとに監視処理が走る
            let boundary = CMTimeMake(value: 20, timescale: 100)//0.2sごとに監視処理が走る
            
            // すべて解除
            //self.center.removeObserver(self)
            
            self.playerLayer00.removeFromSuperlayer()
            self.player00 = AVPlayer(playerItem: playerItem)
            self.player00.automaticallyWaitsToMinimizeStalling = false//速く再生開始となる
            self.playerLayer00 = AVPlayerLayer(player: self.player00)
            self.playerLayer00.frame = self.view.bounds
            self.playerLayer00.videoGravity = .resizeAspectFill
            self.playerLayer00.zPosition = -1 // ボタン等よりも後ろに表示
            
            //testCell.layer.insertSublayer(self.playerLayer00, at: 0) // 動画をレイヤーとして追加
            testCell.layer.addSublayer(self.playerLayer00) // 動画をレイヤーとして追加
            
            self.player00.play()
            
            //self.view.bringSubview(toFront: self.playerLayer00)
            /*
             // 動画の上に重ねる半透明の黒いレイヤー
             let dimOverlay = CALayer()
             dimOverlay.frame = view.bounds
             dimOverlay.backgroundColor = UIColor.black.cgColor
             dimOverlay.zPosition = -1
             dimOverlay.opacity = 0.4 // 不透明度
             view.layer.insertSublayer(dimOverlay, at: 0)
             */
            
            // 動画の読み込み完了時
            //動画が再生されているかどうかは rateで判断
            //再生位置が1nsになるのを監視
            //NSValue(time: init(CMTime: boundary))
            self.player00.addPeriodicTimeObserver(forInterval: boundary, queue: nil, using: {_ in
                //0.5秒後に画像のレイヤーを非表示
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    imageView?.isHidden = true
                }
            })
            
            // 最後まで再生したら最初から再生する
            let playerObserver00 = self.center.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: self.player00.currentItem,
                queue: .main) { [weak playerLayer00] _ in
                    playerLayer00?.player?.seek(to: CMTime.zero)
                    playerLayer00?.player?.play()
            }
            
            // アプリがバックグラウンドから戻ってきた時に再生する
            let willEnterForegroundObserver00 = self.center.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main) { [weak playerLayer00] _ in
                    
                    if(self.appDelegate.castMoviePlayerNumSubMenu01 == 1){
                        print("000-----")
                        playerLayer00?.player?.play()
                    }
            }
            
            self.observers00 = (playerObserver00, willEnterForegroundObserver00)
            
            //キャッシュサーバーに動画キャッシュを作成
            UtilFunc.createCacheMovieByUrl(user_id:Int(user_id)!, file_name:movieName)
            
        }else{
            //一度動画が再生されていれば下記を実行
            //if(self.playFlg == 1){
            //    self.playerLayer.removeFromSuperlayer()
            //    self.playFlg = 0
            //}
            
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            imageView?.image = cellImage
            //画像のレイヤーを表示
            imageView?.isHidden = false
            //playerLayer?.removeFromSuperlayer()
            //playerLayer?.isHidden = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 0.5秒後に実行したい処理
            if #available(iOS 11.0, *) {
                //safeareaの調整
                let topSafeAreaHeight = UserDefaults.standard.float(forKey: "topSafeAreaHeight")
                let bottomSafeAreaHeight = UserDefaults.standard.float(forKey: "bottomSafeAreaHeight")
                
                //safeareaを考慮
                let width = testCell.frame.width
                let height = testCell.frame.height
                
                testCell.upView.frame = CGRect(x: 0, y: CGFloat(topSafeAreaHeight) + 40, width: width, height: testCell.upView.frame.height)
                testCell.downView.frame = CGRect(x: 0, y: height - CGFloat(bottomSafeAreaHeight) - testCell.downView.frame.height, width: width, height: testCell.downView.frame.height)
            }
            
            testCell.upView.isHidden = false
            testCell.downView.isHidden = false
            self.view.bringSubviewToFront(testCell.downView)
        }
        
        return testCell
    }
    
    deinit {
        // 画面が破棄された時に監視をやめる
        if let observers00 = observers00 {
            self.center.removeObserver(observers00.player)
            self.center.removeObserver(observers00.willEnterForeground)
            //observers.bounds.invalidate()
            
            //self.playerArray[indexPath.row].removeObserver(self, forKeyPath: "rate")
        }
        
        self.player00.replaceCurrentItem(with: nil)
    }
    
    //プロフィールボタンを押した時
    @objc func onClick(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modelInfo: UserInfoViewController = storyboard.instantiateViewController(withIdentifier: "toUserInfoViewController") as! UserInfoViewController

        //let modelInfo: UserInfoViewController = self.storyboard!.instantiateViewController(withIdentifier: "toUserInfoViewController") as! UserInfoViewController
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //modelInfo.sendId = strPeerIds[selectedId]
        appDelegate.sendId = castList[buttonRow].user_id
        
        //選択しているサブメニューの保存(重要)
        //appDelegate.sendDetailSubMenu = self.menuStr
        //appDelegate.sendSubMenuFirst = menuStr
        //UserDefaults.standard.set(self.menuStr, forKey: "selectedSubMenu")
        
        // 下記を追加する
        modelInfo.modalPresentationStyle = .overCurrentContext
        
        present(modelInfo, animated: true, completion: nil)
    }
    
    /*
     //１回目の表示(配信リクエストをするかどうかの確認など)
     //トータル待ち人数
     //トータル待ち時間
     func setDialog(cast_id:Int, cast_name:String, wait_num:Int, wait_sec:Int){
     //self.normalDelPointLbl.text = "消費コイン:" + String(self.live_coin)
     let strDelPoint = "消費コイン:" + String(Int(self.appDelegate.live_pay_coin))
     
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
     print("----必要なコインの確認----")
     print("----get_live_point----")
     print(self.appDelegate.get_live_point)
     print("----ex_get_live_point----")
     print(self.appDelegate.ex_get_live_point)
     print("----live_coin----")
     print(self.appDelegate.live_pay_coin)
     print("----live_ex_coin----")
     print(self.appDelegate.live_pay_ex_coin)
     print("----コインの確認(ここまで)----")
     
     //自分の予約データをクリアする
     UtilFunc.reserveListClearByUserId(user_id:user_id, status:0)
     
     if(wait_num == 0){
     //通常リクエスト
     
     //1回目のタップ
     //UIAlertControllerを用意する
     let actionAlert = UIAlertController(title: UtilFunc.strMin(str:cast_name, num:Util.NAME_MOJI_COUNT_SMALL) + "さんとサシライブしますか?\n" + strDelPoint
     ,message: nil, preferredStyle: UIAlertController.Style.actionSheet)
     
     //UIAlertControllerにアクションを追加する
     let modifyAction = UIAlertAction(title: "サシライブする", style: UIAlertAction.Style.default, handler: {
     (action: UIAlertAction!) in
     //選択された時の処理
     
     print("----必要なコインの確認----")
     print("----get_live_point----")
     print(self.appDelegate.get_live_point)
     print("----ex_get_live_point----")
     print(self.appDelegate.ex_get_live_point)
     print("----live_coin----")
     print(self.appDelegate.live_pay_coin)
     print("----live_ex_coin----")
     print(self.appDelegate.live_pay_ex_coin)
     print("----コインの確認(ここまで)----")
     
     //マイコインが足りているかのチェック
     let myPointTemp:Double = UserDefaults.standard.double(forKey: "myPoint")//所有しているコイン
     
     if(self.appDelegate.live_pay_coin > myPointTemp){
     //一旦自分自身をclose(そうしないと最前面にきてしまう)
     //self.closeDialog()
     
     //足りていない場合(購入ダイアログを表示)
     UtilToViewController.toPurchaseCommonViewController()
     }else{
     //最前面に
     self.castSelectedDialog.isHidden = false
     self.view.bringSubviewToFront(self.castSelectedDialog)
     
     //先頭にまずダイアログを表示
     //右上のバツボタンを非表示(重要)
     self.castSelectedDialog.closeBtn.isHidden = true
     
     /***************************/
     //ラベル作成
     /***************************/
     self.castSelectedDialog.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
     // テキストを中央寄せ
     self.castSelectedDialog.infoLbl.attributedText = UtilFunc.getInsertIconString(string: "サシライブ申請準備中...", iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
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
     
     if(self.appDelegate.request_password == "0"
     || self.appDelegate.request_password == ""){
     //パスワードなしの場合
     self.castSelectedDialog.setDialogNext(cast_id:self.appDelegate.request_cast_id,
     user_id:self.user_id,
     cast_name:self.appDelegate.request_cast_name!)
     }
     
     /*
     if(self.castSelectedDialog.mainViewTapFlg == 1){
     //すでに予約中
     }else{
     //新規に予約
     self.castSelectedDialog.mainViewTapFlg = 1//タップをさせないようにする
     
     if(self.appDelegate.request_password == "0"
     || self.appDelegate.request_password == ""){
     //パスワードなしの場合
     self.castSelectedDialog.setDialogNext(cast_id:self.appDelegate.request_cast_id, cast_name:self.appDelegate.request_cast_name!)
     }
     }
     */
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
     }else{
     //予約リクエスト
     
     /****************************/
     //最大予約数のチェック
     /****************************/
     //var cast_login_status_check = 0
     //var cast_live_user_id_check: String = ""
     //var cast_reserve_user_id_check: String = ""
     //var cast_reserve_peer_id_check: String = ""
     var cast_reserve_flg_check = 0
     var max_reserve_count_check = 0
     var now_reserve_have_check = 0
     
     //ストリーマーの状態(MAXの予約数、現在の予約数など)を取得
     var stringUrl = Util.URL_GET_LIVE_CAST_STATUS
     stringUrl.append("?user_id=")
     stringUrl.append(String(cast_id))
     
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
     //cast_login_status_check = Int(obj.login_status)!
     //self.cast_live_user_id_check = obj.live_user_id
     //self.cast_reserve_user_id_check = obj.reserve_user_id
     //self.cast_reserve_peer_id_check = obj.reserve_peer_id
     cast_reserve_flg_check = Int(obj.reserve_flg)!
     max_reserve_count_check = Int(obj.max_reserve_count)!
     now_reserve_have_check = Int(obj.now_reserve_have)!
     
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
     //1回目のタップ
     //0:予約可能　1:予約不可能
     if(cast_reserve_flg_check == 1){
     //予約できない旨のメッセージ
     //self.showAlert(str:UtilStr.ERROR_SELECT_STREAMER_001)
     UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_STREAMER_001, vc:self, sec:2.0)
     }else{
     if(max_reserve_count_check <= now_reserve_have_check){
     //予約がマックス数に達している場合
     //self.showAlert(str:UtilStr.ERROR_SELECT_STREAMER_005)
     UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_STREAMER_005, vc:self, sec:2.0)
     }else{
     //予約できない旨のメッセージ
     //現在サシライブ中のため申請ができない
     UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_STREAMER_008, vc:self, sec:2.0)
     
     /*
     //まだ予約が可能な場合
     let strRequestLabel = "さんへサシライブの予約をしますか?\n消費コイン:" + String(Int(self.appDelegate.live_pay_coin)) + "\n予約が成立した場合、成立時から\n" + UtilFunc.convertStrBySec(sec:wait_sec) + "サシライブが始まります。"
     
     //1回目のタップ
     //UIAlertControllerを用意する
     let actionAlert = UIAlertController(title: UtilFunc.strMin(str:self.appDelegate.request_cast_name!, num:Util.NAME_MOJI_COUNT_SMALL) + strRequestLabel
     ,message: nil, preferredStyle: UIAlertController.Style.actionSheet)
     
     //UIAlertControllerにアクションを追加する
     let modifyAction = UIAlertAction(title: "予約をする", style: UIAlertAction.Style.default, handler: {
     (action: UIAlertAction!) in
     //選択された時の処理
     
     print("----必要なコインの確認----")
     print("----get_live_point----")
     print(self.appDelegate.get_live_point)
     print("----ex_get_live_point----")
     print(self.appDelegate.ex_get_live_point)
     print("----live_coin----")
     print(self.appDelegate.live_pay_coin)
     print("----live_ex_coin----")
     print(self.appDelegate.live_pay_ex_coin)
     print("----コインの確認(ここまで)----")
     
     //マイコインが足りているかのチェック
     let myPointTemp:Double = UserDefaults.standard.double(forKey: "myPoint")//所有しているコイン
     
     if(self.appDelegate.live_pay_coin > myPointTemp){
     //一旦自分自身をclose(そうしないと最前面にきてしまう)
     //self.closeDialog()
     
     //足りていない場合(購入ダイアログを表示)
     UtilToViewController.toPurchaseCommonViewController()
     }else{
     //最前面に
     self.castSelectedDialog.isHidden = false
     self.view.bringSubviewToFront(self.castSelectedDialog)
     
     //先頭にまずダイアログを表示
     //右上のバツボタンを非表示(重要)
     self.castSelectedDialog.closeBtn.isHidden = true
     
     /***************************/
     //ラベル作成
     /***************************/
     self.castSelectedDialog.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
     // テキストを中央寄せ
     self.castSelectedDialog.infoLbl.attributedText = UtilFunc.getInsertIconString(string: "サシライブ申請準備中...", iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
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
     */
     }
     }
     }
     }
     }else{
     //パスワードありの場合（今回は未実装）
     //1回目のタップ
     //self.mainViewTapFlg = 0//タップできる
     }
     }
     */
    
    /*
    //予約なしのバージョン
    //１回目の表示(配信リクエストをするかどうかの確認など)
    func setDialog(cast_id:Int, cast_name:String){
        
        var strLiveTime = ""
        if(self.appDelegate.init_seconds % 60 == 0){
            //1枠の秒数がN分の場合
            strLiveTime = String(self.appDelegate.init_seconds / 60) + "分"
        }else{
            strLiveTime = String(self.appDelegate.init_seconds) + "秒"
        }
        
        //self.normalDelPointLbl.text = "消費コイン:" + String(self.live_coin)
        let strDelPoint = strLiveTime + "の消費コイン:" + String(Int(self.appDelegate.live_pay_coin))
        
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
            print("----必要なコインの確認----")
            print("----get_live_point----")
            print(self.appDelegate.get_live_point)
            print("----ex_get_live_point----")
            print(self.appDelegate.ex_get_live_point)
            print("----live_coin----")
            print(self.appDelegate.live_pay_coin)
            print("----live_ex_coin----")
            print(self.appDelegate.live_pay_ex_coin)
            print("----コインの確認(ここまで)----")
            
            //自分の予約データをクリアする(不要かも)
            UtilFunc.reserveListClearByUserId(user_id:user_id, status:0)
            
            //通常リクエスト
            
            //1回目のタップ
            //UIAlertControllerを用意する
            let actionAlert = UIAlertController(title: UtilFunc.strMin(str:cast_name, num:Util.NAME_MOJI_COUNT_SMALL) + "さんとサシライブしますか?\n" + strDelPoint
                ,message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "サシライブする", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                
                print("----必要なコインの確認----")
                print("----get_live_point----")
                print(self.appDelegate.get_live_point)
                print("----ex_get_live_point----")
                print(self.appDelegate.ex_get_live_point)
                print("----live_coin----")
                print(self.appDelegate.live_pay_coin)
                print("----live_ex_coin----")
                print(self.appDelegate.live_pay_ex_coin)
                print("----コインの確認(ここまで)----")
                
                //マイコインが足りているかのチェック
                let myPointTemp:Double = UserDefaults.standard.double(forKey: "myPoint")//所有しているコイン
                
                if(self.appDelegate.live_pay_coin > myPointTemp){
                    //一旦自分自身をclose(そうしないと最前面にきてしまう)
                    //self.closeDialog()
                    
                    //足りていない場合(購入ダイアログを表示)
                    UtilToViewController.toPurchaseCommonViewController()
                }else{
                    //最前面に
                    self.castSelectedDialog.isHidden = false
                    self.view.bringSubviewToFront(self.castSelectedDialog)
                    
                    //先頭にまずダイアログを表示
                    //右上のバツボタンを非表示(重要)
                    self.castSelectedDialog.closeBtn.isHidden = true
                    
                    /***************************/
                    //ラベル作成
                    /***************************/
                    self.castSelectedDialog.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
                    // テキストを中央寄せ
                    self.castSelectedDialog.infoLbl.attributedText = UtilFunc.getInsertIconString(string: "サシライブ申請準備中...", iconImage: UIImage(named:"live_request")!, iconSize: self.iconSize, lineHeight: 1.5)
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
                    
                    if(self.appDelegate.request_password == "0"
                        || self.appDelegate.request_password == ""){
                        //パスワードなしの場合
                        self.castSelectedDialog.setDialogNext(cast_id:self.appDelegate.request_cast_id,
                                                              user_id:self.user_id,
                                                              cast_name:self.appDelegate.request_cast_name!)
                    }
                    
                    /*
                     if(self.castSelectedDialog.mainViewTapFlg == 1){
                     //すでに予約中
                     }else{
                     //新規に予約
                     self.castSelectedDialog.mainViewTapFlg = 1//タップをさせないようにする
                     
                     if(self.appDelegate.request_password == "0"
                     || self.appDelegate.request_password == ""){
                     //パスワードなしの場合
                     self.castSelectedDialog.setDialogNext(cast_id:self.appDelegate.request_cast_id, cast_name:self.appDelegate.request_cast_name!)
                     }
                     }
                     */
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
        }else{
            //パスワードありの場合（今回は未実装）
            //1回目のタップ
            //self.mainViewTapFlg = 0//タップできる
        }
    }
    */
    
    @IBAction func tapMyprofileList(_ sender: Any) {
        //ダイアログ(ダイアログを重ねる)
        let myprofileListDialog:MyprofileListDialog = UINib(nibName: "MyprofileListDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! MyprofileListDialog
        //画面サイズに合わせる(selfでなく、superviewにすることが重要)
        myprofileListDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(myprofileListDialog)
    }
    
    //背景画像を設定するボタンがタップされたら呼ばれる
    @IBAction func tapImgUploadBtn(_ sender: Any) {
        //アルバムへのアクセス許可
        //UtilFunc.checkPermissionAlbumn()

        //let photoLibraryManager = PhotoLibraryManager.init(parentViewController: self)
        //photoLibraryManager.requestAuthorizationOn()
        //photoLibraryManager.callPhotoLibraryNoTrimView()
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        // 下記を追加する
        picker.modalPresentationStyle = .fullScreen
        
        present(picker, animated: true)
        
        /*
        //ダイアログ(ダイアログを重ねる)
        let imgUploadDialog:ImgUploadDialog = UINib(nibName: "ImgUploadDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! ImgUploadDialog
        //画面サイズに合わせる(selfでなく、superviewにすることが重要)
        imgUploadDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(imgUploadDialog)
         */
    }
    
    // プロフィール画像がタップされたら呼ばれる
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        //print(sender)
        let buttonRow = sender.view?.tag
        
        //print(selectedId)
        let modelInfo: UserInfoViewController = self.storyboard!.instantiateViewController(withIdentifier: "toUserInfoViewController") as! UserInfoViewController
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //modelInfo.sendId = strPeerIds[selectedId]
        appDelegate.sendId = castList[buttonRow!].user_id
        
        //選択しているサブメニューの保存(重要)
        //appDelegate.sendDetailSubMenu = self.menuStr
        
        // 下記を追加する
        modelInfo.modalPresentationStyle = .overCurrentContext
        
        present(modelInfo, animated: true, completion: nil)
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = view.frame.width
        let height: CGFloat = view.frame.height
        return CGSize(width: width, height: height)
        
        /*
         let width: CGFloat = view.frame.width / 4 - 8
         let height: CGFloat = width + 10
         return CGSize(width: width, height: height)
         */
    }
    
    /////////追加(ここから)////////////////////////////
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        //return idCount
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //print(scrollView.currentPage)
        
        if(self.castList.count > 0){
            self.nowPage = scrollView.currentPage - 1
            
            //print(self.nowPage)
            if(self.nowPage < 0){
                self.nowPage = 0
            }
            
            let movieFlgTemp = self.castList[self.nowPage].movie_flg
            
            if(movieFlgTemp == "1"){
                //動画の場合
                self.playerLayer00.isHidden = false
                self.player00.play()
                
                self.appDelegate.castMoviePlayerNumSubMenu01 = 1
            }else{
                //動画でない場合は、一旦停止
                if(self.player00.rate != 0 && self.player00.error == nil){
                    self.playerLayer00.isHidden = true
                    self.player00.pause()
                }
                
                self.appDelegate.castMoviePlayerNumSubMenu01 = 0
            }
        }
    }
    
    /*
     //下記のどちらかを通る
     //基本scrollViewDidEndDeceleratingのみで良いと思う(isPagingEnabled=trueはページの区切りまで自動スクロールするので)が、
     //この Delegate はドラッグをピタッと止めた場合は呼ばれないので、その時でも検出できるように念のためscrollViewDidEndDraggingで
     //かつdecelerate=falseの場合にも取得するようにしておく。
     func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
     if !decelerate {
     print("currentPage:", scrollView.currentPage)
     //self.nowPage = scrollView.currentPage
     }
     }
     
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
     print("currentPage:", scrollView.currentPage)
     //self.nowPage = scrollView.currentPage
     }
     */

    //画面の上部に表示される時間やバッテリー残量を非表示
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //画像のアップロード処理
    //アップロードした画像そのものと、プロフィール用画像と、リスト用画像の３種類を保存する。
    //それぞれ、.jpg _profile.jpg _list.jpg
    //cropThumbnailImage(image :UIImage, w:Int, h:Int)
    func backgroundImageUpload(image: UIImage, user_id: Int) {
        let file_name_temp = UtilFunc.getNowClockString(flg:1)

        //DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        //    self.mainCollectionView.reloadData()
        //}
        
        //画像のサイズ変更(プロフィール画像)
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        let profileImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.BACKGROUND_USER_PROFILE_PHOTO_WIDTH), height:Double(Util.BACKGROUND_USER_PROFILE_PHOTO_HEIGHT))
        if let profiledata = profileImage.pngData() {
            //let fileName = String(user_id) + "_profile.jpg"
            let fileName = file_name_temp + "_profile.jpg"
            
            //let body = Util.httpBody(profiledata,fileName: fileName)
            let body = UtilFunc.httpBodyAlpha(profiledata, fileName: fileName, castId: "0", userId: String(user_id))
            
            //let url = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_PHOTO_BACKGROUND)!, data: body) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        print("Upload done")
                        //画面更新
                        UserDefaults.standard.set(1, forKey: "myPhotoBackgroundFlg")
                        UserDefaults.standard.set(file_name_temp, forKey: "myPhotoBackgroundName")
                        //ボタンの背景に選択した画像を設定
                        //self.userImageView.image = profileImage
                        //ツールバー上のプロフィール画像をセット
                        //self.mainToolbarView.profileImageView.image = profileImage
                        //self.mainToolbarView.profileImageView.isHidden = false
                    } else {
                        //self.mainToolbarView.profileImageView.isHidden = true
                        print(response.statusCode)
                    }
                }
            }
        }
        
        //画像のサイズ変更(個別用の画像)
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        //let orgImage = Util.resizeImage(image :image, w:Int(Util.USER_ORG_PHOTO_WIDTH), h:Int(Util.USER_ORG_PHOTO_HEIGHT))
        let orgImage = UtilFunc.resizeImage(image :image, width:Double(Util.BACKGROUND_USER_ORG_PHOTO_WIDTH), height:Double(Util.BACKGROUND_USER_ORG_PHOTO_HEIGHT))
        if let orgdata = orgImage.pngData() {
            let orgfileName = file_name_temp + ".jpg"
            //let orgbody = Util.httpBody(orgdata, fileName: orgfileName)
            let orgbody = UtilFunc.httpBodyAlpha(orgdata, fileName: orgfileName, castId: "0", userId: String(user_id))
            //let orgurl = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_PHOTO_BACKGROUND)!, data: orgbody) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        print("Upload done")
                        //背景に選択した画像を設定
                        //self.userImageView.image = profileImage
                        //ツールバー上のプロフィール画像をセット
                        //self.mainToolbarView.profileImageView.image = profileImage
                        //self.mainToolbarView.profileImageView.isHidden = false
                        
                        //背景フラグの更新
                        //(user_id:self.user_id, photo_flg:1, photo_name: file_name_temp)
                        //UtilFunc.modifyPhotoBackgroundFlg(user_id:self.user_id, photo_background_flg:1, photo_background_name: file_name_temp)
                        
                        var stringUrl = Util.URL_MODIFY_PHOTO_BACKGROUND_FLG
                        stringUrl.append("?user_id=")
                        stringUrl.append(String(self.user_id))
                        stringUrl.append("&photo_background_flg=1")
                        stringUrl.append("&photo_background_name=")
                        stringUrl.append(file_name_temp)
                        
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
                                dispatchGroup.leave()//サブタスク終了時に記述
                            })
                            task.resume()
                        }
                        // 全ての非同期処理完了後にメインスレッドで処理
                        dispatchGroup.notify(queue: .main) {
                            //画面更新
                            UserDefaults.standard.set(1, forKey: "myPhotoBackgroundFlg")
                            UserDefaults.standard.set(file_name_temp, forKey: "myPhotoBackgroundName")
                            
                            //くるくる表示終了
                            self.busyIndicator.removeFromSuperview()
                            
                            UtilToViewController.toMyprofileInfoViewController()
                        }
                    } else {
                        //self.mainToolbarView.profileImageView.isHidden = true
                        print(response.statusCode)
                    }
                }
            }
        }
        
        //画像のサイズ変更(リスト画像)
        //let listImage = Util.resizeImage(image :image, w:Int(Util.USER_LIST_PHOTO_WIDTH), h:Int(Util.USER_LIST_PHOTO_HEIGHT))
        //画像のサイズ変更(リスト画像)
        let listImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.BACKGROUND_USER_LIST_PHOTO_WIDTH), height:Double(Util.BACKGROUND_USER_LIST_PHOTO_HEIGHT))
        
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        if let listdata = listImage.pngData() {
            let listfileName = file_name_temp + "_list.jpg"
            //let listbody = Util.httpBody(listdata,fileName: listfileName)
            let listbody = UtilFunc.httpBodyAlpha(listdata,fileName: listfileName, castId: "0", userId: String(user_id))
            //let listurl = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_PHOTO_BACKGROUND)!, data: listbody) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        //print("Upload done")
                        //画面更新
                        UserDefaults.standard.set(1, forKey: "myPhotoBackgroundFlg")
                        UserDefaults.standard.set(file_name_temp, forKey: "myPhotoBackgroundName")
                        //photo_flgを更新する
                        //UtilFunc.modifyPhotoFlg(user_id:self.user_id, photo_flg:1, photo_name: file_name_temp)
                        //UserDefaults.standard.set(1, forKey: "myPhotoFlg")
                        //UserDefaults.standard.set(file_name_temp, forKey: "myPhotoName")
                        //dismissがそのあとにあるので、コメントアウトしないとここで落ちる
                        //UtilToViewController.toMypageViewController()
                        
                        //ボタンの背景に選択した画像を設定
                        //self.userImageView.image = profileImage
                        //ツールバー上のプロフィール画像をセット
                        //self.mainToolbarView.profileImageView.image = profileImage
                        //self.mainToolbarView.profileImageView.isHidden = false
                    } else {
                        //self.mainToolbarView.profileImageView.isHidden = true
                        //print(response.statusCode)
                    }
                }
            }
        }
        
        //dismiss(animated: true, completion: nil)
    }
    
    //UIImagePickerControllerのデリゲートメソッド
    //画像が選択された時に呼ばれる.
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        //if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            /*
             @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
             //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
             if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
             */
            //print("サーバーに転送")
            //サーバーに転送
            uploadImage = image
            
            self.baseView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)

            //let view_back_gray = UIView()// 追加するViewを生成
            //view_back_gray.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
            //self.mainView.fitParentView(selectedView:view_back_gray)
            
            //let view_back_gray = UIView()// 追加するViewを生成
            //view_back_gray.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
            
            //backgroundImageUpload(image: image, user_id: self.user_id)
            
            // UIImageView 初期化
            let imageView = UIImageView(image:image)
            
            // スクリーンの縦横サイズを取得
            let screenWidth:CGFloat = view.frame.size.width
            let screenHeight:CGFloat = view.frame.size.height
            
            // 画像の縦横サイズを取得
            let imgWidth:CGFloat = image.size.width
            let imgHeight:CGFloat = image.size.height
            
            // 画像サイズをスクリーン幅に合わせる
            let scale:CGFloat = screenWidth / imgWidth * 0.8
            let rect:CGRect =
                CGRect(x:0, y:0, width:imgWidth*scale, height:imgHeight*scale)
            
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView.frame = rect;
            
            // 画像の中心を画面の中心に設定
            imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
            
            self.baseView.addSubview(imageView)
            
            self.baseView.isHidden = false
            //backgroundImageUpload(image: image, user_id: self.user_id)
        } else{
            //print("Error")
        }
        // モーダルビューを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOkBtn(_ sender: Any) {
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        backgroundImageUpload(image: self.uploadImage, user_id: self.user_id)
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        //ダイアログを閉じる
        self.baseView.isHidden = true
    }
    
/*
    @objc func tapCancelBtn(_ sender: UIButton){
        //print("ボタンがタップされた")
        //self.viewLoad()
        UtilToViewController.toMypageViewController()
    }
    
    @objc func tapOkBtn(_ sender: UIButton){
        print("ボタンがタップされた")
        backgroundImageUpload(image: self.uploadImage, user_id: self.user_id)
    }
*/
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //キャンセルした時、アルバム画面を閉じます
        picker.dismiss(animated: true, completion: nil);
        //print("cancel")
        
        //self.viewLoad()
        UtilToViewController.toMypageViewController()
    }
}
