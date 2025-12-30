//
//  PhotoLibraryManager.swift
//  swift_skyway
//
//  Created by onda on 2018/10/21.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

//参考 https://qiita.com/tetsufe/items/9ff5fe190ee190afa1bb
import UIKit
import Foundation
import Photos
import MobileCoreServices
import AVFoundation

struct PhotoLibraryManager{
    
    var parentViewController : UIViewController!
    
    init(parentViewController: UIViewController){
        self.parentViewController = parentViewController
    }
    
    // 写真へのアクセスがOFFのときに使うメソッド
    func requestAuthorizationOn(){
        // authorization
        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.denied) {
            //アクセス不能の場合。アクセス許可をしてもらう。snowなどはこれを利用して、写真へのアクセスを禁止している場合は先に進めないようにしている。

            /*
            //アラートビューで設定変更するかしないかを聞く
            let alert = UIAlertController(title: "写真へのアクセスを許可",
                                          message: "写真へのアクセスを許可する必要があります。設定を変更してください。",
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定変更", style: .default) { (_) -> Void in
                //選択された時の処理
                //guard let _ = URL(string: UIApplication.openSettingsURLString ) else {
                //    return
                //}
                //AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: {(granted: Bool) in})

                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(settingsAction)
            
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                // ダイアログがキャンセルされた。つまりアクセス許可は得られない。
            })
            
            // iPadでは必須！
            alert.popoverPresentationController?.sourceView = self.parentViewController.view
            
            // ここで表示位置を調整。xは画面中央、yは画面下部になる様に指定
            let screenSize = UIScreen.main.bounds
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
            
            // 下記を追加する
            alert.modalPresentationStyle = .fullScreen
            
            self.parentViewController.present(alert, animated: true)
             */
            
            //20251103 onda
            // 拒否後：自動で設定アプリへ遷移せず、ユーザーが押した時だけ開く
            let alert = UIAlertController(
                title: "写真へのアクセスが必要です",
                message: "この機能を使うには写真へのアクセス許可が必要です。設定で変更できます。",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
            alert.addAction(UIAlertAction(title: "設定を開く", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })

            // ここは UIViewController の中なら self.present でOK
            self.parentViewController.present(alert, animated: true)
            //self.present(alert, animated: true)
        }
    }
    
    //フォトライブラリを呼び出すメソッド
    func callPhotoLibrary(){
        //権限の確認
        requestAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //以下を設定することで、写真選択後にiOSデフォルトのトリミングViewが開くようになる
            picker.allowsEditing = true
            
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.parentViewController.view
                popover.sourceRect = self.parentViewController.view.frame // ポップオーバーの表示元となるエリア
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
            
            // 下記を追加する
            picker.modalPresentationStyle = .fullScreen
            
            self.parentViewController.present(picker, animated: true, completion: nil)
        }
    }
    /*
    //フォトライブラリを呼び出すメソッド
    func callPhotoLibraryNoTrimView(){
        //権限の確認
        requestAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            

            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //以下を設定することで、写真選択後にiOSデフォルトのトリミングViewが開くようになる
            picker.allowsEditing = true
            
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.parentViewController.view
                popover.sourceRect = self.parentViewController.view.frame // ポップオーバーの表示元となるエリア
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }

            // 下記を追加する
            picker.modalPresentationStyle = .fullScreen
     
            self.parentViewController.present(picker, animated: true, completion: nil)
            
        }
    }
    */
    //フォトライブラリを呼び出すメソッド(動画の選択)
    func callPhotoLibraryForMovie(){
        //権限の確認
        requestAuthorizationOn()
        
        // カメラロールを表示
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
            controller.mediaTypes=[kUTTypeMovie as String] // 動画のみ
            //controller.delegate = self.parentViewController
            controller.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            controller.allowsEditing = true
            controller.videoMaximumDuration = 7 // 7秒で動画を切り取る
            controller.videoQuality = UIImagePickerController.QualityType.typeHigh // カメラのハイクォリティのサイズで取得する
            
            // 下記を追加する
            controller.modalPresentationStyle = .fullScreen
            
            self.parentViewController.present(controller, animated: true, completion: nil)
        }
        
        /*
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //以下を設定することで、写真選択後にiOSデフォルトのトリミングViewが開くようになる
            picker.allowsEditing = true
            
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.parentViewController.view
                popover.sourceRect = self.parentViewController.view.frame // ポップオーバーの表示元となるエリア
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
         
            // 下記を追加する
            picker.modalPresentationStyle = .fullScreen
         
            self.parentViewController.present(picker, animated: true, completion: nil)
        }
         */
    }
}
