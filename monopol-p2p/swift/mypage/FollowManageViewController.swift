//
//  FollowManageViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/04.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class FollowManageViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    let iconSize: CGFloat = 12.0
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var followCollectionView: UICollectionView!
    
    //フォローの一覧用(修正必要)
    struct FollowResult: Codable {
        let to_user_id: String
        let to_user_name: String
        let to_notice_text: String
        let value01: String//1:待機通知オン 2:待機通知オフ
        let mod_time: String
        let connect_level: String
        let to_photo_flg: String
        let to_photo_name: String
    }
    struct ResultFollowJson: Codable {
        let count: Int
        let result: [FollowResult]
    }
    
    var followList: [(toUserId:String, toUserName:String, toNoticeText:String, value01:String, modTime:String, connectLevel:String,toPhotoFlg:String,toPhotoName:String)] = []
    var followListTemp: [(toUserId:String, toUserName:String, toNoticeText:String, value01:String, modTime:String, connectLevel:String,toPhotoFlg:String,toPhotoName:String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.getFollowListByUser()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getFollowListByUser(){
        //クリアする
        self.followListTemp.removeAll()
        
        //リスト取得(自分以外の待機中のリストを取得)
        var stringUrl = Util.URL_GET_FOLLOW_LIST
        stringUrl.append("?from_user_id=")
        stringUrl.append(String(self.user_id))
        //print(stringUrl)
        
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
                    let json = try decoder.decode(ResultFollowJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示するリストを配列にする。
                    for obj in json.result {
                        //ブラックリストの配列にない場合はnilが返される
                        if self.appDelegate.array_black_list.index(of: Int(obj.to_user_id)!) == nil {
                            let follow = (obj.to_user_id
                                ,obj.to_user_name.toHtmlString()
                                ,obj.to_notice_text
                                ,obj.value01
                                ,obj.mod_time
                                ,obj.connect_level
                                ,obj.to_photo_flg
                                ,obj.to_photo_name)
                            //配列へ追加
                            self.followList.append(follow)
                            self.followListTemp.append(follow)
                        }
                    }
                    
                    dispatchGroup.leave()
                    //self.CollectionView.reloadData()
                    //print(json.result)
                }catch{
                    //エラー処理
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //リストの取得を待ってから更新
            //コピーする
            self.followList = self.followListTemp
            //self.CollectionView.reloadData()
            self.followCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        //キャスト画像の表示
        let castPhotoFlg = followList[indexPath.row].toPhotoFlg
        let castPhotoName = followList[indexPath.row].toPhotoName
        let castId = followList[indexPath.row].toUserId
        if(castPhotoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + castId + "_profile.jpg"
            let photoUrl = "user_images/" + castId + "/" + castPhotoName + "_profile.jpg"

            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
            //    imageView.image = image?.resizeUIImageRatio(ratio: 50.0)
            //}
            //画像キャッシュを使用
            imageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            imageView.image = cellImage
        }
        
        // Tag番号を使ってLabelのインスタンス生成
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        label.text = followList[indexPath.row].toUserName
        //ラベルの枠を自動調節する
        //label.adjustsFontSizeToFitWidth = true
        //label.minimumScaleFactor = 0.3
        
        // Tag番号を使ってLabelのインスタンス生成(絆レベル)
        let kizunaLabel = testCell.contentView.viewWithTag(3) as! UILabel
        //kizunaLabel.text = "絆Lv:" + followList[indexPath.row].connectLevel
        
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        kizunaLabel.attributedText = UtilFunc.getInsertIconString(string: followList[indexPath.row].connectLevel, iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
        
        //絆レベルのところ
        // 角丸
        kizunaLabel.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        kizunaLabel.layer.masksToBounds = true
        kizunaLabel.backgroundColor = Util.CAST_INFO_COLOR_CONNECT_LV_LABEL
        //ラベルの枠を自動調節する
        kizunaLabel.adjustsFontSizeToFitWidth = true
        kizunaLabel.minimumScaleFactor = 0.3
        
        
        //影をつける
        //testCell.layer.masksToBounds = false //必須
        //testCell.layer.shadowOffset = CGSize(width: 1, height: 1)
        //testCell.layer.shadowOpacity = 0.9
        //testCell.layer.shadowRadius = 2.0
        
        //print("table create")
        return testCell
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = view.frame.width / 3 - 4
        let height: CGFloat = width
        return CGSize(width: width, height: height)

    }
    
    /////////追加(ここから)////////////////////////////
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        self.appDelegate.sendId = followList[indexPath.row].toUserId
        UtilToViewController.toUserInfoViewController()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        //return idCount;
        return followList.count
    }
}
