//
//  MyCollectionViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class MyCollectionViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    //コレクション数　20/50のところ
    @IBOutlet weak var collectionCountLbl: UILabel!
    
    @IBOutlet weak var maxWarningLabel: UILabel!
    
    @IBOutlet weak var addPocketBtn: UIButton!
    
    struct UserResult: Codable {
        let id: String
        let user_id: String
        let cast_id: String
        let file_name: String
        let ins_time: String
        let cast_name: String
    }
    
    struct ResultJson: Codable {
        let count: Int
        let result: [UserResult]
    }
    var idCount:Int=0
    
    var mycollectionList: [(id:String, user_id:String, cast_id:String, file_name:String, ins_time:String, cast_name:String)] = []
    var mycollectionListTemp: [(id:String, user_id:String, cast_id:String, file_name:String, ins_time:String, cast_name:String)] = []
    
    var mycollection_max_count:Int=0
    
    var cover_count:Int=0

    //Baseviewcontrollerで定義済み
    //var user_id: Int = 0//自分のID
    
    // サムネイル画像の名前
    //let photos = ["demo01","demo02","demo03","demo04","demo05","demo06","demo07","demo08","demo09"]
    //var strPeerIds: [String] = []
    //var strNames: [String] = []
    
    //var selectedImage: UIImage?
    //var selectedId:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Baseviewcontrollerで取得済み
        //self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        // 角丸
        addPocketBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        addPocketBtn.layer.masksToBounds = true
        
        // 角丸
        maxWarningLabel.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        maxWarningLabel.layer.masksToBounds = true
        
        //リスト取得
        self.getMyCollectionList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //() -> ()の部分は　(引数) -> (返り値)を指定
    func getMyCollectionList(){
        //クリアする
        //self.mycollectionList.removeAll()
        self.mycollectionListTemp.removeAll()
        
        //現在のマイコレクションのMax値
        self.mycollection_max_count = UserDefaults.standard.integer(forKey: "myCollection_max")

        var stringUrl = Util.URL_MYCOLLECTION_GET_BY_USER
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
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strId = obj.id
                        let strUserId = obj.user_id
                        let strCastId = obj.cast_id
                        let strFileName = obj.file_name
                        let strInsTime = obj.ins_time
                        let strCastName = obj.cast_name.toHtmlString()

                        let mycollection = (strId,strUserId,strCastId,strFileName,strInsTime,strCastName)
                        //配列へ追加
                        self.mycollectionList.append(mycollection)
                        self.mycollectionListTemp.append(mycollection)
                    }
                    dispatchGroup.leave()
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                }
            })
            task.resume()
        }
        //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        //    self.CollectionView.reloadData()
        //}
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //コピーする
            self.mycollectionList = self.mycollectionListTemp
            
            self.collectionCountLbl.text = String(self.mycollectionList.count)
                + "/"
                + String(self.mycollection_max_count)

            //スクリーンサイズの取得
            let screenSize: CGSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            
            // Do any additional setup after loading the view.
            if(self.mycollection_max_count < self.mycollectionList.count){
                //上限を超えている場合
                self.maxWarningLabel.isHidden = false
                self.collectionCountLbl.textColor = UIColor.red
                self.mainCollectionView.frame = CGRect(x: 0, y: 160, width: screenSize.width, height: screenSize.height - 160 - Util.TAB_BAR_HEIGHT)
                
                //カウントを超えている数(グレーで覆われている数)
                self.cover_count = self.mycollectionList.count - self.mycollection_max_count
            }else{
                self.maxWarningLabel.isHidden = true
                self.collectionCountLbl.textColor = UIColor.darkGray
                
                self.mainCollectionView.frame = CGRect(x: 0, y: 130, width: screenSize.width, height: screenSize.height - 130 - Util.TAB_BAR_HEIGHT)
                
                //カウントを超えている数(グレーで覆われている数)
                self.cover_count = 0
            }
            
            //リストの取得を待ってから更新
            self.mainCollectionView.reloadData()
        }
    }
    
    @IBAction func tapAddPocketBtn(_ sender: Any) {
        //所持しているコイン数
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        //print(String(myPoint))
        
        if(myPoint < Util.MYCOLLECTION_UPDATE_COIN){
            //コインがなかったらアラートを出力し、コインの購入画面へ
            self.showCoinAlert()
        }else{
            let actionAlert = UIAlertController(title: Util.MYCOLLECTION_MAX_UPDATE_STR, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            //UIAlertControllerにアクションを追加する
            let modifyAction = UIAlertAction(title: "拡張する", style: UIAlertAction.Style.default, handler: {
                (action: UIAlertAction!) in
                //選択された時の処理
                var stringUrl = Util.URL_MYCOLLECTION_UPDATE_MAX
                stringUrl.append("?user_id=")
                stringUrl.append(String(self.user_id))
                stringUrl.append("&count=")
                stringUrl.append(String(Util.MYCOLLECTION_PLUS_MAX))
                stringUrl.append("&coin=")
                stringUrl.append(String(Util.MYCOLLECTION_UPDATE_COIN))
                
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
                    
                    //コイン消費履歴を保存
                    //type=1:マイコレクションの拡張
                    UtilFunc.writePointUseRireki(type:1,
                                                 point:Util.MYCOLLECTION_UPDATE_COIN,
                                                 user_id:self.user_id,
                                                 target_user_id:0)
                    
                    //設定値を更新
                    self.mycollection_max_count = self.mycollection_max_count + Util.MYCOLLECTION_PLUS_MAX
                    UserDefaults.standard.set(self.mycollection_max_count, forKey: "myCollection_max")
                    
                    //リスト取得
                    //self.getMyCollectionList()
                    
                    //拡張が成功のダイアログを表示
                    self.showAlert()
                }
            })
            
            actionAlert.addAction(modifyAction)
            
            /*
             //UIAlertControllerに***のアクションを追加する
             let ***Action = UIAlertAction(title: "***", style: UIAlertActionStyle.default, handler: {
             (action: UIAlertAction!) in
             print("***のシートが選択されました。")
             })
             actionAlert.addAction(***Action)
             */
            
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
    }
    
    //数秒後に勝手に閉じる(ポケットの拡張が終わった場合)
    func showAlert() {
        // アラート作成
        let alert = UIAlertController(title: nil, message: "ポケットの拡張が完了しました", preferredStyle: .alert)
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alert.dismiss(animated: true, completion: {
                    //画面遷移させる
                    UtilToViewController.toMyCollectionViewController(animated_flg:false)
                    //下記はうまく動作しない(コレクションビューが再描画されない)
                    //self.getMyCollectionList()
                })
                
            })
        })
    }

    //数秒後に勝手に閉じる(コインが足りない場合)
    func showCoinAlert() {
        // アラート作成
        let alert = UIAlertController(title: nil, message: "コインが足りません(" + String(Util.MYCOLLECTION_UPDATE_COIN) + "コイン消費)", preferredStyle: .alert)
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alert.dismiss(animated: true, completion: {
                    //画面遷移させる
                    UtilToViewController.toPurchaseViewController(animated_flg:false)
                    //下記はうまく動作しない(コレクションビューが再描画されない)
                    //self.getMyCollectionList()
                })
                
            })
        })
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
        let testCell:MyCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",for: indexPath) as! MyCollectionViewCell
        
        var photoUrl: String = "mycollection/"
            photoUrl.append(mycollectionList[indexPath.row].user_id)
            photoUrl.append("/")
            photoUrl.append(mycollectionList[indexPath.row].cast_id)
            photoUrl.append("/")
            photoUrl.append(mycollectionList[indexPath.row].file_name)
            photoUrl.append("_list.jpg")
        
        // Tag番号を使ってImageViewのインスタンス生成
        //let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        let imageView = testCell.collectionImageView
        //画像キャッシュを使用
        imageView?.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
        
        //マイコレクションの画像と上に被せるVIEWはサイズ・角丸などを全て合わせる
        // 角丸
        imageView?.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        imageView?.layer.masksToBounds = true
        // 角丸
        testCell.imageCoverView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        testCell.imageCoverView.layer.masksToBounds = true
        
        if(indexPath.row < self.cover_count){
            testCell.imageCoverView.isHidden = false
        }else{
            testCell.imageCoverView.isHidden = true
        }
        /*
        if(indexPath.row < self.cover_count){
            //var coverView: UIView!//覆うVIEW
            //imageViewに被せる
            let coverView = UIView(frame: CGRect(x: 0, y: 0, width: (imageView?.bounds.width)!, height: (imageView?.bounds.height)!))
            // coverViewの背景
            coverView.backgroundColor = UIColor.black
            // 透明度を設定
            coverView.alpha = 0.6
            //coverView.isUserInteractionEnabled = false
            imageView?.addSubview(coverView)
        }*/
        
        //キャスト名を設定
        let castNameLabel = testCell.contentView.viewWithTag(2) as! UILabel
        castNameLabel.text = mycollectionList[indexPath.row].cast_name
        //ラベルの枠を自動調節する
        //castNameLabel.adjustsFontSizeToFitWidth = true
        //castNameLabel.minimumScaleFactor = 0.3
        
        return testCell
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = view.frame.width / 4 - 8
        let height: CGFloat = width + 26
        return CGSize(width: width, height: height)
    }
    
    /////////追加(ここから)////////////////////////////
    // Cell が選択された場合
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row < self.cover_count){
            //上限を超えている場合は選択できない
        }else{
            //選択中のセルの画像を取得する。
            //let index = collectionView.indexPathsForSelectedItems?.first
            //selectedId = index![1]
            //print(selectedId)
            //マイコレクションの個別画面へ渡す
            self.appDelegate.myCollectionType = "1"
            self.appDelegate.myCollectionSelectId = mycollectionList[indexPath.row].id
            self.appDelegate.myCollectionSelectCastId = mycollectionList[indexPath.row].cast_id
            self.appDelegate.myCollectionSelectCastName = mycollectionList[indexPath.row].cast_name
            self.appDelegate.myCollectionSelectInsTime = mycollectionList[indexPath.row].ins_time
            self.appDelegate.myCollectionSelectPhotoFileName = mycollectionList[indexPath.row].file_name
            
            UtilToViewController.toCollectionImageViewController(animated_flg:false)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
        //return idCount;
        return mycollectionList.count;
    }
}

class MyCollectionViewCell:UICollectionViewCell{
    @IBOutlet weak var collectionImageView: UIImageView!
    @IBOutlet weak var imageCoverView: UIView!
    
    override func prepareForReuse(){
        //print("clear")
        self.collectionImageView.image = nil;
        self.imageCoverView.isHidden = true;
    }
}
