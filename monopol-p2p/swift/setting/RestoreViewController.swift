//
//  RestoreViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/07/05.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class RestoreViewController: BaseViewController {

    @IBOutlet weak var centerMainView: UIView!
    
    @IBOutlet weak var nextIdTextField: KeyBoard!
    @IBOutlet weak var passwordTextField: KeyBoard!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    //リストアの結果(カウントを返す)
    struct ResultJson: Codable {
        let result_count: Int
        //let result: [UserResult]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 角丸
        self.setBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.setBtn.layer.masksToBounds = true
        
        // 角丸
        self.cancelBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.cancelBtn.layer.masksToBounds = true
        
        // 入力された文字を非表示モードにする.
        passwordTextField.isSecureTextEntry = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSetBtn(_ sender: Any) {
        self.restoreDo()
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        passwordTextField.text = ""
        nextIdTextField.text = ""
    }
    
    func restoreDo(){
        let strPassword = passwordTextField.text
        let strNextId = nextIdTextField.text
        
        if(strPassword != nil && strPassword != ""){
            
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            let uuid = UserDefaults.standard.string(forKey: "uuid")
            let fcm_token = UserDefaults.standard.string(forKey: "fcm_token")
            
            //リストア
            //GET: user_id,next_id,next_pass,uuid
            var stringUrl = Util.URL_RESTORE_DO
            stringUrl.append("?user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&next_id=")
            stringUrl.append(strNextId!)
            stringUrl.append("&next_pass=")
            stringUrl.append(strPassword!)
            stringUrl.append("&uuid=")
            stringUrl.append(uuid!)
            stringUrl.append("&fcm_token=")
            stringUrl.append(fcm_token!)
            //print(stringUrl)
            
            // Swift4からは書き方が変わりました。
            let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            //let decodedString:String = text.removingPercentEncoding!
            let req = URLRequest(url: url)
            
            //非同期処理を行う
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
            var json_result :ResultJson? = nil
            
            dispatchGroup.enter()
            dispatchQueue.async {
                let task = URLSession.shared.dataTask(with: req, completionHandler: {
                    (data, res, err) in
                    do{
                        //JSONDecoderのインスタンス取得
                        let decoder = JSONDecoder()
                        
                        //受けとったJSONデータをパースして格納
                        json_result = try decoder.decode(ResultJson.self, from: data!)
                        
                        //print("作成されたID")
                        //print(json.id_temp)
                        dispatchGroup.leave()//サブタスク終了時に記述
                    }catch{
                        //エラー処理
                        //print("エラーが出ました")
                        //print("json convert failed in JSONDecoder", err?.localizedDescription)
                    }
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                
                self.passwordTextField.text = ""
                self.nextIdTextField.text = ""
                
                if(json_result?.result_count == 1){
                    //リストア成功
                    //値をセットする
                    UtilFunc.setMyInfo()
                    
                    //ダイアログ表示
                    //self.showAlert()
                    
                    //showalert
                    UtilFunc.showAlert(message:"アカウントの引継ぎが完了しました", vc:self, sec:2.0)
                    
                }else{
                    //リストア失敗
                    //self.showErrorAlert()
                    
                    //showalert
                    UtilFunc.showAlert(message:"アカウントの引継ぎに失敗しました", vc:self, sec:2.0)
                }
            }
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
}
