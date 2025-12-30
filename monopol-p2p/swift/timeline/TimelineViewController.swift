//
//  TimelineViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TimelineViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "タイムライン"
    
    var user_id: Int = 0//自分のID
    
    //くるくる表示開始
    //let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    @IBOutlet weak var noticeTableView: UITableView!

    //フォローしようの画像表示用
    @IBOutlet weak var noticeImageView: UIImageView!
    
    //日付表示の計算用
    let dateString = Date() //現在時刻
    let formatter = DateFormatter()

    //告知の一覧用(修正必要)
    struct NoticeResult: Codable {
        let rireki_id: String
        let user_id: String
        let notice_type: String
        let cast_name: String
        let value01: String
        //let value02: String
        let value03: String//いいねの数
        let mod_time: String
        let cast_photo_flg: String
        let cast_photo_name: String
        let good_rireki_id: String
    }
    struct ResultNoticeJson: Codable {
        let count: Int
        let result: [NoticeResult]
    }
    var noticeList: [(rirekiId:String, userId:String, noticeType:String, cast_name:String, value01:String, value03:String, modTime:String, castPhotoFlg:String, castPhotoName:String, goodRirekiId:String)] = []
    var noticeListTemp: [(rirekiId:String, userId:String, noticeType:String, cast_name:String, value01:String, value03:String, modTime:String, castPhotoFlg:String, castPhotoName:String, goodRirekiId:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // サブメニューの配置
        //let noticeHeader = Bundle.main.loadNibNamed("TimelineHeaderView", owner: self, options: nil)!.first! as! TimelineHeaderView
        //self.view.addSubview(noticeHeader)
        
        //自分のuser_idを指定
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //日付表示の計算用
        //formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" //フォーマット合わせる
        formatter.locale = Locale(identifier: "en_US_POSIX")//重要
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //フォーマット合わせる
        //formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
        
        //テーブルの区切り線を非表示
        self.noticeTableView.separatorColor = UIColor.clear
        
        self.noticeTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.noticeTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.noticeTableView.allowsSelection = false // 選択を不可にする
        self.noticeTableView.isScrollEnabled = true
        self.noticeTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        //tableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.noticeTableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.noticeTableView.register(UINib(nibName: "YourChatPhotoCell", bundle: nil), forCellReuseIdentifier: "YourChatPhoto")
        self.noticeTableView.register(UINib(nibName: "YourChatPhotoTextCell", bundle: nil), forCellReuseIdentifier: "YourChatPhotoText")
        
        //self.bottomView = ChatRoomInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)) // 下部に表示するテキストフィールドを設定
        //CollectionView.reloadData()
        
        /**************************************************************/
        //10フォローしたら130コイン
        //初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
        //UserDefaults.standard.set(strFirstFlg02, forKey: "first_flg02")
        /**************************************************************/
        let timelineFirstFlg = UserDefaults.standard.integer(forKey: "timelineFirstFlg")
        let follow_num = UserDefaults.standard.integer(forKey: "follow_num")
        //初回に開いたとき または フォロー0人の時
        if(timelineFirstFlg != 1 || follow_num == 0){
            //タイムラインを表示するテーブル
            self.noticeTableView.isHidden = true//非表示
            //フォローしようの画像表示用
            self.noticeImageView.isHidden = false//表示
        }else{
            //タイムラインを表示するテーブル
            self.noticeTableView.isHidden = false//表示
            //フォローしようの画像表示用
            self.noticeImageView.isHidden = true//非表示
        }
        /**************************************************************/
        //10フォローしたら130コイン(ここまで)
        /**************************************************************/
        
        //タイムラインを初回見たかのフラグ(1:すでに見た)
        //UserDefaults.standard.set(1, forKey: "timelineFirstFlg")

    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //サブメニューの選択
        UserDefaults.standard.set(0, forKey: "selectedSubMenuTimeline")
        
        //フォロー中の通知・告知一覧を取得
        self.getNoticeListByUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNoticeListByUser(){
        //クリアする
        self.noticeListTemp.removeAll()
        
        //リスト取得(自分が投稿した告知を含めた告知リストを取得)
        var stringUrl = Util.URL_NOTICE_LIST_BY_USER
        stringUrl.append("?status=1&order=1&user_id=")
        stringUrl.append(String(self.user_id))
        //print(stringUrl)
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
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
                    let json = try decoder.decode(ResultNoticeJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する告知リストを配列にする。
                    for obj in json.result {
                        //ブラックリストの配列にない場合はnilが返される
                        if self.appDelegate.array_black_list.index(of: Int(obj.user_id)!) == nil {
                            let notice = (obj.rireki_id,
                                          obj.user_id,
                                          obj.notice_type,
                                          obj.cast_name.toHtmlString(),
                                          obj.value01.htmlDecoded,
                                          obj.value03,
                                          obj.mod_time,
                                          obj.cast_photo_flg,
                                          obj.cast_photo_name,
                                          obj.good_rireki_id)
                            //配列へ追加
                            self.noticeList.append(notice)
                            self.noticeListTemp.append(notice)
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
            //くるくる表示終了
            //self.busyIndicator.removeFromSuperview()
            //コピーする
            self.noticeList = self.noticeListTemp
            
            //リストの取得を待ってから更新
            //self.CollectionView.reloadData()
            //self.noticeTableView.reloadData()

            self.noticeTableView.reloadData()
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
            
            /*
            //reloadDataの後に処理を行う方法
            UIView.animate(
                withDuration: 0.0,
                animations:{
                    // リロード
                    self.noticeTableView.reloadData()
            }, completion:{ finished in
                if (finished) { // 一応finished確認はしておく
                /* やりたい処理 */
                //くるくる表示終了
                self.busyIndicator.removeFromSuperview()
                }
            })
             */
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

    //ボタンが押されるとこの関数が呼ばれる
    @objc func iineDo(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag//indexPath.row
        //castList[buttonRow].user_id
        
        self.appDelegate.sendNoticeId = Int(noticeList[buttonRow].rirekiId)
        
        if(noticeList[buttonRow].userId == String(self.user_id)){
            if(Int(noticeList[buttonRow].value03)! > 0){
                //いいねの数がゼロより大きい場合
                //自分の投稿の場合＞いいねリストを表示
                UtilToViewController.toGoodListViewController()
            }
        }else{
            //自分以外の投稿の場合＞通常のいいね処理
            //くるくる表示開始
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.busyIndicator)
            
            //GET:notice_rireki_id,cast_id,user_id,mod_flg
            //mod_flg=1:いいねの追加処理 2:いいねの削除処理
            var stringUrl = Util.URL_NOTICE_GOOD_DO
            stringUrl.append("?notice_rireki_id=")
            stringUrl.append(noticeList[buttonRow].rirekiId)
            stringUrl.append("&cast_id=")
            stringUrl.append(noticeList[buttonRow].userId)
            stringUrl.append("&user_id=")
            stringUrl.append(String(self.user_id))
            
            //いいねを押されているかの判断
            let goodRirekiId = noticeList[buttonRow].goodRirekiId
            
            /*
            // UITableView内の座標に変換
            let point = self.noticeTableView.convert(sender.center, from: sender)
            // 座標からindexPathを取得
            if let indexPath = self.noticeTableView.indexPathForRow(at: point) {
                print(indexPath)
            } else {
                //ここには来ないはず
                print("indexPath not found.")
            }
             */
            
            if(goodRirekiId == "0"){
                //まだ「いいね」されていない
                stringUrl.append("&mod_flg=1")
                
                let value_temp:Int = Int(noticeList[buttonRow].value03)! + 1
                noticeList[buttonRow].value03 = String(value_temp)
                noticeList[buttonRow].goodRirekiId = "1"
                
                //直接画面の表示を変更する
                sender.setImage(UIImage(named: "like_on"), for: UIControl.State())
                sender.setTitle(noticeList[buttonRow].value03, for: .normal)
            }else{
                //すでに「いいね」されている
                stringUrl.append("&mod_flg=2")
                
                let value_temp:Int = Int(noticeList[buttonRow].value03)! - 1
                noticeList[buttonRow].value03 = String(value_temp)
                noticeList[buttonRow].goodRirekiId = "0"
                
                //直接画面の表示を変更する
                sender.setImage(UIImage(named: "like_off"), for: UIControl.State())
                sender.setTitle(noticeList[buttonRow].value03, for: .normal)
            }
            
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
                    //do{
                    //JSONDecoderのインスタンス取得
                    //let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    //let json = try decoder.decode(ResultJson.self, from: data!)
                    
                    // UserDefaultsを使ってデータを保持する
                    //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                    //UserDefaults.standard.set(rank, forKey: "cast_rank")
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                    //}catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print("json convert failed in JSONDecoder", err?.localizedDescription)
                    //}
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //くるくる表示終了
                self.busyIndicator.removeFromSuperview()
                
                /*
                //画面更新
                // リロード
                //UITableView内の座標に変換
                let point = self.noticeTableView.convert(sender.center, from: sender)
                //座標からindexPathを取得
                if let indexPath = self.noticeTableView.indexPathForRow(at: point) {
                    //print(indexPath)
                    self.noticeTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                } else {
                    //ここには来ないはず
                    print("not found...")
                }
                //くるくる表示終了
                self.busyIndicator.removeFromSuperview()
                */

                //self.getNoticeListByUser()
                
                /*
                self.noticeTableView.reloadData()
                
                DispatchQueue.main.async {
                    //UITableView内の座標に変換
                    let point = self.noticeTableView.convert(sender.center, from: sender)
                    //座標からindexPathを取得
                    if let indexPath = self.noticeTableView.indexPathForRow(at: point) {
                        //print(indexPath)
                        //self.noticeTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                        
                        //いったん先頭に持っていく
                        //let indexPathStart = IndexPath(row: 0, section: 0)
                        //self.noticeTableView.scrollToRow(at: indexPathStart, at: UITableViewScrollPosition.top, animated: false)
                        //その後、所定の位置へ移動
                        //print("その後、所定の位置へ移動")
                        //print(indexPath.row)
                        //self.noticeTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                        //self.noticeTableView.scrollToRow(at: indexPath, animated: false)
                        //self.noticeTableView.contentOffset = point
                        //self.noticeTableView.contentOffset = CGPoint(x: 0, y: -self.tableView.contentInset.top)
                        
                        //くるくる表示終了
                        self.busyIndicator.removeFromSuperview()
                    } else {
                        //ここには来ないはず
                        print("not found...")
                    }
                    
                    
                    

                }
 */
                /*
                //reloadDataの後に処理を行う方法
                UIView.animate(
                    withDuration: 0.0,
                    animations:{
                        self.noticeTableView.reloadData()
                        //self.noticeTableView.reloadRows(at: , with: UITableViewRowAnimation.fade)
                }, completion:{ finished in
                    if (finished) { // 一応finished確認はしておく
                        /* やりたい処理 */
                        //くるくる表示終了
                        self.busyIndicator.removeFromSuperview()
                    }
                })
                 */
            }
        }
    }
    
    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //告知リストの総数
        return noticeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let posTimeText:String = formatter.date(from: noticeList[indexPath.row].modTime)!.timeAgoSinceDate(numericDates: true)
        
        //表示する1行を取得する
        if(noticeList[indexPath.row].noticeType == "2"){
            //画像のみ
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChatPhoto") as! YourChatPhotoCell
            cell.clipsToBounds = true //bound外のものを表示しない
            //cell.textView.text = noticeList[indexPath.row].value01
            
            let photoUrl: String = "timeline/"
                + noticeList[indexPath.row].userId
                + "/"
                + noticeList[indexPath.row].rirekiId
                + "_list.jpg"
            
            //画像キャッシュを使用
            cell.imagePhotoView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
            
            cell.imagePhotoView.isUserInteractionEnabled = true
            cell.imagePhotoView.tag = indexPath.row
            cell.imagePhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:))))

            // 角丸
            cell.imagePhotoView.layer.cornerRadius = 10
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            cell.imagePhotoView.layer.masksToBounds = true

            cell.iineBtn.setTitle(noticeList[indexPath.row].value03, for: .normal)
            //cell.iineLblBtn.setTitle(noticeList[indexPath.row].value03, for: .normal)
            cell.dateLbl.text = posTimeText//**分前の表示
            cell.castNameLabel.text = noticeList[indexPath.row].cast_name
            cell.iineBtn?.tag = indexPath.row
            
            //キャスト画像の表示
            let photoFlg = noticeList[indexPath.row].castPhotoFlg
            let photoName = noticeList[indexPath.row].castPhotoName
            let user_id = noticeList[indexPath.row].userId
            if(photoFlg == "1"){
                //写真設定済み
                //let photoUrl = "user_images/" + user_id + "_profile.jpg"
                //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                //    cell.castImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                //}
                //写真設定済み
                //let photoUrl = "user_images/" + user_id + "_profile.jpg"
                let photoUrl = "user_images/" + user_id + "/" + photoName + "_profile.jpg"
                
                //画像キャッシュを使用
                cell.castImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            }else{
                let cellImage = UIImage(named:"no_image")
                // UIImageをUIImageViewのimageとして設定
                cell.castImageView.image = cellImage
            }
            
            if(self.user_id != Int(user_id)){
                cell.castImageView.isUserInteractionEnabled = true
                cell.castImageView.tag = indexPath.row
                cell.castImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
            }else{
                cell.castImageView.isUserInteractionEnabled = false
            }
            
            //いいねを押されているかの判断
            let goodRirekiId = noticeList[indexPath.row].goodRirekiId
            if(goodRirekiId == "0"){
                //まだ「いいね」されていない
                cell.iineBtn.setImage(UIImage(named: "like_off"), for: UIControl.State())
            }else{
                //すでに「いいね」されている
                cell.iineBtn.setImage(UIImage(named: "like_on"), for: UIControl.State())
            }
            
            //ボタンを隠す
            cell.followBtn.isHidden = true
            cell.kokuchiBtn.isHidden = true
            cell.dateLbl.isHidden = false
            cell.iineBtn.isHidden = false
            //cell.iineLblBtn.isHidden = false
            
            //いいねの数字のところをタップした時の処理
            cell.iineBtn?.tag = indexPath.row
            cell.iineBtn?.addTarget(self, action: #selector(iineDo(sender: )), for: .touchUpInside)
            //cell.iineLblBtn?.tag = indexPath.row
            //cell.iineLblBtn?.addTarget(self, action: #selector(iineDo(sender: )), for: .touchUpInside)
            
            return cell
        }else if(noticeList[indexPath.row].noticeType == "3"){
            //テキストかつ画像
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChatPhotoText") as! YourChatPhotoTextCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.textView.text = noticeList[indexPath.row].value01
            
            let photoUrl: String = "timeline/"
                + noticeList[indexPath.row].userId
                + "/"
                + noticeList[indexPath.row].rirekiId
                + "_list.jpg"
            
            //print(photoUrl)
            
            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
            //    cell.imagePhotoView.image = image?.resizeUIImageRatio(ratio: 50.0)
            //}
            //画像キャッシュを使用
            cell.imagePhotoView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
            
            cell.imagePhotoView.isUserInteractionEnabled = true
            cell.imagePhotoView.tag = indexPath.row
            cell.imagePhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:))))
            
            // 角丸
            cell.imagePhotoView.layer.cornerRadius = 10
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            cell.imagePhotoView.layer.masksToBounds = true
            
            cell.iineBtn.setTitle(noticeList[indexPath.row].value03, for: .normal)
            cell.dateLbl.text = posTimeText//**分前の表示
            cell.castNameLabel.text = noticeList[indexPath.row].cast_name
            cell.iineBtn?.tag = indexPath.row
            
            //キャスト画像の表示
            let photoFlg = noticeList[indexPath.row].castPhotoFlg
            let photoName = noticeList[indexPath.row].castPhotoName
            let user_id = noticeList[indexPath.row].userId
            if(photoFlg == "1"){
                //写真設定済み
                //let photoUrl = "user_images/" + user_id + "_profile.jpg"
                let photoUrl = "user_images/" + user_id + "/" + photoName + "_profile.jpg"
                
                //画像キャッシュを使用
                cell.castImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            }else{
                let cellImage = UIImage(named:"no_image")
                // UIImageをUIImageViewのimageとして設定
                cell.castImageView.image = cellImage
            }
            
            if(self.user_id != Int(user_id)){
                cell.castImageView.isUserInteractionEnabled = true
                cell.castImageView.tag = indexPath.row
                cell.castImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
            }else{
                cell.castImageView.isUserInteractionEnabled = false
            }
            
            //いいねを押されているかの判断
            let goodRirekiId = noticeList[indexPath.row].goodRirekiId
            if(goodRirekiId == "0"){
                //まだ「いいね」されていない
                cell.iineBtn.setImage(UIImage(named: "like_off"), for: UIControl.State())
            }else{
                //すでに「いいね」されている
                cell.iineBtn.setImage(UIImage(named: "like_on"), for: UIControl.State())
            }
            
            //ボタンを隠す
            cell.followBtn.isHidden = true
            cell.kokuchiBtn.isHidden = true
            cell.dateLbl.isHidden = false
            cell.iineBtn.isHidden = false
            //cell.iineLblBtn.isHidden = false
            
            //いいねの数字のところをタップした時の処理
            cell.iineBtn?.tag = indexPath.row
            cell.iineBtn?.addTarget(self, action: #selector(iineDo(sender: )), for: .touchUpInside)
            //cell.iineLblBtn?.tag = indexPath.row
            //cell.iineLblBtn?.addTarget(self, action: #selector(iineDo(sender: )), for: .touchUpInside)
            
            return cell
        }else{
            //テキストのみ
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChat") as! YourChatViewCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.textView.text = noticeList[indexPath.row].value01
            
            cell.iineBtn.setTitle(noticeList[indexPath.row].value03, for: .normal)
            cell.dateLbl.text = posTimeText//**分前の表示
            cell.castNameLabel.text = noticeList[indexPath.row].cast_name
            cell.iineBtn?.tag = indexPath.row
            
            //キャスト画像の表示
            let photoFlg = noticeList[indexPath.row].castPhotoFlg
            let photoName = noticeList[indexPath.row].castPhotoName
            let user_id = noticeList[indexPath.row].userId
            if(photoFlg == "1"){
                //写真設定済み
                //let photoUrl = "user_images/" + user_id + "_profile.jpg"
                let photoUrl = "user_images/" + user_id + "/" + photoName + "_profile.jpg"

                //画像キャッシュを使用
                cell.castImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            }else{
                let cellImage = UIImage(named:"no_image")
                // UIImageをUIImageViewのimageとして設定
                cell.castImageView.image = cellImage
            }
            
            if(self.user_id != Int(user_id)){
                cell.castImageView.isUserInteractionEnabled = true
                cell.castImageView.tag = indexPath.row
                cell.castImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
            }else{
                cell.castImageView.isUserInteractionEnabled = false
            }
            
            //いいねを押されているかの判断
            let goodRirekiId = noticeList[indexPath.row].goodRirekiId
            if(goodRirekiId == "0"){
                //まだ「いいね」されていない
                cell.iineBtn.setImage(UIImage(named: "like_off"), for: UIControl.State())
            }else{
                //すでに「いいね」されている
                cell.iineBtn.setImage(UIImage(named: "like_on"), for: UIControl.State())
            }
            
            //ボタンを隠す
            cell.followBtn.isHidden = true
            cell.kokuchiBtn.isHidden = true
            cell.dateLbl.isHidden = false
            cell.iineBtn.isHidden = false
            //cell.iineLblBtn.isHidden = false
            
            //いいねの数字のところをタップした時の処理
            cell.iineBtn?.tag = indexPath.row
            cell.iineBtn?.addTarget(self, action: #selector(iineDo(sender: )), for: .touchUpInside)
            //cell.iineLblBtn?.tag = indexPath.row
            //cell.iineLblBtn?.addTarget(self, action: #selector(iineDo(sender: )), for: .touchUpInside)
            
            return cell
        }
    }

    @objc func onClickCastInfo(_ sender: UITapGestureRecognizer){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        //let buttonRow = sender.tag
        let buttonRow = sender.view?.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //if(self.user_id != Int(self.noticeList[buttonRow!].userId)){
        //自分ではない場合（自分の場合は何もしない）
        self.appDelegate.sendId = self.noticeList[buttonRow!].userId//相手のID
        UtilToViewController.toUserInfoViewController()
        //}
    }
    
    // 画像がタップされたら呼ばれる(相手の画像)
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view?.tag
        //print("タップ")
        //マイコレクションの個別画面へ渡す
        appDelegate.myCollectionType = "3"
        appDelegate.myCollectionSelectCastId = self.noticeList[buttonRow!].userId//相手のID
        appDelegate.myCollectionSelectCastName = self.noticeList[buttonRow!].cast_name//相手の名前
        appDelegate.myCollectionSelectInsTime = self.noticeList[buttonRow!].modTime
        appDelegate.myCollectionSelectPhotoFileName = self.noticeList[buttonRow!].rirekiId
        
        UtilToViewController.toCollectionImageViewController(animated_flg:false)
    }
}

//tableviewの上部の空白を削除する(swift4)
// MARK: - UITableViewDelegate
extension TimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: TableView Cell

/*
class TimelineTableViewCell:UITableViewCell{
    @IBOutlet weak var imagePhoto:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var timelineLabel:UILabel!
}
*/

