//
//  UserGetScreenshotDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/08/08.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserGetScreenshotDialog: UIView {

    @IBOutlet weak var mainView: UIView!
    //スクショを受け取った時に表示するダイアログ
    @IBOutlet weak var mainAddView: UIView!
    
    //スクリーンショットを受け取った時に表示するVIEW関連
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var getScreenshotImageViewBig: UIImageView!//メインの大きい画像
    @IBOutlet weak var getScreenshotLbl: AutoShrinkLabel!
    @IBOutlet weak var getScreenshotImageView: UIImageView!//右上の小さい画像
    @IBOutlet weak var getScreenshotIcon: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // データベースへの参照
    var rootRef = Database.database().reference()
    var conditionRef = DatabaseReference()
    
    var user_id: Int = 0//自分のID
    var cast_id: Int = 0//キャストのID
    
    //ライブ配信中、キャストからスクリーンショットをもらった時に表示
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        
        //////////////////////////////////////////////
        //スクリーンショットを受け取った時に表示
        //////////////////////////////////////////////
        // 角丸
        self.mainView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainView.layer.masksToBounds = true
        
        do {
            let gif = try UIImage(gifName: "getScreenshot")
            self.getScreenshotIcon.setGifImage(gif)
            self.getScreenshotIcon.loopCount = -1
            self.getScreenshotIcon.isUserInteractionEnabled = false
            self.getScreenshotIcon.alpha = 0.8
        } catch {
            // error handling
        }
        /*
        do {
            let gif = try UIImage(gifName: "getScreenshot")
            self.getScreenshotIcon.setGifImage(gif)
            self.getScreenshotIcon.loopCount = -1
            self.getScreenshotIcon.isUserInteractionEnabled = false
            self.getScreenshotIcon.alpha = 0.8
        } catch {
            // error handling
        }*/
    
        // 角丸
        self.getScreenshotLbl.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.getScreenshotLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        self.getScreenshotLbl.adjustsFontSizeToFitWidth = true
        self.getScreenshotLbl.minimumScaleFactor = 0.3
        
        // 角丸
        self.getScreenshotImageViewBig.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.getScreenshotImageViewBig.layer.masksToBounds = true
        
        // 角丸
        self.getScreenshotImageView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.getScreenshotImageView.layer.masksToBounds = true
        
        //ボタンの整形
        // 枠線の色
        self.okBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.okBtn.layer.borderWidth = 1
        // 角丸
        self.okBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.okBtn.layer.masksToBounds = true
        
        //ボタンの整形
        // 枠線の色
        self.cancelBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.cancelBtn.layer.borderWidth = 1
        // 角丸
        self.cancelBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.cancelBtn.layer.masksToBounds = true
        
        //////////////////////////////////////////////
        //スクリーンショットを受け取った時に表示(ここまで)
        //////////////////////////////////////////////
        
        //キャストのIDを取得
        self.cast_id = Int(self.appDelegate.sendId!)!
        //自分のIDを取得
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //重要(リアルタイムデータベースを使用)
        self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE
            + "/"
            + self.appDelegate.sendId! + "/" + String(self.user_id))
    }

    @IBAction func tapOkBtn(_ sender: Any) {
        //1度だけ取得
        self.conditionRef.observeSingleEvent(of: .value, with: { (snap) in
            let dict = snap.value as! [String : AnyObject]
            let file_name = dict["request_screenshot_name"] as! String
            
            UtilFunc.modifyMycollectionStatusDo(userId:self.user_id, castId:self.cast_id, fileName:file_name, status:1)
        })

        //スクショの名前を0に初期化
        let data = ["request_screenshot_name": "0","request_screenshot_flg": 4] as [String : Any]
        self.conditionRef.updateChildValues(data)

        /*************************************************************/
        //コイン・ポイントなどの計算処理(スクショ受け取り)
        /*************************************************************/
        //コインの消費
        let point = Util.SCREENSHOT_PAY_COIN
        UtilFunc.pointUseDo(type:0, userId: self.user_id, point: Double(point))
        //コイン消費履歴に履歴を保存する
        UtilFunc.writePointUseRireki(type:7,
                                     point:Double(point),
                                     user_id:self.user_id,
                                     target_user_id:self.cast_id)

        //課金ポイントのボーナス値
        let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")
        
        //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
        UtilFunc.savePairMonthRanking(user_id:self.user_id, cast_id:self.cast_id, exp:Int(Double(point)*strConnectBonusRate))
        
        //絆レベルなど相手との情報を取得(スクショ受け取り時には不要)
        //Util.getConnectInfo(my_user_id:self.user_id, target_user_id:self.cast_id)
        /*************************************************************/
        //コイン・ポイントなどの計算処理(ここまで)
        /*************************************************************/

        //self.isHidden = true
        self.mainView.isHidden = true
        self.mainAddView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            //5秒後に下記を非表示
            self.mainAddView.isHidden = true
            self.isHidden = true
        }
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        //1度だけ取得
        self.conditionRef.observeSingleEvent(of: .value, with: { (snap) in
            let dict = snap.value as! [String : AnyObject]
            let file_name = dict["request_screenshot_name"] as! String
            
            UtilFunc.modifyMycollectionStatusDo(userId:self.user_id, castId:self.cast_id, fileName:file_name, status:2)
        })
        
        //スクショの名前を0に初期化
        let data = ["request_screenshot_name": "0","request_screenshot_flg": 0] as [String : Any]
        self.conditionRef.updateChildValues(data)
        
        self.isHidden = true
    }
}
