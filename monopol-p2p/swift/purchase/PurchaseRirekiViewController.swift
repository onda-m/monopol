//
//  PurchaseRirekiViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/10.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PurchaseRirekiViewController: UIViewController,UITableViewDataSource,IndicatorInfoProvider {

    /*
     //コイン購入履歴の取得
     //GET user_id,limit,order,status
     static let URL_GET_PURCHASE_RIREKI_BY_USERID
     */
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "購入・取得履歴"
    
    @IBOutlet weak var rirekiTable: UITableView!
    
    //購入履歴
    struct RirekiResult: Codable {
        let rireki_id: String
        let product_id: String
        let apple_id: String
        let price: String
        let point: String
        let value01: String
        let ins_time: String
        let mod_time: String
    }
    struct ResultRirekiJson: Codable {
        let count: Int
        let result: [RirekiResult]
    }

    var rirekiList: [(rireki_id:String, product_id:String, apple_id:String, price:String, point:String, value01:String, ins_time:String, mod_time:String)] = []
    var rirekiListTemp: [(rireki_id:String, product_id:String, apple_id:String, price:String, point:String, value01:String, ins_time:String, mod_time:String)] = []
    
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
        
        self.rirekiTable.register(UINib(nibName: "PurchaseRirekiViewCell", bundle: nil), forCellReuseIdentifier: "PurchaseRirekiViewCell")
        
        //self.getPurchaseRirekiList()
    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getPurchaseRirekiList()
        //print(sendId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPurchaseRirekiList(){
        //クリアする
        self.rirekiListTemp.removeAll()
        
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //order=3:最新のものから取得
        var stringUrl = Util.URL_GET_PURCHASE_RIREKI_BY_USERID
        stringUrl.append("?status=1&order=3&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&limit=")
        stringUrl.append(String(Util.PURCHASE_RIREKI_LIMIT))
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
                    let json = try decoder.decode(ResultRirekiJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        //let strRirekiId = obj.rireki_id
                        //let strProductId = obj.product_id
                        //let strAppleId = obj.apple_id
                        //let strPrice = obj.price
                        //let strPoint = obj.point
                        //let strValue01 = obj.value01 //コメント
                        //let strInsTime = obj.ins_time
                        //let strModTime = obj.mod_time
                        
                        let rireki = (obj.rireki_id,
                                      obj.product_id,
                                      obj.apple_id,
                                      obj.price,
                                      obj.point,
                                      obj.value01,
                                      obj.ins_time,
                                      obj.mod_time)
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
                    //print(err.debugDescription)
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
        /*
        if(self.rirekiList.count > 0){
            return self.rirekiList.count
        }else{
            return 0
        }
         */
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseRirekiViewCell", for: indexPath) as! PurchaseRirekiViewCell
        
        cell.dateLbl.text = self.rirekiList[indexPath.row].ins_time
        cell.purchaseNameLbl.text = UtilFunc.numFormatter(num: Int(Double(self.rirekiList[indexPath.row].point)!)) + "コイン"
        
        /*
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
        */
        
        /*
         cell.presentCoinLabel.text = Util.numFormatter(num: Int(presentList[indexPath.row].coin)!) + " コイン"
         cell.presentNumLabel.text = Util.numFormatter(num: Int(presentList[indexPath.row].present_count)!) + "個"
         
         // 枠線の色
         //cell.productMainView.layer.borderColor = UIColor.lightGray.cgColor
         // 枠線の太さ
         //cell.productMainView.layer.borderWidth = 1
         */
        
        /*
        cell.listenerImageBtn.tag = indexPath.row
        //購入するボタンを押した時の処理
        cell.listenerImageBtn.addTarget(self, action: #selector(onClickListenerInfo(sender: )), for: .touchUpInside)
         */
        
        return cell
    }
    
    /*
    @objc func onClickListenerInfo(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        let buttonRow = sender.tag
        
        //リスナーのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = self.rirekiList[buttonRow].listener_user_id
        UtilToViewController.toUserInfoViewController()
    }
    */
}
