//
//  WatchRirekiViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/10/29.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class WatchRirekiViewController: BaseViewController, UITableViewDataSource {

    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /*
     //視聴履歴の取得
     //GET: user_id, limit, order
     static let URL_GET_WATCH_RIREKI_BY_USERID = URL_BASE + "getWatchRirekiByUserId.php"
     
     */

    @IBOutlet weak var rirekiTable: UITableView!
    
    //視聴履歴の一覧用
    struct RirekiResult: Codable {
        let point: String//使用したコイン
        let type: String
        let target_user_id: String//キャストID
        let year: String
        let month: String
        let day: String
        let value01: String//コメント
        let ins_time: String//
        let mod_time: String//
        let cast_name: String//
        let cast_photo_flg: String//
        let cast_photo_name: String//
    }
    struct ResultRirekiJson: Codable {
        let count: Int
        let result: [RirekiResult]
    }
    var rirekiList: [(point: String, type: String, target_user_id:String, year:String, month:String, day:String, value01:String, ins_time:String, mod_time:String, cast_name:String, cast_photo_flg:String, cast_photo_name:String)] = []
    var rirekiListTemp: [(point: String, type: String, target_user_id:String, year:String, month:String, day:String, value01:String, ins_time:String, mod_time:String, cast_name:String, cast_photo_flg:String, cast_photo_name:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //テーブルの区切り線を非表示
        self.rirekiTable.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.rirekiTable.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.rirekiTable.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.rirekiTable.allowsSelection = false // 選択を不可にする
        self.rirekiTable.isScrollEnabled = true
        self.rirekiTable.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        // Do any additional setup after loading the view.
        
        self.rirekiTable.register(UINib(nibName: "WatchRirekiViewCell", bundle: nil), forCellReuseIdentifier: "WatchRirekiViewCell")
        
        self.getWatchRirekiList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print(sendId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWatchRirekiList(){
        //クリアする
        self.rirekiListTemp.removeAll()
        
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //order=3:最新のものから取得
        var stringUrl = Util.URL_GET_WATCH_RIREKI_BY_USERID
        stringUrl.append("?order=3&user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&limit=")
        stringUrl.append(String(Util.WATCH_RIREKI_LIMIT))
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
                    let json = try decoder.decode(ResultRirekiJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strPoint = obj.point
                        let strType = obj.type
                        let strTargetUserId = obj.target_user_id
                        let strYear = obj.year
                        let strMonth = obj.month
                        let strDay = obj.day
                        let strValue01 = obj.value01 //コメント
                        let strInsTime = obj.ins_time //
                        let strModTime = obj.mod_time
                        let strCastName = obj.cast_name
                        let strCastPhotoFlg = obj.cast_photo_flg
                        let strCastPhotoName = obj.cast_photo_name
                        
                        let rireki = (strPoint, strType,strTargetUserId,strYear,strMonth,strDay,strValue01,strInsTime,strModTime,strCastName,strCastPhotoFlg,strCastPhotoName)
                        
                        //配列へ追加
                        self.rirekiList.append(rireki)
                        self.rirekiListTemp.append(rireki)
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
            self.rirekiList = self.rirekiListTemp
            
            //リストの取得を待ってから更新
            self.rirekiTable.reloadData()
        }
    }

    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(appDelegate.productList.count)
        //リストの総数
        return self.rirekiList.count
    }
    
    /*
     セルの高さを設定
     */
    /*
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     tableView.estimatedRowHeight = 36 //セルの高さ
     //return UITableViewAutomaticDimension //自動設定
     return tableView.estimatedRowHeight
     }
     */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchRirekiViewCell", for: indexPath) as! WatchRirekiViewCell
        
        let insTime = self.rirekiList[indexPath.row].ins_time
        //cell.dateLbl.text = self.rirekiList[indexPath.row].ins_time
        // 先頭より西暦以降を取得
        let startIndex = insTime.index(insTime.startIndex, offsetBy: 5) //開始位置 5
        let endIndex = insTime.index(startIndex, offsetBy: 14) // 長さ 14
        let insTimeMoji = insTime[startIndex..<endIndex]
        cell.dateLbl.text = String(insTimeMoji)

        cell.castNameLbl.text = self.rirekiList[indexPath.row].cast_name
        
        //視聴時間
        if(self.rirekiList[indexPath.row].value01 == "0"
            || self.rirekiList[indexPath.row].value01 == "'0'"){
            cell.liveTimeLbl.text = "—"
        }else{
            cell.liveTimeLbl.text = self.rirekiList[indexPath.row].value01
        }
        
        //画像の表示
        let photoFlg = self.rirekiList[indexPath.row].cast_photo_flg
        let castPhotoName = self.rirekiList[indexPath.row].cast_photo_name
        let castUserId = self.rirekiList[indexPath.row].target_user_id
        if(photoFlg == "1"){
            //写真設定済み
            let photoUrl = "user_images/" + castUserId + "/" + castPhotoName + "_profile.jpg"
            
            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
            //    imageView.image = image?.resizeUIImageRatio(ratio: 50.0)
            //}
            //画像キャッシュを使用
            cell.castImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            cell.castImageView.image = cellImage
        }
        
        /*
         cell.presentCoinLabel.text = Util.numFormatter(num: Int(presentList[indexPath.row].coin)!) + " コイン"
         cell.presentNumLabel.text = Util.numFormatter(num: Int(presentList[indexPath.row].present_count)!) + "個"
         
         // 枠線の色
         //cell.productMainView.layer.borderColor = UIColor.lightGray.cgColor
         // 枠線の太さ
         //cell.productMainView.layer.borderWidth = 1
         */
        
        cell.castImageBtn.tag = indexPath.row
        //購入するボタンを押した時の処理
        cell.castImageBtn.addTarget(self, action: #selector(onClickCastInfo(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    @objc func onClickCastInfo(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        let buttonRow = sender.tag
        
        //リスナーのuser_idを次の画面（キャスト詳細画面）へ渡す
        self.appDelegate.sendId = self.rirekiList[buttonRow].target_user_id
        UtilToViewController.toUserInfoViewController()
    }
    
}
