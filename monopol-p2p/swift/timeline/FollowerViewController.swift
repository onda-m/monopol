//
//  FollowerViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FollowerViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "フォロワー"
    
    var user_id: Int = 0//自分のID
    
    @IBOutlet weak var followerTableView: UITableView!
    
    /*
    //フォロワーの一覧用
    //相互フォローを考慮する必要がある
    struct FollowerResult: Codable {
        let from_user_id: String
        let from_user_name: String
        let from_notice_type: String
        let from_notice_text: String
        let from_notice_rireki_id: String
        let from_notice_rireki_ins_time: String
        let value01: String//1:待機通知オン 2:待機通知オフ
        let mod_time: String
        let from_photo_flg: String
        let from_photo_name: String
        let each_other_flg: String//1 or 2:相互フォロー中
    }
    struct ResultFollowerJson: Codable {
        let count: Int
        let result: [FollowerResult]
    }
     */
    var followerList: [(fromUserId:String, fromUserName:String, fromNoticeType:String, fromNoticeText:String, fromNoticeRirekiId:String, fromNoticeRirekiInsTime:String, value01:String, modTime:String, fromPhotoFlg:String, fromPhotoName:String, eachOtherFlg:String)] = []
    var followerListTemp: [(fromUserId:String, fromUserName:String, fromNoticeType:String, fromNoticeText:String, fromNoticeRirekiId:String, fromNoticeRirekiInsTime:String, value01:String, modTime:String, fromPhotoFlg:String, fromPhotoName:String, eachOtherFlg:String)] = []
    
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
        self.followerTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.followerTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.followerTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.followerTableView.allowsSelection = false // 選択を不可にする
        self.followerTableView.isScrollEnabled = true
        self.followerTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        //tableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.followerTableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.followerTableView.register(UINib(nibName: "YourChatPhotoCell", bundle: nil), forCellReuseIdentifier: "YourChatPhoto")
        self.followerTableView.register(UINib(nibName: "YourChatPhotoTextCell", bundle: nil), forCellReuseIdentifier: "YourChatPhotoText")
        
        //self.bottomView = ChatRoomInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)) // 下部に表示するテキストフィールドを設定
        
        //CollectionView.reloadData()
    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //サブメニューの選択
        UserDefaults.standard.set(2, forKey: "selectedSubMenuTimeline")
        
        //フォロワー一覧を取得
        getFollowerListByUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getFollowerListByUser(){
        //クリアする
        self.followerListTemp.removeAll()
        
        //リスト取得(自分以外の待機中のリストを取得)
        var stringUrl = Util.URL_GET_FOLLOW_LIST
        stringUrl.append("?to_user_id=")
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
                    let json = try decoder.decode(UtilStruct.ResultFollowerJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する告知リストを配列にする。
                    for obj in json.result {
                        //ブラックリストの配列にない場合はnilが返される
                        if self.appDelegate.array_black_list.index(of: Int(obj.from_user_id)!) == nil {
                            let follower = (obj.from_user_id,
                                            obj.from_user_name.toHtmlString(),
                                            obj.from_notice_type,
                                            obj.from_notice_text.htmlDecoded,
                                            obj.from_notice_rireki_id,
                                            obj.from_notice_rireki_ins_time,
                                            obj.value01,
                                            obj.mod_time,
                                            obj.from_photo_flg,
                                            obj.from_photo_name,
                                            obj.each_other_flg)
                            //配列へ追加
                            self.followerList.append(follower)
                            self.followerListTemp.append(follower)
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
            self.followerList = self.followerListTemp
            
            self.followerTableView.reloadData()
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
            
            /*
            //reloadDataの後に処理を行う方法
            UIView.animate(
                withDuration: 0.0,
                animations:{
                    // リロード
                    self.followerTableView.reloadData()
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
    @objc func showAlertFollow(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        
        //UIAlertControllerを用意する
        let strCastName = followerList[buttonRow].fromUserName
        let targetId = Int(followerList[buttonRow].fromUserId)
        let followFlg = followerList[buttonRow].eachOtherFlg
        
        let actionAlert = UIAlertController(title: strCastName, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if(followFlg == "1" || followFlg == "2"){
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォロー解除", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:2, target_id:targetId)
            })
            actionAlert.addAction(modifyAction)
        }else{
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォローする", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:1, target_id:targetId)
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
        //フォローの追加・削除 GET:from_user_id,to_user_id,flg
        //flg=1:追加 2:削除
        var stringUrl = Util.URL_FOLLOW_DO
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&to_user_id=")
        stringUrl.append(String(target_id))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        
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
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //現在の絆レベルの経験値を取得する
            var stringUrl = Util.URL_USER_INFO
            stringUrl.append("?user_id=")
            stringUrl.append(String(target_id))
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
                        let json = try decoder.decode(ResultJson.self, from: data!)
                        
                        //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                        for obj in json.result {
                            self.strUserId = obj.user_id
                            self.strUuid = obj.uuid
                            self.strUserName = obj.user_name
                            self.strPhotoFlg = obj.photo_flg
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

                //現在の絆レベルの経験値
                var connection_exp: Int = Int(self.strConnectExp)!
                
                //flg=1:追加 2:削除
                if(flg == 1){
                    UtilFunc.plusFollow()
                    connection_exp = connection_exp + Util.CONNECTION_POINT_FOLLOW
                }else{
                    UtilFunc.minusFollow()
                    connection_exp = connection_exp - Util.CONNECTION_POINT_FOLLOW
                }
                
                //絆レベルの更新(値プラス or マイナス)
                self.saveConnectLevel(user_id:self.user_id, target_user_id:target_id, exp:Util.CONNECTION_POINT_FOLLOW, live_count:0, present_point:0, flg:flg)
            }
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
            //月間ペアランキングに反映
            //Util.savePairMonthRankingNew(user_id:user_id, cast_id:target_user_id, exp:Util.CONNECTION_POINT_FOLLOW, flg:flg)
            //フォロワー一覧を取得し再描画
            self.getFollowerListByUser()
        }
    }
    
    //ボタンが押されるとこの関数が呼ばれる
    @objc func showAlertKokuchi(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        
        //UIAlertControllerを用意する
        let strCastName = followerList[buttonRow].fromUserName
        let strCastId = followerList[buttonRow].fromUserId
        //let strKokuchiFlg = followerList[buttonRow].value01
        let strKokuchiFlg = followerList[buttonRow].eachOtherFlg
        
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
                //フォロワー一覧を取得し再描画
                self.getFollowerListByUser()
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
        //告知リストの総数
        return followerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        if(followerList[indexPath.row].fromNoticeType == "2"){
            //画像のみ
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChatPhoto") as! YourChatPhotoCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.castNameLabel.text = followerList[indexPath.row].fromUserName
            
            let photoUrl: String = "timeline/"
                + followerList[indexPath.row].fromUserId
                + "/"
                + followerList[indexPath.row].fromNoticeRirekiId
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
            
            //ユーザー画像の表示
            let photoFlg = followerList[indexPath.row].fromPhotoFlg
            let photoName = followerList[indexPath.row].fromPhotoName
            let user_id = followerList[indexPath.row].fromUserId
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
            cell.dateLbl.isHidden = true
            cell.iineBtn.isHidden = true
            //cell.iineLblBtn.isHidden = true
            
            cell.followBtn?.tag = indexPath.row
            cell.kokuchiBtn?.tag = indexPath.row
            
            if(followerList[indexPath.row].eachOtherFlg == "1"){
                //相互フォロー中
                cell.kokuchiBtn.isHidden = false
                //待機通知オンの場合は「待機通知オン」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オン", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = Util.KOKUCHI_ON_COLOR
                //cell.kokuchiBtn.layer.borderColor = Util.KOKUCHI_ON_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0
                
                cell.followBtn.setTitle("フォロー中", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
                cell.kokuchiBtn.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            }else if(followerList[indexPath.row].eachOtherFlg == "2"){
                //相互フォロー中
                cell.kokuchiBtn.isHidden = false
                //「待機通知オフ」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オフ", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = UIColor.white
                cell.kokuchiBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0.5
                
                cell.followBtn.setTitle("フォロー中", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
                cell.kokuchiBtn.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            }else{
                //相手をフォローしていない
                cell.kokuchiBtn.isHidden = true
                
                cell.followBtn.setTitle("＋フォロー", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = UIColor.white
                cell.followBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0.5
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
            }
            
            return cell
        }else if(followerList[indexPath.row].fromNoticeType == "3"){
            //テキストかつ画像
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChatPhotoText") as! YourChatPhotoTextCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.castNameLabel.text = followerList[indexPath.row].fromUserName
            
            if(followerList[indexPath.row].fromNoticeText == "0"){
                cell.textView?.text = ""
            }else{
                cell.textView?.text = followerList[indexPath.row].fromNoticeText
            }
            
            let photoUrl: String = "timeline/"
                + followerList[indexPath.row].fromUserId
                + "/"
                + followerList[indexPath.row].fromNoticeRirekiId
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
            
            //ユーザー画像の表示
            let photoFlg = followerList[indexPath.row].fromPhotoFlg
            let photoName = followerList[indexPath.row].fromPhotoName
            let user_id = followerList[indexPath.row].fromUserId
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
            cell.dateLbl.isHidden = true
            cell.iineBtn.isHidden = true
            //cell.iineLblBtn.isHidden = true
            
            cell.followBtn?.tag = indexPath.row
            cell.kokuchiBtn?.tag = indexPath.row
            
            if(followerList[indexPath.row].eachOtherFlg == "1"){
                //相互フォロー中
                cell.kokuchiBtn.isHidden = false
                //待機通知オンの場合は「待機通知オン」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オン", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = Util.KOKUCHI_ON_COLOR
                //cell.kokuchiBtn.layer.borderColor = Util.KOKUCHI_ON_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0
                
                cell.followBtn.setTitle("フォロー中", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
                cell.kokuchiBtn.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            }else if(followerList[indexPath.row].eachOtherFlg == "2"){
                //相互フォロー中
                cell.kokuchiBtn.isHidden = false
                //「待機通知オフ」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オフ", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = UIColor.white
                cell.kokuchiBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0.5
                
                cell.followBtn.setTitle("フォロー中", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
                cell.kokuchiBtn.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            }else{
                //相手をフォローしていない
                cell.kokuchiBtn.isHidden = true
                
                cell.followBtn.setTitle("＋フォロー", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = UIColor.white
                cell.followBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0.5
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
            }
            
            return cell
        }else{
            //テキストのみ
            let cell = tableView.dequeueReusableCell(withIdentifier: "YourChat") as! YourChatViewCell
            cell.clipsToBounds = true //bound外のものを表示しない
            cell.castNameLabel.text = followerList[indexPath.row].fromUserName
            
            if(followerList[indexPath.row].fromNoticeText == "0"){
                cell.textView?.text = ""
            }else{
                cell.textView?.text = followerList[indexPath.row].fromNoticeText
            }
            
            //ユーザー画像の表示
            let photoFlg = followerList[indexPath.row].fromPhotoFlg
            let photoName = followerList[indexPath.row].fromPhotoName
            let user_id = followerList[indexPath.row].fromUserId
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
            cell.dateLbl.isHidden = true
            cell.iineBtn.isHidden = true
            //cell.iineLblBtn.isHidden = true
            
            cell.followBtn?.tag = indexPath.row
            cell.kokuchiBtn?.tag = indexPath.row
            
            if(followerList[indexPath.row].eachOtherFlg == "1"){
                //相互フォロー中
                cell.kokuchiBtn.isHidden = false
                //待機通知オンの場合は「待機通知オン」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オン", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = Util.KOKUCHI_ON_COLOR
                //cell.kokuchiBtn.layer.borderColor = Util.KOKUCHI_ON_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0
                
                cell.followBtn.setTitle("フォロー中", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
                cell.kokuchiBtn.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            }else if(followerList[indexPath.row].eachOtherFlg == "2"){
                //相互フォロー中
                cell.kokuchiBtn.isHidden = false
                //「待機通知オフ」のボタンを表示
                cell.kokuchiBtn.setTitle("待機通知オフ", for: .normal) // ボタンのタイトル
                cell.kokuchiBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.kokuchiBtn.backgroundColor = UIColor.white
                cell.kokuchiBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.kokuchiBtn.layer.borderWidth = 0.5
                
                cell.followBtn.setTitle("フォロー中", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
                //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
                cell.kokuchiBtn.addTarget(self, action: #selector(showAlertKokuchi(sender: )), for: .touchUpInside)
            }else{
                //相手をフォローしていない
                cell.kokuchiBtn.isHidden = true
                
                cell.followBtn.setTitle("＋フォロー", for: .normal)
                //枠の大きさを自動調節する
                cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                cell.followBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                cell.followBtn.backgroundColor = UIColor.white
                cell.followBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                cell.followBtn.layer.borderWidth = 0.5
                
                //ボタンを押した時の処理
                //let cast_id_temp = Int(followList[indexPath.row].toUserId)
                cell.followBtn.addTarget(self, action: #selector(showAlertFollow(sender: )), for: .touchUpInside)
            }
            
            return cell
        }
    }
    
    @objc func onClickCastInfo(_ sender: UITapGestureRecognizer){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        //let buttonRow = sender.tag
        let buttonRow = sender.view?.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.followerList[buttonRow!].fromUserId//相手のID
        UtilToViewController.toUserInfoViewController()
    }
    
    // 画像がタップされたら呼ばれる(相手の画像)
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view?.tag
        //print("タップ")
        //マイコレクションの個別画面へ渡す
        appDelegate.myCollectionType = "3"
        appDelegate.myCollectionSelectCastId = self.followerList[buttonRow!].fromUserId//相手のID
        appDelegate.myCollectionSelectCastName = self.followerList[buttonRow!].fromUserName//相手の名前
        //appDelegate.myCollectionSelectInsTime = self.followerList[buttonRow!].modTime
        appDelegate.myCollectionSelectInsTime = self.followerList[buttonRow!].fromNoticeRirekiInsTime
        appDelegate.myCollectionSelectPhotoFileName = self.followerList[buttonRow!].fromNoticeRirekiId
        
        UtilToViewController.toCollectionImageViewController(animated_flg:false)
    }
}

//tableviewの上部の空白を削除する(swift4)
// MARK: - UITableViewDelegate
extension FollowerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
