//
//  FanViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/18.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {

    let iconSize: CGFloat = 11.0
    let iconSize2: CGFloat = 14.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "ファン"
    
    //ランキング1位に関するところ
    @IBOutlet weak var rank01View: UIView!
    @IBOutlet weak var rank01CastImageView: EnhancedCircleImageView!
    @IBOutlet weak var rank01UserImageView: EnhancedCircleImageView!
    @IBOutlet weak var rank01CastNameLbl: UILabel!
    @IBOutlet weak var rank01UserNameLbl: UILabel!
    @IBOutlet weak var rank01ConnectLevelLbl: UILabel!
    @IBOutlet weak var rank01PointLbl: UILabel!

    //ランキング2位に関するところ
    @IBOutlet weak var rank02View: UIView!
    @IBOutlet weak var rank02CastImageView: EnhancedCircleImageView!
    @IBOutlet weak var rank02UserImageView: EnhancedCircleImageView!
    @IBOutlet weak var rank02CastNameLbl: UILabel!
    @IBOutlet weak var rank02UserNameLbl: UILabel!
    @IBOutlet weak var rank02ConnectLevelLbl: UILabel!
    @IBOutlet weak var rank02PointLbl: UILabel!
    
    //ランキング3位に関するところ
    @IBOutlet weak var rank03View: UIView!
    @IBOutlet weak var rank03CastImageView: EnhancedCircleImageView!
    @IBOutlet weak var rank03UserImageView: EnhancedCircleImageView!
    @IBOutlet weak var rank03CastNameLbl: UILabel!
    @IBOutlet weak var rank03UserNameLbl: UILabel!
    @IBOutlet weak var rank03ConnectLevelLbl: UILabel!
    @IBOutlet weak var rank03PointLbl: UILabel!
    
    @IBOutlet weak var mainTableView: UITableView!
    
    /*
     //ファンランキングの1位の枠の色
     static let FAN_RANKING_FRAME_COLOR_01: UIColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
     //ファンランキングの2位の枠の色
     static let FAN_RANKING_FRAME_COLOR_02: UIColor = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1)
     //ファンランキングの3位の枠の色
     static let FAN_RANKING_FRAME_COLOR_03: UIColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
     */

    //ランキングの一覧用
    struct RankingResult: Codable {
        let user_id: String
        let cast_id: String
        let year: String
        let month: String
        let connect_level: String
        let exp: String
        let user_name: String
        let user_photo_flg: String
        let user_photo_name: String
        let cast_name: String
        let cast_photo_flg: String
        let cast_photo_name: String
    }
    struct ResultRankingJson: Codable {
        let count: Int
        let result: [RankingResult]
    }
    
    var rankingList: [(user_id:String, cast_id:String, year:String, month:String
        ,connect_level:String, exp:String, user_name:String, user_photo_flg:String, user_photo_name:String
        , cast_name:String, cast_photo_flg:String, cast_photo_name:String)] = []
    
    var rankingListTemp: [(user_id:String, cast_id:String, year:String, month:String
        ,connect_level:String, exp:String, user_name:String, user_photo_flg:String, user_photo_name:String
        , cast_name:String, cast_photo_flg:String, cast_photo_name:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルの区切り線を非表示
        self.mainTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.mainTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.mainTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.mainTableView.allowsSelection = false // 選択を不可にする
        self.mainTableView.isScrollEnabled = true
        self.mainTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる

        //枠の大きさを自動調節する
        self.rank01ConnectLevelLbl.adjustsFontSizeToFitWidth = true
        self.rank01ConnectLevelLbl.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        self.rank02ConnectLevelLbl.adjustsFontSizeToFitWidth = true
        self.rank02ConnectLevelLbl.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        self.rank03ConnectLevelLbl.adjustsFontSizeToFitWidth = true
        self.rank03ConnectLevelLbl.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        // Do any additional setup after loading the view.
        self.mainTableView.register(UINib(nibName: "RankingFanTableViewCell", bundle: nil), forCellReuseIdentifier: "RankingFan")
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //はじめに現在のViewControllerをセット
        //キャスト詳細＞フォロー後に戻ってきた時にリロードするための対策
        self.appDelegate.viewCallFromViewControllerId = "FanViewController"
        self.appDelegate.viewReloadFlg = 0
        
        getPairRanking()
    }
    
    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapRank01UserInfo(_ sender: Any) {
        //リスナーのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[0].user_id
        UtilToViewController.toUserInfoViewController()
    }
    @IBAction func tapRank01CastInfo(_ sender: Any) {
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[0].cast_id
        UtilToViewController.toUserInfoViewController()
    }
    
    @IBAction func tapRank02UserInfo(_ sender: Any) {
        //リスナーのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[1].user_id
        UtilToViewController.toUserInfoViewController()
    }
    @IBAction func tapRank02CastInfo(_ sender: Any) {
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[1].cast_id
        UtilToViewController.toUserInfoViewController()
    }
    
    @IBAction func tapRank03UserInfo(_ sender: Any) {
        //リスナーのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[2].user_id
        UtilToViewController.toUserInfoViewController()
    }
    @IBAction func tapRank03CastInfo(_ sender: Any) {
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[2].cast_id
        UtilToViewController.toUserInfoViewController()
    }
    
    func getPairRanking(){
        //クリアする
        self.rank01View.isHidden = true
        self.rank02View.isHidden = true
        self.rank03View.isHidden = true
        self.rankingListTemp.removeAll()
        
        //リスト取得
        let stringUrl = Util.URL_GET_MONTH_PAIR_RANKING
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
                    let json = try decoder.decode(ResultRankingJson.self, from: data!)
                    //self.idCount = json.count
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strUserId = obj.user_id
                        let strCastId = obj.cast_id
                        let strYear = obj.year
                        let strMonth = obj.month
                        let strConnectLevel = obj.connect_level
                        let strExp = obj.exp
                        let strUserName = obj.user_name.toHtmlString()
                        let strUserPhotoFlg = obj.user_photo_flg
                        let strUserPhotoName = obj.user_photo_name
                        let strCastName = obj.cast_name.toHtmlString()
                        let strCastPhotoFlg = obj.cast_photo_flg
                        let strCastPhotoName = obj.cast_photo_name
                        //配列へ追加
                        let ranking = (strUserId,strCastId,strYear,strMonth,strConnectLevel,strExp
                        ,strUserName,strUserPhotoFlg,strUserPhotoName,strCastName,strCastPhotoFlg,strCastPhotoName)
                        self.rankingList.append(ranking)
                        self.rankingListTemp.append(ranking)
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
                self.rank02View.isHidden = true
                self.rank03View.isHidden = true
            }else{
                self.rank01View.isHidden = false
                self.rank02View.isHidden = false
                self.rank03View.isHidden = false
                
                /******************************/
                //ランキング1位
                /******************************/
                let user_photoFlg01 = self.rankingList[0].user_photo_flg
                let user_photoName01 = self.rankingList[0].user_photo_name
                let user_id01 = self.rankingList[0].user_id
                if(user_photoFlg01 == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + user_id + "_profile.jpg"
                    let photoUrl = "user_images/" + user_id01 + "/" + user_photoName01 + "_profile.jpg"
                    //画像キャッシュを使用
                    self.rank01UserImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    self.rank01UserImageView.image = cellImage
                }
                //画像の枠線の設定
                self.rank01UserImageView.layer.borderColor = Util.FAN_RANKING_FRAME_COLOR_01.cgColor
                //線の太さ
                self.rank01UserImageView.layer.borderWidth = 4
                
                //キャスト画像の表示
                let cast_photoFlg01 = self.rankingList[0].cast_photo_flg
                let cast_photoName01 = self.rankingList[0].cast_photo_name
                let cast_id01 = self.rankingList[0].cast_id
                if(cast_photoFlg01 == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + cast_id + "_profile.jpg"
                    let photoUrl = "user_images/" + cast_id01 + "/" + cast_photoName01 + "_profile.jpg"
                    //画像キャッシュを使用
                    self.rank01CastImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    self.rank01CastImageView.image = cellImage
                }
                //画像の枠線の設定
                self.rank01CastImageView.layer.borderColor = Util.FAN_RANKING_FRAME_COLOR_01.cgColor
                //線の太さ
                self.rank01CastImageView.layer.borderWidth = 4
                
                self.rank01UserNameLbl.text = self.rankingList[0].user_name.toHtmlString()
                self.rank01CastNameLbl.text = self.rankingList[0].cast_name.toHtmlString()
                
                /**/
                //ランキングラベルのところ
                /**/
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank01PointLbl.attributedText = UtilFunc.getInsertIconString(string: "1位 " + UtilFunc.numFormatter(num:Int(Double(self.rankingList[0].exp)!)) + " pt", iconImage: UIImage(named:"monthly_fan-ranking_ico_crown1")!, iconSize: self.iconSize2, lineHeight: 1.0)
                //let rank:Int = indexPath.row + 1
                //self.rank01PointLbl.text = "ランキング1位 " + Util.numFormatter(num:Int(self.rankingList[0].exp)!) + " pt"
                self.rank01PointLbl.textColor = Util.FAN_RANKING_STR_COLOR_01
                
                /**/
                //絆レベルのところ
                /**/
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank01ConnectLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(self.rankingList[0].connect_level)!), iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
                // 角丸
                self.rank01ConnectLevelLbl.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.rank01ConnectLevelLbl.layer.masksToBounds = true
                self.rank01ConnectLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
                //ラベルの枠を自動調節する
                self.rank01ConnectLevelLbl.adjustsFontSizeToFitWidth = true
                self.rank01ConnectLevelLbl.minimumScaleFactor = 0.3
                /**/
                //絆レベルのところ(ここまで)
                /**/
                
                /******************************/
                //ランキング2位
                /******************************/
                let user_photoFlg02 = self.rankingList[1].user_photo_flg
                let user_photoName02 = self.rankingList[1].user_photo_name
                let user_id02 = self.rankingList[1].user_id
                if(user_photoFlg02 == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + user_id + "_profile.jpg"
                    let photoUrl = "user_images/" + user_id02 + "/" + user_photoName02 + "_profile.jpg"
                    //画像キャッシュを使用
                    self.rank02UserImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    self.rank02UserImageView.image = cellImage
                }
                //画像の枠線の設定
                self.rank02UserImageView.layer.borderColor = Util.FAN_RANKING_FRAME_COLOR_02.cgColor
                //線の太さ
                self.rank02UserImageView.layer.borderWidth = 4
                
                //キャスト画像の表示
                let cast_photoFlg02 = self.rankingList[1].cast_photo_flg
                let cast_photoName02 = self.rankingList[1].cast_photo_name
                let cast_id02 = self.rankingList[1].cast_id
                if(cast_photoFlg02 == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + cast_id + "_profile.jpg"
                    let photoUrl = "user_images/" + cast_id02 + "/" + cast_photoName02 + "_profile.jpg"
                    //画像キャッシュを使用
                    self.rank02CastImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    self.rank02CastImageView.image = cellImage
                }
                //画像の枠線の設定
                self.rank02CastImageView.layer.borderColor = Util.FAN_RANKING_FRAME_COLOR_02.cgColor
                //線の太さ
                self.rank02CastImageView.layer.borderWidth = 4
                
                self.rank02UserNameLbl.text = self.rankingList[1].user_name.toHtmlString()
                self.rank02CastNameLbl.text = self.rankingList[1].cast_name.toHtmlString()
                //let rank:Int = indexPath.row + 2
                
                /**/
                //ランキングラベルのところ
                /**/
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank02PointLbl.attributedText = UtilFunc.getInsertIconString(string: "2位 " + UtilFunc.numFormatter(num:Int(Double(self.rankingList[1].exp)!)) + " pt", iconImage: UIImage(named:"monthly_fan-ranking_ico_crown1")!, iconSize: self.iconSize2, lineHeight: 1.0)
                self.rank02PointLbl.textColor = Util.FAN_RANKING_STR_COLOR_02
                
                /**/
                //絆レベルのところ
                /**/
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank02ConnectLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(self.rankingList[1].connect_level)!), iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
                // 角丸
                self.rank02ConnectLevelLbl.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.rank02ConnectLevelLbl.layer.masksToBounds = true
                self.rank02ConnectLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
                //ラベルの枠を自動調節する
                self.rank02ConnectLevelLbl.adjustsFontSizeToFitWidth = true
                self.rank02ConnectLevelLbl.minimumScaleFactor = 0.3
                /**/
                //絆レベルのところ(ここまで)
                /**/
                
                /******************************/
                //ランキング3位
                /******************************/
                let user_photoFlg03 = self.rankingList[2].user_photo_flg
                let user_photoName03 = self.rankingList[2].user_photo_name
                let user_id03 = self.rankingList[2].user_id
                if(user_photoFlg03 == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + user_id + "_profile.jpg"
                    let photoUrl = "user_images/" + user_id03 + "/" + user_photoName03 + "_profile.jpg"
                    //画像キャッシュを使用
                    self.rank03UserImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    self.rank03UserImageView.image = cellImage
                }
                //画像の枠線の設定
                self.rank03UserImageView.layer.borderColor = Util.FAN_RANKING_FRAME_COLOR_03.cgColor
                //線の太さ
                self.rank03UserImageView.layer.borderWidth = 4
                
                //キャスト画像の表示
                let cast_photoFlg03 = self.rankingList[2].cast_photo_flg
                let cast_photoName03 = self.rankingList[2].cast_photo_name
                let cast_id03 = self.rankingList[2].cast_id
                if(cast_photoFlg03 == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + cast_id + "_profile.jpg"
                    let photoUrl = "user_images/" + cast_id03 + "/" + cast_photoName03 + "_profile.jpg"
                    //画像キャッシュを使用
                    self.rank03CastImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    self.rank03CastImageView.image = cellImage
                }
                //画像の枠線の設定
                self.rank03CastImageView.layer.borderColor = Util.FAN_RANKING_FRAME_COLOR_03.cgColor
                //線の太さ
                self.rank03CastImageView.layer.borderWidth = 4
                
                self.rank03UserNameLbl.text = self.rankingList[2].user_name.toHtmlString()
                self.rank03CastNameLbl.text = self.rankingList[2].cast_name.toHtmlString()
                //let rank:Int = indexPath.row + 3
                
                /**/
                //ランキングラベルのところ
                /**/
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank03PointLbl.attributedText = UtilFunc.getInsertIconString(string: "3位 " + UtilFunc.numFormatter(num:Int(Double(self.rankingList[2].exp)!)) + " pt", iconImage: UIImage(named:"monthly_fan-ranking_ico_crown1")!, iconSize: self.iconSize2, lineHeight: 1.0)
                self.rank03PointLbl.textColor = Util.FAN_RANKING_STR_COLOR_03
                
                /**/
                //絆レベルのところ
                /**/
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.rank03ConnectLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(self.rankingList[2].connect_level)!), iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
                // 角丸
                self.rank03ConnectLevelLbl.layer.cornerRadius = 4
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                self.rank03ConnectLevelLbl.layer.masksToBounds = true
                self.rank03ConnectLevelLbl.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
                //ラベルの枠を自動調節する
                self.rank03ConnectLevelLbl.adjustsFontSizeToFitWidth = true
                self.rank03ConnectLevelLbl.minimumScaleFactor = 0.3
                /**/
                //絆レベルのところ(ここまで)
                /**/
                
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
        //リストの総数
        //return appDelegate.productList.count
        if(rankingList.count > 3){
            return rankingList.count - 3
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
    
    //4位以降
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingFan", for: indexPath) as! RankingFanTableViewCell
        
        //ユーザー画像の表示
        let user_imageView = cell.userImageView
        let user_photoFlg = rankingList[indexPath.row + 3].user_photo_flg
        let user_photoName = rankingList[indexPath.row + 3].user_photo_name
        let user_id = rankingList[indexPath.row + 3].user_id
        
        if(user_photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + user_id + "_profile.jpg"
            let photoUrl = "user_images/" + user_id + "/" + user_photoName + "_profile.jpg"
            
            //画像キャッシュを使用
            user_imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            user_imageView?.image = cellImage
        }
        
        //キャスト画像の表示
        let cast_imageView = cell.castImageView
        let cast_photoFlg = rankingList[indexPath.row + 3].cast_photo_flg
        let cast_photoName = rankingList[indexPath.row + 3].cast_photo_name
        let cast_id = rankingList[indexPath.row + 3].cast_id
        
        if(cast_photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + cast_id + "_profile.jpg"
            let photoUrl = "user_images/" + cast_id + "/" + cast_photoName + "_profile.jpg"
            
            //画像キャッシュを使用
            cast_imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            cast_imageView?.image = cellImage
        }
        
        let rank:Int = indexPath.row + 4
        cell.rankingLbl.text = UtilFunc.numFormatter(num:rank)
        cell.userNameLbl.text = rankingList[indexPath.row + 3].user_name.toHtmlString()
        cell.castNameLbl.text = rankingList[indexPath.row + 3].cast_name.toHtmlString()
        
        
        /**/
        //ランキングポイントのところ
        /**/
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        cell.rankingPointLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(Double(rankingList[indexPath.row + 3].exp)!)) + "pt", iconImage: UIImage(named:"monthly_fan-ranking_ico_crown2")!, iconSize: self.iconSize, lineHeight: 1.0)
        //cell.rankingPointLbl.text = Util.numFormatter(num:Int(rankingList[indexPath.row + 3].exp)!) + "pt"

        /**/
        //絆レベルのところ
        /**/
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        cell.connectLevelLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:Int(rankingList[indexPath.row + 3].connect_level)!), iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
        //cell.connectLevelLbl.text = "Lv:" + Util.numFormatter(num:Int(rankingList[indexPath.row + 3].connect_level)!)
        
        cell.connectLevelLbl.adjustsFontSizeToFitWidth = true
        cell.connectLevelLbl.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        /**/
        //絆レベルのところ(ここまで)
        /**/
        
        /*
         let price: Int = Int(appDelegate.productList[indexPath.row].price)!
         cell.purchaseButton?.setTitle("¥ " + String(Util.numFormatter(num:price)), for: .normal)
         cell.purchaseButton?.tag = indexPath.row
         //購入するボタンを押した時の処理
         cell.purchaseButton?.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
         */
        
        cell.castInfoBtn.tag = indexPath.row + 3
        //キャストボタンを押した時の処理
        cell.castInfoBtn.addTarget(self, action: #selector(onClickCastInfo(sender: )), for: .touchUpInside)
        
        cell.userInfoBtn.tag = indexPath.row + 3
        //キャストボタンを押した時の処理
        cell.userInfoBtn.addTarget(self, action: #selector(onClickUserInfo(sender: )), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func onClickUserInfo(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        let buttonRow = sender.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[buttonRow].user_id
        UtilToViewController.toUserInfoViewController()
    }
    
    @objc func onClickCastInfo(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        let buttonRow = sender.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rankingList[buttonRow].cast_id
        UtilToViewController.toUserInfoViewController()
    }
}
