//
//  PurchaseCommonViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/09/03.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseCommonViewController: UIViewController,PurchaseManagerDelegate,UITableViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ステータスが有効の商品のPRODUCT_IDの格納用
    //productIdentifiers : [String] = ["com.matome7.p2p.001","com.matome7.p2p.002"]
    //var productIdentifiers : [String]
    //Intがある場合、Nullのデータを含んだ場合、正常に動作しない　→ 原因不明
    struct ProductResult: Codable {
        let product_id: String
        let apple_id: String
        let reference_name: String
        let price: String
        let point: String
        let value01: String
        let value02: String
        let value03: String
    }
    struct ResultProductJson: Codable {
        let count: Int
        let result: [ProductResult]
    }
    //var idCount:Int=0
    //var strProductId: [String] = []
    //var strAppleId: [String] = []
    //var strReferenceName: [String] = []
    //var intPrice: [Int] = []
    //var intPoint: [Int] = []
    //var strValue01: [String] = []
    //var strValue02: [String] = []
    //商品リスト(タプル配列)
    //var productList: [(productId:String, appleId:String, referenceName:String, price:Int, point:Int, value01:String, value02:String)] = []
    var productList: [(productId:String, appleId:String, referenceName:String, price:String, point:String, value01:String, value02:String, value03:String)] = []
    var productListTemp: [(productId:String, appleId:String, referenceName:String, price:String, point:String, value01:String, value02:String, value03:String)] = []
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    //購入注意事項関連
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesTextLbl: UILabel!
    @IBOutlet weak var notesTitleLbl: UILabel!
    @IBOutlet weak var productTableView: UITableView!
    
    //購入プラン関連
    @IBOutlet weak var purchasePlanMainView: UIView!
    @IBOutlet weak var purchasePlanTitleLabel: UILabel!
    
    var selectedPathIndex = 0//選択したプラン:buttonRow(本番課金の引数渡し用)
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "productCell")

        //購入注意事項のダイアログ
        self.notesView.isHidden = true
        
        // Do any additional setup after loading the view.
        self.notesTitleLbl.text = UtilStr.COIN_PAY_TITLE_STR
        
        var mainText = UtilStr.COIN_PAY_STR_00
        mainText.append(UtilStr.COIN_PAY_STR_01)
        mainText.append(UtilStr.COIN_PAY_STR_02)
        mainText.append(UtilStr.COIN_PAY_STR_03)
        mainText.append(UtilStr.COIN_PAY_STR_04)
        mainText.append(UtilStr.COIN_PAY_STR_05)
        mainText.append(UtilStr.COIN_PAY_STR_06)
        mainText.append(UtilStr.COIN_PAY_STR_07)
        mainText.append(UtilStr.COIN_PAY_STR_08)
        mainText.append(UtilStr.COIN_PAY_STR_09)
        mainText.append(UtilStr.COIN_PAY_STR_10)
        mainText.append(UtilStr.COIN_PAY_STR_11)
        mainText.append(UtilStr.COIN_PAY_STR_12)
        mainText.append(UtilStr.COIN_PAY_STR_13)
        mainText.append(UtilStr.COIN_PAY_STR_99)
        
        notesTextLbl.text = mainText
        
        // セットした文字からUILabelの幅と高さを算出
        let rect: CGSize = notesTextLbl.sizeThatFits(CGSize(width: notesTextLbl.frame.width, height: CGFloat.greatestFiniteMagnitude))
        // 算出された幅と高さをセット
        notesTextLbl.frame = CGRect(x: notesTextLbl.frame.minX, y: 0, width: rect.width, height: rect.height)
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: notesTextLbl.frame.height + 10)
        
        //テーブルの区切り線を非表示
        self.productTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.productTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.productTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.productTableView.allowsSelection = false // 選択を不可にする
        self.productTableView.isScrollEnabled = true
        self.productTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        self.productTableView.sectionFooterHeight = 0.0
        
        // 角丸
        self.purchasePlanMainView.layer.cornerRadius = 16
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.purchasePlanMainView.layer.masksToBounds = true
        
        //所有しているコインの設定
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        self.purchasePlanTitleLabel.text = "マイコイン " + UtilFunc.numFormatter(num: Int(myPoint))
        
        self.view.bringSubviewToFront(self.purchasePlanMainView)
        
        self.getProductList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getProductList(){
        let firstFlg01Temp = UserDefaults.standard.integer(forKey: "first_flg01")
        
        //クリアする
        self.productListTemp.removeAll()
        
        //有効な商品IDを取得(ポイント順)
        let stringUrl = Util.URL_PRODUCT_LIST+"?status=1&order=0";
        
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
                    let json = try decoder.decode(ResultProductJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strProductId = obj.product_id
                        let strAppleId = obj.apple_id
                        let strReferenceName = obj.reference_name
                        let intPrice = obj.price
                        let intPoint = obj.point
                        let strValue01 = obj.value01
                        let strValue02 = obj.value02
                        let strValue03 = obj.value03
                        
                        if(strValue03 == "1" && firstFlg01Temp == 1){
                            //初回のみ購入可能をすでに購入済
                        }else{
                            //配列へ追加
                            let product = (strProductId,strAppleId,strReferenceName,intPrice,intPoint,strValue01,strValue02,strValue03)
                            self.productList.append(product)
                            self.productListTemp.append(product)
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
            self.productList = self.productListTemp
            
            //リストの取得を待ってから更新
            self.productTableView.reloadData()
        }
    }
    
    //購入プラン関連
    @IBAction func tapPurchasePlanCanselBtn(_ sender: Any) {
        //購入プランのキャンセル
        //くるくる表示終了
        self.busyIndicator.removeFromSuperview()
        
        //self.purchasePlanMainView.isHidden = true
        //self.isHidden = true
        //self.presentListMainView.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    //購入注意事項のリンク
    @IBAction func tapPurchasePlanAlertBtn(_ sender: Any) {
        //購入注意事項画面へ
        //let notes: NotesViewController = self.storyboard!.instantiateViewController(withIdentifier: "toNotesViewController") as! NotesViewController
        // 下記を追加する
        //notes.modalPresentationStyle = .fullScreen
        //present(notes, animated: true, completion: nil)
        self.notesView.isHidden = false
    }
    
    @IBAction func tapNoticeCloseBtn(_ sender: Any) {
        self.notesView.isHidden = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //------------------------------------
    // 課金処理開始
    //------------------------------------
    func startPurchase(productIdentifier : String) {
        print("課金処理開始!!")
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //プロダクト情報を取得
        ProductManager.productsWithProductIdentifiers(productIdentifiers: [productIdentifier], completion: { (products, error) -> Void in
            if (products?.count)! > 0 {
                //課金処理開始
                PurchaseManager.sharedManager().startWithProduct((products?[0])!)
            }
            if (error != nil) {
                print(error as Any)
            }
        })
    }
    
    // リストア開始
    func startRestore() {
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //リストア開始
        PurchaseManager.sharedManager().startRestore()
    }
    
    //------------------------------------
    // MARK: - PurchaseManager Delegate
    //------------------------------------
    //課金終了時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        // TODO UserDefault更新
        self.purchaseDo(pathindex: self.selectedPathIndex)
        //self.purchaseRirekiDo(pathindex: self.selectedPathIndex)
        //UUIDを取得
        let user_uid = UIDevice.current.identifierForVendor!.uuidString
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let product_id = self.productList[self.selectedPathIndex].productId
        let apple_id = self.productList[self.selectedPathIndex].appleId
        let price = self.productList[self.selectedPathIndex].price
        let point = self.productList[self.selectedPathIndex].point
        UtilFunc.purchaseRirekiDo(user_id: user_id, user_uid: user_uid, product_id: product_id, apple_id: apple_id, price: price, point: point)
        
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
        
        //画面の更新
        //Util.toPurchaseViewController()
    }
    
    //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了（指定プロダクトID以外）！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
        
        //画面の更新
        //Util.toPurchaseViewController()
    }
    
    //課金失敗時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithError error: NSError!) {
        print("課金失敗！！")
        // TODO errorを使ってアラート表示
        //くるくる表示終了
        self.busyIndicator.removeFromSuperview()
    }
    
    /*
     // リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
     func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!) {
     print("リストア終了！！")
     // TODO インジケータなどを表示していたら非表示に
     }
     // 承認待ち状態時に呼び出される(ファミリー共有)
     func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!) {
     print("承認待ち！！")
     // TODO インジケータなどを表示していたら非表示に
     }
     // プロダクト情報取得
     fileprivate func fetchProductInformationForIds(_ productIds:[String]) {
     ProductManager.productsWithProductIdentifiers(productIdentifiers: productIds,completion: {[weak self] (products : [SKProduct]?, error : NSError?) -> Void in
     if error != nil {
     if self != nil {
     }
     
     print(error?.localizedDescription as Any)
     return
     }
     
     for product in products! {
     let priceString = ProductManager.priceStringFromProduct(product: product)
     if self != nil {
     print(product.localizedTitle + ":\(priceString)")
     self?.pointLabel.text = product.localizedTitle + ":\(priceString)"
     }
     print(product.localizedTitle + ":\(priceString)" )
     }
     })
     }
     */
    
    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(appDelegate.productList.count)
        //商品リストの総数
        return self.productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        
        // 枠線の色
        cell.productMainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        cell.productMainView.layer.borderWidth = 1
        
        //下記追加20200705
        // 角丸
        cell.productMainView?.layer.cornerRadius = 16
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        cell.productMainView?.layer.masksToBounds = true
        
        //cell.messageLabel?.text = appDelegate.hymDataConnection.messages[indexPath.row].text
        //cell.senderLabel?.text = appDelegate.hymDataConnection.messages[indexPath.row].sender.rawValue
        //cell.productNameLabel?.text = appDelegate.productList[indexPath.row].appleId
        cell.productNameLabel?.text = self.productList[indexPath.row].value01
        //ラベルの枠を自動調節する
        cell.productNameLabel?.adjustsFontSizeToFitWidth = true
        cell.productNameLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        /*
        if(self.productList[indexPath.row].value02 != "0" && self.productList[indexPath.row].value02 != ""){
            cell.productNoteLabel?.text = self.productList[indexPath.row].value02
        }else{
            cell.productNoteLabel?.text = ""
        }*/
        cell.productNoteLabel?.text = ""
        
        //ラベルの枠を自動調節する
        cell.productNoteLabel?.adjustsFontSizeToFitWidth = true
        cell.productNoteLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        let price: Int = Int(self.productList[indexPath.row].price)!
        cell.purchaseButton?.setTitle("¥ " + String(UtilFunc.numFormatter(num:price)), for: .normal)
        //ラベルの枠を自動調節する
        cell.purchaseButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.purchaseButton?.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        // 角丸
        cell.purchaseButton?.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        cell.purchaseButton?.layer.masksToBounds = true
        //背景色
        cell.purchaseButton?.backgroundColor = Util.COMMON_BLUE_COLOR
        
        cell.purchaseButton?.tag = indexPath.row
        
        //購入するボタンを押した時の処理
        cell.purchaseButton?.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        return cell
    }
    
    @objc func onClick(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag
        
        if(Util.INIT_MODE == 1){
            //テスト用
            /***********************************************************/
            //  カスタムポップアップ
            /***********************************************************/
            let popupView:Popupview = UINib(nibName: "Popupview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Popupview
            // ポップアップビュー背景色
            let viewColor = UIColor.black
            // 半透明にして親ビューが見えるように。透過度はお好みで。
            popupView.backgroundColor = viewColor.withAlphaComponent(0.5)
            // ポップアップビューを画面サイズに合わせる
            popupView.frame = self.view.frame
            popupView.labelSet(name: "テスト用の確認画面のため、課金は発生しません。（リリース後は、Appleが用意したダイアログが表示され、AppleIDを入力します。）")
            
            // ダイアログ背景色（白の部分）
            let baseViewColor = UIColor.white
            // ちょっとだけ透明にする
            popupView.baseView.backgroundColor = baseViewColor.withAlphaComponent(1.0)
            // 角丸にする
            popupView.baseView.layer.cornerRadius = 8.0
            // 貼り付ける
            self.view.addSubview(popupView)
            /***********************************************************/
            /***********************************************************/
            
            self.purchaseDo(pathindex: buttonRow)
            //self.purchaseRirekiDo(pathindex: buttonRow)
            //UUIDを取得
            let user_uid = UIDevice.current.identifierForVendor!.uuidString
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            let product_id = self.productList[buttonRow].productId
            let apple_id = self.productList[buttonRow].appleId
            let price = self.productList[buttonRow].price
            let point = self.productList[buttonRow].point
            UtilFunc.purchaseRirekiDo(user_id: user_id, user_uid: user_uid, product_id: product_id, apple_id: apple_id, price: price, point: point)
            
            //DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            //    BusyIndicator.sharedManager.dismiss()//くるくる表示終了
            //}
            
            //画面の更新
            //Util.toPurchaseViewController()
            
        }else if(Util.INIT_MODE == 2){
            //本番用
            self.selectedPathIndex = buttonRow
            
            //くるくる表示開始
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.busyIndicator)
            
            //課金処理
            startPurchase(productIdentifier: self.productList[buttonRow].productId)
        }
    }
    
    //課金後の処理（初回購入のみとその他のプラン共通）
    func commonAfterDo(point:Int){
        //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
        //point更新
        //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
        var myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        var myPointPay:Double = UserDefaults.standard.double(forKey: "myPointPay")
        myPoint = myPoint + Double(point)
        myPointPay = myPointPay + Double(point)
        UserDefaults.standard.set(myPoint, forKey: "myPoint")
        UserDefaults.standard.set(myPointPay, forKey: "myPointPay")
        self.purchasePlanTitleLabel.text = "マイコイン " + UtilFunc.numFormatter(num: Int(myPoint))
        
        //くるくる表示終了
        self.busyIndicator.removeFromSuperview()
    }
    
    //() -> ()の部分は　(引数) -> (引数の型)を指定
    //func purchaseDo(pathindex:Int, _ after:@escaping () -> Void){
    func purchaseDo(pathindex:Int){
        //UUIDを取得
        //let user_uid = UIDevice.current.identifierForVendor!.uuidString
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let point = self.productList[pathindex].point
        
        //GET:user_id,point,type
        //type 1=有償、2=無料
        var stringUrl = Util.URL_PURCHASE_DO_NEW
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=1&point=")
        stringUrl.append(point)
        
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
                
                if err != nil {
                    // エラー処理
                    //クライアントエラー
                    UtilFunc.logRirekiDo(type:2, user_id:user_id, view_name:"PurchaseCommonViewController", value01:err!.localizedDescription)
                    
                    //くるくる表示終了
                    self.busyIndicator.removeFromSuperview()
                    
                    return
                }
                
                guard let data = data, let res = res as? HTTPURLResponse else {
                    //print("no data or no response")
                    UtilFunc.logRirekiDo(type:2, user_id:user_id, view_name:"PurchaseCommonViewController", value01:"no data or no response")
                    
                    //くるくる表示終了
                    self.busyIndicator.removeFromSuperview()
                    
                    return
                }

                if res.statusCode == 200 {
                    print(data)
                } else {
                    // レスポンスのステータスコードが200でない場合などはサーバサイドエラー
                    //print("サーバエラー ステータスコード: \(response.statusCode)\n")
                    UtilFunc.logRirekiDo(type:2, user_id:user_id, view_name:"PurchaseCommonViewController", value01:"サーバエラー ステータスコード: \(res.statusCode)")
                    
                    //くるくる表示終了
                    self.busyIndicator.removeFromSuperview()
                    
                    return
                }
                
                do{
                    UtilFunc.logRirekiDo(type:1, user_id:user_id, view_name:"PurchaseCommonViewController", value01:"purchaseDook")
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(self.productList[pathindex].value03 == "1"){
                //初回だけ購入可能
                //flg=1:初回購入済
                let user_id = UserDefaults.standard.integer(forKey: "user_id")
                //Util.modifyFirstFlg01(user_id:user_id, flg:1)
                
                var stringUrl = Util.URL_MODIFY_FIRST_FLG01
                stringUrl.append("?user_id=")
                stringUrl.append(String(user_id))
                stringUrl.append("&flg=1")
                print(stringUrl)
                
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
                    //リストの取得を待ってから更新
                    UserDefaults.standard.set("1", forKey: "first_flg01")
                    self.getProductList()
                    self.commonAfterDo(point:Int(point)!)
                }
            }else{
                //初回だけ購入可能以外
                self.commonAfterDo(point:Int(point)!)
            }
        }
    }
}
