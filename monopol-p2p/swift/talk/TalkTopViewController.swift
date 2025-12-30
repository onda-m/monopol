//
//  TalkTopViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/03.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class TalkTopViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    //URL_GET_TALK_RIREKI

    @IBOutlet weak var talkTableView: UITableView!
    
    //日付表示の計算用
    let dateString = Date() //現在時刻
    let formatter = DateFormatter()

    //トークの一覧用(修正必要)
    struct TalkResult: Codable {
        let rireki_id: String
        let official_flg: String//1:公式
        let user_id: String
        let target_user_id: String
        let open_status: String
        let photo_flg: String//0:コメントの場合 1:画像の場合
        let value01: String//トーク内容
        let value02: String//運営からのトーク内容(改行抜き)
        let mod_time: String
        let src_user_name: String
        let src_photo_flg: String//自分プロフィール画像のフォトフラグ
        let src_photo_name: String
        let tar_user_name: String
        let tar_photo_flg: String//相手プロフィール画像のフォトフラグ
        let tar_photo_name: String
    }
    struct ResultTalkJson: Codable {
        let count: Int
        let result: [TalkResult]
    }
    var talkList: [(rireki_id:String, official_flg:String, user_id:String, target_user_id:String
        , open_status:String, photo_flg:String, value01:String, value02:String, mod_time:String
        , src_user_name:String, src_photo_flg:String, src_photo_name:String
        , tar_user_name:String, tar_photo_flg:String, tar_photo_name:String)] = []
    
    var talkListTemp: [(rireki_id:String, official_flg:String, user_id:String, target_user_id:String
        , open_status:String, photo_flg:String, value01:String, value02:String, mod_time:String
        , src_user_name:String, src_photo_flg:String, src_photo_name:String
        , tar_user_name:String, tar_photo_flg:String, tar_photo_name:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //日付表示の計算用
        //formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" //フォーマット合わせる
        formatter.locale = Locale(identifier: "en_US_POSIX")//重要
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //フォーマット合わせる
        //formatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
        
        // Do any additional setup after loading the view.
        
        //自分のIDをセット
        //user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //トーク一覧を取得
        //getTalkRirekiByUser()
        
        //テーブルの区切り線を非表示
        self.talkTableView.separatorColor = UIColor.clear
        self.talkTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.talkTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        //self.talkTableView.allowsSelection = false // 選択を不可にする
        self.talkTableView.isScrollEnabled = true
        self.talkTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        //tableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.talkTableView.register(UINib(nibName: "TalkTopViewCell", bundle: nil), forCellReuseIdentifier: "TalkTop")
        //self.talkTableView.register(UINib(nibName: "TalkTopPhotoCell", bundle: nil), forCellReuseIdentifier: "TalkTopPhoto")
        
        //iphone Xのみテーブルのズレが生じる場合があるので、その対応
        if #available(iOS 11.0, *) {
            //self.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior
            self.talkTableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //トークのトップはviewWillAppearに記述
        //そうしないと画面戻ってきた時にデータが反映されない
        self.getTalkRirekiByUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTalkRirekiByUser(){
        //クリアする
        //self.talkList.removeAll()
        self.talkListTemp.removeAll()
        
        //リスト取得(自分以外の待機中のリストを取得)
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        var stringUrl = Util.URL_GET_TALK_RIREKI
        stringUrl.append("?order=1&user_id=")
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
                    //すでに追加した相手ユーザーID
                    var target_user_id_check = [String]()
                    
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultTalkJson.self, from: data!)
                    //self.idCount = json.count
                    
                    var official_count = 0
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        //let strRirekiId = obj.rireki_id
                        //let strOfficialFlg = obj.official_flg
                        //let strUserId = obj.user_id
                        //let strTargetUserId = obj.target_user_id
                        //let strOpenStatus = obj.open_status
                        //let strPhotoFlg = obj.photo_flg
                        var strValue01 = obj.value01.toHtmlString()//トーク内容
                        var strValue02 = obj.value02.toHtmlString()//トーク内容(運営局からの投稿・改行抜き)
                        //let strModTime = obj.mod_time
                        //let strSrcUserName = obj.src_user_name.toHtmlString()
                        //let strSrcPhotoFlg = obj.src_photo_flg
                        //let strSrcPhotoName = obj.src_photo_name
                        //let strTarUserName = obj.tar_user_name.toHtmlString()
                        //let strTarPhotoFlg = obj.tar_photo_flg
                        //let strTarPhotoName = obj.tar_photo_name
                        
                        //公式からのお知らせに表示するデータの選別
                        //if(obj.official_flg == "1" || obj.official_flg == "3"){
                        if(obj.official_flg != "2"){
                            if(official_count == 1){
                                //すでに存在するので追加しない
                            }else{
                                //追加ずみフラグを立てる
                                official_count = 1
                                
                                //前後の空白・改行を削除
                                //strValue01.trimmingCharacters(in: .whitespacesAndNewlines)
                                strValue01 = strValue01.replacingOccurrences(of: "\n", with: "")
                                strValue02 = strValue02.replacingOccurrences(of: "\n", with: "")
                                
                                let talk = (obj.rireki_id,
                                            obj.official_flg,
                                            obj.user_id,
                                            obj.target_user_id,
                                            obj.open_status,
                                            obj.photo_flg,
                                            strValue01,
                                            strValue02,
                                            obj.mod_time,
                                            obj.src_user_name.toHtmlString(),
                                            obj.src_photo_flg,
                                            obj.src_photo_name,
                                            obj.tar_user_name.toHtmlString(),
                                            obj.tar_photo_flg,
                                            obj.tar_photo_name)
                                //配列へ追加
                                self.talkList.append(talk)
                                self.talkListTemp.append(talk)
                            }
                        }else{
                            if(self.appDelegate.array_black_list.index(of: Int(obj.user_id)!)
                                != nil){
                                //ブラックリストに登録されている場合、何もしない
                            }else if(self.appDelegate.array_black_list.index(of: Int(obj.target_user_id)!) != nil){
                                //ブラックリストに登録されている場合、何もしない
                            }else{
                                /******************************************/
                                //DBから取得したデータをグループバイする必要がある
                                /******************************************/
                                if(obj.user_id == String(self.user_id)){
                                    //obj.target_user_idが追加済みかチェックする
                                    if(target_user_id_check.contains(obj.target_user_id)){
                                        //追加ずみの場合
                                        //何もしない
                                    }else{
                                        //チェック配列に追加する
                                        target_user_id_check.append(obj.target_user_id)
                                        
                                        //前後の空白・改行を削除
                                        //strValue01.trimmingCharacters(in: .whitespacesAndNewlines)
                                        strValue01 = strValue01.replacingOccurrences(of: "\n", with: "")
                                        strValue02 = strValue02.replacingOccurrences(of: "\n", with: "")
                                        
                                        let talk = (obj.rireki_id,
                                                    obj.official_flg,
                                                    obj.user_id,
                                                    obj.target_user_id,
                                                    obj.open_status,
                                                    obj.photo_flg,
                                                    strValue01,
                                                    strValue02,
                                                    obj.mod_time,
                                                    obj.src_user_name.toHtmlString(),
                                                    obj.src_photo_flg,
                                                    obj.src_photo_name,
                                                    obj.tar_user_name.toHtmlString(),
                                                    obj.tar_photo_flg,
                                                    obj.tar_photo_name)
                                        //配列へ追加
                                        self.talkList.append(talk)
                                        self.talkListTemp.append(talk)
                                    }
                                }else if(obj.target_user_id == String(self.user_id)){
                                    //obj.user_idが追加済みかチェックする
                                    if(target_user_id_check.contains(obj.user_id)){
                                        //追加ずみの場合
                                        //何もしない
                                    }else{
                                        //チェック配列に追加する
                                        target_user_id_check.append(obj.user_id)
                                        
                                        //前後の空白・改行を削除
                                        //strValue01.trimmingCharacters(in: .whitespacesAndNewlines)
                                        strValue01 = strValue01.replacingOccurrences(of: "\n", with: "")
                                        strValue02 = strValue02.replacingOccurrences(of: "\n", with: "")
                                        
                                        let talk = (obj.rireki_id,
                                                    obj.official_flg,
                                                    obj.user_id,
                                                    obj.target_user_id,
                                                    obj.open_status,
                                                    obj.photo_flg,
                                                    strValue01,
                                                    strValue02,
                                                    obj.mod_time,
                                                    obj.src_user_name.toHtmlString(),
                                                    obj.src_photo_flg,
                                                    obj.src_photo_name,
                                                    obj.tar_user_name.toHtmlString(),
                                                    obj.tar_photo_flg,
                                                    obj.tar_photo_name)
                                        //配列へ追加
                                        self.talkList.append(talk)
                                        self.talkListTemp.append(talk)
                                    }
                                }
                                /******************************************/
                                //DBから取得したデータをグループバイする必要がある(ここまで)
                                /******************************************/
                            }
                        }
                    }
                    
                    dispatchGroup.leave()
                    //self.CollectionView.reloadData()
                    //print(json.result)
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
            
            /*
            var ph = [String]()
            var newjson = [[String:String]]()
            
            for dict in json {
                if ph.contains(dict["Phone"]!) {
                    
                    print("duplicate phone \(dict["Phone"]!)")
                    
                } else {
                    
                    ph.append(dict["Phone"]!)
                    newjson.append(dict)
                    
                }
            }
            //print(newjson)
            */
            
            //コピーする
            self.talkList = self.talkListTemp
            
            //リストの取得を待ってから更新
            //self.CollectionView.reloadData()
            self.talkTableView.reloadData()
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
        //フォローリストの総数
        return talkList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        //クリアする(キャッシュのクリア対応)
        let subviews = tableView.subviews
        for subview in subviews {
            UtilFunc.removeSubviews(parentView: subview)
        }
        //クリアする(ここまで)
        */
        
        //表示する1行を取得する
        if(talkList[indexPath.row].official_flg == "1"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTop") as! TalkTopViewCell
            cell.clipsToBounds = true //bound外のものを表示しない
            // セルの選択不可にする
            cell.selectionStyle = .none
            
            cell.nameLabel.text = "モノポル事務局"
            //cell.textView.text = talkList[indexPath.row].value01
            /*
            if(talkList[indexPath.row].value01.count >= 38){
                //文字数が多い場合
                let str = talkList[indexPath.row].value01
                let array = str.splitInto(38)
                cell.messageLbl.text = array[0] + "……"
            }else{
                cell.messageLbl.text = talkList[indexPath.row].value01
            }
             */
            cell.messageLbl.text = talkList[indexPath.row].value02//運営からの投稿の場合はvalue02を使用
            
            //高さ調整（テキストの上寄せ）
            var rect:CGRect = cell.messageLbl.frame
            cell.messageLbl.sizeToFit()
            rect.size.height = cell.messageLbl.frame.height
            cell.messageLbl.frame = rect
            
            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
            let cellImage = UIImage(named: "monopol_office")
            // UIImageをUIImageViewのimageとして設定
            cell.talkImageView.image = cellImage
            
            cell.talkImageView.isUserInteractionEnabled = false//選択を不可にする
            
            let posTimeText:String = formatter.date(from: talkList[indexPath.row].mod_time)!.timeAgoSinceDate(numericDates: true)
            cell.dateLbl.text = posTimeText//**分前の表示
            
            return cell
        }else{
            
            var target_name:String = ""
            let select_user_id:Int = Int(talkList[indexPath.row].user_id)!
            let select_target_user_id:Int = Int(talkList[indexPath.row].target_user_id)!
            let select_open_status:Int = Int(talkList[indexPath.row].open_status)!
            let select_photo:Int = Int(talkList[indexPath.row].photo_flg)!
            
            if(select_open_status == 3
                && select_target_user_id == self.user_id){
                //未読(山田花子さんからメッセージが届いています)
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTop") as! TalkTopViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                // セルの選択不可にする
                cell.selectionStyle = .none
                
                //他人の投稿
                //appDelegate.sendId = talkList[indexPath.row].user_id
                cell.nameLabel.text = talkList[indexPath.row].src_user_name
                target_name = talkList[indexPath.row].src_user_name
                
                //キャスト画像の表示
                let photoFlg = talkList[indexPath.row].src_photo_flg
                let photoName = talkList[indexPath.row].src_photo_name
                if(photoFlg == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + String(select_user_id) + "_profile.jpg"
                    let photoUrl = "user_images/" + String(select_user_id) + "/" + photoName + "_profile.jpg"
                    
                    //画像キャッシュを使用
                    cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                    
                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    cell.talkImageView.image = cellImage
                }
                
                cell.talkImageView.isUserInteractionEnabled = true
                cell.talkImageView.tag = indexPath.row
                cell.talkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))

                cell.messageLbl.text = target_name + "さんからメッセージが届いています"
                
                //高さ調整（テキストの上寄せ）
                var rect:CGRect = cell.messageLbl.frame
                cell.messageLbl.sizeToFit()
                rect.size.height = cell.messageLbl.frame.height
                cell.messageLbl.frame = rect
                
                let posTimeText:String = formatter.date(from: talkList[indexPath.row].mod_time)!.timeAgoSinceDate(numericDates: true)
                cell.dateLbl.text = posTimeText//**分前の表示
                
                return cell
            }else{
                //既読
                //テキスト・画像共通
                let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTop") as! TalkTopViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                // セルの選択不可にする
                cell.selectionStyle = .none
                
                if(self.user_id == select_user_id && select_target_user_id > 0){
                    //自分の投稿
                    //appDelegate.sendId = talkList[indexPath.row].target_user_id
                    cell.nameLabel.text = talkList[indexPath.row].tar_user_name
                    target_name = talkList[indexPath.row].tar_user_name
                    
                    //キャスト画像の表示
                    let photoFlg = talkList[indexPath.row].tar_photo_flg
                    let photoName = talkList[indexPath.row].tar_photo_name
                    if(photoFlg == "1"){
                        //写真設定済み
                        //let photoUrl = "user_images/" + String(select_target_user_id) + "_profile.jpg"
                        let photoUrl = "user_images/" + String(select_target_user_id) + "/" + photoName + "_profile.jpg"
                        
                        //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                        //    cell.talkImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                        //}
                        //画像キャッシュを使用
                        cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                        
                    }else{
                        let cellImage = UIImage(named:"no_image")
                        // UIImageをUIImageViewのimageとして設定
                        cell.talkImageView.image = cellImage
                    }
                    
                    cell.talkImageView.isUserInteractionEnabled = true
                    cell.talkImageView.tag = indexPath.row
                    cell.talkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
                    
                }else if(self.user_id == select_target_user_id && select_user_id > 0){
                    //他人の投稿
                    //appDelegate.sendId = talkList[indexPath.row].user_id
                    cell.nameLabel.text = talkList[indexPath.row].src_user_name
                    target_name = talkList[indexPath.row].src_user_name
                    
                    //キャスト画像の表示
                    let photoFlg = talkList[indexPath.row].src_photo_flg
                    let photoName = talkList[indexPath.row].src_photo_name
                    if(photoFlg == "1"){
                        //写真設定済み
                        //let photoUrl = "user_images/" + String(select_user_id) + "_profile.jpg"
                        let photoUrl = "user_images/" + String(select_user_id) + "/" + photoName + "_profile.jpg"
                        
                        //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                        //    cell.talkImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                        //}
                        //画像キャッシュを使用
                        cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                        
                    }else{
                        let cellImage = UIImage(named:"no_image")
                        // UIImageをUIImageViewのimageとして設定
                        cell.talkImageView.image = cellImage
                    }
                    
                    cell.talkImageView.isUserInteractionEnabled = true
                    cell.talkImageView.tag = indexPath.row
                    cell.talkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
                }
                
                if(select_photo == 1){
                    //写真の場合
                    cell.messageLbl.text = "画像を送信しました"
                }else{
                    //文字の場合
                    //既読
                    /*
                    if(talkList[indexPath.row].value01.count >= 38){
                        //文字数が多い場合
                        let str = talkList[indexPath.row].value01
                        let array = str.splitInto(38)
                        cell.messageLbl.text = array[0] + "……"
                    }else{
                        cell.messageLbl.text = talkList[indexPath.row].value01
                    }
                     */
                    cell.messageLbl.text = talkList[indexPath.row].value01
                }
                
                //高さ調整（テキストの上寄せ）
                var rect:CGRect = cell.messageLbl.frame
                cell.messageLbl.sizeToFit()
                rect.size.height = cell.messageLbl.frame.height
                cell.messageLbl.frame = rect
                
                let posTimeText:String = formatter.date(from: talkList[indexPath.row].mod_time)!.timeAgoSinceDate(numericDates: true)
                cell.dateLbl.text = posTimeText//**分前の表示
                
                return cell
            }
        }
    }

    @objc func onClickCastInfo(_ sender: UITapGestureRecognizer){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        //let buttonRow = sender.tag
        let buttonRow = sender.view?.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        if(self.user_id != Int(talkList[buttonRow!].user_id)){
            self.appDelegate.sendId = talkList[buttonRow!].user_id//相手のID
        }else if(self.user_id != Int(talkList[buttonRow!].target_user_id)){
            self.appDelegate.sendId = talkList[buttonRow!].target_user_id//相手のID
        }
        UtilToViewController.toUserInfoViewController()
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath){
        if(talkList[indexPath.row].official_flg == "1"){
            self.appDelegate.sendId = "0"
            self.appDelegate.sendUserName = "モノポル事務局"
            self.appDelegate.sendPhotoFlg = talkList[indexPath.row].src_photo_flg
            self.appDelegate.sendPhotoName = talkList[indexPath.row].src_photo_name
            UtilToViewController.toTalkInfoViewController()
        }else{
            //トーク個別ページへ
            //user_idを次の画面（トークの詳細画面）へ渡す
            let select_user_id:Int = Int(talkList[indexPath.row].user_id)!
            let select_target_user_id:Int = Int(talkList[indexPath.row].target_user_id)!
            if(self.user_id == select_user_id && select_target_user_id > 0){
                self.appDelegate.sendId = talkList[indexPath.row].target_user_id
                self.appDelegate.sendUserName = talkList[indexPath.row].tar_user_name
                self.appDelegate.sendPhotoFlg = talkList[indexPath.row].tar_photo_flg
                self.appDelegate.sendPhotoName = talkList[indexPath.row].tar_photo_name
            }else if(self.user_id == select_target_user_id && select_user_id > 0){
                self.appDelegate.sendId = talkList[indexPath.row].user_id
                self.appDelegate.sendUserName = talkList[indexPath.row].src_user_name
                self.appDelegate.sendPhotoFlg = talkList[indexPath.row].src_photo_flg
                self.appDelegate.sendPhotoName = talkList[indexPath.row].src_photo_name
            }
            
            UtilToViewController.toTalkInfoViewController()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableViewAutomaticDimension //変更
        return 80 //変更
        /*
        //var target_name:String = ""
        let select_user_id:Int = Int(talkList[indexPath.row].user_id)!
        let select_target_user_id:Int = Int(talkList[indexPath.row].target_user_id)!
        let select_open_status:Int = Int(talkList[indexPath.row].open_status)!
        let select_photo:Int = Int(talkList[indexPath.row].photo_flg)!
        
        if((select_photo == 1 && self.user_id == select_user_id && select_target_user_id > 0)
            || (select_photo == 1 && self.user_id == select_target_user_id && select_user_id > 0 && select_open_status == 1)){
            //「既読かつ写真」または自分の投稿写真の場合
            return 200
        }else{
            //それ以外
            return UITableViewAutomaticDimension //変更
        }
         */
    }
    
    //tableviewの上部の空白を削除する(swift4)
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

    /*
    画像と文字をそれぞれ分けて表示するパターン（「画像を送信しました」というテキストを表示するパターンは上のソースを使用）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //クリアする(キャッシュのクリア対応)
        let subviews = tableView.subviews
        for subview in subviews {
            Util.removeSubviews(parentView: subview)
        }
        //クリアする(ここまで)
        
        //表示する1行を取得する
        if(talkList[indexPath.row].official_flg == "1"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTop") as! TalkTopViewCell
            cell.clipsToBounds = true //bound外のものを表示しない
            // セルの選択不可にする
            cell.selectionStyle = .none
            
            cell.nameLabel.text = "モノポル事務局"
            //cell.messageLbl.text = talkList[indexPath.row].value01
            if(talkList[indexPath.row].value01.count >= 38){
                //文字数が多い場合
                let str = talkList[indexPath.row].value01
                let array = str.splitInto(38)
                cell.messageLbl.text = array[0] + "……"
            }else{
                cell.messageLbl.text = talkList[indexPath.row].value01
            }
            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
            let cellImage = UIImage(named: "monopol_office")
            // UIImageをUIImageViewのimageとして設定
            cell.talkImageView.image = cellImage
            
            let posTimeText:String = formatter.date(from: talkList[indexPath.row].mod_time)!.timeAgoSinceDate(numericDates: true)
            cell.dateLbl.text = posTimeText//--分前の表示
            
            return cell
        }else{
            
            var target_name:String = ""
            let select_user_id:Int = Int(talkList[indexPath.row].user_id)!
            let select_target_user_id:Int = Int(talkList[indexPath.row].target_user_id)!
            let select_open_status:Int = Int(talkList[indexPath.row].open_status)!
            let select_photo:Int = Int(talkList[indexPath.row].photo_flg)!
            
            if(select_open_status == 3
                && select_target_user_id == self.user_id){
                //未読(山田花子さんからメッセージが届いています)
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTop") as! TalkTopViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                // セルの選択不可にする
                cell.selectionStyle = .none
                
                //他人の投稿
                //appDelegate.sendId = talkList[indexPath.row].user_id
                cell.nameLabel.text = talkList[indexPath.row].src_user_name
                target_name = talkList[indexPath.row].src_user_name
                
                //キャスト画像の表示
                let photoFlg = talkList[indexPath.row].src_photo_flg
                let photoName = talkList[indexPath.row].src_photo_name
                if(photoFlg == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + String(select_user_id) + "_profile.jpg"
                    let photoUrl = "user_images/" + String(select_user_id) + "/" + photoName + "_profile.jpg"
                    
                    //画像キャッシュを使用
                    cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")

                }else{
                    let cellImage = UIImage(named:"no_image")
                    // UIImageをUIImageViewのimageとして設定
                    cell.talkImageView.image = cellImage
                }
                
                cell.messageLbl.text = target_name + "さんからメッセージが届いています"
                
                let posTimeText:String = formatter.date(from: talkList[indexPath.row].mod_time)!.timeAgoSinceDate(numericDates: true)
                cell.dateLbl.text = posTimeText//--分前の表示
                
                return cell
            }else{
                if(select_photo == 1){
                    //写真の場合
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTopPhoto") as! TalkTopPhotoCell
                    cell.clipsToBounds = true //bound外のものを表示しない
                    // セルの選択不可にする
                    cell.selectionStyle = .none
                    
                    if(self.user_id == select_user_id && select_target_user_id > 0){
                        //自分の投稿
                        //appDelegate.sendId = talkList[indexPath.row].target_user_id
                        cell.nameLabel.text = talkList[indexPath.row].tar_user_name
                        target_name = talkList[indexPath.row].tar_user_name
                        
                        //キャスト画像の表示
                        let photoFlg = talkList[indexPath.row].tar_photo_flg
                        let photoName = talkList[indexPath.row].tar_photo_name
                        if(photoFlg == "1"){
                            //写真設定済み
                            //let photoUrl = "user_images/" + String(select_target_user_id) + "_profile.jpg"
                            let photoUrl = "user_images/" + String(select_target_user_id) + "/" + photoName + "_profile.jpg"

                            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                            //    cell.talkImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                            //}
                            //画像キャッシュを使用
                            cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                            
                        }else{
                            let cellImage = UIImage(named:"no_image")
                            // UIImageをUIImageViewのimageとして設定
                            cell.talkImageView.image = cellImage
                        }
                        
                    }else if(self.user_id == select_target_user_id && select_user_id > 0){
                        //他人の投稿
                        //appDelegate.sendId = talkList[indexPath.row].user_id
                        cell.nameLabel.text = talkList[indexPath.row].src_user_name
                        target_name = talkList[indexPath.row].src_user_name
                        
                        //キャスト画像の表示
                        let photoFlg = talkList[indexPath.row].src_photo_flg
                        let photoName = talkList[indexPath.row].src_photo_name
                        if(photoFlg == "1"){
                            //写真設定済み
                            //let photoUrl = "user_images/" + String(select_user_id) + "_profile.jpg"
                            let photoUrl = "user_images/" + String(select_user_id) + "/" + photoName + "_profile.jpg"
                            
                            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                            //    cell.talkImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                            //}
                            //画像キャッシュを使用
                            cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                            
                        }else{
                            let cellImage = UIImage(named:"no_image")
                            // UIImageをUIImageViewのimageとして設定
                            cell.talkImageView.image = cellImage
                        }
                    }
                    
                    let photoUrl: String = "talk/"
                        + talkList[indexPath.row].user_id
                        + "/"
                        + talkList[indexPath.row].target_user_id
                        + "/"
                        + talkList[indexPath.row].rireki_id
                        + "_list.jpg"
                    
                    //print(photoUrl)
                    
                    //画像の表示
                    //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                    //    cell.photoView.image = image?.resizeUIImageRatio(ratio: 50.0)
                    //}
                    //画像キャッシュを使用
                    cell.photoView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
                    
                    // 角丸
                    cell.photoView.layer.cornerRadius = 10
                    // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                    cell.photoView.layer.masksToBounds = true
                    
                    
                    
                    let posTimeText:String = formatter.date(from: talkList[indexPath.row].mod_time)!.timeAgoSinceDate(numericDates: true)
                    cell.dateLbl.text = posTimeText//--分前の表示
                    
                    return cell
                    
                }else{
                    //テキストの場合
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TalkTop") as! TalkTopViewCell
                    cell.clipsToBounds = true //bound外のものを表示しない
                    // セルの選択不可にする
                    cell.selectionStyle = .none
                    
                    if(self.user_id == select_user_id && select_target_user_id > 0){
                        //自分の投稿
                        //appDelegate.sendId = talkList[indexPath.row].target_user_id
                        cell.nameLabel.text = talkList[indexPath.row].tar_user_name
                        target_name = talkList[indexPath.row].tar_user_name
                        
                        //キャスト画像の表示
                        let photoFlg = talkList[indexPath.row].tar_photo_flg
                        let photoName = talkList[indexPath.row].tar_photo_name
                        if(photoFlg == "1"){
                            //写真設定済み
                            //let photoUrl = "user_images/" + String(select_target_user_id) + "_profile.jpg"
                            let photoUrl = "user_images/" + String(select_target_user_id) + "/" + photoName + "_profile.jpg"
                            
                            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                            //    cell.talkImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                            //}
                            //画像キャッシュを使用
                            cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                            
                        }else{
                            let cellImage = UIImage(named:"no_image")
                            // UIImageをUIImageViewのimageとして設定
                            cell.talkImageView.image = cellImage
                        }
                        
                    }else if(self.user_id == select_target_user_id && select_user_id > 0){
                        //他人の投稿
                        //appDelegate.sendId = talkList[indexPath.row].user_id
                        cell.nameLabel.text = talkList[indexPath.row].src_user_name
                        target_name = talkList[indexPath.row].src_user_name
                        
                        //キャスト画像の表示
                        let photoFlg = talkList[indexPath.row].src_photo_flg
                        let photoName = talkList[indexPath.row].src_photo_name
                        if(photoFlg == "1"){
                            //写真設定済み
                            //let photoUrl = "user_images/" + String(select_user_id) + "_profile.jpg"
                            let photoUrl = "user_images/" + String(select_user_id) + "/" + photoName + "_profile.jpg"
                            
                            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                            //    cell.talkImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                            //}
                            //画像キャッシュを使用
                            cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                            
                        }else{
                            let cellImage = UIImage(named:"no_image")
                            // UIImageをUIImageViewのimageとして設定
                            cell.talkImageView.image = cellImage
                        }
                    }
                    
                    //既読
                    if(talkList[indexPath.row].value01.count >= 38){
                        //文字数が多い場合
                        let str = talkList[indexPath.row].value01
                        let array = str.splitInto(38)
                        cell.messageLbl.text = array[0] + "……"
                    }else{
                        cell.messageLbl.text = talkList[indexPath.row].value01
                    }

                    let posTimeText:String = formatter.date(from: talkList[indexPath.row].mod_time)!.timeAgoSinceDate(numericDates: true)
                    cell.dateLbl.text = posTimeText//--分前の表示
                    
                    return cell
                    
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        switch indexPath.row {
        case 0:
            return indexPath
        // 選択不可にしたい場合は"nil"を返す
        case 1:
            return nil
            
        default:
            return indexPath
        }
    }
    */
