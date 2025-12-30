//
//  FollowViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FollowViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "フォロー"
    
    var user_id: Int = 0//自分のID
    
    @IBOutlet weak var followTableView: UITableView!

    //フォローしようの画像表示用
    @IBOutlet weak var followImageView: UIImageView!
    
    //フォローの一覧用(修正必要)
    struct FollowResult: Codable {
        let to_user_id: String
        let to_user_name: String
        let to_notice_type: String
        let to_notice_text: String
        let to_notice_rireki_id: String
        let to_notice_rireki_ins_time: String
        let value01: String//1:待機通知オン 2:待機通知オフ
        let mod_time: String
        let to_photo_flg: String
        let to_photo_name: String
    }
    struct ResultFollowJson: Codable {
        let count: Int
        let result: [FollowResult]
    }
    var followList: [(toUserId:String, toUserName:String, toNoticeType:String, toNoticeText:String, toNoticeRirekiId:String, toNoticeRirekiInsTime:String, value01:String, modTime:String, toPhotoFlg:String, toPhotoName:String)] = []
    var followListTemp: [(toUserId:String, toUserName:String, toNoticeType:String, toNoticeText:String, toNoticeRirekiId:String, toNoticeRirekiInsTime:String, value01:String, modTime:String, toPhotoFlg:String, toPhotoName:String)] = []
    
    //ユーザー情報取得用(現在の絆レベルの経験値を取得用)
    var strUserId: String = ""
    var strUuid: String = ""
    var strUserName: String = ""
    var strPhotoFlg: String = ""
    var strPhotoName: String = ""
    var strConnectLevel: String = ""
    var strConnectExp: String = ""
    var strConnectLiveCount: String = ""
    var strConnectPresentPoint: String = ""
    var strBlackListId: String = ""
    
    struct UserResult: Codable {
        let user_id: String
        let uuid: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let connect_level: String//
        let connect_exp: String//
        let connect_live_count: String//
        let connect_present_point: String//
        let black_list_id: String//ブラックリストに入っている場合はゼロ以外が入る
    }
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //自分のuser_idを指定
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        // Do any additional setup after loading the view.
        //テーブルの区切り線を非表示
        self.followTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.followTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.followTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.followTableView.allowsSelection = false // 選択を不可にする
        self.followTableView.isScrollEnabled = true
        self.followTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        //tableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.followTableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.followTableView.register(UINib(nibName: "YourChatPhotoCell", bundle: nil), forCellReuseIdentifier: "YourChatPhoto")
        self.followTableView.register(UINib(nibName: "YourChatPhotoTextCell", bundle: nil), forCellReuseIdentifier: "YourChatPhotoText")
        
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
            //フォローを表示するテーブル
            self.followTableView.isHidden = true//非表示
            //フォローしようの画像表示用
            self.followImageView.isHidden = false//表示
        }else{
            //フォローを表示するテーブル
            self.followTableView.isHidden = false//表示
            //フォローしようの画像表示用
            self.followImageView.isHidden = true//非表示
        }
        /**************************************************************/
        //10フォローしたら130コイン(ここまで)
        /**************************************************************/
        
        //タイムラインを初回見たかのフラグ(1:すでに見た)
        UserDefaults.standard.set(1, forKey: "timelineFirstFlg")
        
    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //サブメニューの選択
        UserDefaults.standard.set(1, forKey: "selectedSubMenuTimeline")
        
        //フォロー一覧を取得
        getFollowListByUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getFollowListByUser(){
        //クリアする
        self.followListTemp.removeAll()
        
        //リスト取得(自分以外の待機中のリストを取得
        var stringUrl = Util.URL_GET_FOLLOW_LIST
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
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
                    let json = try decoder.decode(ResultFollowJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する告知リストを配列にする。
                    for obj in json.result {
                        //ブラックリストの配列にない場合はnilが返される
                        if self.appDelegate.array_black_list.index(of: Int(obj.to_user_id)!) == nil {
                            let follow = (obj.to_user_id,
                                          obj.to_user_name.toHtmlString(),
                                          obj.to_notice_type,
                                          obj.to_notice_text.htmlDecoded,
                                          obj.to_notice_rireki_id,
                                          obj.to_notice_rireki_ins_time,
                                          obj.value01,
                                          obj.mod_time,
                                          obj.to_photo_flg,
                                          obj.to_photo_name)
                            //配列へ追加
                            self.followList.append(follow)
                            self.followListTemp.append(follow)
                        }
                    }
                    
                    dispatchGroup.leave()
                    //self.CollectionView.reloadData()
                    //print(json.result)
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
            self.followList = self.followListTemp
            
            self.followTableView.reloadData()
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
            
            /*
            //reloadDataの後に処理を行う方法
            UIView.animate(
                withDuration: 0.0,
                animations:{
                    // リロード
                    self.followTableView.reloadData()
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
    /*
    @IBAction func kokuchiBtnTap(_ sender: Any) {
        showAlertKokuchi(rank: 1)
    }
    
    @IBAction func followBtnTap(_ sender: Any) {
        showAlertFollow(rank: 1)
    }
    */

    //ボタンが押されるとこの関数が呼ばれる
    @objc func showAlertFollow(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag

        //UIAlertControllerを用意する
        //let strCastName = "雪梨冴愛"
        let strCastName = followList[buttonRow].toUserName
        let strCastId = followList[buttonRow].toUserId
        
        let actionAlert = UIAlertController(title: strCastName, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "フォロー解除", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            self.follow(flg: 2, to_user_id: Int(strCastId))
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

    func follow(flg: Int!,to_user_id: Int!){
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
            //絆レベルの更新(値プラス or マイナス)
            self.saveConnectLevel(user_id:self.user_id, target_user_id:to_user_id, exp:Util.CONNECTION_POINT_FOLLOW, live_count:0, present_point:0, flg:flg)
        }
    }

    //絆レベルの更新・追加(更新後に処理をする必要があるため、Utilではなくこちらを使用)
    //flg:1:値プラス、2:値マイナス
    //GET: user_id, target_user_id,level,exp,live_count,present_point,flg
    func saveConnectLevel(user_id:Int, target_user_id:Int, exp:Int, live_count:Int, present_point:Int, flg:Int){
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
            //フォロー一覧を取得して再描画
            self.getFollowListByUser()
        }
    }
    
    //ボタンが押されるとこの関数が呼ばれる
    @objc func showAlertKokuchi(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag

        //UIAlertControllerを用意する
        let strCastName = followList[buttonRow].toUserName
        let strCastId = followList[buttonRow].toUserId
        let strKokuchiFlg = followList[buttonRow].value01
        var kokuchiFlg = 0//変更後の待機通知フラグ（告知フラグでなく、通知フラグに仕様変更）
        var strTitle = "待機通知をオン"
        if(strKokuchiFlg == "1"){
            strTitle = "待機通知をオフ"
            kokuchiFlg = 2//2に変更するという意味
        }else{
            strTitle = "待機通知をオン"
            kokuchiFlg = 1//1に変更するという意味
        }

        let actionAlert = UIAlertController(title: strCastName, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: strTitle, style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            var stringUrl = Util.URL_KOKUCHI_DO
            stringUrl.append("?from_user_id=")
            stringUrl.append(String(self.user_id))
            stringUrl.append("&to_user_id=")
            stringUrl.append(strCastId)
            stringUrl.append("&flg=")
            stringUrl.append(String(kokuchiFlg))
            
            print(stringUrl)
            
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
                //フォロー一覧を取得して再描画
                self.getFollowListByUser()
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
    }

    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //フォローリストの総数
        return followList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        if(followList[indexPath.row].toNoticeType == "2"){
            //画像のみ
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChatPhoto") as! YourChatPhotoCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.castNameLabel.text = followList[indexPath.row].toUserName

            let photoUrl: String = "timeline/"
                + followList[indexPath.row].toUserId
                + "/"
                + followList[indexPath.row].toNoticeRirekiId
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
            
            //キャスト画像の表示
            let photoFlg = followList[indexPath.row].toPhotoFlg
            let photoName = followList[indexPath.row].toPhotoName
            let user_id = followList[indexPath.row].toUserId
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
            }
            
            //ボタンを表示
            cell.followBtn.isHidden = false
            cell.kokuchiBtn.isHidden = false
            cell.dateLbl.isHidden = true
            cell.iineBtn.isHidden = true
            //cell.iineLblBtn.isHidden = true
            //cell.iineTextView.isHidden = true
            
            cell.followBtn?.tag = indexPath.row
            cell.kokuchiBtn?.tag = indexPath.row
            
            if(followList[indexPath.row].value01 == "1"){
                //待機通知オンの場合は「待機通知オン」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オン", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = Util.KOKUCHI_ON_COLOR
                //cell.kokuchiBtn.layer.borderColor = Util.KOKUCHI_ON_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0
            }else{
                //それ以外は「待機通知オフ」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オフ", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = UIColor.white
                cell.kokuchiBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0.5
            }
            
            cell.followBtn.setTitle("フォロー中", for: .normal)
            cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
            cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
            //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
            cell.followBtn.layer.borderWidth = 0
            
            //ボタンを押した時の処理
            //let cast_id_temp = Int(followList[indexPath.row].toUserId)
            cell.followBtn?.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
            cell.kokuchiBtn?.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            
            return cell
        }else if(followList[indexPath.row].toNoticeType == "3"){
            //テキストかつ画像
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChatPhotoText") as! YourChatPhotoTextCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.castNameLabel.text = followList[indexPath.row].toUserName
            if(followList[indexPath.row].toNoticeText == "0"){
                cell.textView?.text = ""
            }else{
                cell.textView?.text = followList[indexPath.row].toNoticeText
            }
            
            let photoUrl: String = "timeline/"
                + followList[indexPath.row].toUserId
                + "/"
                + followList[indexPath.row].toNoticeRirekiId
                + "_list.jpg"
            
            //print(photoUrl)
            
            //画像キャッシュを使用
            cell.imagePhotoView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
            
            cell.imagePhotoView.isUserInteractionEnabled = true
            cell.imagePhotoView.tag = indexPath.row
            cell.imagePhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:))))
            
            // 角丸
            cell.imagePhotoView.layer.cornerRadius = 10
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            cell.imagePhotoView.layer.masksToBounds = true
            
            //キャスト画像の表示
            let photoFlg = followList[indexPath.row].toPhotoFlg
            let photoName = followList[indexPath.row].toPhotoName
            let user_id = followList[indexPath.row].toUserId
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
            }
            
            //ボタンを表示
            cell.followBtn.isHidden = false
            cell.kokuchiBtn.isHidden = false
            cell.dateLbl.isHidden = true
            cell.iineBtn.isHidden = true
            //cell.iineLblBtn.isHidden = true
            //cell.iineTextView.isHidden = true
            
            cell.followBtn?.tag = indexPath.row
            cell.kokuchiBtn?.tag = indexPath.row
            
            if(followList[indexPath.row].value01 == "1"){
                //待機通知オンの場合は「待機通知オン」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オン", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = Util.KOKUCHI_ON_COLOR
                //cell.kokuchiBtn.layer.borderColor = Util.KOKUCHI_ON_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0
            }else{
                //それ以外は「待機通知オフ」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オフ", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = UIColor.white
                cell.kokuchiBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0.5
            }
            
            cell.followBtn.setTitle("フォロー中", for: .normal)
            cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
            cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
            //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
            cell.followBtn.layer.borderWidth = 0
            
            //ボタンを押した時の処理
            //let cast_id_temp = Int(followList[indexPath.row].toUserId)
            cell.followBtn?.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
            cell.kokuchiBtn?.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            
            return cell
        }else{
            //テキストのみ
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChat") as! YourChatViewCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.castNameLabel.text = followList[indexPath.row].toUserName
            if(followList[indexPath.row].toNoticeText == "0"){
                cell.textView?.text = ""
            }else{
                cell.textView?.text = followList[indexPath.row].toNoticeText
            }
            
            //キャスト画像の表示
            let photoFlg = followList[indexPath.row].toPhotoFlg
            let photoName = followList[indexPath.row].toPhotoName
            let user_id = followList[indexPath.row].toUserId
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
            }
            
            //ボタンを表示
            cell.followBtn.isHidden = false
            cell.kokuchiBtn.isHidden = false
            cell.dateLbl.isHidden = true
            cell.iineBtn.isHidden = true
            //cell.iineLblBtn.isHidden = true
            //cell.iineTextView.isHidden = true
            
            cell.followBtn?.tag = indexPath.row
            cell.kokuchiBtn?.tag = indexPath.row
            
            if(followList[indexPath.row].value01 == "1"){
                //待機通知オンの場合は「待機通知オン」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オン", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = Util.KOKUCHI_ON_COLOR
                //cell.kokuchiBtn.layer.borderColor = Util.KOKUCHI_ON_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0
            }else{
                //それ以外は「待機通知オフ」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オフ", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = UIColor.white
                cell.kokuchiBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0.5
            }
            
            cell.followBtn.setTitle("フォロー中", for: .normal)
            cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
            cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
            //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
            cell.followBtn.layer.borderWidth = 0
            
            //ボタンを押した時の処理
            //let cast_id_temp = Int(followList[indexPath.row].toUserId)
            cell.followBtn?.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
            cell.kokuchiBtn?.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func onClickCastInfo(_ sender: UITapGestureRecognizer){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        //let buttonRow = sender.tag
        let buttonRow = sender.view?.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.followList[buttonRow!].toUserId//相手のID
        UtilToViewController.toUserInfoViewController()
    }
    
    // 画像がタップされたら呼ばれる(相手の画像)
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view?.tag
        //print("タップ")
        //マイコレクションの個別画面へ渡す
        appDelegate.myCollectionType = "3"
        appDelegate.myCollectionSelectCastId = self.followList[buttonRow!].toUserId//相手のID
        appDelegate.myCollectionSelectCastName = self.followList[buttonRow!].toUserName//相手の名前
        appDelegate.myCollectionSelectInsTime = self.followList[buttonRow!].toNoticeRirekiInsTime
        appDelegate.myCollectionSelectPhotoFileName = self.followList[buttonRow!].toNoticeRirekiId
        
        UtilToViewController.toCollectionImageViewController(animated_flg:false)
    }
}

//tableviewの上部の空白を削除する(swift4)
// MARK: - UITableViewDelegate
extension FollowViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
