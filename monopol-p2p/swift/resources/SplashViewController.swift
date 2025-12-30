//
//  SplashViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/12/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

//自作のスプラッシュ画面
class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            //→ユーザー情報がDBにあるかも見ること(修正必要)
            if UserDefaults.standard.integer(forKey: "login_status") > 0
                && UserDefaults.standard.integer(forKey: "user_id") > 0 {
                //print("UUIDがある場合、呼ばれるアプリ起動時の処理だよ")
                //self.window = UIWindow(frame: UIScreen.main.bounds)
                //self.window?.rootViewController = HomeViewController()//遷移先を指定
                //self.window?.makeKeyAndVisible()
                //アプリ起動時に、ユーザー情報を取得して、UserDefaultに設定
                //            UtilFunc.setMyInfo()
                
                //ユーザー用のストーリーボードへ
                UtilToViewController.toMainViewController()
            }else{
            }
        }
         */
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
