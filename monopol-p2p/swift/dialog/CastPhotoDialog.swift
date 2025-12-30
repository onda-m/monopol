//
//  CastPhotoDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/05/17.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

//参考
//https://i-app-tec.com/ios/camera.html
class CastPhotoDialog: UIView {

    var coverView: UIView!//キーボード以外を覆うVIEW
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var textLbl: UILabel!
    
    @IBOutlet weak var photoImage: UIImageView!

    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var retakeBtn: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var user_id :Int = 0
    
    // データベースへの参照
    var rootRef = Database.database().reference()
    var conditionRef = DatabaseReference()
    var handle = DatabaseHandle()
    
    //相手のコインチェック用
    struct CoinCheckResult: Codable {
        let point: String
    }
    struct ResultCoinCheckJson: Codable {
        let count: Int
        let result: [CoinCheckResult]
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code

        if(self.appDelegate.pickedImage != nil){
            //imageから（カメラから撮影した画像）反転する
            photoImage.image = appDelegate.pickedImage
            
            // 画像を反転
            var transMiller = CGAffineTransform()
            transMiller = CGAffineTransform(scaleX: -1.0, y: 1.0)
            photoImage.transform = transMiller
        }else{
            //URLから
            //すでにサーバーに保存している画像（反転しない）
            //画像キャッシュを使用
            photoImage.setImageListByPINRemoteImage(ratio: 0.0, path: self.appDelegate.pickedImageUrl!, no_image_named:"no_image")
            
            // 画像を反転しない
            var transMiller = CGAffineTransform()
            transMiller = CGAffineTransform(scaleX: 1.0, y: 1.0)
            photoImage.transform = transMiller
        }

        //自分のuser_idを指定
        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        // 角丸
        //textLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //textLbl.layer.masksToBounds = true
        
        //ラベルの枠を自動調節する
        textLbl.adjustsFontSizeToFitWidth = true
        textLbl.minimumScaleFactor = 0.3
        textLbl.text = Util.SCREENSHOT_DIALOG_SEND_STR
        
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
        
        if coverView == nil {
            coverView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            // coverViewの背景
            coverView.backgroundColor = UIColor.black
            // 透明度を設定
            coverView.alpha = 0.1
            coverView.isUserInteractionEnabled = true
            self.addSubview(coverView)
        }
        coverView.isHidden = false
        self.bringSubviewToFront(mainView)
    }

    @IBAction func sendDo(_ sender: Any) {
        //画像を送信する
        let user_id_target: Int = appDelegate.live_target_user_id//送信先

        //Util.SCREENSHOT_PAY_COINをユーザーが持っているかどうかの判断
        var pointTemp:String = "0"//相手のコイン数の取得格納用
        
        var stringUrl = Util.URL_COIN_CHECK_DO
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id_target))
        //print(stringUrl)

        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        //var json_result :ResultJson? = nil

        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultCoinCheckJson.self, from: data!)
                    //self.idCount = json.count

                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        pointTemp = obj.point
                        break
                    }
                    
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(Double(pointTemp)! < Util.SCREENSHOT_PAY_COIN){
                //コインが足りない場合
                UtilFunc.showAlert(message:"相手のコインが足りないため、スクショを送信できませんでした。", vc:self.parentViewController()!, sec:2.0)
                
                self.photoImage.image = nil
                self.appDelegate.pickedImage = nil
                self.removeFromSuperview()
            }else{
                if(self.user_id != user_id_target && self.user_id > 0 && user_id_target > 0){
                    //重要(リアルタイムデータベースを使用)
                    self.conditionRef = self.rootRef.child(Util.INIT_FIREBASE + "/"
                        + String(self.user_id) + "/" + String(user_id_target))
                    self.imageSend(image: self.photoImage.image!, cast_id: self.user_id, user_id: user_id_target)
                }
                
                self.photoImage.image = nil
                self.appDelegate.pickedImage = nil
                self.removeFromSuperview()
            }
        }
    }

    @IBAction func retakeDo(_ sender: Any) {
        self.photoImage.image = nil
        self.appDelegate.pickedImage = nil
        removeFromSuperview()
    }
    
    //画像の送信処理
    //mycollection/cast_id/user_id/.jpg
    func imageSend(image: UIImage, cast_id: Int, user_id: Int) {
        // 画像のupload
        //let storage = Storage.storage()
        //let storageRef = storage.reference(forURL: Util.URL_FIREBASE)
        
        let now = NSDate()
        let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")//重要
        formatter.dateFormat = "yyyyMMddHHmmss"
        //formatter.setLocalizedDateFormatFromTemplate("yyyyMMddHHmmss")
        let db_file_name = formatter.string(from: now as Date)
        let file_name = db_file_name + ".jpg"
        let list_name = db_file_name + "_list.jpg"
        
        //画像のサイズ変更(個別用の画像)
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        //let orgImage = Util.resizeImage(image :image, w:Int(Util.MYCOLLECTION_PHOTO_WIDTH), h:Int(Util.MYCOLLECTION_PHOTO_HEIGHT))
        let orgImage = UtilFunc.resizeImage(image :image, width:Double(Util.MYCOLLECTION_PHOTO_WIDTH), height:Double(Util.MYCOLLECTION_PHOTO_HEIGHT))
        if let orgdata = orgImage.pngData() {
            
            //var orgfileName = file_name
            //let reference = storageRef.child("mycollection/" + String(user_id) + "/" + String(cast_id) + "/" + file_name)
            
            let orgbody = UtilFunc.httpBodyAlpha(orgdata, fileName: file_name, castId: String(cast_id), userId: String(user_id))
            //let orgurl = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_MYCOLLECTION_PHOTO)!, data: orgbody) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        //print("Upload done")
                        
                        //画像のサイズ変更(リスト画像)
                        let listImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.MYCOLLECTION_LIST_PHOTO_WIDTH), height:Double(Util.MYCOLLECTION_LIST_PHOTO_HEIGHT))
                        // UIImagePNGRepresentationでUIImageをNSDataに変換
                        if let listdata = listImage.pngData() {
                            
                            //var listfileName = list_name
                            //let saveListUrl = "mycollection/" + String(user_id) + "/" + String(cast_id) + "/" + list_name
                            
                            let listbody = UtilFunc.httpBodyAlpha(listdata, fileName: list_name, castId: String(cast_id), userId: String(user_id))
                            //let listbody = Util.httpBody(listdata,fileName: listfileName)
                            //let listurl = URL(string: Util.URL_SAVE_PHOTO)!
                            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_MYCOLLECTION_PHOTO)!, data: listbody) {(data, response, error) in
                                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                                    if response.statusCode == 200 {
                                        //print("Upload done")
                                        //画像の送信が終わった場合
                                        //DBに情報を保存
                                        self.writeMycollectionDb(file_name: db_file_name, cast_id: cast_id, user_id: user_id)
                                    } else {
                                        //print(response.statusCode)
                                    }
                                }
                            }
                        }
                    } else {
                        //print("Upload error")
                        //print(response.statusCode)
                    }
                }
            }
        }
    }
    
    func writeMycollectionDb(file_name: String, cast_id: Int, user_id: Int) {
        var stringUrl = Util.URL_MYCOLLECTION_SAVE
        stringUrl.append("?status=3&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&file_name=")
        stringUrl.append(file_name)
        
        //print(stringUrl)
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
                //do{
                //print(json.result)
                dispatchGroup.leave()//サブタスク終了時に記述
                //}catch{
                //エラー処理
                //print("エラーが出ました")
                //print("json convert failed in JSONDecoder", err?.localizedDescription)
                //}
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //くるくる表示終了
            //self.busyIndicator.removeFromSuperview()
            //request_screenshot_nameにファイル名(yyyyMMddHHmmss)を入れる
            //スクショをユーザーに送信(受け取りの承認をユーザーが行う)
            let data = ["request_screenshot_flg": 2, "request_screenshot_name": file_name] as [String : Any]
            self.conditionRef.updateChildValues(data)
        }
    }
}
