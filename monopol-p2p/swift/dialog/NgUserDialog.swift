//
//  NgUserDialog.swift
//  swift_skyway
//
//  Created by onda on 2020/06/18.
//  Copyright © 2020 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class NgUserDialog: UIView {

//    @IBOutlet weak var baseView: UIView!
    //@IBOutlet weak var loginLbl: UILabel!
    //@IBOutlet weak var notesLbl: UILabel!
//    @IBOutlet weak var presentImageView: UIImageView!
    //@IBOutlet weak var mainView: UIView!
//    @IBOutlet weak var closeBtn: UIButton!

    //var selectedImg:UIImage!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // 枠線の色
        //self.mainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //self.mainView.layer.borderWidth = 0
        
        // backgroundColorを使って透過させる。
//        self.baseView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
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
}
