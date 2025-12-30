//
//  MyprofileListDialog.swift
//  swift_skyway
//
//  Created by onda on 2019/12/06.
//  Copyright © 2019 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class MyprofileListDialog: UIView {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var castImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var myprofileLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // backgroundColorを使って透過させる。
        self.baseView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        self.baseView.isHidden = false//表示
        self.baseView.isUserInteractionEnabled = true
        self.baseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapBaseView(_:))))
        
        

        /*
        let castInfo = (String(UserDefaults.standard.integer(forKey: "user_id")),
                        UserDefaults.standard.string(forKey: "myName")!.toHtmlString(),
                        String(UserDefaults.standard.integer(forKey: "myPhotoFlg")),
                        UserDefaults.standard.string(forKey: "myPhotoName")!,
                        String(UserDefaults.standard.integer(forKey: "myMovieFlg")),
                        UserDefaults.standard.string(forKey: "myMovieName")!,
                        String(UserDefaults.standard.integer(forKey: "follower_num")),
                        String(UserDefaults.standard.integer(forKey: "follow_num")),
                        String(UserDefaults.standard.integer(forKey: "myWatchLevel")),
                        String(UserDefaults.standard.integer(forKey: "myLiveLevel")),
                        String(UserDefaults.standard.integer(forKey: "cast_rank")),
                        String(UserDefaults.standard.integer(forKey: "cast_official_flg")))
        */
        //ユーザー画像の表示
        let photoFlg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
        let photoName = UserDefaults.standard.string(forKey: "myPhotoName")!
        let user_id = UserDefaults.standard.integer(forKey: "user_id")

        //写真URL
        if(photoFlg == 1){
            //写真設定済み
            //let photoUrl = "user_images/" + user_id + "_list.jpg"
            let photoUrl = "user_images/" + String(user_id) + "/" + photoName + "_list.jpg"
            //画像キャッシュを使用
            castImageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            castImageView?.image = cellImage
        }
        
        /*
         Util.CAST_STATUS_COLOR_WAIT
         Util.CAST_STATUS_COLOR_ONLIVE
         Util.CAST_STATUS_COLOR_OFF
         */
        
        // Tag番号を使ってLabelのインスタンス生成
        //キャスト名
        //let label = testCell.contentView.viewWithTag(92) as! UILabel
        myprofileLabel.text = UserDefaults.standard.string(forKey: "myName")!.toHtmlString()
        
        statusLabel.textColor = Util.CAST_STATUS_COLOR_OFF
        
        //ダイアログ関連
        // 枠線の色
        //self.mainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.mainView.layer.borderWidth = 0
        
        // 角丸
        self.mainView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.mainView.layer.masksToBounds = true

        // 角丸
        self.castImageView.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.castImageView.layer.masksToBounds = true
        
        /*
        // 角丸
        self.cancelBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.cancelBtn.layer.masksToBounds = true
         */
    }
    
    // 背景Viewがタップされたら呼ばれる
    @objc func tapBaseView(_ sender: UITapGestureRecognizer) {
        //ダイアログを閉じる
        self.removeFromSuperview()
    }
}
