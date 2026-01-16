//
//  MediaConnectionViewController.swift
//  swift
//
//

import UIKit
import SkyWayRoom
import ReverseExtension
import Firebase
import FirebaseDatabase
import AVFoundation//自動応答ライブ動画の再生用
import SwiftyGif
import StoreKit
import CommonKeyboard

class MediaConnectionViewController: UIViewController,UITextViewDelegate ,UITabBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,PurchaseManagerDelegate {

    let iconSize: CGFloat = 16.0//ライブ時間の左側のアイコンの大きさ
    
    /*
     ログを出すタイミングは、
     コイン残りが
     104（約8分）
     65（約5）
     26（約2分）
     このメッセージを出すときは、チャットを強制オンに。
     */
    var nocoinFlg_26: Int = 0//1:すでにチャットログに警告を流した
    var nocoinFlg_65: Int = 0//1:すでにチャットログに警告を流した
    var nocoinFlg_104: Int = 0//1:すでにチャットログに警告を流した
    
    var castSelectedDialog = UINib(nibName: "CastSelectedDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastSelectedDialog
    
    @IBOutlet weak var fullView: UIView!
    
    //キーボード用
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardScrollView: UIScrollView!
    @IBOutlet weak var keyboardView: UIView!
    
    let keyboardObserver = CommonKeyboardObserver()
    
    /********************************************/
    //自動応答ライブ動画の再生用
    //監視関連
    let center = NotificationCenter.default
    
    private var observers: (player: NSObjectProtocol,willEnterForeground: NSObjectProtocol)?
    
    //動画のURLの配列
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    /********************************************/

    //監視の箇所で使用（メモリ対策）
    var temp_cast_send_screenshot:String = ""
    var temp_cast_live_point:Int = 0
    var temp_dict = [String : AnyObject]()
    
    //ライブ中のエフェクト用
    var effect_id: Int = 0//ライブ配信で設定したエフェクトID
    var effect_id_before: Int = 0//ライブ配信で設定したエフェクトID(直前の比較用)
    
    var coverView: UIView!//利用者のタップをできないようにするために覆うVIEW
    
    let gradientLayer = EffectGradient()//グラデーション用
    var effectView: UIView!//エフェクト用のVIEW
    var effectImageView: UIImageView!//エフェクト用のIMAGEVIEW
    
    var liveTimelineFlg: Int = 1// 0:タイムライン表示オフ 1:オン
    
    let userGetScreenshotDialog:UserGetScreenshotDialog = UINib(nibName: "UserGetScreenshotDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! UserGetScreenshotDialog
    let userPresentListDialog:UserPresentListDialog = UINib(nibName: "UserPresentListDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! UserPresentListDialog
    let autoUserTabDialog:AutoUserTabDialog = UINib(nibName: "AutoUserTabDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! AutoUserTabDialog

    //変数の宣言だけ(キャストと繋がった時点でダイアログを作成しておく)
    var castInfoDialog = OnLiveCastInfo()
    
    var selectedPathIndex = 0//選択したプラン:buttonRow(本番課金の引数渡し用)
    
    private var myTabBar:UITabBar!

    //予約リストの取得用
    //var reserveList: [(id:String, cast_id:String, user_id:String, user_peer_id:String, wait_sec:String)] = []
    //var reserveListTemp: [(id:String, cast_id:String, user_id:String, user_peer_id:String, wait_sec:String)] = []
    var reserveList: [(id:String, cast_id:String, user_id:String, user_peer_id:String
        , wait_sec:String, reserve_user_name:String
        , reserve_photo_flg:String, reserve_photo_name:String)] = []
    var reserveListTemp: [(id:String, cast_id:String, user_id:String, user_peer_id:String
        , wait_sec:String, reserve_user_name:String
        , reserve_photo_flg:String, reserve_photo_name:String)] = []
    
    //キャスト情報取得用
    var cast_login_status_check: String = ""
    var cast_live_user_id_check: String = ""
    var cast_reserve_user_id_check: String = ""
    var cast_reserve_peer_id_check: String = ""
    var cast_reserve_flg_check: String = ""

    //相手との絆レベル取得用
    struct ConnectResult: Codable {
        let level: String//
        let bonus_rate: String//
    }
    struct ResultConnectJson: Codable {
        let count: Int
        let result: [ConnectResult]
    }
    
    //キャストのエフェクトフラグ取得用
    struct EffectResult: Codable {
        let effect_flg01: String//
        let effect_flg02: String//
        let effect_flg03: String//
    }
    struct ResultEffectJson: Codable {
        let count: Int
        let result: [EffectResult]
    }
    
    //プレゼントの一覧用
    var presentList: [(present_id:String, present_name:String, coin:String, star:String, live_point: String, photo_flg:String, status:String, present_count:String)] = []
    var presentListTemp: [(present_id:String, present_name:String, coin:String, star:String, live_point: String, photo_flg:String, status:String, present_count:String)] = []
    
    //ステータスが有効の商品のPRODUCT_IDの格納用
    //productIdentifiers : [String] = ["com.matome7.p2p.001","com.matome7.p2p.002"]
    //var productIdentifiers : [String]
    //Intがある場合、Nullのデータを含んだ場合、正常に動作しない　→ 原因不明
    struct ProductResult: Codable {
        let product_id: String
        let apple_id: String
        let reference_name: String
        let price: String
        let point: String
        let value01: String
        let value02: String
        let value03: String
    }
    struct ResultProductJson: Codable {
        let count: Int
        let result: [ProductResult]
    }

    //商品リスト(タプル配列)
    var productList: [(productId:String, appleId:String, referenceName:String, price:String, point:String, value01:String, value02:String, value03:String)] = []
    var productListTemp: [(productId:String, appleId:String, referenceName:String, price:String, point:String, value01:String, value02:String, value03:String)] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // データベースへの参照
    var rootRef = Database.database().reference()
    var conditionRef = DatabaseReference()
    var handle = DatabaseHandle()

    //キャスト情報取得用
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

    /*************************************/
    //skyway関連
    /*************************************/
    private var room: Room?
    private var localMember: LocalRoomMember?
    private var roomPublications: [RoomPublication] = []
    private var roomSubscriptions: [RoomSubscription] = []
    private var waitRoom: Room?
    private var waitLocalMember: LocalRoomMember?
    private var waitRoomTask: Task<Void, Never>?
    private var waitRoomClosed = false
    private var waitingMemberIds: [String] = []
    private var localVideoStream: LocalVideoStream?
    private var localAudioStream: LocalAudioStream?
    private var localDataStream: LocalDataStream?
    private var microphoneAudioSource: MicrophoneAudioSource?
    private var cameraVideoSource: CameraVideoSource?
    private var dataSource: DataSource?
    private var cameraDevice: CameraVideoSource.Camera?
    private var remoteVideoStream: RemoteVideoStream?
    private var remoteAudioStream: RemoteAudioStream?
    private var remoteDataStream: RemoteDataStream?
    private var localVideoView: CameraPreviewView?
    private var remoteVideoView: VideoView?

    var messages = [Message]()
    struct Message{
        enum SenderType:String{
            case send
            case get
        }
        var sender:SenderType = .send
        var text:String?
    }
    
    private var roomTask: Task<Void, Never>?
    private var roomClosed = false
    
    
    //チャットやりとりのリストの部分
    @IBOutlet weak var messageTableView: UITableView!

    //コールバック用
    @IBOutlet weak var localStreamView: UIView!
    @IBOutlet weak var remoteStreamView: UIView!
    /*************************************/
    //skyway関連(ここまで)
    /*************************************/
    
    //タイマーの変数
    var timerUser = Timer()
    let formatter = DateComponentsFormatter()
    
    //カウント(経過時間)の変数
    //var count = 0
    
    //@IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    //右上の現在の経過時間のところ（廃止のため非表示）
    @IBOutlet weak var countDownLabel: UILabel!

    //左上のライブポイントのところ
    @IBOutlet weak var livePointView: UIView!
    @IBOutlet weak var livePointLbl: UILabel!
    
    //何か文字の入力があれば、sendBtnの画像を変更するsend_ico_off＞send_ico_on
    //@IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendTextEditView: PlaceHolderTextView!
    
    //@IBOutlet weak var btnPresents: UIButton!
    //@IBOutlet weak var getPresentLabel: UILabel!//プレゼントを受け取った時に表示

    //private var defaultScrollOffset: CGFloat?
    @IBOutlet weak var sendTextView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    
    //var sendText:String = ""
    var liveCastId:String = ""//キャストのユーザーID

    var user_id: Int = 0//自分のID
    var my_photo_flg: Int = 0
    var my_photo_name: String = "0"
    
    var isReconnect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.castSelectedDialog.frame = self.view.frame
        
        let mainBoundSize: CGSize = UIScreen.main.bounds.size
        self.castSelectedDialog.frame = CGRect(x: 0, y: -50, width: mainBoundSize.width, height: mainBoundSize.height + 100)
        //self.castSelectedDialog.setDialog()
        self.castSelectedDialog.isHidden = true
        
        self.appDelegate.window?.addSubview(self.castSelectedDialog)

        //初期化
        self.nocoinFlg_26 = 0//1:すでにチャットログに警告を流した
        self.nocoinFlg_65 = 0//1:すでにチャットログに警告を流した
        self.nocoinFlg_104 = 0//1:すでにチャットログに警告を流した
        
        //キーボード関連
        self.sendTextEditView.delegate = self
        
        // drag down to dismiss keyboard
        self.keyboardScrollView.keyboardDismissMode = .interactive

        //スクロール無効に
        self.keyboardScrollView.isScrollEnabled = false
        
        // 枠線の色
        //self.sendTextEditView.layer.borderColor = UIColor.clear
        // 枠線の太さ
        self.sendTextEditView.layer.borderWidth = 0
        // 角丸
        self.sendTextEditView.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.sendTextEditView.layer.masksToBounds = true
        self.sendTextEditView.placeHolder = "メッセージを入力"
        
        //最前面に
        self.fullView.bringSubviewToFront(self.messageTableView)
        
        keyboardObserver.subscribe(events: [.willChangeFrame, .dragDown]) { [weak self] (info) in
            guard let weakSelf = self else { return }
            var bottom = CGFloat(0)//重要
            if info.isShowing {
                //キーボードが表示された場合
                //print("表示・または表示領域が変更されました")
                //bottom = -info.visibleHeight
                bottom = info.visibleHeight//下からの距離（260 or 216）

                //print(info.visibleHeight)
                if #available(iOS 11, *) {
                    bottom += weakSelf.view.safeAreaInsets.bottom
                }
                
                // backgroundColorを使って透過させる。
                self?.sendTextView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 0.9)

                //最前面に
                //messagetabel
                //keyboardscrollview
                self!.fullView.bringSubviewToFront(self!.keyboardScrollView)

            }else{
                //キーボードが非表示
                let strTemp = self!.sendTextEditView.text
                
                if(strTemp == ""){
                    //チャットログを最前面に
                    self!.fullView.bringSubviewToFront(self!.messageTableView)
                }else{
                    //入力のところを最前面に
                    self!.fullView.bringSubviewToFront(self!.keyboardScrollView)
                }
                
                // backgroundColorを使って透過させる。>元に戻す
                self?.sendTextView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 0.2)
            }
            
            UIView.animate(info, animations: { [weak self] in
                self?.bottomConstraint.constant = bottom
                self?.view.layoutIfNeeded()
                //print(bottom)
            })
        }

        //自分のIDを取得
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.my_photo_flg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
        self.my_photo_name = UserDefaults.standard.string(forKey: "myPhotoName")!
        
        //self.messageTableView.isHidden = true//起動直後は非表示
        self.messageTableView.isHidden = false//起動直後は表示
        self.liveTimelineFlg = 1
        
        //アプリを起動した直後の秒数
        //表示形式："1:00:01"
        self.formatter.unitsStyle = .positional
        self.formatter.allowedUnits = [.minute,.hour,.second]
        
        //スクリーンショットを受け取った時のダイアログ
        self.userGetScreenshotDialog.isHidden = true//配信情報を非表示
        //画面サイズに合わせる
        self.userGetScreenshotDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.userGetScreenshotDialog)

        //プレゼントリストのダイアログ
        self.userPresentListDialog.isHidden = true//非表示
        //画面サイズに合わせる
        self.userPresentListDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.userPresentListDialog)
        self.userPresentListDialog.presentListCollectionView.delegate = self//必要
        self.userPresentListDialog.presentListCollectionView.dataSource = self//必要

        /******************************/
        //自動応答でのみ使用されるダイアログ
        /******************************/
        self.autoUserTabDialog.isHidden = true//非表示
        //画面サイズに合わせる
        self.autoUserTabDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.autoUserTabDialog)
        
        /******************************/
        //コイン購入プランのダイアログ
        /******************************/
        Util.userPurchasePlanDialog = UINib(nibName: "UserPurchasePlanDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! UserPurchasePlanDialog
        Util.userPurchasePlanDialog.isHidden = true//コイン購入プランを非表示
        Util.userPurchasePlanDialog.mainView.isHidden = true//ノーコインダイアログを非表示
        
        //画面サイズに合わせる
        Util.userPurchasePlanDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(Util.userPurchasePlanDialog)
        Util.userPurchasePlanDialog.productTableView.delegate = self//必要
        Util.userPurchasePlanDialog.productTableView.dataSource = self//必要
        
        Util.userPurchasePlanDialog.productTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "productCell")
        /******************************/
        //コイン購入プランのダイアログ(ここまで)
        /******************************/

        // 角丸
        self.livePointView.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.livePointView.layer.masksToBounds = true
        
        //ラベルの枠を自動調節する
        self.livePointLbl.adjustsFontSizeToFitWidth = true
        self.livePointLbl.minimumScaleFactor = 0.3
        
        // 角丸
        self.countDownLabel.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.countDownLabel.layer.masksToBounds = true
        //初期化しておく
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.countDownLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-2 ,string: "Live:--:--", iconImage: UIImage(named:"live")!, iconSize: self.iconSize)
        
        //キーボード対応
        //self.configureObserver()
        
        //テーブルの区切り線を非表示
        self.messageTableView.separatorColor = UIColor.clear
        self.messageTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        //self.messageTableView.rowHeight = UITableViewAutomaticDimension // Contentに合わせたセルの高さに設定
        self.messageTableView.allowsSelection = false // 選択を不可にする
        self.messageTableView.isScrollEnabled = true
        //self.messageTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        self.messageTableView.register(UINib(nibName: "LiveChatViewCell", bundle: nil), forCellReuseIdentifier: "LiveChat")
        self.messageTableView.register(UINib(nibName: "LiveChatPhotoViewCell", bundle: nil), forCellReuseIdentifier: "LiveChatPhoto")
        self.messageTableView.register(UINib(nibName: "LiveChatNocoinViewCell", bundle: nil), forCellReuseIdentifier: "LiveChatNocoin")

        // backgroundColorを使って透過させる。
        self.sendTextView.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 0.2)
        
        //自分の映像は非表示
        //localStreamView.isHidden = true
        
        //相手のキャストIDを取得
        liveCastId = String(self.appDelegate.request_cast_id)
        
        //sendId = "99"
        //キャストの情報・絆レベル関連の情報を取得
        self.getCastInfo()

        // TableView Design（下から上へチャットを流すため、外部APIを使用）
        messageTableView.re.dataSource = self
        messageTableView.re.delegate = self
        
        /*********************************************************/
        //自動映像用
        /*********************************************************/
        //1:通常、2:自動応答のどれを選んでいるか。
        let selectedStreamerAuto = UserDefaults.standard.integer(forKey: "selectedStreamerAuto")
        
        if(selectedStreamerAuto == 2){
            //自動応答の場合は「7428」で固定
            self.livePointLbl.text = UtilFunc.numFormatter(num: 7428) + " pt"
            
            /************************************/
            //キャストのダイアログを作成しておく(重要)
            self.castInfoDialog = UINib(nibName: "OnLiveCastInfo", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! OnLiveCastInfo
            //最初は非表示(キャスト情報ダイアログ)
            //画面サイズに合わせる
            self.castInfoDialog.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.castInfoDialog)
            self.castInfoDialog.isHidden = true
            /************************************/
            
            //自動応答の場合は動画を再生
            let movieName = "auto_live_movie"
            let movieUrl = Util.URL_USER_MOVIE_BASE + liveCastId + "/" + movieName + ".mp4"

            let url = URL(string: movieUrl)!
            let playerItem = AVPlayerItem.init(url: url)
            
            self.playerLayer.removeFromSuperlayer()
            self.player = AVPlayer(playerItem: playerItem)
            self.player.automaticallyWaitsToMinimizeStalling = false//速く再生開始となる
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer.frame = self.view.bounds
            self.playerLayer.videoGravity = .resizeAspectFill
            self.playerLayer.zPosition = -1 // ボタン等よりも後ろに表示
            
            //testCell.layer.insertSublayer(self.playerLayer00, at: 0) // 動画をレイヤーとして追加
            self.view.layer.addSublayer(self.playerLayer) // 動画をレイヤーとして追加
            //self.view.layer.insertSublayer(self.playerLayer, at: 0) // 動画をレイヤーとして追加
            
            self.remoteStreamView.isHidden = true
            self.player.play()
            
            //キャッシュサーバーに動画キャッシュを作成
            UtilFunc.createCacheMovieByUrl(user_id:self.user_id, file_name:movieName)
            
            // 最後まで再生したら最初から再生する
            let playerObserver = self.center.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: self.player.currentItem,
                queue: .main) { [weak playerLayer] _ in
                    playerLayer?.player?.seek(to: CMTime.zero)
                    playerLayer?.player?.play()
            }
            
            // アプリがバックグラウンドから戻ってきた時に再生する
            let willEnterForegroundObserver = self.center.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main) { [weak playerLayer] _ in
                    playerLayer?.player?.play()
            }
            
            self.observers = (playerObserver, willEnterForegroundObserver)
            
            //イヤホンの抜き差し対応（自動応答動画の再生用）
            self.addAudioSessionObserversAuto()
            
            //メッセージの初期化
            self.messages.removeAll()
            //self.getChatRirekiByUser()
            
            //最下部にタブバーを表示
            self.setTabBar()
            
            /**********************************************/
            //サシライブに参加しました！というメッセージをタイムラインに流す
            //少し遅れて流す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // 0.5秒後に実行したい処理
                //self.send(text: "サシライブに参加しました！")
                self.sendAuto(text: "$$$_auto_01")
                self.messageTableView.reloadData()
                //self.messageTextField.text = nil
                self.sendTextEditView.text = nil
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                // 5.0秒後に実行したい処理
                self.sendAuto(text: "$$$_auto_02")
                self.messageTableView.reloadData()
                //self.messageTextField.text = nil
                self.sendTextEditView.text = nil
            }
            
            /*
            モノポル公式
            $$$_auto_01:このサシライブはテスト用の自動映像です。サシライブの機能を試してみることができます。
            ▼▼▼5秒後に以下を表示
            モノポル公式
            $$$_auto_02:サシライブでは、あなたの映像は映りません。映像が映るのはストリーマーのみです。
            */
            /**********************************************/
        }else{
            //絆レベル課金ポイントのボーナス比率など相手との情報を取得
            var stringUrl = Util.URL_GET_CONNECT_LEVEL_BY_USERID
            stringUrl.append("?user_id=")
            stringUrl.append(liveCastId)
            stringUrl.append("&my_user_id=")
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
                        let decoder = JSONDecoder()
                        //受けとったJSONデータをパースして格納
                        let json = try decoder.decode(ResultConnectJson.self, from: data!)
                        //self.idCount = json.count
                        
                        //ただしゼロ番目のみ参照可能
                        for obj in json.result {
                            
                            //データが取得できなかった場合を考慮
                            if(obj.level == "" || obj.level == "0"){
                                UserDefaults.standard.set("1", forKey: "sendConnectLevel")
                            }else{
                                UserDefaults.standard.set(obj.level, forKey: "sendConnectLevel")
                            }
                            
                            if(obj.bonus_rate == "" || obj.bonus_rate == "0"){
                                UserDefaults.standard.set("1.0", forKey: "sendConnectBonusRate")
                            }else{
                                UserDefaults.standard.set(obj.bonus_rate, forKey: "sendConnectBonusRate")
                            }
                            
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
                //skywayの待機処理(一度待機状態へ)
                self.setup()
                
                //メッセージの初期化
                self.messages.removeAll()
                //self.getChatRirekiByUser()

                //最下部にタブバーを表示
                self.setTabBar()
            }
        }

        /*
        //リスナーがタスクキルした場合などに実行
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(taskKill),
            name:UIApplication.willTerminateNotification,
            object: nil)
         */
    }

    //@objc func taskKill(){
    //}
    
    deinit {
        // 画面が破棄された時に監視をやめる
        if let observers = observers {
            self.center.removeObserver(observers.player)
            self.center.removeObserver(observers.willEnterForeground)
            //observers.bounds.invalidate()
            
            //self.playerArray[indexPath.row].removeObserver(self, forKeyPath: "rate")
        }

        self.player.replaceCurrentItem(with: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //完全に遷移が行われ、スクリーン上からViewControllerが表示されなくなったときに呼ばれる。
        super.viewDidDisappear(animated)
        
        //一旦全て停止
        if(self.player.rate != 0 && self.player.error == nil){
            self.player.pause()
            //self.appDelegate.castMoviePlayerNum = 1
        }
        
        self.player.replaceCurrentItem(with: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //何か文字の入力があれば、sendBtnの画像を変更するsend_ico_off＞send_ico_on
        //print(textView.text)
        let strTemp = textView.text
        
        var frame = textView.frame
        frame.size.height = textView.contentSize.height
        //textView.frame = frame

        //元々のyの座標が13
        textView.frame = CGRect(x: textView.frame.minX, y: 13 + 30 - textView.contentSize.height, width: textView.frame.width, height: textView.contentSize.height)
        //self.sendTextView.frame.size.height = textView.contentSize.height + 26
        
        if(strTemp == ""){
            let picture = UIImage(named: "send_ico_off")
            self.sendBtn.setImage(picture, for: .normal)
            //チャットログを最前面に
            self.fullView.bringSubviewToFront(self.messageTableView)
        }else{
            let picture = UIImage(named: "send_ico_on")
            self.sendBtn.setImage(picture, for: .normal)
            //入力のところを最前面に
            self.fullView.bringSubviewToFront(self.keyboardScrollView)
        }
    }
    
    //20201122 リフレッシュ機能を一旦廃止
    //画面をリフレッシュ＝Skywayの接続をし直す。(リスナーのみの機能)
    @IBAction func refreshBtnAction(_ sender: Any) {

        /*
        //ラベル作成
        self.castSelectedDialog.infoLbl.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:0)
        // テキストを中央寄せ
        self.castSelectedDialog.infoLbl.attributedText = UtilFunc.getInsertIconString(string: "画面をリフレッシュしています。", iconImage: UIImage(), iconSize: self.iconSize, lineHeight: 1.5)
        //self.infoLbl.textAlignment = NSTextAlignment.center
        self.castSelectedDialog.infoLbl.font = UIFont.boldSystemFont(ofSize: 15)
        self.castSelectedDialog.infoLbl.sizeToFit()
        self.castSelectedDialog.infoLbl.center = self.castSelectedDialog.center
        self.castSelectedDialog.closeBtn.isHidden = true
        //最前面へ
        self.castSelectedDialog.infoLbl.isHidden = false
        self.castSelectedDialog.bringSubviewToFront(self.castSelectedDialog.infoLbl)
        //ラベル作成(ここまで)
        
        self.castSelectedDialog.isHidden = false
        //self.view.bringSubviewToFront(self.castSelectedDialog)
        self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialog)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print(self.liveCastId)
            self.call(targetPeerId: self.liveCastId)
        }
        
        self.send(text: "画面リフレッシュ")
        */
    }
    
    //ストリーマーのエフェクトのチェック
    //GET: cast_id
    func effectCheckDo(cast_id:Int){
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
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultEffectJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        self.effect_id = Int(obj.effect_flg01)!
                        //let strEffectFlg02 = obj.effect_flg02
                        //let strEffectFlg03 = obj.effect_flg03
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
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
            
            if(self.effect_id_before == self.effect_id){
                //直前のFLGから変更がない場合は、何もしない
            }else{
                self.effectDo(effect_id: self.effect_id)
                //連続して行われるのを防ぐため
                self.effect_id_before = self.effect_id
            }
        }
    }
    
    @objc func timerInterruptUser(_ timer:Timer){
        //5秒おきにキャストのエフェクトの確認・テーブルのリロード
        //変更があればエフェクトを変更
        if(CGFloat(self.appDelegate.count).truncatingRemainder(dividingBy: 5.0) == 0){
            self.effectCheckDo(cast_id:Int(self.liveCastId)!)
            //テーブルのリロード
            self.messageTableView.reloadData()
        }

        //count(経過時間)に+1していく
        self.appDelegate.count += 1
        var strLiveTime = ""
        
        if(self.appDelegate.count < 60){
            //countDownLabel.text = "Live:0:" + timerString
            strLiveTime = NSString(format: "Live:0:%02d", self.appDelegate.count) as String
        //}else if(count < 10){
        //    countDownLabel.text = "Live:0:0" + timerString
        }else{
            //let timerString = formatter.string(from: Double(count))!
            strLiveTime = "Live:" + formatter.string(from: Double(self.appDelegate.count))!
        }
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.countDownLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-2 ,string: strLiveTime, iconImage: UIImage(named:"live")!, iconSize: self.iconSize)
        
        //持っているコイン数のチェック
        /*
         ログを出すタイミングは、
         コイン残りが
         104（約8分）
         65（約5）
         26（約2分）
         このメッセージを出すときは、チャットを強制オンに。
         */
        let coin_count:Double = UserDefaults.standard.double(forKey: "myPoint")
        
        //2分に必要なコイン
        let coin_2minute:Double = Double(self.appDelegate.live_pay_coin) * 2
        let coin_5minute:Double = Double(self.appDelegate.live_pay_coin) * 5
        let coin_8minute:Double = Double(self.appDelegate.live_pay_coin) * 8
        
        if(self.appDelegate.live_pay_coin > 0 || self.appDelegate.live_pay_ex_coin > 0){
            //if(coin_count <= self.appDelegate.live_pay_coin){
            if(coin_count <= coin_2minute && self.nocoinFlg_26 == 0){
                //コインが少なくなってきた
                self.sendNocoin(coin: Int(coin_2minute))
                
                self.nocoinFlg_26 = 1//1:すでにチャットログに警告を流した
                self.nocoinFlg_65 = 1//1:すでにチャットログに警告を流した
                self.nocoinFlg_104 = 1//1:すでにチャットログに警告を流した
                
                //オフ＞オン
                self.messageTableView.isHidden = false
                //self.castWaitDialog.bringSubview(toFront: self.castWaitDialog.downLiveInfoTableView)
                //オンにする
                self.liveTimelineFlg = 1
                //画像のオン・オフの切り替えのためいったん削除し、タブメニューを再作成する。
                self.myTabBar.removeFromSuperview()
                self.setTabBar()
                
                //最前面に表示
                self.view.bringSubviewToFront(self.messageTableView)
                
            }else if(coin_count <= coin_5minute && self.nocoinFlg_65 == 0){
                //コインが少なくなってきた
                self.sendNocoin(coin: Int(coin_5minute))
                
                self.nocoinFlg_26 = 0//1:すでにチャットログに警告を流した
                self.nocoinFlg_65 = 1//1:すでにチャットログに警告を流した
                self.nocoinFlg_104 = 1//1:すでにチャットログに警告を流した
                
                //オフ＞オン
                self.messageTableView.isHidden = false
                //self.castWaitDialog.bringSubview(toFront: self.castWaitDialog.downLiveInfoTableView)
                //オンにする
                self.liveTimelineFlg = 1
                //画像のオン・オフの切り替えのためいったん削除し、タブメニューを再作成する。
                self.myTabBar.removeFromSuperview()
                self.setTabBar()
                
                //最前面に表示
                self.view.bringSubviewToFront(self.messageTableView)
                
            }else if(coin_count <= coin_8minute && self.nocoinFlg_104 == 0){
                //コインが少なくなってきた
                self.sendNocoin(coin: Int(coin_8minute))
                
                self.nocoinFlg_26 = 0//1:すでにチャットログに警告を流した
                self.nocoinFlg_65 = 0//1:すでにチャットログに警告を流した
                self.nocoinFlg_104 = 1//1:すでにチャットログに警告を流した
                
                //オフ＞オン
                self.messageTableView.isHidden = false
                //self.castWaitDialog.bringSubview(toFront: self.castWaitDialog.downLiveInfoTableView)
                //オンにする
                self.liveTimelineFlg = 1
                //画像のオン・オフの切り替えのためいったん削除し、タブメニューを再作成する。
                self.myTabBar.removeFromSuperview()
                self.setTabBar()
                
                //最前面に表示
                self.view.bringSubviewToFront(self.messageTableView)
                
            }else{
                //コインはまだ十分にある
                //フラグの初期化
                if(coin_count > coin_2minute){
                    self.nocoinFlg_26 = 0//1:すでにチャットログに警告を流した
                }
                if(coin_count > coin_5minute){
                    self.nocoinFlg_65 = 0//1:すでにチャットログに警告を流した
                }
                if(coin_count > coin_8minute){
                    self.nocoinFlg_104 = 0//1:すでにチャットログに警告を流した
                }
            }
        }

        //コイン消費処理
        if(self.appDelegate.count < self.appDelegate.init_seconds){
            //通常枠内
            //何もしない
        }else{
            if((self.appDelegate.count - self.appDelegate.init_seconds) % Util.INIT_EX_UNIT_SECONDS == 0){
                /*
                 //ストリーマーが得られるポイント(最初の5分枠で得られるポイント)
                 self.appDelegate.get_live_point = self.get_live_point
                 //延長時ストリーマーが得られるポイント
                 self.appDelegate.ex_get_live_point = self.ex_get_live_point
                 //消費するコイン
                 self.appDelegate.live_pay_coin = self.live_coin
                 //消費するコイン(延長時)
                 self.appDelegate.live_pay_ex_coin = self.live_ex_coin
                 */
                //持っているコインで、延長が可能な場合
                print("----(３０秒ごとに延長時)必要なコインの確認----")
                print("----get_live_point----")
                print(self.appDelegate.get_live_point)
                print("----ex_get_live_point----")
                print(self.appDelegate.ex_get_live_point)
                print("----live_pay_coin----")
                print(self.appDelegate.live_pay_coin)
                print("----live_ex_coin----")
                print(self.appDelegate.live_pay_ex_coin)
                print("----コインの確認(ここまで)----")
                
                if(Double(coin_count) >= self.appDelegate.live_pay_ex_coin){
                    //持っているコインで、延長(60秒)が可能な場合
                    //コインの消費処理(60秒の延長分のコインを消費)
                    /**********************************************/
                    //ポイント・コインなどの計算(延長時)
                    /**********************************************/
                    //コイン消費履歴に履歴を保存する(8:延長で消費したコイン)
                    //かつ、延長1回分のコインを消費
                    UtilFunc.writePointUseRirekiType58(type:8,
                                                 point:self.appDelegate.live_pay_ex_coin,
                                                 user_id:self.user_id,
                                                 target_user_id:Int(self.liveCastId)!)
                    
                    //配信レベルの処理（１コインにつき１配信経験値）
                    //let live_point_temp:Int = Int(self.appDelegate.live_pay_ex_coin) * Util.LIVE_POINT_GET
                    let live_point_temp:Int = Util.LIVE_POINT_GET_ONE
                    
                    //（ストリーマーの）スターの追加処理＞ストリーマー側へ通知する
                    self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE
                        + "/"
                        + self.liveCastId + "/" + String(self.user_id))
                    self.conditionRef.updateChildValues(["cast_add_star": self.appDelegate.ex_get_live_point, "cast_add_point": live_point_temp])
                    
                    //絆レベルの更新
                    //取得する絆レベルの経験値（１コインにつき１経験値）
                    let exp_temp:Int = Int(self.appDelegate.live_pay_ex_coin) * Util.CONNECTION_POINT_LIVE
                    
                    //絆レベルの更新・追加(更新後に何も処理をしない場合に使用)
                    //flg:1:値プラス、2:値マイナス
                    UtilFunc.saveConnectLevelNew(user_id:self.user_id, target_user_id:Int(self.liveCastId)!, exp:exp_temp, live_count:0, present_point:0, flg:1)
                    
                    let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")
                    
                    //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
                    UtilFunc.savePairMonthRanking(user_id:self.user_id, cast_id:Int(self.liveCastId)!, exp:Int(self.appDelegate.live_pay_ex_coin * strConnectBonusRate))
                    
                    //絆レベルなど相手との情報を取得
                    UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:Int(self.liveCastId)!)
                    //self.getConnectInfo()
                    
                    /**********************************************/
                    //ポイント・コインなどの計算ここまで(延長時)
                    /**********************************************/
                }else{
                    //コインが足りない場合
                    //そのまま終了
                    /*************共通で使用******************/
                    //バツボタンを押したフラグを立てる(復帰はできないようにするための対策)
                    self.appDelegate.listener_live_close_btn_tap_flg = 1
                    
                    //監視の解放
                    self.conditionRef.removeObserver(withHandle: self.handle)
                    
                    //初期化
                    //self.appDelegate.request_count_num = 0//動画再生画面を含むこの画面を何回タップしたか。
                    self.appDelegate.request_password = "0"
                    self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
                    
                    self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE
                        + "/"
                        + self.liveCastId + "/" + String(self.user_id))
                    let data = ["status_listener": 4]
                    self.conditionRef.updateChildValues(data)
                    /**************共通で使用ここまで*****************/
                }
            }
        }
    }

    //コインの比較・コインが足りない場合のダイアログ表示
    func checkCoinDo(pay_coin: Int) {
        //所有しているコイン
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        
        if(pay_coin > 0 && Int(myPoint) < pay_coin){
            //コインが足りない場合
            Util.userPurchasePlanDialog.isHidden = false
            Util.userPurchasePlanDialog.mainView.isHidden = false
            Util.userPurchasePlanDialog.purchasePlanMainView.isHidden = true
            Util.userPurchasePlanDialog.notesView.isHidden = true
            
            self.view.bringSubviewToFront(Util.userPurchasePlanDialog)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //バックグラウンドなどではなく、違う画面に遷移したときにだけ実行される。（1度のみ実行）
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //1:通常、2:自動応答のどれを選んでいるか。
        let selectedStreamerAuto = UserDefaults.standard.integer(forKey: "selectedStreamerAuto")
        
        if(selectedStreamerAuto == 2){
            //自動応答の場合
            //何もしない
        }else{
            //ライブ配信終了へ
            self.closeMedia()
            self.sessionClose()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        UtilLog.printf(str:"MediaConnectionController - MemoryWarning")
    }

    func getCastInfo(){
        //モデル詳細取得
        var stringUrl = Util.URL_USER_INFO
        stringUrl.append("?user_id=")
        stringUrl.append(liveCastId)
        stringUrl.append("&my_user_id=")
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
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultJson.self, from: data!)
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
                        self.strTwitter = obj.twitter
                        self.strFacebook = obj.facebook
                        self.strInstagram = obj.instagram
                        self.strHomepage = obj.homepage
                        self.strFreetext = obj.freetext
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
        }
    }
    
    func getProductList(){
        let firstFlg01Temp = UserDefaults.standard.integer(forKey: "first_flg01")
        
        //クリアする
        self.productListTemp.removeAll()
        
        //有効な商品IDを取得(ポイント順)
        let stringUrl = Util.URL_PRODUCT_LIST+"?status=1&order=0";
        
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
                    let json = try decoder.decode(ResultProductJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strProductId = obj.product_id
                        let strAppleId = obj.apple_id
                        let strReferenceName = obj.reference_name
                        let intPrice = obj.price
                        let intPoint = obj.point
                        let strValue01 = obj.value01
                        let strValue02 = obj.value02
                        let strValue03 = obj.value03
                        
                        if(strValue03 == "1" && firstFlg01Temp == 1){
                            //初回のみ購入可能をすでに購入済
                        }else{
                            //配列へ追加
                            let product = (strProductId,strAppleId,strReferenceName,intPrice,intPoint,strValue01,strValue02,strValue03)
                            self.productList.append(product)
                            self.productListTemp.append(product)
                        }
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
            //コピーする
            self.productList = self.productListTemp
            
            //リストの取得を待ってから更新
            Util.userPurchasePlanDialog.productTableView.reloadData()
        }
    }
    
    func getPresentList(){
        //クリアする
        self.presentListTemp.removeAll()
        //リスト取得
        //var stringUrl = Util.URL_GET_PRESENT_LIST
        //stringUrl.append("?order=1&status=1")
        var stringUrl = Util.URL_GET_PRESENT_LIST_BY_USERID_FOR_LIVE
        stringUrl.append("?order=1&status=0&user_id=")
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
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(UtilStruct.ResultPresentJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        //配列へ追加
                        let present = (obj.present_id
                            ,obj.present_name
                            ,obj.coin
                            ,obj.star
                            ,obj.live_point
                            ,obj.photo_flg
                            ,obj.status
                            ,obj.present_count)
                        self.presentList.append(present)
                        self.presentListTemp.append(present)
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
            //コピーする
            self.presentList = self.presentListTemp
            
            //リストの取得を待ってから更新
            self.userPresentListDialog.presentListCollectionView.reloadData()
        }
    }
    
    @IBAction func tapSend(){
        guard let text = self.sendTextEditView.text else{
            return
        }
        self.view.endEditing(true)
        //appDelegate.hymDataConnection.send(text: text)
        self.send(text: text)
        //self.messageTableView.reloadData()
        self.sendTextEditView.text = nil
        //self.sendTextEditView.reloadInputViews()
        
        //テキストフィールドが空になったので、ボタンも変更
        let picture = UIImage(named: "send_ico_off")
        self.sendBtn.setImage(picture, for: .normal)
        
        //チャットログを最前面に
        self.fullView.bringSubviewToFront(self.messageTableView)
        
        //サイズを改行する前に元に戻す
        //元々のyの座標が13
        self.sendTextEditView.frame = CGRect(x: self.sendTextEditView.frame.minX, y: 13, width: self.sendTextEditView.frame.width, height: 30)
    }

    @IBAction func tapEndCall(){
        print("end call")
        self.closeAlert()
    }

    //切断ボタンが押されるとこの関数が呼ばれる
    func closeAlert(){
        //UIAlertControllerを用意する
        let actionAlert = UIAlertController(title:"ライブ配信の視聴を終了しますか?"
            , message: "終了した場合、時間が残っている場合でも戻ることは出来ません。"
            , preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "視聴を終了する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            /*************共通で使用******************/
            //バツボタンを押したフラグを立てる(復帰はできないようにするための対策)
            self.appDelegate.listener_live_close_btn_tap_flg = 1

            //1:通常、2:自動応答のどれを選んでいるか。
            let selectedStreamerAuto = UserDefaults.standard.integer(forKey: "selectedStreamerAuto")
            
            if(selectedStreamerAuto == 2){
                //自動応答の場合
                
                self.endLiveDoAuto()
                
            }else{
                //通常ライブ配信の場合
                //監視の解放
                self.conditionRef.removeObserver(withHandle: self.handle)
                
                //初期化
                //self.appDelegate.request_count_num = 0//動画再生画面を含むこの画面を何回タップしたか。
                self.appDelegate.request_password = "0"
                self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
                
                self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE
                    + "/"
                    + self.liveCastId + "/" + String(self.user_id))
                let data = ["status_listener": 3]
                self.conditionRef.updateChildValues(data)
            }
            /**************共通で使用ここまで*****************/
        })
        actionAlert.addAction(modifyAction)

        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelAction = UIAlertAction(title: "視聴を続ける", style: UIAlertAction.Style.cancel, handler: {
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

    //復帰時にキャストがすでにいない場合にもコールされる（終了処理の共通部分）
    func endLiveDoCommon(){
        //初期化
        //self.appDelegate.request_count_num = 0//動画再生画面を含むこの画面を何回タップしたか。
        self.appDelegate.request_password = "0"
        self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
        
        self.detachRemoteVideo()
        self.remoteVideoStream = nil
        self.remoteAudioStream = nil
        self.remoteDataStream = nil
        self.roomPublications.removeAll()
        self.roomSubscriptions.removeAll()
        
        print("close 通話")
        
        //キーボード対応
        //self.removeObserver() // Notificationを画面が消えるときに削除
        
        //タイマーの経過時間を初期化
        self.countDownLabel.isHidden = true
        
        //監視を解放する(firebaseのオブザーバーの解放)
        self.conditionRef.removeObserver(withHandle: self.handle)
    }
    
    //ライブ配信終了の時に呼ぶ
    func endLiveDo(){
        
        self.endLiveDoCommon()
        
        //ライブ終了ダイアログ(ダイアログを重ねる)
        let endLiveDialog:EndLiveDialog = UINib(nibName: "EndLiveDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! EndLiveDialog
        //画面サイズに合わせる(selfでなく、superviewにすることが重要)
        endLiveDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(endLiveDialog)
        //2秒後に画面遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 2.0秒後に実行したい処理
            //タイマー停止
            UtilFunc.stopTimer(timer:self.timerUser)
            //トップ画面へ
            UtilToViewController.toMainViewController()
        }
    }
    
    //ライブ配信終了の時に呼ぶ（自動応答ストリーマー用）
    func endLiveDoAuto(){

        //初期化
        //self.appDelegate.request_count_num = 0//動画再生画面を含むこの画面を何回タップしたか。
        self.appDelegate.request_password = "0"
        self.appDelegate.request_cast_id = 0//選択中（かつ申請中）のキャスト
        
        //タイマーの経過時間を初期化
        self.countDownLabel.isHidden = true

        //ライブ終了ダイアログ(ダイアログを重ねる)
        let endLiveDialog:EndLiveDialog = UINib(nibName: "EndLiveDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! EndLiveDialog
        //画面サイズに合わせる(selfでなく、superviewにすることが重要)
        endLiveDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(endLiveDialog)
        //2秒後に画面遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 2.0秒後に実行したい処理
            //タイマー停止
            UtilFunc.stopTimer(timer:self.timerUser)
            //トップ画面へ
            UtilToViewController.toMainViewController()
        }
    }

    /*
     ライブ視聴時のメニュー
     ・タイムライン
     ・キャスト情報の表示
     ・スクショリクエスト
     ・シェア
     ・プレゼントを送信
     */
    func setTabBar(){
        //let width = self.view.frame.width
        //let height = self.view.frame.height
        //デフォルトは49
        //let tabBarHeight:CGFloat = Util.TAB_BAR_HEIGHT
        
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
        
        //選択中・未選択状態の切り替えもここで
        //ボタンを生成(タイムライン)
        let timelineBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"lm_ico_off"), tag: 1)
        timelineBtn.image = UIImage(named: "lm_ico_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //timelineBtn.selectedImage = UIImage(named: "lm_ico_on")
        //選択中の時
        if(self.liveTimelineFlg == 1){
            timelineBtn.image = UIImage(named: "lm_ico_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        
        //ボタンを生成(キャスト情報の表示)
        let castInfoBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"live_info_off"), tag: 2)
        castInfoBtn.image = UIImage(named: "live_info_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //castInfoBtn.selectedImage = UIImage(named: "live_info_on.png")

        /*
        //ボタンを生成(スクショリクエスト)＞機能廃止
        let screenshotReqBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"camera_off"), tag: 3)
        screenshotReqBtn.image = UIImage(named: "camera_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //screenshotReqBtn.selectedImage = UIImage(named: "camera_on.png")
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //ここだけ特別な処理(ダイアログを被せるため)
        //screenshotReqBtn.selectedImage = UIImage(named: "camera_on")
        */
        
        //ボタンを生成(シェア)
        let shareBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"share_ico_off"), tag: 4)
        shareBtn.image = UIImage(named: "share_ico_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //shareBtn.selectedImage = UIImage(named: "share_ico_on")
        
        //ボタンを生成(プレゼントを送信)
        let presentBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"lm_gift_ico_off"), tag: 5)
        presentBtn.image = UIImage(named: "lm_gift_ico_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //presentBtn.selectedImage = UIImage(named: "lm_gift_ico_off")
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //presentBtn.selectedImage = UIImage(named: "lm_gift_ico_on")
        
        //選択中・未選択状態の切り替えもここで(ここまで)
        /***********************************************************/
        /***********************************************************/

        //ボタンをタブバーに配置する
        //myTabBar.items = [timelineBtn,castInfoBtn,screenshotReqBtn,shareBtn,presentBtn]
        myTabBar.items = [timelineBtn,castInfoBtn,shareBtn,presentBtn]
        //デリゲートを設定する
        myTabBar.delegate = self
        
        //画像位置をtabbarの高さ中央に配置
        let insets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        myTabBar.items![0].imageInsets = insets
        myTabBar.items![1].imageInsets = insets
        myTabBar.items![2].imageInsets = insets
        myTabBar.items![3].imageInsets = insets
        //myTabBar.items![4].imageInsets = insets
        
        //区切り線
        myTabBar.shadowImage = UIImage.colorForTabBar(color: UIColor.clear)
        //myTabBar.backgroundImage = UIImage() //0x0のUIImage
        
        //バーの色
        self.myTabBar.isOpaque = false // 不透明を false
        //self.myTabBar.barTintColor = Util.DOWN_TABBAR_COLOR//黒の半透明
        self.myTabBar.barTintColor = UIColor.clear//透明
        //self.myTabBar.tintColor = UIColor.clear//透明
        //サイズは引き延ばされるため適当
        self.myTabBar.backgroundImage = UtilFunc.toumeiImage(size: CGSize(width:30, height:10))
        
        self.view.addSubview(myTabBar)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag{
        case 1:
            self.autoUserTabDialog.isHidden = true
            //self.userShareDialog.isHidden = true
            self.userPresentListDialog.isHidden = true
            //self.userPurchasePlanDialog.isHidden = true
            //タイムライン
            if(self.liveTimelineFlg == 0){
                //オフ＞オン
                self.messageTableView.isHidden = false
                //self.castWaitDialog.bringSubview(toFront: self.castWaitDialog.downLiveInfoTableView)
                //オンにする
                self.liveTimelineFlg = 1
            }else{
                //オン＞オフ
                self.messageTableView.isHidden = true
                //オフにする
                self.liveTimelineFlg = 0
            }
            
            //画像のオン・オフの切り替えのためいったん削除し、タブメニューを再作成する。
            self.myTabBar.removeFromSuperview()
            self.setTabBar()
            
        case 2:
            self.autoUserTabDialog.isHidden = true
            //self.userShareDialog.isHidden = true
            self.userPresentListDialog.isHidden = true
            //self.userPurchasePlanDialog.isHidden = true
            //キャスト情報の表示
            self.castInfoDialog.setValue()
            self.castInfoDialog.isHidden = false
            self.view.bringSubviewToFront(self.castInfoDialog)

        /*
        case 3:
            //self.userShareDialog.isHidden = true
            self.userPresentListDialog.isHidden = true
            //self.userPurchasePlanDialog.isHidden = true
            //スクショリクエスト
            let actionAlert = UIAlertController(title: "スクショをリクエストしますか？(消費コイン:" + String(Int(Util.SCREENSHOT_PAY_COIN)) + ")", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "リクエストする", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //所有しているコイン
                let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
                
                if(myPoint < Util.SCREENSHOT_PAY_COIN){
                    //コインが足りない場合
                    Util.userPurchasePlanDialog.isHidden = false
                    Util.userPurchasePlanDialog.mainView.isHidden = false
                    Util.userPurchasePlanDialog.purchasePlanMainView.isHidden = true
                    Util.userPurchasePlanDialog.notesView.isHidden = true
                    
                    self.view.bringSubviewToFront(Util.userPurchasePlanDialog)
                }else{
                    //スクショをリクエストしました。
                    //self.appDelegate.hymDataConnection.sendStamp(text: "$$$_screenshot_request")
                    self.sendStamp(text: "$$$_screenshot_request")
                    self.messageTableView.reloadData()
                    
                    let data = ["request_screenshot_flg": 1]
                    self.conditionRef.updateChildValues(data)
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
            
        case 4:
            //1:通常、2:自動応答のどれを選んでいるか。
            let selectedStreamerAuto = UserDefaults.standard.integer(forKey: "selectedStreamerAuto")
            if(selectedStreamerAuto == 2){
                //自動応答の場合
                self.autoUserTabDialog.isHidden = false
                self.userPresentListDialog.isHidden = true
                
                self.autoUserTabDialog.mainImageView.image = UIImage(named:"auto_share")
                
            }else{
                self.userPresentListDialog.isHidden = true
                //シェア関連のダイアログ
                //self.userShareDialog.isHidden = false//表示
                UtilFunc.shareDo(parentVC: self, parentView: self.view, url:UtilStr.SHARE_URL, str01: UtilStr.SHARE_STR01, str02:UtilStr.SHARE_STR02)
            }
            
        case 5:
            //1:通常、2:自動応答のどれを選んでいるか。
            let selectedStreamerAuto = UserDefaults.standard.integer(forKey: "selectedStreamerAuto")
            if(selectedStreamerAuto == 2){
                //自動応答の場合
                self.autoUserTabDialog.isHidden = false
                self.userPresentListDialog.isHidden = true
                
                self.autoUserTabDialog.mainImageView.image = UIImage(named:"auto_present")
                
            }else{
                //ラベルの枠を自動調節する
                self.userPresentListDialog.presentListTitleLabel.adjustsFontSizeToFitWidth = true
                self.userPresentListDialog.presentListTitleLabel.minimumScaleFactor = 0.3
                
                self.userPresentListDialog.presentListTitleLabel.text = UtilFunc.strMin(str:self.appDelegate.request_cast_name!, num:Util.NAME_MOJI_COUNT_SMALL) + Util.PRESENT_LIST_DIALOG_TITLE_STR
                
                //所有しているコインの設定
                let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
                self.userPresentListDialog.presentListCoinLabel.text = "コイン " + UtilFunc.numFormatter(num: Int(myPoint))
                
                self.getProductList()
                self.getPresentList()
                self.userPresentListDialog.isHidden = false
            }
            
        default : return
        }
    }
}

// MARK: UITableViewDelegate UITableViewDataSource
extension MediaConnectionViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(tableView.tag == 11){
            return 5 // セルの下部のスペース
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if(tableView.tag == 11){
            view.tintColor = UIColor.clear // 透明にすることでスペースとする
        }else{
            view.tintColor = UIColor.clear // 透明にすることでスペースとする
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 11){
            return 1 // 普通はここで表示したいセルの数を返すが、セクションのヘッダーとフッターでスペーシングしているので、固定で1を返す
        }else if(tableView.tag == 99){
            //商品リストの総数
            return self.productList.count
        }else{
            return 0
        }
    }
    
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView.tag == 11){
            //return appDelegate.hymDataConnection.messages.count
            //return self.messages.count + self.chatRirekiList.count
            return self.messages.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView.tag == 11){
            //チャットテーブル
            //let rowCount = indexPath.section - self.chatRirekiList.count
            let rowCount = indexPath.section
            
            //表示する1行を取得する
            //let text_temp: String = appDelegate.hymDataConnection.messages[rowCount].text!
            let text_temp: String = self.messages[rowCount].text!
            
            //念の為、再度取得（ライブ開始時に取得してある）
            let photoName = UserDefaults.standard.string(forKey: "myPhotoName")

            //$$$から始まる文字列はスタンプとする
            if(text_temp.hasPrefix("$$$_stamp_")){
                let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChatPhoto") as! LiveChatPhotoViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                
                //ユーザー画像の表示
                if(self.my_photo_flg == 1){
                    //写真設定済み
                    //let photoUrl = "user_images/" + String(self.user_id) + "_profile.jpg"
                    let photoUrl = "user_images/" + String(self.user_id) + "/" + photoName! + "_profile.jpg"

                    //画像キャッシュを使用
                    cell.liveChatImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                    
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    cell.liveChatImageView.image = cellImage
                }
                
                //ユーザー(自分)の名前
                let myName = UserDefaults.standard.string(forKey: "myName")
                cell.nameLabel?.text = UtilFunc.strMin(str:myName!, num:Util.NAME_MOJI_COUNT_BIG)
                
                //スタンプ(プレゼント画像)の設定
                //let str = "$$$_stamp_"
                let stamp_id = String(text_temp.suffix(text_temp.count - 10))
                let photoUrl = "present_images/" + stamp_id + ".png"
                print(photoUrl)
                cell.sendImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"901")
                
                return cell
                
            //$$$_auto_から始まる文字列は運営からとする
            /*
            モノポル公式
            $$$_auto_01:このサシライブはテスト用の自動映像です。サシライブの機能を試してみることができます。
            ▼▼▼5秒後に以下を表示
            モノポル公式
            $$$_auto_02:サシライブでは、あなたの映像は映りません。映像が映るのはストリーマーのみです。
            */
            }else if(text_temp.hasPrefix("$$$_auto_")){
                let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChat") as! LiveChatViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                
                //モノポル公式画像の表示
                // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                let cellImage = UIImage(named: "monopol_office")
                // UIImageをUIImageViewのimageとして設定
                cell.liveChatImageView.image = cellImage
                
                if(text_temp == "$$$_auto_01"){
                    //cell.textView?.text = appDelegate.hymDataConnection.messages[rowCount].text
                    cell.textView?.text
                        = "このサシライブはテスト用の自動映像です。サシライブの機能を試してみることができます。"
                }else if(text_temp == "$$$_auto_02"){
                    //cell.textView?.text = appDelegate.hymDataConnection.messages[rowCount].text
                    cell.textView?.text
                        = "サシライブでは、あなたの映像は映りません。映像が映るのはストリーマーのみです。"
                }
                
                cell.nameLabel?.text = "モノポル公式"
                
                return cell
                
            //$$$から始まる文字列はスタンプとする
            }else if(text_temp.hasPrefix("$$$_nocoin_")){
                let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChatNocoin") as! LiveChatNocoinViewCell
                cell.clipsToBounds = true //bound外のものを表示しない

                //足りないコイン数、分数の設定
                //let str = "$$$_nocoin_"
                //1分あたりの消費コイン＝self.appDelegate.live_pay_coin
                let coin_count = String(text_temp.suffix(text_temp.count - 11))
                
                //var intNum: Int = str.toInt()!
                let minute_temp = Int(coin_count)! / Int(self.appDelegate.live_pay_coin)
                    //floor(Double(coin_count) / Double(self.appDelegate.live_pay_coin))
                
                //残りの通話時間(切り捨て)
                let minute_count = String(Int(floor(Double(minute_temp))))
                
                //最後に３文字ほど空文字を入れる。NSMakeRangeを使用するため
                let sub_before_text = "コインの残高が" + String(coin_count)
                    + "(約" + minute_count + "分)   \n以下になりました。"
                // 文字列から、attributedStringを作成します.
                let attr_sub_before_text = NSMutableAttributedString(string: sub_before_text)

                // フォントカラーを設定します.
                // rangeで該当箇所を指定します(多めに10文字分)
                attr_sub_before_text.addAttribute(.foregroundColor,
                                                  value: Util.COIN_FUSOKU_TEXT_COLOR,
                                                  range: NSMakeRange(7, 9))

                let sub_after_text = "\nコインが不足するとサシライブは終了します。コインを購入してサシライブを延長しますか？"
                let attr_sub_after_text = NSMutableAttributedString(string: sub_after_text)
                
                attr_sub_before_text.append(attr_sub_after_text)
                
                // attributedTextとしてUILabelに追加します.
                cell.subLabel.attributedText = attr_sub_before_text
                
                //モノポル公式画像の表示
                // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                let cellImage = UIImage(named: "monopol_office")
                // UIImageをUIImageViewのimageとして設定
                cell.liveChatImageView.image = cellImage
                
                //ボタンをクリックしたら課金ダイアログを表示
                cell.coinBtn.addTarget(self,action: #selector(onClickNocoinCell(_ :)),for: .touchUpInside)
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "LiveChat") as! LiveChatViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                
                //ユーザー画像の表示
                if(self.my_photo_flg == 1){
                    //写真設定済み
                    //let photoUrl = "user_images/" + String(self.user_id) + "_profile.jpg"
                    let photoUrl = "user_images/" + String(self.user_id) + "/" + photoName! + "_profile.jpg"

                    //画像キャッシュを使用
                    cell.liveChatImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                    
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    cell.liveChatImageView.image = cellImage
                }
                
                //cell.textView?.text = appDelegate.hymDataConnection.messages[rowCount].text
                cell.textView?.text = self.messages[rowCount].text
                
                //ユーザー(自分)の名前
                let myName = UserDefaults.standard.string(forKey: "myName")
                cell.nameLabel?.text = UtilFunc.strMin(str:myName!, num:Util.NAME_MOJI_COUNT_BIG)
                
                return cell
            }
        }else if(tableView.tag == 99){
            //コイン購入プランのテーブル
            //表示する1行を取得する
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell

            // 枠線の色
            cell.productMainView.layer.borderColor = Util.COIN_VIEW_FRAME_COLOR.cgColor
            // 枠線の太さ
            cell.productMainView.layer.borderWidth = 1
            // 角丸
            cell.productMainView?.layer.cornerRadius = 16
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            cell.productMainView?.layer.masksToBounds = true
            
            //cell.messageLabel?.text = appDelegate.hymDataConnection.messages[indexPath.row].text
            //cell.senderLabel?.text = appDelegate.hymDataConnection.messages[indexPath.row].sender.rawValue
            //cell.productNameLabel?.text = appDelegate.productList[indexPath.row].appleId
            cell.productNameLabel?.text = self.productList[indexPath.row].value01
            //ラベルの枠を自動調節する
            cell.productNameLabel?.adjustsFontSizeToFitWidth = true
            cell.productNameLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
            
            // 最後の3文字「コイン」の箇所のフォントを変更
            let intCount = self.productList[indexPath.row].value01.count//文字数
            let attrText = NSMutableAttributedString(string: self.productList[indexPath.row].value01)
            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 12), range: NSMakeRange(intCount - 3, 3))
            cell.productNameLabel.attributedText = attrText
            cell.productNoteLabel?.text = ""
            
            //ラベルの枠を自動調節する
            cell.productNoteLabel?.adjustsFontSizeToFitWidth = true
            cell.productNoteLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
            //cell.productNoteLabel?.textColor = Util.COIN_NOTES_STRING_COLOR
            
            let price: Int = Int(self.productList[indexPath.row].price)!
            cell.purchaseButton?.setTitle("¥ " + String(UtilFunc.numFormatter(num:price)), for: .normal)
            //ラベルの枠を自動調節する
            cell.purchaseButton?.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.purchaseButton?.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
            
            // 角丸
            cell.purchaseButton?.layer.cornerRadius = 8
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            cell.purchaseButton?.layer.masksToBounds = true
            cell.purchaseButton?.backgroundColor = Util.COIN_YEN_BG_COLOR
            cell.purchaseButton?.tag = indexPath.row
            
            //購入するボタンを押した時の処理
            cell.purchaseButton?.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
            return cell
        }else{
            //その他(未使用)
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoContentsCell") as! NoContentsCell
            cell.clipsToBounds = true //bound外のものを表示しない
            return cell
        }
    }
    
    //コイン購入ボタンのセルをタップした時にコイン購入ダイアログを表示（別ファイルのtapCoinPurchaseBtnと似ているので注意）
    //@IBAction func tapCoinPurchaseBtn(_ sender: Any) {
    @objc func onClickNocoinCell(_ sender: Any) {
        //所有しているコインの設定
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        Util.userPurchasePlanDialog.purchasePlanTitleLabel.text = "マイコイン " + UtilFunc.numFormatter(num: Int(myPoint))
        Util.userPurchasePlanDialog.isHidden = false
        Util.userPurchasePlanDialog.productTableView.isHidden = false
        self.view.bringSubviewToFront(Util.userPurchasePlanDialog)
        
        self.getProductList()
        self.getPresentList()
        //Util.userPurchasePlanDialog.productTableView.reloadData()
    }
    
    @objc func onClick(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag

        if(Util.INIT_MODE == 1){
            //テスト用
            /***********************************************************/
            //  カスタムポップアップ
            /***********************************************************/
            let popupView:Popupview = UINib(nibName: "Popupview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Popupview
            // ポップアップビュー背景色
            let viewColor = UIColor.black
            // 半透明にして親ビューが見えるように。透過度はお好みで。
            popupView.backgroundColor = viewColor.withAlphaComponent(0.5)
            // ポップアップビューを画面サイズに合わせる
            popupView.frame = self.view.frame
            popupView.labelSet(name: "テスト用の確認画面のため、課金は発生しません。（リリース後は、Appleが用意したダイアログが表示され、AppleIDを入力します。）")
            
            // ダイアログ背景色（白の部分）
            let baseViewColor = UIColor.white
            // ちょっとだけ透明にする
            popupView.baseView.backgroundColor = baseViewColor.withAlphaComponent(1.0)
            // 角丸にする
            popupView.baseView.layer.cornerRadius = 8.0
            // 貼り付ける
            self.view.addSubview(popupView)
            /***********************************************************/
            /***********************************************************/
            
            self.purchaseDo(pathindex: buttonRow)
            //self.purchaseRirekiDo(pathindex: buttonRow)
            //UUIDを取得
            let user_uid = UIDevice.current.identifierForVendor!.uuidString
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            let product_id = self.productList[buttonRow].productId
            let apple_id = self.productList[buttonRow].appleId
            let price = self.productList[buttonRow].price
            let point = self.productList[buttonRow].point
            UtilFunc.purchaseRirekiDo(user_id: user_id, user_uid: user_uid, product_id: product_id, apple_id: apple_id, price: price, point: point)

            //画面の更新
            //Util.toPurchaseViewController()
            
        }else if(Util.INIT_MODE == 2){
            //本番用
            self.selectedPathIndex = buttonRow
            
            //課金処理
            startPurchase(productIdentifier: self.productList[buttonRow].productId)
        }
    }
    
    //課金後の処理（初回購入のみとその他のプラン共通）
    func commonAfterDo(point:Int){
        //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
        //point更新
        //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
        var myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        var myPointPay:Double = UserDefaults.standard.double(forKey: "myPointPay")
        myPoint = myPoint + Double(point)
        myPointPay = myPointPay + Double(point)
        UserDefaults.standard.set(myPoint, forKey: "myPoint")
        UserDefaults.standard.set(myPointPay, forKey: "myPointPay")
        //self.pointLabel.text = "残りポイント：" + Util.numFormatter(num: myPoint) + "ポイント"

        //各ダイアログに表示しているコイン数を更新
        self.userPresentListDialog.presentListCoinLabel.text = "コイン " + UtilFunc.numFormatter(num: Int(myPoint))
        Util.userPurchasePlanDialog.purchasePlanTitleLabel.text = "マイコイン " + UtilFunc.numFormatter(num: Int(myPoint))
    }
    
    //() -> ()の部分は　(引数) -> (引数の型)を指定
    //func purchaseDo(pathindex:Int, _ after:@escaping () -> Void){
    func purchaseDo(pathindex:Int){
        //リスト取得(自分以外の待機中のリストを取得)
        //UUIDを取得
        //let user_uid = UIDevice.current.identifierForVendor!.uuidString
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let point = self.productList[pathindex].point
        
        //GET:user_id,point,type
        //type 1=有償、2=無料
        var stringUrl = Util.URL_PURCHASE_DO_NEW
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=1&point=")
        stringUrl.append(point)
        
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
                
                if err != nil {
                    // エラー処理
                    //クライアントエラー
                    UtilFunc.logRirekiDo(type:2, user_id:user_id, view_name:"MediaConnectionViewController", value01:err!.localizedDescription)
                    return
                }
                
                guard let data = data, let res = res as? HTTPURLResponse else {
                    //print("no data or no response")
                    UtilFunc.logRirekiDo(type:2, user_id:user_id, view_name:"MediaConnectionViewController", value01:"no data or no response")
                    return
                }

                if res.statusCode == 200 {
                    print(data)
                } else {
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    //print("サーバエラー ステータスコード: \(response.statusCode)\n")
                    UtilFunc.logRirekiDo(type:2, user_id:user_id, view_name:"MediaConnectionViewController", value01:"サーバエラー ステータスコード: \(res.statusCode)")
                    return
                }
                
                do{
                    UtilFunc.logRirekiDo(type:1, user_id:user_id, view_name:"MediaConnectionViewController", value01:"purchaseDook")
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(self.productList[pathindex].value03 == "1"){
                //初回だけ購入可能
                //flg=1:初回購入済
                let user_id = UserDefaults.standard.integer(forKey: "user_id")
                //Util.modifyFirstFlg01(user_id:user_id, flg:1)
                
                var stringUrl = Util.URL_MODIFY_FIRST_FLG01
                stringUrl.append("?user_id=")
                stringUrl.append(String(user_id))
                stringUrl.append("&flg=1")
                print(stringUrl)
                
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
                    //リストの取得を待ってから更新
                    UserDefaults.standard.set("1", forKey: "first_flg01")
                    self.getProductList()
                    self.commonAfterDo(point:Int(point)!)
                }
            }else{
                //初回だけ購入可能以外
                self.commonAfterDo(point:Int(point)!)
            }
        }
    }

    //------------------------------------
    // 課金処理開始
    //------------------------------------
    func startPurchase(productIdentifier : String) {
        print("課金処理開始!!")
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //プロダクト情報を取得
        ProductManager.productsWithProductIdentifiers(productIdentifiers: [productIdentifier], completion: { (products, error) -> Void in
            if (products?.count)! > 0 {
                //課金処理開始
                PurchaseManager.sharedManager().startWithProduct((products?[0])!)
            }
            if (error != nil) {
                print(error as Any)
            }
        })
    }
    
    // リストア開始
    func startRestore() {
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //リストア開始
        PurchaseManager.sharedManager().startRestore()
    }
    
    //------------------------------------
    // MARK: - PurchaseManager Delegate
    //------------------------------------
    //課金終了時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        // TODO UserDefault更新
        self.purchaseDo(pathindex: self.selectedPathIndex)
        //self.purchaseRirekiDo(pathindex: self.selectedPathIndex)
        //UUIDを取得
        let user_uid = UIDevice.current.identifierForVendor!.uuidString
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let product_id = self.productList[self.selectedPathIndex].productId
        let apple_id = self.productList[self.selectedPathIndex].appleId
        let price = self.productList[self.selectedPathIndex].price
        let point = self.productList[self.selectedPathIndex].point
        UtilFunc.purchaseRirekiDo(user_id: user_id, user_uid: user_uid, product_id: product_id, apple_id: apple_id, price: price, point: point)
        
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
        
        //画面の更新
        //Util.toPurchaseViewController()
    }
    
    //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了（指定プロダクトID以外）！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
        
        //画面の更新
        //Util.toPurchaseViewController()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        //let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath)
        let testCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PresentCell", for: indexPath) as! PresentCell
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        //プレゼント画像の表示
        let photoFlg = presentList[indexPath.row].photo_flg
        let present_id = presentList[indexPath.row].present_id
        if(photoFlg == "1"){
            //写真設定済み
            //ゼロ埋め String(format: "%03d", present_id)
            let photoUrl = "present_images/" + present_id + ".png"

            //画像キャッシュを使用
            imageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"901")
        }else{
            let cellImage = UIImage(named:"901")
            // UIImageをUIImageViewのimageとして設定
            imageView.image = cellImage
        }
        
        // Tag番号を使ってLabelのインスタンス生成
        //プレゼントの商品名
        let presentNameLabel = testCell.contentView.viewWithTag(2) as! UILabel
        presentNameLabel.text = presentList[indexPath.row].present_name
        //ラベルの枠を自動調節する
        presentNameLabel.adjustsFontSizeToFitWidth = true
        presentNameLabel.minimumScaleFactor = 0.3
        
        // Tag番号を使ってLabelのインスタンス生成(絆レベル)
        //必要なコイン数
        let coinLabel = testCell.contentView.viewWithTag(3) as! UILabel
        //ラベルの枠を自動調節する
        coinLabel.adjustsFontSizeToFitWidth = true
        coinLabel.minimumScaleFactor = 0.3
        
        //所持している場合は、所持数を表示（ただし無料プレゼントはゼロの時でも所持数を表示）
        if(presentList[indexPath.row].present_count != "0"
            || presentList[indexPath.row].status == "3"){
            coinLabel.text = "所持:" + presentList[indexPath.row].present_count
        }else{
            coinLabel.text = presentList[indexPath.row].coin + "コイン"
        }
        
        //print("table create")
        return testCell
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = self.view.frame.width / 4 - 20
        let height: CGFloat = width + 46
        return CGSize(width: width, height: height)
    }
    
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //リスナーのuser_idを次の画面（キャスト詳細画面）へ渡す
        //appDelegate.sendId = presentList[indexPath.row].id
        //present(modelInfo, animated: true, completion: nil)
        
        //プレゼントを贈る
        //self.showAlert(selectRow:indexPath.row, present_id: presentList[indexPath.row].present_id
        //    ,present_name: presentList[indexPath.row].present_name)
        
        let myPointTemp:Double = UserDefaults.standard.double(forKey: "myPoint")
        
        if(self.presentList[indexPath.row].present_count != "0"
            && self.presentList[indexPath.row].status == "3"){
            //無料プレゼントの場合(所持数がゼロでない場合)
            self.showAlert(type:1, selectRow:indexPath.row)
            
        }else if(self.presentList[indexPath.row].present_count == "0"
            && self.presentList[indexPath.row].status == "3"){
            //無料プレゼントの場合(所持数がゼロの場合)
            //何もしない（押しても反応させない）
        }else{
            if(self.presentList[indexPath.row].present_count != "0"){
                //有料プレゼント(所持数が0でない)
                self.showAlert(type:3, selectRow:indexPath.row)
                
            }else{
                //有料プレゼント(所持数が0 = プレゼント購入)
                if(Int(myPointTemp) >= Int(self.presentList[indexPath.row].coin)!){
                    //コインが足りている場合
                    self.showAlert(type:4, selectRow:indexPath.row)
                }else{
                    //コインが足りない場合
                    self.checkCoinDo(pay_coin: Int(self.presentList[indexPath.row].coin)!)
                }
            }
        }
    }
    
    //ボタンが押されるとこの関数が呼ばれる
    //func showAlert(selectRow: Int, present_id: String, present_name:String){
    //type:1=無料プレゼント 2:無料プレゼント(所持数ゼロ) 3:有料プレゼント 4:有料プレゼント(所持数ゼロ)
    func showAlert(type:Int, selectRow:Int){
        let actionAlert = UIAlertController(title: self.presentList[selectRow].present_name + "を贈りますか?", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "贈る", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            
            //プレゼントを贈る処理
            //self.appDelegate.hymDataConnection.sendStamp(text: "$$$_stamp_" + present_id)
            self.sendStamp(text: "$$$_stamp_" + self.presentList[selectRow].present_id)

            if(type == 4){
                //ライブ配信中に購入してプレゼント
                self.presentAfterCommonDo(type:4, selectRow:selectRow)
            }else if(type == 1){
                //手持ちの無料プレゼントを贈る
                //最も古いプレゼントから贈る
                //GET: user_id, target_user_id, present_id, status
                //status=1:所持 3:送信済み
                var stringUrl = Util.URL_MODIFY_PRESENT_STATUS
                stringUrl.append("?user_id=")
                stringUrl.append(String(self.user_id))
                stringUrl.append("&target_user_id=")
                stringUrl.append(String(self.appDelegate.request_cast_id))
                stringUrl.append("&present_id=")
                stringUrl.append(self.presentList[selectRow].present_id)
                stringUrl.append("&status=3")
                
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
                    //プレゼントを送った後の処理(ポイントの計算など)
                    //更新
                    self.userPresentListDialog.presentListCollectionView.reloadData()
                    self.presentAfterCommonDo(type:1, selectRow:selectRow)
                }
            }else if(type == 3){
                //手持ちの有料プレゼントを贈る
                //最も古いプレゼントから贈る
                //GET: user_id, target_user_id, present_id, status
                //status=1:所持 3:送信済み
                var stringUrl = Util.URL_MODIFY_PRESENT_STATUS
                stringUrl.append("?user_id=")
                stringUrl.append(String(self.user_id))
                stringUrl.append("&target_user_id=")
                stringUrl.append(String(self.appDelegate.request_cast_id))
                stringUrl.append("&present_id=")
                stringUrl.append(self.presentList[selectRow].present_id)
                stringUrl.append("&status=3")
                
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
                    //プレゼントを送った後の処理(ポイントの計算など)
                    //更新
                    self.userPresentListDialog.presentListCollectionView.reloadData()
                    self.presentAfterCommonDo(type:3, selectRow:selectRow)
                }
            }else{
                //所有していないプレゼンを送ろうとした？＞何もしない
            }
            
            //所有しているコインの設定
            let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
            //各ダイアログに表示しているコイン数を更新
            self.userPresentListDialog.presentListCoinLabel.text = "コイン " + UtilFunc.numFormatter(num: Int(myPoint))
            Util.userPurchasePlanDialog.purchasePlanTitleLabel.text = "マイコイン " + UtilFunc.numFormatter(num: Int(myPoint))

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
    
    //プレゼントを(購入し)送信した後の共通処理
    //type:1=無料プレゼント 2:無料プレゼント(所持数ゼロ) 3:有料プレゼント 4:有料プレゼント(所持数ゼロ)
    func presentAfterCommonDo(type:Int, selectRow:Int){
        /*************************************************************/
        //コイン・ポイントなどの計算処理(プレゼントを購入＞ストリーマーへ送るまで)
        /*************************************************************/
        if(type == 4){
            //コインの消費処理
            UtilFunc.pointUseDo(type:0, userId: self.user_id, point: Double(self.presentList[selectRow].coin)!)
            //コイン消費履歴に履歴を保存する
            UtilFunc.writePointUseRireki(type:6,
                                         point:Double(self.presentList[selectRow].coin)!,
                                         user_id:self.user_id,
                                         target_user_id:self.appDelegate.request_cast_id)
        }
        
        //絆レベルの更新
        //connect_levelの更新、pair_month_rankingの更新が必要
        //現在の絆レベルの経験値
        var connection_exp: Int = Int(self.strConnectExp)!
        let connection_point_temp: Double = Util.CONNECTION_POINT_PRESENT * Double(self.presentList[selectRow].coin)!
        //加算される経験値
        let add_point:Int = Util.CONNECTION_POINT_PRESENT_SEND + Int(connection_point_temp)
        
        connection_exp = connection_exp + add_point
        
        //絆レベルの更新(値プラス or マイナス)
        //present_point : 送ったギフトポイント＝スター
        self.saveConnectLevelNew(user_id:self.user_id, target_user_id:self.appDelegate.request_cast_id, exp:add_point, live_count:0, present_point:Int(self.presentList[selectRow].star)!, flg:1)
        
        let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")
        
        //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
        UtilFunc.savePairMonthRanking(user_id:self.user_id, cast_id:self.appDelegate.request_cast_id, exp:Int(Double(self.presentList[selectRow].coin)!*strConnectBonusRate))
        
        //配信レベル・配信ポイントを更新（基本的に１スターにつき１ポイント、無料プレゼントは例外）
        //配信ポイント履歴にキャストが得た配信ポイントなどの履歴を保存する
        //UtilFunc.writeLivePointRireki(type:2, cast_id:self.appDelegate.request_cast_id, user_id:self.user_id, point:Int(self.presentList[selectRow].live_point)!, star:Int(self.presentList[selectRow].star)!, seconds:0, re_star:0)
        
        if(type == 1 || type == 3 || type == 4){
            //無料プレゼントは、配信経験値のみ付与される
            //プレゼントで贈るスターをセット
            let present_data = ["present_star": Int(self.presentList[selectRow].star)!
                , "present_point": Int(self.presentList[selectRow].live_point)!]
            self.conditionRef.updateChildValues(present_data)
            //キャストへスターの追加＞キャスト側で行う
        }
        
        //絆レベルなど相手との情報を取得
        UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:self.appDelegate.request_cast_id)
        //self.getConnectInfo()
        /*************************************************************/
        //コイン・ポイントなどの計算処理(ここまで)
        /*************************************************************/
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        //return idCount;
        return presentList.count
    }
    
    //絆レベルの更新・追加(更新後に処理をする必要があるため、Utilではなくこちらを使用)
    //flg:1:値プラス、2:値マイナス
    //GET: user_id, target_user_id,level,exp,live_count,present_point,flg
    func saveConnectLevelNew(user_id:Int, target_user_id:Int, exp:Int, live_count:Int, present_point:Int, flg:Int){
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
            //月間ペアランキングに反映
            //Util.savePairMonthRankingNew(user_id:user_id, cast_id:Int(self.strUserId)!, exp:exp, flg:flg)
            
            //self.userPurchasePlanDialog.isHidden = true
            self.userPresentListDialog.isHidden = true
            self.messageTableView.reloadData()
        }
    }
}

extension MediaConnectionViewController: CommonKeyboardContainerProtocol {
    // return specific scrollViewContainer
    // UIScrollView or a class that inherited from (e.g., UITableView or UICollectionView)
    var scrollViewContainer: UIScrollView {
        return keyboardScrollView
    }
}
