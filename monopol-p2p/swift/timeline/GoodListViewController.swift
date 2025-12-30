//
//  GoodListViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/08/08.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class GoodListViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //いいねの一覧用
    struct GoodResult: Codable {
        let user_id: String
        let user_name: String
        let photo_flg: String
        let photo_name: String
    }
    struct ResultGoodJson: Codable {
        let count: Int
        let result: [GoodResult]
    }
    var goodList: [(userId:String, userName:String, photoFlg:String, photoName:String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 枠線の色
        mainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        mainView.layer.borderWidth = 2
        // 角丸
        mainView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mainView.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        
        self.getGoodList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //自分以外のいいねを押している人を取得

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closeBtnTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func getGoodList(){
        //クリアする
        self.goodList.removeAll()
        //リスト取得(自分以外の待機中のリストを取得)
        //自分のuser_idを指定
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let sendNoticeId = self.appDelegate.sendNoticeId
        
        //GET:notice_id,user_id,order
        var stringUrl = Util.URL_GET_GOOD_LIST
        stringUrl.append("?order=1&notice_id=")
        stringUrl.append(String(sendNoticeId!))
        stringUrl.append("&user_id=")
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
                    let json = try decoder.decode(ResultGoodJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strUserId = obj.user_id
                        let strUserName = obj.user_name
                        let strPhotoFlg = obj.photo_flg
                        let strPhotoName = obj.photo_name
                        
                        let goodTemp = (strUserId,strUserName,strPhotoFlg,strPhotoName)
                        //配列へ追加
                        self.goodList.append(goodTemp)
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
            //リストの取得を待ってから更新
            //self.CollectionView.reloadData()
            self.CollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        //キャスト画像の表示
        let photoFlg = goodList[indexPath.row].photoFlg
        let photoName = goodList[indexPath.row].photoName
        let user_id = goodList[indexPath.row].userId
        if(photoFlg == "1"){
            //写真設定済み
            //let photoUrl = "user_images/" + user_id + "_profile.jpg"
            let photoUrl = "user_images/" + user_id + "/" + photoName + "_profile.jpg"
            
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
        label.text = goodList[indexPath.row].userName
        //ラベルの枠を自動調節する
        //label.adjustsFontSizeToFitWidth = true
        //label.minimumScaleFactor = 0.3
        
        //print("table create")
        return testCell
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = view.frame.width / 4 - 10
        let height: CGFloat = width
        return CGSize(width: width, height: height)
        
    }
    
    /////////追加(ここから)////////////////////////////
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        appDelegate.sendId = goodList[indexPath.row].userId
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
        return goodList.count
    }
}
