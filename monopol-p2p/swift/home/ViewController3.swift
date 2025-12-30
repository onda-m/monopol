//
//  ViewController3.swift
//  swift_skyway
//
//  Created by onda on 2018/04/17.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
//import SkyWay
import XLPagerTabStrip
//import FirebaseStorage

class ViewController3: UIViewController,UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, IndicatorInfoProvider {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let menuStr = "2"
    let iconSize: CGFloat = 10.0
    //let iconSize2: CGFloat = 14.0
    
    // 画像の表示用
    //let storageRef = Storage.storage().reference(forURL: Util.URL_FIREBASE)
    
    // インジケータのインスタンス
    let indicator = UIActivityIndicatorView()
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "最新"
    
    //let cell_hi: CGFloat = 0.95//縦横比=161:150
    let cell_hi: CGFloat = 1.3//160:208
    
    var idCount:Int=0
    
    //fileprivate var peer: SKWPeer?
    //fileprivate var mediaConnection: SKWMediaConnection?
    //var hymPeer: HYMPeer!
    //var hymMedeiaConnection: HYMMediaConnection!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    var castList: [(user_id:String, uuid:String, user_name:String, photo_flg:String, photo_name:String, movie_flg:String, movie_name:String
        , value02:String, value03:String, value06:String, cast_rank:String, cast_official_flg:String, cast_month_ranking_point:String, freetext:String
        , live_password:String, login_status:String, reserve_user_id:String, reserve_flg:String
        , max_reserve_count:String, effect_flg02:String, bank_info02:String, bank_info03:String, bank_info04:String, bank_info05:String, ins_time:String, ex_live_sec:String, ex_get_live_point:String, ex_ex_get_live_point:String, ex_coin:String, ex_ex_coin:String, ex_min_reserve_coin:String, ex_status:String)] = []
    //castListのコピー
    var castListTemp: [(user_id:String, uuid:String, user_name:String, photo_flg:String, photo_name:String, movie_flg:String, movie_name:String
        , value02:String, value03:String, value06:String, cast_rank:String, cast_official_flg:String, cast_month_ranking_point:String, freetext:String
        , live_password:String, login_status:String, reserve_user_id:String, reserve_flg:String
        , max_reserve_count:String, effect_flg02:String, bank_info02:String, bank_info03:String, bank_info04:String, bank_info05:String, ins_time:String, ex_live_sec:String, ex_get_live_point:String, ex_ex_get_live_point:String, ex_coin:String, ex_ex_coin:String, ex_min_reserve_coin:String, ex_status:String)] = []
    
    /*
     // サムネイル画像の名前
     let photos = ["01","02","03","04","05","06","07"
     ,"01","02","03","04","05","06","07"
     ,"01","02","03","04","05","06","07"]
     var strUserIds: [String] = []
     var strPeerIds: [String] = []
     var strNames: [String] = []
     var strFollowNum: [String] = []
     var strOfficialFlg: [String] = []
     var strRankingPoint: [String] = []
     var strLivePassword: [String] = []
     var strLoginStatus: [String] = []
     var strInsTime: [String] = []
     */
    
    var selectedImage: UIImage?
    var selectedId:Int=0
    var selectedIndexPath: IndexPath?
    //static var selectedIndexCount:Int=0//押した回数「2」になっている場合は申請中の状態
    
    //cellのサイズ
    static var cellsize_height:CGFloat=0.0
    static var cellsize_width:CGFloat=0.0
    //var selectedId=""
    
    //下にスクロールした時にくるくる回すところ
    let refreshControl = UIRefreshControl()
    
    /****************************************/
    //以降すべて１、２、３共通（並び替えだけ違う）
    /****************************************/
    var timer = Timer()
    var modifyFlg = 0 //0:更新できる 1:更新できない(連続更新すると落ちるため回避策)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //最新アプリバージョンかのチェック
        //UtilFunc.appVersionCheck()
        
        //iphone Xのみテーブルのズレが生じる場合があるので、その対応
        if #available(iOS 11.0, *) {
            //self.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior
            self.CollectionView.contentInsetAdjustmentBehavior = .never
        }

        //timer処理(5秒ごとに実行する)
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            self.modifyFlg = 0
        })
        
        /*
         //ダイアログ以外、タップできないようにする
         if coverView == nil {
         coverView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
         // coverViewの背景
         coverView.backgroundColor = UIColor.black
         // 透明度を設定
         coverView.alpha = 0.4
         coverView.isUserInteractionEnabled = true
         self.view.addSubview(coverView)
         }
         coverView.isHidden = true
         */
        CollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(sender:)), for: .valueChanged)
        
        //UserDefaults.standard.set(2, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
        
        CollectionView.register(UINib(nibName: "ModelListViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        //リスト取得(自分以外の待機中のリストを取得)
        self.getModelList()

    }
    
    @objc func refresh(sender: UIRefreshControl) {
        //リロードなどの処理
        //coverView.isHidden = false
        
        if(self.modifyFlg == 0){
            self.modifyFlg = 1
            //リスト取得(自分以外の待機中のリストを取得)
            self.getModelList()
        }
        refreshControl.endRefreshing() //インジケータを終了する
        //self.coverView.isHidden = true
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.appDelegate.searchString = ""//重要(検索文字列をクリア)
        self.appDelegate.viewCallFromViewControllerId = ""
        self.appDelegate.viewReloadFlg = 0
    }
    
    //() -> ()の部分は　(引数) -> (返り値)を指定
    //func getModelList(_ after:@escaping () -> Void){
    func getModelList(){
        //リスト取得(自分以外の待機中のリストを取得)
        // UIActivityIndicatorView のスタイルをテンプレートから選択
        indicator.style = .whiteLarge
        // 表示位置
        indicator.center = self.view.center
        // 色の設定
        indicator.color = UIColor.gray
        // アニメーション停止と同時に隠す設定
        indicator.hidesWhenStopped = true
        // 画面に追加
        self.view.addSubview(indicator)
        // 最前面に移動
        self.view.bringSubviewToFront(indicator)
        // くるくるアニメーション開始
        indicator.startAnimating()
        
        //クリアする
        self.castListTemp.removeAll()
        
        //UUIDを取得
        //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        var stringUrl = Util.URL_GET_LIST
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&order=3")
        
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
                    let json = try decoder.decode(UtilStruct.ResultUserListJson.self, from: data!)
                    
                    self.idCount = json.count
                    
                    //表示するモデルリストを配列にする。
                    for obj in json.result {
                        if(obj.cast_official_flg != "3"){
                            //自動映像流すアカウント(cast_official_flg = 3)は注目のみ表示
                            let castInfo = (obj.user_id
                                ,obj.uuid
                                ,obj.user_name
                                ,obj.photo_flg
                                ,obj.photo_name
                                ,obj.movie_flg
                                ,obj.movie_name
                                ,obj.value02
                                ,obj.value03
                                ,obj.value06
                                ,obj.cast_rank
                                ,obj.cast_official_flg
                                ,obj.cast_month_ranking_point
                                ,obj.freetext
                                ,obj.live_password
                                ,obj.login_status
                                ,obj.reserve_user_id
                                ,obj.reserve_flg
                                ,obj.max_reserve_count
                                ,obj.effect_flg02
                                ,obj.bank_info02
                                ,obj.bank_info03
                                ,obj.bank_info04
                                ,obj.bank_info05
                                ,obj.ins_time
                                ,obj.ex_live_sec
                                ,obj.ex_get_live_point
                                ,obj.ex_ex_get_live_point
                                ,obj.ex_coin
                                ,obj.ex_ex_coin
                                ,obj.ex_min_reserve_coin
                                ,obj.ex_status
                            )
                            
                            //配列へ追加
                            self.castList.append(castInfo)
                            self.castListTemp.append(castInfo)
                        }
                    }
                    
                    dispatchGroup.leave()
                    //self.CollectionView.reloadData()
                    //print(json.result)
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        //    self.CollectionView.reloadData()
        //}
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //コピーする
            self.castList = self.castListTemp
            
            self.indicator.stopAnimating()
            //リストの取得を待ってから更新
            self.CollectionView.reloadData()
            //self.coverView.isHidden = true
            
            //下記をしないと、iphoneXなどで画面下部が見切れる
            if #available(iOS 11.0, *) {
                //safeareaのボトム調整
                let bottomSafeAreaHeight:CGFloat = CGFloat(UserDefaults.standard.float(forKey: "bottomSafeAreaHeight"))
                
                print(bottomSafeAreaHeight) // iPhoneXなら34,  その他は0
                
                //safeareaを考慮
                let width = self.view.frame.width
                //let height = self.view.frame.height
                
                let x_temp = (width - self.CollectionView.frame.width) / 2
                //let height_temp = self.CollectionView.frame.height
                let height_temp = self.view.frame.height
                //self.CollectionView.frame = CGRect(x: x_temp, y: 0, width: self.CollectionView.frame.width, height: self.CollectionView.frame.height - bottomSafeAreaHeight)
                self.CollectionView.frame = CGRect(x: x_temp, y: 0, width: self.CollectionView.frame.width, height: height_temp - bottomSafeAreaHeight)
                self.CollectionView.contentSize = CGSize(width:self.CollectionView.frame.width, height:height_temp + bottomSafeAreaHeight)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //hymPeer?.close()
        //hymPeer?.destroy()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     //スクロールを検知した時の処理
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
     //if (scrollView.contentOffset.y >= tableView.contentSize.height - self.tableView.bounds.size.height) {
     //    callAPI(apiurl: "hoge.com/api/data/")
     //}
     //クリアする
     let subviews = CollectionView.subviews
     for subview in subviews {
     Util.removeSubviews(parentView: subview)
     }
     UserDefaults.standard.set(0, forKey: "selectedIndexCount")
     //クリアする(ここまで)
     }
     */
    
    //モデル一覧の箇所
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:ModelListViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath) as! ModelListViewCell
        //let testCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        //let imageView = testCell.contentView.viewWithTag(91) as! UIImageView
        let imageView = testCell.castImageView
        
        //ユーザー画像の表示
        let photoFlg = castList[indexPath.row].photo_flg
        let photoName = castList[indexPath.row].photo_name
        let user_id = castList[indexPath.row].user_id

        //写真URL
        if(photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + user_id + "_list.jpg"
            let photoUrl = "user_images/" + user_id + "/" + photoName + "_list.jpg"
            //画像キャッシュを使用
            imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
        }else{
            let cellImage = UIImage(named:"demo_noimage")
            // UIImageをUIImageViewのimageとして設定
            imageView?.image = cellImage
        }
        
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
        testCell.profileBtn.setTitle(strFreeTextTemp, for: .normal)
        testCell.profileBtn.titleLabel!.lineBreakMode = NSLineBreakMode.byCharWrapping
        testCell.profileBtn.titleLabel!.numberOfLines = 3
        testCell.profileBtn.titleLabel!.textAlignment = NSTextAlignment.left
        testCell.profileBtn.layer.cornerRadius = 8// 角を丸める
        
        //pr動画フラグ
        let movieFlg = castList[indexPath.row].movie_flg
        
        //左下の動画アイコンのところ
        let pr_movie_image = testCell.prMovieImageView as UIImageView
        
        if(movieFlg == "1"){
            //動画設定済み
            pr_movie_image.isHidden = false
        }else{
            pr_movie_image.isHidden = true
        }
        
        /**************************************************************/
        //ストリーマー作成のイベント関連
        /**************************************************************/
        //イベント表示フラグ
        //let eventFlg = castList[indexPath.row].effect_flg02
        //右下のイベントラベルのところ
        let event_label = testCell.eventLabel as UILabel
        /*
        if(eventFlg == "1"){
            //イベント表示
            event_label.isHidden = false
        }else{
            event_label.isHidden = true
        }*/
        event_label.isHidden = true
        
        //イベント直前の画像の表示・非表示
        let eventNowFlg = castList[indexPath.row].value06
        let event_now_image = testCell.eventNowImageView as UIImageView
        
        if(eventNowFlg == "1"){
            //イベント直前の画像の表示
            event_now_image.isHidden = false
        }else{
            event_now_image.isHidden = true
        }
        /**************************************************************/
        //ストリーマー作成のイベント関連(ここまで)
        /**************************************************************/
        
        // Tag番号を使ってLabelのインスタンス生成
        //キャスト名
        //let label = testCell.contentView.viewWithTag(92) as! UILabel
        let label = testCell.profileLabel as UILabel
        label.text = castList[indexPath.row].user_name.toHtmlString()
        
        // Tag番号を使ってLabelのインスタンス生成
        //1:待機中 2:通話中 3:ログオフ状態
        //let label_status = testCell.contentView.viewWithTag(93) as! UILabel
        let label_status = testCell.statusLabel as UILabel
        
        // Tag番号を使ってLabelのインスタンス生成
        //パスワードアイコンのところ
        //let image_password = testCell.contentView.viewWithTag(97) as! UIImageView
        let image_password = testCell.passwordImageView as UIImageView
        
        // Tag番号を使ってLabelのインスタンス生成
        //右上の状態アイコンのところ
        //let image_status = testCell.contentView.viewWithTag(99) as! UIImageView
        let image_status = testCell.statusImageView as UIImageView
        
        //左上のイベントアイコンのところ
        let image_event = testCell.eventImageView as UIImageView
        
        //右下の無料サシライブアイコン
        let image_live_free = testCell.liveFreeImageView as UIImageView
        //右下の無料サシライブアイコン非表示
        image_live_free.isHidden = true
        
        //予約可のところ
        //let label_onlive = testCell.contentView.viewWithTag(96) as! UILabel
        let label_onlive = testCell.onliveLabel as UILabel
        label_onlive.backgroundColor = Util.CAST_LIST_RESERVE_BG
        // 角丸
        label_onlive.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        label_onlive.layer.masksToBounds = true
        
        if(castList[indexPath.row].bank_info02 == "1"
            || castList[indexPath.row].bank_info03 == "1"
            || castList[indexPath.row].bank_info04 == "1"
            || castList[indexPath.row].bank_info05 == "1"){
            //キャッシュバックイベントのストリーマーの場合
            //左上のイベントアイコン
            image_event.image = UIImage(named:"cast_list_event")
            image_event.isHidden = false
        }else{
            //イベントに参加していない人
            image_event.isHidden = true
        }
        
        if(castList[indexPath.row].login_status == "1"){
            //welcome
            //待機状態の帯
            //label_status.isHidden = false
            //label_status.text = "Welcome"
            label_status.textColor = Util.CAST_STATUS_COLOR_WAIT
            //label_status.backgroundColor = Util.WELCOME_LABEL_COLOR
            
            //右上のステータスアイコン
            let cellImageStatus = UIImage(named:"cast_list_welcome")
            image_status.image = cellImageStatus
            image_status.isHidden = false
            
            //パスワードアイコン
            if(castList[indexPath.row].live_password == "0"){
                //通常
                image_password.isHidden = true
            }else{
                //パスワード付き
                image_password.isHidden = false
            }
            
            //予約可のところ
            label_onlive.isHidden = true
            
            //右下の無料サシライブアイコン表示
            if(castList[indexPath.row].bank_info02 == "2"
                || castList[indexPath.row].bank_info03 == "2"
                || castList[indexPath.row].bank_info04 == "2"
                || castList[indexPath.row].bank_info05 == "2"){
                //ミスいちごイベント参加のストリーマーの場合
                image_live_free.image = UIImage(named:"missichigo_icon")
                image_live_free.isHidden = false
            }else{
                //イベントに参加していない人
                //無料か有料かの判断（無料のみ表示）
                if(castList[indexPath.row].ex_status == "1"){
                    //1設定済み（プレミアムユーザー）
                    image_live_free.image = UIImage(named:"live_premium_icon")
                    image_live_free.isHidden = false
                }else if(castList[indexPath.row].ex_status == "3"){
                    //3設定済み無効＞無料ユーザー
                    image_live_free.image = UIImage(named:"live_free_icon")
                    image_live_free.isHidden = false
                }else if(castList[indexPath.row].ex_status != "1"){
                    //1有効2無効3設定済み無効
                    if(castList[indexPath.row].cast_rank == "1"){
                        //無料サシライブの場合
                        image_live_free.image = UIImage(named:"live_free_icon")
                        image_live_free.isHidden = false
                    }else{
                        //有料サシライブの場合
                        image_live_free.isHidden = true
                    }
                }else{
                    image_live_free.isHidden = true
                }
            }
        }else if(castList[indexPath.row].login_status == "2"
            || castList[indexPath.row].login_status == "4"
            || castList[indexPath.row].login_status == "5"
            || castList[indexPath.row].login_status == "6"
            || castList[indexPath.row].login_status == "7"
            ){
            //ライブ中
            //0:会員登録中 1:待機中 2:通話中 3:ログオフ状態 4:通話中(予約申請) 5:通話中(予約済) 6:予約キャンセル 7:キャストによる予約拒否 98:削除 99:リストア済み
            //待機状態の帯
            //label_status.isHidden = false
            //label_status.text = "On Live"
            label_status.textColor = Util.CAST_STATUS_COLOR_ONLIVE
            //label_status.backgroundColor = Util.ON_LIVE_LABEL_COLOR
            
            //パスワードアイコン
            if(castList[indexPath.row].live_password == "0"){
                //通常
                image_password.isHidden = true
            }else{
                //パスワード付き
                image_password.isHidden = false
            }
            
            /***************************************/
            /*初期リリース時は予約不可*/
            /***************************************/
            //予約不可
            label_onlive.isHidden = true
            
            //右上のステータスアイコン
            let cellImageStatus = UIImage(named:"cast_list_onlive")
            image_status.image = cellImageStatus
            image_status.isHidden = false
            
            //右下の無料サシライブアイコン表示
            if(castList[indexPath.row].bank_info02 == "2"
                || castList[indexPath.row].bank_info03 == "2"
                || castList[indexPath.row].bank_info04 == "2"
                || castList[indexPath.row].bank_info05 == "2"){
                //ミスいちごイベント参加のストリーマーの場合
                image_live_free.image = UIImage(named:"missichigo_icon")
                image_live_free.isHidden = false
            }else{
                //イベントに参加していない人
                //無料か有料かの判断(プレミアムユーザーのみ表示)
                if(castList[indexPath.row].ex_status == "1"){
                    //1設定済み（プレミアムユーザー）
                    image_live_free.image = UIImage(named:"live_premium_icon")
                    image_live_free.isHidden = false
                }else if(castList[indexPath.row].ex_status == "3"){
                    //3設定済み無効＞無料ユーザー
                    //image_live_free.image = UIImage(named:"live_free_icon")
                    image_live_free.isHidden = true
                }
            }
            
            /*
             //予約可のところ
             if(castList[indexPath.row].reserve_flg == "1"){
             //予約不可
             label_onlive.isHidden = true
             
             //右上のステータスアイコン
             let cellImageStatus = UIImage(named:"cast_list_reserve")
             image_status.image = cellImageStatus
             image_status.isHidden = false
             }else{
             if(castList[indexPath.row].login_status == "2"
             || castList[indexPath.row].login_status == "6"
             || castList[indexPath.row].login_status == "7"){
             //予約可能
             label_onlive.isHidden = false
             
             //右上のステータスアイコン
             let cellImageStatus = UIImage(named:"cast_list_onlive")
             image_status.image = cellImageStatus
             image_status.isHidden = false
             }else{
             //予約不可
             label_onlive.isHidden = true
             
             //右上のステータスアイコン
             let cellImageStatus = UIImage(named:"cast_list_reserve")
             image_status.image = cellImageStatus
             image_status.isHidden = false
             }
             }
             */
            /***************************************/
            /*初期リリース時は予約不可（ここまで）*/
            /***************************************/
        }else if(castList[indexPath.row].login_status == "3"){
            //待機状態のアイコン
            //label_status.isHidden = true
            label_status.textColor = Util.CAST_STATUS_COLOR_OFF
            //右上のステータスアイコン
            image_status.isHidden = true
            //パスワードアイコン
            image_password.isHidden = true
            //予約可のところ
            label_onlive.isHidden = true
            
            //右下の無料サシライブアイコン表示
            if(castList[indexPath.row].bank_info02 == "2"
                || castList[indexPath.row].bank_info03 == "2"
                || castList[indexPath.row].bank_info04 == "2"
                || castList[indexPath.row].bank_info05 == "2"){
                //ミスいちごイベント参加のストリーマーの場合
                image_live_free.image = UIImage(named:"missichigo_icon")
                image_live_free.isHidden = false
            }else{
                //イベントに参加していない人
                //無料か有料かの判断(プレミアムユーザーのみ表示)
                if(castList[indexPath.row].ex_status == "1"){
                    //1設定済み（プレミアムユーザー）
                    image_live_free.image = UIImage(named:"live_premium_icon")
                    image_live_free.isHidden = false
                }else if(castList[indexPath.row].ex_status == "3"){
                    //3設定済み無効＞無料ユーザー
                    //image_live_free.image = UIImage(named:"live_free_icon")
                    image_live_free.isHidden = true
                }
            }
        }else{
            //待機状態のアイコン
            //label_status.isHidden = true
            label_status.textColor = Util.CAST_STATUS_COLOR_OFF
            //右上のステータスアイコン
            image_status.isHidden = true
            //パスワードアイコン
            image_password.isHidden = true
            //予約可のところ
            label_onlive.isHidden = true
            
            //右下の無料サシライブアイコン表示
            if(castList[indexPath.row].bank_info02 == "2"
                || castList[indexPath.row].bank_info03 == "2"
                || castList[indexPath.row].bank_info04 == "2"
                || castList[indexPath.row].bank_info05 == "2"){
                //ミスいちごイベント参加のストリーマーの場合
                image_live_free.image = UIImage(named:"missichigo_icon")
                image_live_free.isHidden = false
            }else{
                //イベントに参加していない人
                //無料か有料かの判断(プレミアムユーザーのみ表示)
                if(castList[indexPath.row].ex_status == "1"){
                    //1設定済み（プレミアムユーザー）
                    image_live_free.image = UIImage(named:"live_premium_icon")
                    image_live_free.isHidden = false
                }else if(castList[indexPath.row].ex_status == "3"){
                    //3設定済み無効＞無料ユーザー
                    //image_live_free.image = UIImage(named:"live_free_icon")
                    image_live_free.isHidden = true
                }
            }
        }
        
        // Tag番号を使ってLabelのインスタンス生成
        //ランキングポイントのところ
        //let label_ranking_point = testCell.contentView.viewWithTag(94) as! UILabel
        let label_ranking_point = testCell.rankingPointLabel as UILabel
        //let view_ranking_point:UIView = testCell.contentView.viewWithTag(98)!
        
        if(Double(castList[indexPath.row].cast_month_ranking_point)! > 0.0){
            //label_ranking_point.text = Util.numFormatter(num:Int(castList[indexPath.row].cast_month_ranking_point)!)
            //ラベルの枠を自動調節する
            label_ranking_point.adjustsFontSizeToFitWidth = true
            label_ranking_point.minimumScaleFactor = 0.3
            label_ranking_point.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(Double(castList[indexPath.row].cast_month_ranking_point)!)), iconImage: UIImage(named:"castinfo_rank_ico")!, iconSize: self.iconSize, lineHeight: 1.0)
            // 角丸
            label_ranking_point.layer.cornerRadius = 4
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            label_ranking_point.layer.masksToBounds = true
            
            label_ranking_point.backgroundColor = Util.CAST_LIST_RANKING_POINT_BG
            
            label_ranking_point.isHidden = false
        }else{
            label_ranking_point.isHidden = true
        }
        
        // Tag番号を使ってLabelのインスタンス生成
        //公式ラベルのところ
        //let label_official = testCell.contentView.viewWithTag(95) as! UILabel
        let label_official = testCell.officialLabel as UILabel
        
        if(castList[indexPath.row].cast_official_flg == "1"){
            //1:公式
            label_official.isHidden = false
            // 角丸
            label_official.layer.cornerRadius = 4
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            label_official.layer.masksToBounds = true
        }else{
            label_official.isHidden = true
        }
        
        /*
         //影をつける
         testCell.layer.masksToBounds = false //必須
         testCell.layer.shadowOffset = CGSize(width: 1, height: 1)
         testCell.layer.shadowOpacity = 0.9
         testCell.layer.shadowRadius = 2.0
         */
        
        // 角丸
        testCell.layer.cornerRadius = 5
        imageView?.layer.cornerRadius = 5
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        testCell.layer.masksToBounds = true
        imageView?.layer.masksToBounds = true
        
        // 枠線の色
        //testCell.layer.borderColor = Util.SUKOSHIUSUI_GRAY_COLOR.cgColor
        // 枠線の太さ
        //testCell.layer.borderWidth = 1
        testCell.layer.borderWidth = 0
        
        //プロフィールボタンを押した時の処理
        testCell.profileBtn.tag = indexPath.row
        testCell.profileBtn.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        
        //重なり優先の変更
        testCell.profileLabel.layer.zPosition=4//above
        testCell.profileBtn.layer.zPosition=3//above
        testCell.triangleBtn.layer.zPosition=2//below
        
        //print("table create")
        return testCell
    }
    
    //プロフィールボタンを押した時
    @objc func onClick(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag//indexPath.row
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = castList[buttonRow].user_id
        UtilToViewController.toUserInfoViewController()
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //ViewController.cellsize_width = self.view.bounds.width/2 - 10
        //ViewController.cellsize_height = self.view.bounds.width * cell_hi / 2 - 2
        
        //パターン１
        ViewController.cellsize_width = self.view.bounds.width/2 - 18
        ViewController.cellsize_height = self.view.bounds.width * cell_hi / 2 - 2
        
        //パターン2
        //ViewController.cellsize_width = self.view.bounds.width/2 - 18
        //ViewController.cellsize_height = self.view.bounds.width * cell_hi / 2 - 4
        
        //パターン3
        //ViewController.cellsize_width = self.view.bounds.width/2 - 30
        //ViewController.cellsize_height = self.view.bounds.width * cell_hi / 2 - 2
        
        
        //ViewController.cellsize_width = self.view.bounds.width/2 - 4
        //ViewController.cellsize_height = self.view.bounds.width/2 + 2
        
        //スペースを空ける
        //ViewController.cellsize_width = self.view.bounds.width/2 - 16
        //ViewController.cellsize_height = self.view.bounds.width * cell_hi / 2 - 2
        
        //cellsize_width = cellSize
        //cellsize_height = cellSize * cell_hi//高さは少しだけ小さく(見た目をcellに合わせるため)
        //cellsize_height = cellSize - 10//高さは少しだけ小さく(見た目をcellに合わせるため)
        
        //cell_size_width = ViewController.cellsize_width
        //cell_size_height = ViewController.cellsize_height
        
        return CGSize(width: ViewController.cellsize_width, height: ViewController.cellsize_height)
    }
    
    /////////追加(ここから)////////////////////////////
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Util.toCastSelectViewController()
        //Util.toMainCastSelectViewController()
        
        //画面遷移のタイミングでパーミッションチェック
        //UtilFunc.checkPermissionMicrophone()
        
        //print(sender)
        let buttonRow = indexPath.row
        //print(selectedId)
        let modelMovieInfo: MainCastSelectViewController = self.storyboard!.instantiateViewController(withIdentifier: "toMainCastSelectViewController") as! MainCastSelectViewController
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //modelInfo.sendId = strPeerIds[selectedId]
        appDelegate.sendId = castList[buttonRow].user_id
        appDelegate.sendSubMenuFirst = menuStr
        UserDefaults.standard.set(self.menuStr, forKey: "selectedSubMenu")
        //print("-----------------")
        //print(self.menuStr)
        //print("-----------------")
        
        // 下記を追加する
        modelMovieInfo.modalPresentationStyle = .fullScreen
        
        present(modelMovieInfo, animated: true, completion: nil)
        
        /*
         //現在の選択ずみのセルを未選択状態にする
         //if(selectedIndexPath != nil){
         //    let now_cell = collectionView.cellForItem(at: selectedIndexPath!)
         //    Util.removeSubviews(parentView: now_cell!)
         //}
         //クリアする
         let subviews = collectionView.subviews
         for subview in subviews {
         Util.removeSubviews(parentView: subview)
         }
         //下記はクリアしてはいけない
         //UserDefaults.standard.set(0, forKey: "selectedIndexCount")
         //クリアする(ここまで)
         
         //UserDefaults.standard.set(int, forKey: "selectedIndexCount")
         let selectedCount = UserDefaults.standard.integer(forKey: "selectedIndexCount")
         
         //選択したセルにViewを重ねる
         let cell = collectionView.cellForItem(at: indexPath)!
         //cell?.selectedBackgroundView(UIColor.lightGrayColor())
         
         let selectedView:ListSelectedview = UINib(nibName: "ListSelectedview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! ListSelectedview
         
         //1:待機中 2:通話中 3:ログオフ状態
         if(castList[indexPath.row].login_status == "1"){
         //待機中のキャスト
         
         if(selectedCount == 0){
         //1回めのタップ
         UserDefaults.standard.set(1, forKey: "selectedIndexCount")
         }else if(selectedCount == 1 && selectedIndexPath == indexPath){
         //2回めのタップ
         UserDefaults.standard.set(2, forKey: "selectedIndexCount")
         }else if(selectedIndexPath != indexPath){
         //1回めのタップ
         UserDefaults.standard.set(1, forKey: "selectedIndexCount")
         }
         
         //選択したセルを保存
         selectedIndexPath = indexPath
         let index = CollectionView.indexPathsForSelectedItems?.first
         selectedId = index![1]
         
         //選択したキャスト名を一時保存
         //かぶせるダイアログで使用するため
         //let appDelegate = UIApplication.shared.delegate as! AppDelegate
         //appDelegate.live_target_select_user_name = strNames[selectedId]
         
         // ポップアップビュー背景色
         let viewColor = UIColor.black
         // 半透明にして親ビューが見えるように。透過度はお好みで。
         selectedView.backgroundColor = viewColor.withAlphaComponent(0.7)
         //重ねるVIEWのサイズを指定
         //selectedView.frame = CGRect(x: -1.0, y: 0.0, width: ViewController.cellsize_width + 1, height: ViewController.cellsize_height - Util.TOP_LABLE_HEIGHT)
         selectedView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width/2 , height: self.view.bounds.width * cell_hi / 2 - Util.TOP_LABLE_HEIGHT)
         
         
         let temp_selectedCount = UserDefaults.standard.integer(forKey: "selectedIndexCount")
         //かぶせるダイアログの設定
         selectedView.selectedViewSetting(cast_id:Int(castList[indexPath.row].user_id)!
         ,cast_uuid:castList[indexPath.row].uuid
         , cast_name:castList[indexPath.row].user_name
         , password:castList[indexPath.row].live_password
         , frame_count:1, count:temp_selectedCount)//1枠
         
         cell.addSubview(selectedView)
         
         }else if(castList[indexPath.row].login_status == "2"){
         //配信中
         if(selectedCount == 0){
         //1回めのタップ
         UserDefaults.standard.set(1, forKey: "selectedIndexCount")
         }else if(selectedCount == 1 && selectedIndexPath == indexPath){
         //2回めのタップ
         UserDefaults.standard.set(2, forKey: "selectedIndexCount")
         }else if(selectedIndexPath != indexPath){
         //1回めのタップ
         UserDefaults.standard.set(1, forKey: "selectedIndexCount")
         }
         
         //選択したセルを保存
         selectedIndexPath = indexPath
         
         //選択中のセルの画像を取得する。
         let index = CollectionView.indexPathsForSelectedItems?.first
         selectedId = index![1]
         
         // ポップアップビュー背景色
         let viewColor = UIColor.black
         // 半透明にして親ビューが見えるように。透過度はお好みで。
         selectedView.backgroundColor = viewColor.withAlphaComponent(0.7)
         //重ねるVIEWのサイズを指定
         selectedView.frame = CGRect(x: -1.0, y: 0.0, width: ViewController.cellsize_width + 1, height: ViewController.cellsize_height - Util.TOP_LABLE_HEIGHT)
         
         let temp_selectedCount = UserDefaults.standard.integer(forKey: "selectedIndexCount")
         //かぶせるダイアログの設定
         selectedView.selectedViewSetting(cast_id:Int(castList[indexPath.row].user_id)!
         ,cast_uuid:castList[indexPath.row].uuid
         , cast_name:castList[indexPath.row].user_name
         , password:castList[indexPath.row].live_password
         , frame_count:1
         , count:temp_selectedCount)//1枠
         
         cell.addSubview(selectedView)
         }else if(castList[indexPath.row].login_status == "3"){
         //ログオフ状態
         //選択したセルをクリア
         selectedIndexPath = nil
         }else{
         //その他
         //選択したセルをクリア
         selectedIndexPath = nil
         }
         */
        
        
        /*
         //print(selectedId)
         let modelInfo: MainTelViewController = self.storyboard!.instantiateViewController(withIdentifier: "toMainTelViewController") as! MainTelViewController
         
         //モデルのpeerIdを次の画面（モデル詳細画面）へ渡す
         //modelInfo.sendId = strPeerIds[selectedId]
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         appDelegate.sendId = strPeerIds[selectedId]
         
         // 下記を追加する
         modelInfo.modalPresentationStyle = .fullScreen
         
         present(modelInfo, animated: false, completion: nil)
         */
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return idCount;
    }
}
