//
//  KeyBoard.swift
//  swift_skyway
//
//  Created by onda on 2018/07/04.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

//閉じるボタンの付いたキーボード
class KeyBoard: UITextField{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //let okButton: UIBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(tapOkButton(_:)))
        let closeButton = UIBarButtonItem(title: Util.KEYBOARD_CLOSE_STR, style: UIBarButtonItem.Style.plain, target: self, action: #selector(KeyBoard.closeButtonTapped))
        tools.items = [spacer, closeButton]
        self.inputAccessoryView = tools
    }
    
    @objc func closeButtonTapped(){
        self.endEditing(true)
        self.resignFirstResponder()
    }
}
