//
//  FirstFollowView.swift
//  swift_skyway
//
//  Created by onda on 2020/03/20.
//  Copyright © 2020 worldtrip. All rights reserved.
//

import Foundation
import UIKit

//10フォロー達成した際に表示するダイアログ
class FirstFollowView: UIView {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // 枠線の色
        //self.mainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //self.mainView.layer.borderWidth = 0
        
        // backgroundColorを使って透過させる。
        //self.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        // ポップアップビュー背景色
        //let viewColor = UIColor.black
        // 半透明にして親ビューが見えるように。透過度はお好みで。
        //self.backgroundColor = viewColor.withAlphaComponent(0.5)
        
        /*
        //ラベルの枠を自動調節する
        self.loginLbl.adjustsFontSizeToFitWidth = true
        self.loginLbl.minimumScaleFactor = 0.3
        
        //ラベルの枠を自動調節する
        self.notesLbl.adjustsFontSizeToFitWidth = true
        self.notesLbl.minimumScaleFactor = 0.3
        self.notesLbl.text = "プレゼントを獲得しました!"
        */
        
        // ダイアログ背景色（白の部分）
        //let baseViewColor = UIColor.gray
        // ちょっとだけ透明にする
        //self.menuView.backgroundColor = baseViewColor.withAlphaComponent(1.0)
        // 角丸にする
        //self.mainView.layer.cornerRadius = 8.0
        
        //プレゼントの画像を設定
        //self.selectedImg = UIImage(named:"901")
        // UIImageをUIImageViewのimageとして設定
        //self.presentImageView.image = self.selectedImg
    }
    
    @IBAction func close(_ sender: UIButton) {
        //連続タップをできないように
        sender.isEnabled = false

        //10フォローしたら130コイン(無料コイン扱い)
        //ポップアップを閉じたタイミングで130コインが追加されている。
        //UUIDを取得(使用しない)
        //let user_uid = UIDevice.current.identifierForVendor!.uuidString
        let user_id = Foundation.UserDefaults.standard.integer(forKey: "user_id")
        let point = Util.EVENT_FOLLOW_COIN
        
        //user_infoの更新のみ
        //GET:user_id,point,type
        //type 1=有償、2=無料
        var stringUrl = Util.URL_PURCHASE_DO_NEW
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=2&point=")
        stringUrl.append(String(point))
        
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
                    
                    //ここまでに処理を記述
                    dispatchGroup.leave()
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //point(コイン数)更新
            var myPoint:Double = Foundation.UserDefaults.standard.double(forKey: "myPoint")
            myPoint = myPoint + Double(point)
            UserDefaults.standard.set(myPoint, forKey: "myPoint")
            //self.pointLabel.text = "残りポイント：" + Util.numFormatter(num: myPoint) + "ポイント"
            
            //cast_action_rirekiに保存
            //type:1:初回待機 2:ライブ開始 3:ライブ後の待機 4：待機解除 5:運営タイムスタンプ（待機確認）6:リスナーからのリクエスト 11フォロー達成によるコイン受取
            UtilFunc.addActionRireki(user_id: user_id, listener_id: 0, type: 11, value01:Util.EVENT_FOLLOW_COIN, value02:0)
            
            //初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
            //UserDefaults.standard.set(2, forKey: "first_flg02")
            UtilFunc.modifyFirstFlg02(flg:2)
            
            self.removeFromSuperview()
        }
    }

    /*
    func labelSet(name: String){
        textLbl.text = name //文字列
        textLbl.numberOfLines = 0//折り返し
        textLbl.sizeToFit()//サイズを文字列に合わせる
        textLbl.lineBreakMode = NSLineBreakMode.byCharWrapping //文字で改行
    }
     */
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
