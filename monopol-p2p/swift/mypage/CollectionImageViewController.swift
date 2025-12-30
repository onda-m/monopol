//
//  CollectionImageViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/04.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class CollectionImageViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // スクショ画像の名前
    //let photos = ["demo01","demo02","demo03","demo04","demo05","demo06","demo07","demo08","demo09"]
    //var photoUrl: String = "mycollection/11/22/1.jpg"
    var photoUrl: String = ""
    
    @IBOutlet weak var mainImageView: UIImageView!

    var tapFlg: Int = 0// 0:画面がタップされていない（ツールバーなどを表示）
    
    @IBOutlet weak var photoInsTimeLbl: UILabel!
    @IBOutlet weak var photoInsTimeView: UIView!

    let mainToolbarView:Maintoolbarview = UINib(nibName: "Maintoolbarview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Maintoolbarview
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /***********************************************************/
        //  MenuToolbar
        /***********************************************************/
        mainToolbarView.isHidden = false
        mainToolbarView.toolbarViewSetting()
        //画面サイズに合わせる
        mainToolbarView.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(mainToolbarView)
        /***********************************************************/
        /***********************************************************/
        
        /*
        appDelegate.myCollectionSelectId = mycollectionList[indexPath.row].id
        appDelegate.myCollectionSelectCastName = mycollectionList[indexPath.row].cast_name
        appDelegate.myCollectionSelectInsTime = mycollectionList[indexPath.row].ins_time
        appDelegate.myCollectionSelectPhotoFileName = mycollectionList[indexPath.row].file_name
        */
        
        // Do any additional setup after loading the view.

        //自分のIDを取得
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let collection_type: String = appDelegate.myCollectionType!
        let cast_id: String = appDelegate.myCollectionSelectCastId!
        let cast_name: String = appDelegate.myCollectionSelectCastName!
        let photo_file_name = appDelegate.myCollectionSelectPhotoFileName
        
        if(collection_type == "1"){
            //1:マイコレクション
            photoUrl = "mycollection/" + String(user_id) + "/" + String(cast_id) + "/" + photo_file_name! + ".jpg"
        }else if(collection_type == "2"){
            //2:スクリーンショット
            photoUrl = "screenshot/" + String(user_id) + "/" + photo_file_name! + ".jpg"
        }else if(collection_type == "3"){
            //3:タイムライン
            photoUrl = "timeline/" + cast_id + "/" + photo_file_name! + ".jpg"
        }else if(collection_type == "4"){
            //4:トーク(自分の写真)
            photoUrl = "talk/" + String(user_id) + "/" + String(cast_id) + "/" + photo_file_name! + ".jpg"
        }else if(collection_type == "5"){
            //5:トーク(相手の写真)
            photoUrl = "talk/" + String(cast_id) + "/" + String(user_id) + "/" + photo_file_name! + ".jpg"
        }
        
        //print(photoUrl)
        //画像キャッシュを使用
        self.mainImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
        
        self.mainImageView.isUserInteractionEnabled = true
        self.mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:))))
        
        self.photoInsTimeLbl.text = "■ " + self.appDelegate.myCollectionSelectInsTime!
        self.photoInsTimeLbl.textColor = UIColor.white
        
        //print(cast_name + "の写真")
        mainToolbarView.monopolBtn.setTitle(UtilFunc.strMin(str:cast_name, num:Util.NAME_MOJI_COUNT_SMALL) + "の写真", for: .normal)
        /*
        // ImageViewのインスタンス生成
        UIImage.contentOfFIRStorage(path: photoUrl) { image in
            self.mainImageView.image = image
            self.mainImageView.isUserInteractionEnabled = true
            self.mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:))))
            
            self.photoInsTimeLbl.text = "■ " + self.appDelegate.myCollectionSelectInsTime!
            mainToolbarView.monopolBtn.setTitle(cast_name + "の写真", for: .normal)
        }
        */
    }
    
    // 画像がタップされたら呼ばれる
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        //print("タップ")
        if(self.tapFlg == 0){
            //1度タップされた時
            self.mainToolbarView.isHidden = true
            self.photoInsTimeView.isHidden = true
            self.tapFlg = 1
        }else{
            self.mainToolbarView.isHidden = false
            self.photoInsTimeView.isHidden = false
            self.tapFlg = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
