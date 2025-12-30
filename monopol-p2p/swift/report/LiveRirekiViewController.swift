//
//  LiveRirekiViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/14.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class LiveRirekiViewController: UIViewController, UITableViewDataSource, IndicatorInfoProvider {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "ライブ履歴"
    
    @IBOutlet weak var rirekiTable: UITableView!
    
    //自分の配信に関して、視聴履歴の一覧用
    struct RirekiResult: Codable {
        let point_type: String
        let listener_user_id: String
        let year: String
        let month: String
        let day: String
        let point: String//配信ポイント
        let value01: String//配信分数
        let ins_time: String//
        let listener_user_name: String//
        let listener_photo_flg: String//
        let listener_photo_name: String//
    }
    struct ResultRirekiJson: Codable {
        let count: Int
        let result: [RirekiResult]
    }
    var rirekiList: [(point_type: String, listener_user_id:String, year:String, month:String, day:String, point:String, value01:String, ins_time:String, listener_user_name:String, listener_photo_flg:String, listener_photo_name:String)] = []
    var rirekiListTemp: [(point_type: String, listener_user_id:String, year:String, month:String, day:String, point:String, value01:String, ins_time:String, listener_user_name:String, listener_photo_flg:String, listener_photo_name:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        self.rirekiTable.register(UINib(nibName: "LiveRirekiViewCell", bundle: nil), forCellReuseIdentifier: "LiveRirekiViewCell")
        
        self.getLiveRirekiList()
    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print(sendId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLiveRirekiList(){
        //クリアする
        self.rirekiListTemp.removeAll()
        
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //type=1:配信履歴のみ取得
        //type=99:配信+延長の履歴を取得
        //order=3:最新のものから取得
        var stringUrl = Util.URL_GET_LIVE_POINT_RIREKI
        stringUrl.append("?status=1&order=3&type=1&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&limit=")
        stringUrl.append(String(Util.LIVE_RIREKI_LIMIT))
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
                        let strPointType = obj.point_type
                        let strListenerUserId = obj.listener_user_id
                        let strYear = obj.year
                        let strMonth = obj.month
                        let strDay = obj.day
                        let strPoint = obj.point
                        let strValue01 = obj.value01 //配信分数
                        let strInsTime = obj.ins_time //
                        let strListenerUserName = obj.listener_user_name.toHtmlString()
                        let strListenerPhotoFlg = obj.listener_photo_flg
                        let strListenerPhotoName = obj.listener_photo_name
                        
                        let rireki = (strPointType,strListenerUserId,strYear,strMonth,strDay,strPoint,strValue01,strInsTime,strListenerUserName,strListenerPhotoFlg,strListenerPhotoName)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveRirekiViewCell", for: indexPath) as! LiveRirekiViewCell
        
        cell.dateLbl.text = self.rirekiList[indexPath.row].ins_time
        cell.listenerNameLbl.text = self.rirekiList[indexPath.row].listener_user_name
        
        //画像の表示
        let photoFlg = self.rirekiList[indexPath.row].listener_photo_flg
        let listenerPhotoName = self.rirekiList[indexPath.row].listener_photo_name
        let listenerUserId = self.rirekiList[indexPath.row].listener_user_id
        if(photoFlg == "1"){
            //写真設定済み
            let photoUrl = "user_images/" + listenerUserId + "/" + listenerPhotoName + "_profile.jpg"
            
            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
            //    imageView.image = image?.resizeUIImageRatio(ratio: 50.0)
            //}
            //画像キャッシュを使用
            cell.listenerImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            cell.listenerImageView.image = cellImage
        }
        
        /*
        cell.presentCoinLabel.text = Util.numFormatter(num: Int(presentList[indexPath.row].coin)!) + " コイン"
        cell.presentNumLabel.text = Util.numFormatter(num: Int(presentList[indexPath.row].present_count)!) + "個"
        
        // 枠線の色
        //cell.productMainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //cell.productMainView.layer.borderWidth = 1
        */

        cell.listenerImageBtn.tag = indexPath.row
        //ボタンを押した時の処理
        cell.listenerImageBtn.addTarget(self, action: #selector(onClickListenerInfo(sender: )), for: .touchUpInside)
        
        return cell
    }

    @objc func onClickListenerInfo(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        let buttonRow = sender.tag
        
        //リスナーのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rirekiList[buttonRow].listener_user_id
        UtilToViewController.toUserInfoViewController()
    }
    
}
