//
//  Uitl.swift
//  swift_skyway
//
//

import Foundation
import UIKit

//TIPS
//配信関連
//userrequest/cast_id/user_id
//userrequest_test/cast_id/user_id
//スクショリクエスト
//$$$_screenshot_request を文字として送る

//FireBase監視関連
//予約リクエスト時の監視(1ファイル)
//CastSelectedDialog
//ストリーマー側ライブ時の監視(2ファイル)
//CastWaitDialog
//WaitViewController
//479行目あたり
//ユーザー側ライブ時の監視
//MediaConnectionViewController
//346行目あたり

//注意
//firebaseのデータには、何かの値を残すこと
//現状は「userrequest/temp = 0」を残すこととしている（削除してはいけない）

//課金処理のあるページ
//PurchaseViewController.swift
//UserPurchasePlanDialog.swift

//コインの消費処理 ＞ 履歴保存、ユーザー情報DBの更新、アプリ内保持の値を更新、商品の購入処理。
//PresentShopViewControllerを参照すること

//リアルタイム通知
//FireBase・端末ごとのfcmトークンを使用する

//画像の場所
//タイムライン関連
//notice/user_id/notice_rireki_id.jpg
//トーク関連
//talk/user_id/target_user_id/talk_rireki_id.jpg
//ユーザーの画像
//user_images/user_id.jpg
//マイコレクション関連
//mycollection/?/?/mycollection_rireki_id.jpg
//スクリーンショット関連
//screenshot/cast_id/screenshot_rireki_id.jpg

//問題点
//スクショの管理画面よりスクショの個別画面と削除機能が必要？
//振込依頼ボタンを押した場合、そこまでのスター分を固定で振り込むようにする
//MovieSettingViewController ローカルに動画ファイルが残ってしまう。（削除したい）
//コレクションビューのループができない

class Util {
    /***********************************************************/
    //アプリ内で保持する値メモ
    /***********************************************************/
    //規約同意チェックフラグ：１＝チェック済
    //let rule_check_flg = UserDefaults.standard.integer(forKey: "rule_check_flg")
    
    /***********************************************************/
    //URL共通部分(本番用)
    /***********************************************************/
    /*
    static let APPLEID = "1391460315"//アプリのアップルID
    static let INIT_FIREBASE = "userrequest"//Firebaseで使用
    static let INIT_MODE: Int = 2//1:課金テスト用 2:課金本番用
    static let FILE_MODE: Int = 0//1:ファイル出力 2:コンソール 0:出力しない
    static let URL_BASE = "https://jbh36p8c.user.webaccel.jp/"
    static let DOMAIN_BASE = "jbh36p8c.user.webaccel.jp"
    static let URL_USER_PHOTO_BASE = "https://jbh36p8c.user.webaccel.jp/"//画像URLの共通部分(ストリーミング)
    static let URL_USER_MOVIE_BASE = "https://jbh36p8c.user.webaccel.jp/cast_movies/"//動画URLの共通部分(ストリーミング)
    // https://webrtc.ecl.ntt.com/からAPIKeyとDomainを取得してください
    static let skywayAPIKey: String = "892b648f-98c5-4b9a-b02f-79133280483d"
    static let skywayDomain: String = "localhost"
    //firebaseのサーバーキー
    //サーバーキーは Firebase コンソールから、
    //「プロジェクトの設定」（歯車のアイコンをクリック）-> 「クラウドメッセージング」から確認できます。
    static let serverKey: String = "AAAAQunvYIo:APA91bER4pyI3pGh9iTMeCzmWelV-wdP9dKPM49Fv0QZO5KXu3nV-yzWHRhpzedPSCd0FFyORuCpS15aa1bPDV0iCRyH5wE2mJIDBoPxp8nv0vioRvQtEd-TP17drCR2dU_6jtLRI0yD"
    //問い合わせのWebViewのURL
    static let CONTACTUS_URL = "https://monopol.jp/usr_contact_webview.html"
    //規約のWebViewのURL
    static let RULE_URL = "https://monopol.jp/terms_of_service_webview.html"
    //レート関連のWebView
    //GET:user_id
    static let SETTING_WEBVIEW_URL = "https://monopol.jp/usr_stream_rate_webview.html"
    //背景画像アップ用のWebView(未使用)
    static let IMG_UPLOAD_WEBVIEW_URL = "https://monopol.jp/img_upload_webview.html"
    //マイイベント確認のWebView
    //GET:user_id
    static let MYEVENT_CHECK_WEBVIEW_URL = "https://monopol.jp/myevent_check_webview.html"
     
    //イベント告知ページ
    static let URL_EVENT_URL = "https://event.monopol.jp/?id="
    //イベント申込ページ
    static let URL_EVENT_APPLY_URL = "https://event.monopol.jp/apply.html?id="
     
    //1枠の分（1枠1分と設定しておく）
    static let INIT_LIVE_MINUTES: Int = 1
    static let INIT_LIVE_SECONDS: Int = 60
    static let INIT_EX_UNIT_SECONDS: Int = 60//延長時の１枠の単位(60秒ごとに課金が発生するという意味)
     
    //1時間の無料ライブをすることにより配信ポイント3000ポイントを取得という意味
    static let FREE_LIVE_POINT_MAX: Int = 3000//有料サシライブまでの配信ポイント(MAX値)
    static let FREE_LIVE_POINT_BY_MINUTE: Int = 50//1分あたりの配信ポイント(延長でも同じ)
    //リクエスト申請時のタイムアウト秒数
    static let REQUEST_TIMEOUT_SEC: Int = 65
    //LineログインのチャネルID
    static let LINE_CHANNEL_ID = "1656988739"

*/
    /***********************************************************/
    //URL共通部分(検証用)
    /***********************************************************/

    static let APPLEID = "1391460315"//アプリのアップルID
    static let INIT_FIREBASE = "userrequest_test"//Firebaseで使用
    static let INIT_MODE: Int = 1//1:課金テスト用 2:課金本番用
    static let FILE_MODE: Int = 1//1:ファイル出力 2:コンソール 0:出力しない
    static let URL_BASE = "https://ancuvcdg.user.webaccel.jp/"
    static let DOMAIN_BASE = "ancuvcdg.user.webaccel.jp"
    static let URL_USER_PHOTO_BASE = "https://ancuvcdg.user.webaccel.jp/"//画像URLの共通部分(ストリーミング)
    static let URL_USER_MOVIE_BASE = "https://ancuvcdg.user.webaccel.jp/cast_movies/"//動画URLの共通部分(ストリーミング)
    // https://webrtc.ecl.ntt.com/からAPIKeyとDomainを取得してください
    static let skywayAPIKey: String = "d53e1b48-2ef6-4649-93e4-3a69c66b6e28"
    static let skywayDomain: String = "localhost"
    // SkyWay Room SDK 固定トークン（開発用）
    static let skywayRoomToken: String = "<fixed_token>"
    //firebaseのサーバーキー
    //サーバーキーは Firebase コンソールから、
    //「プロジェクトの設定」（歯車のアイコンをクリック）-> 「クラウドメッセージング」から確認できます。
    static let serverKey: String = "AAAAQunvYIo:APA91bER4pyI3pGh9iTMeCzmWelV-wdP9dKPM49Fv0QZO5KXu3nV-yzWHRhpzedPSCd0FFyORuCpS15aa1bPDV0iCRyH5wE2mJIDBoPxp8nv0vioRvQtEd-TP17drCR2dU_6jtLRI0yD"
    //問い合わせのWebViewのURL
    static let CONTACTUS_URL = "https://test.monopol.jp/usr_contact_webview.html"
    //規約のWebViewのURL
    static let RULE_URL = "https://test.monopol.jp/terms_of_service_webview.html"
    //レート関連のWebView
    //GET:user_id
    static let SETTING_WEBVIEW_URL = "https://test.monopol.jp/usr_stream_rate_webview.html"
    //背景画像アップ用のWebView(未使用)
    static let IMG_UPLOAD_WEBVIEW_URL = "https://test.monopol.jp/img_upload_webview.html"
    //マイイベント確認のWebView
    //GET:user_id
    static let MYEVENT_CHECK_WEBVIEW_URL = "https://test.monopol.jp/myevent_check_webview.html"
    
    //イベント告知ページ
    static let URL_EVENT_URL = "https://eventtest.monopol.jp/?id="
    //イベント申込ページ
    static let URL_EVENT_APPLY_URL = "https://eventtest.monopol.jp/apply.html?id="
    
    //1枠の分（1枠1分と設定しておく）
    //static let INIT_LIVE_MINUTES: Int = 2
    //static let INIT_LIVE_SECONDS: Int = 120
    static let INIT_LIVE_MINUTES: Int = 1
    static let INIT_LIVE_SECONDS: Int = 60
    static let INIT_EX_UNIT_SECONDS: Int = 60//延長時の１枠の単位(60秒ごとに課金が発生するという意味)
    
    //1時間の無料ライブをすることにより配信ポイント3000ポイントを取得という意味
    static let FREE_LIVE_POINT_MAX: Int = 3000//有料サシライブまでの配信ポイント(MAX値)
    static let FREE_LIVE_POINT_BY_MINUTE: Int = 50//1分あたりの配信ポイント(延長でも同じ)
    //リクエスト申請時のタイムアウト秒数
    static let REQUEST_TIMEOUT_SEC: Int = 65
    //LineログインのチャネルID
    static let LINE_CHANNEL_ID = "1656967155"

    /***********************************************************/
    //(ここまで)
    /***********************************************************/
    
    //相手との絆レベル取得用
    struct ConnectResult: Codable {
        let level: String//
        let bonus_rate: String//
    }
    struct ResultConnectJson: Codable {
        let count: Int
        let result: [ConnectResult]
    }
    
    //ダイアログの宣言(コイン購入のダイアログ)
    static var userPurchasePlanDialog = UserPurchasePlanDialog()
    
    /*************************************/
    //ストリーマーリスト画面関連
    /*************************************/
    //Tiktok画面のimageViewの縦横比を取得し、1137*643より縦長の場合は、画面フルに表示する
    //let aspect_hi_base:CGFloat = 1137 / 643 = 1.77
    static let ASPECT_HI_BASE:CGFloat = 1.49
    //static let ASPECT_HI_BASE:CGFloat = 0.8

    //名前の左横に、待機中、オンライブ、オフラインを●で表示
    //待機中：#5abfa7(rgb(90, 191, 167))
    //オンライブ：#edad0b(rgb(237, 173, 11))
    //オフライン：#8e8e8e(rgb(142, 142, 142))
    static let CAST_STATUS_COLOR_WAIT: UIColor = UIColor(red: 90/255, green: 191/255, blue: 167/255, alpha: 1)
    static let CAST_STATUS_COLOR_ONLIVE: UIColor = UIColor(red: 237/255, green: 173/255, blue: 11/255, alpha: 1)
    static let CAST_STATUS_COLOR_OFF: UIColor = UIColor(red: 142/255, green: 142/255, blue: 142/255, alpha: 1)
    //下記の２つは使用しないようにしたい
    static let ON_LIVE_LABEL_COLOR: UIColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
    static let WELCOME_LABEL_COLOR: UIColor = UIColor(red: 0/255, green: 153/255, blue: 0/255, alpha: 1)
    //名前のちょっと上にあるランキング数値がある部分の背景色：#c7243a(rgb(199, 36, 58))
    static let CAST_LIST_RANKING_POINT_BG: UIColor = UIColor(red: 199/255, green: 36/255, blue: 58/255, alpha: 1)
    //予約可の背景：#edad0b(rgb(237, 173, 11))
    static let CAST_LIST_RESERVE_BG: UIColor = UIColor(red: 237/255, green: 173/255, blue: 11/255, alpha: 1)
    //ストリーマー選択画面のグラデ
    //static let CAST_SELECT_GRAD_START: UIColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 0.1)
    //static let CAST_SELECT_GRAD_END: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
    static let CAST_SELECT_GRAD_START: UIColor = UIColor(white: 0, alpha: 0.8)
    static let CAST_SELECT_GRAD_END: UIColor = UIColor(white: 0, alpha: 0)
    static let CAST_SELECT_GRAD_DOWN_START: UIColor = UIColor(white: 0, alpha: 0.0)
    static let CAST_SELECT_GRAD_DOWN_END: UIColor = UIColor(white: 0, alpha: 0.2)
    //static let CAST_SELECT_GRAD_DOWN_END: UIColor = UIColor(red: 92/255, green: 149/255, blue: 251/255, alpha: 1)
    /*************************************/
    //配信準備画面関連
    /*************************************/
    //サシライブ配信待機！の文字色 #5c95fb(rgb(92, 149, 251))
    static let LIVE_WAIT_STRING_COLOR: UIColor = UIColor(red: 92/255, green: 149/255, blue: 251/255, alpha: 1)
    //aboutViewの背景色 #62bfad(rgb(98, 191, 173))
    static let LIVE_WAIT_ABOUT_VIEW_BG_COLOR: UIColor = UIColor(red: 98/255, green: 191/255, blue: 173/255, alpha: 1)
    //aboutViewのタイトル文字色 #62bfad(rgb(98, 191, 173))
    static let LIVE_WAIT_ABOUT_TITLE_COLOR: UIColor = UIColor(red: 98/255, green: 191/255, blue: 173/255, alpha: 1)
    //通常のラベルの背景色 #5c95fb(rgb(92, 149, 251))
    static let LIVE_WAIT_LABEL_BG_COLOR: UIColor = UIColor(red: 92/255, green: 149/255, blue: 251/255, alpha: 1)
    //パスワードオンの時の背景色 #e54b4b(rgb(229, 75, 75))
    static let LIVE_WAIT_ON_BG_COLOR: UIColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)
    
    //イベント作成時の未選択ボタン背景色 #f2f2f2(rgb(242, 242, 242))
    static let EVENT_CREATE_BTN_BG_COLOR: UIColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    //イベント作成時の次へボタン背景色 #7dccfc(rgb(125, 204, 252))
    static let EVENT_CREATE_NEXT_BTN_BG_COLOR: UIColor = UIColor(red: 125/255, green: 204/255, blue: 252/255, alpha: 1)
    
    /*************************************/
    //コイン購入画面関連
    /*************************************/
    //コインのプラン説明の文字色 #e54b4b(rgb(229, 75, 75))
    //未使用かも
    static let COIN_NOTES_STRING_COLOR: UIColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)
    //コインの値段のところの背景色 #ffb700(rgb(255, 183, 0))
    static let COIN_YEN_BG_COLOR: UIColor = UIColor(red: 255/255, green: 183/255, blue: 0/255, alpha: 1)
    //コイン購入VIEWの枠線の色 #979797(rgb(151, 151, 151))
    static let COIN_VIEW_FRAME_COLOR: UIColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
    /*************************************/
    //プレゼントショップ画面関連
    /*************************************/
    //必要コインの背景色 #5c95fb(rgb(92, 149, 251))
    static let SHOP_COIN_BG_COLOR: UIColor = UIColor(red: 92/255, green: 149/255, blue: 251/255, alpha: 1)
    //所持数の背景色 #32b67a(rgb(50, 182, 122))
    static let SHOP_HAVE_BG_COLOR: UIColor = UIColor(red: 50/255, green: 182/255, blue: 122/255, alpha: 1)
    /*************************************/
    //トーク詳細画面関連
    /*************************************/
    //自分の発言の背景色 #659fee(rgb(101, 159, 238))
    static let TALK_MY_BG_COLOR: UIColor = UIColor(red: 101/255, green: 159/255, blue: 238/255, alpha: 1)
    //相手の発言の背景色 #e8ebef(rgb(232, 235, 239))
    static let TALK_YOUR_BG_COLOR: UIColor = UIColor(red: 232/255, green: 235/255, blue: 239/255, alpha: 1)
    /*************************************/
    //ランキング画面関連
    /*************************************/
    //サシライブランキングの1位の枠の色 #f47a90(rgb(244, 122, 144))
    static let SASHI_RANKING_FRAME_COLOR_01: UIColor = UIColor(red: 244/255, green: 122/255, blue: 144/255, alpha: 1)
    //サシライブランキングのランキング部分の文字色 #7b7b7b(rgb(123, 123, 123))
    static let SASHI_RANKING_LABEL_COLOR: UIColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1)
    //サシライブランキングの1位の文字色 #f47a90(rgb(244, 122, 144))
    static let SASHI_RANKING_STR_COLOR_01: UIColor = UIColor(red: 244/255, green: 122/255, blue: 144/255, alpha: 1)
    //サシライブランキングの2位の文字色 #61bfad(rgb(97, 191, 173))
    static let SASHI_RANKING_STR_COLOR_02: UIColor = UIColor(red: 97/255, green: 191/255, blue: 173/255, alpha: 1)
    //サシライブランキングの3位の文字色 #f0cf61(rgb(240, 207, 97))
    static let SASHI_RANKING_STR_COLOR_03: UIColor = UIColor(red: 240/255, green: 207/255, blue: 97/255, alpha: 1)
    //サシライブランキングの4位以降の文字色 #bea1a5(rgb(190, 161, 165))
    static let SASHI_RANKING_STR_COLOR_04: UIColor = UIColor(red: 190/255, green: 161/255, blue: 165/255, alpha: 1)
    
    //ファンランキングのランキング部分の文字色 #7b7b7b(rgb(123, 123, 123))
    static let FAN_RANKING_LABEL_COLOR: UIColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1)
    //ファンランキングの1位の枠の色 #f47a90(rgb(244, 122, 144))
    static let FAN_RANKING_FRAME_COLOR_01: UIColor = UIColor(red: 244/255, green: 122/255, blue: 144/255, alpha: 1)
    //ファンランキングの2位の枠の色 #f3c9dd(rgb(243, 201, 221))
    static let FAN_RANKING_FRAME_COLOR_02: UIColor = UIColor(red: 243/255, green: 201/255, blue: 221/255, alpha: 1)
    //ファンランキングの3位の枠の色 #f0cf61(rgb(240, 207, 97))
    static let FAN_RANKING_FRAME_COLOR_03: UIColor = UIColor(red: 240/255, green: 207/255, blue: 97/255, alpha: 1)

    //ファンランキングの1位の文字色 #ffa000(rgb(255, 160, 0))
    static let FAN_RANKING_STR_COLOR_01: UIColor = UIColor(red: 255/255, green: 160/255, blue: 0/255, alpha: 1)
    //ファンランキングの2位の文字色 #ffa000(rgb(255, 160, 0))
    static let FAN_RANKING_STR_COLOR_02: UIColor = UIColor(red: 255/255, green: 160/255, blue: 0/255, alpha: 1)
    //ファンランキングの3位の文字色 #ffa000(rgb(255, 160, 0))
    static let FAN_RANKING_STR_COLOR_03: UIColor = UIColor(red: 255/255, green: 160/255, blue: 0/255, alpha: 1)
    
    //ファンランキングの4位以降のランキングラベルの背景色 #ffa000(rgb(255, 160, 0))
    static let FAN_RANKING_BG_COLOR_04: UIColor = UIColor(red: 255/255, green: 160/255, blue: 0/255, alpha: 1)
    
    /*************************************/
    //ストリーマー詳細関連
    /*************************************/
    //フォロー・フォロワーの枠線の色:#c4c4c4(rgb(196, 196, 196))
    static let CAST_INFO_COLOR_FOLLOW_FRAME: UIColor = UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1)
    static let CAST_INFO_COLOR_FOLLOWER_FRAME: UIColor = UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1)
    
    //フォローするボタン[フォロー中]：#e54b4b(rgb(229, 75, 75))
    //static let CAST_INFO_COLOR_FOLLOW_BTN: UIColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)
    //#dd957d(rgb(221, 149, 125))
    static let CAST_INFO_COLOR_FOLLOW_BTN: UIColor = UIColor(red: 221/255, green: 149/255, blue: 125/255, alpha: 1)
    
    //ダイレクトメールボタン：#32b67a(rgb(50, 182, 122))
    //static let CAST_INFO_COLOR_MAIL_BTN: UIColor = UIColor(red: 50/255, green: 182/255, blue: 122/255, alpha: 1)
    static let CAST_INFO_COLOR_MAIL_BTN: UIColor = UIColor(red: 135/255, green: 176/255, blue: 166/255, alpha: 1)
    
    //ランキングポイントラベル：#ff8b8b(rgb(255, 139, 139))
    //2022-11-14 #DD957D(rgb(221, 149, 125))
    static let CAST_INFO_COLOR_RANKING_POINT_LABEL: UIColor = UIColor(red: 221/255, green: 149/255, blue: 125/255, alpha: 1)
    //絆レベルのラベル：#61bfad(rgb(97, 191, 173))
    //2022-11-14 #A4C187(rgb(164, 193, 135))
    static let CAST_INFO_COLOR_CONNECT_LV_LABEL: UIColor = UIColor(red: 164/255, green: 193/255, blue: 135/255, alpha: 1)
    //左が配信レベル、右が視聴レベル
    //@IBOutlet weak var watchLevelLbl: UILabel!
    //@IBOutlet weak var liveLevelLbl: UILabel!
    //配信レベルのラベル：#bfb5d7(rgb(191, 181, 215))
    //2022-11-14 #D1C653(rgb(209, 198, 83))
    static let CAST_INFO_COLOR_LIVE_LV_LABEL: UIColor = UIColor(red: 209/255, green: 198/255, blue: 83/255, alpha: 1)
    //視聴レベルのラベル：#f0cf61(rgb(240, 207, 97))
    //2022-11-14 #DCB34B(rgb(220, 179, 75))
    static let CAST_INFO_COLOR_WATCH_LV_LABEL: UIColor = UIColor(red: 220/255, green: 179/255, blue: 75/255, alpha: 1)
    //月間ランキングのラベル：#abcee2(rgb(171, 206, 226))
    //2022-11-14 #A5C5C0(rgb(165, 197, 192))
    static let CAST_INFO_COLOR_MONTH_RANKING_LABEL: UIColor = UIColor(red: 165/255, green: 197/255, blue: 192/255, alpha: 1)
    //累計配信のラベル：#85ACA2(rgb(133, 172, 162))
    static let CAST_INFO_COLOR_ALL_COUNT_LABEL: UIColor = UIColor(red: 133/255, green: 172/255, blue: 162/255, alpha: 1)
    /*************************************/
    //ストリーマー詳細関連(ここまで)
    /*************************************/
    //ボタンのテキストの色（iOSの標準の青っぽい色）
    static let BTN_DEFAULT_TEXT_COLOR: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    //ボタンの背景色（未選択時）
    static let BTN_DEFAULT_BACKGROUND_COLOR: UIColor = UIColor.groupTableViewBackground
    
    //ボタンのテキストの色
    static let BTN_DEFAULT_TEXT_COLOR_SELECTED: UIColor = UIColor.white
    //ボタンの背景色（選択時）
    static let BTN_DEFAULT_BACKGROUND_COLOR_SELECTED: UIColor = UIColor(red: 226/255, green: 149/255, blue: 156/255, alpha: 1.0)
    
    //エフェクト関連(WaitViewControllerの1474行目あたりから使用)
    //紫
    static let EFFECT_COLOR_001: UIColor = UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 0.1)
    //青
    static let EFFECT_COLOR_002: UIColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.1)
    //赤
    static let EFFECT_COLOR_003: UIColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.1)
    //白
    static let EFFECT_COLOR_004: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
    
    //グラデーション用
    //青
    static let EFFECT_GRAD_START_002: UIColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.5)
    //赤
    static let EFFECT_GRAD_START_003: UIColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.5)
    //白
    static let EFFECT_GRAD_START_004: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
    //紫
    static let EFFECT_GRAD_START_005: UIColor = UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 0.5)
    
    //青
    static let EFFECT_GRAD_END_002: UIColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 0.8)
    //赤
    static let EFFECT_GRAD_END_003: UIColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.8)
    //白
    static let EFFECT_GRAD_END_004: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
    //紫
    static let EFFECT_GRAD_END_005: UIColor = UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 0.8)
    
    //オレンジ（コイン残高不足のところで使用）
    static let COIN_FUSOKU_TEXT_COLOR: UIColor = UIColor(red: 255/255, green: 177/255, blue: 0/255, alpha: 1)

    //基本のテキスト色　RGM（37,31,32）
    static let BASE_TEXT_COLOR: UIColor = UIColor(red: 37/255, green: 31/255, blue: 32/255, alpha: 1)
    //タイトルのテキスト色　RGM（255,255,255）
    static let TITLE_TEXT_COLOR: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)

    //タイムラインで使用
    //#32b67a(rgb(50, 182, 122))
    static let KOKUCHI_ON_COLOR: UIColor = UIColor(red: 50/255, green: 182/255, blue: 122/255, alpha: 1)
    //#e54b4b(rgb(229, 75, 75))
    //static let FOLLOW_ON_COLOR: UIColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)
    //#dd957d(rgb(221, 149, 125))
    static let FOLLOW_ON_COLOR: UIColor = UIColor(red: 221/255, green: 149/255, blue: 125/255, alpha: 1)
    
    //諸所オフ時の枠線の色 #c4c4c4(rgb(196, 196, 196))
    static let TIMELINE_OFF_FRAME_COLOR: UIColor = UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1)
    
    //配信画面で使用
    static let DOWN_TABBAR_COLOR: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)//黒の半透明
    //配信レベル設定で使用
    //static let LIVE_LEVEL_SETTING_COLOR: UIColor = UIColor(red: 67/255, green: 135/255, blue: 233/255, alpha: 1)//
    //少し薄いグレー
    static let SUKOSHIUSUI_GRAY_COLOR: UIColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    //薄いグレー
    static let USUI_GRAY_COLOR: UIColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1)
    
    //タブバー・メニューバーの背景色(#fafafa)
    //static let BAR_BG_COLOR: UIColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
    //タブバー・メニューバーの背景色(#87b0a6)
    static let BAR_BG_COLOR: UIColor = UIColor(red: 135/255, green: 176/255, blue: 166/255, alpha: 1)
    
    //モノポル内で使用する青色 #5c95fb(rgb(92, 149, 251))
    static let COMMON_BLUE_COLOR: UIColor = UIColor(red: 92/255, green: 149/255, blue: 251/255, alpha: 1)
    //モノポル内で使用する赤色 #e54b4b(rgb(229, 75, 75))
    static let COMMON_RED_COLOR: UIColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)

    /***********************************************************/
    //pub_codeの取得
    /***********************************************************/
    //code_name=mainte_flg 1:メンテ中
    static let URL_GET_PUBCODE = URL_BASE + "getPubcode.php"//メンテナンスかどうかのチェックetc

    /***********************************************************/
    //ログ履歴保存
    /***********************************************************/
    //type 1:課金正常時 2:課金エラー時
    //user_id
    //view_name 発生したVIEW名など
    //value01 エラーメッセージなど
    static let URL_LOG_RIREKI_DO = URL_BASE + "logRirekiDo.php"//エラーログの履歴などの保存
    static let URL_LOG_IP_RIREKI_DO = URL_BASE + "logIpRirekiDo.php"//IPログの履歴などの保存
    
    /***********************************************************/
    //プッシュ通知
    /***********************************************************/
    //GET:type,from_user_id,to_user_id,token(firebaseのトークン)
    //type 1:視聴リクエスト
    static let URL_REQUEST_LIVE_NOTIFY = URL_BASE + "batch/requestLiveByUser.php"//プッシュ通知を送る
    //GET:type,from_user_id,to_user_id,token(firebaseのトークン)
    //type 1:ストリーマーの待機完了
    static let URL_CAST_WAIT_NOTIFY = URL_BASE + "batch/castWaitRemoteNotify.php"//プッシュ通知を送る
    
    /*********GET**************************************************/
    //画像・動画の保存関連(バイナリデータを保存)
    /***********************************************************/
    static let URL_SAVE_PHOTO = URL_BASE + "module/saveUserPhoto.php"//ユーザーの画像を保存
    static let URL_SAVE_PHOTO_BACKGROUND = URL_BASE + "module/saveUserPhotoBackground.php"//ユーザーの画像を保存
    static let URL_SAVE_CAST_MOVIE = URL_BASE + "module/saveCastMovie.php"//ストリーマーの動画を保存
    static let URL_SAVE_TIMELINE_PHOTO = URL_BASE + "module/saveTimelinePhoto.php"//タイムラインの画像を保存
    static let URL_SAVE_TALK_PHOTO = URL_BASE + "module/saveTalkPhoto.php"//トークの画像を保存
    static let URL_SAVE_MYCOLLECTION_PHOTO = URL_BASE + "module/saveMycollectionPhoto.php"//マイコレクションの画像を保存
    static let URL_SAVE_SCREENSHOT_PHOTO = URL_BASE + "module/saveScreenshotPhoto.php"//スクリーンショットの画像を保存
    //さくらのキャッシュサーバーにキャッシュを作成する（curlを使用）
    //GET:base_url,user_id,file_name
    static let URL_CREATE_CACHE_PHOTO_BY_URL = URL_BASE + "createCachePhotoByUrl.php"
    static let URL_CREATE_CACHE_PHOTO_BACKGROUND_BY_URL = URL_BASE + "createCachePhotoBackgroundByUrl.php"
    static let URL_CREATE_CACHE_MOVIE_BY_URL = URL_BASE + "createCacheMovieByUrl.php"
    /***********************************************************/
    //配信中のエフェクト関連処理
    /***********************************************************/
    //エフェクトフラグを取得
    //GET:cast_id
    static let URL_LIVE_EFFECT_CHECK_DO = URL_BASE + "liveEffectCheckDo.php"
    //エフェクトフラグを更新
    //GET:cast_id,effect_flg01,effect_flg02,effect_flg03
    static let URL_MODIFY_EFFECT_FLG = URL_BASE + "modifyEffectFlg.php"
    
    /***********************************************************/
    //配信中のストリーマーロック関連処理
    /***********************************************************/
    //ストリーマーをロックする
    //GET:cast_id,user_id,type(1:待機状態への遷移ロック)
    static let URL_ADD_CAST_LOCK = URL_BASE + "addCastLockByUserId.php"
    //ストリーマーのロック情報を削除する
    //GET:cast_id,user_id,type(1:待機状態への遷移ロック)
    static let URL_DELETE_CAST_LOCK = URL_BASE + "deleteCastLockByUserId.php"
    //ストリーマーのロック情報の件数を取得する（ロック情報の自分以外の件数が返却される）
    //GET:lock_type(1:待機状態への遷移ロック),cast_id,user_id
    static let URL_GET_CAST_LOCK = URL_BASE + "getCastLock.php"
    
    /***********************************************************/
    //絆レベル,配信レベルの更新の関連処理
    /***********************************************************/
    //絆レベルの更新・追加
    //flg:1:値プラス、2:値マイナス
    //GET: user_id, target_user_id,level,exp,live_count,present_point,flg
    //static let URL_SAVE_CONNECT_LEVEL = "https://p2p.monopol.jp/saveConnectLevel.php"//connect_levelの更新
    //GET: user_id, target_user_id,exp,live_count,present_point,flg
    static let URL_SAVE_CONNECT_LEVEL_NEW = URL_BASE + "saveConnectLevelNew.php"//レベルの計算も含む
    //ペアランキング(絆ランキング)の更新・追加
    //GET: user_id,cast_id,exp
    static let URL_SAVE_PAIR_RANKING = URL_BASE + "savePairMonthRanking.php"
    
    //配信レベルに関して
    //配信ポイントの加算処理(user_infoの更新)
    //GET: user_id, point,level,count,minutes,flg
    //static let URL_ADD_LIVE_POINT_DO = "https://p2p.monopol.jp/addLivePointDo.php"
    //GET: user_id, point,count,seconds,flg
    static let URL_ADD_LIVE_POINT_DO_NEW = URL_BASE + "addLivePointDoNew.php"//レベルの計算も含む
    
    //配信時はリスナーの方で処理をすることにする(cast_live_point_rirekiの更新)
    //配信ポイント獲得履歴（履歴保存）
    //type:1:配信 2:プレゼント
    //static func writeLivePointRireki(type:Int, cast_id:Int, user_id:Int, point:Int, minutes:Int)

    //経験値から絆レベルの取得
    //GET exp
    static let URL_GET_CONNECT_LEVEL_BY_EXP = URL_BASE + "getConnectLevelByExp.php"
    //経験値から配信レベルの取得
    //GET exp
    static let URL_GET_LIVE_LEVEL_BY_EXP = URL_BASE + "getLiveLevelByExp.php"
    
    //相手ユーザーとの絆レベルの取得
    //GET user_id,my_user_id
    static let URL_GET_CONNECT_LEVEL_BY_USERID = URL_BASE + "getConnectLevelByUserId.php"
    
    //支払い履歴の取得(実際にお金をキャストに振り込んだ履歴)
    //GET user_id,limit,order,status
    static let URL_GET_PAYMENT_RIREKI_BY_USERID = URL_BASE + "getPaymentRirekiByUserId.php"
    
    //コイン購入履歴の取得
    //GET user_id,limit,order,status
    static let URL_GET_PURCHASE_RIREKI_BY_USERID = URL_BASE + "getPurchaseRirekiByUserId.php"

    //スター＞支払い申請処理
    //GET:user_id, request_star
    static let URL_PAYMENT_REQUEST_DO = URL_BASE + "paymentRequestDo.php"
    
    //「スター:live_now_star」を「コイン:point」に変換する
    //payment_rirekiにインサートする（status=4）
    //paymentRequestToCoinDo.php
    //GET:user_id, star, coin
    static let URL_TO_COIN_DO = URL_BASE + "paymentRequestToCoinDo.php"
    
    /***********************************************************/
    //スクリーンショット関連
    /***********************************************************/
    //スクリーンショットの保存 GET:user_id file_name
    static let URL_SAVE_SCREENSHOT = URL_BASE + "saveScreenshot.php"
    //スクリーンショットリストの取得 GET:user_id status order
    static let URL_GET_SCREENSHOT_LIST = URL_BASE + "getScreenshotList.php"
    
    /***********************************************************/
    //スクリーンショット関連(ここまで)
    /***********************************************************/
    
    //static var name: String = "Qiita"
    static let URL_GET_LIST: String  = URL_BASE + "getUserInfoByStatus.php"//待機のモデル一覧を取得
    
    //ユーザー名からステータスを変更する
    //GET: user_id, status, user_name
    //static let URL_MOD_STATUS_DO_BY_USER_NAME: String = URL_BASE + "modifyStatusDoByUserName.php"

    static let URL_MOD_STATUS: String = URL_BASE + "modifyMyLoginStatus.php"//モデル待機用
    //static let URL_MOD_STATUS_BY_RESERVE: String = URL_BASE + "modifyMyLoginStatusByReserve.php"//モデル待機用(予約あり専用)>未使用
    static let URL_USER_INFO = URL_BASE + "getUserInfoByUserId.php"//ユーザーの情報を取得
    static let URL_USER_INFO_BY_UUID = URL_BASE + "getUserInfoByUuid.php"//ユーザーの情報を取得(引数：UUID)
    static let URL_USER_INFO_BY_LINEID = URL_BASE + "getUserInfoByLineid.php"//ユーザーの情報を取得(引数：LINEID)
    static let URL_USER_INFO_BY_APPLEID = URL_BASE + "getUserInfoByAppleid.php"//ユーザーの情報を取得(引数：APPLEID)
    static let URL_MOD_RANK: String = URL_BASE + "modifyCastRank.php"//キャストのランク変更

    //ユーザーの情報を変更(登録時のみ使用)
    //GET: user_id, name, sex, apple_id(任意)
    static let URL_SAVE_FIRST = URL_BASE + "modifyFirstUserInfo.php"
    //ユーザーの情報UUIDを変更(SNSログインを利用の登録時のみ使用)
    //GET: user_id, uuid
    static let URL_MODIFY_UUID = URL_BASE + "modifyUuidByUserId.php"
    
    //fcm_tokenの更新(プッシュ通知用)
    //GET: user_id, token
    static let URL_MODIFY_TOKEN = URL_BASE + "modifyFcmToken.php"
    
    //引き継ぎ用パスワードを変更
    //GET: password, user_id, next_id
    static let URL_MODIFY_PASSWORD = URL_BASE + "modifyUserInfoPassword.php"
    static let URL_SAVE = URL_BASE + "saveUserInfo.php"//ユーザーの情報を保存

    static let URL_PRODUCT_LIST = URL_BASE + "getProductList.php"//課金商品のリストを取得
    //下記は使用したくない
    static let URL_PURCHASE_DO = URL_BASE + "purchaseDo.php"//課金処理（ポイント購入）GET:user_id,point,user_uid（user_uidは未使用）
    //下記を使用すること
    static let URL_PURCHASE_DO_NEW = URL_BASE + "purchaseDoNew.php"//課金処理（ポイント購入）GET:user_id,point,type(1=有償、2=無料)
    static let URL_PURCHASE_RIREKI = URL_BASE + "savePurchaseRireki.php"//課金処理（履歴保存）GET:user_id,price,point,user_uid,product_id,apple_id
    static let URL_POINT_USE_DO = URL_BASE + "pointUseDo.php"//ポイント消費 GET:user_id,point,type=1は返却
    //ポイント消費（履歴保存）GET:user_id,point,user_uid,type,target_user_id
    static let URL_POINT_USE_RIREKI = URL_BASE + "savePointUseRireki.php"
    
    //各キャストのリスナー一覧の表示などでも使用
    //TABLE:cast_live_point_rireki
    //配信時はリスナーの方で処理をすることにする
    static let URL_LIVE_POINT_RIREKI = URL_BASE + "saveLivePointRireki.php"//配信ポイント獲得履歴（履歴保存）GET:type,cast_id,user_id,point,star,seconds,re_star, status
    static let URL_GET_LIVE_POINT_RIREKI = URL_BASE + "getLivePointRirekiByCast.php"//配信ポイント履歴（履歴取得）GET:type,status,user_id,order
    
    //通報履歴（保存）GET:alert_type, cast_id, user_id, cast_rank, live_time_count, star_temp, coin_temp
    static let URL_ALERT_RIREKI = URL_BASE + "saveAlertRireki.php"
    
    //キャストの検索 GET:user_id,order,type,keyword,limit
    //type:1:キャストのみ
    static let URL_SEARCH_CAST = URL_BASE + "searchCastInfo.php"
    
    //初回のみ購入フラグの変更
    //GET: user_id, flg:0=購入可能,1=購入済
    static let URL_MODIFY_FIRST_FLG01 = URL_BASE + "modifyFirstFlg01.php"
    //10人フォローすると130コインプレゼント
    //タイムライン（初回に開いたとき＆フォロー0人の時）
    //「10人フォローすると130コインプレゼント！」の画像を設置
    //タイムライン（フォロー10人未満の時、まだコインプレゼントもらってない時）
    //「あと**人フォローすると130コインプレゼント！」のテキストを設置
    //10人フォロー完了するとタイムラインのメニュを赤にする。
    //ポップアップを閉じたタイミングで130コインが追加されている。
    //GET: user_id, flg:1:10人フォロー達成済 2:達成後コイン受取済
    static let URL_MODIFY_FIRST_FLG02 = URL_BASE + "modifyFirstFlg02.php"
    //static let URL_MODIFY_FIRST_FLG03 = URL_BASE + "modifyFirstFlg03.php"

    /***********************************************************/
    //ライブ中のチャット関連
    /***********************************************************/
    //GET: type,from_user_id,to_user_id,present_id,chat_text,status
    static let URL_SAVE_CHAT = URL_BASE + "saveChatRireki.php"//ユーザー、モデル間などの全てのチャット履歴を保存
    //GET: user_id,status,order,limit
    static let URL_GET_CHAT_RIREKI = URL_BASE + "getChatRirekiByUserId.php"//チャット履歴を取得
    
    /***********************************************************/
    //ブラックリスト関連
    /***********************************************************/
    //ブラックリスト（保存）GET:from_user_id,to_user_id,flg
    static let URL_SAVE_BLACKLIST = URL_BASE + "saveBlackList.php"
    //ブラックリスト（一覧取得）GET:user_id,order
    static let URL_GET_BLACKLIST = URL_BASE + "getBlackList.php"
    //双方のブラックリスト（一覧取得）GET:user_id,order,to_user_id
    static let URL_GET_BLACKLIST_BOTH = URL_BASE + "getBlackListBoth.php"
    /***********************************************************/
    //ライブ配信関連
    /***********************************************************/
    //キャストがライブ配信する時に状態などを変更(使用したくない)
    //GET: cast_id, password, status:1=待機
    //static let URL_LIVE_DO = URL_BASE + "liveDo.php"
    //こちらを使用したい
    //GET: user_id,status,live_user_id,reserve_flg,max_reserve_count,password
    static let URL_MODIFY_STATUS_INFO = URL_BASE + "modifyStatusInfo.php"
    
    //待機時のタイムスタンプ
    //1:初回待機 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）
    //GET: user_id,listener_user_id,type
    static let URL_ADD_ACTION_RIREKI = URL_BASE + "addCastActionRirekiByUserId.php"
    
    //タイムアウト対策
    static let URL_MODIFY_STATUS_INFO_FOR_TIMEOUT = URL_BASE + "modifyStatusInfoForTimeout.php"
    static let URL_GET_STATUS_INFO_FOR_TIMEOUT = URL_BASE + "getStatusInfoForTimeout.php"//GET:user_id

    //キャストが予約フラグを変更
    //GET: user_id, flg:0=予約可能,1=予約不可
    static let URL_MODIFY_RESERVE_FLG = URL_BASE + "modifyReserveFlg.php"
    
    //プレゼントのリストを取得
    //GET: order, status:1=有効 3:ログイン時プレゼント
    //static let URL_GET_PRESENT_LIST = URL_BASE + "getPresentList.php"
    //GET: order, status, user_id
    static let URL_GET_PRESENT_LIST_BY_USERID = URL_BASE + "getPresentListByUserId.php"
    static let URL_GET_PRESENT_LIST_BY_USERID_FOR_LIVE = URL_BASE + "getPresentListByUserIdForLive.php"
    
    //プレゼントの状態を変更（キャストへ贈ったときに使用）
    //最も古いプレゼントから贈る
    //GET: user_id, target_user_id, present_id, status
    //status=1:所持 3:送信済み
    static let URL_MODIFY_PRESENT_STATUS = URL_BASE + "modifyPresentStatus.php"

    //プレゼントの情報を取得
    //GET: present_id
    static let URL_GET_PRESENT_INFO = URL_BASE + "getPresentInfoById.php"
    
    //配信情報の保存
    //GET: cast_id, type, notes, user_id
    static let URL_SAVE_LIVE_LOG = URL_BASE + "saveLiveLogRireki.php"

    //配信情報の取得
    //GET: user_id, limit, order
    static let URL_GET_LIVE_RIREKI_BY_USERID = URL_BASE + "getLiveRirekiByUserId.php"
    
    //視聴履歴の取得
    //GET: user_id, limit, order
    static let URL_GET_WATCH_RIREKI_BY_USERID = URL_BASE + "getWatchRirekiByUserId.php"
    
    //配信の予約
    //GET: user_id, peer_id, cast_id, status
    //static let URL_RESERVE_DO = URL_BASE + "reserveDo.php"
    
    //配信の予約のチェック(予約しているユーザーのID,PEER_IDを取得)
    //GET: cast_id
    //static let URL_RESERVE_CHECK_DO = URL_BASE + "reserveCheckDo.php"
    
    //ユーザーがコインを持っているかのチェックで使用(コイン数を取得)
    //GET: user_id
    static let URL_COIN_CHECK_DO = URL_BASE + "coinCheckDo.php"
    
    //キャストの配信ランク(FとかAとかの情報)の取得
    //GET: rank_id
    static let URL_GET_LIVE_RANK_INFO = URL_BASE + "getCastLiveRankInfo.php"

    //キャストの状態を取得
    //GET: user_id
    //0:会員登録中 1:待機中 2:通話中 3:ログオフ状態 4:通話中(予約申請) 5:通話中(予約済) 6:通話中(予約キャンセル) 7:キャストによる予約拒否 8:予約ありでライブ中でなく待機状態の時 98:削除 99:リストア済み
    static let URL_GET_LIVE_CAST_STATUS = URL_BASE + "getCastStatus.php"
    
    //スターの加算処理
    //GET: user_id, star, type
    //type=1:スターの没収
    static let URL_ADD_STAR_DO = URL_BASE + "addStarDo.php"

    //配信ポイントの加算処理
    //GET: user_id, user_uid,point,level,count,minutes
    //static let URL_ADD_LIVE_POINT_DO = "https://p2p.monopol.jp/addLivePointDo.php"
    
    /***********************************************************/
    //new予約システム関連
    //１連の配信が終わったら（または配信をスタートするタイミングで）、キャストIDに紐づくデータをdeleteする
    //ユーザー側では5秒おきにチェックタイムスタンプを現時刻に更新する。
    //キャスト側では、５秒おきに、前後のズレが１０秒以上のデータをstatus=2とする。
    /***********************************************************/
    //予約情報の取得＞アプリ内の変数に格納
    //GET: cast_id, user_id, status
    //user_id = 0の場合は、予約最後の人からのリストを返す
    //status=0の場合は、status=1,3の両データを取得している
    //static let URL_GET_RESERVE_INFO_NEW = URL_BASE + "getReserveInfoNew.php"
    
    //配信の予約
    //GET: cast_id, user_id, user_peer_id, wait_count, wait_sec, live_sec, status
    //return:id_temp
    //static let URL_RESERVE_DO_NEW = URL_BASE + "addReserveInfoDo.php"
    
    //配信情報の更新（ライブ時間を更新。予約者などはゼロに更新）
    //GET: cast_id, user_id, live_sec, status
    //static let URL_MODIFY_RESERVE_INFO_LIVE_SEC = URL_BASE + "modifyReserveInfoLiveSec.php"
        
    //配信情報の更新（チェック用のタイムスタンプ、待ち人数、待ち時間などの更新）
    //GET: cast_id, user_id, reserve_info_id
    //static let URL_MODIFY_RESERVE_INFO = URL_BASE + "modifyReserveInfoByUserId.php"
    
    //（有効な）予約のリストを取得(予約しているユーザーのID,PEER_IDなどを取得)
    //GET: cast_id, sec, status, order(1がasc)
    //static let URL_RESERVE_INFO_BY_CAST = URL_BASE + "getReserveInfoByCastId.php"

    //（有効な）予約の数を取得(予約数を取得)
    //GET: cast_id, sec, status, not_user_id
    //reserve_countを返却
    //static let URL_RESERVE_COUNT_BY_CAST = URL_BASE + "getReserveCountByCastId.php"
    
    //予約リストのクリア(キャストIDを軸)
    //GET:cast_id, status
    //static let URL_RESERVE_LIST_CLEAR_CAST = URL_BASE + "deleteReserveInfoByCastId.php"
    
    //予約リストのクリア(ユーザーIDを軸)
    //GET:user_id, status
    //static let URL_RESERVE_LIST_CLEAR_USER = URL_BASE + "deleteReserveInfoByUserId.php"
    
    //予約リストのクリア(キャストIDを軸)
    //sec秒以前の予約を削除する（予約時の異常終了対策）
    //GET:cast_id, sec, wait_sec(wait_secがバッファ時間に入ると、Mysqlのカウントダウンがストップするので注意。)
    //static let URL_RESERVE_LIST_CLEAR_CAST_SEC = URL_BASE + "deleteReserveInfoByCastIdSec.php"
    
    //配信情報の更新（ステータスを更新）
    //GET: cast_id, user_id, status
    //static let URL_MODIFY_RESERVE_INFO_STATUS = URL_BASE + "modifyReserveInfoStatus.php"
    
    //配信情報の更新（特定のストリーマーの配信に関して、現在のライブ時間を更新する）
    //リスナーのIDがわからない場合
    //GET: cast_id, sec
    //static let URL_COUNTDOWN_COMMON_DO = URL_BASE + "countdownCommonDo.php"
    
    //配信情報の更新（status=1のものを全部、wait_secを前倒しする機能）
    //（ストリーマーが配信リクエストをキャンセルした場合に必要）
    //GET: cast_id, count, sec
    //static let URL_RESERVE_WAIT_SEC_DECREASE = URL_BASE + "modifyReserveWaitSecDecrease.php"
    
    //現在の予約・配信数のトータル更新
    //GET: cast_id, flg=1:追加（プラス１） 2:削除(マイナス１) 3:クリア（ゼロにする）
    //static let URL_MODIFY_RESERVE_TOTAL_COUNT = URL_BASE + "modifyReserveTotalCount.php"
    /***********************************************************/
    //設定関連
    /***********************************************************/
    //ユーザーの情報を変更(設定＞プロフィールの編集)
    //POST: user_id, user_name, sex, twitter, facebook, instagram
    static let URL_MODIFY_PROFILE: String = URL_BASE + "modifyUserInfo.php"
    //写真フラグを変更
    //POST: user_id, photo_flg, photo_name
    static let URL_MODIFY_PHOTO_FLG: String = URL_BASE + "modifyUserInfoPhotoFlg.php"
    //背景写真フラグを変更
    //POST: user_id, photo_background_flg, photo_background_name
    static let URL_MODIFY_PHOTO_BACKGROUND_FLG: String = URL_BASE + "modifyUserInfoPhotoBackgroundFlg.php"
    //動画フラグを変更
    //POST: user_id, movie_flg, movie_name
    static let URL_MODIFY_MOVIE_FLG: String = URL_BASE + "modifyUserInfoMovieFlg.php"
    //リストア(復元)する
    //GET: user_id,next_id,next_pass,uuid
    static let URL_RESTORE_DO: String = URL_BASE + "restoreDo.php"
    //通知フラグを変更
    //GET: user_id,flg
    //flg = 1:オン 2:オフ
    static let URL_MODIFY_NOTIFY_FLG: String = URL_BASE + "modifyNotifyFlg.php"

    /***********************************************************/
    // ライブ配信のリクエスト関連
    /***********************************************************/
    //リクエスト履歴に追加
    //GET:user_id, listener_user_id, type, request_status, status
    static let URL_LIVE_REQUEST_DO: String = URL_BASE + "addLiveRequestDo.php"
    
    //リクエスト履歴の未読＞既読へ
    //GET:user_id, status
    //status 0:削除以外全て 1:既読 2:削除 3:未読
    static let URL_MODIFY_LIVE_REQUEST: String = URL_BASE + "modifyLiveRequestStatus.php"
    
    //リクエスト状態の更新（リクエスト後に配信までしたのかなどの状態>最新の一件のみ更新）
    //GET:user_id, listener_user_id, request_status
    //request_status 1:リクエスト後配信 2:リクエスト後キャストが拒否 3:リクエストしてそのまま
    static let URL_MODIFY_LIVE_REQUEST_STATUS_ONE: String = URL_BASE + "modifyLiveRequestStatusByOne.php"
    
    //未読件数の取得 GET:type, user_id
    //type = 1:リスナーによる配信リクエスト
    static let URL_GET_LIVE_REQUEST_NOREAD_COUNT = URL_BASE + "getLiveRequestNoreadCount.php"
    
    //リクエスト履歴を取得
    //GET:user_id, type, status, order, limit
    //type = 1:リスナーによる配信リクエスト
    //status = 0:削除以外全て 1:既読 2:削除 3:未読
    //order = 2:最近のものから
    static let URL_GET_LIVE_REQUEST_RIREKI: String = URL_BASE + "getLiveRequestRirekiByCast.php"
    
    /***********************************************************/
    // プレゼント関連
    /***********************************************************/
    //プレゼント取得など
    //GET:user_id,target_id,present_id,status
    static let URL_PRESENT_DO: String = URL_BASE + "presentDo.php"
    
    /***********************************************************/
    //マイコレクション関連
    /***********************************************************/
    //マイコレクションの一覧（ユーザー用）
    //GET:user_id,order,status
    static let URL_MYCOLLECTION_GET_BY_USER: String  = URL_BASE + "getMycollectionByUserId.php"
    //マイコレクションの保存
    //GET:user_id,cast_id,file_name,status
    static let URL_MYCOLLECTION_SAVE: String  = URL_BASE + "saveMycollection.php"
    //ポケットの拡張
    //GET:user_id,count,coin
    static let URL_MYCOLLECTION_UPDATE_MAX: String  = URL_BASE + "updateMycollectionMax.php"
    //マイコレクションのステータス変更
    //GET:user_id,cast_id,file_name,status
    static let URL_MYCOLLECTION_UPDATE_STATUS: String  = URL_BASE + "modifyMycollectionStatus.php"
    
    /***********************************************************/
    //リスナー関連
    /***********************************************************/
    //リスナーの一覧
    //GET:cast_id,order,not_user_id
    //TABLE:cast_live_point_rireki
    static let URL_LISTENER_GET_BY_CAST: String  = URL_BASE + "getListenerListByCastId.php"
    
    /***********************************************************/
    //ランキング関連
    /***********************************************************/
    //月間キャストランキングの取得(サシライブランキング)
    //GET:limit, user_id
    static let URL_GET_MONTH_CAST_RANKING: String  = URL_BASE + "getCastRanking.php"
    //月間ペアランキングの取得
    //GET:なし
    static let URL_GET_MONTH_PAIR_RANKING: String  = URL_BASE + "getCastPairRanking.php"
    //キャスト毎の月間ペアランキングの取得
    //GET:cast_id
    static let URL_GET_MONTH_PAIR_RANKING_BY_CAST: String  = URL_BASE + "getCastPairRankingByCast.php"
    
    /***********************************************************/
    //フォロー関連
    /***********************************************************/
    static let URL_FOLLOW_DO = URL_BASE + "followDo.php"//フォローの追加・削除 GET:from_user_id,to_user_id,flg
    //flg=1:追加 2:削除
    static let URL_KOKUCHI_DO = URL_BASE + "modifyKokuchiFlg.php"//告知のオン・オフ GET:from_user_id,to_user_id,flg
    //flg=1:オン 2:オフ
    static let URL_GET_FOLLOW_LIST: String  = URL_BASE + "getFollowInfo.php"//フォロワーの一覧
    static let URL_NOTICE_SEND_DO: String  = URL_BASE + "noticeSendDo.php"//告知・通知の送信
    //告知・通知の一覧
    static let URL_NOTICE_LIST_BY_USER: String  = URL_BASE + "noticeListByFollow.php"
    
    //告知のいいねボタンの処理
    //GET:notice_rireki_id,cast_id,user_id,mod_flg
    //mod_flg=1:いいねの追加処理 2:いいねの削除処理
    static let URL_NOTICE_GOOD_DO: String  = URL_BASE + "modifyNoticeGoodCount.php"
    
    //GET:notice_id,user_id,order
    static let URL_GET_GOOD_LIST: String  = URL_BASE + "getGoodList.php"//いいねの一覧

    /***********************************************************/
    //トーク関連
    /***********************************************************/
    //トーク処理 GET:parent_rireki_id,user_id,target_id,sendtext
    static let URL_TALK_SEND_DO = URL_BASE + "talkSendDo.php"
    //トーク履歴を取得 GET:user_id,order
    static let URL_GET_TALK_RIREKI = URL_BASE + "getTalkRirekiByUserId.php"
    //トーク履歴(個別画面用)を取得 GET:user_id,target_id,order
    static let URL_GET_TALK_RIREKI_BY_TARGET_ID = URL_BASE + "getTalkRirekiByUserIdandTargetId.php"
    //未読・既読切り替え GET:talk_id,user_id,target_id,open_point,open_status
    static let URL_MODIFY_TALK_OPENFLG = URL_BASE + "modifyTalkOpenFlg.php"
    //未読件数の取得 GET:user_id
    static let URL_GET_TALK_NOREAD_COUNT = URL_BASE + "getNoreadCount.php"
    //公式からのお知らせに関して、未読・既読切り替え GET:user_id,flg(flg=1:オン 0:オフ)
    static let URL_MODIFY_OFFICIAL_OPENFLG = URL_BASE + "modifyOfficialReadFlg.php"
    /***********************************************************/

    /***********************************************************/
    //イベント関連
    /***********************************************************/
    //イベント作成 POST:
    static let URL_ADD_EVENT_BY_USERID = URL_BASE + "addEventByUserId.php"
    //イベントの価格設定を取得
    //status 1:有効 2:削除 3:保留
    static let URL_GET_EVENT_PUBCODE_STAR_PRICE_LIST = URL_BASE + "getEventPubcodeStarPriceList.php"
    //イベントの状態を更新
    //cast_id,event_id
    //open_status 1:開催前,status 1:有効 2:削除 3:保留
    static let URL_MODIFY_EVENT_STATUS = URL_BASE + "modifyEventStatus.php"
    //自分の作成(有効)したイベント数の取得 GET:user_id、type
    //type 1:イベント作成時のカウントチェック用 2:「マイページ>イベントの確認」からイベント件数確認用
    static let URL_GET_MY_EVENT_COUNT = URL_BASE + "getMyEventCount.php"
    //自分の作成(有効)した親イベントの取得 GET:user_id
    static let URL_GET_MY_EVENT_PARENT = URL_BASE + "getMyEventParentId.php"
    /***********************************************************/
    
    //static let URL_FIREBASE = "gs://monopol-5ce01.appspot.com"//Firebaseの共通部分
    
    //色などの指定(swift4)
    //let rgba = UIColor(red: 255/255, green: 128/255, blue: 168/255, alpha: 1.0)
    //button.backgroundColor = rgba
    
    //openCVやscenekit particleをつかって、撮影した後の画像にエフェクトをつける
    //顔変換
    //https://qiita.com/chaoz/items/c6de2fc80fb686942570
    //webrtcを使用したリアルタイム顔変換
    //https://medium.com/@lyokato/webrtcによるリアルタイム動画通信で-snowのようなイメージフィルタリング-を可能にするには-17285fdf5592
    
    //キャスト検索結果の上限
    static let SEARCH_CAST_LIMIT: Int = 500
    //月間キャストランキングの上限
    static let MONTH_CAST_RANKING_LIMIT: Int = 500
    //配信レポート＞ライブ履歴の上限
    static let LIVE_RIREKI_LIMIT: Int = 500
    //配信レポート＞リクエスト履歴の上限
    static let REQUEST_RIREKI_LIMIT: Int = 500
    //視聴履歴の上限
    static let WATCH_RIREKI_LIMIT: Int = 500
    //コイン購入履歴の上限
    static let PURCHASE_RIREKI_LIMIT: Int = 500
    
    //名前の文字数(小さい幅の時)
    //名前の表示が「namesample…」となる
    static let NAME_MOJI_COUNT_SMALL: Int = 12
    //名前の文字数(大きい幅の時)
    static let NAME_MOJI_COUNT_BIG: Int = 16
    
    //デフォルトは49
    static let TAB_BAR_HEIGHT:CGFloat = 48.0
    
    //トップ画面の名前ラベルの高さ(Viewで覆う時に必要)
    static let TOP_LABLE_HEIGHT: CGFloat = 33.0
    //初期に付与するポイント
    static let INIT_POINT: Double = 0.0
    //初期に付与する配信ポイント
    static let INIT_LIVE_POINT: Int = 0

    /****************************/
    //ライブ配信時間に関する設定値
    //延長した場合は、過ぎた秒数分をストリーマーに払う（切上げ）
    //予約のキャンセル料の設定をする
    /****************************/
    //static let INIT_EX_UNIT_MINUTES: Double = 0.5//延長時の１枠の単位(0.5分ごとに課金が発生するという意味)
    //static let INIT_RESERVE_REDO_SECONDS: Int = 15//予約が始まる直前15秒にカウントの同期をとる
    //------予約をキャンセルした時にリスナーが払うコイン数(修正必要とりあえず固定で300)
    //static let INIT_RESERVE_CANCEL_COIN: Double = 300.0
    //------予約をキャンセルした時にリスナーが払うコイン数(修正必要とりあえず固定で300)
    //static let INIT_RESERVE_CANCEL_COIN_STREAMER: Int = 100
    
    //static let INIT_RESERVE_CHECK_INTERVAL_SEC = 3//3秒おきに予約のチェックを行う（リスナーもこの値を使用する）
    //static let INIT_RESERVE_CHECK_TIME_SEC = 15//10秒タイムスタンプが更新されていない場合は、予約を無効とする
    
    //ライブ中のものが終了してから次の予約リクエストまでのバッファ(間の時間)
    static let BUFFER_SECONDS: Int = 10
    //1枠5分で消費するコイン数
    //static let INIT_POINT_BY_ONE: Int = 200
    //自動延長時の単位時間(自動的に60秒延長される場合)＞廃止
    //static let EXTENSION_SECONDS: Int = 60
    
    //キャストに申請を送ってからの待ち時間
    //static let WAIT_SECONDS: Int = 30
    /****************************/
    //ライブ配信時間に関する設定値(ここまで)
    /****************************/
    
    //ユーザーの画像保存時の大きさ(個別用)
    static let USER_ORG_PHOTO_HEIGHT: CGFloat = 1600.0
    static let USER_ORG_PHOTO_WIDTH: CGFloat = 1200.0
    //ユーザーの画像保存時の大きさ(リスト用)
    static let USER_LIST_PHOTO_HEIGHT: CGFloat = 800.0
    static let USER_LIST_PHOTO_WIDTH: CGFloat = 800.0
    //ユーザーの画像保存時の大きさ(プロフィール用)
    static let USER_PROFILE_PHOTO_HEIGHT: CGFloat = 200.0
    static let USER_PROFILE_PHOTO_WIDTH: CGFloat = 200.0
    
    //背景画像-ユーザーの画像保存時の大きさ(個別用)
    static let BACKGROUND_USER_ORG_PHOTO_HEIGHT: CGFloat = 1600.0
    static let BACKGROUND_USER_ORG_PHOTO_WIDTH: CGFloat = 1200.0
    //背景画像-ユーザーの画像保存時の大きさ(リスト用)
    static let BACKGROUND_USER_LIST_PHOTO_HEIGHT: CGFloat = 800.0
    static let BACKGROUND_USER_LIST_PHOTO_WIDTH: CGFloat = 800.0
    //背景画像-ユーザーの画像保存時の大きさ(プロフィール用)
    static let BACKGROUND_USER_PROFILE_PHOTO_HEIGHT: CGFloat = 200.0
    static let BACKGROUND_USER_PROFILE_PHOTO_WIDTH: CGFloat = 200.0
    
    //スクリーンショットの画像保存時の大きさ(比率)
    //static let SCREENSHOT_PHOTO_HI: CGFloat = 0.3
    //static let SCREENSHOT_PHOTO_HEIGHT: CGFloat = 680.0
    //static let SCREENSHOT_PHOTO_WIDTH: CGFloat = 340.0
    //スクリーンショットの大きさ(個別用)
    static let SCREENSHOT_PHOTO_HEIGHT: CGFloat = 600.0
    static let SCREENSHOT_PHOTO_WIDTH: CGFloat = 400.0
    //スクリーンショットの大きさ(リスト用)
    static let SCREENSHOT_LIST_PHOTO_HEIGHT: CGFloat = 300.0
    static let SCREENSHOT_LIST_PHOTO_WIDTH: CGFloat = 300.0
    
    //マイコレクション画像の大きさ(個別用)
    static let MYCOLLECTION_PHOTO_HEIGHT: CGFloat = 600.0
    static let MYCOLLECTION_PHOTO_WIDTH: CGFloat = 400.0
    //マイコレクション画像の大きさ(リスト用-正方形)
    static let MYCOLLECTION_LIST_PHOTO_HEIGHT: CGFloat = 300.0
    static let MYCOLLECTION_LIST_PHOTO_WIDTH: CGFloat = 300.0
    
    //タイムライン画像の大きさ(個別用)
    static let TIMELINE_PHOTO_HEIGHT: CGFloat = 600.0
    static let TIMELINE_PHOTO_WIDTH: CGFloat = 400.0
    //タイムライン画像の大きさ(リスト用-正方形)
    static let TIMELINE_LIST_PHOTO_HEIGHT: CGFloat = 300.0
    static let TIMELINE_LIST_PHOTO_WIDTH: CGFloat = 300.0
    
    //トーク画像の大きさ(個別用)
    static let TALK_PHOTO_HEIGHT: CGFloat = 600.0
    static let TALK_PHOTO_WIDTH: CGFloat = 400.0
    //トーク画像の大きさ(リスト用-正方形)
    static let TALK_LIST_PHOTO_HEIGHT: CGFloat = 300.0
    static let TALK_LIST_PHOTO_WIDTH: CGFloat = 300.0
    
    //ライブ配信時にスクリーンショットを送った時にもらえるスターの数(ただしユーザー側が受け取った場合のみ)
    static let SCREENSHOT_GET_STAR: Int = 200
    //スクリーンショットを受け取った時に支払うコイン(ユーザー側)
    static let SCREENSHOT_PAY_COIN: Double = 65.0

    /********************************/
    //キャストとの間の絆ポイント(経験値)に関して
    /********************************/
    //配信時の消費ポイント1コインにつき1絆ポイント
    static let CONNECTION_POINT_LIVE: Int = 1
    //配信を1回視聴する
    static let CONNECTION_POINT_LIVE_ONE: Int = 50
    //プレゼントの消費ポイント1コインにつき
    static let CONNECTION_POINT_PRESENT: Double = 0.8
    //プレゼントを送った時に取得できる(無料・有料関わらず)
    static let CONNECTION_POINT_PRESENT_SEND: Int = 5
    //DM送信時の消費ポイント1コインにつき
    static let CONNECTION_POINT_DM_SEND: Int = 0
    //DM開封時の消費ポイント1コインにつき
    static let CONNECTION_POINT_DM_READ: Int = 1
    //フォローする(ユーザー＞キャスト、キャスト＞ユーザー共通)
    static let CONNECTION_POINT_FOLLOW: Int = 200
    /********************************/
    //キャストとの間の絆ポイントに関して(ここまで)
    /********************************/
    
    /********************************/
    //キャストの配信ポイントに関して
    /********************************/
    //1枠の配信成立時の獲得スター1スターにつき1
    static let LIVE_POINT_GET: Int = 1
    //1枠の配信成立または延長時
    static let LIVE_POINT_GET_ONE: Int = 50
    //プレゼント獲得ポイント、1スターにつき1
    static let LIVE_POINT_GET_PRESENT: Int = 1
    /********************************/
    //キャストの配信ポイントに関して(ここまで)
    /********************************/
    
    //ライブ配信情報の取得リミット値
    static let LIMIT_LIVE_RIREKI: Int = 200
    //ライブ配信情報(タイムライン)の取得リミット値
    static let LIMIT_LIVE_TIMELINE_RIREKI: Int = 200
    
    //マイコレクションのMAX値(デフォルト値)
    static let MYCOLLECTION_MAX: Int = 50
    //10コインでMAX+25枚
    static let MYCOLLECTION_UPDATE_COIN: Double = 10.0
    static let MYCOLLECTION_PLUS_MAX: Int = 25
    
    //お給料に関する項目
    //毎月5日~10日の間、かつ 10万配信ポイント(スター)を超えている場合のみ押せる。
    static let FURIKOMI_DAY_FROM: Int = 5
    static let FURIKOMI_DAY_TO: Int = 10
    static let FURIKOMI_MIN_POINT: Int = 100000
    
    //支払いレポート画面の上限レコード数
    static let PAYMENT_RIREKI_MAX: Int = 1000
    
    //トークに関する項目
    //テキストを送信するのに必要なコイン
    //static let SEND_TALK_TEXT_COIN: Double = 25.0
    //画像を送信するのに必要なコイン
    //static let SEND_TALK_PHOTO_COIN: Double = 25.0
    //未読のものを表示するのに必要なコイン
    //static let READ_TALK_COIN: Double = 25.0
    //テキストを送信するのに必要なコイン(相手が有料ストリーマーの場合)
    static let SEND_TALK_TEXT_COIN: Double = 7.0
    //画像を送信するのに必要なコイン(相手が有料ストリーマーの場合)
    static let SEND_TALK_PHOTO_COIN: Double = 7.0
    //テキストを送信するのに必要なコイン(相手が無料ストリーマーの場合)
    static let SEND_TALK_TEXT_COIN_FREE: Double = 0.0
    //画像を送信するのに必要なコイン(相手が無料ストリーマーの場合)
    static let SEND_TALK_PHOTO_COIN_FREE: Double = 0.0
    
    //リスナーが画像・テキストを送信時にストリーマーがもらうスター数（ストリーマーが有料サシライブ設定のとき）
    static let GET_TALK_STAR: Double = 20.0
    
    //未読のものを表示するのに必要なコイン(無料とする)
    static let READ_TALK_COIN: Double = 0.0
    
    //10フォローで130コイン
    static let EVENT_FOLLOW_COIN: Int = 130
    /***********************************************************/
    //文章関連
    /***********************************************************/
    //キャスト側の配信終了(バツボタン)を押した時に表示する文章
    static let CAST_LIVE_CLOSE_STR = "サシライブ配信を終了しますか?\n終了すると、リスナーにも通知されます。\n"
    //通報ボタンを押した時に表示する文章
    static let ALERT_STR = "通報ボタンが押されました。\n\n配信中にリスナーとトラブルが発生した場合、\n強制的に配信を終了することができます。\n※自己都合による配信終了のためには使用しないでください。\n"
    
    //キーボードを閉じるボタンの文字列
    static let KEYBOARD_CLOSE_STR = "編集完了"

    //リアルタイム通知での文字列
    //static let NOTIFY_CAST_TITLE = "Monopolからのお知らせ"
    //static let NOTIFY_CAST_MESSAGE = "さんからサシライブのリクエストがありました！\nアプリを開いてライブを始めよう！"
    
    //配信レベル設定画面
    static let RANK_HOSOKU_FREE_STR = ""
    static let RANK_HOSOKU_B_STR = "時給¥2,400円相当"
    static let RANK_HOSOKU_A_STR = "時給¥3,000円相当"
    static let RANK_HOSOKU_APLUS_STR = "時給¥3,600円相当"
    static let RANK_HOSOKU_S_STR = "時給¥4,200円相当"
    static let RANK_HOSOKU_SS_STR = "時給¥4,800円相当"
    static let RANK_HOSOKU_SSS_STR = "時給¥5,400円相当"
    static let RANK_HOSOKU_HATENA_STR = ""
    
    //待機中キャストを選択する画面に表示する帯の文字列
    static let WAIT_WELCOME_STR = "Welcome！（タップしてサシライブ申請できます）"
    
    //ライブ配信画面(ユーザー側)
    static let PRESENT_LIST_DIALOG_TITLE_STR = "さんにギフトをプレゼントして応援しよう！"
    //ライブ配信画面(キャスト側)

    static let SCREENSHOT_DIALOG_SEND_STR = "スクショが受け取られると" + String(SCREENSHOT_GET_STAR) + "スターが加算されます"
    static let SCREENSHOT_MANAGE_DIALOG_SEND_STR = "サシライブ中にリスナーからスクショリクエストがあった場合にスクショを送信すると、" + String(SCREENSHOT_GET_STAR) + "スターが手に入ります。予めストックを用意しておくと便利です。\nスクショはサシライブ中にも撮影可能です。"
    
    //マイコレクションの最大値を更新するときの文章
    static let MYCOLLECTION_MAX_UPDATE_STR = "ポケットを" + String(MYCOLLECTION_PLUS_MAX) + "枚拡張しますか？(" + String(MYCOLLECTION_UPDATE_COIN) + "コイン消費)"
    //トークの未読メッセージを開封するときの文章
    //static let READ_TALK_STR = "メッセージを開封しますか？(" + String(Int(Util.READ_TALK_COIN)) + "コイン消費)"
    static let READ_TALK_STR = "メッセージを開封しますか？(無料)"
    
    //840行目あたりからのライブ履歴で使用する
    static let LIVE_RIREKI_STR01 = "さんからスクショリクエストがありました"
    static let LIVE_RIREKI_STR02 = "さんにスクショを送りました"
    static let LIVE_RIREKI_STR03 = "ランクがアップしました"
    static let LIVE_RIREKI_STR04 = "さんが予約しました"
    static let LIVE_RIREKI_STR05 = "ライブ配信終了まであと1分"
    //・ランクがアップしました（R47）
    //・2枠目をやじさんが予約しました
    //・1枠目終了まであと1分
    /***********************************************************/
}
