//
//  CheckBox.swift
//  swift_skyway
//
//  Created by onda on 2019/05/25.
//  Copyright © 2019年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

//同意するしないのチェックで使用
class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "ico_check_on")! as UIImage
    let uncheckedImage = UIImage(named: "ico_check_off")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
