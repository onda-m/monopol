//
//  MovieSettingViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/07/20.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
//import FirebaseStorage
import MobileCoreServices
import AVFoundation

class MovieSettingViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // 画像のupload・表示用
    //let storageRef = Storage.storage().reference(forURL: Util.URL_FIREBASE)
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapMovieSelectBtn(_ sender: Any) {
        // アルバム(Photo liblary)の閲覧権限の確認
        //UtilFunc.checkPermission()
        //UtilFunc.checkPermissionAlbumn()
        //callPhotoLibraryForMovie
        
        let photoLibraryManager = PhotoLibraryManager.init(parentViewController: self)
        //photoLibraryManager.requestAuthorizationOn()
        photoLibraryManager.callPhotoLibraryForMovie()
        
        /*
        // カメラロールを表示
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
            controller.mediaTypes=[kUTTypeMovie as String] // 動画のみ
            controller.delegate = self
            controller.allowsEditing = true
            controller.videoMaximumDuration = 7 // 7秒で動画を切り取る
            controller.videoQuality = UIImagePickerController.QualityType.typeHigh // カメラのハイクォリティのサイズで取得する
            
            // 下記を追加する
            controller.modalPresentationStyle = .fullScreen
         
            self.present(controller, animated: true, completion: nil)
        }*/

        /*
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){

            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            //imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.allowsEditing = true
            // 下記を追加する
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)

            //imagePicker.delegate = self
            //imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            //imagePicker.mediaTypes = [kUTTypeMovie] // ここで動画を指定する。
            //imagePicker.allowsEditing = false
            //imagePicker.showsCameraControls = true
        }
         */
    }
    
    /*
    //動画選択時にサーバーへアップロードする処理
    func movieUpload(user_id: Int) {
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
        }
    }
    */
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        //if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
        
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            /*
            //サーバーにアップロードする
            // Create a root reference
            let fileName = "cast_movies/tmpVideo.mp4"
            let mountainsRef = self.storageRef.child(fileName);
            //var file = ... // use the Blob or File API
            mountainsRef.putFile(from: url as URL)
            */
            
            //くるくる表示開始
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.busyIndicator)
            
            // 一時保持用のパス
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentationDirectory, .userDomainMask, true)[0] as String
            let fileName = "tmpVideo_monopol.mp4"
            let videoPath = documentsPath + fileName
            let out: NSURL = NSURL.fileURL(withPath: videoPath) as NSURL
            
            // MOV→MP4に変換
            self.converVideo(inputURL: url, outputURL: out, handler: { (exportSession: AVAssetExportSession) in
                if (exportSession.status == AVAssetExportSession.Status.completed) {
                    // カメラロールに保存する
                    UISaveVideoAtPathToSavedPhotosAlbum(out.path!, self, #selector(self.showResultOfSaveMovie(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //ローカルへの保存が終わったら、サーバーにアップロードして、ローカルのファイルを削除して終了
    @objc func showResultOfSaveMovie(_ video: NSString, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
    //@objc func videoSaveEnd(out: NSURL) {
        //if (error != nil) {
            //print("video saving fails")
            //myLabel.text = "video saving fails"
        //} else {
            //print("video saving success")
        //サーバーにアップロードする
        //アップロード時のファイル名
        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //let upload_fileName = "cast_movies/" + String(user_id) + ".mp4"
        //let upload_fileName = Util.URL_USER_MOVIE_BASE + String(user_id) + ".mp4"

        //ローカル保存したファイルへのパス
        let out: URL = NSURL.fileURL(withPath: video as String)

        let file_name_temp = UtilFunc.getNowClockString(flg:1)
        let fileName = file_name_temp + ".mp4"

        //let fileNameWithoutExt = (fileName as NSString).deletingPathExtension
        //let ext = (fileName as NSString).pathExtension
        // UIImageからJPEGに変換してアップロード
        //let imageData = UIImageJPEGRepresentation(UIImage(named: fileName)!, 1.0)!
        // 読み込んだファイルをそのままアップロード
        //let imageData = try! Data(contentsOf: Bundle.main.url(forResource: fileNameWithoutExt, withExtension: ext)!)
        let movieData = try! Data(contentsOf: out)
        //let body = Util.httpBody(movieData,fileName: fileName)
        let body = UtilFunc.httpBodyAlpha(movieData, fileName: fileName, castId: "0", userId: String(user_id))
        let url = URL(string: Util.URL_SAVE_CAST_MOVIE)!
        
        UtilFunc.fileUpload(url, data: body) {(data, response, error) in
            if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                if response.statusCode == 200 {
                    
                    //print("Upload done")
                    do {
                        //movie_flgを更新
                        self.modifyMovieFlg(movie_flg:1, movie_name:file_name_temp)
                        UserDefaults.standard.set(1, forKey: "myMovieFlg")
                        
                        UtilFunc.showAlert(message:"動画のアップロードが完了しました", vc:self, sec:2.0)
                        
                        //下記は正常に動作しない（ローカルの動画ファイルを消せない？）
                        try FileManager.default.removeItem(at: out)
                    } catch _ {
                    }
                } else {
                    print(response.statusCode)
                }
                
            }
        }

        /*
        // Create a root reference
        let mountainsRef = self.storageRef.child(upload_fileName)
        //var file = ... // use the Blob or File API
        mountainsRef.putFile(from: out as URL, metadata: nil) { metadata, error in
            //guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            //    return
            //}
            // Metadata contains file metadata such as size, content-type.
            //let size = metadata.size
            // You can also access to download URL after upload.
            //storageRef.downloadURL { (url, error) in
            //    guard let downloadURL = url else {
            // Uh-oh, an error occurred!
            //        return
            //    }
            //}
            do {
                try FileManager.default.removeItem(at: out as URL)
                
                //movie_flgを更新
                self.modifyMovieFlg(movie_flg:1)
                UserDefaults.standard.set(1, forKey: "myMovieFlg")
            } catch _ {
            }
        }
        //}
        */
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func converVideo(inputURL: NSURL, outputURL: NSURL, handler: @escaping (_ exportSession: AVAssetExportSession) -> Void) {
        do {
            // ファイルがあれば削除
            try FileManager.default.removeItem(at: outputURL.absoluteURL!)
        }
        catch _ {
            
        }
        let asset:AVURLAsset = AVURLAsset.init(url: inputURL.absoluteURL!, options: nil)
        let exportSession:AVAssetExportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputURL = outputURL.absoluteURL
        exportSession.outputFileType = kUTTypeMPEG4 as AVFileType
        //AVFileTypeMPEG4// MP4形式出力
        
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            handler(exportSession);
        })
    }
    
    //movie_flgを更新する
    func modifyMovieFlg(movie_flg:Int, movie_name:String){
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        var stringUrl = Util.URL_MODIFY_MOVIE_FLG
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&movie_flg=")
        stringUrl.append(String(movie_flg))
        stringUrl.append("&movie_name=")
        stringUrl.append(movie_name)
        
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
            
            //くるくる表示終了
            //self.busyIndicator.isHidden = true
            self.busyIndicator.removeFromSuperview()
        }
    }
}
