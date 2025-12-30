//
//  PlaceHolderTextView.swift
//  swift_skyway
//
//  Created by onda on 2018/06/06.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

//閉じるボタンの付いたキーボード
public class PlaceHolderTextView: UITextView {
    
    lazy var placeHolderLabel:UILabel = UILabel()
    var placeHolderColor:UIColor      = UIColor.lightGray
    var placeHolder:NSString          = ""
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textChanged(notification:)), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    override public func draw(_ rect: CGRect) {
        if(self.placeHolder.length > 0) {
            self.placeHolderLabel.frame           = CGRect(x : 8, y : 8, width : self.bounds.size.width - 16, height : 0)
            self.placeHolderLabel.lineBreakMode   = NSLineBreakMode.byWordWrapping
            self.placeHolderLabel.numberOfLines   = 0
            self.placeHolderLabel.font            = self.font
            self.placeHolderLabel.backgroundColor = UIColor.clear
            self.placeHolderLabel.textColor       = self.placeHolderColor
            self.placeHolderLabel.alpha           = 0
            self.placeHolderLabel.tag             = 1
            
            self.placeHolderLabel.text = self.placeHolder as String
            self.placeHolderLabel.sizeToFit()
            self.addSubview(placeHolderLabel)
        }
        
        self.sendSubviewToBack(placeHolderLabel)
        
        if(self.text.utf16.count == 0 && self.placeHolder.length > 0){
            self.viewWithTag(1)?.alpha = 1
        }
        
        super.draw(rect)
    }
    
    @objc public func textChanged(notification:NSNotification?) -> (Void) {
        if(self.placeHolder.length == 0){
            return
        }
        
        if(self.text.utf16.count == 0) {
            self.viewWithTag(1)?.alpha = 1
        }else{
            self.viewWithTag(1)?.alpha = 0
        }
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
