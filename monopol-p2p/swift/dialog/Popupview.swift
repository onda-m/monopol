//
//  Popupview.swift
//  swift_skyway
//
//  Created by onda on 2018/04/28.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class Popupview: UIView {

    @IBOutlet weak var textLbl: UILabel!

    @IBOutlet weak var baseView: UIView!
    
    @IBAction func close(_ sender: UIButton) {
        self.removeFromSuperview()
    }

    func labelSet(name: String){
        textLbl.text = name //文字列
        textLbl.numberOfLines = 0//折り返し
        textLbl.sizeToFit()//サイズを文字列に合わせる
        textLbl.lineBreakMode = NSLineBreakMode.byCharWrapping //文字で改行
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
