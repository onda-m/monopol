//
//  CastEffectDialog.swift
//  swift_skyway
//
//  Created by onda on 2019/01/25.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class CastEffectDialog: UIView {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var effectListView: UIView!
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    //ボタン関連
    @IBOutlet weak var effectBtn01: UIButton!
    @IBOutlet weak var effectBtn02: UIButton!
    @IBOutlet weak var effectBtn03: UIButton!
    @IBOutlet weak var effectBtn04: UIButton!
    @IBOutlet weak var effectBtn05: UIButton!
    @IBOutlet weak var effectBtn06: UIButton!
    
    /*
    //未選択時のボタンの色
    //ボタンのテキストの色（iOSの標準の青っぽい色）
    static let BTN_DEFAULT_TEXT_COLOR: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    //ボタンの背景色（未選択時）
    static let BTN_DEFAULT_BACKGROUND_COLOR: UIColor = UIColor.groupTableViewBackground

    //選択時のボタンの色
    //ボタンのテキストの色
    static let BTN_DEFAULT_TEXT_COLOR_SELECTED: UIColor = UIColor.white
    //ボタンの背景色（選択時）
    static let BTN_DEFAULT_BACKGROUND_COLOR_SELECTED: UIColor = UIColor(red: 226/255, green: 149/255, blue: 156/255, alpha: 1.0)
    */
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // backgroundColorを使って透過させる。
        self.mainView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        
        //effectListView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        /*
        cell.followBtn.setTitle("＋フォロー", for: .normal)
        //枠の大きさを自動調節する
        cell.followBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.followBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        cell.followBtn.setTitleColor(UIColor.lightGray, for: .normal) // タイトルの色
        cell.followBtn.backgroundColor = UIColor.white
        cell.followBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
        cell.followBtn.layer.borderWidth = 0.5
        */
        
        // 枠線の色
        effectListView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        effectListView.layer.borderWidth = 1
        // 角丸
        effectListView.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        effectListView.layer.masksToBounds = true
        
        //枠線は表示しない
        clearBtn.layer.borderWidth = 0
        effectBtn01.layer.borderWidth = 0
        effectBtn02.layer.borderWidth = 0
        effectBtn03.layer.borderWidth = 0
        effectBtn04.layer.borderWidth = 0
        effectBtn05.layer.borderWidth = 0
        effectBtn06.layer.borderWidth = 0
        
        //角丸
        clearBtn.layer.cornerRadius = 6
        effectBtn01.layer.cornerRadius = 6
        effectBtn02.layer.cornerRadius = 6
        effectBtn03.layer.cornerRadius = 6
        effectBtn04.layer.cornerRadius = 6
        effectBtn05.layer.cornerRadius = 6
        effectBtn06.layer.cornerRadius = 6
        
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        clearBtn.layer.masksToBounds = true
        effectBtn01.layer.masksToBounds = true
        effectBtn02.layer.masksToBounds = true
        effectBtn03.layer.masksToBounds = true
        effectBtn04.layer.masksToBounds = true
        effectBtn05.layer.masksToBounds = true
        effectBtn06.layer.masksToBounds = true
        
        //枠の大きさを自動調節する
        clearBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        effectBtn01.titleLabel?.adjustsFontSizeToFitWidth = true
        effectBtn02.titleLabel?.adjustsFontSizeToFitWidth = true
        effectBtn03.titleLabel?.adjustsFontSizeToFitWidth = true
        effectBtn04.titleLabel?.adjustsFontSizeToFitWidth = true
        effectBtn05.titleLabel?.adjustsFontSizeToFitWidth = true
        effectBtn06.titleLabel?.adjustsFontSizeToFitWidth = true
        
        clearBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        effectBtn01.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        effectBtn02.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        effectBtn03.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        effectBtn04.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        effectBtn05.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        effectBtn06.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        //ぼかしはリリース時はなしで。
        effectBtn06.isHidden = true
        
        // ボタンの位置とサイズを設定
        //「エフェクト効果を解除」ボタン
        clearBtn.frame = CGRect(x:20, y:20,width:140, height:20)

        mainView.isHidden = true
        effectListView.isHidden = true
    }
    
    @IBAction func tapCloseEffectListView(_ sender: Any) {
        self.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    //エフェクトフラグを更新
    //GET:cast_id,effect_flg01,effect_flg02,effect_flg03
    func modifyEffectFlg(cast_id:Int, effect_flg01:Int, effect_flg02:Int, effect_flg03:Int){
        var stringUrl = Util.URL_MODIFY_EFFECT_FLG
        stringUrl.append("?cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&effect_flg01=")
        stringUrl.append(String(effect_flg01))
        stringUrl.append("&effect_flg02=")
        stringUrl.append(String(effect_flg02))
        stringUrl.append("&effect_flg03=")
        stringUrl.append(String(effect_flg03))
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //print("aaaa")
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    if data != nil {
                        //ステータス変更が成功
                    }else{
                    }
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //待機処理が終わった後に実行する処理
            self.appDelegate.live_effect_id = effect_flg01
        }
    }
    
    @IBAction func tapEffectClear(_ sender: Any) {
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.modifyEffectFlg(cast_id:user_id, effect_flg01:0, effect_flg02:0, effect_flg03:0)
        
        //共通のクリア処理
        //self.effectClear()
        
        /*
        //未選択時のボタンの色
        //ボタンのテキストの色（iOSの標準の青っぽい色）
        static let BTN_DEFAULT_TEXT_COLOR: UIColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        //ボタンの背景色（未選択時）
        static let BTN_DEFAULT_BACKGROUND_COLOR: UIColor = UIColor.groupTableViewBackground
        
        //選択時のボタンの色
        //ボタンのテキストの色
        static let BTN_DEFAULT_TEXT_COLOR_SELECTED: UIColor = UIColor.white
        //ボタンの背景色（選択時）
        static let BTN_DEFAULT_BACKGROUND_COLOR_SELECTED: UIColor = UIColor(red: 226/255, green: 149/255, blue: 156/255, alpha: 1.0)
        */
        
        //ボタンの色を変更（全て未選択に）
        clearBtn.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        clearBtn.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn01.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn01.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn02.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn02.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn03.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn03.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn04.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn04.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn05.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn05.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn06.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn06.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        //ダイアログを閉じる
        self.isHidden = true
        //self.coverView.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    //波エフェクト
    @IBAction func tapEffectBtn001(_ sender: Any) {
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.modifyEffectFlg(cast_id:user_id, effect_flg01:1, effect_flg02:0, effect_flg03:0)
        
        //共通のクリア処理
        //self.effectClear()
        
        /*
         //Effect効果009(アニメーションGIF)
         //UIImageを作る.
         //let myImage = UIImage(named: "animation001")!
         
         let gif = UIImage(gifName: "animation001")
         effectImageView = UIImageView(gifImage: gif, loopCount: -1) // Use -1 for infinite loop
         effectImageView.isUserInteractionEnabled = false
         effectImageView.alpha = 0.3
         //imageview.frame = view.bounds
         effectImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT)
         self.addSubview(effectImageView)
         */
        
        /*
         let gifManager = SwiftyGifManager(memoryLimit:100)
         let gif = UIImage(gifName: "animation002")
         let imageview = UIImageView(gifImage: gif, manager: gifManager)
         imageview.frame = CGRect(x: 0.0, y: 5.0, width: 400.0, height: 200.0)
         self.view.addSubview(imageview)
         */
        
        //ボタンの色を変更（全て未選択に）
        clearBtn.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        clearBtn.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn01.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR_SELECTED, for: .normal) // タイトルの色
        effectBtn01.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR_SELECTED
        
        effectBtn02.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn02.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn03.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn03.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn04.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn04.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn05.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn05.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn06.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn06.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        //ダイアログを閉じる
        self.isHidden = true
        //self.coverView.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    //パープル
    @IBAction func tapEffectBtn002(_ sender: Any) {
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.modifyEffectFlg(cast_id:user_id, effect_flg01:2, effect_flg02:0, effect_flg03:0)
        
        //共通のクリア処理
        //self.effectClear()
        
        /*
        //Effect効果001
        effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT))
        // coverViewの背景
        effectView.backgroundColor = Util.EFFECT_COLOR_001
        // 透明度を設定
        //effectView.alpha = 0.4
        effectView.isUserInteractionEnabled = false
        self.addSubview(effectView)
        */
        
        //ボタンの色を変更
        clearBtn.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        clearBtn.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn01.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn01.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn02.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR_SELECTED, for: .normal) // タイトルの色
        effectBtn02.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR_SELECTED
        
        effectBtn03.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn03.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn04.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn04.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn05.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn05.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn06.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn06.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        //ダイアログを閉じる
        self.isHidden = true
        //self.coverView.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    //ブルー
    @IBAction func tapEffectBtn003(_ sender: Any) {
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.modifyEffectFlg(cast_id:user_id, effect_flg01:3, effect_flg02:0, effect_flg03:0)
        
        //共通のクリア処理
        //self.effectClear()
        
        /*
        //Effect効果002
        effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT))
        // coverViewの背景
        effectView.backgroundColor = Util.EFFECT_COLOR_002
        // 透明度を設定
        //effectView.alpha = 0.4
        effectView.isUserInteractionEnabled = false
        self.addSubview(effectView)
        */
        
        //ボタンの色を変更
        clearBtn.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        clearBtn.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn01.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn01.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn02.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn02.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn03.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR_SELECTED, for: .normal) // タイトルの色
        effectBtn03.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR_SELECTED
        
        effectBtn04.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn04.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn05.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn05.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn06.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn06.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        //ダイアログを閉じる
        self.isHidden = true
        //self.coverView.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    //スクリーン（中央の赤を「紫っぽく」で使っている色に）
    @IBAction func tapEffectBtn004(_ sender: Any) {
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.modifyEffectFlg(cast_id:user_id, effect_flg01:4, effect_flg02:0, effect_flg03:0)
        
        //共通のクリア処理
        //self.effectClear()
        
        /*
         //Effect効果008(グラデーションをかける)
         //中央に向けたグラデーションを追加
         gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT)
         self.layer.addSublayer(gradientLayer)
         */
        
        //ボタンの色を変更（全て未選択に）
        clearBtn.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        clearBtn.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn01.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn01.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn02.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn02.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn03.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn03.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn04.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR_SELECTED, for: .normal) // タイトルの色
        effectBtn04.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR_SELECTED
        
        effectBtn05.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn05.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn06.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn06.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        //ダイアログを閉じる
        self.isHidden = true
        //self.coverView.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    /*
     //赤っぽく(削除)
     @IBAction func tapEffectBtn003(_ sender: Any) {
     //FireBase更新
     let effect_id_temp = ["effect_id": 3]
     self.conditionRef.updateChildValues(effect_id_temp)
     appDelegate.live_effect_ id = 3
     
     //共通のクリア処理
     self.effectClear()
     
     //Effect効果003
     effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT))
     // coverViewの背景
     effectView.backgroundColor = Util.EFFECT_COLOR_003
     // 透明度を設定
     //effectView.alpha = 0.4
     effectView.isUserInteractionEnabled = false
     self.addSubview(effectView)
     
     //ダイアログを閉じる
     self.isHidden = true
     //self.coverView.isHidden = true
     //self.effectListView.isHidden = true
     }
     */
    
    //ホワイト
    @IBAction func tapEffectBtn005(_ sender: Any) {
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.modifyEffectFlg(cast_id:user_id, effect_flg01:5, effect_flg02:0, effect_flg03:0)
        
        //共通のクリア処理
        //self.effectClear()
        
        /*
        //Effect効果004
        effectView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT))
        // coverViewの背景
        effectView.backgroundColor = Util.EFFECT_COLOR_004
        // 透明度を設定
        //effectView.alpha = 0.4
        effectView.isUserInteractionEnabled = false
        self.addSubview(effectView)
        */
        
        //ボタンの色を変更
        clearBtn.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        clearBtn.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn01.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn01.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn02.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn02.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn03.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn03.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn04.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn04.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn05.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR_SELECTED, for: .normal) // タイトルの色
        effectBtn05.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR_SELECTED
        
        effectBtn06.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn06.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        //ダイアログを閉じる
        self.isHidden = true
        //self.coverView.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    /*
     //ぼかす1(削除)
     @IBAction func tapEffectBtn005(_ sender: Any) {
     //FireBase更新
     let effect_id_temp = ["effect_id": 5]
     self.conditionRef.updateChildValues(effect_id_temp)
     appDelegate.live_effect_ id = 5
     
     //下記を使用してぼかした場合
     //https://qiita.com/shirape/items/056719c7a717c1281c6b
     //共通のクリア処理
     self.effectClear()
     
     //Effect効果005(ぼかす)
     // ブラーエフェクトを作成
     let blurEffect = UIBlurEffect(style: .dark)
     
     // ブラーエフェクトからエフェクトビューを作成
     effectView = UIVisualEffectView(effect: blurEffect)
     
     // エフェクトビューのサイズを画面に合わせる
     effectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT)
     
     effectView.isUserInteractionEnabled = false
     self.addSubview(effectView)
     
     //ダイアログを閉じる
     self.isHidden = true
     //self.coverView.isHidden = true
     //self.effectListView.isHidden = true
     }
     */
    
    //画面をぼかす
    @IBAction func tapEffectBtn006(_ sender: Any) {
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        self.modifyEffectFlg(cast_id:user_id, effect_flg01:6, effect_flg02:0, effect_flg03:0)
        
        //共通のクリア処理
        //self.effectClear()
        
        /*
        //Effect効果006(ぼかす)
        // ブラーエフェクトを作成
        let blurEffect = UIBlurEffect(style: .light)
        
        // ブラーエフェクトからエフェクトビューを作成
        effectView = UIVisualEffectView(effect: blurEffect)
        
        // エフェクトビューのサイズを画面に合わせる
        effectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT)
        
        effectView.isUserInteractionEnabled = false
        self.addSubview(effectView)
        */
        
        //ボタンの色を変更（全て未選択に）
        clearBtn.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        clearBtn.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn01.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn01.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn02.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn02.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn03.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn03.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn04.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn04.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn05.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR, for: .normal) // タイトルの色
        effectBtn05.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR
        
        effectBtn06.setTitleColor(Util.BTN_DEFAULT_TEXT_COLOR_SELECTED, for: .normal) // タイトルの色
        effectBtn06.backgroundColor = Util.BTN_DEFAULT_BACKGROUND_COLOR_SELECTED
        
        //ダイアログを閉じる
        self.isHidden = true
        //self.coverView.isHidden = true
        //self.effectListView.isHidden = true
    }
    
    /*
     //ぼかす3(削除)
     @IBAction func tapEffectBtn007(_ sender: Any) {
     //FireBase更新
     let effect_id_temp = ["effect_id": 7]
     self.conditionRef.updateChildValues(effect_id_temp)
     appDelegate.live_effect_ id = 7
     
     //共通のクリア処理
     self.effectClear()
     
     //Effect効果007(ぼかす)
     // ブラーエフェクトを作成
     let blurEffect = UIBlurEffect(style: .extraLight)
     
     // ブラーエフェクトからエフェクトビューを作成
     effectView = UIVisualEffectView(effect: blurEffect)
     
     // エフェクトビューのサイズを画面に合わせる
     effectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Util.TAB_BAR_HEIGHT)
     
     effectView.isUserInteractionEnabled = false
     self.addSubview(effectView)
     
     //ダイアログを閉じる
     self.isHidden = true
     //self.coverView.isHidden = true
     //self.effectListView.isHidden = true
     }
     */
}
