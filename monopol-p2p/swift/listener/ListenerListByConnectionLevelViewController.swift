//
//  ListenerListByConnectionLevelViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/18.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ListenerListByConnectionLevelViewController: UIViewController, IndicatorInfoProvider,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    let iconSize: CGFloat = 12.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "絆Lv順"
    
    @IBOutlet weak var listenerListCollectionView: UICollectionView!
    
    //リスナーの一覧用
    struct ListenerResult: Codable {
        let listener_user_id: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
        let connect_level: String
    }
    struct ResultListenerJson: Codable {
        let count: Int
        let result: [ListenerResult]
    }
    var listenerList: [(listener_user_id:String, user_name:String, photo_flg:String, photo_name:String, connect_level:String)] = []
    var listenerListTemp: [(listener_user_id:String, user_name:String, photo_flg:String, photo_name:String, connect_level:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getListenerListByCast()
        // Do any additional setup after loading the view.
    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getListenerListByCast(){
        //クリアする
        self.listenerListTemp.removeAll()
        //リスト取得
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //選択中のuser_idを指定
        let cast_id = appDelegate.sendIdByListenerList!
        
        var stringUrl = Util.URL_LISTENER_GET_BY_CAST
        stringUrl.append("?order=2&cast_id=")
        stringUrl.append(String(cast_id))
        stringUrl.append("&not_user_id=")
        stringUrl.append(String(user_id))
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
                    let json = try decoder.decode(ResultListenerJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //重複フィルター用
                    var listenerUserIdList = [String]()
                    //表示するリストを配列にする。
                    for obj in json.result {
                        let strListenerUserId = obj.listener_user_id
                        let strUserName = obj.user_name.toHtmlString()
                        let strPhotoFlg = obj.photo_flg
                        let strPhotoName = obj.photo_name
                        let strConnectLevel = obj.connect_level
                        
                        if listenerUserIdList.contains(obj.listener_user_id) {
                            //重複している場合、何もしない
                        } else {
                            listenerUserIdList.append(obj.listener_user_id)
                            //配列へ追加
                            let listener = (strListenerUserId,strUserName,strPhotoFlg,strPhotoName,strConnectLevel)
                            self.listenerList.append(listener)
                            self.listenerListTemp.append(listener)
                        }
                    }
                    
                    dispatchGroup.leave()
                    //self.CollectionView.reloadData()
                    //print(json.result)
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                    print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //コピーする
            self.listenerList = self.listenerListTemp
            
            //リストの取得を待ってから更新
            //self.CollectionView.reloadData()
            self.listenerListCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        //ユーザー画像の表示
        let photoFlg = listenerList[indexPath.row].photo_flg
        let photoName = listenerList[indexPath.row].photo_name
        let listener_user_id = listenerList[indexPath.row].listener_user_id
        if(photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + listener_user_id + ".jpg"
            let photoUrl = "user_images/" + listener_user_id + "/" + photoName + "_profile.jpg"

            //画像キャッシュを使用
            imageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")

        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            imageView.image = cellImage
        }
        
        // Tag番号を使ってLabelのインスタンス生成
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        label.text = listenerList[indexPath.row].user_name
        //ラベルの枠を自動調節する
        //label.adjustsFontSizeToFitWidth = true
        //label.minimumScaleFactor = 0.3
        
        // Tag番号を使ってLabelのインスタンス生成(絆レベル)
        let kizunaLabel = testCell.contentView.viewWithTag(3) as! UILabel
        //kizunaLabel.text = "絆Lv:" + listenerList[indexPath.row].connect_level
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        kizunaLabel.attributedText = UtilFunc.getInsertIconString(string: listenerList[indexPath.row].connect_level, iconImage: UIImage(named:"castinfo_kizuna_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
        
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
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modelInfo: UserInfoViewController = storyboard.instantiateViewController(withIdentifier: "toUserInfoViewController") as! UserInfoViewController
        
        //リスナーのuser_idを次の画面（ストリーマー詳細画面）へ渡す
        appDelegate.sendId = listenerList[indexPath.row].listener_user_id
        
        // 下記を追加する
        modelInfo.modalPresentationStyle = .overCurrentContext
        
        present(modelInfo, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        //return idCount;
        return listenerList.count
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
