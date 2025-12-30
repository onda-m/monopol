//
//  SashiLiveViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/18.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SashiLiveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {

    let iconSize: CGFloat = 12.0
    let iconSize2: CGFloat = 18.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "サシライブ"
    
    var user_id: Int = 0//自分のID
    
    //ランキング1位に関するところ
    @IBOutlet weak var rank01View: UIView!
    @IBOutlet weak var rank01CrownImageView: UIImageView!
    @IBOutlet weak var rank01ImageView: EnhancedCircleImageView!
    @IBOutlet weak var rank01NameLbl: UILabel!
    @IBOutlet weak var rank01PointLbl: UILabel!
    @IBOutlet weak var rank01LiveCountLbl: UILabel!
    @IBOutlet weak var rank01FollowBtn: UIButton!
    
    @IBOutlet weak var mainTableView: UITableView!
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    //ランキングの一覧用
    struct RankingResult: Codable {
        let user_id: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let movie_flg: String
        let movie_name: String
        let value01: String
        let value02: String
        let value03: String
        let value04: String
        let value05: String
        let live_point: String
        let watch_level: String
        let live_level: String
        let cast_rank: String
        let cast_official_flg: String
        let cast_month_ranking: String
        let cast_month_ranking_point: String
        let cast_month_live_count: String
        let freetext: String
        let login_status: String
        let follow_id: String
    }
    struct ResultRankingJson: Codable {
        let count: Int
        let result: [RankingResult]
    }
    
    var rankingList: [(user_id:String, user_name:String
    , photo_flg:String, photo_name:String, movie_flg:String, movie_name:String
    , value01:String, value02:String, value03:String, value04:String, value05:String, live_point:String
    , watch_level:String, live_level:String, cast_rank:String, cast_official_flg:String, cast_month_ranking:String
    , cast_month_ranking_point:String, cast_month_live_count:String, freetext:String, login_status:String, follow_id: String)] = []

    var rankingListTemp: [(user_id:String, user_name:String
        , photo_flg:String, photo_name:String, movie_flg:String, movie_name:String
        , value01:String, value02:String, value03:String, value04:String, value05:String, live_point:String
        , watch_level:String, live_level:String, cast_rank:String, cast_official_flg:String, cast_month_ranking:String
        , cast_month_ranking_point:String, cast_month_live_count:String, freetext:String, login_status:String, follow_id: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //自分のuser_idを指定
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //テーブルの区切り線を非表示
        self.mainTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.mainTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.mainTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.mainTableView.allowsSelection = false // 選択を不可にする
        self.mainTableView.isScrollEnabled = true
        self.mainTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        // Do any additional setup after loading the view.
        
        self.mainTableView.register(UINib(nibName: "RankingSashiLiveTableViewCell", bundle: nil), forCellReuseIdentifier: "RankingSashiLive")
        /*
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )*/
    }
    
    /*
    @objc func onDidBecomeActive(_ notification: Notification?) {
        //戻ってきた時にも実行
        if (self.isViewLoaded && (self.view.window != nil)) {
            self.getCastRanking()
        }
    }*/
    
    deinit {
        //画面から離れる場合
        //print("deinit is called by sashi_live.")
        
        //値を初期化
        self.appDelegate.viewCallFromViewControllerId = ""
        self.appDelegate.viewReloadFlg = 0
        //var viewCallFromViewControllerId:String?//UserInfoViewControllerの呼び出し元ViewController
        //var viewReloadFlg:Int = 0//1:UserInfoViewControllerを閉じた時にリロードが必要
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //はじめに現在のViewControllerをセット
        //キャスト詳細＞フォロー後に戻ってきた時にリロードするための対策
        self.appDelegate.viewCallFromViewControllerId = "SashiLiveViewController"
        self.appDelegate.viewReloadFlg = 0

        self.getCastRanking()
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //戻ってきた時にも実行
        self.getCastRanking()
    }
    */
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapRank01ImageBtn(_ sender: Any) {
        //1位のキャスト画像をクリック時
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[0].user_id
        UtilToViewController.toUserInfoViewController()
    }
    
    @IBAction func tapRank01FollowBtn(_ sender: Any) {
        //print(sender)
        let buttonRow = 0
        //UIAlertControllerを用意する
        let strCastName = self.rankingList[buttonRow].user_name
        let targetId = Int(self.rankingList[buttonRow].user_id)
        let followId = self.rankingList[buttonRow].follow_id
        
        let actionAlert = UIAlertController(title: strCastName, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if(followId != "0"){
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォロー解除", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:2, target_id:targetId)
                
                //この人をフォローしていない場合
                self.rank01FollowBtn.setTitle("+フォロー", for: .normal)
                self.rank01FollowBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                self.rank01FollowBtn.backgroundColor = UIColor.white
                self.rank01FollowBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                self.rank01FollowBtn.layer.borderWidth = 0.5
                
                self.rankingList[buttonRow].follow_id = "0"
                
            })
            actionAlert.addAction(modifyAction)
        }else{
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォローする", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:1, target_id:targetId)
                
                //この人をフォローしている場合
                self.rank01FollowBtn.setTitle("フォロー中", for: .normal)
                self.rank01FollowBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                self.rank01FollowBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                self.rank01FollowBtn.layer.borderWidth = 0
                
                //follow_idに何か数値を入れておく
                self.rankingList[buttonRow].follow_id = "1"
            })
            actionAlert.addAction(modifyAction)
        }
        
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
    
    func getCastRanking(){
        //クリアする
        self.rank01View.isHidden = true
        self.rankingListTemp.removeAll()
        
        //リスト取得
        //GET:limit,user_id
        var stringUrl = Util.URL_GET_MONTH_CAST_RANKING
        stringUrl.append("?user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&limit=")
        stringUrl.append(String(Util.MONTH_CAST_RANKING_LIMIT))
        
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
                    let json = try decoder.decode(ResultRankingJson.self, from: data!)
                    //self.idCount = json.count
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        //ブラックリストの配列にない場合はnilが返される
                        if self.appDelegate.array_black_list.index(of: Int(obj.user_id)!) == nil {
                            //配列へ追加
                            let ranking = (obj.user_id
                                ,obj.user_name
                                ,obj.photo_flg
                                ,obj.photo_name
                                ,obj.movie_flg
                                ,obj.movie_name
                                ,obj.value01
                                ,obj.value02
                                ,obj.value03
                                ,obj.value04
                                ,obj.value05
                                ,obj.live_point
                                ,obj.watch_level
                                ,obj.live_level
                                ,obj.cast_rank
                                ,obj.cast_official_flg
                                ,obj.cast_month_ranking
                                ,obj.cast_month_ranking_point
                                ,obj.cast_month_live_count
                                ,obj.freetext
                                ,obj.login_status
                                ,obj.follow_id)
                            
                            self.rankingList.append(ranking)
                            self.rankingListTemp.append(ranking)
                        }
                    }
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                    print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //コピーする
            self.rankingList = self.rankingListTemp
            
            if(self.rankingList.count == 0){
                self.rank01View.isHidden = true
            }else{
                self.rank01View.isHidden = false

                //1位の表示
                let photoFlg = self.rankingList[0].photo_flg
                let photoName = self.rankingList[0].photo_name
                let user_id = self.rankingList[0].user_id
                if(photoFlg == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + user_id + "_list.jpg"
                    let photoUrl = "user_images/" + user_id + "/" + photoName + "_profile.jpg"
                    //画像キャッシュを使用
                    self.rank01ImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    self.rank01ImageView.image = cellImage
                }
                //画像の枠線の設定
                self.rank01ImageView.layer.borderColor = Util.SASHI_RANKING_FRAME_COLOR_01.cgColor
                //線の太さ
                self.rank01ImageView.layer.borderWidth = 4
                
                //王冠を最前面へ
                //self.rank01CrownImageView.isHidden = false
                self.rank01ImageView.bringSubviewToFront(self.rank01CrownImageView)
                
                /**/
                //ランキングポイントのところ
                /**/
                //let ranking_str = "ランキング" + self.rankingList[0].cast_month_ranking + "位"
                let ranking_point_str = UtilFunc.numFormatter(num:Int(Double(self.rankingList[0].cast_month_ranking_point)!)) + " pt"
                //self.rank01PointLbl.text = ranking_point_str
                self.rank01PointLbl.textColor = Util.SASHI_RANKING_STR_COLOR_01
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank01PointLbl.attributedText = UtilFunc.getInsertIconString(string: ranking_point_str, iconImage: UIImage(named:"monthly_ranking_ico_rank1_star")!, iconSize: self.iconSize2, lineHeight: 1.0)
                //ラベルの枠を自動調節する
                self.rank01PointLbl.adjustsFontSizeToFitWidth = true
                self.rank01PointLbl.minimumScaleFactor = 0.3
                
                /**/
                //配信レベルのところ
                /**/
                //self.rank01LiveCountLbl.text = "配信:" + Util.numFormatter(num:Int(self.rankingList[0].cast_month_live_count)!)
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank01LiveCountLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(self.rankingList[0].cast_month_live_count)!), iconImage: UIImage(named:"stream_count")!, iconSize: self.iconSize, lineHeight: 1.0)
                // 角丸
                self.rank01LiveCountLbl.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.rank01LiveCountLbl.layer.masksToBounds = true
                //ラベルの枠を自動調節する
                self.rank01LiveCountLbl.adjustsFontSizeToFitWidth = true
                self.rank01LiveCountLbl.minimumScaleFactor = 0.3
                //背景色変更
                self.rank01LiveCountLbl.backgroundColor = Util.COMMON_BLUE_COLOR
                
                /**/
                //配信レベルのところ(ここまで)
                /**/
                
                self.rank01NameLbl.text = self.rankingList[0].user_name.toHtmlString()
                //@IBOutlet weak var rank01FollowBtn: UIButton!
                
                /**/
                //フォローボタンのところ
                /**/
                // 角丸
                self.rank01FollowBtn.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.rank01FollowBtn.layer.masksToBounds = true
                //枠の大きさを自動調節する
                self.rank01FollowBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                self.rank01FollowBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                
                let followId = self.rankingList[0].follow_id
                if(followId == "0"){
                    //この人をフォローしていない場合
                    self.rank01FollowBtn.setTitle("+フォロー", for: .normal)
                    self.rank01FollowBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                    self.rank01FollowBtn.backgroundColor = UIColor.white
                    self.rank01FollowBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                    self.rank01FollowBtn.layer.borderWidth = 0.5
                }else{
                    //この人をフォローしている場合
                    self.rank01FollowBtn.setTitle("フォロー中", for: .normal)
                    self.rank01FollowBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                    self.rank01FollowBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                    //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                    self.rank01FollowBtn.layer.borderWidth = 0
                }
                /**/
                //フォローボタンのところ(ここまで)
                /**/
                
                if(self.user_id == Int(user_id)){
                    //自分自身の場合
                    self.rank01FollowBtn.isEnabled = false
                }else{
                    self.rank01FollowBtn.isEnabled = true
                }
                
                //リストの取得を待ってから更新
                //self.CollectionView.reloadData()
                self.mainTableView.reloadData()
            }
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

    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(appDelegate.productList.count)

        if(rankingList.count > 1){
            //リストの総数(1位以外を表示)
            return rankingList.count - 1
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /*
        if(talkList[indexPath.row].photo_flg == "1"
            && (talkList[indexPath.row].open_status == "1" || self.user_id == Int(talkList[indexPath.row].user_id))){
            //「既読かつ写真」または自分の投稿写真の場合
            return 200
        }else{
            //それ以外
            return UITableViewAutomaticDimension //変更
        }
         */
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingSashiLive", for: indexPath) as! RankingSashiLiveTableViewCell
        
        //ユーザー画像の表示
        let center_imageView = cell.centerImageView
        let photoFlg = rankingList[indexPath.row + 1].photo_flg
        let photoName = rankingList[indexPath.row + 1].photo_name
        let user_id = rankingList[indexPath.row + 1].user_id
        if(photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + user_id + "_list.jpg"
            let photoUrl = "user_images/" + user_id + "/" + photoName + "_list.jpg"
            
            //画像キャッシュを使用
            center_imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            center_imageView?.image = cellImage
        }
        
        //ブラックリストのユーザーを飛ばす必要があるため、cast_month_rankingは使用しない
        //let ranking_temp = Int(rankingList[indexPath.row + 1].cast_month_ranking)
        //2位から表示
        let ranking_temp = indexPath.row + 2
        cell.rankingLbl.text = UtilFunc.numFormatter(num:ranking_temp)
        
        //cell.rankingPointLbl.text = Util.numFormatter(num:Int(rankingList[indexPath.row + 1].cast_month_ranking_point)!) + " pt"
        let ranking_point_str = UtilFunc.numFormatter(num:Int(Double(rankingList[indexPath.row + 1].cast_month_ranking_point)!)) + " pt"
        if(ranking_temp == 2){
            //2位
            cell.rankingPointLbl.textColor = Util.SASHI_RANKING_STR_COLOR_02

            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            cell.rankingPointLbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height: -1, string: ranking_point_str, iconImage: UIImage(named:"monthly_ranking_ico_rank2_star")!, iconSize: self.iconSize)
            
        }else if(ranking_temp == 3){
            //3位
            cell.rankingPointLbl.textColor = Util.SASHI_RANKING_STR_COLOR_03
            
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            cell.rankingPointLbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height: -1, string: ranking_point_str, iconImage: UIImage(named:"monthly_ranking_ico_rank3_star")!, iconSize: self.iconSize)
            
        }else{
            //4位以降
            cell.rankingPointLbl.textColor = Util.SASHI_RANKING_STR_COLOR_04
            
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            cell.rankingPointLbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height: -1, string: ranking_point_str, iconImage: UIImage(named:"monthly_ranking_ico_rank4_star")!, iconSize: self.iconSize)
        }
        
        /**/
        //配信レベルのところ
        /**/
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        cell.livePointLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(rankingList[indexPath.row + 1].cast_month_live_count)!), iconImage: UIImage(named:"stream_count")!, iconSize: self.iconSize, lineHeight: 1.0)
        //cell.livePointLbl.text = "配信:" + Util.numFormatter(num:Int(rankingList[indexPath.row + 1].cast_month_live_count)!)
        /**/
        //配信レベルのところ(ここまで)
        /**/
        
        cell.castNameLbl.text = rankingList[indexPath.row + 1].user_name.toHtmlString()

        let followId = rankingList[indexPath.row + 1].follow_id
        if(followId == "0"){
            //この人をフォローしていない場合
            cell.followBtn.setTitle("＋", for: .normal)
            //枠の大きさを自動調節する
            cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
            cell.followBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
            cell.followBtn.backgroundColor = UIColor.white
            cell.followBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
            cell.followBtn.layer.borderWidth = 0.5
        }else{
            //この人をフォローしている場合
            cell.followBtn.setTitle("✔︎", for: .normal)
            //枠の大きさを自動調節する
            cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
            cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
            cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
            //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
            cell.followBtn.layer.borderWidth = 0
        }
        
        cell.castInfoBtn.tag = indexPath.row + 1
        //キャストボタンを押した時の処理
        cell.castInfoBtn.addTarget(self, action: #selector(onClickCastInfo(sender: )), for: .touchUpInside)
        
        cell.followBtn.tag = indexPath.row + 1
        //フォローボタンを押した時の処理
        cell.followBtn.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        
        if(self.user_id == Int(user_id)){
            //自分自身の場合
            cell.followBtn.isEnabled = false
        }else{
            cell.followBtn.isEnabled = true
        }
        
        return cell
    }
    
    @objc func onClickCastInfo(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        let buttonRow = sender.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[buttonRow].user_id
        UtilToViewController.toUserInfoViewController()
    }
    
    @objc func onClick(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        let buttonRow = sender.tag
        
        //UIAlertControllerを用意する
        let strCastName = self.rankingList[buttonRow].user_name
        let targetId = Int(self.rankingList[buttonRow].user_id)
        let followId = self.rankingList[buttonRow].follow_id
        
        let actionAlert = UIAlertController(title: strCastName, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if(followId != "0"){
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォロー解除", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:2, target_id:targetId)
                
                //この人をフォローしていない場合
                sender.setTitle("＋", for: .normal)
                //枠の大きさを自動調節する
                sender.titleLabel?.adjustsFontSizeToFitWidth = true
                sender.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                sender.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                sender.backgroundColor = UIColor.white
                sender.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                sender.layer.borderWidth = 0.5
                self.rankingList[buttonRow].follow_id = "0"

            })
            actionAlert.addAction(modifyAction)
        }else{
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォローする", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:1, target_id:targetId)
                
                //この人をフォローしている場合
                sender.setTitle("✔︎", for: .normal)
                //枠の大きさを自動調節する
                sender.titleLabel?.adjustsFontSizeToFitWidth = true
                sender.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                sender.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                sender.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                sender.layer.borderWidth = 0
                
                //follow_idに何か数値を入れておく
                self.rankingList[buttonRow].follow_id = "1"
            })
            actionAlert.addAction(modifyAction)
        }
        
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
    
    func follow(flg: Int!, target_id: Int!){
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
        stringUrl.append(String(target_id))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
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
            
            //取得する絆レベルの経験値
            let exp_temp = Util.CONNECTION_POINT_FOLLOW
            
            //flg=1:追加 2:削除
            if(flg == 1){
                UtilFunc.setMyInfo()//追加時はDBとの同期をしないと、無料コインがゲットされる場合があるため。
                UtilFunc.plusFollow()
            }else{
                UtilFunc.minusFollow()
            }
            
            //絆レベルの更新・追加(更新後に何も処理をしない場合に使用)
            //flg:1:値プラス、2:値マイナス
            UtilFunc.saveConnectLevelNew(user_id:self.user_id, target_user_id:target_id, exp:exp_temp, live_count:0, present_point:0, flg:flg)
            
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
        }
    }
    
}
