//
//  EndLiveDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/07/15.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class EndLiveDialog: UIView {

    @IBOutlet weak var mainCoreVIew: UIView!
    
    @IBOutlet weak var mainView: UIView!

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        // 角丸
        //mainView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //mainView.layer.masksToBounds = true
        
        // backgroundColorを使って透過させる。
        mainCoreVIew.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    }

}
