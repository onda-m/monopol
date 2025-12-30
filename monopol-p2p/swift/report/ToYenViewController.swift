//
//  ToYenViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/18.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

//リジェクトされたので、いったん未使用
class ToYenViewController: BaseViewController {

    //振込可能スターのところ
    @IBOutlet weak var myStarLbl: UILabel!
    @IBOutlet weak var myStarView: UIView!
    //振込可能スターor振込リクエスト中のスター
    @IBOutlet weak var starTitleLbl: UILabel!
    
    //リクエストボタン
    @IBOutlet weak var payRequestBtn: UIButton!
    
    //本人確認ボタン
    @IBOutlet weak var confirmBtn: UIButton!
    
    //振込リクエストは毎月5~10日に行えます。のところ
    @IBOutlet weak var hosokuLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let payment_request_star = UserDefaults.standard.integer(forKey: "payment_request_star")
        //現在のスターの数
        let myNowStar = UserDefaults.standard.integer(forKey: "live_now_star")
        
        // 角丸
        myStarView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        myStarView.layer.masksToBounds = true
        
        // 角丸
        payRequestBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        payRequestBtn.layer.masksToBounds = true
        
        // 角丸
        confirmBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        confirmBtn.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        
        //スターの数を設定
        //ラベルの枠を自動調節する
        myStarLbl.adjustsFontSizeToFitWidth = true
        myStarLbl.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        hosokuLbl.adjustsFontSizeToFitWidth = true
        hosokuLbl.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        //振込可能スターor振込リクエスト中のスター
        starTitleLbl.adjustsFontSizeToFitWidth = true
        starTitleLbl.minimumScaleFactor = 0.3
        
        if(payment_request_star > 0){
            //リクエスト申請中
            //リクエスト中のスター数を設定
            myStarLbl.text = UtilFunc.numFormatter(num: payment_request_star)
            
            payRequestBtn.isEnabled = false
            payRequestBtn.backgroundColor = UIColor.orange
            payRequestBtn.titleLabel?.textColor = UIColor.white
            payRequestBtn.setTitle("<< 振込リクエスト中 >>", for: .normal)
            
            confirmBtn.isHidden = true
            hosokuLbl.text = "振込リクエスト中です。翌月末に振り込まれます。"
            starTitleLbl.text = "振込リクエスト中のスター"
        }else{
            let day_handan = UserDefaults.standard.integer(forKey: "today_day")
            //現在のスター数を設定
            myStarLbl.text = UtilFunc.numFormatter(num: myNowStar)
            
            //通常
            if(day_handan >= Util.FURIKOMI_DAY_FROM
                && day_handan <= Util.FURIKOMI_DAY_TO
                && myNowStar >= Util.FURIKOMI_MIN_POINT){
                //振込申請可能の場合
                payRequestBtn.isEnabled = true
                payRequestBtn.backgroundColor = UIColor.black
                //payRequestBtn.titleLabel?.textColor = UIColor.white
                payRequestBtn.setTitleColor(UIColor.white, for: .normal)
                payRequestBtn.setTitle("振込リクエストを行う", for: .normal)
                
                confirmBtn.isHidden = false
                hosokuLbl.text = "振込リクエストは毎月" + String(Util.FURIKOMI_DAY_FROM) + "~" + String(Util.FURIKOMI_DAY_TO) + "日に行えます。"
                starTitleLbl.text = "振込可能スター"
            }else{
                //振込申請できない場合
                payRequestBtn.isEnabled = false
                payRequestBtn.backgroundColor = UIColor.gray
                //payRequestBtn.titleLabel?.textColor = UIColor.gray
                payRequestBtn.setTitleColor(UIColor.lightGray, for: .normal)
                payRequestBtn.setTitle("振込リクエストを行う", for: .normal)
                
                confirmBtn.isHidden = false
                hosokuLbl.text = "振込リクエストは毎月" + String(Util.FURIKOMI_DAY_FROM) + "~" + String(Util.FURIKOMI_DAY_TO) + "日に行えます。"
                starTitleLbl.text = "振込可能スター"
            }
        }
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

    @IBAction func tapPayRequestBtn(_ sender: Any) {
        
        let actionAlert = UIAlertController(title: "振込リクエストを行いますか？", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            //現在のスターの数
            let myNowStar = UserDefaults.standard.integer(forKey: "live_now_star")
            
            //振込リクエスト中のスターpayment_request_star = live_now_star
            //現在のスターの数live_now_star = 0に更新する
            //payment_rirekiにインサートする（status=3）
            //paymentRequestDo.php
            //GET:user_id, request_star
            var stringUrl = Util.URL_PAYMENT_REQUEST_DO
            stringUrl.append("?user_id=")
            stringUrl.append(String(self.user_id))
            stringUrl.append("&request_star=")
            stringUrl.append(String(myNowStar))
            
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
                UtilFunc.setMyInfo()
                
                //リクエスト申請中
                //リクエスト中のスター数を設定
                self.myStarLbl.text = UtilFunc.numFormatter(num: myNowStar)
                
                self.payRequestBtn.isEnabled = false
                self.payRequestBtn.backgroundColor = UIColor.orange
                self.payRequestBtn.titleLabel?.textColor = UIColor.white
                self.payRequestBtn.setTitle("<< 振込リクエスト中 >>", for: .normal)
                
                self.confirmBtn.isHidden = true
                self.hosokuLbl.text = "振込リクエスト中です。翌月末に振り込まれます。"
                self.starTitleLbl.text = "振込リクエスト中のスター"
            }
        })
        actionAlert.addAction(modifyAction)
        
        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler: {
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
    
    @IBAction func tapConfirmBtn(_ sender: Any) {
        //本人確認画面へ
        UtilToViewController.toIdentificationViewController(animated_flg: false)
    }
}
