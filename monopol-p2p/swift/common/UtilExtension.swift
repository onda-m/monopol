//
//  UtilExtension.swift
//  swift_skyway
//
//  Created by onda on 2018/10/30.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    //同時タップを禁止する
    /*
     使用方法
     super.viewDidLoad()
     self.exclusiveAllTouches() // これを呼ぶだけで同時タップが防げる
     
     // TODO: 同時タップを許したいViewだけ個別にexclusiveTouchをfalseに
     例：button1.exclusiveTouch = false
     */
    
    func exclusiveAllTouches() {
        self.applyAllViews { $0.isExclusiveTouch = true }
    }
    
    func applyAllViews(apply: (UIView) -> ()) {
        apply(self.view)
        self.applyAllSubviews(view: self.view, apply: apply)
    }
    
    private func applyAllSubviews(view: UIView, apply: (UIView) -> ()) {
        let subviews = view.subviews as [UIView]
        subviews.map { (view: UIView) -> () in
            apply(view)
            self.applyAllSubviews(view: view, apply: apply)
        }
    }
}

extension UIImage {
    //URLで画像を指定する関数
    //こんな感じで呼び出す
    //let image:UIImage = UIImage(url: "https://rr.img")
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
    
    /*
    //画像を反転させる
    func flipHorizontal() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let imageRef = self.cgImage
        let context = UIGraphicsGetCurrentContext()
        //CGContext.translateBy(x:y:)
        context!.translateBy(x:size.width, y:size.height)
        context!.scaleBy(x:-1.0, y:-1.0)
        context!.draw(imageRef!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let flipHorizontalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flipHorizontalImage!
    }
    //画像を回転させる
    //image?.rotatedBy(degree: 30.0, isCropped: false)
    func rotatedBy(degree: CGFloat, isCropped: Bool = true) -> UIImage {
        let radian = -degree * CGFloat.pi / 180
        var rotatedRect = CGRect(origin: .zero, size: self.size)
        if !isCropped {
            rotatedRect = rotatedRect.applying(CGAffineTransform(rotationAngle: radian))
        }
        UIGraphicsBeginImageContext(rotatedRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: rotatedRect.size.width / 2, y: rotatedRect.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.rotate(by: radian)
        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
     */
    
    //画像のサイズ変更
    //let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
    //image?.reSizeImage(reSize: reSize)
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    //0.5倍率で画像を縮小する場合など
    //image?.scaleImage(scaleSize: 0.5)
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
    /*容量制限があるため使用しない
     // Firebase URLからUIImage取得
     static func contentOfFIRStorage(path: String, callback: @escaping (UIImage?) -> Void) {
     //ユーザーIDをセットする
     //let user_id = UserDefaults.standard.integer(forKey: "user_id")
     
     let storage = Storage.storage()
     let storageRef = storage.reference(forURL: Util.URL_FIREBASE)
     //let dbRef = storageRef.child("screenshot/" + String(user_id))
     let dbRef = storageRef.child(path)
     
     dbRef.getData(maxSize: 1024 * 1024 * 10) { (data: Data?, error: Error?) in
     if error != nil {
     callback(nil)
     return
     }
     if let imageData = data {
     let image = UIImage(data: imageData)
     callback(image)
     }
     }
     }
     */
    /*
     func resizeUIImageRatio(ratio: CGFloat) -> UIImage! {
     
     // 指定された画像の大きさのコンテキストを用意.
     UIGraphicsBeginImageContextWithOptions(CGSize(width: ratio, height: ratio), false, 0.0)
     //UIGraphicsBeginImageContext(CGSize(width: ratio, height: ratio - 50))
     
     // コンテキストに自身に設定された画像を描画する.
     self.draw(in: CGRect(x: 0, y: 0, width: ratio, height: ratio))
     
     // コンテキストからUIImageを作る.
     let newImage = UIGraphicsGetImageFromCurrentImageContext()
     
     // コンテキストを閉じる.
     UIGraphicsEndImageContext()
     
     return newImage
     }
     */
    class func colorForTabBar(color: UIColor) -> UIImage {
        let rect = CGRect(x : 0, y : 0, width : 1, height : 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

//ページ番号の取得(縦方向)
extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.y + (0.5 * self.bounds.height)) / self.bounds.height) + 1
    }
}

extension String {
    //文字列を一定の文字数ごとに分割した配列にして取得
    //let str = "abcdefghijklmnopqrstuvwxyz"
    //let array = str.splitInto(3)
    //print(array)
    // >> ["abc", "def", "ghi", "jkl", "mno", "pqr", "stu", "vwx", "yz"]
    func splitInto(_ length: Int) -> [String] {
        var str = self
        for i in 0 ..< (str.count - 1) / max(length, 1) {
            str.insert(",", at: str.index(str.startIndex, offsetBy: (i + 1) * max(length, 1) + i))
        }
        return str.components(separatedBy: ",")
    }
    
    //半角英数字の判定
    func isAlphanumeric() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[a-zA-Z0-9]+").evaluate(with: self)
    }
    
    func toHtmlString() -> String {
        let str = self
        return str.replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil)
    }
    
    //HTMLエンティティを含む文字列をデコードする
    //let test = "&lt;&amp;&gt;"
    //Swift.print(test.htmlDecoded)
    // ⇒ <&>
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType : NSAttributedString.DocumentType.html,
            .characterEncoding : String.Encoding.utf8.rawValue
        ]
        guard let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attrStr.string
    }
    
    // StringからCharacterSetを取り除く
    func remove(characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet).joined()
    }

    // StringからCharacterSetを抽出する
    func extract(characterSet: CharacterSet) -> String {
        return remove(characterSet: characterSet.inverted)
    }
}

extension UIView {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
    
    /*
    /// Viewいっぱいにオートレイアウト
    func autoLayout(to toView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: toView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: toView.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: toView.rightAnchor).isActive = true
    }
     */
}

//最前面のUIViewControllerを取得
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
//PINRemoteImageを使用して画像キャッシュを利用し画像をviewに設定
extension UIImageView {
    func setImageListByPINRemoteImage(ratio: CGFloat, path: String, no_image_named:String) {
        /*
         let storage = Storage.storage()
         let storageRef = storage.reference(forURL: Util.URL_FIREBASE)
         //let dbRef = storageRef.child("screenshot/" + String(user_id))
         let dbRef = storageRef.child(path)
         
         dbRef.downloadURL { url, error in
         if (error != nil) {
         //print("Uh-oh, an error occurred!")
         } else {
         //print("download success!! URL:", url!)
         self.pin_setImage(from: url) { [weak self] result in
         // Success
         if result.error == nil, let image = result.image {
         if(ratio > 0.0){
         self?.image = image.resizeUIImageRatio(ratio: ratio)
         }else{
         self?.image = image
         }
         } else {
         // 写真がない場合(現状、正常に動作しない)
         let no_image_temp = UIImage(named:no_image_named)
         // UIImageをUIImageViewのimageとして設定
         self?.image = no_image_temp
         }
         }
         }
         }*/
        
        let photoUrl = URL(string: Util.URL_USER_PHOTO_BASE + path)!
        
        //print(photoUrl)
        
        self.pin_setImage(from: photoUrl) { [weak self] result in
            // Success
            if result.error == nil {
                //if result.error == nil, let image = result.image {
                //if(ratio > 0.0){
                //self?.image = image.resizeUIImageRatio(ratio: ratio)
                //}else{
                //    self?.image = image
                //}
            } else {
                // 写真がない場合
                let no_image_temp = UIImage(named:no_image_named)
                // UIImageをUIImageViewのimageとして設定
                self?.image = no_image_temp
            }
        }
        
        /*
         //デフォルト設定でセッションオブジェクトを作成する。
         let session = URLSession(configuration: .default)
         let downloadPicTask = session.dataTask(with: photoUrl) { (data, response, error) in
         if error != nil {
         //print("cat pictureのダウンロード中にエラーが発生しました: \(e)")
         } else {
         if (response as? HTTPURLResponse) != nil {
         if data != nil {
         //何らかの処理
         
         //let imageimage = UIImage(data: imageData)
         //print(imageimage!)
         //self.templateThumbnailImageView.image = imageimage
         
         
         } else {
         //print("画像を取得できませんでした：画像はありません")
         }
         } else {
         //print("何らかの理由で応答コードを取得できませんでした")
         }
         }
         }
         
         downloadPicTask.resume()
         */
    }
    
    /*
     func setImageListByPINRemoteImageNoCache(ratio: CGFloat, path: String, no_image_named:String) {
     
     let photoUrl = URL(string: Util.URL_USER_PHOTO_BASE + path)!
     
     //if let cacheKey = PINRemoteImageManager.shared().cacheKey(for: photoUrl, processorKey: nil) {
     //    PINRemoteImageManager.shared().cache.removeObjectForKey(cacheKey, block: nil)
     //}
     let cacheKey = PINRemoteImageManager.shared().cacheKey(for: photoUrl, processorKey: nil)
     PINRemoteImageManager.shared().cache.removeObject(forKey: cacheKey, block: nil)
     
     self.pin_setImage(from: photoUrl) { [weak self] result in
     // Success
     if result.error == nil {
     //if result.error == nil, let image = result.image {
     //if(ratio > 0.0){
     //self?.image = image.resizeUIImageRatio(ratio: ratio)
     //}else{
     //    self?.image = image
     //}
     } else {
     // 写真がない場合
     let no_image_temp = UIImage(named:no_image_named)
     // UIImageをUIImageViewのimageとして設定
     self?.image = no_image_temp
     }
     }
     }*/
}
