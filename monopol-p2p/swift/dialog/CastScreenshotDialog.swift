//
//  CastScreenshotDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/06/08.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseDatabase
//import FirebaseStorage

//スクショ管理の画面から「スクショを撮って保存」のボタンを押したときに表示
//参考
//https://i-app-tec.com/ios/camera.html
class CastScreenshotDialog: UIView {

    var coverView: UIView!//利用者のタップをできないようにするために覆うVIEW
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var retakeBtn: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code

        //ダイアログ以外、タップできないようにする
        if coverView == nil {
            coverView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            // coverViewの背景
            coverView.backgroundColor = UIColor.black
            // 透明度を設定
            coverView.alpha = 0.9
            coverView.isUserInteractionEnabled = true
            self.addSubview(coverView)
        }
        coverView.isHidden = false
        
        if(self.appDelegate.pickedImage != nil){
            photoImage.image = appDelegate.pickedImage
            //imageから(反転)>90度回転してしまう
            //photoImage.image = appDelegate.pickedImage?.flipHorizontal()
            //270度回転することにより戻す
            //photoImage.image = photoImage.image!.rotatedBy(degree: 270.0)
        }else{
            //URLから
            //画像キャッシュを使用
            photoImage.setImageListByPINRemoteImage(ratio: 0.0, path: self.appDelegate.pickedImageUrl!, no_image_named:"no_image")
        }

        // 画像を反転
        var transMiller = CGAffineTransform()
        transMiller = CGAffineTransform(scaleX: -1.0, y: 1.0)
        photoImage.transform = transMiller
        
        // 角丸
        mainView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mainView.layer.masksToBounds = true

        //ボタンの整形
        // 枠線の色
        sendBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        sendBtn.layer.borderWidth = 1
        // 角丸
        sendBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        sendBtn.layer.masksToBounds = true
        
        // 枠線の色
        retakeBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        retakeBtn.layer.borderWidth = 1
        // 角丸
        retakeBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        retakeBtn.layer.masksToBounds = true
        
        self.bringSubviewToFront(mainView)
    }
    
    
    @IBAction func saveDo(_ sender: Any) {
        //ユーザーIDをセットする
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //画像を送信する
        imageSave(image: self.photoImage.image!, cast_id: user_id)
        
        self.photoImage.image = nil
        self.appDelegate.pickedImage = nil
        self.coverView.isHidden = true
        self.mainView.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    @IBAction func retakeDo(_ sender: Any) {
        self.photoImage.image = nil
        self.appDelegate.pickedImage = nil
        self.coverView.isHidden = true
        self.mainView.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    //画像の保存処理
    //screenshot/cast_id/.jpg
    func imageSave(image: UIImage, cast_id: Int) {
        // データベースへの参照(URL保存用)
        //let rootRef = Database.database().reference()
        
        // 画像のupload
        //let storage = Storage.storage()
        //let storageRef = storage.reference(forURL: Util.URL_FIREBASE)
        
        let now = NSDate()
        let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")//重要
        formatter.dateFormat = "yyyyMMddHHmmss"
        //formatter.setLocalizedDateFormatFromTemplate("yyyyMMddHHmmss")
        
        let file_name = formatter.string(from: now as Date)

        /*
        //画像のサイズ変更
        //image?.scaleImage(scaleSize: Util.SCREENSHOT_PHOTO_HI)
        //画像のサイズ変更
        let reSize = CGSize(width: Util.SCREENSHOT_PHOTO_WIDTH, height: Util.SCREENSHOT_PHOTO_HEIGHT)
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        if let data = UIImagePNGRepresentation(image.reSizeImage(reSize: reSize)) {
            let reference = storageRef.child("user_images/" + String(user_id) + ".jpg")
            reference.putData(data, metadata: nil, completion: { metaData, error in
                //print(metaData as Any)
                //print(error as Any)
                
                //ボタンの背景に選択した画像を設定
                self.userImageView.image = image
                
                //photo_flgを更新
                self.modifyPhotoFlg(photo_flg:1)
                UserDefaults.standard.set(1, forKey: "myPhotoFlg")
            })
            dismiss(animated: true, completion: nil)
        }*/

        //画像のサイズ変更(個別用の画像)
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        //let orgImage = Util.resizeImage(image :image, w:Int(Util.SCREENSHOT_PHOTO_WIDTH), h:Int(Util.SCREENSHOT_PHOTO_HEIGHT))
        let orgImage = UtilFunc.resizeImage(image :image, width:Double(Util.SCREENSHOT_PHOTO_WIDTH), height:Double(Util.SCREENSHOT_PHOTO_HEIGHT))
        
        if let orgdata = orgImage.pngData() {
            
            var orgfileName = file_name
            orgfileName.append(".jpg")
            //let saveUrl = "screenshot/" + String(cast_id) + "/" + file_name + ".jpg"
            
            let orgbody = UtilFunc.httpBodyAlpha(orgdata, fileName: orgfileName, castId: String(cast_id), userId: "0")
            //let orgurl = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_SCREENSHOT_PHOTO)!, data: orgbody) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        //print("Upload done")
                    } else {
                        //print("Upload error")
                        //print(response.statusCode)
                    }
                }
            }
        }
        
        //画像のサイズ変更(リスト画像)
        let listImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.SCREENSHOT_LIST_PHOTO_WIDTH), height:Double(Util.SCREENSHOT_LIST_PHOTO_HEIGHT))
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        if let listdata = listImage.pngData() {
            
            var listfileName = file_name
            listfileName.append("_list.jpg")
            //let saveListUrl = "screenshot/" + String(cast_id) + "/" + file_name + "_list.jpg"
            
            let listbody = UtilFunc.httpBodyAlpha(listdata, fileName: listfileName, castId: String(cast_id), userId: "0")
            //let listbody = Util.httpBody(listdata,fileName: listfileName)
            //let listurl = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_SCREENSHOT_PHOTO)!, data: listbody) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        //print("Upload done")
                        
                        //画像の送信が終わった場合
                        // 保存が成功したらDBにURLを追加
                        //let saveUrl = "screenshot/" + String(cast_id) + "/" + file_name + ".jpg"
                        //let dbRef = rootRef.child("screenshot/" + String(cast_id) + "/" + file_name)
                        //dbRef.setValue(saveUrl)

                        var stringUrl = Util.URL_SAVE_SCREENSHOT
                        stringUrl.append("?user_id=")
                        stringUrl.append(String(cast_id))
                        stringUrl.append("&file_name=")
                        stringUrl.append(file_name)
                        
                        // Swift4からは書き方が変わりました。
                        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
                        //let decodedString:String = text.removingPercentEncoding!
                        let req = URLRequest(url: url)
                        
                        //非同期処理を行う
                        let dispatchGroup = DispatchGroup()
                        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
                        
                        dispatchGroup.enter()
                        dispatchQueue.async {
                            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                                (data, res, err) in
                                dispatchGroup.leave()//サブタスク終了時に記述
                            })
                            task.resume()
                        }
                        // 全ての非同期処理完了後にメインスレッドで処理
                        dispatchGroup.notify(queue: .main) {
                        }
                    }
                }
            }
        }
    }
}
