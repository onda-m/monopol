//
//  NoticeViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
//import UserNotifications
import Photos
//import Alamofire
import FirebaseStorage

//通知の投稿を行う画面
class NoticeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 画像の表示用
    //let storageRef = Storage.storage().reference(forURL: Util.URL_FIREBASE)
    
    //投稿ボタン
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!//キーボードが隠れてしまう問題の対応
    private var defaultScrollOffset: CGFloat?
    
    //@IBOutlet weak var noticeTableView: UITableView!
    //@IBOutlet weak var noticeSendTextField: UITextField!
    @IBOutlet weak var noticeSendTextView: PlaceHolderTextView!
    @IBOutlet weak var noticeSendImageView: UIImageView!
    
    @IBOutlet weak var myPhotoView: EnhancedCircleImageView!//自分自身の画像
    @IBOutlet weak var closeBtn: UIButton!
    //画像選択ボタンのところ
    @IBOutlet weak var sendTextView: UIView!

    //画像選択ボタン
    @IBOutlet weak var ImageSelectBtn: UIButton!

    //画像取り消しボタン
    @IBOutlet weak var cancelImageBtn: UIButton!
    
    //タイムライン投稿完了用(id_tempは画像を送信時にファイル名で使用)
    struct ResultJson: Codable {
        let id_temp: Int
        //let result: [UserResult]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //画像がないので非表示
        cancelImageBtn.isHidden = true
        //imageviewを初期化
        self.noticeSendImageView.image = nil
        
        // 枠線の色
        sendTextView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        sendTextView.layer.borderWidth = 1
    
        // 角丸
        sendBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        sendBtn.layer.masksToBounds = true
        
        // 枠線の色
        noticeSendTextView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        noticeSendTextView.layer.borderWidth = 1
        // 角丸
        noticeSendTextView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        noticeSendTextView.layer.masksToBounds = true
        noticeSendTextView.placeHolder = "いまどうしてる？"
        noticeSendTextView.placeHolderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)

        // Do any additional setup after loading the view.
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let myPhotoFlg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
        let myPhotoName = UserDefaults.standard.string(forKey: "myPhotoName")
        
        /*
        let islandRef = storageRef.child("user_images/" + String(user_id) + ".jpg")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
                self.myPhotoView.image = UIImage(named:"no_image")
            } else {
                // Data for "images/island.jpg" is returned
                let image:UIImage? = UIImage(data: data!)
                self.myPhotoView.image = image
            }
        }
        */
        
        if(myPhotoFlg == 1){
            //写真を設定ずみ
            //let photoUrl = "user_images/" + String(user_id) + "_profile.jpg"
            let photoUrl = "user_images/" + String(user_id) + "/" + myPhotoName! + "_profile.jpg"
            
            //画像キャッシュを使用
            self.myPhotoView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")

        }else{
            self.myPhotoView.image = UIImage(named:"no_image")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /*
        //自分の告知一覧を取得
        getNoticeList()

        //テーブルの区切り線を非表示
        self.noticeTableView.separatorColor = UIColor.clear
        //self.view.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)
        //self.noticeTableView.backgroundColor = UIColor(red: 113/255, green: 148/255, blue: 194/255, alpha: 1)

        self.noticeTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.noticeTableView.rowHeight = UITableViewAutomaticDimension // Contentに合わせたセルの高さに設定
        self.noticeTableView.allowsSelection = false // 選択を不可にする
        self.noticeTableView.isScrollEnabled = true
        self.noticeTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる

        //tableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.noticeTableView.register(UINib(nibName: "MyChatViewCell", bundle: nil), forCellReuseIdentifier: "MyChat")
        
        //self.bottomView = ChatRoomInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)) // 下部に表示するテキストフィールドを設定
        
        //CollectionView.reloadData()
        
        // 枠を表示する.
        //text1.borderStyle = UITextBorderStyle.roundedRect
        */
        
        // 現状のscrollViewの高さを記憶する
        self.defaultScrollOffset = self.scrollView.contentOffset.y
        self.registObserveKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func tapCloseBtn(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func tapCancelImageBtn(_ sender: Any) {
        //キャンセルボタンを非表示
        self.cancelImageBtn.isHidden = true
        //imageviewを初期化
        self.noticeSendImageView.image = nil
    }
    
    @IBAction func tapPhotoBtn(_ sender: Any) {
        //画像の選択
        // アルバム(Photo liblary)の閲覧権限の確認
        //checkPermission()
        
        let photoLibraryManager = PhotoLibraryManager.init(parentViewController: self)
        photoLibraryManager.requestAuthorizationOn()
        photoLibraryManager.callPhotoLibrary()
        
        //if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            /*
             //PhotoLibraryから画像を選択
             picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
             //デリゲートを設定する
             picker.delegate = self
             //現れるピッカーNavigationBarの文字色を設定する
             picker.navigationBar.tintColor = UIColor.white
             //現れるピッカーNavigationBarの背景色を設定する
             picker.navigationBar.barTintColor = UIColor.gray
             */
        //    let imagePicker = UIImagePickerController()
        //    imagePicker.delegate = self
        //    imagePicker.sourceType = .photoLibrary
        //    imagePicker.allowsEditing = true
            // 下記を追加する
            //    imagePicker.modalPresentationStyle = .fullScreen
        //    self.present(imagePicker, animated: true, completion: nil)
        //}
    }
    
    //UIImagePickerControllerのデリゲートメソッド
    //画像が選択された時に呼ばれる.
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
    */
            //imageViewに画像を設定
            self.noticeSendImageView.image = image

            //自分のIDを取得
            //let user_id = UserDefaults.standard.integer(forKey: "user_id")
            
            //サーバーに転送
            //imageUpload(image: image, user_id: user_id)
            
            // 角丸
            self.noticeSendImageView.layer.cornerRadius = 10
            // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
            self.noticeSendImageView.layer.masksToBounds = true
            
            //キャンセルボタンを表示
            self.cancelImageBtn.isHidden = false
            //最前面に
            self.view.bringSubviewToFront(self.cancelImageBtn)
            
        } else{
            print("Error")
        }
        // モーダルビューを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //キャンセルした時、アルバム画面を閉じます
        picker.dismiss(animated: true, completion: nil);
        //print("cancel")
    }
    
    /*
    // アルバム(Photo liblary)の閲覧権限の確認をするメソッド
    func checkPermission(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("auth")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                }
            })
            print("not Determined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        }
    }*/
    
    @IBAction func sendDo(_ sender: Any) {
        var type_flg:Int = 0
        
        //送信ボタンを押した時
        if(self.noticeSendTextView.text == "" && self.noticeSendImageView.image == nil){
            //空の場合何もしない
            return
        }else if(self.noticeSendTextView.text == ""){
            //画像のみ投稿
            type_flg = 2
        }else if(self.noticeSendImageView.image == nil){
            //テキストのみ投稿
            type_flg = 1
        }else{
            //両方投稿
            type_flg = 3
        }
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        var stringUrl = Util.URL_NOTICE_SEND_DO
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&type=")//1:テキスト 2:画像 3:両方
        stringUrl.append(String(type_flg))
        stringUrl.append("&sendtext=")
        stringUrl.append((noticeSendTextView.text)!)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        //let decodedString:String = text.removingPercentEncoding!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    json_result = try decoder.decode(ResultJson.self, from: data!)
                    
                    //print("作成されたID")
                    //print(json.id_temp)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print("json convert failed in JSONDecoder", err?.localizedDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            if(self.noticeSendImageView.image != nil){
                //自分のuser_idを指定
                let user_id = UserDefaults.standard.integer(forKey: "user_id")
                let image:UIImage = self.noticeSendImageView.image!
                let temp_id: Int = json_result!.id_temp
                
                //画像のサイズ変更(個別用の画像)
                // UIImagePNGRepresentationでUIImageをNSDataに変換
                //let orgImage = Util.resizeImage(image :image, w:Int(Util.TIMELINE_PHOTO_WIDTH), h:Int(Util.TIMELINE_PHOTO_HEIGHT))
                let orgImage = UtilFunc.resizeImage(image :image, width:Double(Util.TIMELINE_PHOTO_WIDTH), height:Double(Util.TIMELINE_PHOTO_HEIGHT))
                if let orgdata = orgImage.pngData() {

                    var orgfileName = String(temp_id)
                    orgfileName.append(".jpg")

                    let orgbody = UtilFunc.httpBodyAlpha(orgdata, fileName: orgfileName, castId: "0", userId: String(user_id))
                    //let orgurl = URL(string: Util.URL_SAVE_PHOTO)!
                    UtilFunc.fileUpload(URL(string: Util.URL_SAVE_TIMELINE_PHOTO)!, data: orgbody) {(data, response, error) in
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
                let listImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.TIMELINE_LIST_PHOTO_WIDTH), height:Double(Util.TIMELINE_LIST_PHOTO_HEIGHT))
                // UIImagePNGRepresentationでUIImageをNSDataに変換
                if let listdata = listImage.pngData() {
                    
                    var listfileName = String(temp_id)
                    listfileName.append("_list.jpg")
                    
                    let listbody = UtilFunc.httpBodyAlpha(listdata, fileName: listfileName, castId: "0", userId: String(user_id))
                    //let listbody = Util.httpBody(listdata,fileName: listfileName)
                    //let listurl = URL(string: Util.URL_SAVE_PHOTO)!
                    UtilFunc.fileUpload(URL(string: Util.URL_SAVE_TIMELINE_PHOTO)!, data: listbody) {(data, response, error) in
                        if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                            if response.statusCode == 200 {
                                //print("Upload done")
                                //画像の送信が終わった場合
                                //タイムラインのトップに戻る。
                                UtilToViewController.toTimelineViewController()
                            } else {
                                //print(response.statusCode)
                            }
                        }
                    }
                }
            }

            //(注意)下記の処理はこの位置で処理しないといけない
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
            //キーボードを閉じる
            self.view.endEditing(true)
            //送信完了
            self.noticeSendTextView.text = ""
            //画面更新
            //self.getNoticeList()
        }
    }

    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

//MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
// MARK: UITextFieldDelegate
extension NoticeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

//tableviewの上部の空白を削除する(swift4)
// MARK: - UITableViewDelegate
extension NoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

//キーボードが隠れてしまう問題の対応
extension NoticeViewController: UITextViewDelegate {
    
    func registObserveKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.showKeyboard(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.hideKeyboard(notification:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    func unregistObserveKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification: Notification) {
        // keyboardのサイズを取得
        var keyboardFrame: CGRect = CGRect.zero
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                keyboardFrame = keyboard.cgRectValue
            }
        }

        // 画面サイズの取得
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        if self.sendTextView.frame.size.height <= keyboardFrame.size.height + 60 {
            self.scrollView.contentOffset.y = myBoundSize.height / 3 + 30
        }
        
    }
    
    @objc  func hideKeyboard(notification: Notification) {
        if let defaultOffset = self.defaultScrollOffset {
            self.scrollView.contentOffset.y = defaultOffset
        }
    }
}

/*
class NoticeTableViewCell:UITableViewCell{
    @IBOutlet weak var noticeTextLabel:UILabel!
    @IBOutlet weak var noticeImage:UIImageView!
}
*/
