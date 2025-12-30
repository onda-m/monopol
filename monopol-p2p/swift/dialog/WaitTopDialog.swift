//
//  WaitTopDialog.swift
//  swift_skyway
//
//  Created by onda on 2018/06/03.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class WaitTopDialog: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var waitImageView: UIImageView!
    @IBOutlet weak var screenshotImageView: EnhancedCircleImageView!
    
    // 画像がタップされたら呼ばれる
    @objc func waitTap(_ sender: UITapGestureRecognizer) {
        //写真が登録されているかの判断
        let photoFlg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
        
        if(photoFlg == 1){
            //写真が登録されていたら配信待機のトップ画面へ
            //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
            UserDefaults.standard.set(3, forKey: "selectedMenuNum")
            UtilToViewController.toWaitTopViewController()
        }else{
            //写真が登録されていない場合
            self.showAlert()
        }
    }
    
    @objc func showAlert(){
        //UIAlertControllerを用意する
        let actionAlert = UIAlertController(title: "プロフィール写真をアップロードしてください", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "写真をアップロード", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            // アルバム(Photo liblary)の閲覧権限の確認
            //Util.checkPermission()
            /*
            //これは正常に動作しない
            let photoLibraryManager = PhotoLibraryManager.init(parentViewController: self.parentViewController()!)
            
            //photoLibraryManager.requestAuthorizationOn()
            photoLibraryManager.callPhotoLibrary()
            */
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
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
                let imagePicker = UIImagePickerController()
                //imagePicker.delegate = (self.parentViewController() as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                imagePicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                
                // 下記を追加する
                imagePicker.modalPresentationStyle = .fullScreen
                
                self.parentViewController()?.present(imagePicker, animated: true, completion: nil)
           }
        })
        
        actionAlert.addAction(modifyAction)
        
        //UIAlertControllerにキャンセルのアクションを追加する
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            //print("キャンセルのシートが押されました。")
        })
        actionAlert.addAction(cancelAction)
        
        // iPadでは必須！
        actionAlert.popoverPresentationController?.sourceView = self.parentViewController()!.view
        
        // ここで表示位置を調整。xは画面中央、yは画面下部になる様に指定
        let screenSize = UIScreen.main.bounds
        actionAlert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // 下記を追加する
        actionAlert.modalPresentationStyle = .fullScreen
        
        //アクションを表示する
        self.parentViewController()?.present(actionAlert, animated: true, completion: nil)
    }

    //画像のアップロード処理
    //アップロードした画像そのものと、プロフィール用画像と、リスト用画像の３種類を保存する。
    //それぞれ、.jpg _profile.jpg _list.jpg
    //cropThumbnailImage(image :UIImage, w:Int, h:Int)
    func imageUpload(image: UIImage, user_id: Int) {
        
        let file_name_temp = UtilFunc.getNowClockString(flg:1)

        //画像のサイズ変更(プロフィール画像)
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        let profileImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.USER_PROFILE_PHOTO_WIDTH), height:Double(Util.USER_PROFILE_PHOTO_HEIGHT))
        if let profiledata = profileImage.pngData() {
            let fileName = file_name_temp + "_profile.jpg"
            //let body = Util.httpBody(profiledata,fileName: fileName)
            let body = UtilFunc.httpBodyAlpha(profiledata, fileName: fileName, castId: "0", userId: String(user_id))

            //let url = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_PHOTO)!, data: body) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        //print("Upload done")
                        //ボタンの背景に選択した画像を設定
                        //self.userImageView.image = profileImage
                    } else {
                        //print(response.statusCode)
                    }
                }
            }
        }
        
        //画像のサイズ変更(個別用の画像)
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        //let orgImage = Util.resizeImage(image :image, w:Int(Util.USER_ORG_PHOTO_WIDTH), h:Int(Util.USER_ORG_PHOTO_HEIGHT))
        let orgImage = UtilFunc.resizeImage(image :image, width:Double(Util.USER_ORG_PHOTO_WIDTH), height:Double(Util.USER_ORG_PHOTO_HEIGHT))
        if let orgdata = orgImage.pngData() {
            let orgfileName = file_name_temp + ".jpg"
            //let orgbody = Util.httpBody(orgdata, fileName: orgfileName)
            let orgbody = UtilFunc.httpBodyAlpha(orgdata, fileName: orgfileName, castId: "0", userId: String(user_id))

            //let orgurl = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_PHOTO)!, data: orgbody) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        print("Upload done")
                    } else {
                        print("Upload error")
                        print(response.statusCode)
                    }
                }
            }
        }
        
        //画像のサイズ変更(リスト画像)
        //let listImage = Util.resizeImage(image :image, w:Int(Util.USER_LIST_PHOTO_WIDTH), h:Int(Util.USER_LIST_PHOTO_HEIGHT))
        //画像のサイズ変更(リスト画像)
        let listImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.USER_LIST_PHOTO_WIDTH), height:Double(Util.USER_LIST_PHOTO_HEIGHT))
        
        // UIImagePNGRepresentationでUIImageをNSDataに変換
        if let listdata = listImage.pngData() {
            let listfileName = file_name_temp + "_list.jpg"
            //let listbody = Util.httpBody(listdata,fileName: listfileName)
            let listbody = UtilFunc.httpBodyAlpha(listdata,fileName: listfileName, castId: "0", userId: String(user_id))
            
            //let listurl = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_PHOTO)!, data: listbody) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        //print("Upload done")
                        //photo_flgを更新する
                        UtilFunc.modifyPhotoFlg(user_id:user_id, photo_flg:1, photo_name: file_name_temp)
                        
                        UserDefaults.standard.set(1, forKey: "myPhotoFlg")
                        UserDefaults.standard.set(file_name_temp, forKey: "myPhotoName")
                        
                        //うまく遷移できないためコメントアウト
                        //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                        //UserDefaults.standard.set(3, forKey: "selectedMenuNum")
                        //Util.toWaitTopViewController()
                    } else {
                        //print(response.statusCode)
                    }
                }
            }
        }
        self.parentViewController()?.dismiss(animated: true, completion: nil)
    }
    
    
    //UIImagePickerControllerのデリゲートメソッド
    //画像が選択された時に呼ばれる.
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
    /*
    //UIImagePickerControllerのデリゲートメソッド
    //画像が選択された時に呼ばれる.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
    */
            //サーバーに転送
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            imageUpload(image: image, user_id: user_id)
        } else{
            print("Error")
        }
        // モーダルビューを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //キャンセルした時、アルバム画面を閉じます
        picker.dismiss(animated: true, completion: nil);
        print("cancel")
    }
    
    // 画像がタップされたら呼ばれる
    @objc func screenshotManageTap(_ sender: UITapGestureRecognizer) {
        //スクショ管理画面へ
        //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
        UserDefaults.standard.set(3, forKey: "selectedMenuNum")
        UtilToViewController.toScreenshotViewController()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //ここで1度目の権限確認（必要）
        UtilFunc.checkPermission()
        //self.checkPermissionMicrophone()
        //UtilFunc.checkPermissionCamera()
        
        waitImageView.isUserInteractionEnabled = true
        waitImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.waitTap(_:))))
        
        screenshotImageView.isUserInteractionEnabled = true
        screenshotImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.screenshotManageTap(_:))))
    }
    
    func waitTopDialogSetting(){
        // ポップアップビュー背景色
        let viewColor = UIColor.black
        // 半透明にして親ビューが見えるように。透過度はお好みで。
        self.backgroundColor = viewColor.withAlphaComponent(0.85)
    }

    func close() {
        self.removeFromSuperview()
    }
    
    // メニュー外をタップした場合に非表示にする
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        //self.dismiss(animated: true, completion: nil)
        
        //var i = 0
        for touch in touches {
            if touch.view?.tag == 1 {
                self.close()
                /*
                 print("touch")
                 i = 1
                 UIView.animate(
                 withDuration: 0.2,
                 delay: 0,
                 options: .curveEaseIn,
                 animations: {
                 self.menuView.layer.position.x = -self.menuView.frame.width
                 },
                 completion: { bool in
                 self.close()
                 }
                 )*/
            }
        }
    }
}
