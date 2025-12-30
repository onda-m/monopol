//
//  WaitViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import SkyWay
import AVFoundation
import ReverseExtension
import Firebase
import FirebaseAuth
import FirebaseDatabase
//import SwiftyGif

class WaitViewController: UIViewController, AVCapturePhotoCaptureDelegate,UITabBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var refreshBtn: UIButton!
    var isReconnect = false
    
    //監視関連
    let center = NotificationCenter.default
    
    //選択した時に重ねるView
    var castSelectedDialog = UINib(nibName: "CastSelectedDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastSelectedDialog
    let iconSize: CGFloat = 16.0//ライブ時間の左側のアイコンの大きさ
    var first_flg = 0//1だとSKWMediaConstraintsを設定してはならない
    
    private var myTabBar:UITabBar!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //JSONDecoderのインスタンス取得
    let decoder = JSONDecoder()
    
    var effectTimerCount = 0//エフェクトチェック用のタイマーのカウント（何秒経過したか）
    var effectView: UIView!//エフェクト用のVIEW
    let gradientLayer = EffectGradient()//グラデーション用
    var effectImageView: UIImageView!//Gifアニメーション使用のエフェクト用のIMAGEVIEW
    
    var liveInfoFlg: Int = 0// 0:ライブ配信情報表示オフ 1:オン
    var liveTimelineFlg: Int = 1// 0:タイムライン表示オフ 1:オン

    var listenerStatus: Int = 0//0:リスナーが正常状態 1:リスナーが異常状態(5分-buffer以内) 2:延長時
    var listenerErrorFlg: Int = 0//一時的な値 0:リスナーが異常で終了した場合（デフォルト）
    
    //変数の宣言だけ(ユーザーと繋がった時点でダイアログを作成しておく)
    var castWaitDialog = UINib(nibName: "CastWaitDialog", bundle: nil).instantiate(withOwner: WaitViewController.self,options: nil)[0] as! CastWaitDialog
    var effectListDialog = UINib(nibName: "CastEffectDialog", bundle: nil).instantiate(withOwner: WaitViewController.self,options: nil)[0] as! CastEffectDialog
    var userInfoDialog = OnLiveUserInfo()
    
    //タブのボタン関連
    let timelineBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"lm_ico_off"), tag: 1)
    let liveinfoBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"live_info_off"), tag: 2)
    let cameraBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"camera_streamer_off"), tag: 3)
    let snowBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"effect_streamer_off"), tag: 4)

    //予約があるときに表示される次のライブまでの残り時間
    @IBOutlet weak var nextWaitTimeView: UIView!
    @IBOutlet weak var nextWaitTimeLbl: UILabel!
    
    //左上の予約数の表示(今は押せなくするが、ボタンにしてある)
    @IBOutlet weak var reserveCountBtn: UIButton!
    
    //スクリーンショットダイアログ関連
    @IBOutlet weak var screenshotManageMainView: UIView!
    @IBOutlet weak var screenshotManageMainCollectionView: UICollectionView!
    @IBOutlet weak var screenshotManageNotesLbl: UILabel!

    //var idCount:Int=0
    var screenshotList: [(id:String, user_id:String, file_name:String, value01:String, value02:String, value03:String, value04:String, value05:String, status:String, ins_time:String, mod_time:String)] = []

    // データベースへの参照
    var rootRef = Database.database().reference()
    var conditionRef = DatabaseReference()
    var handle = DatabaseHandle()
    
    var castWaitConditionRef = DatabaseReference()//通常の配信リクエスト申請専用
    var request_handler: UInt = 0//リクエスト時の監視に使用（waitviewcontrollerから離れる際に解放すること）
    
    // デバイス
    var device: AVCaptureDevice!
    // セッション
    var session: AVCaptureSession!
    // 画像のアウトプット
    var output: AVCapturePhotoOutput!
    // プレビューレイヤ
    var previewLayer: CALayer!
    //キャプチャするときのツールバー
    var captureToolbar: UIToolbar!
    
    /*************************************/
    //skyway関連
    /*************************************/
    var dataConnection: SKWDataConnection?
    var messages = [Message]()
    struct Message{
        enum SenderType:String{
            case send
            case get
        }
        var sender:SenderType = .send
        var text:String?
    }

    //ストリーマー側ライブ配信の接続用
    var peer: SKWPeer?
    //var peer_temp: SKWPeer?//ダミー用
    var mediaConnection: SKWMediaConnection?
    //var localStream: SKWMediaStream?
//    var remoteStream: SKWMediaStream?//重要
    
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var remoteStreamView: SKWVideo!//使用しないのでhiddenに
    /*************************************/
    //skyway関連(ここまで)
    /*************************************/
    
    //エフェクト用タイマー
    var timerEffect = Timer()
    //タイマーの変数
    var timerLive = Timer()
    let formatter = DateComponentsFormatter()
    var timerString: String = ""
    var nextTimerString: String = ""//NEXT 0:00のところ
    var timerStringNowListener: String = ""//「ライブ終了まで」のところ

    @IBOutlet weak var countDownLabel: UILabel!
    //右上のユーザーアイコンの部分
    @IBOutlet weak var userIconImageView: EnhancedCircleImageView!
    //お知らせのところ
    @IBOutlet weak var oshiraseView: UIView!
    @IBOutlet weak var oshiraseLbl: UILabel!
 
    //右上のスター受信のところ
    @IBOutlet weak var starGetView: UIView!
    @IBOutlet weak var starLbl: AutoShrinkLabel!
    @IBOutlet weak var starGetLbl: UILabel!

    //左上のライブポイントのところ
    @IBOutlet weak var livePointView: UIView!
    @IBOutlet weak var livePointLbl: UILabel!
    
    //予約の許可・拒否を選択するボタン
    @IBOutlet weak var reserveFlgBtn: UIButton!
    
    //通話終了ボタン
    @IBOutlet weak var endCallButton: UIButton!
    
    var user_id:Int=0//自分のユーザーID

    /*
     *********相手の情報を格納(一部)*********
     *********全格納はOnLiveUserInfoへ*********
     */
    var strUserId: String = ""
    var strUuid: String = ""
    var strUserName: String = ""
    var strPhotoFlg: String = ""
    var strPhotoName: String = ""
    //var strLoginStatus: String = ""
    //var strLoginTime: String = ""
    //var strInsTime: String = ""
    var strConnectLevel: String = ""
    //var strBlackListId: String = ""
    /********相手の情報を格納(ここまで)*********/
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainBoundSize: CGSize = UIScreen.main.bounds.size
        self.castSelectedDialog.frame = CGRect(x: 0, y: -50, width: mainBoundSize.width, height: mainBoundSize.height + 100)
        
        //self.castSelectedDialog.setDialog()
        self.castSelectedDialog.isHidden = true
        
        self.appDelegate.window?.addSubview(self.castSelectedDialog)

        self.exclusiveAllTouches() // これを呼ぶだけで同時タップが防げる
        
        /*****************************************************/
        //リリース時には予約不可能とする(念のためここでDBの状態を変更)
        self.appDelegate.reserveFlg = "0"
        UtilFunc.modifyReserveFlg(user_id:self.user_id, flg:0)
        /*****************************************************/

        /*********************************/
        // カメラの設定
        // セッションを生成
        self.session = AVCaptureSession()
        // バックカメラを選択
        //device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        //device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        self.device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        // バックカメラからキャプチャ入力生成
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("Caught exception!")
            return
        }
        
        self.session.addInput(input)
        self.output = AVCapturePhotoOutput()
        self.session.addOutput(output)
        self.session.sessionPreset = .photo
        // プレビューレイヤを生成
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.frame = view.bounds
        //previewLayer.frame = self.view.frame
        view.layer.addSublayer(self.previewLayer)
        self.session.stopRunning()//必ず「配信カメラ」と「キャプチャカメラ」のどっちかを停止している状態にすること
        self.previewLayer.isHidden = true
        /*********************************/

        //フォントの自動調整
        self.countDownLabel.adjustsFontSizeToFitWidth = true
        self.countDownLabel.minimumScaleFactor = 0.3

        //初期化しておく
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.countDownLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-2 ,string: "Live:--:--", iconImage: UIImage(named:"live")!, iconSize: self.iconSize)
        
        //フォントの自動調整
        self.nextWaitTimeLbl.adjustsFontSizeToFitWidth = true
        self.nextWaitTimeLbl.minimumScaleFactor = 0.3
        
        self.nextWaitTimeView.isHidden = true

        //予約数のボタン
        self.reserveCountBtn.isEnabled = false//押せなくする
        // 角丸
        self.reserveCountBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.reserveCountBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        self.reserveCountBtn.titleLabel!.adjustsFontSizeToFitWidth = true
        self.reserveCountBtn.titleLabel!.minimumScaleFactor = 0.3
        //初期設定
        self.reserveCountBtn.setTitle("予約 0人", for:.normal)
        self.reserveCountBtn.backgroundColor = UIColor.blue

        //予約許可・拒否ボタン
        // 角丸
        self.reserveFlgBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.reserveFlgBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        self.reserveFlgBtn.titleLabel!.adjustsFontSizeToFitWidth = true
        self.reserveFlgBtn.titleLabel!.minimumScaleFactor = 0.3
        
        //初期設定
        //flg:0=予約可能,1=予約不可
        if(self.appDelegate.reserveFlg == "1"){
            //ボタンのデザインを変更
            self.reserveFlgBtn.setTitle("予約拒否", for:.normal)
            self.reserveFlgBtn.backgroundColor = UIColor.red
        }else{
            //ボタンのデザインを変更
            self.reserveFlgBtn.setTitle("予約許可", for:.normal)
            self.reserveFlgBtn.backgroundColor = UIColor.blue
        }

        /*************************************/
        //リリース時は非表示
        //self.reserveCountBtn.isHidden = false
        //self.reserveFlgBtn.isHidden = false
        self.reserveCountBtn.isHidden = true
        self.reserveFlgBtn.isHidden = true
        /*************************************/
        
        // 透明度を設定(初期設定)
        //self.castWaitDialog.allCoverViewForRequest.alpha = 0.7
        self.castWaitDialog.allCoverMessage.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        self.castWaitDialog.allCoverMessage.isUserInteractionEnabled = true
        
        // 透明度を設定(初期設定)
        self.castWaitDialog.allCoverRequest.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        self.castWaitDialog.allCoverRequest.isUserInteractionEnabled = true
        
        if self.castWaitDialog.re_connect_label == nil {
            self.castWaitDialog.re_connect_label = UILabel(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0))
            // 最大行まで行数表示できるようにする
            self.castWaitDialog.re_connect_label.numberOfLines = 0
            self.castWaitDialog.re_connect_label.textColor = UIColor.white
            // テキストを中央寄せ
            self.castWaitDialog.re_connect_label.textAlignment = NSTextAlignment.center
            self.castWaitDialog.re_connect_label.sizeToFit();
            self.castWaitDialog.re_connect_label.center = self.view.center
            self.view.addSubview(self.castWaitDialog.re_connect_label);
        }

        //240,320と比べて縦、横の比がどちらが大きいかを比較（大きい方の倍率で縦横に引き延ばす）
        let width_hi = self.view.frame.width / 240
        let height_hi = self.view.frame.height / 320

        /*****************************/
        //ログ用
        //自分のuser_idを指定
        /*一旦コメントアウト
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        let width_hi_log:Double = Double(self.view.frame.width)
        let height_hi_log:Double = Double(self.view.frame.height)
        
        let width_hihi:Double = Double(self.view.frame.width / 240)
        let height_hihi:Double = Double(self.view.frame.height / 320)
        UtilLog.printf(str: "WaitViewController:self.user_id = " + String(self.user_id) + ":self.view.frame.width = " + String(width_hi_log))
        UtilLog.printf(str: "WaitViewController:self.user_id = " + String(self.user_id) + ":self.view.frame.height = " + String(height_hi_log))
        
        UtilLog.printf(str: "WaitViewController:self.user_id = " + String(self.user_id) + ":width_hi = " + String(width_hihi))
        UtilLog.printf(str: "WaitViewController:self.user_id = " + String(self.user_id) + ":height_hi = " + String(height_hihi))
         */
        /*****************************/

        /*
         let width_hi = 1.0
         let height_hi = 1.0
         */
        
        if(width_hi > height_hi){
            self.localStreamView.transform = CGAffineTransform(scaleX: CGFloat(width_hi), y: CGFloat(width_hi));
        }else{
            self.localStreamView.transform = CGAffineTransform(scaleX: CGFloat(height_hi), y: CGFloat(height_hi));
        }
        
        //作成されたlocalStreamViewと比べて縦、横の比がどちらが小さいかを比較（大きい方の倍率で縦横に縮小する）
        let width_hi_localStreamView = self.view.frame.width / self.localStreamView.frame.width
        let height_hi_localStreamView = self.view.frame.height / self.localStreamView.frame.height
        
        if(width_hi_localStreamView > height_hi_localStreamView){
            //self.localStreamView.transform = CGAffineTransform(scaleX: CGFloat(width_hi), y: CGFloat(width_hi));
            let rect:CGRect = CGRect(x:0, y:0, width:self.localStreamView.frame.width * width_hi_localStreamView, height:self.localStreamView.frame.height * width_hi_localStreamView)
            self.localStreamView.frame = rect
            
            //print(self.localStreamView.frame.width)
            //print(self.localStreamView.frame.height)
        }else{
            //self.localStreamView.transform = CGAffineTransform(scaleX: CGFloat(height_hi), y: CGFloat(height_hi));
            let rect:CGRect = CGRect(x:0, y:0, width:self.localStreamView.frame.width * height_hi_localStreamView, height:self.localStreamView.frame.height * height_hi_localStreamView)
            self.localStreamView.frame = rect
            
            //print(self.localStreamView.frame.width)
            //print(self.localStreamView.frame.height)
        }

        //中央に合わせる
        self.localStreamView.center = self.view.center

        self.screenshotManageMainView.isHidden = true
        self.effectListDialog.isHidden = true
        //self.effectListView.isHidden = true
        
        //下記はデフォルトON
        self.castWaitDialog.messageTableView.isHidden = false//タイムラインを表示
        self.liveTimelineFlg = 1
        
        self.castWaitDialog.waitDialogView.isHidden = false//「１枠で配信中」のダイアログ
        self.refreshBtn.isHidden = true
        //self.castWaitDialog.backDialogView.isHidden = false//「状態を元に戻す」のダイアログ
        //self.castWaitDialog.waitTimeLbl.isHidden = false//「待機時間」のところ
        self.castWaitDialog.statusLbl.isHidden = false//「待機中」のところ
        
        //表示形式："1:00:01"
        self.formatter.unitsStyle = .positional
        self.formatter.allowedUnits = [.minute,.hour,.second]
        
        //自分のuser_idを指定
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        // 角丸
        livePointView.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        livePointView.layer.masksToBounds = true
        
        // 角丸
        nextWaitTimeView.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        nextWaitTimeView.layer.masksToBounds = true
        
        // 角丸
        self.countDownLabel.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.countDownLabel.layer.masksToBounds = true
        
        //機能廃止
        //※お知らせ 必要に応じて以下のようなメッセージを流す(2行か3行) 各メッセージは5秒ほどで消える
        //・ランクがアップしました(R47)
        //・2枠目をやじさんが予約しました
        //・1枠目終了まであと1分
        //・1枠目終了まであと30秒
        //・1枠目終了まであと15秒
        //・まつさんからスクショリクエストがありました
        //・まつさんにスクショを送りました
        // 角丸
        self.oshiraseView.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.oshiraseView.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        self.oshiraseLbl.adjustsFontSizeToFitWidth = true
        self.oshiraseLbl.minimumScaleFactor = 0.3
        
        //右上のスター受信のところ
        // 角丸
        self.starGetView.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.starGetView.layer.masksToBounds = true
        
        // 角丸
        self.starLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.starLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        self.starLbl.adjustsFontSizeToFitWidth = true
        self.starLbl.minimumScaleFactor = 0.3

        /*
         /***********************************************************/
         //  MenuToolbar
         /***********************************************************/
         let mainToolbarView:Maintoolbarview = UINib(nibName: "Maintoolbarview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Maintoolbarview
         mainToolbarView.toolbarViewSetting()
         //画面サイズに合わせる
         mainToolbarView.frame = self.view.frame
         // 貼り付ける
         self.view.addSubview(mainToolbarView)
         /***********************************************************/
         /***********************************************************/
         */
        
        //キーボード対応
        self.configureObserver()
        
        //テーブルの区切り線を非表示
        self.castWaitDialog.messageTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.castWaitDialog.messageTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        //self.messageTableView.rowHeight = UITableViewAutomaticDimension // Contentに合わせたセルの高さに設定
        self.castWaitDialog.messageTableView.allowsSelection = false // 選択を不可にする
        self.castWaitDialog.messageTableView.isScrollEnabled = true
        self.castWaitDialog.messageTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        self.castWaitDialog.messageTableView.register(UINib(nibName: "LiveChatViewCell", bundle: nil), forCellReuseIdentifier: "LiveChat")
        self.castWaitDialog.messageTableView.register(UINib(nibName: "LiveChatPhotoViewCell", bundle: nil), forCellReuseIdentifier: "LiveChatPhoto")
        self.castWaitDialog.messageTableView.register(UINib(nibName: "LiveChatNoneViewCell", bundle: nil), forCellReuseIdentifier: "LiveChatNone")
        
        self.castWaitDialog.downLiveInfoTableView.delegate = self//必要
        self.castWaitDialog.downLiveInfoTableView.dataSource = self//必要
        self.castWaitDialog.downLiveInfoTableView.register(UINib(nibName: "CastLiveInfoDownCell", bundle: nil), forCellReuseIdentifier: "CastLiveInfoDownCell")

        self.castWaitDialog.messageTableView.re.dataSource = self
        self.castWaitDialog.messageTableView.re.delegate = self
        
        //最下部にタブバーを表示
        self.setTabBar()
        
        // ツールバーの高さ
        let footerBarHeight: CGFloat = Util.TAB_BAR_HEIGHT
        
        // ツールバー本体のインスタンス化
        captureToolbar = UIToolbar(frame: CGRect(
            x: 0,
            y: self.view.bounds.size.height - footerBarHeight,
            width: self.view.bounds.size.width,
            height: footerBarHeight)
        )

        //キャプチャ時のツールバー
        // ツールバースタイルの設定
        captureToolbar.barStyle = .default
        // ボタンのサイズ
        let buttonSize: CGFloat = 24
        
        //バーの色
        captureToolbar.isOpaque = false // 不透明を false
        captureToolbar.barTintColor = Util.DOWN_TABBAR_COLOR//黒の半透明
        //ボタンを押した時の色(これを指定しないと押したときに一瞬青くなる)
        captureToolbar.tintColor = UIColor.white
        
        // スクショ管理ページへボタン
        let screenshotManageButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        screenshotManageButton.setBackgroundImage(UIImage(named: "to_screenshot_file"), for: UIControl.State())
        screenshotManageButton.addTarget(self, action: #selector(self.onClickScreenshotManage(_:)), for: .touchUpInside)
        let screenshotManageButtonItem = UIBarButtonItem(customView: screenshotManageButton)
        
        // 撮影ボタン
        let cameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        cameraButton.setBackgroundImage(UIImage(named: "to_shutter"), for: UIControl.State())
        cameraButton.addTarget(self, action: #selector(self.onClickCamera(_:)), for: .touchUpInside)
        let cameraButtonItem = UIBarButtonItem(customView: cameraButton)
        // 進むボタン
        //let forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        //forwardButton.setBackgroundImage(UIImage(named: "arrow_sharp_right"), for: UIControlState())
        //forwardButton.addTarget(self, action: #selector(self.onClickForward(_:)), for: .touchUpInside)
        //let forwardButtonItem = UIBarButtonItem(customView: forwardButton)
        // 閉じるボタン
        let closeBrowserButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        closeBrowserButton.setBackgroundImage(UIImage(named: "cancel"), for: UIControl.State())
        closeBrowserButton.addTarget(self, action: #selector(self.onClickClose(_:)), for: .touchUpInside)
        let closeBrowserButtonItem = UIBarButtonItem(customView: closeBrowserButton)
        // 余白を設定するスペーサー
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        // ツールバーにアイテムを追加する.
        captureToolbar.items = [screenshotManageButtonItem,flexibleItem, cameraButtonItem, flexibleItem,closeBrowserButtonItem]
        // ツールバーを追加
        self.view.addSubview(captureToolbar)
        captureToolbar.isHidden = true
        
        if #available(iOS 11.0, *) {
            //safeareaのボトム調整
            let bottomSafeAreaHeight = UserDefaults.standard.float(forKey: "bottomSafeAreaHeight")
            
            //safeareaを考慮
            let width = self.view.frame.width
            let height = self.view.frame.height
            //デフォルトは49
            let tabBarHeight:CGFloat = Util.TAB_BAR_HEIGHT
            
            captureToolbar.frame = CGRect(x:0,y:height - tabBarHeight - CGFloat(bottomSafeAreaHeight),width:width,height:tabBarHeight + CGFloat(bottomSafeAreaHeight))
        }

        self.setWait()
        
        //共通のダイアログを表示
        self.setCommonDialog()

        //リアルタイム通知の初期化(通知フラグのチェックは、リクエストを投げる時castSelectDialogの時に行う)
        // アプリ起動時・フォアグラウンド復帰時の通知を設定する
        self.center.addObserver(
            self,
            selector: #selector(self.onDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        self.center.addObserver(
            self,
            selector: #selector(self.viewDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    func setWait(){
        //エフェクトの初期化
        self.effectCheckDoForWait(cast_id:self.user_id)
        
        //初めは非表示に（ライブ中のメインタイマーで表示か非表示か判断する）
        self.nextWaitTimeView.isHidden = true
        self.effectListDialog.isHidden = true
        //self.coverView.isHidden = true
        
        self.castWaitDialog.allCoverMessage.isHidden = true
        self.castWaitDialog.re_connect_label.isHidden = true
        self.castWaitDialog.topInfoLabel.isHidden = true
        
        //くるくる表示開始
        if(self.busyIndicator.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            self.view.bringSubviewToFront(self.busyIndicator)
        }else{
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.busyIndicator)
            self.view.bringSubviewToFront(self.busyIndicator)
        }
            
        //self.localStreamView.frame = self.view.frame
        //self.localStreamView.videoGravity = .resizeAspectFill
        /*
            //letinaかどうかの判断
            let letina_num = UIScreen.main.scale
            if(letina_num == 2.0){
            //Retina
            } else {
            //Not Retina
            }
        */

        //配信ポイント(累計)
        let myLivePoint = UserDefaults.standard.integer(forKey: "myLivePoint")
        if self.livePointLbl != nil {
            self.livePointLbl.text = String(UtilFunc.numFormatter(num: myLivePoint)) + " pt"
            
            //ラベルの枠を自動調節する
            self.livePointLbl.adjustsFontSizeToFitWidth = true
            self.livePointLbl.minimumScaleFactor = 0.3
        }

        //skywayの待機処理
        self.setup()

        //待機中はオブジェクトを全てhiddenに
        //messageTextField.isHidden = true
        self.countDownLabel.isHidden = true
        self.userIconImageView.isHidden = true
        self.endCallButton.isHidden = true
        
        //お知らせのところ
        self.oshiraseView.isHidden = true
        //右上のスター受信のところ
        self.starGetView.isHidden = true
            
        /****************************************/
        //予約機能の処理＞予約機能は廃止
        /****************************************/
        if(self.appDelegate.reserveStatus == "5"){
            //予約がある場合は、reserve_user_idはそのまま
            //待機中＞予約あり
            //予約関連の項目はそのまま（MySqlのDB）
            //UtilFunc.loginDoByReserve(user_id:self.user_id, status:1, live_user_id:0)
            UtilFunc.loginDo(user_id:self.user_id, status:5, live_user_id:0, reserve_flg:Int(self.appDelegate.reserveFlg)!, max_reserve_count:Int(self.appDelegate.reserveMaxCount)!, password:"0")
        }else{
            //待機中
            UtilFunc.loginDo(user_id:self.user_id, status:1, live_user_id:0, reserve_flg:Int(self.appDelegate.reserveFlg)!, max_reserve_count:Int(self.appDelegate.reserveMaxCount)!, password:"0")
        }
        /****************************************/
        //予約機能の処理(ここまで)
        /****************************************/

        //くるくる表示終了
        self.busyIndicator.removeFromSuperview()
    }
    
    @IBAction func refreshBtnAction(_ sender: Any) {
        
        self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialog)

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
        //最前面へ
        self.castSelectedDialog.infoLbl.isHidden = false
        self.castSelectedDialog.bringSubviewToFront(self.castSelectedDialog.infoLbl)
        /***************************/
        //ラベル作成(ここまで)
        /***************************/
        
        self.castSelectedDialog.closeBtn.isHidden = true

        self.castSelectedDialog.isHidden = false
        //self.view.bringSubviewToFront(self.castSelectedDialog)
                self.send(text: "画面リフレッシュ")
        self.listenerStatus = 0
    }

    //エフェクトのタイマー（共通化）
    func startEffectTimer(){
        //エフェクトを監視する処理(1秒おき)
        //もしタイマーが停止していたら実行
        if(self.timerEffect.isValid == false){
            self.timerEffect = Timer.scheduledTimer( //TimerクラスのメソッドなのでTimerで宣言
                timeInterval: 1.0, //処理を行う間隔の秒
                target: self,  //指定した処理を記述するクラスのインスタンス
                selector: #selector(self.effectCheck(_:)), //実行されるメソッド名
                userInfo: nil, //selectorで指定したメソッドに渡す情報
                repeats: true //処理を繰り返すか否か
            )
        }
    }
    
    //リアルタイム通知からのフォアグラウンドに移ったときに処理される
    // アプリ起動時・フォアグラウンド復帰時に行う処理（リアルタイム通知からの起動で使用する）
    @objc func onDidBecomeActive(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            //print("フォアグラウンド復帰時")
            //self.setup()

            UtilFunc.isPeerIdExist(peer: self.peer!, peerId: String(self.user_id)){ (flg) in
                if(flg == false){
                    //接続されていない場合(バックグラウンドにある場合)
                    //正常状態(人的操作によるもの)にする
                    self.listenerErrorFlg = 1
                    self.appDelegate.localStream!.removeVideoRenderer(self.localStreamView, track: 0)
                    
                    let option: SKWPeerOption = SKWPeerOption.init();
                    option.key = Util.skywayAPIKey
                    option.domain = Util.skywayDomain
                    
                    //peer = SKWPeer(options: option)
                    //idにはuser_idを入れる
                    self.peer = SKWPeer(id: String(self.user_id), options: option)
                    
                    if let _peer = self.peer{
                        self.setupPeerCallBacks(peer: _peer)
                        self.setupStream(peer: _peer)
                    }else{
                        print("failed to create peer setup")
                    }
                    
                }else{
                    //PEERだけが繋がっている場合
                    //一旦ローカルストリームをクローズ(必須)
                    //if(self.localStream != nil){
                }
            }
            
            //もしタイマーが停止中だったら実行
            self.startEffectTimer()
        }
    }
    
    /*
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            UtilLog.printf(str: "フォアグラウンド")
            
            //skywayの待機処理
            if(peer == nil || peer?.isDisconnected == true){
                self.set_up()
            }
        }
    }*/

    @objc func viewDidEnterBackground(_ notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            //print("バックグラウンド")
            //self.castWaitDialog.app_status = 1
            //タイマー解放(落ちる原因となるタイマーをストップ)
            UtilFunc.stopTimer(timer: self.timerEffect)
        }
    }
    
    func setCommonDialog(){
        //エフェクトダイアログ、待機ダイアログなど必須のダイアログを作成する共通処理
        if(self.castWaitDialog.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
        }else{
            //画面サイズに合わせる
            self.castWaitDialog.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.castWaitDialog)//画面から離れる時に解放する必要がある
        }
        
        if(self.effectListDialog.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
        }else{
            //画面サイズに合わせる
            self.effectListDialog.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.effectListDialog)//画面から離れる時に解放する必要がある
        }
    }
    
    //配信経験値をゲットした時に実行される
    //配信経験値/スターの加算
    //type:1:配信による経験値 2:プレゼントによる経験値3:延長による経験値99:没収したスター
    //live_count:延長の時はゼロ
    //注意：point_numは返却or追加の両方で使用
    //action_flg=1 処理後にダイアログなどを出力する
    //action_flg=2 処理後に何も出力しない
    func getLivePoint(type:Int, cast_id:Int, user_id:Int, point_num:Int, star_num:Int, live_count:Int, seconds:Int, re_star:Int, action_flg:Int){
        if(type == 99){
            //スター/経験値の没収の時
            UtilFunc.writeLivePointRireki(type:99, cast_id:cast_id, user_id:user_id, point:point_num, star:0, seconds:seconds, re_star:re_star)
            
            //user_infoテーブル更新
            //flg:1:値プラス、2:値マイナス
            //GET: user_id, point,star,live_count,seconds,flg
            UtilFunc.saveLiveLevelNew(user_id:cast_id, point:point_num, star:re_star, live_count:0, seconds:seconds, flg:2)
            
            //アプリ内の値を更新
            UtilFunc.setMyInfo()
            
        }else{
            //配信経験値・スターの追加
            let point_temp = UserDefaults.standard.integer(forKey: "myLivePoint")
            let new_point_temp = point_temp + point_num//更新後のポイント
            UserDefaults.standard.set(new_point_temp, forKey: "myLivePoint")
            
            if self.livePointLbl != nil {
                self.livePointLbl.text = String(UtilFunc.numFormatter(num: new_point_temp)) + " pt"
            }
            
            //配信経験値履歴にストリーマーが得た配信経験値などの履歴を保存する
            UtilFunc.writeLivePointRireki(type:type, cast_id:cast_id, user_id:user_id, point:point_num, star:star_num, seconds:seconds, re_star:0)

            //FireBase更新
            let data_point_temp = ["cast_live_point": new_point_temp]
            self.conditionRef.updateChildValues(data_point_temp)
            
            //user_infoテーブル更新
            //flg:1:値プラス、2:値マイナス
            //GET: user_id, point,star,live_count,seconds,flg
            UtilFunc.saveLiveLevelNew(user_id:cast_id, point:point_num, star:star_num, live_count:live_count, seconds:seconds, flg:1)
            
            //アプリ内の値を更新
            UtilFunc.setMyInfo()
            
            if(action_flg == 1 && star_num > 0){
                //ダイアログ(スターの加算のダイアログ)を数秒表示
                self.starGetLbl.text = "+" + String(star_num)//+--
                self.starGetView.isHidden = false
                self.view.bringSubviewToFront(self.starGetView)
                
                //タイムラインのテーブルをリロードする
                //self.castWaitDialog.downLiveInfoTableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    // 5.0秒後に実行したい処理
                    //非表示
                    self.starGetView.isHidden = true
                }
            }
        }
    }
    /******************************************/
    //ポイント計算関連(ここまで)
    /******************************************/
    
    //メインのタイマー
    @objc func timerInterruptLive(_ timer:Timer){
        //0:会員登録中 1:待機中 2:通話中 3:ログオフ状態 4:通話中(予約申請) 5:通話中(予約済) 6:予約キャンセル 7:ストリーマーによる予約拒否 98:削除 99:リストア済み
        if(self.appDelegate.reserveStatus != "1"
            && self.appDelegate.reserveStatus != "3"
            && self.listenerStatus != 2){
            //通話中の時のみカウントする
            //count(経過時間)に+1していく
            self.appDelegate.count += 1
            
            if(self.listenerStatus == 1){
                //リスナーが異常終了している場合
            }else{
                //各オブジェクトの表示（常に表示しておきたいので、念のため、ここでも必要。）
                self.countDownLabel.isHidden = false
                
                //ストリーマー側は非表示のまま（2020/08/19修正）
                //self.refreshBtn.isHidden = false
                self.refreshBtn.isHidden = true

                self.userIconImageView.isHidden = false
                self.endCallButton.isHidden = false
            }
            
            self.timerString = formatter.string(from: Double(self.appDelegate.count))!

            var strLiveTime = ""
            if(self.appDelegate.count < 60){
                //countDownLabel.text = "Live:0:" + timerString
                strLiveTime = NSString(format: "Live:0:%02d", self.appDelegate.count) as String

            }else{
                strLiveTime = "Live:" + timerString
            }
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.countDownLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-2 ,string: strLiveTime, iconImage: UIImage(named:"live")!, iconSize: self.iconSize)

            //0:リスナーが正常 1:リスナーが異常状態(1分-buffer以内)
            //2:リスナーが異常状態(1度エラー処理を実行して待機中)
            if(self.listenerStatus == 0 || self.listenerStatus == 1){
                
                if(isReconnect == false &&  self.listenerStatus == 1){
                    
                    //リスナーが異常切断してしまった場合
                    //ラベルなどはすでに表示済み。
                    //ここでは、一定時間内で復帰できなかった時の処理だけ行う。
                    if(self.appDelegate.count > 0
                        && (self.appDelegate.init_seconds - Util.BUFFER_SECONDS) > self.appDelegate.count){
                        //1分以内の場合(まだ復帰が可能)
                        self.castWaitDialog.showMessageDo(message:"リスナーとの接続が不安定です。\nそのままお待ちください。", font: 15)
                        
                        //ダイアログを最前面に
                        self.view.bringSubviewToFront(self.castWaitDialog)
                        
                    }else{
                        //１分 - bufferをすでに過ぎている場合
                        //そのまま待機状態へ(リスナーは延長できず終了)
                        self.listenerStatus = 2//２になると復帰ができない状態
                        
                        self.commonWaitDo(status:1)
                    }
                }
            }
        }else{
            //復帰できなくなった場合
            //待機中の時の非表示・表示
            //各オブジェクトの表示（常に表示しておきたいので、念のため、ここでも必要。）
            //self.messageTableView.isHidden = false
            //self.messageTextField.isHidden = false
            self.countDownLabel.isHidden = true
            //callButton.isHidden = true
            //endCallButton.isHidden = true
            //self.textSendBtn.isHidden = false
            self.userIconImageView.isHidden = true
            //self.alertBtn.isHidden = false
            //self.alertImageView.isHidden = false
            self.endCallButton.isHidden = true

            //メッセージを消す処理
            self.castWaitDialog.delMessageDo()
        }
    }

    /*
    //未使用
    func GetImage() -> UIImage{
        // キャプチャする範囲を取得.
        let rect = localStreamView.bounds
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        // 対象のview内の描画をcontextに複写する.
        localStreamView.layer.render(in: context)
        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // contextを閉じる.
        UIGraphicsEndImageContext()
        return capturedImage
    }
    */
    
    //未使用
    //スクショ機能(カメラ起動)
    func startCamera() {
        // スクリーン設定
        //setupDisplay()
        
        //ローカルストリームを一時停止
        self.appDelegate.localStream?.setEnableVideoTrack(0, enable: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1.0秒後に実行したい処理
            // セッションを開始
            self.previewLayer.isHidden = false
            self.session.startRunning()

            //下記はセットとして考えて良い(isHiddenとremoveのどちらも必要)
            self.castWaitDialog.isHidden = true
            self.effectListDialog.isHidden = true
            self.effectClear()
            //self.effectView.isHidden = true
            
            //ツールバーを表示する
            //screenshotNotesLbl.isHidden = true
            self.myTabBar.isHidden = true
            self.captureToolbar.isHidden = false
            self.view.bringSubviewToFront(self.captureToolbar)
        }
    }
    
    //未使用
    // スクショ管理画面へボタンをクリックした時の処理
    @objc func onClickScreenshotManage(_ sender: UIButton) {
        //カメラ関連はクローズ
        self.onCameraClose()
        
        self.getScreenshotList()
        
        //ラベルの枠を自動調節する
        screenshotManageNotesLbl.adjustsFontSizeToFitWidth = true
        screenshotManageNotesLbl.minimumScaleFactor = 0.3
        
        if(self.appDelegate.live_target_user_id > 0){
            //ライブ配信中
            screenshotManageNotesLbl.text = "ストックから送信するスクショを選択する"
        }else{
            //待機状態の時は「送信」でなく「保存」
            screenshotManageNotesLbl.text = Util.SCREENSHOT_DIALOG_SEND_STR
        }

        // 角丸
        screenshotManageMainView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        screenshotManageMainView.layer.masksToBounds = true
        
        // カメラの停止
        //self.session.stopRunning()
        
        //ダイアログを表示
        self.screenshotManageMainView.isHidden = false
        self.view.bringSubviewToFront(self.screenshotManageMainView)
        
        //self.onCameraCloseForScreenshot()
    }

    //未使用
    @IBAction func tapScreenshotManageCancelBtn(_ sender: Any) {
        // カメラの起動
        self.screenshotManageClose()
    }
    
    //未使用
    func screenshotManageClose() {
        // カメラの起動
        //self.session.startRunning()
        //self.coverView.isHidden = true

        self.screenshotManageMainView.isHidden = true
    }
    
    //未使用
    func getScreenshotList(){
        //クリアする
        self.screenshotList.removeAll()
        
        var stringUrl = Util.URL_GET_SCREENSHOT_LIST
        stringUrl.append("?status=1&order=1&user_id=")
        stringUrl.append(String(self.user_id))
        
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
                    //let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try self.decoder.decode(UtilStruct.ScreenshotResultJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strId = obj.id
                        let strUserId = obj.user_id
                        let strFileName = obj.file_name
                        let strValue01 = obj.value01
                        let strValue02 = obj.value02
                        let strValue03 = obj.value03
                        let strValue04 = obj.value04
                        let strValue05 = obj.value05
                        let strStatus = obj.status
                        let strInsTime = obj.ins_time
                        let strModTime = obj.mod_time
                        
                        let screenshot = (strId,strUserId,strFileName,strValue01,strValue02,strValue03,strValue04,strValue05,strStatus,strInsTime,strModTime)
                        //配列へ追加
                        self.screenshotList.append(screenshot)
                    }
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //リストの取得を待ってから更新
            self.screenshotManageMainCollectionView.reloadData()
        }
    }
    
    //未使用
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        //let cellImage = UIImage(named: photos[indexPath.row])
        
        //画像キャッシュを使用
        let temp_url = "screenshot/" + String(self.user_id) + "/" + screenshotList[indexPath.row].file_name + "_list.jpg"
        imageView.setImageListByPINRemoteImage(ratio: 0.0, path: temp_url, no_image_named:"demo_noimage")
        
        // 角丸
        imageView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        imageView.layer.masksToBounds = true
        
        //print("table create")
        return testCell
    }
    
    //未使用
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = screenshotManageMainView.frame.width / 4 - 16
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    //未使用
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(self.appDelegate.live_target_user_id > 0){
            //ライブ配信中
            //選択中のセルの画像を取得する。
            //let photoUrl = photoUrls[indexPath.row]
            let photoUrl = "screenshot/" + String(self.user_id) + "/" + screenshotList[indexPath.row].file_name + ".jpg"
            //let imgView:UIImageView! = nil//imageデータの作成用
            //画像キャッシュを使用
            //imgView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            //self.appDelegate.pickedImage = imgView.image
            
            self.appDelegate.pickedImageUrl = photoUrl
            
            //写真ダイアログを表示
            let castPhotoDialog:CastPhotoDialog = UINib(nibName: "CastPhotoDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastPhotoDialog
            //画面サイズに合わせる
            castPhotoDialog.frame = self.view.frame
            
            // 貼り付ける
            self.view.addSubview(castPhotoDialog)
        }else{
            //待機状態の時は選択できないように
        }
    }
    
    //未使用
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    //未使用
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        //return idCount;
        return self.screenshotList.count;
    }
    
    //未使用
    // 撮影ボタンをクリックした時の処理
    @objc func onClickCamera(_ sender: UIButton) {
        //print("タップ")
        //ツールバーを表示する(念のため)
        myTabBar.isHidden = true
        captureToolbar.isHidden = false
        self.view.bringSubviewToFront(captureToolbar)

        takeStillPicture()
    }
    
    //未使用
    // (カメラを)閉じるボタンをクリックした時の処理
    @objc func onClickClose(_ sender: UIButton) {
        // カメラの停止とメモリ解放.
        self.session.stopRunning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1.0秒後に実行したい処理
            //隠れる？
            self.previewLayer.isHidden = true
            
            //下記はセットとして考えて良い
            self.castWaitDialog.isHidden = false
            self.refreshBtn.isHidden = true
            self.effectListDialog.isHidden = true
            
            //ツールバーを表示する
            self.myTabBar.isHidden = false
            self.captureToolbar.isHidden = true
            
            //ローカルストリームを再開
            self.appDelegate.localStream?.setEnableVideoTrack(0, enable: true)
            
            //onCameraClose()とはここだけ異なる
            self.screenshotManageMainView.isHidden = true
            
            //エフェクト再設定
            self.effectDo(effect_id: self.appDelegate.live_effect_id)

            //self.effectView.isHidden = false
            self.view.bringSubviewToFront(self.myTabBar)
        }
    }

    //未使用
    //カメラ画像を閉じる
    func onCameraClose() {
        // カメラの停止とメモリ解放.
        self.session.stopRunning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1.0秒後に実行したい処理
            //隠れる？
            self.previewLayer.isHidden = true
            
            //下記はセットとして考えて良い
            self.castWaitDialog.isHidden = false
            self.refreshBtn.isHidden = true
            self.effectListDialog.isHidden = true

            //ツールバーを表示する
            self.myTabBar.isHidden = false
            self.captureToolbar.isHidden = true
            
            //ローカルストリームを再開
            self.appDelegate.localStream?.setEnableVideoTrack(0, enable: true)
            
            //エフェクト再設定
            self.effectDo(effect_id: self.appDelegate.live_effect_id)
            
            //self.effectView.isHidden = false
            self.view.bringSubviewToFront(self.myTabBar)//これ重要
        }
    }
    
    //未使用
    func takeStillPicture(){
        let photoSettings = AVCapturePhotoSettings()
        //frontの場合は、下記の設定をするとアプリが落ちる
        //photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        output?.capturePhoto(with: photoSettings, delegate: self)
    }

    //未使用
    //　撮影が完了した時に呼ばれる
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // AVCapturePhotoOutput.jpegPhotoDataRepresentation deprecated in iOS11
        let imageData = photo.fileDataRepresentation()
        
        let photo = UIImage(data: imageData!)
        // アルバムに追加.
        //UIImageWriteToSavedPhotosAlbum(photo!, self, nil, nil)
        
        self.appDelegate.pickedImage = photo
        
        if(self.appDelegate.live_target_user_id > 0){
            //ライブ配信中
            //写真ダイアログを表示
            let castPhotoDialog:CastPhotoDialog = UINib(nibName: "CastPhotoDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastPhotoDialog
            //画面サイズに合わせる
            castPhotoDialog.frame = self.view.frame
            
            // 貼り付ける
            self.view.addSubview(castPhotoDialog)
        }else{
            //待機状態の時は「送信」でなく「保存」
            //写真ダイアログを表示
            let castPhotoDialog:CastScreenshotDialog = UINib(nibName: "CastScreenshotDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastScreenshotDialog
            //画面サイズに合わせる
            castPhotoDialog.frame = self.view.frame
            
            // 貼り付ける
            self.view.addSubview(castPhotoDialog)
        }
    }

    //フォアグラウンドなどではなく、この画面に遷移したときにだけ実行される。（1度のみ実行）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 子ノード condition への参照
        self.castWaitConditionRef = self.rootRef.child(Util.INIT_FIREBASE + "/"
            + String(self.user_id))
        // クラウド上で、ノード Util.INIT_FIREBASE に変更があった場合のコールバック処理
        self.request_handler = self.castWaitConditionRef.observe(.value) { (snap: DataSnapshot) in
            //self.conditionRef.removeObserver(withHandle: handler)

            if(snap.exists() == false){
                //UtilLog.printf(str:"すでにデータがない(ストリーマー側)")
                
                //全て非表示
                self.castWaitDialog.allCoverMessage.isHidden = true
                self.castWaitDialog.allCoverRequest.isHidden = true
                self.castWaitDialog.topInfoLabel.isHidden = true

                return
            }
            
            for item in (snap.children) {
                // 中身の取り出し
                let snapshot = item as! DataSnapshot
                let dict = snapshot.value as! [String: Any]
                print(dict)
                //print(dict["user_id"] as Any)
                //print(dict["cast_id"] as Any)
                
                if(dict["user_id"] == nil || dict["cast_id"] == nil){
                    //いったんFireBaseのデータを削除する
                    //self.rootRef.child(Util.INIT_FIREBASE + "/" + String(self.user_id)).removeValue()
                    return
                }
                
                self.castWaitDialog.get_user_id  = dict["user_id"] as! Int
                self.castWaitDialog.get_cast_id  = dict["cast_id"] as! Int
                //status = 1:申請中 2:申請したけど拒否された 3:申請が取り消された 99:接続が承認された
                self.castWaitDialog.status  = dict["status"] as! Int
                
                if(self.user_id == self.castWaitDialog.get_cast_id && self.castWaitDialog.status == 1){
                    //自分への通常リクエストの場合
                    self.castWaitDialog.get_user_name  = dict["user_name"] as? String
                    self.castWaitDialog.get_user_photo_flg = dict["user_photo_flg"] as! Int
                    self.castWaitDialog.get_user_photo_name = dict["user_photo_name"] as? String

                    UtilFunc.isPeerIdExist(peer: self.peer!, peerId: String(self.user_id)){ (flg) in
                        if(flg == false){
                            //接続されていない場合(バックグラウンドにある場合)
                            //ここでは何もしない＞処理は、WaitViewController+CommonSkywayの待機完了後に行う。
                        }else{
                            //フォアグラウンドにある場合
                            self.castWaitDialog.requestDialogDo()
                        }
                    }
                }
            }
        }
    }
    
    //バックグラウンドなどではなく、違う画面に遷移したときにだけ実行される。（1度のみ実行）
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //ライブ配信終了へ
        //正常状態(人的操作によるもの)にする
        self.listenerErrorFlg = 1
        
        self.closeMedia()
        self.sessionClose()
        
        //リクエスト監視の解放（ここで解放しないと監視が徐々に増えていく？）
        self.castWaitConditionRef.removeObserver(withHandle: self.request_handler)

        //タイマー解放
        UtilFunc.stopTimer(timer: self.timerEffect)
        UtilFunc.stopTimer(timer: self.timerLive)

        //ダイアログ解放(下記はセット)
        self.castWaitDialog.removeFromSuperview()
        self.effectListDialog.removeFromSuperview()
        self.effectClear()

        //全てのサブビューを削除しておく
        UtilFunc.removeAllSubviews(parentView: self.view)
    }
    
    //未使用
    //予約許可・拒否ボタンを押した時
    @IBAction func tapReserveFlgBtn(_ sender: Any) {
        //ストリーマーが配信中に予約フラグを変更
        //自分のuser_idを指定(念のため再取得)
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //flg:0=予約可能,1=予約不可
        if(self.appDelegate.reserveFlg == "1"){
            //予約許可に変更
            self.appDelegate.reserveFlg = "0"
            UtilFunc.modifyReserveFlg(user_id:self.user_id, flg:0)
            
            //ボタンのデザインを変更
            self.reserveFlgBtn.setTitle("予約許可", for:.normal)
            self.reserveFlgBtn.backgroundColor = UIColor.blue
        }else{
            //予約拒否に変更
            self.appDelegate.reserveFlg = "1"
            UtilFunc.modifyReserveFlg(user_id:self.user_id, flg:1)
            
            //ボタンのデザインを変更
            self.reserveFlgBtn.setTitle("予約拒否", for:.normal)
            self.reserveFlgBtn.backgroundColor = UIColor.red
        }
    }
    
    //終了ボタンを押した時の処理
    @IBAction func tapCloseBtn(_ sender: Any) {
        //UIAlertControllerを用意
        let actionAlert = UIAlertController(title: Util.CAST_LIVE_CLOSE_STR, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "配信を終了する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            //初期化
            self.refreshBtn.isHidden = true
            self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE + "/"
                + String(self.user_id) + "/" + String(self.appDelegate.live_target_user_id))
            let data = ["status_streamer": 3]
            self.conditionRef.updateChildValues(data)
            
            if(self.appDelegate.reserveStatus == "5"){
                //予約がある時（機能を廃止）
                self.commonWaitDo(status:8)
            }else{
                self.commonWaitDo(status:1)
            }
        })
        
        actionAlert.addAction(modifyAction)
        
        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelAction = UIAlertAction(title: "配信を続ける", style: UIAlertAction.Style.cancel, handler: {
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

    //待機状態にするための共通処理
    //statusには１(予約なし)か８(予約あり)が入る
    //予約は廃止
    func commonWaitDo(status:Int){
        //待機状態へ
        //くるくる表示開始
        if(self.busyIndicator.isDescendant(of: self.view)){
            //すでに追加(addsubview)済み
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            self.view.bringSubviewToFront(self.busyIndicator)
        }else{
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.busyIndicator)
            self.view.bringSubviewToFront(self.busyIndicator)
        }
        
        if(status == 8){
            //次に予約がある場合で待機状態にする場合
            self.listenerStatus = 2
        }
        
        //監視を解放する(firebaseのオブザーバーの解放)
        self.conditionRef.removeObserver(withHandle: self.handle)

        //正常状態(人的操作によるもの)にする
        self.listenerErrorFlg = 1
        self.mediaConnection?.close()
        self.dataConnection?.close()
        self.peer!.disconnect()
        self.peer!.destroy()

        //非表示
        self.userInfoDialog.isHidden = true

        //メッセージの初期化
        self.messages = [Message]()
        self.castWaitDialog.messageTableView.reloadData()
        
        if(status == 8){
            //予約がありの時
            //let strTimeNextLive = UtilFunc.convertStrBySecReserve(sec:self.appDelegate.reserve_wait_time)
            
            //現在ライブ中の残り時間を生成
            //self.castWaitDialog.showMessageDo(message:"サシライブ準備中です。\n" + strTimeNextLive, font: 15)
        }else{
            self.castWaitDialog.showMessageDo(message:"サシライブ準備中です。\nそのままお待ちください。", font: 15)
        }

        UtilFunc.liveModifyStatusDo(user_id:self.user_id, status:status, live_user_id: 0, reserve_flg: Int(self.appDelegate.reserveFlg)!, max_reserve_count: Int(self.appDelegate.reserveMaxCount)!, password: "0")
        
        //これが重要(１or８となる)
        self.appDelegate.reserveStatus = String(status)
        
        //いったんFireBaseのデータを削除する
        self.rootRef.child(Util.INIT_FIREBASE + "/" + String(self.user_id)).removeValue()
        
        //reserve_flg 予約の可否
        //var status: Int = 0//1:申請中
        self.castWaitDialog.status = 0
        //self.castWaitDialog.reserve_flg = self.appDelegate.reserveFlg

        //相手の名前を共通変数に格納しておく(クリア)
        self.appDelegate.live_target_user_name = ""
        self.appDelegate.live_target_user_id = 0
        
        if(status == 8){
            //予約がある場合
            //予約がある場合に待機へ移る時＝リスナーを切り替える時
            self.countDownLabel.isHidden = true
            self.castWaitDialog.bringSubviewCommonDo(type:5)
            self.view.bringSubviewToFront(self.castWaitDialog)
        }else{
            //予約がない場合
            UtilFunc.stopTimer(timer:self.timerLive)
            
            //経過時間を初期化
            //self.countDownLabel.text = "Live:--:--"
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            self.countDownLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-2 ,string: "Live:--:--", iconImage: UIImage(named:"live")!, iconSize: self.iconSize)
            
            self.appDelegate.count = 0
        }

        //skywayの待機処理
        self.setup()
        //くるくる表示終了
        self.busyIndicator.removeFromSuperview()
        
        //リアルタイム通知の初期化(通知を行うかどうかのロジックは、リクエストを投げる時castSelectDialogの時に行う)
        // アプリ起動時・フォアグラウンド復帰時の通知を設定する
        //iOS9からremoveは必要ない？
        self.center.addObserver(
            self,
            selector: #selector(self.onDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        UtilLog.printf(str:"WaitViewController - MemoryWarning")
    }
    
    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // ユーザーアイコンがタップされたら呼ばれる(ユーザーの詳細情報を下から表示)
    @objc func userIconImageViewTapped(_ sender: UITapGestureRecognizer) {
        //ユーザー情報の表示
        self.userInfoDialog.setValue()
        self.userInfoDialog.isHidden = false
        self.view.bringSubviewToFront(self.userInfoDialog)
    }
    
    func setTabBar(){
        /**   TabBarを設置   **/
        self.myTabBar = UITabBar()
        //self.myTabBar.frame = CGRect(x:0,y:height - tabBarHeight,width:width,height:tabBarHeight)
        
        if #available(iOS 11.0, *) {
            //safeareaのボトム調整
            let bottomSafeAreaHeight = UserDefaults.standard.float(forKey: "bottomSafeAreaHeight")
            
            //safeareaを考慮
            let width = self.view.frame.width
            let height = self.view.frame.height
            //デフォルトは49
            let tabBarHeight:CGFloat = Util.TAB_BAR_HEIGHT
            
            self.myTabBar.frame = CGRect(x:0,y:height - tabBarHeight - CGFloat(bottomSafeAreaHeight),width:width,height:tabBarHeight + CGFloat(bottomSafeAreaHeight))
        }

        /***********************************************************/
        //選択中・未選択状態の切り替え含む(ここから)
        self.timelineBtn.image = UIImage(named: "lm_ico_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //選択中の時
        if(self.liveTimelineFlg == 1){
            self.timelineBtn.image = UIImage(named: "lm_ico_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }

        //ボタンを生成(配信情報の詳細(オン/オフ))
        //let liveinfoBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"live_info_off"), tag: 3)
        self.liveinfoBtn.image = UIImage(named: "live_info_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中の時
        if(self.liveInfoFlg == 1){
            self.liveinfoBtn.image = UIImage(named: "live_info_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }

        /*
        //ボタンを生成(スクショ機能)
        //let cameraBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"camera_off"), tag: 2)
        //self.cameraBtn.image = UIImage(named: "camera_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.cameraBtn.image = UIImage(named: "camera_streamer_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //cameraBtn.selectedImage = UIImage(named: "camera_off")
         */

        //ボタンを生成(Snow的機能)
        //let snowBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"face_edit_off"), tag: 4)
        //self.snowBtn.image = UIImage(named: "face_edit_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.snowBtn.image = UIImage(named: "effect_streamer_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //snowBtn.selectedImage = UIImage(named: "face_edit_on")
        
        //選択中・未選択状態の切り替え含む(ここまで)
        /***********************************************************/
        
        //ボタンをタブバーに配置する
        //myTabBar.items = [timelineBtn,liveinfoBtn,cameraBtn,snowBtn]
        myTabBar.items = [timelineBtn,liveinfoBtn,snowBtn]

        //デリゲートを設定する
        myTabBar.delegate = self
        
        //画像位置をtabbarの高さ中央に配置
        let insets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        myTabBar.items![0].imageInsets = insets
        myTabBar.items![1].imageInsets = insets
        myTabBar.items![2].imageInsets = insets

        //区切り線
        myTabBar.shadowImage = UIImage.colorForTabBar(color: UIColor.clear)

        //バーの色
        self.myTabBar.isOpaque = false // 不透明を false
        self.myTabBar.barTintColor = UIColor.clear//透明
        //サイズは引き延ばされるため適当
        self.myTabBar.backgroundImage = UtilFunc.toumeiImage(size: CGSize(width:30, height:10))
        
        self.view.addSubview(myTabBar)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag{
        case 1:
            //タイムライン
            if(self.liveTimelineFlg == 0){
                //オフ＞オン
                self.castWaitDialog.messageTableView.isHidden = false
                self.castWaitDialog.bringSubviewToFront(self.castWaitDialog.messageTableView)
                //オンにする
                self.liveTimelineFlg = 1
            }else{
                //オン＞オフ
                self.castWaitDialog.messageTableView.isHidden = true
                //オフにする
                self.liveTimelineFlg = 0
            }
            
            //画像のオン・オフの切り替えのためいったん削除し、タブメニューを再作成する。
            self.myTabBar.removeFromSuperview()
            self.setTabBar()
        case 2:
            //配信情報の詳細(オン/オフ)
            if(self.liveInfoFlg == 0){
                //ライブ配信中
                self.castWaitDialog.downLiveInfoTableView.isHidden = false
                self.castWaitDialog.bringSubviewToFront(self.castWaitDialog.downLiveInfoTableView)

                //オンにする
                self.liveInfoFlg = 1
                //UtilFunc.scrollToBottom(textView: self.castWaitDialog.rirekiTextView)
            }else{
                //オン＞オフ
                self.castWaitDialog.downLiveInfoTableView.isHidden = true
                //self.castWaitDialog.liveInfoMainView.isHidden = true
                //オフにする
                self.liveInfoFlg = 0
            }
            
            //画像のオン・オフの切り替えのためいったん削除し、タブメニューを再作成する。
            self.myTabBar.removeFromSuperview()
            self.setTabBar()
        
        /*
        case 3:
            //スクショ機能へ
            self.startCamera()
        */
            
        case 4:
            //Snow的機能
            self.effectListDialog.isHidden = false
            self.effectListDialog.mainView.isHidden = false
            self.effectListDialog.effectListView.isHidden = false
            self.view.bringSubviewToFront(self.effectListDialog)
            self.view.bringSubviewToFront(self.effectListDialog.mainView)
            self.view.bringSubviewToFront(self.effectListDialog.effectListView)
            
        default : return
        }
    }
    
    func getTargetInfo(target_id : Int){
        //モデル詳細取得
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        var stringUrl = Util.URL_USER_INFO
        stringUrl.append("?user_id=")
        stringUrl.append(String(target_id))//相手のID
        stringUrl.append("&my_user_id=")
        stringUrl.append(String(user_id))
        
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
                    //let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try self.decoder.decode(UtilStruct.ResultJsonMin.self, from: data!)
                    //self.idCount = json.count
                    
                    //モデル詳細を配列にする。(先頭のみ参照)
                    for obj in json.result {
                        self.strUserId = obj.user_id
                        self.strUuid = obj.uuid
                        self.strUserName = obj.user_name.toHtmlString()
                        self.strPhotoFlg = obj.photo_flg
                        self.strPhotoName = obj.photo_name
                        self.strConnectLevel = obj.connect_level//絆レベル
                        
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
            if(self.strPhotoFlg == "1"){
                //写真を設定ずみ
                let photoUrl = "user_images/" + String(target_id) + "/" + self.strPhotoName + "_profile.jpg"
                
                //画像キャッシュを使用
                self.userIconImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            }else{
                // UIImageをUIImageViewのimageとして設定
                self.userIconImageView.image = UIImage(named:"no_image")
            }
        }
    }
}//メインのクラスはここまで

// MARK: UITableViewDelegate UITableViewDataSource
extension WaitViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(tableView.tag == 1){
            //チャットテーブル
            return 5.0 // セルの下部のスペース
        } else if(tableView.tag == 3){
            // 配信情報ダイアログの下のテーブル
            return 0.0
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if(tableView.tag == 1){
            //チャットテーブル
            view.tintColor = UIColor.clear // 透明にすることでスペースとする
        }else{
            view.tintColor = UIColor.clear // 透明にすることでスペースとする
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 1){
            //チャットテーブル
            return 1 // 普通はここで表示したいセルの数を返すが、セクションのヘッダーとフッターでスペーシングしているので、固定で1を返す
        } else if(tableView.tag == 3){
            // 配信情報ダイアログの下のテーブル
            //return self.reserveList.count + 2
            return 1
        }else{
            return 0
        }
    }
    
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView.tag == 1){
            //チャットテーブル
            //return self.messages.count + self.chatRirekiList.count
            return self.messages.count
        } else if(tableView.tag == 3){
            // 配信情報ダイアログの下のテーブル
            return 1
        }else{
            return 1
        }
    }
    
    /*
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 1){
            //チャットテーブル
        } else if(tableView.tag == 2){
            // 配信情報ダイアログの上のテーブル
            return 1
        } else if(tableView.tag == 3){
            // 配信情報ダイアログの下のテーブル
            return 1
        }else{
            return 1
        }
    }
     */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if(tableView.tag == 1){
                //チャットテーブル
                //let rowCount = indexPath.section - self.chatRirekiList.count
                let rowCount = indexPath.section
            
                //表示する1行を取得する
                let text_temp: String = self.messages[rowCount].text!
                
                /*****************************/
                //イベント監視
                /*****************************/
                if (text_temp.hasPrefix("$$$_screenshot_request")) {
                    //スクショのリクエストは廃止
                    //表示する1行を取得する
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChat") as! LiveChatViewCell
                    // backgroundColorを使って透過させる。
                    //cell.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
                    cell.clipsToBounds = true //bound外のものを表示しない
                    
                    //ユーザー画像の表示
                    if(self.strPhotoFlg == "1"){
                        //写真設定済み
                        //let photoUrl = "user_images/" + String(appDelegate.live_target_user_id) + "_profile.jpg"
                        let photoUrl = "user_images/" + String(appDelegate.live_target_user_id) + "/" + self.strPhotoName + "_profile.jpg"
                        
                        //画像キャッシュを使用
                        cell.liveChatImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                        
                    }else{
                        let cellImage = UIImage(named:"no_image")
                        // UIImageをUIImageViewのimageとして設定
                        cell.liveChatImageView.image = cellImage
                    }
                    
                    //ユーザーの名前
                    cell.nameLabel?.text = UtilFunc.strMin(str:appDelegate.live_target_user_name, num:20)
                    //appDelegate.hymDataConnection.messages[rowCount].text! = "スクショをリクエストしました。"
                    
                    return cell
                }else if(text_temp.hasPrefix("$$$_stamp_")) {
                    //プレゼントを受け取った
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChatPhoto") as! LiveChatPhotoViewCell
                    // backgroundColorを使って透過させる。
                    //cell.mainView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
                    cell.clipsToBounds = true //bound外のものを表示しない
                    
                    //ユーザー画像の表示
                    if(self.strPhotoFlg == "1"){
                        //写真設定済み
                        //let photoUrl = "user_images/" + String(appDelegate.live_target_user_id) + "_profile.jpg"
                        let photoUrl = "user_images/" + String(appDelegate.live_target_user_id) + "/" + self.strPhotoName + "_profile.jpg"
                        
                        //画像キャッシュを使用
                        cell.liveChatImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                        
                    }else{
                        let cellImage = UIImage(named:"no_image")
                        // UIImageをUIImageViewのimageとして設定
                        cell.liveChatImageView.image = cellImage
                    }
                    
                    //ユーザーの名前
                    cell.nameLabel?.text = UtilFunc.strMin(str:appDelegate.live_target_user_name, num:20)
                    
                    //スタンプ(プレゼント画像)の設定
                    //let str = "$$$_stamp_"
                    let stamp_id = String(text_temp.suffix(text_temp.count - 10))
                    let photoUrl = "present_images/" + stamp_id + ".png"
                    //print(photoUrl)
                    cell.sendImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"901")
                    
                    return cell

                }else if(text_temp.hasPrefix("$$$_nocoin_")) {
                    //リスナーがコイン不足のとき（ストリーマーにも表示）
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChatNone") as! LiveChatNoneViewCell

                    //写真設定
                    // UIImageをUIImageViewのimageとして設定
                    cell.liveChatImageView.image = UIImage(named: "monopol_office")
                    
                    //リスナーの足りないコイン数、分数の設定
                    //let str = "$$$_nocoin_"
                    //1分あたりの消費コイン＝self.appDelegate.live_pay_coin
                    let coin_count = String(text_temp.suffix(text_temp.count - 11))
                    
                    //必要なコイン(１枠１分)
                    let temp_coin_num = UserDefaults.standard.double(forKey: "coin")
                    let minute_temp = Int(coin_count)! / Int(temp_coin_num)
                    //floor(Double(coin_count) / Double(self.appDelegate.live_pay_coin))

                    //残りの通話時間(切り捨て)
                    let minute_count = String(Int(floor(Double(minute_temp))))
                    
                    //1行目
                    cell.nameLabel?.text = "リスナーのコイン残高：" + coin_count
                        + "（約" + minute_count + "分）"
                    //2行目以降(文章は横幅に応じて自動で改行される)
                    cell.textView.text = "コインが不足すると自動的にサシライブが終了します。"
                    
                    return cell
                    
                }else{
                    //表示する1行を取得する
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChat") as! LiveChatViewCell
                    cell.clipsToBounds = true //bound外のものを表示しない
                    
                    //ユーザー画像の表示
                    if(self.strPhotoFlg == "1"){
                        //写真設定済み
                        let photoUrl = "user_images/" + String(appDelegate.live_target_user_id) + "/" + self.strPhotoName + "_profile.jpg"
                        
                        //画像キャッシュを使用
                        cell.liveChatImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                        
                    }else{
                        let cellImage = UIImage(named:"no_image")
                        // UIImageをUIImageViewのimageとして設定
                        cell.liveChatImageView.image = cellImage
                    }
                    
                    //cell.textView?.text = appDelegate.hymDataConnection.messages[rowCount].text
                    cell.textView?.text = self.messages[rowCount].text
                    
                    //ユーザーの名前
                    cell.nameLabel?.text = UtilFunc.strMin(str:appDelegate.live_target_user_name, num:20)
                    
                    return cell
                }
        }else if(tableView.tag == 3){
            // 配信情報ダイアログの下のテーブル
            let cell = tableView.dequeueReusableCell(withIdentifier: "CastLiveInfoDownCell") as! CastLiveInfoDownCell
            cell.accessoryType = .none

            if(self.appDelegate.live_target_user_id > 0){
                //ライブ配信中
                //現在のリスナー
                cell.typeLbl.text = "現在のリスナー"
                cell.userNameLbl.text = self.appDelegate.live_target_user_name
                cell.userImageView.isHidden = false
                
                if(self.strPhotoFlg == "1"){
                    //写真を設定ずみ
                    let photoUrl = "user_images/" + String(self.appDelegate.live_target_user_id) + "/" + self.strPhotoName + "_profile.jpg"

                    //画像キャッシュを使用
                    cell.userImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    // UIImageをUIImageViewのimageとして設定
                    cell.userImageView.image = UIImage(named:"no_image")
                }
                
                return cell
            }else{
                //待機中の場合は獲得スターのみ表示
                let live_now_star = UserDefaults.standard.integer(forKey: "live_now_star")
                cell.starLbl.text = String(UtilFunc.numFormatter(num: live_now_star))
                
                //現在のリスナー
                cell.typeLbl.text = "現在のリスナー"
                cell.userNameLbl.text = "--"
                cell.userImageView.isHidden = true
                
                return cell
            }
        }else{
            //下記は適当
            let cell = tableView.dequeueReusableCell(withIdentifier: "CastLiveInfoDownCell") as! CastLiveInfoDownCell
            
            //cell.textLabel?.text = data[indexPath.row]
            cell.accessoryType = .none
            //cell.accessoryView = UISwitch() // スィッチ
            
            return cell
        }
    }
}

//キーボードが隠れてしまう問題の対応
extension WaitViewController: UITextFieldDelegate {
    // Notificationを設定
    func configureObserver() {
        self.center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Notificationを削除
    //func removeObserver() {
    //    self.center.removeObserver(self)
    //}
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        
        let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
            self.view.transform = transform
            
        })
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
        return true
    }
}
