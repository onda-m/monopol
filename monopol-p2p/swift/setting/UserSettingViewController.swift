//
//  UserSettingViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/05.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class UserSettingViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileEdit(_ sender: Any) {
        //プロフィール編集
        UtilToViewController.toProfileSettingViewController()
    }
    
    @IBAction func accountEdit(_ sender: Any) {
        //アカウント設定
        UtilToViewController.toAccountEditViewController()
    }

    @IBAction func accountDel(_ sender: Any) {
        //アカウント削除
        let alert = UIAlertController(
             title: "アカウントを削除しますか？",
             message: "削除するとすべてのデータが失われます。この操作は取り消せません。",
             preferredStyle: .alert
         )
         alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
         alert.addAction(UIAlertAction(title: "削除する", style: .destructive) { _ in
             //UUIDを取得
             //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
             //let phonedeviceId = UUID().uuidString
             let user_id = UserDefaults.standard.integer(forKey: "user_id")

             var stringUrl = Util.URL_MODIFY_STATUS_INFO
             stringUrl.append("?user_id=")
             stringUrl.append(String(user_id))
             stringUrl.append("&status=98")//削除ステータス
             
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
                     //do{
                         dispatchGroup.leave()//サブタスク終了時に記述
                     //}catch{
                         //エラー処理
                         //print("エラーが出ました")
                         //print("json convert failed in JSONDecoder", err?.localizedDescription)
                     //    print("削除失敗: \(error)")
                     //}
                 })
                 task.resume()
             }
             // 全ての非同期処理完了後にメインスレッドで処理
             dispatchGroup.notify(queue: .main) {
                 //ユーザー情報を更新
                 //UtilFunc.setMyInfo()
                 //UtilFunc.showAlert(message:"アカウントの削除が完了しました", vc:self, sec:2.0)

                 // --- ローカル情報を初期化 ---
                 UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                 UserDefaults.standard.synchronize()
                 UtilToViewController.toSplashViewController()//スプラッシュ画面に戻す（ただしその後は遷移しない）

                 /*
                 // --- 初回起動画面に戻す ---
                 DispatchQueue.main.async {
                     // 例：Main.storyboard の "InitialViewController"（ログインやチュートリアル画面）
                     let storyboard = UIStoryboard(name: "SubMain", bundle: nil)
                     let initialVC = storyboard.instantiateViewController(withIdentifier: "SubMainViewController")
                     
                     if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let window = windowScene.windows.first {
                         window.rootViewController = initialVC
                         window.makeKeyAndVisible()
                         // フェードで自然に遷移
                         UIView.transition(with: window,
                                           duration: 0.4,
                                           options: .transitionCrossDissolve,
                                           animations: nil)
                     }
                 }
                 */
                 
             }
         })
         present(alert, animated: true)
    }
    
    @IBAction func notifyEdit(_ sender: Any) {
        //通知設定
        UtilToViewController.toNotifySettingViewController()
    }
    
    @IBAction func blacklistEdit(_ sender: Any) {
        //ブラックリスト編集
        UtilToViewController.toBlackListViewController()
    }
    
    @IBAction func overEdit(_ sender: Any) {
        //リストア画面へ
        UtilToViewController.toRestoreViewController()
    }
    
    @IBAction func movieEdit(_ sender: Any) {
        //動画設定画面へ
        UtilToViewController.toMovieSettingViewController()
    }

    @IBAction func ruleCheck(_ sender: Any) {
        //利用規約画面へ
        UtilToViewController.toRuleViewController()
    }
    
    @IBAction func contactUsCheck(_ sender: Any) {
        //お問い合わせ画面へ
        UtilToViewController.toContactUsViewController()
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
