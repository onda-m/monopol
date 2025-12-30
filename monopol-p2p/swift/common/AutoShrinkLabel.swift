//
//  AutoShrinkLabel.swift
//  swift_skyway
//
//  Created by onda on 2018/05/28.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class AutoShrinkLabel: UILabel {

    var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    //drawTextで余白（padding）を付ける
    override func drawText(in rect: CGRect) {
        //let newRect = UIEdgeInsetsInsetRect(rect, padding)
        let newRect = rect.inset(by: padding)
        super.drawText(in: newRect)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
