//
//  PayReportViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/14.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

//リジェクトされたので、いったん未使用
class PayReportViewController: BaseViewController,UITableViewDataSource {

    @IBOutlet weak var paymentRirekiTable: UITableView!
    
    //支払い履歴の一覧用
    struct PaymentResult: Codable {
        let rireki_id: String
        let user_id: String
        let pay_money: String
        let year: String
        let month: String
        let day: String
    }
    struct ResultPaymentJson: Codable {
        let count: Int
        let result: [PaymentResult]
    }
    var paymentList: [(rireki_id:String, user_id:String, pay_money:String, year:String, month:String, day:String)] = []
    var paymentListTemp: [(rireki_id:String, user_id:String, pay_money:String, year:String, month:String, day:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //テーブルの区切り線を非表示
        self.paymentRirekiTable.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        
        self.paymentRirekiTable.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.paymentRirekiTable.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        self.paymentRirekiTable.allowsSelection = false // 選択を不可にする
        self.paymentRirekiTable.isScrollEnabled = true
        self.paymentRirekiTable.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        self.paymentRirekiTable.register(UINib(nibName: "PaymentRirekiCell", bundle: nil), forCellReuseIdentifier: "PaymentRirekiCell")
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getPaymentRireki()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func getPaymentRireki(){
        //クリアする
        self.paymentListTemp.removeAll()
        //支払い履歴の取得
        //GET user_id,limit,order,status
        var stringUrl = Util.URL_GET_PAYMENT_RIREKI_BY_USERID
        stringUrl.append("?status=1&order=1&user_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&limit=")
        stringUrl.append(String(Util.PAYMENT_RIREKI_MAX))
        
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
                    let json = try decoder.decode(ResultPaymentJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strRirekiId = obj.rireki_id
                        let strUserId = obj.user_id
                        let strPayMoney = obj.pay_money
                        let strYear = obj.year
                        let strMonth = obj.month
                        let strDay = obj.day
                        
                        //配列へ追加
                        let payment = (strRirekiId,strUserId,strPayMoney,strYear,strMonth,strDay)
                        self.paymentList.append(payment)
                        self.paymentListTemp.append(payment)
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
            self.paymentList = self.paymentListTemp
            
            if(self.paymentList.count == 0){
                self.paymentRirekiTable.isHidden = true
            }else{
                //リストの取得を待ってから更新
                self.paymentRirekiTable.isHidden = false
                self.paymentRirekiTable.reloadData()
            }
        }
    }
    
    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(appDelegate.productList.count)
        //履歴の総数
        return self.paymentList.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentRirekiCell", for: indexPath) as! PaymentRirekiCell

        //String(format: "%02d", count)
        cell.dateLbl.text = self.paymentList[indexPath.row].year + "/" + self.paymentList[indexPath.row].month + "/" + self.paymentList[indexPath.row].day
        cell.yenLbl.text = "¥" + UtilFunc.numFormatter(num:Int(self.paymentList[indexPath.row].pay_money)!)
        
        // 枠線の色
        //cell.productMainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //cell.productMainView.layer.borderWidth = 1
        
        /*
        cell.presentBtn.tag = indexPath.row
        //購入するボタンを押した時の処理
        cell.presentBtn.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        */
        
        return cell
    }

}
