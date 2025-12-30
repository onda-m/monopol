//
//  AppleLoginStartViewController.swift
//  swift_skyway
//
//  Created by dev monopol on 2022/05/27.
//  Copyright © 2022 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class AppleLoginStartViewController: UIViewController {
    
    // LoginButtonDelegate, UIPickerViewDelegate, UIPickerViewDataSource
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //新規登録するボタン
    @IBOutlet weak var saveInfoBtn: UIButton!
    
    //区切り線
    //@IBOutlet weak var separateView: UIView!
    
    // 選択肢
    //let dataList = ["性別を選択してください", "女性", "男性"]
    //var sexCd: Int = 0
    var lineIdCount: Int = 0//LineID登録件数 0 or 1
    var appleIdCount: Int = 0//AppleID登録件数 0 or 1
    
    @IBOutlet weak var NameFeild: KeyBoard!

    //@IBOutlet weak var sexCdBtn: UIButton!
    //@IBOutlet weak var nextIdLbl: UILabel!
    //引き継ぎボタン
    //@IBOutlet weak var nextBtn: UIButton!
    
    //ユーザー情報取得用
    struct UserResult: Codable {
        let user_id: String
        let next_id: String
        let next_pass: String
        let uuid: String
        let fcm_token: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let movie_flg: String
        let movie_name: String
        let sns_userid01: String//LineのユーザーID
        let sns_userid02: String//未使用
        let sns_userid03: String//未使用
        let value01: String//性別
        let value02: String//フォロワー数
        let value03: String//フォロー数
        let value04: String//報酬一覧のWebViewの表示・非表示フラグ
        //let value05: String//未使用
        let mycollection_max: String//マイコレクションのMAX値
        let point: String//所有しているポイント
        let point_pay: String
        let point_free: String
        let live_point: String//配信ポイント
        let watch_level: String//視聴レベル
        let live_level: String//配信レベル
        let cast_rank: String//1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
        let cast_official_flg: String//1:公式
        let cast_month_ranking: String//キャスト月間ランキング
        let cast_month_ranking_point: String//キャスト月間ランキングポイント
        let twitter: String//
        let facebook: String//
        let instagram: String//
        let homepage: String//
        let freetext: String//
        let notice_text: String//
        let login_status: String//
        //let login_time: String//
        //let ins_time: String//
    }
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //  メンテナンス中かの判断(メンテナンス画面の中では直接記述すること)
        UtilFunc.maintenanceCheck()
        
        /*
         // 枠線の色
         sexCdBtn.layer.borderColor = UIColor.lightGray.cgColor
         // 枠線の太さ
         sexCdBtn.layer.borderWidth = 2
         // 角丸
         sexCdBtn.layer.cornerRadius = 4
         // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
         sexCdBtn.layer.masksToBounds = true
         */

        // 枠線の色
        //NameFeild.layer.borderColor = UIColor.lightGray.cgColor
        NameFeild.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        NameFeild.layer.borderWidth = 0.5
        // 角丸
        NameFeild.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        NameFeild.layer.masksToBounds = true
        
        // 枠線の色
        //saveInfoBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //saveInfoBtn.layer.borderWidth = 0
        // 角丸
        //saveInfoBtn.layer.cornerRadius = 10
        saveInfoBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        saveInfoBtn.layer.masksToBounds = true
        //色指定
        saveInfoBtn.backgroundColor = Util.COMMON_BLUE_COLOR

        // 区切り線の色
        //self.separateView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 区切り線の太さ
        //self.separateView.layer.borderWidth = 0.5
        
        // 角丸
        //nextBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //nextBtn.layer.masksToBounds = true
        //色指定ffb700
        //nextBtn.backgroundColor = Util.COIN_YEN_BG_COLOR
        
        //self.setMyInfo()
        
        // Do any additional setup after loading the view.
        
        /*
        // Create Line Login Button.
        let loginButton = LoginButton()
        loginButton.delegate = self
        
        // Configuration for permissions and presenting.
        loginButton.permissions = [.profile]
        loginButton.presentingViewController = self
        
        // Add button to view and layout it.
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        // Create Login Button.(ここまで)
        */
        
        /*
        //同意確認がされていない場合は、RuleCheckViewを重ねる
        //規約同意チェックフラグ：１＝チェック済
        let rule_check_flg = UserDefaults.standard.integer(forKey: "rule_check_flg")
        if(rule_check_flg != 1){
            let ruleCheckView:RuleCheckView = UINib(nibName: "RuleCheckView", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! RuleCheckView
            //mainToolbarView.toolbarViewSetting()
            //画面サイズに合わせる
            ruleCheckView.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(ruleCheckView)
        }
         */
    }
    
    /*
    //Line login Delegate
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        //hideIndicator()
        print("Login Succeeded.")
        
        if let profile = loginResult.userProfile {
            print("User ID: \(profile.userID)")
            print("User Display Name: \(profile.displayName)")
            print("User Icon: \(String(describing: profile.pictureURL))")
        }
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        //hideIndicator()
        print("Error: \(error)")
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        //showIndicator()
        print("Login Started.")
    }
    //Line login Delegate(ここまで)
    */

    /*
    //monopolIDでログインボタン
    @IBAction func tapNextBtn(_ sender: Any) {
        //もう一度トークンなどの情報をセットしておく
        self.setMyInfo()
        
        UtilToViewController.toNextInfoViewController()
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // UUIDがアプリ内に設定されているかの判断
        //if UserDefaults.standard.object(forKey: "uuid") != nil {
        if UserDefaults.standard.integer(forKey: "login_status") > 0
            && UserDefaults.standard.integer(forKey: "user_id") > 0 {
            
            //Mainのストーリーボードへ
            UtilToViewController.toMainViewController()
        }
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        //if inputText1.text != "" && inputText2.text != "" {
        self.goNext()
    }

    //() -> ()の部分は　(引数) -> (返り値)を指定
    func goNext(){
        let strName = NameFeild.text
        
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let apple_id = UserDefaults.standard.string(forKey: "sns_userid02")
        
        //if(strName != nil && strName != "" && sexCd > 0){
        if(strName != nil && strName != ""){
            //UUIDを取得
            //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
            //let phonedeviceId = UUID().uuidString

            //ユーザーの情報を変更(登録時のみ使用)
            //GET: user_id, name, sex, apple_id(任意)
            var stringUrl = Util.URL_SAVE_FIRST
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&name=")
            stringUrl.append(strName!)
            stringUrl.append("&sex=0")
            stringUrl.append("&apple_id=")
            stringUrl.append(apple_id!)
            
            print(stringUrl)
            
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
                    //do{
                    
                    dispatchGroup.leave()//サブタスク終了時に記述
                    //}catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print("json convert failed in JSONDecoder", err?.localizedDescription)
                    //}
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                // 名前を保存
                UserDefaults.standard.set(strName, forKey: "myName")
                //UserDefaults.standard.set(self.sexCd, forKey: "sex_cd")
                //ログイン情報を設定
                UserDefaults.standard.set(3, forKey: "login_status")
                
                //let fcm_token = UserDefaults.standard.string(forKey: "fcm_token_temp")
                let fcm_token = UserDefaults.standard.string(forKey: "fcm_token_temp")
                //print("----------------------------")
                //print("****************************")
                //print(fcm_token)
                //print("****************************")
                //print("----------------------------")
                
                UtilFunc.modifyFcmToken(user_id:user_id, token:fcm_token!)
                
                //ホーム画面へ遷移
                UtilToViewController.toMainViewController()
            }
        }
    }
    
    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
