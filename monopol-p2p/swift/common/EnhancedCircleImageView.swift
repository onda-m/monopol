//
//  EnhancedCircleImageView.swift
//  swift_skyway
//
//  Created by onda on 2018/05/15.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

//画像を丸で表示する
//https://qiita.com/saku/items/29c7fa20a62cc2f366fa
//また layoutSubViews もオーバーライドして、そのタイミングで
//layer.cornerRadius を設定することでlayer自体も丸に変更しているため、
//layer.borderColor や layer.borderWidth を指定して枠線をつけてももうまく動作します。

import UIKit

class EnhancedCircleImageView: UIImageView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        // swap UIImage because you can't asign yourself.
        let image = self.image
        self.image = image
    }
    
    open override var image: UIImage? {
        get { return super.image }
        set {
            self.contentMode = .scaleAspectFit
            super.image = newValue?.roundImage()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2.0
    }
}

extension UIImage {
    func roundImage() -> UIImage {
        let minLength: CGFloat = min(self.size.width, self.size.height)
        let rectangleSize: CGSize = CGSize(width: minLength, height: minLength)
        UIGraphicsBeginImageContextWithOptions(rectangleSize, false, 0.0)
        
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: rectangleSize), cornerRadius: minLength).addClip()
        self.draw(in: CGRect(origin: CGPoint(x: (minLength - self.size.width) / 2, y: (minLength - self.size.height) / 2), size: self.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
