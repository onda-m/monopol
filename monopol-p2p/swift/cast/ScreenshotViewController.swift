//
//  ScreenshotViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import AVFoundation
//import Firebase
//import FirebaseDatabase
//import FirebaseStorage

//未使用（スクショ機能は廃止）
//スクショ管理の画面　→ スクショを撮り保存するまでの処理
//参考
//https://i-app-tec.com/ios/camera.html
class ScreenshotViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,AVCapturePhotoCaptureDelegate {

    let iconSize: CGFloat = 20.0
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    struct UserResult: Codable {
        let id: String
        let user_id: String
        let file_name: String
        let value01: String
        let value02: String
        let value03: String
        let value04: String
        let value05: String
        let status: String
        let ins_time: String
        let mod_time: String
    }
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }
    var idCount:Int=0
    
    var screenshotList: [(id:String, user_id:String, file_name:String, value01:String, value02:String, value03:String, value04:String, value05:String, status:String, ins_time:String, mod_time:String)] = []
    var screenshotListTemp: [(id:String, user_id:String, file_name:String, value01:String, value02:String, value03:String, value04:String, value05:String, status:String, ins_time:String, mod_time:String)] = []
    
    // デバイス
    var device: AVCaptureDevice!
    // セッション
    var session: AVCaptureSession!
    // 画像のアウトプット
    var output: AVCapturePhotoOutput!
    // プレビューレイヤ
    var previewLayer: CALayer!
    //キャプチャするときのツールバー
    var captureToolbar: UIToolbar!
    
    // スクショ画像の名前
    //let photos = ["demo01","demo02","demo03","demo04","demo05","demo06","demo07","demo08","demo09"]
    //var photoUrls: [String] = []
    var selectedId:Int=0
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var screenshotBtn: UIButton!
    @IBOutlet weak var screenshotNotesLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        screenshotNotesLbl.text = Util.SCREENSHOT_MANAGE_DIALOG_SEND_STR
        screenshotNotesLbl.isHidden = false
        
        // 枠線の色
        screenshotBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
        // 枠線の太さ
        screenshotBtn.layer.borderWidth = 1
        // 角丸
        screenshotBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        screenshotBtn.layer.masksToBounds = true
        screenshotBtn.setTitleColor(Util.LIVE_WAIT_STRING_COLOR, for: .normal)
        
        // Do any additional setup after loading the view.
        // ツールバー本体のインスタンス化
        captureToolbar = UIToolbar(frame: CGRect(
            x: 0,
            y: self.view.bounds.size.height - Util.TAB_BAR_HEIGHT,
            width: self.view.bounds.size.width,
            height: Util.TAB_BAR_HEIGHT)
        )
        
        //キャプチャ時のツールバー
        // ツールバースタイルの設定
        captureToolbar.barStyle = .default
        // ボタンのサイズ
        let buttonSize: CGFloat = 24
        // 閉じるボタン(スクリーンショット管理画面へ)
        let closeBrowserButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        closeBrowserButton.setBackgroundImage(UIImage(named: "to_screenshot_file"), for: UIControl.State())
        closeBrowserButton.addTarget(self, action: #selector(self.onClickClose(_:)), for: .touchUpInside)
        let closeBrowserButtonItem = UIBarButtonItem(customView: closeBrowserButton)
        
        // 撮影ボタン
        let cameraButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        cameraButton.setBackgroundImage(UIImage(named: "to_shutter"), for: UIControl.State())
        cameraButton.addTarget(self, action: #selector(self.onClickCamera(_:)), for: .touchUpInside)
        let cameraButtonItem = UIBarButtonItem(customView: cameraButton)
        // 進むボタン
        //let forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        //forwardButton.setBackgroundImage(UIImage(named: "arrow_sharp_right"), for: UIControlState())
        //forwardButton.addTarget(self, action: #selector(self.onClickForward(_:)), for: .touchUpInside)
        //let forwardButtonItem = UIBarButtonItem(customView: forwardButton)

        // 余白を設定するスペーサー
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        // ツールバーにアイテムを追加する.
        captureToolbar.items = [closeBrowserButtonItem, flexibleItem, cameraButtonItem, flexibleItem]
        // ツールバーを追加
        self.view.addSubview(captureToolbar)
        captureToolbar.isHidden = true
        
    }

    func getScreenshotList(){
        //クリアする
        //self.screenshotList.removeAll()
        self.screenshotListTemp.removeAll()
        
        var stringUrl = Util.URL_GET_SCREENSHOT_LIST
        stringUrl.append("?status=1&order=1&user_id=")
        stringUrl.append(String(self.user_id))

        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    let json = try decoder.decode(ResultJson.self, from: data!)
                    self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strId = obj.id
                        let strUserId = obj.user_id
                        let strFileName = obj.file_name
                        let strValue01 = obj.value01
                        let strValue02 = obj.value02
                        let strValue03 = obj.value03
                        let strValue04 = obj.value04
                        let strValue05 = obj.value05
                        let strStatus = obj.status
                        let strInsTime = obj.ins_time
                        let strModTime = obj.mod_time
                        
                        let screenshot = (strId,strUserId,strFileName,strValue01,strValue02,strValue03,strValue04,strValue05,strStatus,strInsTime,strModTime)
                        //配列へ追加
                        self.screenshotList.append(screenshot)
                        self.screenshotListTemp.append(screenshot)
                    }
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //コピーする
            self.screenshotList = self.screenshotListTemp
            
            //リストの取得を待ってから更新
            self.mainCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getScreenshotList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapScreenshotBtn(_ sender: Any) {
        // セッションを生成
        session = AVCaptureSession()
        // バックカメラを選択
        //device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        //device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        // バックカメラからキャプチャ入力生成
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("Caught exception!")
            return
        }
        
        session.addInput(input)
        output = AVCapturePhotoOutput()
        session.addOutput(output)
        session.sessionPreset = .photo
        // プレビューレイヤを生成
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        //previewLayer.frame = self.view.frame
        view.layer.addSublayer(previewLayer)
        // セッションを開始
        session.startRunning()
        
        //ツールバーを表示する
        captureToolbar.isHidden = false
        screenshotNotesLbl.isHidden = true
    }

    // 撮影ボタンをクリックした時の処理
    @objc func onClickCamera(_ sender: UIButton) {
        //print("タップ")
        takeStillPicture()
    }
    
    // 閉じるボタンをクリックした時の処理
    @objc func onClickClose(_ sender: UIButton) {
        //print("閉じるボタンがクリックされた")
        /*
         // self.viewの上に乗っているオブジェクトを順番に取得する
         for v in view.subviews {
         // オブジェクトの型がUIImageView型で、タグ番号が1〜5番のオブジェクトを取得する
         if let v = v as? UIImageView, v.tag >= 90 && v.tag <= 99  {
         // そのオブジェクトを親のviewから取り除く
         v.removeFromSuperview()
         }
         }
         */
        
        //view.layer.isHidden = true
        //view.removeFromSuperview()
        //self.dismiss(animated: true, completion: nil)
        // カメラの停止とメモリ解放.
        self.session.stopRunning()
        for output in self.session.outputs
        {
            self.session.removeOutput(output)
        }
        for input in self.session.inputs
        {
            self.session.removeInput(input)
        }
        self.session = nil
        self.device = nil
        
        
        //隠れる？
        previewLayer.isHidden = true
        
        // ツールバーを非表示
        captureToolbar.isHidden = true
        screenshotNotesLbl.isHidden = false
        
        self.getScreenshotList()
    }
    
    func takeStillPicture(){
        let photoSettings = AVCapturePhotoSettings()
        //frontの場合は、下記の設定をするとアプリが落ちる
        //photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        output?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    //　撮影が完了した時に呼ばれる
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // AVCapturePhotoOutput.jpegPhotoDataRepresentation deprecated in iOS11
        let imageData = photo.fileDataRepresentation()

        let photo = UIImage(data: imageData!)
        // アルバムに追加.
        //UIImageWriteToSavedPhotosAlbum(photo!, self, nil, nil)
        
        self.appDelegate.pickedImage = photo
        //写真ダイアログを表示(配信中のスクリーンショット画面を使いまわす)
        let castScreenshotDialog:CastScreenshotDialog = UINib(nibName: "CastScreenshotDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! CastScreenshotDialog
        //画面サイズに合わせる
        castScreenshotDialog.frame = self.view.frame

        // 貼り付ける
        self.view.addSubview(castScreenshotDialog)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        //let cellImage = UIImage(named: photos[indexPath.row])
        
        //画像キャッシュを使用
        let temp_url = "screenshot/" + String(self.user_id) + "/" + screenshotList[indexPath.row].file_name + "_list.jpg"
        imageView.setImageListByPINRemoteImage(ratio: 0.0, path: temp_url, no_image_named:"demo_noimage")
        /*
        UIImage.contentOfFIRStorage(path: photoUrls[indexPath.row]) { image in
            imageView.image = image?.resizeUIImageRatio(ratio: 50.0)
        }
        */

        // UIImageをUIImageViewのimageとして設定
        //imageView.image = cellImage
        
        // 角丸
        imageView.layer.cornerRadius = 6
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        imageView.layer.masksToBounds = true
        
        /*
         // Tag番号を使ってLabelのインスタンス生成
         let label = testCell.contentView.viewWithTag(2) as! UILabel
         label.text = strNames[indexPath.row]
         
         //影をつける
         testCell.layer.masksToBounds = false //必須
         testCell.layer.shadowOffset = CGSize(width: 1, height: 1)
         testCell.layer.shadowOpacity = 0.9
         testCell.layer.shadowRadius = 2.0
         */
        
        //print("table create")
        return testCell
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = view.frame.width / 4 - 16
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    /////////追加(ここから)////////////////////////////
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //選択中のセルの画像を取得する。
        //let index = collectionView.indexPathsForSelectedItems?.first
        //selectedId = index![1]
        //print(selectedId)
        //let modelInfo: MainTelViewController = self.storyboard!.instantiateViewController(withIdentifier: "toMainTelViewController") as! MainTelViewController
        
        //モデルのpeerIdを次の画面（モデル詳細画面）へ渡す
        //modelInfo.sendId = strPeerIds[selectedId]
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.sendId = strPeerIds[selectedId]
        
        // 下記を追加する
        //modelInfo.modalPresentationStyle = .fullScreen
        
        //present(modelInfo, animated: false, completion: nil)
        
        //選択中のセルの画像を取得する。
        //let index = collectionView.indexPathsForSelectedItems?.first
        //selectedId = index![1]
        //print(selectedId)
        //マイコレクションの個別画面へ渡す
        appDelegate.myCollectionType = "2"
        appDelegate.myCollectionSelectId = screenshotList[indexPath.row].id
        appDelegate.myCollectionSelectCastId = String(self.user_id)//自分のID
        appDelegate.myCollectionSelectCastName = UserDefaults.standard.string(forKey: "myName")!//自分の名前
        appDelegate.myCollectionSelectInsTime = screenshotList[indexPath.row].ins_time
        appDelegate.myCollectionSelectPhotoFileName = screenshotList[indexPath.row].file_name
        
        UtilToViewController.toCollectionImageViewController(animated_flg:false)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        return idCount;
    }
}
