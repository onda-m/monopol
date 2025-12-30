//
//  AsyncImageView.swift
//  swift_skyway
//
//  Created by onda on 2018/05/03.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class AsyncImageView: UIImageView {
    //URLから画像を読み込んで表示するImageView
    //使い方
    //let imageView = AsyncImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40));
    //imageView.loadImage("https://~~~/image.png");
    //self.view.addSubview(imageView);
    
    let CACHE_SEC : TimeInterval = 10 * 60; //10分キャッシュ
    
    //画像を非同期で読み込む
    func loadImage(urlString: String){
        let req = URLRequest(url: NSURL(string:urlString)! as URL,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: CACHE_SEC);
        let conf =  URLSessionConfiguration.default;
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main);
        
        session.dataTask(with: req, completionHandler:
            { (data, resp, err) in
                if((err) == nil){ //Success
                    let image = UIImage(data:data!)
                    self.image = image;
                    
                }else{ //Error
                    print("AsyncImageView:Error")
                    //print("AsyncImageView:Error \(err?.localizedDescription)");
                }
        }).resume();
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
