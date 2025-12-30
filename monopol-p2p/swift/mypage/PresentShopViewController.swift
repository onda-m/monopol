//
//  PresentShopViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/09/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class PresentShopViewController: BaseViewController,UITableViewDataSource {

    let iconSize: CGFloat = 22.0
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var presentTableView: UITableView!
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var coinNotesLabel: AutoShrinkLabel!//必要コインのところ
    @IBOutlet weak var numNotesLabel: AutoShrinkLabel!//所持数のところ

    //コインが足りない場合に表示するダイアログ
    let noCoinDialog:NoCoinDialog = UINib(nibName: "NoCoinDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! NoCoinDialog
    
    //プレゼントの一覧用
    struct PresentResult: Codable {
        let present_id: String
        let present_name: String
        let coin: String
        let photo_flg: String
        let present_count: String
    }
    struct ResultPresentJson: Codable {
        let count: Int
        let result: [PresentResult]
    }
    var presentList: [(present_id:String, present_name:String, coin:String, photo_flg:String, present_count:String)] = []
    var presentListTemp: [(present_id:String, present_name:String, coin:String, photo_flg:String, present_count:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //noCoinDialog
        self.noCoinDialog.isHidden = true//非表示にしておく
        //画面サイズに合わせる
        self.noCoinDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.noCoinDialog)

        //テーブルの区切り線を非表示
        //self.productTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.presentTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.presentTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.presentTableView.allowsSelection = false // 選択を不可にする
        self.presentTableView.isScrollEnabled = true
        self.presentTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        self.presentTableView.register(UINib(nibName: "PresentShopViewCell", bundle: nil), forCellReuseIdentifier: "presentShopCell")
        
        //ラベルの枠を自動調節する
        coinNotesLabel.adjustsFontSizeToFitWidth = true
        coinNotesLabel.minimumScaleFactor = 0.8
        // 角丸
        coinNotesLabel.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        coinNotesLabel.layer.masksToBounds = true
        coinNotesLabel.backgroundColor = Util.SHOP_COIN_BG_COLOR
        
        //ラベルの枠を自動調節する
        numNotesLabel.adjustsFontSizeToFitWidth = true
        numNotesLabel.minimumScaleFactor = 0.8
        // 角丸
        numNotesLabel.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        numNotesLabel.layer.masksToBounds = true
        numNotesLabel.backgroundColor = Util.SHOP_HAVE_BG_COLOR
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //ポイントをセットする
        //□ --
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        //pointLabel.text = "残りポイント：" + myPoint.description + "ポイント"
        //pointLabel.text = Util.numFormatter(num: myPoint)
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.pointLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-6 ,string: UtilFunc.numFormatter(num: Int(myPoint)), iconImage: UIImage(named:"coin_ico")!, iconSize: self.iconSize)
        
        //pointLabel.sizeToFit()
        
        self.getPresentList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPresentList(){
        //クリアする
        self.presentListTemp.removeAll()
        //リスト取得
        var stringUrl = Util.URL_GET_PRESENT_LIST_BY_USERID
        //stringUrl.append("?order=1&status=1&user_id=")
        stringUrl.append("?order=2&status=99&user_id=")
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
                    let json = try decoder.decode(ResultPresentJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strId = obj.present_id
                        let strPresentName = obj.present_name
                        let strCoin = obj.coin
                        let strPhotoFlg = obj.photo_flg
                        let strPresentCount = obj.present_count
                        
                        //配列へ追加
                        let present = (strId,strPresentName,strCoin,strPhotoFlg,strPresentCount)
                        self.presentList.append(present)
                        self.presentListTemp.append(present)
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
            self.presentList = self.presentListTemp
            
            //リストの取得を待ってから更新
            self.presentTableView.reloadData()
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
        //プレゼントリストの総数
        return self.presentList.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "presentShopCell", for: indexPath) as! PresentShopViewCell
        
        cell.presentNameLabel.text = self.presentList[indexPath.row].present_name
        //ラベルの枠を自動調節する
        cell.presentNameLabel?.adjustsFontSizeToFitWidth = true
        cell.presentNameLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        //プレゼント画像の表示
        let photoFlg = presentList[indexPath.row].photo_flg
        let present_id = presentList[indexPath.row].present_id
        if(photoFlg == "1"){
            //写真設定済み
            //ゼロ埋め String(format: "%03d", present_id)
            let photoUrl = "present_images/" + present_id + ".png"
            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
            //    imageView.image = image?.resizeUIImageRatio(ratio: 50.0)
            //}
            //画像キャッシュを使用
            //print(present_id)
            cell.presentImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"901")
        }else{
            let cellImage = UIImage(named:"901")
            // UIImageをUIImageViewのimageとして設定
            cell.presentImageView.image = cellImage
        }
        
        if(Int(presentList[indexPath.row].coin)! > 0){
            //cell.presentCoinLabel.text = Util.numFormatter(num: Int(presentList[indexPath.row].coin)!) + " コイン"
            //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
            cell.presentCoinLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-6 ,string: UtilFunc.numFormatter(num: Int(presentList[indexPath.row].coin)!) + " コイン", iconImage: UIImage(named:"coin_ico")!, iconSize: self.iconSize)
            //cell.presentCoinLabel.attributedText = Util.getInsertIconStringTitle(y_height:-6 ,string: Util.numFormatter(num: Int(presentList[indexPath.row].coin)!), iconImage: UIImage(named:"coin_ico")!, iconSize: self.iconSize)
        }else{
            //必要コインがゼロの時
            cell.presentCoinLabel.text = ""
        }
        
        cell.presentNumLabel.text = UtilFunc.numFormatter(num: Int(presentList[indexPath.row].present_count)!) + "個"
        
        // 枠線の色
        //cell.productMainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //cell.productMainView.layer.borderWidth = 1
        
        /*
        cell.productNameLabel?.text = appDelegate.productList[indexPath.row].value01
        //ラベルの枠を自動調節する
        cell.productNameLabel?.adjustsFontSizeToFitWidth = true
        cell.productNameLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        if(appDelegate.productList[indexPath.row].value02 != "0" && appDelegate.productList[indexPath.row].value02 != ""){
            cell.productNoteLabel?.text = appDelegate.productList[indexPath.row].value02
        }else{
            cell.productNoteLabel?.text = ""
        }
        //ラベルの枠を自動調節する
        cell.productNoteLabel?.adjustsFontSizeToFitWidth = true
        cell.productNoteLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        let price: Int = Int(appDelegate.productList[indexPath.row].price)!
        cell.purchaseButton?.setTitle("¥ " + String(Util.numFormatter(num:price)), for: .normal)
        //ラベルの枠を自動調節する
        cell.purchaseButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.purchaseButton?.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        cell.purchaseButton?.tag = indexPath.row
        */
        
        cell.presentBtn.tag = indexPath.row

        //購入するボタンを押した時の処理
        cell.presentBtn.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)

        return cell
    }

    @objc func onClick(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        
        if(Int(self.presentList[buttonRow].coin)! > 0){
            let myPointTemp:Double = UserDefaults.standard.double(forKey: "myPoint")
            
            if(Int(myPointTemp) >= Int(self.presentList[buttonRow].coin)!){
                //コインが足りている場合
                let actionAlert = UIAlertController(title: self.presentList[buttonRow].present_name + "を" + UtilFunc.numFormatter(num: Int(self.presentList[buttonRow].coin)!) + "コインで購入しますか?", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                //UIAlertControllerにアクションを追加する
                let modifyAction = UIAlertAction(title: "購入する", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in
                    
                    //購入する
                    self.presentGet(present_id:Int(self.presentList[buttonRow].present_id)!, coin:Double(self.presentList[buttonRow].coin)!)
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
            }else{
                //コインが足りない場合
                self.noCoinDialog.isHidden = false
            }
        }
    }
    
    //プレゼント購入処理
    func presentGet(present_id:Int, coin:Double){
        //コインの消費
        //GET:user_id,point,user_uid
        
        //UUIDを取得
        let user_uid = UIDevice.current.identifierForVendor!.uuidString
        
        var stringUrl = Util.URL_POINT_USE_DO
        stringUrl.append("?user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&user_uid=")
        stringUrl.append(user_uid)
        stringUrl.append("&point=")
        stringUrl.append(String(coin))
        stringUrl.append("&type=0")
        
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
                dispatchGroup.leave()//サブタスク終了時に記述
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //プレゼントの取得処理
            //GET:user_id,target_id,present_id,status
            var stringUrl = Util.URL_PRESENT_DO
            stringUrl.append("?user_id=")
            stringUrl.append(String(self.user_id))
            stringUrl.append("&target_id=0&status=1&present_id=")
            stringUrl.append(String(present_id))
            
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
                    dispatchGroup.leave()//サブタスク終了時に記述
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //コイン消費履歴を保存
                //type=6:プレゼントの購入
                UtilFunc.writePointUseRireki(type:6,
                                             point:coin,
                                             user_id:self.user_id,
                                             target_user_id:0)
                
                //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
                var myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
                myPoint = myPoint - Double(coin)
                UserDefaults.standard.set(myPoint, forKey: "myPoint")
                
                //self.pointLabel.text = Util.numFormatter(num: myPoint)
                //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
                self.pointLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-6 ,string: UtilFunc.numFormatter(num: Int(myPoint)), iconImage: UIImage(named:"coin_ico")!, iconSize: self.iconSize)
                
                self.getPresentList()
            }
        }
    }
}

//tableviewの上部の空白を削除する(swift4)
// MARK: - UITableViewDelegate
extension PresentShopViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
