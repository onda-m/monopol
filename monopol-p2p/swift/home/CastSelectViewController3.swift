//
//  CastSelectViewController3.swift
//  swift_skyway
//
//  Created by onda on 2018/07/11.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//import FirebaseStorage
import AVFoundation
import Firebase
import FirebaseDatabase

class CastSelectViewController3: UIViewController,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,IndicatorInfoProvider {
    
    //監視関連
    let center = NotificationCenter.default
    
    // データベースへの参照
    var rootRef = Database.database().reference()
    var conditionRef = DatabaseReference()
    var array_request_do_user_id: [String] = []//リクエスト中またはライブ中のユーザーID
    
    let iconSize: CGFloat = 12.0
    //let iconSize2: CGFloat = 14.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let menuStr = "2"
    var nowPage:Int = 0//現在のページ番号(0から)
    private var observers00: (player: NSObjectProtocol,willEnterForeground: NSObjectProtocol)?
    private var observers01: (player: NSObjectProtocol,willEnterForeground: NSObjectProtocol)?
    private var observers02: (player: NSObjectProtocol,willEnterForeground: NSObjectProtocol)?
    // インジケータのインスタンス
    let indicator = UIActivityIndicatorView()
    
    //自分のuser_idを指定
    var user_id:Int = 0
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "最新"
    
    //動画のURLの配列
    //    var player = AVPlayer()
    var player00 = AVPlayer()
    var player01 = AVPlayer()
    var player02 = AVPlayer()
    //    var playerLayer = AVPlayerLayer()
    var playerLayer00 = AVPlayerLayer()
    var playerLayer01 = AVPlayerLayer()
    var playerLayer02 = AVPlayerLayer()
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    //選択した時に重ねるView
    var castSelectedDialog = UINib(nibName: "CastSelectedDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastSelectedDialog
    //無料ストリーマーかつライブ配信中の時にかぶせるダイアログ
    var castSelectedDialogFree = UINib(nibName: "CastSelectedDialogFree", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastSelectedDialogFree
    //有料ストリーマーかつライブ配信中の時にかぶせるダイアログ
    var castSelectedDialogCountDown = UINib(nibName: "CastSelectedDialogCountDown", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastSelectedDialogCountDown
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
    }*/

    var idCount:Int=0
    
    var castList: [(user_id:String, notify_flg:String, uuid:String, user_name:String, photo_flg:String, photo_name:String, photo_background_flg:String, photo_background_name:String, movie_flg:String, movie_name:String, value02:String, value03:String, value06:String, watch_level:String, live_level:String, cast_rank:String, cast_official_flg:String, cast_month_ranking_point:String, freetext:String, live_password:String, login_status:String, live_user_id:String, reserve_user_id:String, reserve_flg:String, max_reserve_count:String, effect_flg02:String, bank_info02:String, bank_info03:String, bank_info04:String, bank_info05:String, ins_time:String, user_follow_id:String, ex_live_sec:String, ex_get_live_point:String, ex_ex_get_live_point:String, ex_coin:String, ex_ex_coin:String, ex_min_reserve_coin:String, ex_status:String)] = []
    var castListTemp: [(user_id:String, notify_flg:String, uuid:String, user_name:String, photo_flg:String, photo_name:String, photo_background_flg:String, photo_background_name:String, movie_flg:String, movie_name:String, value02:String, value03:String, value06:String, watch_level:String, live_level:String, cast_rank:String, cast_official_flg:String, cast_month_ranking_point:String, freetext:String, live_password:String, login_status:String, live_user_id:String, reserve_user_id:String, reserve_flg:String, max_reserve_count:String, effect_flg02:String, bank_info02:String, bank_info03:String, bank_info04:String, bank_info05:String, ins_time:String, user_follow_id:String, ex_live_sec:String, ex_get_live_point:String, ex_ex_get_live_point:String, ex_coin:String, ex_ex_coin:String, ex_min_reserve_coin:String, ex_status:String)] = []

    //実際に表示したいセル達のWidthをいれておく変数
    var cellItemsHeight: CGFloat = 0.0
    
    //選択したストリーマーの状態チェック用
    var strSelectUserId: String = ""
    var strSelectUserName: String = ""
    var strSelectPhotoFlg: String = ""
    var strSelectPhotoName: String = ""
    var strSelectValue01: String = ""
    var strSelectLoginStatus: String = ""
    var strSelectLiveUserId: String = ""
    var strSelectReserveUserId: String = ""
    var strSelectReservePeerId: String = ""
    var strSelectReserveFlg: String = ""
    var strSelectConnectLevel: String = ""
    var strSelectConnectExp: String = ""
    var strSelectConnectLiveCount: String = ""
    var strSelectConnectPresentPoint: String = ""
    var strSelectBlackListId: String = ""
    
    struct SelectUserResult: Codable {
        let user_id: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let value01: String//性別
        let login_status: String//
        let live_user_id: String//
        let reserve_user_id: String//
        let reserve_peer_id: String//
        let reserve_flg: String//
        //let login_status: String//
        //let login_time: String//
        //let ins_time: String//
        let connect_level: String//
        let connect_exp: String//
        let connect_live_count: String//
        let connect_present_point: String//
        let black_list_id: String//ブラックリストに入っている場合はゼロ以外が入る
    }
    struct SelectResultJson: Codable {
        let count: Int
        let result: [SelectUserResult]
    }
    
    //キャストの配信レベル情報を取得用
    struct UserResultLevel: Codable {
        let get_live_point: String
        let ex_get_live_point: String
        let coin: String
        let ex_coin: String
        let min_reserve_coin: String//
        let cancel_coin: String//
        let cancel_get_star: String//
    }
    struct ResultJsonLevel: Codable {
        let count: Int
        let result: [UserResultLevel]
    }
    var levelCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        /*********************************/
        //ダイアログの準備
        /*********************************/
        //最初は非表示
        //画面サイズに合わせる
        self.castSelectedDialog.frame = self.view.frame
        //self.castSelectedDialog.setDialog()
        self.castSelectedDialog.isHidden = true
        // 貼り付ける
        //AppDelegateが持つwindowにaddSubview(本当はしたくない)
        self.appDelegate.window?.addSubview(self.castSelectedDialog)
        
        //無料ストリーマーかつライブ配信中の時にかぶせるダイアログ
        //画面サイズに合わせる
        self.castSelectedDialogFree.frame = self.view.frame
        self.castSelectedDialogFree.isHidden = true
        // 貼り付ける
        self.appDelegate.window?.addSubview(self.castSelectedDialogFree)
        
        //有料ストリーマーかつライブ配信中の時にかぶせるダイアログ
        //画面サイズに合わせる
        self.castSelectedDialogCountDown.frame = self.view.frame
        self.castSelectedDialogCountDown.isHidden = true
        // 貼り付ける
        self.appDelegate.window?.addSubview(self.castSelectedDialogCountDown)
        /*********************************/
        //ダイアログの準備(ここまで)
        /*********************************/
        
        /*
        // バックグラウンド時の通知を設定する
        self.center.addObserver(
            self,
            selector: #selector(self.onBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
         */
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //サブメニューの選択
        //UserDefaults.standard.set(self.menuStr, forKey: "selectedSubMenu")
        //self.appDelegate.sendDetailSubMenu = self.menuStr
        self.appDelegate.sendSubMenu = self.menuStr

        if(self.appDelegate.castMoviePlayerNumSubMenu02 == 1){
            self.player00.play()
        }else if(self.appDelegate.castMoviePlayerNumSubMenu02 == 2){
            self.player01.play()
        }else if(self.appDelegate.castMoviePlayerNumSubMenu02 == 3){
            self.player02.play()
        }
        //初期状態に戻す
        //self.appDelegate.castMoviePlayerNum = 0
        
        //すでにリクエストデータがあった場合は、配信・予約も済みとする。
        //Firebaseにすでにリクエストデータがあるということは、リクエスト申請中か、または配信中である。
        let conditionRef = self.rootRef.child(Util.INIT_FIREBASE)
        conditionRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            self.array_request_do_user_id = value?.allKeys as! [String]
            //print("value \(value?.allKeys as! [String])")
            
            //画面の上部に表示される時間やバッテリー残量を非表示
            //self.setNeedsStatusBarAppearanceUpdate()
            
            //print("self.user_id")
            //print(self.user_id)
            //リスト取得(自分以外の待機中のリストを取得)
            self.getModelList(user_id:self.user_id)
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //完全に遷移が行われ、スクリーン上からViewControllerが表示されなくなったときに呼ばれる。
        super.viewDidDisappear(animated)
        
        //一旦全て停止
        if(self.player00.rate != 0 && self.player00.error == nil){
            self.player00.pause()
            //self.appDelegate.castMoviePlayerNum = 1
        }
        
        if(self.player01.rate != 0 && self.player01.error == nil){
            self.player01.pause()
            //self.appDelegate.castMoviePlayerNum = 2
        }
        
        if(self.player02.rate != 0 && self.player02.error == nil){
            self.player02.pause()
            //self.appDelegate.castMoviePlayerNum = 3
        }
        
        self.player00.replaceCurrentItem(with: nil)
        self.player01.replaceCurrentItem(with: nil)
        self.player02.replaceCurrentItem(with: nil)
    }
    
    //() -> ()の部分は　(引数) -> (返り値)を指定
    //func getModelList(_ after:@escaping () -> Void){
    func getModelList(user_id:Int){
        //リスト取得(自分以外の待機中のリストを取得)
        //クリアする
        self.castListTemp.removeAll()

        var stringUrl = Util.URL_GET_LIST
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&order=3")
        
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
                    let json = try decoder.decode(UtilStruct.ResultUserListJson.self, from: data!)
                    
                    self.idCount = json.count
                    
                    //表示するモデルリストを配列にする。
                    for obj in json.result {

                        if(obj.cast_official_flg != "3"){
                            //自動映像流すアカウント(cast_official_flg = 3)は注目のみ表示
                        
                            let castInfo = (obj.user_id,
                                            obj.notify_flg,
                                            obj.uuid,
                                            obj.user_name.toHtmlString(),
                                            obj.photo_flg,
                                            obj.photo_name,
                                            obj.photo_background_flg,
                                            obj.photo_background_name,
                                            obj.movie_flg,
                                            obj.movie_name,
                                            obj.value02,
                                            obj.value03,
                                            obj.value06,
                                            obj.watch_level,
                                            obj.live_level,
                                            obj.cast_rank,
                                            obj.cast_official_flg,
                                            obj.cast_month_ranking_point,
                                            obj.freetext,
                                            obj.live_password,
                                            obj.login_status,
                                            obj.live_user_id,
                                            obj.reserve_user_id,
                                            obj.reserve_flg,
                                            obj.max_reserve_count,
                                            obj.effect_flg02,
                                            obj.bank_info02,
                                            obj.bank_info03,
                                            obj.bank_info04,
                                            obj.bank_info05,
                                            obj.ins_time,
                                            obj.user_follow_id,
                                            obj.ex_live_sec,
                                            obj.ex_get_live_point,
                                            obj.ex_ex_get_live_point,
                                            obj.ex_coin,
                                            obj.ex_ex_coin,
                                            obj.ex_min_reserve_coin,
                                            obj.ex_status)
                            
                            //let movieUrl = Util.URL_USER_MOVIE_BASE + strUserId + ".mp4"
                            
                            //配列へ追加
                            //if(self.appDelegate.sendId == strUserId && self.appDelegate.sendDetailSubMenu == self.menuStr){
                            if(self.appDelegate.sendId == obj.user_id
                                && self.appDelegate.sendSubMenuFirst == self.menuStr){
                                //先頭へ追加
                                self.castList.insert(castInfo, at:0)
                                self.castListTemp.insert(castInfo, at:0)
                                //self.strMovieUrlArray.insert(movieUrl, at:0)
                                
                                //動画関連
                                //let url = URL(string: movieUrl)!
                                //self.urlArray.insert(url, at:0)
                                //let playerItem = AVPlayerItem.init(url: url)
                                //self.playerItemArray.insert(playerItem, at:0)
                                //let player = AVPlayer(playerItem: playerItem)
                                //self.playerArray.insert(player, at:0)
                                
                                
                                //最初に選択したものが画像でかつ最初の起動時:1 2回目以降は2となる
                                //if(strMovieFlg == "0" && self.firstPlayFlg != 2){
                                //    self.firstPlayFlg = 1
                                //}
                                
                            }else{
                                self.castList.append(castInfo)
                                self.castListTemp.append(castInfo)
                            }
                        }
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
            //コピーする
            self.castList = self.castListTemp
            
            if(self.castListTemp.count > 0){
                //一つ目の要素だけここで動画かどうかを判断する(この時点では、スクロールがされていないため)
                if(self.castList[0].movie_flg == "1"){
                    //動画の場合
                    self.appDelegate.castMoviePlayerNumSubMenu02 = 1
                }
                
                //リストの取得を待ってから更新
                self.mainCollectionView.reloadData()
            }
        }
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

        //ページ下部のグラデーション設定
        // ポップアップビュー背景色
        //let viewColor = UIColor.black
        // 半透明にして親ビューが見えるように。透過度はお好みで。
        //testCell.downView.backgroundColor = viewColor.withAlphaComponent(0.1)
        let topColor = Util.CAST_SELECT_GRAD_DOWN_START
        let middleColor = Util.CAST_SELECT_GRAD_DOWN_END
        let bottomColor = Util.CAST_SELECT_GRAD_DOWN_END
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, middleColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 0.4, 1]
        //gradientLayer.frame = testCell.downView.frame
        gradientLayer.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:260)
        testCell.downGradationView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        testCell.downGradationView.layer.insertSublayer(gradientLayer, at: 0)
        //testCell.downView.layer.addSublayer(gradientLayer)
        
        //予約可のところ
        testCell.reserveLabel.backgroundColor = Util.CAST_LIST_RESERVE_BG
        // 角丸
        testCell.reserveLabel.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        testCell.reserveLabel.layer.masksToBounds = true
        
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
        
        //キャスト名
        //let label = testCell.contentView.viewWithTag(3) as! UILabel
        //label.text = castList[indexPath.row].user_name
        //ラベルの枠を自動調節する
        testCell.userNameLabel.adjustsFontSizeToFitWidth = true
        testCell.userNameLabel.minimumScaleFactor = 0.3
        testCell.userNameLabel.text = castList[indexPath.row].user_name.toHtmlString()
        
        //freetextの表示
        var strFreeTextTemp = ""
        if(castList[indexPath.row].freetext.toHtmlString() != ""
            && castList[indexPath.row].freetext.toHtmlString() != "0"
            && castList[indexPath.row].freetext.toHtmlString() != "'0'"){
            strFreeTextTemp = castList[indexPath.row].freetext.toHtmlString()
            //改行を取り除く
            strFreeTextTemp = strFreeTextTemp.remove(characterSet: .newlines)
        }
        //cell.castFreetextLbl.text = strFreeTextTemp
        testCell.freetextBtn.setTitle(strFreeTextTemp, for: .normal)
        testCell.freetextBtn.titleLabel!.lineBreakMode = NSLineBreakMode.byCharWrapping
        testCell.freetextBtn.titleLabel!.numberOfLines = 3
        testCell.freetextBtn.titleLabel!.textAlignment = NSTextAlignment.left
        testCell.freetextBtn.layer.cornerRadius = 8// 角を丸める
        
        testCell.freetextBtn.tag = indexPath.row
        testCell.freetextBtn.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        
        if(castList[indexPath.row].user_follow_id != "0"){
            //この人をフォローしている場合
            // 枠線の色
            //followBtn.layer.borderColor = UIColor.lightGray.cgColor
            // 枠線の太さ
            testCell.followBtn.layer.borderWidth = 0
            // 角丸
            testCell.followBtn.layer.cornerRadius = 4
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            testCell.followBtn.layer.masksToBounds = true
            
            testCell.followBtn.setTitle("フォロー中", for: .normal)
            testCell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
            testCell.followBtn.backgroundColor = Util.CAST_INFO_COLOR_FOLLOW_BTN // 背景色
            
            testCell.followBtn.tag = indexPath.row
            testCell.followBtn.addTarget(self, action: #selector(onClickNotFollow(sender: )), for: .touchUpInside)
        }else{
            //この人をフォローしていない場合
            // 枠線の色
            testCell.followBtn.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
            // 枠線の太さ
            testCell.followBtn.layer.borderWidth = 0
            // 角丸
            testCell.followBtn.layer.cornerRadius = 4
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            testCell.followBtn.layer.masksToBounds = true
            
            testCell.followBtn.setTitle("+フォロー", for: .normal)
            testCell.followBtn.setTitleColor(UIColor.gray, for: .normal) // タイトルの色
            testCell.followBtn.backgroundColor = UIColor.white // 背景色
            
            testCell.followBtn.tag = indexPath.row
            testCell.followBtn.addTarget(self, action: #selector(onClickFollow(sender: )), for: .touchUpInside)
        }
        
        if(castList[indexPath.row].value06 == "1"){
            //イベント設定している人に対して、イベントの２分前に表示
            //イベント終了ボタンが押されるまで表示
            testCell.eventNowImageView.isHidden = false
        }else{
            //非表示
            testCell.eventNowImageView.isHidden = true
        }
        
        // Tag番号を使ってLabelのインスタンス生成
        //1:待機中 2:通話中 3:ログオフ状態
        //let label_status = testCell.contentView.viewWithTag(93) as! UILabel
        // Tag番号を使ってLabelのインスタンス生成
        //パスワードアイコンのところ
        //let image_password = testCell.contentView.viewWithTag(97) as! UIImageView
        // Tag番号を使ってLabelのインスタンス生成
        //予約可のところ
        //let label_onlive = testCell.contentView.viewWithTag(96) as! UILabel
        
        if(castList[indexPath.row].bank_info02 == "1"
            || castList[indexPath.row].bank_info03 == "1"
            || castList[indexPath.row].bank_info04 == "1"
            || castList[indexPath.row].bank_info05 == "1"){
            //キャッシュバックイベントのストリーマーの場合
            //左上のイベントアイコン
            testCell.eventImageBtn.setImage(UIImage(named: "cast_list_event"), for: .normal)
            testCell.eventImageBtn.isHidden = false
        }else{
            //イベントに参加していない人
            testCell.eventImageBtn.isHidden = true
        }
        
        //右下のプレミアムユーザーアイコン
        if(castList[indexPath.row].bank_info02 == "2"
            || castList[indexPath.row].bank_info03 == "2"
            || castList[indexPath.row].bank_info04 == "2"
            || castList[indexPath.row].bank_info05 == "2"){
            //ミスいちごイベント参加のストリーマーの場合
            testCell.premiumImageView.image = UIImage(named:"missichigo_icon_tictoc")
            testCell.premiumImageView.isHidden = false
        }else{
            //イベントに参加していない人
            if(castList[indexPath.row].ex_status == "1"){
                //1設定済み（プレミアムユーザー）
                testCell.premiumImageView.image = UIImage(named:"live_premium_icon_tictoc")
                testCell.premiumImageView.isHidden = false
            }else{
                testCell.premiumImageView.isHidden = true
            }
        }
        
        //右下のイベントボタン(20210831追加)
        /*
        if(Int(castList[indexPath.row].effect_flg02)! > 0){
            //イベントボタンを表示
            //testCell.premiumImageView.image = UIImage(named:"missichigo_icon_tictoc")
            testCell.userEventBtn.isHidden = false
            
            testCell.userEventBtn.tag = indexPath.row
            testCell.userEventBtn.addTarget(self, action: #selector(onClickUserEvent(sender: )), for: .touchUpInside)
        }else{
            //イベントボタンを非表示
            testCell.userEventBtn.isHidden = true
        }*/
        //イベントボタンを非表示
        testCell.userEventBtn.isHidden = true
        
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
                testCell.liveStartBtn.isUserInteractionEnabled = true
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
                //testCell.liveStartBtn.isUserInteractionEnabled = false
                testCell.liveStartBtn.isUserInteractionEnabled = true//押せるようにする
                
                testCell.liveStartBtn.isHidden = false
                let picture = UIImage(named: "live_on_btn")
                testCell.liveStartBtn.setImage(picture, for: .normal)
                
                //右上のステータスアイコン
                //let cellImageStatus = UIImage(named:"cast_list_reserve")
                let cellImageStatus = UIImage(named:"cast_list_onlive")
                testCell.statusImage.image = cellImageStatus
                testCell.statusImage.isHidden = false
                /*
                 //予約可のところ
                 if(castList[indexPath.row].reserve_flg == "1"){
                 //予約不可
                 testCell.reserveLabel.isHidden = true
                 
                 //ライブ配信ボタン非表示
                 testCell.liveStartBtn.isHidden = true
                 
                 //右上のステータスアイコン
                 let cellImageStatus = UIImage(named:"cast_list_reserve")
                 testCell.statusImage.image = cellImageStatus
                 testCell.statusImage.isHidden = false
                 }else{
                 //予約可能
                 testCell.reserveLabel.isHidden = false
                 
                 //ライブ配信ボタン表示
                 testCell.liveStartBtn.isHidden = false
                 
                 //右上のステータスアイコン
                 let cellImageStatus = UIImage(named:"cast_list_onlive")
                 testCell.statusImage.image = cellImageStatus
                 testCell.statusImage.isHidden = false
                 }
                 */
                /***************************************/
                /*初期リリース時は予約不可（ここまで）*/
                /***************************************/
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
                //testCell.liveStartBtn.isHidden = true
                
                //ライブ配信ボタン表示
                testCell.liveStartBtn.isUserInteractionEnabled = false
                testCell.liveStartBtn.isHidden = false
                let picture = UIImage(named: "live_off_btn")
                testCell.liveStartBtn.setImage(picture, for: .normal)
                
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
                //testCell.liveStartBtn.isHidden = true
                
                //ライブ配信ボタン表示
                testCell.liveStartBtn.isUserInteractionEnabled = false
                testCell.liveStartBtn.isHidden = false
                let picture = UIImage(named: "live_off_btn")
                testCell.liveStartBtn.setImage(picture, for: .normal)
            }
        }
        
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
        
        //ライブ視聴ボタンを押した時の処理
        testCell.liveStartBtn.tag = indexPath.row
        testCell.liveStartBtn.addTarget(self, action: #selector(liveStartRequest(sender: )), for: .touchUpInside)
        
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
        let imageBackView = testCell.castBackImageView
        let movieFlg = castList[indexPath.row].movie_flg
        let movieName = castList[indexPath.row].movie_name
        
        //背景画像
        let photoBackgroundFlg = castList[indexPath.row].photo_background_flg
        let photoBackgroundName = castList[indexPath.row].photo_background_name
        
        /*********2022-12-23 onda追加****************************************/
        //追加したViewをクリア
        for subview in imageBackView!.subviews {
             subview.removeFromSuperview()
        }
        //画像の表示をデフォルトに戻す
        imageView?.contentMode = .scaleAspectFit
        //画像のレイヤーを表示
        imageView?.isHidden = false
        imageBackView?.isHidden = false
        /*********2022-12-23 onda追加（ここまで）************************/
        
        if(movieFlg == "0"){
            //動画の設定なし
            if(photoBackgroundFlg == "1"){
                //背景画像の設定あり
                let photoBackgroundUrlBase = "user_background_images/" + user_id + "/" + photoBackgroundName + ".jpg"
                let photoBackgroundUrl = URL(string: Util.URL_USER_PHOTO_BASE + photoBackgroundUrlBase)!
                
                //画像キャッシュを使用
                //imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoBackgroundUrl, no_image_named:"demo_noimage")
                //imageView?.pin_setImage(from: photoBackgroundUrl) { [weak self] result in
                imageView?.pin_setImage(from: photoBackgroundUrl) { result in
                    // Success
                    if result.error == nil {
                        //print(result.image!.size) //->(800.0, 600.0)(width, height)
                        //imageViewの縦横比を取得し、643＊1137より縦長の場合は、画面フルに表示する
                        //let imageViewWith = result.image!.size.width
                        //let imageViewHeight = result.image!.size.height
                        let aspect_hi:CGFloat = result.image!.size.height / result.image!.size.width
                        
                        if(aspect_hi > Util.ASPECT_HI_BASE){
                            imageView?.contentMode = .scaleAspectFill
                        }else{
                            // 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
                            imageView!.layer.shadowOffset = CGSize(width: 0.0, height: 20.0)
                            // 影の色
                            imageView!.layer.shadowColor = UIColor.black.cgColor
                            // 影の濃さ
                            imageView!.layer.shadowOpacity = 0.2
                            // 影をぼかし
                            imageView!.layer.shadowRadius = 30
                            
                            //背景ぼかし表示用
                            //画像キャッシュを使用
                            //imageBackView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoBackgroundUrlBase, no_image_named:"demo_noimage")
                            imageBackView?.image = imageView!.image
                            
                            /****************************/
                            //2重にぼかす
                            /****************************/
                            // ぼかし効果を設定したUIVisualEffectViewのインスタンスを生成
                            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                            // ぼかし効果Viewのframeをviewのframeに合わせる
                            blurEffectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            // viewにぼかし効果viewを追加
                            imageBackView!.addSubview(blurEffectView)
                            
                            // ぼかし効果を設定したUIVisualEffectViewのインスタンスを生成
                            let blurEffectView2 = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                            // ぼかし効果Viewのframeをviewのframeに合わせる
                            blurEffectView2.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            // viewにぼかし効果viewを追加
                            imageBackView!.addSubview(blurEffectView2)
                            /****************************/
                            //2重にぼかす(ここまで)
                            /****************************/
                        }
                    } else {
                        // 写真がない場合
                        imageView?.image = UIImage(named:"demo_noimage")
                    }
                }
                
                //キャッシュサーバーに画像キャッシュを作成
                UtilFunc.createCachePhotoBackgroundByUrl(user_id:Int(user_id)!, file_name:photoBackgroundName)
            }else{
                //背景画像の設定なし
                if(photoFlg == "1"){
                    //写真設定済み
                    let photoUrlBase = "user_images/" + user_id + "/" + photoName + ".jpg"
                    let photoUrl = URL(string: Util.URL_USER_PHOTO_BASE + photoUrlBase)!
                    
                    //画像キャッシュを使用
                    //imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
                    //imageView?.pin_setImage(from: photoUrl) { [weak self] result in
                    imageView?.pin_setImage(from: photoUrl) { result in
                        // Success
                        if result.error == nil {
                            //print(result.image!.size) //->(800.0, 600.0)(width, height)
                            //imageViewの縦横比を取得し、643＊1137より縦長の場合は、画面フルに表示する
                            //let imageViewWith = result.image!.size.width
                            //let imageViewHeight = result.image!.size.height
                            let aspect_hi:CGFloat = result.image!.size.height / result.image!.size.width
                            
                            if(aspect_hi > Util.ASPECT_HI_BASE){
                                imageView?.contentMode = .scaleAspectFill
                            }else{
                                // 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
                                imageView!.layer.shadowOffset = CGSize(width: 0.0, height: 20.0)
                                // 影の色
                                imageView!.layer.shadowColor = UIColor.black.cgColor
                                // 影の濃さ
                                imageView!.layer.shadowOpacity = 0.2
                                // 影をぼかし
                                imageView!.layer.shadowRadius = 30
                                
                                //背景ぼかし表示用
                                //画像キャッシュを使用
                                //imageBackView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrlBase, no_image_named:"demo_noimage")
                                imageBackView?.image = imageView!.image
                                
                                /*
                                for subview in imageBackView!.subviews {
                                     subview.removeFromSuperview()
                                }
                                 */

                                /****************************/
                                //2重にぼかす
                                /****************************/
                                // ぼかし効果を設定したUIVisualEffectViewのインスタンスを生成
                                let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                                // ぼかし効果Viewのframeをviewのframeに合わせる
                                blurEffectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                // viewにぼかし効果viewを追加
                                imageBackView!.addSubview(blurEffectView)
                                
                                // ぼかし効果を設定したUIVisualEffectViewのインスタンスを生成
                                let blurEffectView2 = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                                // ぼかし効果Viewのframeをviewのframeに合わせる
                                blurEffectView2.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                // viewにぼかし効果viewを追加
                                imageBackView!.addSubview(blurEffectView2)
                                /****************************/
                                //2重にぼかす(ここまで)
                                /****************************/
                            }
                        } else {
                            // 写真がない場合
                            imageView?.image = UIImage(named:"demo_noimage")
                        }
                    }
                    //キャッシュサーバーに画像キャッシュを作成
                    UtilFunc.createCachePhotoByUrl(user_id:Int(user_id)!, file_name:photoName)
                }
            }
        }else if(movieFlg == "1"){
            if(photoBackgroundFlg == "1"){
                //背景画像の設定あり
                //写真設定済み
                //let photoUrl = "user_images/" + user_id + ".jpg"
                let photoBackgroundUrl = "user_background_images/" + user_id + "/" + photoBackgroundName + ".jpg"
                
                //画像キャッシュを使用
                imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoBackgroundUrl, no_image_named:"demo_noimage")
                
                //キャッシュサーバーに画像キャッシュを作成
                UtilFunc.createCachePhotoBackgroundByUrl(user_id:Int(user_id)!, file_name:photoBackgroundName)
            }else{
                //背景画像の設定なし
                if(photoFlg == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + user_id + ".jpg"
                    let photoUrl = "user_images/" + user_id + "/" + photoName + ".jpg"
                    
                    //画像キャッシュを使用
                    imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
                    
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
            
            //3で割った余りによって使用するplayerを変える
            if(CGFloat(indexPath.row).truncatingRemainder(dividingBy: 3.0) == 0){
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
                    //画像のレイヤーを非表示
                    imageView?.isHidden = true
                    imageBackView?.isHidden = true
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
                            playerLayer00?.player?.play()
                        }
                }
                
                self.observers00 = (playerObserver00, willEnterForegroundObserver00)
                
            }else if(CGFloat(indexPath.row).truncatingRemainder(dividingBy: 3.0) == 1){
                self.playerLayer01.removeFromSuperlayer()
                self.player01 = AVPlayer(playerItem: playerItem)
                self.player01.automaticallyWaitsToMinimizeStalling = false//速く再生開始となる
                self.playerLayer01 = AVPlayerLayer(player: self.player01)
                self.playerLayer01.frame = self.view.bounds
                self.playerLayer01.videoGravity = .resizeAspectFill
                self.playerLayer01.zPosition = -1 // ボタン等よりも後ろに表示
                
                //testCell.layer.insertSublayer(self.playerLayer01, at: 0) // 動画をレイヤーとして追加
                testCell.layer.addSublayer(self.playerLayer01) // 動画をレイヤーとして追加
                
                self.player01.play()
                
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
                self.player01.addPeriodicTimeObserver(forInterval: boundary, queue: nil, using: {_ in
                    //画像のレイヤーを非表示
                    imageView?.isHidden = true
                    imageBackView?.isHidden = true
                })
                
                // 最後まで再生したら最初から再生する
                let playerObserver01 = self.center.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: self.player01.currentItem,
                    queue: .main) { [weak playerLayer01] _ in
                        playerLayer01?.player?.seek(to: CMTime.zero)
                        playerLayer01?.player?.play()
                }
                
                // アプリがバックグラウンドから戻ってきた時に再生する
                let willEnterForegroundObserver01 = self.center.addObserver(
                    forName: UIApplication.willEnterForegroundNotification,
                    object: nil,
                    queue: .main) { [weak playerLayer01] _ in
                        if(self.appDelegate.castMoviePlayerNumSubMenu01 == 2){
                            playerLayer01?.player?.play()
                        }
                }
                
                self.observers01 = (playerObserver01, willEnterForegroundObserver01)
                
            }else if(CGFloat(indexPath.row).truncatingRemainder(dividingBy: 3.0) == 2){
                self.playerLayer02.removeFromSuperlayer()
                self.player02 = AVPlayer(playerItem: playerItem)
                self.player02.automaticallyWaitsToMinimizeStalling = false//速く再生開始となる
                self.playerLayer02 = AVPlayerLayer(player: self.player02)
                self.playerLayer02.frame = self.view.bounds
                self.playerLayer02.videoGravity = .resizeAspectFill
                self.playerLayer02.zPosition = -1 // ボタン等よりも後ろに表示
                //view.layer.insertSublayer(playerLayer02, at: 0) // 動画をレイヤーとして追加
                
                //testCell.layer.insertSublayer(self.playerLayer02, at: 0) // 動画をレイヤーとして追加
                testCell.layer.addSublayer(self.playerLayer02) // 動画をレイヤーとして追加
                
                self.player02.play()
                /*
                 // 動画の上に重ねる半透明の黒いレイヤー
                 let dimOverlay = CALayer()
                 dimOverlay.frame = view.bounds
                 dimOverlay.backgroundColor = UIColor.black.cgColor
                 dimOverlay.zPosition = -1
                 dimOverlay.opacity = 0.4 // 不透明度
                 view.layer.insertSublayer(dimOverlay, at: 0)
                 */
                self.player02.addPeriodicTimeObserver(forInterval: boundary, queue: nil, using: {_ in
                    //画像のレイヤーを非表示
                    imageView?.isHidden = true
                    imageBackView?.isHidden = true
                })
                
                // 最後まで再生したら最初から再生する
                let playerObserver02 = self.center.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: self.player02.currentItem,
                    queue: .main) { [weak playerLayer02] _ in
                        playerLayer02?.player?.seek(to: CMTime.zero)
                        playerLayer02?.player?.play()
                }
                
                // アプリがバックグラウンドから戻ってきた時に再生する
                let willEnterForegroundObserver02 = self.center.addObserver(
                    forName: UIApplication.willEnterForegroundNotification,
                    object: nil,
                    queue: .main) { [weak playerLayer02] _ in
                        
                        if(self.appDelegate.castMoviePlayerNumSubMenu01 == 3){
                            playerLayer02?.player?.play()
                        }
                }
                
                self.observers02 = (playerObserver02, willEnterForegroundObserver02)
            }
            
            //キャッシュサーバーに動画キャッシュを作成
            UtilFunc.createCacheMovieByUrl(user_id:Int(user_id)!, file_name:movieName)
            
            /*
             // 端末が回転した時に動画レイヤーのサイズを調整する
             let boundsObserver = testCell.layer.observe(\.bounds) { [weak playerLayer, weak dimOverlay] view, _ in
             DispatchQueue.main.async {
             playerLayer?.frame = view.bounds
             dimOverlay?.frame = view.bounds
             }
             }
             
             // 最後まで再生したら最初から再生する
             let playerObserver = self.center.addObserver(
             forName: .AVPlayerItemDidPlayToEndTime,
             object: player.currentItem,
             queue: .main) { [weak playerLayer] _ in
             playerLayer?.player?.seek(to: kCMTimeZero)
             playerLayer?.player?.play()
             }
             
             // アプリがバックグラウンドから戻ってきた時に再生する
             let willEnterForegroundObserver = self.center.addObserver(
             forName: .UIApplicationWillEnterForeground,
             object: nil,
             queue: .main) { [weak playerLayer] _ in
             playerLayer?.player?.play()
             }
             
             self.observers = (playerObserver, willEnterForegroundObserver)
             }
             }*/
            
            //self.playFlg = 1
        }else{
            //一度動画が再生されていれば下記を実行
            //if(self.playFlg == 1){
            //    self.playerLayer.removeFromSuperlayer()
            //    self.playFlg = 0
            //}
            
            let cellImage = UIImage(named:"demo_noimage")
            // UIImageをUIImageViewのimageとして設定
            imageView?.image = cellImage
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
        
        if let observers01 = observers01 {
            self.center.removeObserver(observers01.player)
            self.center.removeObserver(observers01.willEnterForeground)
            //observers.bounds.invalidate()
            
            //self.playerArray[indexPath.row].removeObserver(self, forKeyPath: "rate")
        }
        
        if let observers02 = observers02 {
            self.center.removeObserver(observers02.player)
            self.center.removeObserver(observers02.willEnterForeground)
            //observers.bounds.invalidate()
            
            //self.playerArray[indexPath.row].removeObserver(self, forKeyPath: "rate")
        }
        
        self.player00.replaceCurrentItem(with: nil)
        self.player01.replaceCurrentItem(with: nil)
        self.player02.replaceCurrentItem(with: nil)
    }
    
    //プロフィールボタンを押した時
    @objc func onClick(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        //print(selectedId)
        //let modelInfo: UserInfoViewController = self.storyboard!.instantiateViewController(withIdentifier: "toUserInfoViewController") as! UserInfoViewController
        let modelInfo: UserInfoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "toUserInfoViewController") as! UserInfoViewController
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //modelInfo.sendId = strPeerIds[selectedId]
        appDelegate.sendId = castList[buttonRow].user_id
        
        //選択しているサブメニューの保存(重要)
        //appDelegate.sendDetailSubMenu = self.menuStr
        appDelegate.sendSubMenuFirst = menuStr
        UserDefaults.standard.set(self.menuStr, forKey: "selectedSubMenu")
        
        // 下記を追加する
        modelInfo.modalPresentationStyle = .overCurrentContext
        
        present(modelInfo, animated: true, completion: nil)
    }
    
    //followボタンを押した時
    @objc func onClickFollow(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //modelInfo.sendId = strPeerIds[selectedId]
        //この人をフォロー
        follow(flg: 1, to_user_id: Int(castList[buttonRow].user_id))
        
        sender.setTitle("フォロー中", for: .normal)
        sender.setTitleColor(UIColor.white, for: .normal) // タイトルの色
        sender.backgroundColor = Util.FOLLOW_ON_COLOR
        //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
        sender.layer.borderWidth = 0
        
        self.castList[buttonRow].user_follow_id = castList[buttonRow].user_id
        
        sender.tag = buttonRow
        sender.addTarget(self, action: #selector(onClickNotFollow(sender: )), for: .touchUpInside)
    }
    
    //followボタンを押した時(followを取り消す)
    @objc func onClickNotFollow(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //modelInfo.sendId = strPeerIds[selectedId]
        //この人をフォロー取り消す
        follow(flg: 2, to_user_id: Int(castList[buttonRow].user_id))
        
        sender.setTitle("+フォロー", for: .normal)
        sender.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
        sender.backgroundColor = UIColor.white
        sender.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
        sender.layer.borderWidth = 0.5
        
        self.castList[buttonRow].user_follow_id = "0"
        
        sender.tag = buttonRow
        sender.addTarget(self, action: #selector(onClickFollow(sender: )), for: .touchUpInside)
    }
    
    //右下イベントボタンを押した時
    @objc func onClickUserEvent(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag

        //イベント告知ページ
        //外部ブラウザでURLを開く
        var stringUrl = Util.URL_EVENT_URL
        stringUrl.append(self.castList[buttonRow].effect_flg02)//イベントID
        stringUrl.append("&listener_id=")
        stringUrl.append(String(self.user_id))//自分のID
        print(stringUrl)
        let url = NSURL(string: stringUrl)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
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
         //キャストが得られるポイント(最初の1分枠で得られるポイント)
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
            //UtilFunc.reserveListClearByUserId(user_id:user_id, status:0)
            
            //通常リクエスト
            
            //1回目のタップ
            //UIAlertControllerを用意する
            let actionAlert = UIAlertController(title: UtilFunc.strMin(str:cast_name, num:Util.NAME_MOJI_COUNT_SMALL) + "さんとサシライブしますか?\n" + strDelPoint
                ,message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "サシライブする", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                var checkFlg = 0//チェック用(1の場合はエラーメッセージを出力して終了)
                
                //ストリーマーの1分に必要なコイン数、延長するのに必要なコイン数を取得し最終チェック
                //どちらかが異なる場合は、エラーメッセージ（ERROR_SELECT_COMMON_001）を表示し終了。
                var strCastRank: String = ""
                //var strPubGetLivePoint: String = ""
                //var strPubExGetLivePoint: String = ""
                var strPubCoin: String = ""
                var strPubExCoin: String = ""
                //var strPubMinReserveCoin: String = ""
                //var strCancelCoin: String = ""
                //var strCancelGetStar: String = ""
                //個別設定用
                //var strExLiveSec: String = ""
                //var strExGetLivePoint: String = ""
                //var strExExGetLivePoint: String = ""
                var strExCoin: String = ""
                var strExExCoin: String = ""
                //var strExMinReserveCoin: String = ""
                var strExStatus: String = ""//1有効2無効3設定済み無効
                
                //ストリーマーの状態を取得
                //cast_id:self.appDelegate.request_cast_id,
                //user_id:self.user_id
                var stringUrl = Util.URL_USER_INFO
                stringUrl.append("?user_id=")
                stringUrl.append(String(self.appDelegate.request_cast_id))
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
                            let json = try decoder.decode(UtilStruct.ResultJsonTempNoRank.self, from: data!)
                            //self.idCount = json.count
                            
                            //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                            for obj in json.result {
                                //strPubGetLivePoint = obj.pub_get_live_point
                                //strPubExGetLivePoint = obj.pub_ex_get_live_point
                                strCastRank = obj.cast_rank
                                //strPubMinReserveCoin = obj.pub_min_reserve_coin
                                //strCancelCoin = obj.cancel_coin
                                //strCancelGetStar = obj.cancel_get_star
                                //個別設定用
                                //strExLiveSec = obj.ex_live_sec
                                //strExGetLivePoint = obj.ex_get_live_point
                                //strExExGetLivePoint = obj.ex_ex_get_live_point
                                strExCoin = obj.ex_coin
                                strExExCoin = obj.ex_ex_coin
                                //strExMinReserveCoin = obj.ex_min_reserve_coin
                                strExStatus = obj.ex_status
                                
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
                    //1有効2無効3設定済み無効
                    //if(strExStatus == "1" || strExStatus == "3"){
                    if(strExStatus == "1"){
                        /*
                        //個別設定がされている
                        UserDefaults.standard.set(strExGetLivePoint, forKey: "get_live_point")
                        UserDefaults.standard.set(strExExGetLivePoint, forKey: "ex_get_live_point")
                        UserDefaults.standard.set(strExCoin, forKey: "coin")
                        UserDefaults.standard.set(strExExCoin, forKey: "ex_coin")
                        UserDefaults.standard.set(strExMinReserveCoin, forKey: "min_reserve_coin")
                        //１枠の秒数を設定
                        UserDefaults.standard.set(strExLiveSec, forKey: "live_sec")
                         */
                        //1回、視聴するのに消費するコイン,延長するのに消費するコインを再度チェック
                        //self.appDelegate.live_pay_coin
                        //self.appDelegate.live_pay_ex_coin
                        if(self.appDelegate.live_pay_coin == Double(strExCoin)
                            && self.appDelegate.live_pay_ex_coin == Double(strExExCoin)){
                            //最終チェックOK
                            checkFlg = 0
                        }else{
                            //最終チェックNG
                            checkFlg = 1
                        }
                        
                        self.commonCheck(checkFlg: checkFlg)
                    }else{
                        /*
                        //個別設定がされてない
                        UserDefaults.standard.set(strPubGetLivePoint, forKey: "get_live_point")
                        UserDefaults.standard.set(strPubExGetLivePoint, forKey: "ex_get_live_point")
                        UserDefaults.standard.set(strPubCoin, forKey: "coin")
                        UserDefaults.standard.set(strPubExCoin, forKey: "ex_coin")
                        UserDefaults.standard.set(strPubMinReserveCoin, forKey: "min_reserve_coin")
                        //１枠の秒数を設定
                        UserDefaults.standard.set(Util.INIT_LIVE_SECONDS, forKey: "live_sec")
                         */
                        
                        //1回、視聴するのに消費するコイン,延長するのに消費するコインを再度チェック
                        //self.appDelegate.live_pay_coin
                        //self.appDelegate.live_pay_ex_coin
                        
                        //キャストのランクを取得
                        var stringUrl = Util.URL_GET_LIVE_RANK_INFO
                        stringUrl.append("?rank_id=")
                        stringUrl.append(strCastRank)
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
                                    let json = try decoder.decode(ResultJsonLevel.self, from: data!)
                                    //self.levelCount = json.count
                                    
                                    for obj in json.result {
                                        strPubCoin = obj.coin
                                        strPubExCoin = obj.ex_coin
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
                            if(self.appDelegate.live_pay_coin == Double(strPubCoin)
                                && self.appDelegate.live_pay_ex_coin == Double(strPubExCoin)){
                                //最終チェックOK
                                checkFlg = 0
                            }else{
                                //最終チェックNG
                                checkFlg = 1
                            }
                            
                            self.commonCheck(checkFlg: checkFlg)
                        }
                    }
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
    
    func commonCheck(checkFlg: Int){
        //チェック用(1の場合はエラーメッセージを出力して終了)
        if(checkFlg == 1){
            //エラーメッセージを表示
            //UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_COMMON_001, vc:self, sec: 5.0)
            // アラート作成
            //let messageFont = [kCTFontAttributeName: UIFont(name: "Avenir-Roman", size: 9.0)!]
            let messageFont = [kCTFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
            
            let messageAttrString = NSMutableAttributedString(string: UtilStr.ERROR_SELECT_COMMON_001, attributes: messageFont as [NSAttributedString.Key : Any])
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            //let alert = UIAlertController(title: nil, preferredStyle: .alert)
            
            alert.setValue(messageAttrString, forKey: "attributedMessage")
            
            // 下記を追加する
            alert.modalPresentationStyle = .fullScreen
            
            // アラート表示
            self.present(alert, animated: true, completion: {
                // アラートを閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    alert.dismiss(animated: true, completion: nil)
                    
                    //トップのリスト画面に戻す
                    UtilToViewController.toMainViewController()
                })
            })
        }else{
            /*
            //1回、視聴するのに消費するコイン
            var live_pay_coin: Double = 0.0
            //1回、延長するのに消費するコイン
            var live_pay_ex_coin: Double = 0.0
            //予約するのに必要なコイン
            var min_reserve_coin: Int = 0
            */
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
                //self.view.bringSubviewToFront(self.castSelectedDialog)
                self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialog)
                
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
            
                /*
                // アプリが終了する直前に呼ばれる処理を設置
                self.center.addObserver(
                    self,
                    selector: #selector(self.appEnd),
                    name: UIApplication.willTerminateNotification,
                    object: nil
                )*/
                
                if(self.appDelegate.request_password == "0"
                    || self.appDelegate.request_password == ""){
                    //パスワードなしの場合
                    self.castSelectedDialog.setDialogNext(cast_id:self.appDelegate.request_cast_id,
                                                          user_id:self.user_id,
                                                          cast_name:self.appDelegate.request_cast_name!)
                }
            }
        }
    }
    
    /*
    //アプリが終了する直前に呼ばれる
    @objc func appEnd() {
        //コードを書く
        //print("リスナー側アプリが終了！！")
        //リクエストしていれば、リクエスト自体を削除
        self.castSelectedDialog.timeoutCloseDialog()
    }*/
    
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
    
    //20200416修正
    // ライブ視聴ボタンが押されたら呼ばれる
    //func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    @objc func liveStartRequest(sender: UIButton){
        
        let buttonRow = sender.tag
        
        if(self.castList[buttonRow].login_status == "2"
        || self.castList[buttonRow].login_status == "4"
        || self.castList[buttonRow].login_status == "6"
        || self.castList[buttonRow].login_status == "7"
        ){
            //通話中(全画面のダイアログ表示)
            //無料か有料かの判断
            //ストリーマーのライブ情報を取得し設定
            self.getCastLiveInfo(flg: 2, row: buttonRow)

        }else{
            UtilFunc.checkPermissionAudio()
            
            //UserDefaults.standard.set(int, forKey: "selectedIndexCount")
            //let selectedCount = UserDefaults.standard.integer(forKey: "selectedIndexCount")
            
            //選択したセルにViewを重ねる
            //let cell = collectionView.cellForItem(at: indexPath)!
            //cell?.selectedBackgroundView(UIColor.lightGrayColor())
            //let selectedView:ListSelectedview = UINib(nibName: "ListSelectedview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! ListSelectedview
            //画面サイズに合わせる
            //self.selectedView.frame = self.view.frame
            
            /**************************/
            //同時リクエストなどを予防する
            /**************************/
            //自分のuser_idを指定
            //let user_id = UserDefaults.standard.integer(forKey: "user_id")
            
            //ストリーマーの状態を取得
            var stringUrl = Util.URL_USER_INFO
            stringUrl.append("?user_id=")
            stringUrl.append(self.castList[buttonRow].user_id)
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
                        let json = try decoder.decode(SelectResultJson.self, from: data!)
                        //self.idCount = json.count
                        //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                        for obj in json.result {
                            self.strSelectUserId = obj.user_id
                            self.strSelectUserName = obj.user_name.toHtmlString()
                            self.strSelectPhotoFlg = obj.photo_flg
                            self.strSelectPhotoName = obj.photo_name
                            self.strSelectValue01 = obj.value01
                            self.strSelectLoginStatus = obj.login_status
                            self.strSelectLiveUserId = obj.live_user_id
                            self.strSelectReserveUserId = obj.reserve_user_id
                            self.strSelectReservePeerId = obj.reserve_peer_id
                            self.strSelectReserveFlg = obj.reserve_flg
                            self.strSelectConnectLevel = obj.connect_level//絆レベル
                            self.strSelectConnectExp = obj.connect_exp//絆レベルの経験値
                            self.strSelectConnectLiveCount = obj.connect_live_count//視聴回数
                            self.strSelectConnectPresentPoint = obj.connect_present_point//プレゼントしたポイント
                            self.strSelectBlackListId = obj.black_list_id
                            
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
                /**********************************/
                //第一段階のエラーチェック
                //「申請中」になる直前のチェック（MySQLを使用したチェックのみ）
                /**********************************/
                /*
                 //キャストの情報を取得して判断する
                 //予約拒否フラグが立っている場合・またはブラックリストに入っている場合
                 UtilStr.ERROR_SELECT_STREAMER_001 = "現在、予約申請をすることができません。"
                 //予約がすでに埋まっている場合
                 UtilStr.ERROR_SELECT_STREAMER_002 = "すでに予約が埋まっています。"
                 //ログオフ状態の場合
                 UtilStr.ERROR_SELECT_STREAMER_003 = "現在、サシライブを行っていません。"
                 //通常の申請時にブラックリストに入っている場合、またはなんらかのエラー
                 UtilStr.ERROR_SELECT_STREAMER_004 = "現在、サシライブの申請をすることができません。"
                 
                 //数秒後に勝手に閉じる
                 //使い方
                 //UtilFunc.showAlert(message:"", vc:self.parentViewController()!)
                 //UtilFunc.showAlert(message:"", vc:self)
                 UtilFunc.showAlert(message:String, vc:UIViewController) {
                 */
                //var errorFlgTemp = 0//1:何らかのエラーがありリクエストが送れない場合
                
                if(Int(self.castList[buttonRow].user_id)! > 0){
                    //配信リクエストのダイアログを表示
                    if(self.strSelectReserveFlg == "1" || self.strSelectBlackListId != "0"){
                        //予約拒否状態 or ブラックリストに自分が入っている
                        UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_STREAMER_001, vc:self, sec:2.0)
                    }else if(self.strSelectLoginStatus == "3"){
                        //ログオフ状態
                        //選択したセルをクリア
                        //selectedIndexPath = nil
                    }else{
                        //申請可能
                        //0:待機中
                        //1:現在配信中で、予約はなし
                        //2以上:現在配信中で、予約もあり
                        self.appDelegate.request_cast_id = Int(self.castList[buttonRow].user_id)!
                        self.appDelegate.request_notify_flg = Int(self.castList[buttonRow].notify_flg)
                        self.appDelegate.request_max_reserve_count = Int(self.castList[buttonRow].max_reserve_count)!
                        self.appDelegate.request_cast_uuid = self.castList[buttonRow].uuid
                        self.appDelegate.request_cast_name = self.castList[buttonRow].user_name
                        self.appDelegate.request_cast_rank = self.castList[buttonRow].cast_rank
                        self.appDelegate.request_password = self.castList[buttonRow].live_password
                        //appDelegate.request_reserve_user_id = 0
                        //self.appDelegate.request_frame_count = 1//枠数
                        //self.appDelegate.request_count_num = 1//1回目のタップ
                        //self.appDelegate.request_cast_login_status = 1
                        self.appDelegate.request_live_user_id = Int(self.castList[buttonRow].live_user_id)!
                        
                        //2021-12-08 処理追加(マイコインをリアルタイムに反映するため)
                        self.setMyInfoCastLiveInfo(row:buttonRow)
                        
                    }
                }else{
                    //予期せぬエラー(何もしない)
                    UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_STREAMER_004, vc:self, sec:2.0)
                }
            }
        }
    }
    
    //自分の情報をアプリ内に記憶した後にgetCastLiveInfo
    func setMyInfoCastLiveInfo(row:Int){
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
//        var strPubGetLivePoint: String = ""
//        var strPubExGetLivePoint: String = ""
//        var strPubCoin: String = ""
//        var strPubExCoin: String = ""
//        var strPubMinReserveCoin: String = ""
        //var strCancelCoin: String = ""
        //var strCancelGetStar: String = ""
        //個別設定用
//        var strExLiveSec: String = ""
//        var strExGetLivePoint: String = ""
//        var strExExGetLivePoint: String = ""
//        var strExCoin: String = ""
//        var strExExCoin: String = ""
//        var strExMinReserveCoin: String = ""
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
                        //strPubGetLivePoint = obj.pub_get_live_point
                        //strPubExGetLivePoint = obj.pub_ex_get_live_point
                        //strPubCoin = obj.pub_coin
                        //strPubExCoin = obj.pub_ex_coin
                        //strPubMinReserveCoin = obj.pub_min_reserve_coin
                        //strCancelCoin = obj.cancel_coin
                        //strCancelGetStar = obj.cancel_get_star
                        //個別設定用
                        //strExLiveSec = obj.ex_live_sec
                        //strExGetLivePoint = obj.ex_get_live_point
                        //strExExGetLivePoint = obj.ex_ex_get_live_point
                        //strExCoin = obj.ex_coin
                        //strExExCoin = obj.ex_ex_coin
                        //strExMinReserveCoin = obj.ex_min_reserve_coin
                        strExStatus = obj.ex_status
                        
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
            /*
             //self.CollectionView.reloadData()
             //self.nameField.text = "モデル名："+self.strNames[0]
             //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
             UserDefaults.standard.set(userInfo[0].cast_rank, forKey: "cast_rank")
             UserDefaults.standard.set(userInfo[0].cast_official_flg, forKey: "cast_official_flg")//1:公式
             //キャスト月間ランキング
             UserDefaults.standard.set(userInfo[0].cast_month_ranking, forKey: "cast_month_ranking")
             //キャスト月間ランキングポイント
             UserDefaults.standard.set(userInfo[0].cast_month_ranking_point, forKey: "cast_month_ranking_point")
             */
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
            //キャスト月間ランキング
            UserDefaults.standard.set(strCastMonthRanking, forKey: "cast_month_ranking")
            //キャスト月間ランキングポイント
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
            
            //ストリーマーのライブ情報を取得し設定
            self.getCastLiveInfo(flg: 1, row: row)
            
        }
    }
    
    //ストリーマー個別の設定を取得し反映
    //flg=1 最後にsetDialogしサシライブへ
    //flg=2 最後に終了予想時間の画面を出力し数秒後に閉じる
    func getCastLiveInfo(flg: Int, row: Int){
        
        print("----------------")
        print(self.appDelegate.request_live_user_id)
        //print(self.appDelegate.request_cast_rank as Any)
        print("----------------")
        
        //2020-05-20追加
        //自分の現在の有償コイン数を取得
        //UserDefaults.standard.set(strPointPay, forKey: "myPointPay")
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        let myPointPay:Double = UserDefaults.standard.double(forKey: "myPointPay")
        
        if((self.castList[row].bank_info02 == "3"
            || self.castList[row].bank_info03 == "3"
            || self.castList[row].bank_info04 == "3"
            || self.castList[row].bank_info05 == "3")
            && Int(myPointPay) == 0
            && Int(myPoint) > 0){
            //無償コイン受付フラグが立っておらず、有償コインもない場合(無料コインがある場合)
            self.castSelectedDialogFree.mainLbl02.isHidden = true
            self.castSelectedDialogFree.mainLbl01.text
                = UtilStr.ERROR_SELECT_STREAMER_009
            self.castSelectedDialogFree.isHidden = false
            //最前面に
            self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialogFree)
            
            //5秒後に隠す
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                // 5.0秒後に実行したい処理
                self.castSelectedDialogFree.isHidden = true
                self.castSelectedDialogFree.mainLbl02.isHidden = false
            }
            
            return
        }
        
        //if(self.castList[buttonRow].ex_live_sec == "0"){
        if(self.castList[row].ex_status != "1"){
            //個別設定がしてない場合
            //キャストのランクを取得
            //let cast_rank = self.appDelegate.request_cast_rank
            let cast_rank = self.castList[row].cast_rank
            
            var stringUrl = Util.URL_GET_LIVE_RANK_INFO
            stringUrl.append("?rank_id=")
            stringUrl.append(cast_rank)
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
                        let json = try decoder.decode(ResultJsonLevel.self, from: data!)
                        //self.levelCount = json.count
                        
                        for obj in json.result {
                            self.appDelegate.get_live_point = Int(obj.get_live_point)!
                            self.appDelegate.ex_get_live_point = Int(obj.ex_get_live_point)!
                            self.appDelegate.live_pay_coin = Double(obj.coin)!
                            self.appDelegate.live_pay_ex_coin = Double(obj.ex_coin)!
                            self.appDelegate.min_reserve_coin = Int(obj.min_reserve_coin)!
                            //self.appDelegate.cancel_coin = Int(obj.cancel_coin)!
                            //self.appDelegate.cancel_get_star = Int(obj.cancel_get_star)!
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
                //1枠の秒数(基準値に設定)
                self.appDelegate.init_seconds = Util.INIT_LIVE_SECONDS

                // 背景が真っ黒にならなくなる
                //castInfo.modalPresentationStyle = .overCurrentContext
                // 下記を追加する
                //castInfo.modalPresentationStyle = .fullScreen
                //present(castInfo, animated: true, completion: nil)
                
                //最後の人の待ち人数
                //最後の人のトータル待ち時間　+ 最後の人のライブ時間(2分) ＝合計待ち時間
                /*self.setDialog(
                 cast_id:self.appDelegate.request_cast_id,
                 cast_name:self.appDelegate.request_cast_name!,
                 wait_num:temp_reserve_last_count,
                 wait_sec:temp_reserve_total_wait_sec)
                 */
                if(flg == 1){
                    //下記はelseの方の処理と同じ
                    //ライブ配信中のユーザーの名前（相手の名前とID）初期化
                    self.appDelegate.live_target_user_name = ""
                    self.appDelegate.live_target_user_id = 0
                    
                    self.setDialog(
                        cast_id:self.appDelegate.request_cast_id,
                        cast_name:self.appDelegate.request_cast_name!)
                    
                }else if(flg == 2){
                    //無料か有料かの判断
                    if(self.appDelegate.live_pay_ex_coin > 0.0){
                        //30分以上か未満かの判断
                        //var now_listener_name = ""
                        var now_listener_coin = 0.0
                        
                        //現在サシライブ中のリスナーのコイン数の取得
                        var stringUrl = Util.URL_USER_INFO
                        stringUrl.append("?user_id=")
                        stringUrl.append(self.castList[row].live_user_id)
                        //stringUrl.append("&my_user_id=")
                        //stringUrl.append(String(self.user_id))
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
                                    let json = try decoder.decode(UtilStruct.ResultUserLiveNowJson.self, from: data!)
                                    //self.idCount = json.count
                                    //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                                    for obj in json.result {
                                        //self.strSelectUserId = obj.user_name.toHtmlString()
                                        //self.strSelectUserName = obj.user_name.toHtmlString()
                                        //now_listener_name = obj.user_name.toHtmlString()
                                        now_listener_coin = Double(obj.point)!
                                        break
                                    }
                                    
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
                            //30分以上か未満かの判断
                            //var now_listener_coin = 0.0
                            //1回(1分)延長するのにかかるコイン数
                            //self.appDelegate.live_pay_ex_coin
                            
                            //有料ストリーマーかつライブ配信中の時にかぶせるダイアログ
                            //***さんは現在サシライブ中です。
                            self.castSelectedDialogCountDown.mainLbl01.text
                                = self.castList[row].user_name + UtilStr.ERROR_SELECT_COMMON_003
                            self.castSelectedDialogCountDown.isHidden = false
                            //最前面に
                            self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialogCountDown)

                            //分数のところ（切り捨て）
                            let minValue = Int(floor(now_listener_coin / self.appDelegate.live_pay_ex_coin))

                            //30分以上、約30分、約25分、約20分、約15分、約10分、約5分、約1分、1分以内
                            if(minValue <= 30 && minValue >= 26){
                                //26分以上30分以下 > 5秒後に非表示
                                //約30分
                                //約＊分のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"約30分")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                                
                            }else if(minValue < 26 && minValue >= 21){
                                //21分以上25分以下 > 5秒後に非表示
                                //約25分
                                //約＊分のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"約25分")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                                
                            }else if(minValue < 21 && minValue >= 16){
                                //16分以上20分以下 > 5秒後に非表示
                                //約20分
                                //約＊分のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"約20分")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                                
                            }else if(minValue < 16 && minValue >= 11){
                                //11分以上15分以下 > 5秒後に非表示
                                //約15分
                                //約＊分のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"約15分")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                                
                            }else if(minValue < 11 && minValue >= 6){
                                //6分以上10分以下 > 5秒後に非表示
                                //約10分
                                //約＊分のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"約10分")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                            }else if(minValue < 6 && minValue > 1){
                                //2分以上5分以下 > 5秒後に非表示
                                //約5分
                                //約＊分のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"約5分")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(2, 1))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }

                            }else if(minValue == 1){
                                //約1分 > 5秒後に非表示
                                //約＊分のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"約1分")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(2, 1))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                                
                            }else if(minValue == 0){
                                //1分以内 > 5秒後に非表示
                                //分以内のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"1分以内")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(1, 3))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                                
                            }else{
                                //30分以上 > 5秒後に非表示
                                //分以上のところのフォントを小さく
                                let attrText = NSMutableAttributedString(string:"30分以上")
                                attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(2, 3))
                                self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                                
                                //5秒後に隠す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                    // 5.0秒後に実行したい処理
                                    self.castSelectedDialogCountDown.isHidden = true
                                    self.castSelectedDialogCountDown.countdownLbl.text = ""
                                }
                            }
                        }
                    }else{
                        //無料ストリーマーかつライブ配信中の時にかぶせるダイアログ
                        //***さんは現在サシライブ中です。
                        self.castSelectedDialogFree.mainLbl01.text
                            = self.castList[row].user_name + UtilStr.ERROR_SELECT_COMMON_003
                        self.castSelectedDialogFree.isHidden = false
                        //最前面に
                        self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialogFree)
                        
                        //5秒後に隠す
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            // 5.0秒後に実行したい処理
                            self.castSelectedDialogFree.isHidden = true
                        }
                    }
                }
                //self.castSelectedDialog.isHidden = false
                //最前面に
                //self.view.bringSubviewToFront(self.castSelectedDialog)
            }
        }else{
            //個別設定がしてある場合
            //1枠の秒数
            self.appDelegate.init_seconds = Int(self.castList[row].ex_live_sec)!
            //キャストが得られる配信ポイント(最初の5分枠で得られるポイント)(スター)
            self.appDelegate.get_live_point = Int(self.castList[row].ex_get_live_point)!
            //延長時キャストが得られる配信ポイント(スター)
            self.appDelegate.ex_get_live_point = Int(self.castList[row].ex_ex_get_live_point)!
            //1回、視聴するのに消費するコイン
            self.appDelegate.live_pay_coin = Double(self.castList[row].ex_coin)!
            //1回、延長するのに消費するコイン(60秒を視聴するのに必要なコイン)
            self.appDelegate.live_pay_ex_coin = Double(self.castList[row].ex_ex_coin)!
            //予約するのに必要なコイン
            self.appDelegate.min_reserve_coin = Int(self.castList[row].ex_min_reserve_coin)!
            //予約をキャンセルする時に払うコイン
            //self.appDelegate.cancel_coin = Int(self.castList[buttonRow].ex_live_sec)!
            //予約をキャンセルされた場合に追加されるスター
            //self.appDelegate.cancel_get_star = Int(self.castList[buttonRow].ex_live_sec)!
            
            // 背景が真っ黒にならなくなる
            //castInfo.modalPresentationStyle = .overCurrentContext
            // 下記を追加する
            //castInfo.modalPresentationStyle = .fullScreen
            //present(castInfo, animated: true, completion: nil)
            
            //最後の人の待ち人数
            //最後の人のトータル待ち時間　+ 最後の人のライブ時間(2分) ＝合計待ち時間
            /*self.setDialog(
             cast_id:self.appDelegate.request_cast_id,
             cast_name:self.appDelegate.request_cast_name!,
             wait_num:temp_reserve_last_count,
             wait_sec:temp_reserve_total_wait_sec)
             */
            
            /******************************/
            //これ以降は個別設定していない時と同じ
            /******************************/
            if(flg == 1){
                //ライブ配信中のユーザーの名前（相手の名前とID）初期化
                self.appDelegate.live_target_user_name = ""
                self.appDelegate.live_target_user_id = 0
                
                self.setDialog(
                    cast_id:self.appDelegate.request_cast_id,
                    cast_name:self.appDelegate.request_cast_name!)
            }else if(flg == 2){
                //無料か有料かの判断
                if(self.appDelegate.live_pay_ex_coin > 0.0){
                    //30分以上か未満かの判断
                    //var now_listener_name = ""
                    var now_listener_coin = 0.0
                    
                    //現在サシライブ中のリスナーのコイン数の取得
                    var stringUrl = Util.URL_USER_INFO
                    stringUrl.append("?user_id=")
                    stringUrl.append(self.castList[row].live_user_id)
                    //stringUrl.append("&my_user_id=")
                    //stringUrl.append(String(self.user_id))
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
                                let json = try decoder.decode(UtilStruct.ResultUserLiveNowJson.self, from: data!)
                                //self.idCount = json.count
                                //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                                for obj in json.result {
                                    //self.strSelectUserId = obj.user_name.toHtmlString()
                                    //self.strSelectUserName = obj.user_name.toHtmlString()
                                    //now_listener_name = obj.user_name.toHtmlString()
                                    now_listener_coin = Double(obj.point)!
                                    break
                                }
                                
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
                        //30分以上か未満かの判断
                        //var now_listener_coin = 0.0
                        //1回(1分)延長するのにかかるコイン数
                        //self.appDelegate.live_pay_ex_coin
                        
                        //有料ストリーマーかつライブ配信中の時にかぶせるダイアログ
                        //***さんは現在サシライブ中です。
                        self.castSelectedDialogCountDown.mainLbl01.text
                            = self.castList[row].user_name + UtilStr.ERROR_SELECT_COMMON_003
                        self.castSelectedDialogCountDown.isHidden = false
                        //最前面に
                        self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialogCountDown)
                        
                        //分数のところ（切り捨て）
                        let minValue = Int(floor(now_listener_coin / self.appDelegate.live_pay_ex_coin))

                        //30分以上、約30分、約25分、約20分、約15分、約10分、約5分、約1分、1分以内
                        if(minValue <= 30 && minValue >= 26){
                            //26分以上30分以下 > 5秒後に非表示
                            //約30分
                            //約＊分のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"約30分")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                            
                        }else if(minValue < 26 && minValue >= 21){
                            //21分以上25分以下 > 5秒後に非表示
                            //約25分
                            //約＊分のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"約25分")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                            
                        }else if(minValue < 21 && minValue >= 16){
                            //16分以上20分以下 > 5秒後に非表示
                            //約20分
                            //約＊分のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"約20分")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                            
                        }else if(minValue < 16 && minValue >= 11){
                            //11分以上15分以下 > 5秒後に非表示
                            //約15分
                            //約＊分のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"約15分")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                            
                        }else if(minValue < 11 && minValue >= 6){
                            //6分以上10分以下 > 5秒後に非表示
                            //約10分
                            //約＊分のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"約10分")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(3, 1))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                        }else if(minValue < 6 && minValue > 1){
                            //2分以上5分以下 > 5秒後に非表示
                            //約5分
                            //約＊分のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"約5分")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(2, 1))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }

                        }else if(minValue == 1){
                            //約1分 > 5秒後に非表示
                            //約＊分のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"約1分")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, 1))
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(2, 1))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                            
                        }else if(minValue == 0){
                            //1分以内 > 5秒後に非表示
                            //分以内のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"1分以内")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(1, 3))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                            
                        }else{
                            //30分以上 > 5秒後に非表示
                            //分以上のところのフォントを小さく
                            let attrText = NSMutableAttributedString(string:"30分以上")
                            attrText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(2, 3))
                            self.castSelectedDialogCountDown.countdownLbl.attributedText = attrText
                            
                            //5秒後に隠す
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                // 5.0秒後に実行したい処理
                                self.castSelectedDialogCountDown.isHidden = true
                                self.castSelectedDialogCountDown.countdownLbl.text = ""
                            }
                        }
                    }
                }else{
                    //無料ストリーマーかつライブ配信中の時にかぶせるダイアログ
                    //***さんは現在サシライブ中です。
                    self.castSelectedDialogFree.mainLbl01.text
                        = self.castList[row].user_name + UtilStr.ERROR_SELECT_COMMON_003
                    self.castSelectedDialogFree.isHidden = false
                    //最前面に
                    self.appDelegate.window!.bringSubviewToFront(self.castSelectedDialogFree)
                    
                    //5秒後に隠す
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        // 5.0秒後に実行したい処理
                        self.castSelectedDialogFree.isHidden = true
                    }
                }
            }
            //self.castSelectedDialog.isHidden = false
            //最前面に
            //self.view.bringSubviewToFront(self.castSelectedDialog)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return idCount
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
                if(CGFloat(self.nowPage).truncatingRemainder(dividingBy: 3.0) == 0){
                    self.playerLayer00.isHidden = false
                    self.player00.play()
                    
                    if(self.player01.rate != 0 && self.player01.error == nil){
                        self.player01.pause()
                    }
                    
                    if(self.player02.rate != 0 && self.player02.error == nil){
                        self.player02.pause()
                    }
                    
                    self.appDelegate.castMoviePlayerNumSubMenu01 = 1
                }else if(CGFloat(self.nowPage).truncatingRemainder(dividingBy: 3.0) == 1){
                    self.playerLayer01.isHidden = false
                    self.player01.play()
                    
                    if(self.player00.rate != 0 && self.player00.error == nil){
                        self.player00.pause()
                    }
                    
                    if(self.player02.rate != 0 && self.player02.error == nil){
                        self.player02.pause()
                    }
                    
                    self.appDelegate.castMoviePlayerNumSubMenu01 = 2
                }else if(CGFloat(self.nowPage).truncatingRemainder(dividingBy: 3.0) == 2){
                    self.playerLayer02.isHidden = false
                    self.player02.play()
                    
                    if(self.player00.rate != 0 && self.player00.error == nil){
                        self.player00.pause()
                    }
                    
                    if(self.player01.rate != 0 && self.player01.error == nil){
                        self.player01.pause()
                    }
                    
                    self.appDelegate.castMoviePlayerNumSubMenu01 = 3
                }
            }else{
                //動画でない場合は、一旦停止
                if(self.player00.rate != 0 && self.player00.error == nil){
                    self.playerLayer00.isHidden = true
                    self.player00.pause()
                }
                
                if(self.player01.rate != 0 && self.player01.error == nil){
                    self.playerLayer01.isHidden = true
                    self.player01.pause()
                }
                
                if(self.player02.rate != 0 && self.player02.error == nil){
                    self.playerLayer02.isHidden = true
                    self.player02.pause()
                }
                
                self.appDelegate.castMoviePlayerNumSubMenu01 = 0
            }
        }
    }
    
    func follow(flg: Int!, to_user_id: Int!){
        //フォローの追加・削除 GET:from_user_id,to_user_id,flg
        //flg=1:追加 2:削除
        var stringUrl = Util.URL_FOLLOW_DO
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(to_user_id))
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
            UtilFunc.saveConnectLevelNew(user_id:self.user_id, target_user_id:to_user_id, exp:Util.CONNECTION_POINT_FOLLOW, live_count:0, present_point:0, flg:flg)
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
    
}
