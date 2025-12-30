//
//  NetworkErrorViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/21.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Reachability

class NetworkErrorViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var retryBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ポップアップビュー背景色
        //let viewColor = UIColor.white
        // 半透明にして親ビューが見えるように。透過度はお好みで。
        //mainView.backgroundColor = viewColor.withAlphaComponent(1.0)
        
        // 角丸
        mainView.layer.cornerRadius = 14
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mainView.layer.masksToBounds = true
        
        //ボタンの整形
        // 枠線の色
        retryBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        retryBtn.layer.borderWidth = 1
        // 角丸
        retryBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        retryBtn.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapRetryBtn(_ sender: Any) {
        
        let reachability = try! Reachability()
        if reachability.connection == .unavailable {
            // インターネット接続なし
        } else {
            // インターネット接続あり
            //getTopViewController()?.loadView()
            //getTopViewController()?.viewDidLoad()
            //ホーム画面へ
            UtilToViewController.toMainViewController()
        }
        
        /*
        do {
            if let reachability:Reachability = try! Reachability() {
                if(reachability.connection == .unavailable){
                }else{
                    //getTopViewController()?.loadView()
                    //getTopViewController()?.viewDidLoad()
                    //ホーム画面へ
                    UtilToViewController.toMainViewController()
                }
            }
        }*/
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //現在のViewControllerを取得
    func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewControlelr: UIViewController = rootViewController
            
            while let presentedViewController = topViewControlelr.presentedViewController {
                topViewControlelr = presentedViewController
            }
            
            return topViewControlelr
        } else {
            return nil
        }
    }
}
