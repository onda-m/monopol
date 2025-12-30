//
//  CastSearchViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/09/18.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class CastSearchViewController: BaseViewController,UITableViewDataSource, UITableViewDelegate ,UITextFieldDelegate {
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var castListTable: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var searchTextField: UITextField!

    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    //キャストの検索結果用
    struct SearchCastResult: Codable {
        let user_id: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let movie_flg: String
        let movie_name: String
        let freetext: String
        let follow_id: String
    }
    struct ResultSearchCastJson: Codable {
        let count: Int
        let result: [SearchCastResult]
    }
    var searchCastList: [(user_id:String, user_name:String, photo_flg:String, photo_name:String, movie_flg:String, movie_name:String, freetext:String, follow_id:String)] = []
    var searchCastListTemp: [(user_id:String, user_name:String, photo_flg:String, photo_name:String, movie_flg:String, movie_name:String, freetext:String, follow_id:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //テーブルの区切り線を非表示
        //self.castListTable.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.castListTable.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.castListTable.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.castListTable.allowsSelection = false // 選択を不可にする
        self.castListTable.isScrollEnabled = true
        self.castListTable.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        self.castListTable.register(UINib(nibName: "SearchCastInfoCell", bundle: nil), forCellReuseIdentifier: "SearchCastInfoCell")
        
        // テキストを全消去するボタンを表示
        self.searchTextField.clearButtonMode = .always
        // 改行ボタンの種類を変更
        self.searchTextField.returnKeyType = .done
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //はじめに現在のViewControllerをセット
        //キャスト詳細＞フォロー後に戻ってきた時にリロードするための対策
        self.appDelegate.viewCallFromViewControllerId = "CastSearchViewController"
        self.appDelegate.viewReloadFlg = 1
        
        //ポイントをセットする
        //□ --
        //let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        //pointLabel.text = "残りポイント：" + myPoint.description + "ポイント"
        //pointLabel.text = Util.numFormatter(num: myPoint)
        //pointLabel.sizeToFit()
        
        //フォーカスを合わせる
        self.searchTextField.becomeFirstResponder()
        
        //if(self.appDelegate.searchString == ""){
            //検索文字列が入っていない場合は何もしない
            //self.castListTable.reloadData()
        //}else{
            self.searchTextField.text = self.appDelegate.searchString
            getSearchCastList()
        //}
        
        //self.getSearchCastList()
    }
    
    //バックグラウンドなどではなく、違う画面に遷移したときにだけ実行される。（1度のみ実行）
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchTextField.text = self.appDelegate.searchString
        getSearchCastList()
        
        /*
        if(self.appDelegate.viewReloadFlg == 1){
            self.searchTextField.text = self.appDelegate.searchString
            getSearchCastList()
        }else{
            //全てクリア
            self.appDelegate.searchString = ""
            self.searchTextField.text = ""
            //クリアする
            self.searchCastList.removeAll()
            self.searchCastListTemp.removeAll()
            
            self.castListTable.reloadData()
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSearchCastList(){
        //クリアする
        self.searchCastListTemp.removeAll()
        
        /*
         //キャストの検索 GET:user_id,order,type,keyword,limit
         //type:1:キャストのみ
         static let URL_SEARCH_CAST = "https://p2p.monopol.jp/searchCastInfo.php"
         Util.SEARCH_CAST_LIMIT
         */
        
        // TextFieldから文字を取得
        let textFieldString = self.searchTextField.text!
        
        if(textFieldString == "0" || textFieldString == ""){
            //何もしない
            self.castListTable.isHidden = true
        }else{
            //リスト取得
            var stringUrl = Util.URL_SEARCH_CAST
            stringUrl.append("?order=1&type=1&user_id=")
            stringUrl.append(String(self.user_id))
            stringUrl.append("&keyword=")
            stringUrl.append(textFieldString)
            stringUrl.append("&limit=")
            stringUrl.append(String(Util.SEARCH_CAST_LIMIT))
            
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
                        let json = try decoder.decode(ResultSearchCastJson.self, from: data!)
                        //self.idCount = json.count
                        
                        //表示する通知・告知リストを配列にする。
                        for obj in json.result {
                            //ブラックリストの配列にない場合はnilが返される
                            if self.appDelegate.array_black_list.index(of: Int(obj.user_id)!) == nil {
                                //let strUserId = obj.user_id
                                //let strUserName = obj.user_name.toHtmlString()
                                //let strPhotoFlg = obj.photo_flg
                                //let strPhotoName = obj.photo_name
                                //let strMovieFlg = obj.movie_flg
                                //let strMovieName = obj.movie_name
                                //let strFreetext = obj.freetext.toHtmlString()
                                //let strFollowId = obj.follow_id
                                //配列へ追加
                                let castInfo = (obj.user_id
                                    ,obj.user_name.toHtmlString()
                                    ,obj.photo_flg
                                    ,obj.photo_name
                                    ,obj.movie_flg
                                    ,obj.movie_name
                                    ,obj.freetext.toHtmlString()
                                    ,obj.follow_id)
                                self.searchCastList.append(castInfo)
                                self.searchCastListTemp.append(castInfo)
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
                //コピーする
                self.searchCastList = self.searchCastListTemp
                
                if(self.searchCastList.count == 0){
                    self.castListTable.isHidden = true
                }else{
                    //リストの取得を待ってから更新
                    self.castListTable.reloadData()
                    self.castListTable.isHidden = false
                }
                
                // TextFieldの中身をクリア
                //textField.text = ""
            }
        }
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        //キャンセルボタンが押されたら、すべてクリアしてトップに戻す
        //self.dismiss(animated: false, completion: nil)
        self.appDelegate.searchString = ""
        self.searchTextField.text = ""

        self.appDelegate.viewCallFromViewControllerId = ""
        self.appDelegate.viewReloadFlg = 0
        
        UtilToViewController.toMainViewController()
    }
    
    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(appDelegate.productList.count)
        //リストの総数
        return self.searchCastList.count
    }
    
    /*
     セルの高さを設定
     */
    /*
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
     tableView.estimatedRowHeight = 67 //セルの高さ
     //return UITableViewAutomaticDimension //自動設定
     return tableView.estimatedRowHeight
     }
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCastInfoCell", for: indexPath) as! SearchCastInfoCell
        
        cell.castNameLbl.text = self.searchCastList[indexPath.row].user_name
        
        var strFreeTextTemp = ""
        if(self.searchCastList[indexPath.row].freetext != ""
            && self.searchCastList[indexPath.row].freetext != "0"
            && self.searchCastList[indexPath.row].freetext != "'0'"){
            strFreeTextTemp = self.searchCastList[indexPath.row].freetext
        }
        cell.castFreetextLbl.text = strFreeTextTemp
        
        //画像の表示
        let photoFlg = searchCastList[indexPath.row].photo_flg
        let photoName = searchCastList[indexPath.row].photo_name
        let userId = searchCastList[indexPath.row].user_id
        if(photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + userId + "_profile.jpg"
            let photoUrl = "user_images/" + userId + "/" + photoName + "_profile.jpg"
            
            //print(photoUrl)
            //画像キャッシュを使用
            cell.castImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            cell.castImageView.image = cellImage
        }
        
        let followId = searchCastList[indexPath.row].follow_id
        if(followId == "0"){
            //この人をフォローしていない場合
            cell.followBtn.setTitle("＋フォロー", for: .normal)
            //枠の大きさを自動調節する
            cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
            cell.followBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
            cell.followBtn.backgroundColor = UIColor.white
            cell.followBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
            cell.followBtn.layer.borderWidth = 0.5
        }else{
            //この人をフォローしている場合
            cell.followBtn.setTitle("フォロー中", for: .normal)
            cell.followBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
            cell.followBtn.backgroundColor = Util.FOLLOW_ON_COLOR
            //cell.followBtn.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
            cell.followBtn.layer.borderWidth = 0
        }

        // 枠線の色
        //cell.productMainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //cell.productMainView.layer.borderWidth = 1
        
        cell.castInfoBtn.tag = indexPath.row
        //キャストボタンを押した時の処理
        cell.castInfoBtn.addTarget(self, action: #selector(onClickCastInfo(sender: )), for: .touchUpInside)
        
        cell.followBtn.tag = indexPath.row
        //フォローボタンを押した時の処理
        cell.followBtn.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        
        return cell
    }

    @objc func onClickCastInfo(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        self.appDelegate.viewReloadFlg = 1
        
        //テキストフィールドの値を保持する
        self.appDelegate.searchString = self.searchTextField.text!
        print(self.appDelegate.searchString)
        //print(sender)
        let buttonRow = sender.tag
        
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.searchCastList[buttonRow].user_id
        UtilToViewController.toUserInfoViewController()
    }
    
    @objc func onClick(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる

        //print(sender)
        let buttonRow = sender.tag
        
        //UIAlertControllerを用意する
        let strCastName = self.searchCastList[buttonRow].user_name
        let targetId = Int(self.searchCastList[buttonRow].user_id)
        let followId = self.searchCastList[buttonRow].follow_id
        
        let actionAlert = UIAlertController(title: strCastName, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if(followId != "0"){
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォロー解除", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:2, target_id:targetId)
                
                //この人をフォローしていない場合
                sender.setTitle("＋フォロー", for: .normal)
                //枠の大きさを自動調節する
                sender.titleLabel?.adjustsFontSizeToFitWidth = true
                sender.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
                sender.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
                sender.backgroundColor = UIColor.white
                sender.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
                sender.layer.borderWidth = 0.5

                self.searchCastList[buttonRow].follow_id = "0"
            })
            actionAlert.addAction(modifyAction)
        }else{
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "フォローする", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                self.follow(flg:1, target_id:targetId)
                
                //この人をフォローしている場合
                sender.setTitle("フォロー中", for: .normal)
                sender.setTitleColor(UIColor.white, for: .normal) // タイトルの色
                sender.backgroundColor = Util.FOLLOW_ON_COLOR
                //sender.layer.borderColor = Util.FOLLOW_ON_COLOR.cgColor
                sender.layer.borderWidth = 0
                
                //follow_idに何か数値を入れておく
                self.searchCastList[buttonRow].follow_id = "1"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /* 以下は UITextFieldDelegate のメソッド */
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを隠す
        textField.resignFirstResponder()
        return true
    }
    
    // クリアボタンが押された時の処理
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //print("Clear")
        self.appDelegate.searchString = ""
        return true
    }
    
    // テキストフィールドがフォーカスされた時の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //print("Start")
        return true
    }
    
    // テキストフィールドでの編集が終わろうとするときの処理
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //print("End")
        self.appDelegate.searchString = textField.text!
        self.getSearchCastList()
        return true
    }

}
