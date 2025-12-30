//
//  MainCastSelectViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/07/11.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip

class MainCastSelectViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var upMainView: UIView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //safearea取得用
    var topSafeAreaHeight: CGFloat = 0
    var bottomSafeAreaHeight: CGFloat = 0
    
    override func viewDidLoad() {
        //  メンテナンス中かの判断(メンテナンス画面の中では直接記述すること)
        UtilFunc.maintenanceCheck()
        
        /*
         //バーの色
         settings.style.buttonBarBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
         //ボタンの色
         settings.style.buttonBarItemBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
         //セルの文字色
         settings.style.buttonBarItemTitleColor = UIColor.white
         //セレクトバーの色
         settings.style.selectedBarBackgroundColor = UIColor(red: 254/255, green: 0, blue: 124/255, alpha: 1)
         */
        
        //透明化
        upMainView.backgroundColor = UIColor.clear
        //self.buttonBarView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        
        //バーの色(透明)
        //settings.style.buttonBarBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        //settings.style.buttonBarBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        settings.style.buttonBarBackgroundColor = UIColor.clear
        
        //ボタンの色(透明)
        //settings.style.buttonBarItemBackgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        settings.style.buttonBarItemBackgroundColor = UIColor.clear

        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.white
        //セレクトバーの色
        //settings.style.selectedBarBackgroundColor = Util.BASE_TEXT_COLOR
        settings.style.selectedBarBackgroundColor = UIColor.white
        
        settings.style.buttonBarHeight = 30.0
        
        // タブの文字サイズ
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
        
        //3つのボタンの幅
        settings.style.buttonBarMinimumLineSpacing = 10.0
        //左側のマージン
        settings.style.buttonBarLeftContentInset = 30.0
        //右側のマージン
        settings.style.buttonBarRightContentInset = 30.0

        //選択バーの高さ
        settings.style.selectedBarHeight = 2.0
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*****************************/
        //グラデーション(画面の上部分)
        /*****************************/
        //画面のサイズを取得
        //let width = UIScreen.main.bounds.size.width
        //let height = UIScreen.main.bounds.size.height
        //frame boundsを試してみる
        //グラデーションの開始色
        //let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
        let topColorUp = Util.CAST_SELECT_GRAD_START
        //グラデーションの開始色
        //let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        let bottomColorUp = Util.CAST_SELECT_GRAD_END
        //グラデーションの色を配列で管理
        let gradientColorsUp: [CGColor] = [topColorUp.cgColor, bottomColorUp.cgColor]
        //グラデーションレイヤーを作成
        let gradientLayerUp: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayerUp.colors = gradientColorsUp
        //グラデーションレイヤーをスクリーンサイズにする
        //gradientLayer.frame = self.view.bounds
        gradientLayerUp.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:80)
        
        //グラデーションレイヤー配置
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        self.view.layer.addSublayer(gradientLayerUp)
        
        /*****************************/
        //グラデーション(画面の下部分)
        /*****************************/
        /*
        //グラデーションの開始色
        //let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
        let topColorDown = Util.CAST_SELECT_GRAD_END
        //グラデーションの開始色
        //let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        let bottomColorDown = Util.CAST_SELECT_GRAD_START
        //グラデーションの色を配列で管理
        let gradientColorsDown: [CGColor] = [topColorDown.cgColor, bottomColorDown.cgColor]
        //グラデーションレイヤーを作成
        let gradientLayerDown: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayerDown.colors = gradientColorsDown
        //グラデーションレイヤーをスクリーンサイズにする
        //gradientLayer.frame = self.view.bounds
        gradientLayerDown.frame = CGRect(x:0, y:self.view.frame.height - 80, width:self.view.frame.width, height:80)
        
        //グラデーションレイヤー配置
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        self.view.layer.addSublayer(gradientLayerDown)
         */
        
        //最前面に
        self.view.bringSubviewToFront(upMainView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        //管理されるViewControllerを返す処理
        let firstVC = UIStoryboard(name: "StreamerInfo", bundle: nil).instantiateViewController(withIdentifier: "toCastSelectViewController")
        let secondVC = UIStoryboard(name: "StreamerInfo", bundle: nil).instantiateViewController(withIdentifier: "toCastSelectViewController2")
        let thirdVC = UIStoryboard(name: "StreamerInfo", bundle: nil).instantiateViewController(withIdentifier: "toCastSelectViewController3")
        
        //タブメニュの切り替えの画面一覧
        let childViewControllers:[UIViewController] = [firstVC, secondVC, thirdVC]
        
        //let childViewControllers:[UIViewController] = [firstVC]
        return childViewControllers
    }
    
    //初期の選択
    //他の画面を表示するときもここを通る？？かも
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let selectedSubMenu = UserDefaults.standard.integer(forKey: "selectedSubMenu")
        print(selectedSubMenu)
        
        self.moveToViewController(at: selectedSubMenu, animated: false)
        
        if #available(iOS 11.0, *) {
            //safeareaの調整
            self.topSafeAreaHeight = CGFloat(UserDefaults.standard.float(forKey: "topSafeAreaHeight"))
            self.bottomSafeAreaHeight = CGFloat(UserDefaults.standard.float(forKey: "bottomSafeAreaHeight"))
            
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            //self.topSafeAreaHeight = self.view.safeAreaInsets.top
            //self.bottomSafeAreaHeight = self.view.safeAreaInsets.bottom
            print("in viewDidLayoutSubviews")
            print(self.topSafeAreaHeight)    // iPhoneXなら44, その他は20.0
            print(self.bottomSafeAreaHeight) // iPhoneXなら34,  その他は0
            
            //safeareaを考慮
            let width = self.view.frame.width
            //let height = self.view.frame.height
            
            self.upMainView.frame = CGRect(x:0,y:self.topSafeAreaHeight,width:width,height:self.upMainView.frame.height)
            
            //self.containerView.frame = CGRect(x:0,y:topSafeAreaHeight - 20,width:width,height:height - bottomSafeAreaHeight)
        }
    }
    
    @IBAction func tapCloseBtn(_ sender: Any) {
        //Util.toMainViewController()
        
        //選択しているサブメニュを保存
        UserDefaults.standard.set(self.appDelegate.sendSubMenu, forKey: "selectedSubMenu")
        self.appDelegate.sendSubMenu = "99"
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //画面の上部に表示される時間やバッテリー残量を非表示
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
