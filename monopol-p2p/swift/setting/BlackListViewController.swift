//
//  BlackListViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/08/18.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class BlackListViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var blackListCollectionView: UICollectionView!

    /*
    //ブラックリストの一覧用(修正必要)
    struct BlackResult: Codable {
        let from_user_id: String
        let to_user_id: String
        let ins_time: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
    }
    struct ResultBlackJson: Codable {
        let count: Int
        let result: [BlackResult]
    }
    */
    
    var blackList: [(from_user_id:String, to_user_id:String, ins_time:String, user_name:String, photo_flg:String, photo_name:String)] = []
    var blackListTemp: [(from_user_id:String, to_user_id:String, ins_time:String, user_name:String, photo_flg:String, photo_name:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getBlackListByUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBlackListByUser(){
        //クリアする
        self.blackListTemp.removeAll()
        
        //リスト取得
        var stringUrl = Util.URL_GET_BLACKLIST
        stringUrl.append("?order=1&user_id=")
        stringUrl.append(String(self.user_id))
        print(stringUrl)
        
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
                    let json = try decoder.decode(UtilStruct.ResultBlackJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        /*
                        let strFromUserId = obj.from_user_id
                        let strToUserId = obj.to_user_id
                        let strInsTime = obj.ins_time
                        let strUserName = obj.user_name.toHtmlString()
                        let strPhotoFlg = obj.photo_flg
                        let strPhotoName = obj.photo_name
                        */
                        let black_info = (obj.from_user_id
                            ,obj.to_user_id
                            ,obj.ins_time
                            ,obj.user_name.toHtmlString()
                            ,obj.photo_flg
                            ,obj.photo_name)
                        
                        //配列へ追加
                        self.blackList.append(black_info)
                        self.blackListTemp.append(black_info)
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
            self.blackList = self.blackListTemp
            
            self.blackListCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:BlackListViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath) as! BlackListViewCell

        let imageView = testCell.blackListImageView
        //画像の表示
        let castPhotoFlg = blackList[indexPath.row].photo_flg
        let castPhotoName = blackList[indexPath.row].photo_name
        let castId = blackList[indexPath.row].to_user_id
        if(castPhotoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + castId + "_profile.jpg"
            let photoUrl = "user_images/" + castId + "/" + castPhotoName + "_profile.jpg"

            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
            //    imageView.image = image?.resizeUIImageRatio(ratio: 50.0)
            //}
            //画像キャッシュを使用
            imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            imageView?.image = cellImage
        }

        let label = testCell.userName
        label?.text = blackList[indexPath.row].user_name
        //ラベルの枠を自動調節する
        //label.adjustsFontSizeToFitWidth = true
        //label.minimumScaleFactor = 0.3
        
        let delBtn = testCell.delBtn
        // 角丸
        delBtn?.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        delBtn?.layer.masksToBounds = true
        
        //削除ボタンを押した時の処理
        delBtn?.tag = indexPath.row
        delBtn?.addTarget(self, action: #selector(onClick(sender: )), for: .touchUpInside)
        
        //影をつける
        //testCell.layer.masksToBounds = false //必須
        //testCell.layer.shadowOffset = CGSize(width: 1, height: 1)
        //testCell.layer.shadowOpacity = 0.9
        //testCell.layer.shadowRadius = 2.0
        
        //print("table create")
        return testCell
    }
    
    //削除ボタンを押した時
    @objc func onClick(sender: UIButton){
        //print(sender)
        let buttonRow = sender.tag//indexPath.row
        
        let actionAlert = UIAlertController(title: "ブラックリストから削除しますか？", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //UIAlertControllerにアクションを追加する
        let modifyAction = UIAlertAction(title: "削除する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //選択された時の処理
            var stringUrl = Util.URL_SAVE_BLACKLIST
            stringUrl.append("?flg=2&from_user_id=")
            stringUrl.append(String(self.user_id))
            stringUrl.append("&to_user_id=")
            stringUrl.append(self.blackList[buttonRow].to_user_id)
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
                    dispatchGroup.leave()//サブタスク終了時に記述
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //ブラックリスト一覧を取得して再描画
                self.getBlackListByUser()
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
        actionAlert.popoverPresentationController?.sourceView = self.view
        
        // ここで表示位置を調整。xは画面中央、yは画面下部になる様に指定
        let screenSize = UIScreen.main.bounds
        actionAlert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        
        // 下記を追加する
        actionAlert.modalPresentationStyle = .fullScreen
        
        //アクションを表示する
        self.present(actionAlert, animated: true, completion: nil)
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
        self.appDelegate.sendId = blackList[indexPath.row].to_user_id
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
        return blackList.count
    }
}

class BlackListViewCell:UICollectionViewCell{
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var blackListImageView: UIImageView!
    
    override func prepareForReuse(){
        //print("clear")
        self.blackListImageView.image = nil;
    }
}
