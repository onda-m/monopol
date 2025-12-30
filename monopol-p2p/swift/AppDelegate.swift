//
//  AppDelegate.swift
//  swift
//
//

import UIKit
import StoreKit
import SkyWaySupport
import Firebase
import Reachability
import UserNotifications
import FirebaseMessaging
import FirebaseDatabase
import CommonKeyboard
import LineSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,PurchaseManagerDelegate {
    //var navigationController: UINavigationController?
    
    //ストリーマー側ライブ配信の接続用
    //var peer: SKWPeer?
    var localStream: SKWMediaStream?
    //var peerFlg: Int = 0//待機状態になると一時的に1になる。1の場合はPEERオブジェクトは初期化される
    
    // notification center (singleton)
    //let center = UNUserNotificationCenter.current()
    
    var backgroundTaskID : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    //監視関連
    let center = NotificationCenter.default
    
    //下記はSashiLiveViewControllerなどで、ストリーマーをフォローした際に利用する
    //現在この仕組みを使用しているViewController
    //・SashiLiveViewController
    var viewCallFromViewControllerId:String = ""//UserInfoViewControllerの呼び出し元ViewController
    var viewReloadFlg:Int = 0//1:UserInfoViewControllerを閉じた時にリロードが必要
    var searchString:String = ""//検索文字列(フォローし戻ったときなどにこの検索文字列で画面をリロードするため)
    //ここまで
    
    //ストリーマーリストの動画再生用のフラグ（横移動時に動画再生していたプレイヤー番号を記録）
    var castMoviePlayerNumSubMenu00:Int = 0
    var castMoviePlayerNumSubMenu01:Int = 0
    var castMoviePlayerNumSubMenu02:Int = 0
    
    //一時保持用
    var sendSubMenu:String = "99"//99:初期値 0:フォロー1:注目2:最新(ストリーマー一覧のスワイプ画面)
    //一覧画面から動画再生画面への遷移時にどこのタブメニューから移動したかを保存
    var sendSubMenuFirst:String = "99"//99:初期値 0:フォロー1:注目2:最新(ストリーマー一覧のスワイプ画面)
    //var sendTopSubMenu:String?//0:フォロー1:注目2:最新(ストリーマー一覧のスワイプ画面)
    //var sendDetailSubMenu:String?//0:フォロー1:注目2:最新(ストリーマー一覧「縦」のスワイプ画面)
    var sendId:String?//値渡しするため（トーク・リスナー画面・ユーザー情報詳細画面で使用：選択した人のUSER_ID）
    var sendNoticeId:Int?//値渡しするため（いいねリスト画面で使用：選択したタイムラインの通知ID）
    //var liveCastId:String?//値渡しするため（ライブ配信専用：選択したCASTのユーザーID 自分自身待機中はゼロ）
    var sendUserName:String?//値渡しするため（選択した人のUSER_NAME）
    var sendPhotoFlg:String?//値渡しするため（選択した人のphoto_flg）
    var sendPhotoName:String?//値渡しするため（選択した人のphoto_name）
    //var waitWaku:Int?//値渡しするため（ストリーマー用の待機枠）
    var myCollectionType:String?//値渡しするため（マイコレクション用）1:マイコレクション 2:スクリーンショット 3:タイムライン 4:トーク
    var myCollectionSelectId:String?//値渡しするため（マイコレクション用）
    var myCollectionSelectCastId:String?//値渡しするため（マイコレクション用）
    var myCollectionSelectCastName:String?//値渡しするため（マイコレクション用）
    var myCollectionSelectInsTime:String?//値渡しするため（マイコレクション用）
    var myCollectionSelectPhotoFileName:String?//値渡しするため（マイコレクション用）
    
    //イベント作成用
    var createEventId: Int = 0//値渡しするため（作成されたID）
    // 選択肢(1枠のサシライブ時間)
    var eventOneFrameTimeCd: Int = 0
    var starPriceRangeCd: Int = 0//値渡しするため（価格）
    //var starPriceRangeStr:String?//確認画面用
    // 選択肢(価格)
    var eventPrice: Int = 0//値渡しするため（価格）
    // 選択肢(獲得スター)
    var eventStar: Int = 0//値渡しするため（価格）
    // 選択肢(1回目イベントの実施日)
    var event01YearCd: Int = 0
    var event01MonthCd: Int = 0
    var event01DayCd: Int = 0
    // 選択肢(2回目イベントの実施日)
    var event02YearCd: Int = 0
    var event02MonthCd: Int = 0
    var event02DayCd: Int = 0
    //1回目イベントの始めたい時間
    var eventStartTime01FirstFlg: Int = 0//初回のみ16:00をドラムのデフォルトとする
    var event01StartTimeCd: Int = 0//
    //var event01StartTimeCd: Int = 33//16:00
    //2回目イベントの始めたい時間
    var eventStartTime02FirstFlg: Int = 0//初回のみ16:00をドラムのデフォルトとする
    var event02StartTimeCd: Int = 0//
    //var event02StartTimeCd: Int = 33//16:00
    //1回目イベントの枠数
    var event01SumFrameCd: Int = 0
    //2回目イベントの枠数
    var event02SumFrameCd: Int = 0
    //1回目イベントのインターバル
    var event01IntervalCd: Int = 0
    //2回目イベントのインターバル
    var event02IntervalCd: Int = 0
    //1回目イベントの予約開始日
    var event01ReserveStartYearCd: Int = 0
    var event01ReserveStartMonthCd: Int = 0
    var event01ReserveStartDayCd: Int = 0
    var event01ReserveStartHourCd: Int = 0//0から23
    var event01ReserveStartMinuteCd: Int = 0
    //2回目イベントの予約開始日
    var event02ReserveStartYearCd: Int = 0
    var event02ReserveStartMonthCd: Int = 0
    var event02ReserveStartDayCd: Int = 0
    var event02ReserveStartHourCd: Int = 0//0から23
    var event02ReserveStartMinuteCd: Int = 0
    // 選択肢(イベント合計時間)
    //var eventSumTimeCd: Int = 0
    //イベント特典
    var eventNote: String!
    
    /*********************************/
    //ライブ配信に関する値について
    /*********************************/
    //
    //共通で使用

    //ひと枠の秒数
    var init_seconds: Int = Util.INIT_LIVE_SECONDS
    
    var count: Int = 0//ストリーマー側・リスナー側で使用する値(ライブ経過時間の秒数)
    //下記は重要
    //var ex_seconds = 0
    //予約が入った場合の残りの秒数（5分からスタートとなる）バッファは含まれない。
    //var reserve_wait_time: Int!

    /*予約関連(相手の情報)*/
    //var reserveUserId: String = "0"
    //var reservePeerId: String = "0"
    //var reserveUserName: String = ""
    //var reservePhotoFlg: String = "0"
    //var reservePhotoName: String = ""
    //var reserveFlg: String = "0"//予約可能かどうか（リスナー設定値）//0:予約可能 1:予約を許可しない
    //初期のリリースでは予約は許可しない（予約できない）
    var reserveFlg: String = "1"//予約可能かどうか（リスナー設定値）//0:予約可能 1:予約を許可しない
    var reserveMaxCount: String = "100"//予約可能な人数(デフォルト指定)
    //var reserveMaxCount: String = "0"//予約可能な人数(デフォルト指定)
    
    //0:会員登録中 1:待機中 2:通話中 3:ログオフ状態 4:通話中(予約申請) 5:通話中(予約済) 6:予約キャンセル 7:ストリーマーによる予約拒否 98:削除 99:リストア済み
    var reserveStatus: String = ""
    
    //ブラックリストの配列
    var array_black_list: [Int] = [] //ユーザーIDしか格納しない
    
    //
    //ストリーマー側のみで使用
    //
    //ライブ配信中のユーザーの名前（相手の名前とID）
    var live_target_user_name: String!
    var live_target_user_id: Int!
    var live_password: String!
    var live_password_flg: Int!//1:パスワード必要
    //var live_reserve_flg: Int!//0:予約可能 1:予約を許可しない
    //ライブ中のエフェクト用
    var live_effect_id: Int = 0//ライブ配信で設定したエフェクトID
    var live_effect_id_before: Int = 0//ライブ配信で設定したエフェクトID(直前の比較用)
    //var live_reserve_count: Int = 0//現在の予約数(全てのダイアログなどで使用したいため。エフェクト監視にて同期をとる)
    //下記は一番最初のライブ配信時、左上に予約ラベルが表示されてしまうのを防ぐため
    //var live_first_flg: Int = 0
    // 0:ライブ開始時(１人目の開始直前) 1:はじめの3秒ごと処理が終わっている場合
    
    //予約しているユーザーの情報(できれば上を使いたい)
    //var ext_flg: Int = 0//0:予約なし 1:予約あり
//    var ext_count_max_flg = 0//1:これ以上は延長できない
    //var ext_user_id: Int = 0
    //var ext_user_name: String = ""
    //var ext_photo_flg: Int = 0
    //var ext_photo_name: String = ""
    //ext_count 延長した回数。１分を何回延長したか。
//    var ext_count: Int = 0

    //予約関連の処理で使用
//    var reserveUserIdTemp: String = ""//予約リクエストが来たときに前後のデータを保持するため
//    var reserveStatusTemp: String = ""//予約リクエストが来たときに前後のデータを保持するため
    
    //
    //リスナー側で使用
    //
    //待ち人数・待ち時間
    //UserDefaults.standard.set(int, forKey: "reserve_wait_id")この値がゼロの時は予約はまだしていない
    //UserDefaults.standard.set(int, forKey: "reserve_count")
    //UserDefaults.standard.set(int, forKey: "reserve_sec")
    //ストリーマーへのリクエスト時・ユーザー側ライブ配信中もこの値を使用
    var request_cast_id:Int = 0
    var request_notify_flg:Int?
    var request_max_reserve_count:Int = 0//Maxの予約数
    var request_cast_uuid:String?
    var request_cast_name:String?
    var request_cast_rank:String?
    var request_password:String = ""
    //var request_reserve_user_id:Int = 0
    //var request_frame_count:Int?//枠数
    //var request_count_num:Int?//タップ数に使用していたが、現在は、0:ダイアログを表示直後　99：リスナー側の接続中の状態
    //var request_cast_login_status:Int?
    var request_live_user_id:Int = 0//現在ライブ中のユーザーID
    
    //自らが配信終了ボタン（バツボタン）を押したかどうか（復帰時の判断に使用）
    //0:バツボタンは押されていない。1：押された
    var listener_live_close_btn_tap_flg:Int = 0
    
    //リスナー側で保存する値(cast_live_point_rirekiの保存で必要)
    //ストリーマーが得られる配信ポイント(最初の1分枠で得られるポイント)(スター)
    var get_live_point: Int = 0
    //延長時ストリーマーが得られる配信ポイント(スター)
    var ex_get_live_point: Int = 0
    //1回、視聴するのに消費するコイン
    var live_pay_coin: Double = 0.0
    //1回、延長するのに消費するコイン
    var live_pay_ex_coin: Double = 0.0
    //予約するのに必要なコイン
    var min_reserve_coin: Int = 0
    //予約をキャンセルする時に払うコイン
    //var cancel_coin: Int = 0
    //予約をキャンセルされた場合に追加されるスター
    //var cancel_get_star: Int = 0
    
    //延長できるMAXの秒数（リスナー側のみ保持）
    //var reserve_max_second:Int = 0
    //延長時に使用できる全コイン数（ライブ中にプレゼントを送ったりすると、ここが減る）（リスナー側のみ保持）
    //var reserve_max_coin: Int!(復帰時にも使用できるので下記を使用する。DBに保存するタイミングを注意。配信が終わったタイミングでDBに保存する)
    //var myPoint:Double = UserDefaults.standard.integer(forKey: "myPoint")
    //myPoint = myPoint - point
    //UserDefaults.standard.set(myPoint, forKey: "myPoint")
    
    //リスナー側で保存する値（ここまで）
    /*********************************/
    //ライブ配信に関する値について(ここまで)
    /*********************************/

    // UserDefaultsを使ってデータを保持する(メモ)
    //タイムラインを初回見たかのフラグ
    //UserDefaults.standard.set(0, forKey: "timelineFirstFlg")
    
    //リスナーの復帰用
    //落ちた時にライブ配信中だったストリーマーIDを保存する(リスナー側で使用)
    //ライブ配信が始まった時にストリーマーIDとストリーマー名を保存しておく必要がある
    //UserDefaults.standard.set(int, forKey: "live_cast_id")
    //UserDefaults.standard.set(String, forKey: "live_cast_name")
    //配信ランクに関する必要なコイン、得られる配信ポイントを保存しておく（リスナー側）
    //UserDefaults.standard.set(int, forKey: "get_live_point")
    //UserDefaults.standard.set(int, forKey: "ex_get_live_point")
    //UserDefaults.standard.set(int, forKey: "live_pay_coin")
    //UserDefaults.standard.set(double, forKey: "live_pay_ex_coin")
    //
    //配信ランクに関する必要なコイン、得られる配信ポイントを保存しておく（ストリーマー側）
    //UserDefaults.standard.set(int, forKey: "get_live_point")
    //UserDefaults.standard.set(int, forKey: "ex_get_live_point")
    //UserDefaults.standard.set(int, forKey: "coin")
    //UserDefaults.standard.set(double, forKey: "ex_coin")
    //UserDefaults.standard.set(int, forKey: "min_reserve_coin")
    //UserDefaults.standard.set(int, forKey: "cancel_coin")
    //UserDefaults.standard.set(int, forKey: "cancel_get_star")
    
    //ストリーマーが得られるポイント(最初の5分枠で得られるポイント)
    //self.appDelegate.get_live_point = self.get_live_point
    //消費するコイン
    //self.appDelegate.live_pay_coin = self.live_coin
    //消費するコイン(延長時)
    //self.appDelegate.live_pay_ex_coin = self.live_ex_coin
    //リスナーの復帰用(ここまで)
    
    //userinfoで使用
    var sendIdByListenerList:String?//値渡しするため（「リスナーを見る」にて選択中のCAST_ID）
    var sendNameByListenerList:String?//値渡しするため（「リスナーを見る」にて選択中のCAST_NAME）
    //userinfoで使用
    var sendIdByPairRanking:String?//値渡しするため（「ペアランキングを見る」にて選択中のCAST_ID）
    var sendNameByPairRanking:String?//値渡しするため（「ペアランキングを見る」にて選択中のCAST_NAME）
    //キャプチャ用
    var pickedImage: UIImage? = nil //取得した写真を保持
    var pickedImageUrl: String?
    
    //毎日のプレゼント用にアプリアクセス日を保持
    //UserDefaults.standard.set(int, forKey: "today_year")
    //UserDefaults.standard.set(int, forKey: "today_month")
    //UserDefaults.standard.set(int, forKey: "today_day")
    // Keyを指定して保存
    //ストリーマー一覧画面にて
    //押した回数「2」になっている場合は申請中の状態
    //UserDefaults.standard.set(int, forKey: "selectedIndexCount")
    //UserDefaults.standard.set(phonedeviceId, forKey: "uuid")
    //UserDefaults.standard.set(strFcmToken, forKey: "fcm_token")
    //UserDefaults.standard.set(json.id_temp, forKey: "user_id")
    //UserDefaults.standard.set(0, forKey: "follow_num")
    //UserDefaults.standard.set(0, forKey: "follower_num")

    // 名前、初期ポイントを保存
    //UserDefaults.standard.set(strName, forKey: "myName")
    //UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
    //UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
    //UserDefaults.standard.set(strMycollectionMax, forKey: "myCollection_max")
    //UserDefaults.standard.set(Util.INIT_POINT, forKey: "myPoint")
    //UserDefaults.standard.set(Util.INIT_POINT, forKey: "myLivePoint")
    //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
    //UserDefaults.standard.set(1, forKey: "cast_rank")
    
    //UserDefaults.standard.set(, forKey: "liveFrameRequestFlg")
    //1枠の分（1枠5分と設定）
    //UserDefaults.standard.set(, forKey: "liveInitMinutes")
    //UserDefaults.standard.set(, forKey: "liveInitSeconds")

    //配信時(ストリーマー側)
    //ユーザー情報のダイアログのY座標と高さを保存しておく。
    //UserDefaults.standard.set(int, forKey: "userInfoDialogY")
    //UserDefaults.standard.set(int, forKey: "userInfoDialogHeight")
    
    //配信時(ユーザー側)
    //ストリーマー情報のダイアログのY座標と高さを保存しておく。
    //UserDefaults.standard.set(int, forKey: "castInfoDialogY")
    //UserDefaults.standard.set(int, forKey: "castInfoDialogHeight")
    
    //相手との情報(ライブ中もトークでも共通)
    //UserDefaults.standard.set(String, forKey: "sendConnectLevel")//値渡しするため（選択した人との絆レベル）
    //UserDefaults.standard.set(String, forKey: "sendConnectBonusRate")//値渡しするため（選択した人との課金ポイントのボーナス率）値を呼び出すときは、DOUBLE型となるのに注意
    
    //トークの未読数
    //UserDefaults.standard.set(, forKey: "talkNoreadCount")
    
    //リクエスト履歴の未読数
    //UserDefaults.standard.set(, forKey: "requestRirekiNoreadCount")
    
    //safeareaの調整値を保存
    //UserDefaults.standard.set(CGFloat, forKey: "topSafeAreaHeight")
    //UserDefaults.standard.set(CGFloat, forKey: "bottomSafeAreaHeight")
    
    //取得の方法
    //uuid = UserDefaults.standard.string(forKey: "uuid")
    
    //ユーザーID
    struct ResultJson: Codable {
        let id_temp: Int
        //let result: [UserResult]
    }
    var user_id: Int = 0

    /*
    override init() {
        super.init()
        FirebaseApp.configure()
    }*/
    
    /*********************************/
    //バックグラウンドでも処理を続けるための記述
    //待機状態またはライブ配信中はバックグラウンドでも処理を続ける必要がある
    //https://qiita.com/SatoTakeshiX/items/8e1489560444a63c21e7
    /*********************************/
    /*
    //バックグラウンド遷移移行直前に呼ばれる
    func applicationWillResignActive(application: UIApplication) {
        
        self.backgroundTaskID = application.beginBackgroundTask(){
            [weak self] in
            application.endBackgroundTask((self?.backgroundTaskID)!)
            self?.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    //アプリがアクティブになる度に呼ばれる
    func applicationDidBecomeActive(application: UIApplication) {
        
        application.endBackgroundTask(self.backgroundTaskID)
    }
     */
    /*********************************/
    //バックグラウンドでも処理を続けるための記述(ここまで)
    /*********************************/

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //Line login用
        return LoginManager.shared.application(app, open: url)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //Line login用
        LoginManager.shared.setup(channelID: Util.LINE_CHANNEL_ID, universalLinkURL: nil)
        
        //google Firebase用
        FirebaseApp.configure()

        //キーボード関連
        CommonKeyboard.shared.enabled = true
        
        //アプリ起動中、勝手にスリープしないようにする
        UIApplication.shared.isIdleTimerDisabled = true
        
        //インターネットに接続されているかの確認
        do {
            //オンライン・オフラインの判断用
            let reachability = try! Reachability()
            
            reachability.whenUnreachable = { reachability in
                //オフラインになった時に実行される
                //print(reachability.connection)
                UtilToViewController.toNetworkErrorViewController()
            }
            try! reachability.startNotifier()
        }
        
        //アイコン右上の数字
        application.applicationIconBadgeNumber = 0
        
        //ストリーマー側のコネクションのフラグを初期化
        //self.peerFlg = 0
        
        //前準備(リモート通知に登録する)
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        //Messaging.messaging().subscribe(toTopic: "/topics/test")
        // [END register_for_notifications]
        
        //---------------------------------------
        // アプリ内課金設定
        //---------------------------------------
        // デリゲート設定
        PurchaseManager.sharedManager().delegate = self
        // オブザーバー登録
        SKPaymentQueue.default().add(PurchaseManager.sharedManager())

        UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
        self.sendSubMenu = "1"
        
        //アプリ起動時に、ユーザー情報を取得して、UserDefaultに設定
        UtilFunc.setMyInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.startDo()
        }
        
        return true
    }
    
    func startDo(){
        //→ユーザー情報がDBにあるかも見ること(修正必要)
        if UserDefaults.standard.integer(forKey: "login_status") != 0
            && UserDefaults.standard.integer(forKey: "login_status") != 97
            && UserDefaults.standard.integer(forKey: "login_status") != 98
            && UserDefaults.standard.integer(forKey: "login_status") != 99
            && UserDefaults.standard.integer(forKey: "user_id") > 0 {
            //print("UUIDがある場合、呼ばれるアプリ起動時の処理だよ")
            //self.window = UIWindow(frame: UIScreen.main.bounds)
            //self.window?.rootViewController = HomeViewController()//遷移先を指定
            //self.window?.makeKeyAndVisible()
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            
            //ipや機種情報などを保存
            UtilFunc.logIpRirekiDo(type: 1, user_id: user_id)

            //ユーザー用のストーリーボードへ
            self.getLiveRequestNoreadCount(type:1, user_id:user_id)
            //UtilToViewController.toMainViewController()
        }else{
            //引き継ぎIDの払い出し
            //UUIDを取得
            let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
            //let phonedeviceId = UUID().uuidString
            
            var stringUrl = Util.URL_SAVE
            stringUrl.append("?uid=")
            stringUrl.append(String(phonedeviceId))
            stringUrl.append("&point=")
            stringUrl.append(String(Util.INIT_POINT))
            stringUrl.append("&mycollection=")
            stringUrl.append(String(Util.MYCOLLECTION_MAX))
            //print(stringUrl)
            
            // Swift4からは書き方が変わりました。
            let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            //let decodedString:String = text.removingPercentEncoding!
            let req = URLRequest(url: url)
            
            //非同期処理を行う
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
            var json :ResultJson? = nil
            
            dispatchGroup.enter()
            dispatchQueue.async {
                let task = URLSession.shared.dataTask(with: req, completionHandler: {
                    (data, res, err) in
                    do{
                        //JSONDecoderのインスタンス取得
                        let decoder = JSONDecoder()
                        //受けとったJSONデータをパースして格納
                        json = try decoder.decode(ResultJson.self, from: data!)
                        //print(json.result)
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
                //作成されたIDを保存する
                UserDefaults.standard.set(json?.id_temp, forKey: "user_id")
                
                //ipや機種情報などを保存
                UtilFunc.logIpRirekiDo(type: 1, user_id: json!.id_temp)
                //windowを生成
                self.window = UIWindow(frame: UIScreen.main.bounds)
                //Storyboardを指定
                let storyboard = UIStoryboard(name: "SubMain", bundle: nil)
                //Viewcontrollerを指定
                let initialViewController = storyboard.instantiateInitialViewController()
                //rootViewControllerに入れる
                self.window?.rootViewController = initialViewController
                //表示
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    //下記はUtilFunc内と同じ関数
    //リクエスト未読数取得 > ユーザー用のストーリーボードへ（トップページへ）
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
            //ユーザー用のストーリーボードへ（トップページへ）
            UtilToViewController.toMainViewController()
        }
    }
    
    // 課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("#### didFinishUntreatedPurchaseWithTransaction ####")
        // TODO: コンテンツ解放処理
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //println("アプリ閉じそうな時に呼ばれる")
/*
        //UUIDを取得
        let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
        let stringUrl = Util.URL_MOD_STATUS+"?uid="+String(phonedeviceId)+"&status=0";
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
*/
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //println("アプリを閉じた時に呼ばれる")
        //UtilLog.printf(str:"アプリを閉じた時に呼ばれる")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //println("アプリを開きそうな時に呼ばれる")
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //println("アプリを開いた時に呼ばれる")
        
        //アイコン右上の数字
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //println("アプリを終了させた時に呼ばれる")
        print("アプリを終了させた時に呼ばれる")
        //UtilLog.printf(str:"アプリを終了させた時に呼ばれる")
        //ログオフ状態に変更
        //3:ストリーマー-ログオフ状態
        UtilFunc.loginDo(user_id:UserDefaults.standard.integer(forKey: "user_id"), status:3, live_user_id:0, reserve_flg:Int(self.reserveFlg)!, max_reserve_count:Int(self.reserveMaxCount)!, password:"0")

        //7:アプリ終了時
        //1:待機スタート 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）
        UtilFunc.addActionRireki(user_id: UserDefaults.standard.integer(forKey: "user_id"), listener_id: 0, type: 7, value01:0, value02:0)

        /*
        //現在の状態
        //0登録中 1待機中 2通話中 3ログオフ 4通話中(予約申請) 5通話中(予約済) 6通話中(予約キャンセル) 7:ストリーマーによる予約拒否 8:予約あり＋切り替え時 10:強制非表示 97凍結 98削除 99リストア済み
        let loginStatus:Int = UserDefaults.standard.integer(forKey: "login_status")
        if(loginStatus == 1 || loginStatus == 2
            || loginStatus == 4 || loginStatus == 5
            || loginStatus == 6 || loginStatus == 7 || loginStatus == 8){
            //7:アプリ終了時の待機解除
            //1:待機スタート 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）
            UtilFunc.addActionRireki(user_id: UserDefaults.standard.integer(forKey: "user_id"), listener_id: 0, type: 7, value01:0, value02:0)
            
            print("----")
            print(loginStatus)
        }
         */

        // オブザーバー登録解除
        SKPaymentQueue.default().remove(PurchaseManager.sharedManager());
    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print(userInfo)
        
        /*
        print("Push通知から起動")
        
        switch application.applicationState {
        case .inactive:
            // アプリがバックグラウンドにいる状態で、Push通知から起動したとき
            Util.toTalkTopViewController()
            break
            
        case .active:
            // アプリ起動時にPush通知を受信したとき
            break
            
        case .background:
            // アプリがバックグラウンドにいる状態でPush通知を受信したとき
            break

        }
        */
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    // 通知を受け取った時に(開く前に)呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    // 通知を開いた時に呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //print(userInfo)

        completionHandler()
        
        //アイコン右上の数字
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //通知を開いた時に呼ばれる
        //Util.toTalkTopViewController()
        //何もしないと、ただアプリの状態をフォアグラウンドにする。
        //＞なので、何もしない
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //print("Firebase registration token: \(fcmToken)")
        
        //ここは起動時に通る（初回も）
        //アプリ内変数でトークンを保持する
        //値が変更されていたら毎回どこかで更新する必要がある＞BaseViewかな
        UserDefaults.standard.set(fcmToken, forKey: "fcm_token")//入らない場合があるため、fcm_token_tempも用意
        UserDefaults.standard.set(fcmToken, forKey: "fcm_token_temp")
        //let fcm_token = UserDefaults.standard.string(forKey: "fcm_token")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        //DBにFCM_TOKENを保存する
        let user_id_temp = UserDefaults.standard.integer(forKey: "user_id")
        UtilFunc.modifyFcmToken(user_id:user_id_temp, token:fcmToken!)
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    //func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        //print("Received data message: \(remoteMessage.appData)")
    //}
    // [END ios_10_data_message]

}

public extension URL {
    func queryParams() -> [String : String] {
        var params = [String : String]()
        
        guard let comps = URLComponents(string: self.absoluteString) else {
            return params
        }
        guard let queryItems = comps.queryItems else { return params }
        
        for queryItem in queryItems {
            params[queryItem.name] = queryItem.value
        }
        return params
    }
}
