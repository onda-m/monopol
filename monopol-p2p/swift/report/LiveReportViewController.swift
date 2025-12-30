//
//  LiveReportViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/14.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

//1000スター＝130コイン（固定）
class LiveReportViewController: UIViewController, IndicatorInfoProvider {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let request_star = 1000
    let change_coin = 130
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "配信レポート"
    
    //履歴の一覧用
    struct RirekiResult: Codable {
        let point_type: String
        let year: String
        let month: String
        let day: String
        let point: String//配信経験値
        let star: String//ゲットしたスター
        let value01: String//配信秒数 or 没収秒数
        let value02: String//没収したスター
        let value03: String//イベントによる補填スター
        let value04: String//オーガナイザー料
        let value05: String//補正スター
    }
    struct ResultRirekiJson: Codable {
        let count: Int
        let result: [RirekiResult]
    }
    var rirekiList: [(point_type: String, year:String, month:String, day:String,
        point:String, star:String, value01:String, value02:String, value03:String, value04:String, value05:String)] = []
    
    //振込可能スターのところ
    @IBOutlet weak var paymentTitleLbl: UILabel!
    
    @IBOutlet weak var dateTodayLbl: UILabel!
    @IBOutlet weak var dateThisMonthLbl: UILabel!
    @IBOutlet weak var dateMonthLbl: UILabel!
    
    //支払いレポートボタン
    @IBOutlet weak var payreportBtn: UIButton!
    //スターを換金するボタン
    @IBOutlet weak var toYenBtn: UIButton!
    //スターをコインに変換するボタン
    @IBOutlet weak var toCoinBtn: UIButton!
    
    
    @IBOutlet weak var allLiveMinutesLbl: UILabel!
    @IBOutlet weak var allGetPointLbl: UILabel!
    
    //換金に関するところなのでいったんHiddenに
    @IBOutlet weak var allPayLbl: UILabel!
    
    @IBOutlet weak var todayLbl: UILabel!

    //今日のライブ配信時間
    @IBOutlet weak var todayLiveMinutesLbl: UILabel!
    //今日受け取ったプレゼント
    @IBOutlet weak var todayGetPointLbl: UILabel!
    //今日の合計獲得スター
    @IBOutlet weak var todayTotalPointLbl: UILabel!
    
    //今月のライブ配信時間
    @IBOutlet weak var monthLiveMinutesLbl: UILabel!
    //今月受け取ったプレゼント
    @IBOutlet weak var monthGetPointLbl: UILabel!
    //今月の合計獲得スター
    @IBOutlet weak var monthTotalPointLbl: UILabel!
    
    //先月のライブ配信時間
    @IBOutlet weak var lastMonthLiveMinutesLbl: UILabel!
    //先月受け取ったプレゼント
    @IBOutlet weak var lastMonthGetPointLbl: UILabel!
    //先月の合計獲得スター
    @IBOutlet weak var lastMonthTotalPointLbl: UILabel!

    @IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 枠線の色
        dateTodayLbl.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        dateTodayLbl.layer.borderWidth = 1
        // 角丸
        dateTodayLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        dateTodayLbl.layer.masksToBounds = true
        
        // 枠線の色
        dateThisMonthLbl.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        dateThisMonthLbl.layer.borderWidth = 1
        // 角丸
        dateThisMonthLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        dateThisMonthLbl.layer.masksToBounds = true
        
        // 枠線の色
        dateMonthLbl.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        dateMonthLbl.layer.borderWidth = 1
        // 角丸
        dateMonthLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        dateMonthLbl.layer.masksToBounds = true
        
        
        //ボタン関連
        // 角丸
        payreportBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        payreportBtn.layer.masksToBounds = true
        
        // 角丸
        toYenBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        toYenBtn.layer.masksToBounds = true
        
        // 角丸
        toCoinBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        toCoinBtn.layer.masksToBounds = true
        
        /*
        let pay_point_temp: Int = UserDefaults.standard.integer(forKey: "live_now_star")
        if(pay_point_temp < request_star){
            //ボタンを無効化
            toCoinBtn.isEnabled = false
        }else{
            //ボタンを有効化
            toCoinBtn.isEnabled = true
        }*/
        
        // Do any additional setup after loading the view.
        todayLbl.text = UtilFunc.getToday(format:"yyyy/MM/dd")
        
        
        //スクロールビューの設定
        mainScrollView.contentSize = CGSize(width: self.view.frame.width, height: 540)
        
        
        getLiveRirekiListByUser()
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
    
    func getLiveRirekiListByUser(){
        //クリアする
        self.rirekiList.removeAll()
        //リスト取得(自分以外の待機中のリストを取得)
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        var stringUrl = Util.URL_GET_LIVE_POINT_RIREKI
        stringUrl.append("?status=1&order=2&user_id=")
        stringUrl.append(String(user_id))
        
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
                        let strPointType = obj.point_type
                        let strYear = obj.year
                        let strMonth = obj.month
                        let strDay = obj.day
                        let strPoint = obj.point
                        let strStar = obj.star
                        let strValue01 = obj.value01 //配信秒数
                        let strValue02 = obj.value02 //没収したスター数
                        let strValue03 = obj.value03 //イベントによる補填スター
                        let strValue04 = obj.value04 //オーガナイザー料
                        let strValue05 = obj.value05 //補正スター
                        let rireki = (strPointType,strYear,strMonth,strDay,strPoint,strStar,strValue01,strValue02,strValue03,strValue04,strValue05)
                        //配列へ追加
                        self.rirekiList.append(rireki)
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
            //累計スター数
            var all_live_star: Int = 0
            
            //本日の年月日
            let year_today = UtilFunc.getToday(format:"yyyy")
            let month_today = UtilFunc.getToday(format:"M")
            let day_today = UtilFunc.getToday(format:"d")
            // 先月の月
            let calendar = Calendar.current
            let date = Date()
            let last_month = calendar.date(byAdding: .month, value: -1, to: calendar.startOfDay(for: date))
            
            let dateFormater = DateFormatter()
            dateFormater.locale = Locale(identifier: "en_US_POSIX")//重要
            //dateFormater.locale = Locale(identifier: "ja_JP")
            dateFormater.dateFormat = "M"
            let last_month_temp = dateFormater.string(from: last_month!)
            dateFormater.dateFormat = "yyyy"
            let last_month_year_temp = dateFormater.string(from: last_month!)
            //print(last_month_year_temp)     //先月の年
            //print(last_month_temp)     //先月
            
            var today_live_sec: Int = 0
            var today_live_point: Int = 0
            var today_live_star: Int = 0
            var today_get_point: Int = 0//プレゼント
            var today_get_star: Int = 0//プレゼント
            //var today_total_point: Int = 0
            var today_total_star: Int = 0
            
            var today_month_live_sec: Int = 0
            var today_month_live_point: Int = 0
            var today_month_live_star: Int = 0
            var today_month_get_point: Int = 0//プレゼント
            var today_month_get_star: Int = 0//プレゼント
            //var today_month_total_point: Int = 0
            var today_month_total_star: Int = 0
            
            var last_month_live_sec: Int = 0
            var last_month_live_point: Int = 0
            var last_month_live_star: Int = 0
            var last_month_get_point: Int = 0//プレゼント
            var last_month_get_star: Int = 0//プレゼント
            //var last_month_total_point: Int = 0
            var last_month_total_star: Int = 0
            
            // 取得した履歴分ループしViewに配置
            for i in 0 ..< self.rirekiList.count {
                
                if(year_today == self.rirekiList[i].year
                    && month_today == self.rirekiList[i].month
                    && day_today == self.rirekiList[i].day){
                    //本日分
                    if(self.rirekiList[i].point_type == "1"
                        || self.rirekiList[i].point_type == "3"
                        || self.rirekiList[i].point_type == "4"
                        || self.rirekiList[i].point_type == "5"){
                        //ライブ配信 or 延長配信 or 予約キャンセル or スクショで取得したスター
                        today_live_sec = today_live_sec + Int(self.rirekiList[i].value01)!
                        today_live_point = today_live_point + Int(self.rirekiList[i].point)!
                        today_live_star = today_live_star + Int(self.rirekiList[i].star)!
                    }else if(self.rirekiList[i].point_type == "2"){
                        //プレゼントをゲット
                        today_get_point = today_get_point + Int(self.rirekiList[i].point)!
                        today_get_star = today_get_star + Int(self.rirekiList[i].star)!
                    }else if(self.rirekiList[i].point_type == "99"){
                        //配信で得たスターの没収（キャストからの配信中止による）
                        today_live_star = today_live_star - Int(self.rirekiList[i].value02)!
                    }
                }
                
                //point_type=6:イベント補填によるスター数 7:オーガナイザー料 8:補正スター
                //上記を考慮20220205
                if(year_today == self.rirekiList[i].year
                    && month_today == self.rirekiList[i].month){
                    //今月
                    if(self.rirekiList[i].point_type == "1"
                        || self.rirekiList[i].point_type == "3"
                        || self.rirekiList[i].point_type == "4"
                        || self.rirekiList[i].point_type == "5"){
                        //ライブ配信 or 延長配信 or 予約キャンセル or スクショで取得したスター
                        today_month_live_sec = today_month_live_sec + Int(self.rirekiList[i].value01)!
                        today_month_live_point = today_month_live_point + Int(self.rirekiList[i].point)!
                        today_month_live_star = today_month_live_star + Int(self.rirekiList[i].star)!
                    }else if(self.rirekiList[i].point_type == "2"){
                        //プレゼントをゲット
                        today_month_get_point = today_month_get_point + Int(self.rirekiList[i].point)!
                        today_month_get_star = today_month_get_star + Int(self.rirekiList[i].star)!
                    }else if(self.rirekiList[i].point_type == "6"){
                        //イベント補填によるスター数
                        today_month_live_star = today_month_live_star + Int(self.rirekiList[i].value03)!
                    }else if(self.rirekiList[i].point_type == "7"){
                        //オーガナイザー料
                        today_month_live_star = today_month_live_star + Int(self.rirekiList[i].value04)!
                    }else if(self.rirekiList[i].point_type == "8"){
                        //補正スター
                        today_month_live_star = today_month_live_star + Int(self.rirekiList[i].value05)!
                    }else if(self.rirekiList[i].point_type == "99"){
                        //配信で得たスターの没収（キャストからの配信中止による）
                        today_month_live_star = today_month_live_star - Int(self.rirekiList[i].value02)!
                    }
                }

                if(last_month_year_temp == self.rirekiList[i].year
                    && last_month_temp == self.rirekiList[i].month){
                    //先月
                    if(self.rirekiList[i].point_type == "1"
                        || self.rirekiList[i].point_type == "3"
                        || self.rirekiList[i].point_type == "4"
                        || self.rirekiList[i].point_type == "5"){
                        //ライブ配信 or 延長配信 or 予約キャンセル or スクショで取得したスター
                        last_month_live_sec = last_month_live_sec + Int(self.rirekiList[i].value01)!
                        last_month_live_point = last_month_live_point + Int(self.rirekiList[i].point)!
                        last_month_live_star = last_month_live_star + Int(self.rirekiList[i].star)!
                    }else if(self.rirekiList[i].point_type == "2"){
                        //プレゼントをゲット
                        last_month_get_point = last_month_get_point + Int(self.rirekiList[i].point)!
                        last_month_get_star = last_month_get_star + Int(self.rirekiList[i].star)!
                    }else if(self.rirekiList[i].point_type == "6"){
                        //イベント補填によるスター数
                        last_month_live_star = last_month_live_star + Int(self.rirekiList[i].value03)!
                    }else if(self.rirekiList[i].point_type == "7"){
                        //オーガナイザー料
                        last_month_live_star = last_month_live_star + Int(self.rirekiList[i].value04)!
                    }else if(self.rirekiList[i].point_type == "8"){
                        //補正スター
                        last_month_live_star = last_month_live_star + Int(self.rirekiList[i].value05)!
                    }else if(self.rirekiList[i].point_type == "99"){
                        //配信で得たスターの没収（キャストからの配信中止による）
                        last_month_live_star = last_month_live_star - Int(self.rirekiList[i].value02)!
                    }
                }
                
                //add 20220205
                //累計スター数の計算
                if(self.rirekiList[i].point_type == "1"
                    || self.rirekiList[i].point_type == "3"
                    || self.rirekiList[i].point_type == "4"
                    || self.rirekiList[i].point_type == "5"){
                    //ライブ配信 or 延長配信 or 予約キャンセル or スクショで取得したスター
                    all_live_star = all_live_star + Int(self.rirekiList[i].star)!
                }else if(self.rirekiList[i].point_type == "2"){
                    //プレゼントをゲット
                    all_live_star = all_live_star + Int(self.rirekiList[i].star)!
                }else if(self.rirekiList[i].point_type == "6"){
                    //イベント補填によるスター数
                    all_live_star = all_live_star + Int(self.rirekiList[i].value03)!
                }else if(self.rirekiList[i].point_type == "7"){
                    //オーガナイザー料
                    all_live_star = all_live_star + Int(self.rirekiList[i].value04)!
                }else if(self.rirekiList[i].point_type == "8"){
                    //補正スター
                    all_live_star = all_live_star + Int(self.rirekiList[i].value05)!
                }else if(self.rirekiList[i].point_type == "99"){
                    //配信で得たスターの没収（キャストからの配信中止による）
                    all_live_star = all_live_star - Int(self.rirekiList[i].value02)!
                }
                
            }/*end of for*/
            
            //累積値の表示
            //計算用・ラベルに表示用
            let all_live_sec: Int = UserDefaults.standard.integer(forKey: "live_total_sec")
            //let all_live_star: Int = UserDefaults.standard.integer(forKey: "live_total_star")
            
            //brief
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .brief//N分N秒の表示形式
            self.allLiveMinutesLbl.text = formatter.string(from: Double(all_live_sec))
            self.allGetPointLbl.text = String(UtilFunc.numFormatter(num: all_live_star))

            /*
            let payment_request_star = UserDefaults.standard.integer(forKey: "payment_request_star")
            if(payment_request_star > 0){
                //リクエスト申請中
                self.paymentTitleLbl.text = "振込リクエスト中のスター"
                self.allPayLbl.text = String(UtilFunc.numFormatter(num: payment_request_star))
            }else{
                //通常
                self.paymentTitleLbl.text = "振込可能スター"
                self.allPayLbl.text = String(UtilFunc.numFormatter(num: pay_star))
            }
             */

            //スター合計値の計算
            today_total_star = today_live_star + today_get_star
            today_month_total_star = today_month_live_star + today_month_get_star
            last_month_total_star = last_month_live_star + last_month_get_star
            
            //今日のライブ配信時間(60分N秒|スター:3,000)
            self.todayLiveMinutesLbl.text = formatter.string(from: Double(today_live_sec))! + "｜スター:" + String(UtilFunc.numFormatter(num: today_live_star))
            //今日受け取ったプレゼント(スター:500)
            self.todayGetPointLbl.text = "スター:" + String(UtilFunc.numFormatter(num: today_get_star))
            //今日の合計獲得スター(合計｜スター:3,500)
            self.todayTotalPointLbl.text = "合計｜スター:" + String(UtilFunc.numFormatter(num: today_total_star))

            //今月のライブ配信時間(60分|スター:3,000)
            self.monthLiveMinutesLbl.text = formatter.string(from: Double(today_month_live_sec))! + "｜スター:" + String(UtilFunc.numFormatter(num: today_month_live_star))
            //今月受け取ったプレゼント(スター:500)
            self.monthGetPointLbl.text = "スター:" + String(UtilFunc.numFormatter(num: today_month_get_star))
            //今月の合計獲得スター(合計｜スター:3,500)
            self.monthTotalPointLbl.text = "合計｜スター:" + String(UtilFunc.numFormatter(num: today_month_total_star))

            //先月のライブ配信時間(60分|スター:3,000)
            self.lastMonthLiveMinutesLbl.text = formatter.string(from: Double(last_month_live_sec))! + "｜スター:" + String(UtilFunc.numFormatter(num: last_month_live_star))
            //先月受け取ったプレゼント(スター:500)
            self.lastMonthGetPointLbl.text = "スター:" + String(UtilFunc.numFormatter(num: last_month_get_star))
            //先月の合計獲得スター(合計｜スター:3,500)
            self.lastMonthTotalPointLbl.text = "合計｜スター:" + String(UtilFunc.numFormatter(num: last_month_total_star))
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

    @IBAction func tapPayreportBtn(_ sender: Any) {
        //支払いレポートボタン
        UtilToViewController.toPayReportViewController(animated_flg:false)
    }
    
    @IBAction func tapToYenBtn(_ sender: Any) {
        //スターを換金するボタン
        UtilToViewController.toToYenViewController(animated_flg:false)
    }
    
    @IBAction func tapToCoinBtn(_ sender: Any) {
        //スターをコインに変換するボタン
        //UtilToViewController.toToCoinViewController(animated_flg:false)
        
        //現在のスターの数
        let myNowStarTemp = UserDefaults.standard.integer(forKey: "live_now_star")
        
        if(myNowStarTemp < request_star){
            //スターが足りない
            self.showAlertError(star:request_star)
        }else{
            self.showAlert(star:request_star, coin:change_coin)
        }
    }

    //数秒後に勝手に閉じる(ポケットの拡張が終わった場合)
    func showAlertError(star:Int) {
        // アラート作成
        let alert = UIAlertController(title: nil, message: String(UtilFunc.numFormatter(num: star)) + "スターから交換が可能です。", preferredStyle: .alert)
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alert.dismiss(animated: true, completion: {
                    //画面遷移させる
                    //UtilToViewController.toMyCollectionViewController(animated_flg:false)
                    //下記はうまく動作しない(コレクションビューが再描画されない)
                    //self.getMyCollectionList()
                })
                
            })
        })
    }
    
    func showAlert(star:Int, coin:Int){
        //UIAlertControllerを用意する
        let actionAlert = UIAlertController(title: String(UtilFunc.numFormatter(num: star)) + "スターを" + String(UtilFunc.numFormatter(num: coin)) + "コインに変換しますか？", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "変更する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            //自分のuser_idを指定
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            
            //現在のスターの数
            //let myNowStar = UserDefaults.standard.integer(forKey: "live_now_star")
            
            //GET:user_id, star, coin
            //static let URL_TO_COIN_DO = URL_BASE + "paymentRequestToCoinDo.php"
            var stringUrl = Util.URL_TO_COIN_DO
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&star=")
            stringUrl.append(String(star))
            stringUrl.append("&coin=")
            stringUrl.append(String(coin))
            
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
                //現在のコイン数
                let myPointTemp:Double = UserDefaults.standard.double(forKey: "point")
                //現在のスターの数
                let myNowStarTemp = UserDefaults.standard.integer(forKey: "live_now_star")
                
                //更新しておく
                UserDefaults.standard.set(myPointTemp + Double(coin), forKey: "point")
                UserDefaults.standard.set(myNowStarTemp - star, forKey: "live_now_star")
                self.allPayLbl.text = String(UtilFunc.numFormatter(num: myNowStarTemp - star))
                
                if(myNowStarTemp - star < star){
                    //ボタンを無効化
                    self.toCoinBtn.isEnabled = false
                }else{
                    //ボタンを有効化
                    self.toCoinBtn.isEnabled = true
                }
                
                //スターをコインに変更後
                self.showCompAlert(star:star, coin:coin)
            }
        })
        
        actionAlert.addAction(modifyAction)
        
        /*
         //UIAlertControllerに***のアクションを追加する
         let ***Action = UIAlertAction(title: "***", style: UIAlertActionStyle.default, handler: {
         (action: UIAlertAction!) in
         print("***のシートが選択されました。")
         })
         actionAlert.addAction(***Action)
         */
        
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
    
    //数秒後に勝手に閉じる
    func showCompAlert(star:Int, coin:Int) {
        // アラート作成
        let alert = UIAlertController(title: nil, message: String(UtilFunc.numFormatter(num: star)) + "スターを" + String(UtilFunc.numFormatter(num: coin)) + "コインに変換しました。", preferredStyle: .alert)
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                alert.dismiss(animated: true, completion: nil)
                //トップに戻す
                //UtilToViewController.toMainViewController()
            })
        })
    }
}
