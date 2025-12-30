//
//  EventTopViewController.swift
//  swift_skyway
//
//  Created by dev monopol on 2021/10/04.
//  Copyright © 2021 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EventTopViewController: UIViewController, IndicatorInfoProvider {

    let iconSize: CGFloat = 20.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "イベント作成"
    
    // プルダウン選択肢(最大待機時間)
    //例：10分を選択した場合は、５分経過時までライブ開始が可能(ひと枠分のライブ配信が可能)。
    //それ以降は待機が解除される。
    //let waitTimeList = ["60分", "30分", "10分"]
    //let waitTimeData = ["60", "30", "10"]//次の画面に渡す用
    //var waitTimeCd: Int = 0
    
    // プルダウン選択肢(枠の延長リクエスト)
    //let frameRequestList = ["リクエスト時に毎回確認", "常に許可(確認不要)", "枠の延長リクエストを受け付けない"]
    //var frameRequestCd: Int = 0
    
    
    //@IBOutlet weak var mainScrollView: UIScrollView!
    
    //イベント作成ボタン
    @IBOutlet weak var createEventBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        self.passwordTextField.placeholder = "パスワードを設定してください"
        
        if(self.passwordTextFieldFlg == 0){
            self.passwordLiveBtn.setTitle("オフ", for: .normal)
            self.passwordTextField.isHidden = true
        }else if(self.passwordTextFieldFlg == 1){
            self.passwordLiveBtn.setTitle("オン", for: .normal)
            self.passwordTextField.isHidden = false
        }*/
    
        
        /*
        // 角丸
        oneFrameTimeLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        oneFrameTimeLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        oneFrameTimeLbl.adjustsFontSizeToFitWidth = true
        oneFrameTimeLbl.minimumScaleFactor = 0.3
        
        // 角丸
        frameRequestLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        frameRequestLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        frameRequestLbl.adjustsFontSizeToFitWidth = true
        frameRequestLbl.minimumScaleFactor = 0.3
        */
        
        /*パスワードのところは実装しない
        //ラベルの枠を自動調節する
        passwordLiveLbl.adjustsFontSizeToFitWidth = true
        passwordLiveLbl.minimumScaleFactor = 0.3
        
        // 角丸
        passwordLiveLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        passwordLiveLbl.layer.masksToBounds = true
        passwordLiveLbl.backgroundColor = Util.LIVE_WAIT_LABEL_BG_COLOR
        */
        
        /*
        //ボタンの整形
        // 枠線の色
        maxWaitTimeBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        maxWaitTimeBtn.layer.borderWidth = 0.5
        // 角丸
        maxWaitTimeBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        maxWaitTimeBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        maxWaitTimeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        maxWaitTimeBtn.titleLabel?.minimumScaleFactor = 0.3
        */

        // Do any additional setup after loading the view.
        
        UtilFunc.checkPermission()
        //self.checkPermissionMicrophone()
        //UtilFunc.checkPermissionCamera()
        
        // スクロールの高さを変更
        //mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: 650)
    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //くるくる表示終了
        //self.busyIndicator.removeFromSuperview()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        UtilLog.printf(str:"EventTopViewController - MemoryWarning")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */

    @IBAction func createEventTop(_ sender: Any) {
        //1回目イベントの始めたい時間
        //self.appDelegate.eventStartTime01FirstFlg = 0
        //2回目イベントの始めたい時間
        //self.appDelegate.eventStartTime02FirstFlg = 0
        
        //作成したイベント数のチェック
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.getMyEventCount(user_id:user_id)
    }

    //マイイベント数取得
    func getMyEventCount(user_id:Int){
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")
        var event_count = 0
        
        var stringUrl = Util.URL_GET_MY_EVENT_COUNT
        stringUrl.append("?type=1&user_id=")
        stringUrl.append(String(user_id))
        
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
                    let json = try decoder.decode(UtilStruct.ResultMyEventCountJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        event_count = Int(obj.my_event_count)!
                        //UserDefaults.standard.set(obj.my_event_count, forKey: "talkNoreadCount")
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(event_count == 0){
                //イベント作成の直前ページへ
                //UtilToViewController.toCreateEventTopViewController()
                //イベント作成のページへ
                UtilToViewController.toCreateEventViewController()
            }else{
                //エラーメッセージ
                //アラート表示
                let alert = UIAlertController(title: "イベントを既に作成済みです", message: "イベントの内容は「マイページ」の「イベント確認」メニューから確認することが出来ます。", preferredStyle: .alert)
                //ここから追加
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    //マイページへ
                    //UtilToViewController.toMypageViewController()
                }
                alert.addAction(ok)
                //ここまで追加
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
