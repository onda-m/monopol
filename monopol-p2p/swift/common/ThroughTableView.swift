//
//  ThroughView.swift
//  swift_skyway
//
//  Created by onda on 2018/06/12.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class ThroughTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    //自分自身はサワレナイ(下記を透過したいVIewに記述)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self {
            return nil
        }
        return view
    }

}
