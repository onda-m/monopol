//
//  TalkInfoViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/11.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Photos
//import Alamofire
//import FirebaseStorage
//import CommonKeyboard

class TalkInfoViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    //let iconSize: CGFloat = 14.0
    
    var coverView: UIView!//キーボード以外を覆うVIEW
    var keyboardFlg = 0//1の時はキーボードをずらさずに表示する
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    //var bottomView: TalkInputView! //画面下部に表示するテキストフィールドと送信ボタン
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 画像のupload・表示用
    //let storageRef = Storage.storage().reference(forURL: Util.URL_FIREBASE)
    
    //var user_id: Int = 0
    var myCoin: Double = 0.0//現在のコイン数
    var myLiveLevel: Int = 0//現在の配信レベル
    var parent_rireki_id:String = "0"//相手との初めてのトークの場合は、ゼロのままトーク送信となる。
    
    //@IBOutlet weak var sendTextView: UIView!
    //private var defaultScrollOffset: CGFloat?
    
    /*
    //コインがない場合に表示するVIEW
    @IBOutlet weak var noCoinView: UIView!
    @IBOutlet weak var noCoinLabel01: UILabel!
    @IBOutlet weak var noCoinLabel02: UILabel!
    */
    //コインが足りない場合に表示するダイアログ
    let noCoinDialog:NoCoinDialog = UINib(nibName: "NoCoinDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! NoCoinDialog
    
    //消費コイン:25のところ
    @IBOutlet weak var coinLabel: UILabel!
    //消費コインのところ
    @IBOutlet weak var coinTempLabel: UILabel!
    @IBOutlet weak var talkSendIcon: UIImageView!

    @IBOutlet weak var talkinfoTableView: ThroughTableView!
    //@IBOutlet weak var sendTextField: UITextField!
    @IBOutlet weak var sendTextView: PlaceHolderTextView!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var sendImageBtn: UIButton!
    @IBOutlet weak var coinIconImageView: UIImageView!

    
    
    //キーボード用
    //@IBOutlet var bottomConstraint: NSLayoutConstraint!
    //@IBOutlet weak var keyboardScrollView: UIScrollView!
    //@IBOutlet weak var keyboardView: UIView!
    //let keyboardObserver = CommonKeyboardObserver()
    @IBOutlet weak var sendView: UIView!
    
    //トーク送信完了用(id_tempは画像を送信時にファイル名で使用)
    struct ResultJson: Codable {
        let id_temp: Int
        //let result: [UserResult]
    }

    //トークの一覧用(修正必要)
    struct TalkResult: Codable {
        let rireki_id: String
        let parent_rireki_id: String
        let user_id: String
        let target_user_id: String
        let open_status: String
        let photo_flg: String//0:コメントの場合 1:画像の場合
        let value01: String//トーク内容
        let ins_time: String
        let mod_time: String
    }
    struct ResultTalkJson: Codable {
        let count: Int
        let result: [TalkResult]
    }
    var talkList: [(rireki_id:String, parent_rireki_id:String, user_id:String, target_user_id:String
        , open_status:String, photo_flg:String, value01:String, ins_time:String, mod_time:String)] = []
    var talkListTemp: [(rireki_id:String, parent_rireki_id:String, user_id:String, target_user_id:String
        , open_status:String, photo_flg:String, value01:String, ins_time:String, mod_time:String)] = []
    
    //相手のユーザーID
    var sendId:String = ""
    //相手のフォトフラグ
    var sendPhotoFlg:String = ""
    var sendPhotoName:String = ""
    //相手の無料or有料フラグ
    //1:無料 2:有料
    var sendFreeFlg:String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.coinLabel.text = String(Int(Util.SEND_TALK_TEXT_COIN))
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        //self.coinLabel.attributedText = Util.getInsertIconString(string: String(Util.SEND_TALK_TEXT_COIN), iconImage: UIImage(named:"coin_ico")!, iconSize: self.iconSize)
        
        /*
        //コインがない場合に表示するVIEW
        // 角丸
        noCoinView.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        noCoinView.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        noCoinLabel01.adjustsFontSizeToFitWidth = true
        noCoinLabel01.minimumScaleFactor = 0.3
        //ラベルの枠を自動調節する
        noCoinLabel02.adjustsFontSizeToFitWidth = true
        noCoinLabel02.minimumScaleFactor = 0.3
        */
        //noCoinDialog
        self.noCoinDialog.isHidden = true//非表示にしておく
        //画面サイズに合わせる
        self.noCoinDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.noCoinDialog)
        
        // 角丸
        sendBtn.layer.cornerRadius = 10
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        sendBtn.layer.masksToBounds = true
        
        // 枠線の色
        sendTextView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        sendTextView.layer.borderWidth = 1
        // 角丸
        sendTextView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        sendTextView.layer.masksToBounds = true
        sendTextView.placeHolder = "メッセージを作成"
        
        //talkinfoTableView.re.dataSource = self
        //talkinfoTableView.re.delegate = self
        talkinfoTableView.dataSource = self
        talkinfoTableView.delegate = self
        
        //キーボード対応
        self.configureObserver()
        
        self.myCoin = UserDefaults.standard.double(forKey: "myPoint")
        self.myLiveLevel = UserDefaults.standard.integer(forKey: "myLiveLevel")
        
        //相手のIDを取得
        sendId = self.appDelegate.sendId!
        sendPhotoFlg = self.appDelegate.sendPhotoFlg!
        sendPhotoName = self.appDelegate.sendPhotoName!
        
        if(sendId == "0"){
            //公式からのお知らせに関して、未読・既読切り替え GET:user_id,flg(flg=1:オン 0:オフ)
            //static let URL_MODIFY_OFFICIAL_OPENFLG = URL_BASE + "modifyOfficialReadFlg.php"
            self.readOfficial()
            
            //モノポル運営には送信できない
            sendTextView.isHidden = true
            sendBtn.isHidden = true
            sendImageBtn.isHidden = true
            coinIconImageView.isHidden = true
            
            //消費コイン:25のところ
            coinLabel.isHidden = true
            //消費コインのところ
            coinTempLabel.isHidden = true
            talkSendIcon.isHidden = true
            
        }else{
            sendTextView.isHidden = false
            sendBtn.isHidden = false
            sendImageBtn.isHidden = false
            coinIconImageView.isHidden = false
            
            //消費コイン:25のところ
            //自分の配信レベル10未満　→　誰に送ってもコイン消費
            //自分の配信レベル10以上　→　誰に送ってもコイン無料
            if(self.myLiveLevel < 10){
                //相手が有料サシライブのためコインを消費
                self.coinLabel.text = String(Int(Util.SEND_TALK_TEXT_COIN))
                //送信無料or有料フラグ
                //1:無料 2:有料
                self.sendFreeFlg = "2"
            }else{
                //相手が無料サシライブ
                self.coinLabel.text = String(Int(Util.SEND_TALK_TEXT_COIN_FREE))
                //送信無料or有料フラグ
                //1:無料 2:有料
                self.sendFreeFlg = "1"
            }
            
/*
            //sendIdが有料ストリーマーかの判断
            //配信レベルが１０以上の人はみんなストリーマー扱い＞ストリーマーへ送信時にコインを必要とする
            var strLiveLevel: String = ""//配信レベル
//            var strCastRank: String = ""
            //個別設定用
//            var strExLiveSec: String = ""
            
            //相手の情報取得
            let stringUrl = Util.URL_USER_INFO + "?user_id=" + String(sendId)

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
                        let json = try decoder.decode(UtilStruct.ResultFreeJson.self, from: data!)
                        //self.idCount = json.count
                        
                        //モデル詳細を配列にする。(ただしゼロ番目のみ参照可能)
                        for obj in json.result {
                            strLiveLevel = obj.live_level
//                            strCastRank = obj.cast_rank
                            //個別設定用
//                            strExLiveSec = obj.ex_live_sec
                            
                            break
                        }
                        
                        //print(json.result)
                        dispatchGroup.leave()//サブタスク終了時に記述
                    }catch{
                        //エラー処理
                        //print("エラーが出ました")
                    }
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //配信レベルが１０以上か１０未満で判断
                if(Int(strLiveLevel)! >= 10){
                    //相手が有料サシライブのためコインを消費
                    self.coinLabel.text = String(Int(Util.SEND_TALK_TEXT_COIN))
                    //相手の無料or有料フラグ
                    //1:無料 2:有料
                    self.sendFreeFlg = "2"
                }else{
                    //相手が無料サシライブ
                    self.coinLabel.text = String(Int(Util.SEND_TALK_TEXT_COIN_FREE))
                    //相手の無料or有料フラグ
                    //1:無料 2:有料
                    self.sendFreeFlg = "1"
                }
            }
            */
            
            coinLabel.isHidden = false
            //消費コインのところ
            coinTempLabel.isHidden = false
            talkSendIcon.isHidden = false
        }

        //トークを取得
        getTalkRirekiByUserandTarget()
        
        //テーブルの区切り線を非表示
        self.talkinfoTableView.separatorColor = UIColor.clear
        self.talkinfoTableView.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.talkinfoTableView.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        //self.talkTableView.allowsSelection = false // 選択を不可にする
        self.talkinfoTableView.isScrollEnabled = true
        self.talkinfoTableView.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        
        //self.bottomView = TalkInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)) // 下部に表示するテキストフィールドを設定
        //self.view.addSubview(self.bottomView)
        
        //絆レベルなど相手との情報を取得
        //self.getConnectInfo()
        UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:Int(sendId)!)
        
        //コインが足りない場合はコイン購入画面へ遷移
        //noCoinView.isUserInteractionEnabled = true
        //noCoinView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.noCoinViewTapped(_:))))

        self.talkinfoTableView.register(UINib(nibName: "MyTalkViewCell", bundle: nil), forCellReuseIdentifier: "MyTalk")
        self.talkinfoTableView.register(UINib(nibName: "MyTalkPhotoCell", bundle: nil), forCellReuseIdentifier: "MyTalkPhoto")
        self.talkinfoTableView.register(UINib(nibName: "YourTalkViewCell", bundle: nil), forCellReuseIdentifier: "YourTalk")
        self.talkinfoTableView.register(UINib(nibName: "YourTalkPhotoCell", bundle: nil), forCellReuseIdentifier: "YourTalkPhoto")
        self.talkinfoTableView.register(UINib(nibName: "YourTalkNoreadViewCell", bundle: nil), forCellReuseIdentifier: "YourTalkNoread")
    }

    /*
    // noCoinViewがタップされたら呼ばれる(コイン購入画面へ)
    @objc func noCoinViewTapped(_ sender: UITapGestureRecognizer) {
        //print("タップ")
        Util.toPurchaseViewController(animated_flg:false)
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
        self.myCoin = UserDefaults.standard.integer(forKey: "myPoint")
        
        //コイン数の確認
        if(self.myCoin < Util.SEND_TALK_PHOTO_COIN){
            //コインがない場合
            if(sendId == "0"){
                //相手が運営者の場合
                //noCoinView.isHidden = true
            }else{
                //noCoinView.isHidden = false
                //view.bringSubview(toFront: noCoinView)
                sendImageBtn.isEnabled = false//無効
            }
        }else{
            //noCoinView.isHidden = true
            sendImageBtn.isEnabled = true//有効
        }
         */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //キーボード対応
        self.removeObserver() // Notificationを画面が消えるときに削除
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //override var inputAccessoryView: UIView? {
    //    return bottomView //通常はテキストフィールドのプロパティに設定しますが、画面を表示している間は常に表示したいため、ViewControllerのプロパティに設定します
    //}
    
    func getTalkRirekiByUserandTarget(){
        //クリアする
        //self.talkList.removeAll()
        self.talkListTemp.removeAll()
        
        var stringUrl = Util.URL_GET_TALK_RIREKI_BY_TARGET_ID
        if(sendId == "0"){
            //モノポル運営
            stringUrl.append("?order=1&user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&target_id=0")
            //print(stringUrl)
        }else{
            //一般ユーザー
            stringUrl.append("?order=1&user_id=")
            stringUrl.append(String(user_id))
            stringUrl.append("&target_id=")
            stringUrl.append(sendId)
            //print(stringUrl)
        }
        
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
                    let json = try decoder.decode(ResultTalkJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strRirekiId = obj.rireki_id
                        self.parent_rireki_id = obj.parent_rireki_id
                        let strParentRirekiId = obj.parent_rireki_id
                        let strUserId = obj.user_id
                        let strTargetUserId = obj.target_user_id
                        let strOpenStatus = obj.open_status
                        let strPhotoFlg = obj.photo_flg
                        let strValue01 = obj.value01
                        let strInsTime = obj.ins_time
                        let strModTime = obj.mod_time
                        let talk = (strRirekiId, strParentRirekiId,strUserId,strTargetUserId,strOpenStatus,strPhotoFlg,strValue01,strInsTime,strModTime)
                        //配列へ追加
                        self.talkList.append(talk)
                        self.talkListTemp.append(talk)
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
            self.talkList = self.talkListTemp
            
            /*
            self.myCoin = UserDefaults.standard.integer(forKey: "myPoint")
            
            if(self.myCoin < Util.SEND_TALK_PHOTO_COIN){
                //コインがない場合
                if(self.sendId == "0"){
                    //相手が運営者の場合
                    //self.noCoinView.isHidden = true
                }else{
                    //self.noCoinView.isHidden = false
                    //self.view.bringSubview(toFront: self.noCoinView)
                    self.sendImageBtn.isEnabled = false
                }
            }else{
                //self.noCoinView.isHidden = true
                self.sendImageBtn.isEnabled = true
            }
             */
            
            //リストの取得を待ってから更新
            //self.CollectionView.reloadData()
            self.talkinfoTableView.reloadData()
            
            // 最下部へscrollさせる
            //self.talkinfoTableView.setContentOffset(CGPoint(x:0, y:self.talkinfoTableView.contentSize.height - self.talkinfoTableView.frame.size.height),animated: false);

            if(self.talkList.count > 2){
                self.talkinfoTableView.scrollToRow(at: IndexPath(row: self.talkList.count - 1, section: 0),
                                                   at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @IBAction func tapSendImageBtn(_ sender: Any) {
        //ブラックリストのチェック
        //ブラックリストの配列にない場合はnilが返される
        if self.appDelegate.array_black_list.index(of: Int(self.sendId)!) == nil {
        }else{
            //ブラックリストにある場合
            UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_COMMON_008, vc:self, sec:3.0)
            return
        }
        
        self.myCoin = UserDefaults.standard.double(forKey: "myPoint")
        
        //コイン数の確認(有料の場合と無料の場合それぞれ一応チェック)
        if(self.sendFreeFlg == "1" && self.myCoin < Util.SEND_TALK_PHOTO_COIN_FREE){
            //コインがない場合(1:無料)
            //課金画面へ
            //Util.toPurchaseViewController(animated_flg:false)
            self.noCoinDialog.isHidden = false
        }else if(self.sendFreeFlg == "2" && self.myCoin < Util.SEND_TALK_PHOTO_COIN){
            //コインがない場合(2:有料)
            //課金画面へ
            //Util.toPurchaseViewController(animated_flg:false)
            self.noCoinDialog.isHidden = false
        }else{
            // アルバム(Photo liblary)の閲覧権限の確認
            //checkPermission()
            
            let photoLibraryManager = PhotoLibraryManager.init(parentViewController: self)
            photoLibraryManager.requestAuthorizationOn()
            photoLibraryManager.callPhotoLibrary()
            
            //if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
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
                //let imagePicker = UIImagePickerController()
                //imagePicker.delegate = self
                //imagePicker.sourceType = .photoLibrary
                //imagePicker.allowsEditing = true
            
                // 下記を追加する
                //imagePicker.modalPresentationStyle = .fullScreen
            
                //self.present(imagePicker, animated: true, completion: nil)
            //}
        }
    }
    
    //画像のアップロード処理
    func imageUpload(image: UIImage, user_id: Int) {
        //画像ファイル名に使用するIDの払い出し
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        var stringUrl = Util.URL_TALK_SEND_DO
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&target_id=")
        stringUrl.append(sendId)
        stringUrl.append("&sendtext=0&parent_rireki_id=")
        stringUrl.append(parent_rireki_id)
        stringUrl.append("&official_flg=2&open_status=3&photo_flg=1&send_point=")
        
        if(self.sendFreeFlg == "1"){
            //送信無料
            stringUrl.append(String(Util.SEND_TALK_PHOTO_COIN_FREE))
        }else{
            //送信有料
            stringUrl.append(String(Util.SEND_TALK_PHOTO_COIN))
        }
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        
        //非同期処理を行う
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        var json_result :ResultJson? = nil
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let task = URLSession.shared.dataTask(with: req, completionHandler: {
                (data, res, err) in
                do{
                    //JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    
                    //受けとったJSONデータをパースして格納
                    json_result = try decoder.decode(ResultJson.self, from: data!)

                    //print("作成されたID")
                    //print(json.id_temp)
                    dispatchGroup.leave()//サブタスク終了時に記述
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print("json convert failed in JSONDecoder", err?.localizedDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //作成されたID
            let temp_id: Int = json_result!.id_temp
            //画像のサイズ変更(個別用の画像)
            // UIImagePNGRepresentationでUIImageをNSDataに変換
            //let orgImage = Util.resizeImage(image :image, w:Int(Util.TALK_PHOTO_WIDTH), h:Int(Util.TALK_PHOTO_HEIGHT))
            let orgImage = UtilFunc.resizeImage(image :image, width:Double(Util.TALK_PHOTO_WIDTH), height:Double(Util.TALK_PHOTO_HEIGHT))
            
            if let orgdata = orgImage.pngData() {

                var orgfileName = String(temp_id)
                orgfileName.append(".jpg")
                
                let orgbody = UtilFunc.httpBodyAlpha(orgdata, fileName: orgfileName, castId: self.sendId, userId: String(user_id))
                //let orgurl = URL(string: Util.URL_SAVE_PHOTO)!
                UtilFunc.fileUpload(URL(string: Util.URL_SAVE_TALK_PHOTO)!, data: orgbody) {(data, response, error) in
                    if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                        if response.statusCode == 200 {
                            //print("Upload done")
                        } else {
                            //print("Upload error")
                            //print(response.statusCode)
                        }
                    }
                }
            }
            
            //画像のサイズ変更(リスト画像)
            let listImage = UtilFunc.cropThumbnailImage(image :image, width:Double(Util.TALK_LIST_PHOTO_WIDTH), height:Double(Util.TALK_LIST_PHOTO_HEIGHT))
            // UIImagePNGRepresentationでUIImageをNSDataに変換
            if let listdata = listImage.pngData() {
                
                var listfileName = String(temp_id)
                listfileName.append("_list.jpg")
                
                let listbody = UtilFunc.httpBodyAlpha(listdata, fileName: listfileName, castId: self.sendId, userId: String(user_id))
                //let listbody = Util.httpBody(listdata,fileName: listfileName)
                //let listurl = URL(string: Util.URL_SAVE_PHOTO)!
                UtilFunc.fileUpload(URL(string: Util.URL_SAVE_TALK_PHOTO)!, data: listbody) {(data, response, error) in
                    if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                        if response.statusCode == 200 {
                            //print("Upload done")
                            //画像の送信が終わった場合
                            //type= 1:マイコレクションMAX値 2:トーク開封 3:トーク送信(テキスト) 4: トーク送信(画像) 5:ライブ配信(1枠)
                            var point = 0
                            if(self.sendFreeFlg == "1"){
                                //送信無料
                                point = Int(Util.SEND_TALK_PHOTO_COIN_FREE)
                            }else{
                                //送信有料
                                point = Int(Util.SEND_TALK_PHOTO_COIN)
                            }
                            
                            /*************************************************************/
                            //コイン・ポイントなどの計算処理(トーク画像送信)
                            /*************************************************************/
                            //コインを消費
                            UtilFunc.pointUseDo(type:0, userId:user_id, point:Double(point))
                            //コイン消費履歴に履歴を保存する
                            UtilFunc.writePointUseRireki(type:4,
                                                         point:Double(point),
                                                         user_id:self.user_id,
                                                         target_user_id:Int(self.sendId)!)
                            
                            /*****************************************************/
                            //絆レベルの更新(絆レベルの経験値がゼロのため、現状処理をしない)
                            //connect_levelの更新、pair_month_rankingの更新が必要
                            //DM送信時の消費ポイント1コインにつき経験値は
                            //static let CONNECTION_POINT_DM_SEND: Int = 0
                            //DM開封時の消費ポイント1コインにつき経験値は
                            //static let CONNECTION_POINT_DM_READ: Int = 1
                            /*****************************************************/
                            
                            //絆レベルの更新・追加(更新後に何も処理をしない場合に使用)
                            //flg:1:値プラス、2:値マイナス
                            UtilFunc.saveConnectLevelNew(user_id:self.user_id, target_user_id:Int(self.sendId)!, exp:Int(point)*Util.CONNECTION_POINT_DM_SEND, live_count:0, present_point:0, flg:1)
                            
                            //let strConnectBonusRate = UserDefaults.standard.string(forKey: "sendConnectBonusRate")
                            let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")
                            
                            //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
                            UtilFunc.savePairMonthRanking(user_id:self.user_id, cast_id:Int(self.sendId)!, exp:Int(Double(point)*strConnectBonusRate))
                            
                            //画面更新
                            self.getTalkRirekiByUserandTarget()
                            
                            //絆レベルなど相手との情報を取得
                            //self.getConnectInfo()
                            UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:Int(self.sendId)!)
                            
                            //ここのタイミングで相手にスターを加算
                            //type:0=スターのゲット 1=スターの没収
                            if(self.sendFreeFlg == "1"){
                                //送信無料
                                //何もしない
                            }else{
                                //送信有料
                                //相手にスターを加算
                                UtilFunc.getStar(type:0
                                    , user_id:Int(self.sendId)!
                                    , star_num:Int(Util.GET_TALK_STAR))
                            }
                            
                            /*************************************************************/
                            //コイン・ポイントなどの計算処理(ここまで)
                            /*************************************************************/
                        } else {
                            //print(response.statusCode)
                        }
                    }
                }
            }
            
            //画像の送信が終わった場合
            //self.dismiss(animated: true, completion: nil)
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
            //キーボードを閉じる
            self.view.endEditing(true)
/*
            // UIImagePNGRepresentationでUIImageをNSDataに変換
            if let data = UIImagePNGRepresentation(orgImage) {
                let temp_id: Int = json_result!.id_temp
                
                var strPhotoPath = "talk/"
                strPhotoPath.append(String(user_id))
                strPhotoPath.append("/")
                strPhotoPath.append(self.sendId)
                strPhotoPath.append("/")
                strPhotoPath.append(String(temp_id))
                strPhotoPath.append(".jpg")

                let reference = self.storageRef.child(strPhotoPath)
                reference.putData(data, metadata: nil, completion: { metaData, error in
                    //print(metaData as Any)
                    //print(error as Any)
                    //画像のサイズ変更(リスト画像)
                    let listImage = Util.resizeImage(image :image, w:Int(Util.USER_LIST_PHOTO_WIDTH), h:Int(Util.USER_LIST_PHOTO_HEIGHT))
                    // UIImagePNGRepresentationでUIImageをNSDataに変換
                    
                    var strListPhotoPath = "talk/"
                    strListPhotoPath.append(String(user_id))
                    strListPhotoPath.append("/")
                    strListPhotoPath.append(self.sendId)
                    strListPhotoPath.append("/")
                    strListPhotoPath.append(String(temp_id))
                    strListPhotoPath.append("_list.jpg")
                    
                    if let listdata = UIImagePNGRepresentation(listImage) {
                        let listreference = self.storageRef.child(strListPhotoPath)
                        listreference.putData(listdata, metadata: nil, completion: { metaData, error in
                            //print(metaData as Any)
                            //print(error as Any)
                        })
                    }
                })
            }
 */
        }
    }
    
    @IBAction func tapSendBtn(_ sender: Any) {
        //送信ボタンを押した時
        //ブラックリストのチェック
        //ブラックリストの配列にない場合はnilが返される
        if self.appDelegate.array_black_list.index(of: Int(self.sendId)!) == nil {
        }else{
            //ブラックリストにある場合
            UtilFunc.showAlert(message:UtilStr.ERROR_SELECT_COMMON_008, vc:self, sec:3.0)
            return
        }
                
        self.myCoin = UserDefaults.standard.double(forKey: "myPoint")

        //コイン数の確認(有料の場合と無料の場合それぞれ一応チェック)
        if(self.sendFreeFlg == "1" && self.myCoin < Util.SEND_TALK_TEXT_COIN_FREE){
            //コインがない場合(1:無料)
            //課金画面へ
            //Util.toPurchaseViewController(animated_flg:false)
            self.noCoinDialog.isHidden = false
        }else if(self.sendFreeFlg == "2" && self.myCoin < Util.SEND_TALK_TEXT_COIN){
            //コインがない場合(2:有料)
            //課金画面へ
            //Util.toPurchaseViewController(animated_flg:false)
            self.noCoinDialog.isHidden = false
        }else{
            //トーク処理 GET:parent_rireki_id,user_id,target_id,sendtext
            if(sendTextView.text == ""){
                //空の場合何もしない
                return
            }
            
            //くるくる表示開始
            //画面サイズに合わせる
            self.busyIndicator.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(self.busyIndicator)
            
            var stringUrl = Util.URL_TALK_SEND_DO
            stringUrl.append("?user_id=")
            stringUrl.append(String(self.user_id))
            stringUrl.append("&target_id=")
            stringUrl.append(sendId)
            stringUrl.append("&sendtext=")
            stringUrl.append((sendTextView.text)!)
            stringUrl.append("&parent_rireki_id=")
            stringUrl.append(parent_rireki_id)
            stringUrl.append("&official_flg=2&open_status=3&photo_flg=0&send_point=")

            if(self.sendFreeFlg == "1"){
                //送信無料
                stringUrl.append(String(Util.SEND_TALK_TEXT_COIN_FREE))
            }else{
                //送信有料
                stringUrl.append(String(Util.SEND_TALK_TEXT_COIN))
            }
            
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
                    //do{
                    //JSONDecoderのインスタンス取得
                    //let decoder = JSONDecoder()
                    //受けとったJSONデータをパースして格納
                    //let json = try decoder.decode(ResultJson.self, from: data!)
                    
                    // UserDefaultsを使ってデータを保持する
                    //1:フリー 2:B 3:A 4:Aplus 5:s 6:ss 7:sss
                    //UserDefaults.standard.set(rank, forKey: "cast_rank")
                    
                    //print(json.result)
                    dispatchGroup.leave()//サブタスク終了時に記述
                    //}catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print("json convert failed in JSONDecoder", err?.localizedDescription)
                    //}
                })
                task.resume()
            }
            // 全ての非同期処理完了後にメインスレッドで処理
            dispatchGroup.notify(queue: .main) {
                //type= 1:マイコレクションMAX値 2:トーク開封 3:トーク送信(テキスト) 4: トーク送信(画像) 5:ライブ配信(1枠)
                var point = 0
                if(self.sendFreeFlg == "1"){
                    //送信無料
                    point = Int(Util.SEND_TALK_TEXT_COIN_FREE)
                }else{
                    //送信有料
                    point = Int(Util.SEND_TALK_TEXT_COIN)
                }
                
                /*************************************************************/
                //コイン・ポイントなどの計算処理(トークテキスト送信)
                /*************************************************************/
                //ポイントを消費
                UtilFunc.pointUseDo(type:0, userId:self.user_id, point:Double(point))
                //ポイント消費履歴に履歴を保存する
                UtilFunc.writePointUseRireki(type:3,
                                             point:Double(point),
                                             user_id:self.user_id,
                                             target_user_id:Int(self.sendId)!)
                
                /*****************************************************/
                //絆レベルの更新(絆レベルの経験値がゼロのため、現状処理をしない)
                //connect_levelの更新、pair_month_rankingの更新が必要
                //DM送信時の消費ポイント1コインにつき経験値は
                //static let CONNECTION_POINT_DM_SEND: Int = 0
                //DM開封時の消費ポイント1コインにつき経験値は
                //static let CONNECTION_POINT_DM_READ: Int = 1
                /*****************************************************/
                
                //絆レベルの更新・追加(更新後に何も処理をしない場合に使用)
                //flg:1:値プラス、2:値マイナス
                UtilFunc.saveConnectLevelNew(user_id:self.user_id, target_user_id:Int(self.sendId)!, exp:Int(point)*Util.CONNECTION_POINT_DM_SEND, live_count:0, present_point:0, flg:1)
                
                let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")
                
                //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
                UtilFunc.savePairMonthRanking(user_id:self.user_id, cast_id:Int(self.sendId)!, exp:Int(Double(point)*strConnectBonusRate))

                //くるくる表示終了
                self.busyIndicator.removeFromSuperview()
                
                //キーボードを閉じる
                self.view.endEditing(true)
                //送信完了
                self.sendTextView.text = ""
                //画面更新
                self.getTalkRirekiByUserandTarget()
                
                //絆レベルなど相手との情報を取得
                UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:Int(self.sendId)!)
                
                //ここのタイミングで相手にスターを加算
                //type:0=スターのゲット 1=スターの没収
                if(self.sendFreeFlg == "1"){
                    //送信無料
                    //何もしない
                }else{
                    //送信有料
                    //相手にスターを加算
                    UtilFunc.getStar(type:0
                        , user_id:Int(self.sendId)!
                        , star_num:Int(Util.GET_TALK_STAR))
                }
                
                /*************************************************************/
                //コイン・ポイントなどの計算処理(ここまで)
                /*************************************************************/
            }
        }
    }
    
    //公式からのお知らせに関して、既読に切り替え GET:user_id,flg(flg=1:未読 0:既読)
    func readOfficial(){
        //既読へ GET:user_id,flg
        var stringUrl = Util.URL_MODIFY_OFFICIAL_OPENFLG
        stringUrl.append("?flg=0&user_id=")
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
                    
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //既読に更新
            //Util.getNoreadCount(user_id: self.user_id)
            UserDefaults.standard.set(0, forKey: "official_read_flg")
            
            //画面更新
            //self.getTalkRirekiByUserandTarget()
        }
    }
    
    func readTalk(talk_id: Int!,open_point: Int!){
        //既読へ GET:talk_id,user_id,target_id,open_point,open_status
        var stringUrl = Util.URL_MODIFY_TALK_OPENFLG
        stringUrl.append("?talk_id=")
        stringUrl.append(String(talk_id))
        stringUrl.append("&user_id=")
        stringUrl.append(sendId)
        stringUrl.append("&target_id=")
        stringUrl.append(String(self.user_id))
        stringUrl.append("&open_point=")
        stringUrl.append(String(open_point))
        stringUrl.append("&open_status=1")
        
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
                    
                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //トークの未読数を更新
            UtilFunc.getNoreadCount(user_id: self.user_id)

            //画面更新
            self.getTalkRirekiByUserandTarget()
        }
    }

    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //UIImagePickerControllerのデリゲートメソッド
    //画像が選択された時に呼ばれる.
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
    /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
    */
            //サーバーに転送
            imageUpload(image: image, user_id: self.user_id)
        } else{
            print("Error")
        }
        // モーダルビューを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //キャンセルした時、アルバム画面を閉じます
        picker.dismiss(animated: true, completion: nil);
        //print("cancel")
    }
    
    /*
    // アルバム(Photo liblary)の閲覧権限の確認をするメソッド
    func checkPermission(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("auth")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("not Determined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        }
    }
     */

    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //フォローリストの総数
        return talkList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        //クリアする(キャッシュのクリア対応)
        let subviews = tableView.subviews
        for subview in subviews {
            UtilFunc.removeSubviews(parentView: subview)
        }
        //クリアする(ここまで)
         */
        
        //表示する1行を取得する
        let cell_user_id:Int = Int(talkList[indexPath.row].user_id)!
        
        if(self.user_id == cell_user_id){
            //自分の発言
            
            if(talkList[indexPath.row].photo_flg == "1"){
                //画像の場合
                //appDelegate.sendId = talkList[indexPath.row].target_user_id
                //cell.nameLabel.text = talkList[indexPath.row].tar_user_name
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyTalkPhoto") as! MyTalkPhotoCell
                cell.clipsToBounds = true //bound外のものを表示しない
                //cell.textView.text = talkList[indexPath.row].value01
                
                let photoUrl: String = "talk/"
                    + talkList[indexPath.row].user_id
                    + "/"
                    + talkList[indexPath.row].target_user_id
                    + "/"
                    + talkList[indexPath.row].rireki_id
                    + "_list.jpg"
                
                //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                //    cell.myTalkPhotoImageVIew.image = image?.resizeUIImageRatio(ratio: 50.0)
                //}
                //画像キャッシュを使用
                cell.myTalkPhotoImageVIew.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
                
                
                cell.myTalkPhotoImageVIew.isUserInteractionEnabled = true
                cell.myTalkPhotoImageVIew.tag = indexPath.row
                cell.myTalkPhotoImageVIew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTappedMy(_:))))
                
                // 角丸
                cell.myTalkPhotoImageVIew.layer.cornerRadius = 10
                // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                cell.myTalkPhotoImageVIew.layer.masksToBounds = true
                
                cell.timeLabel.text = talkList[indexPath.row].ins_time
                
                // セルの選択不可にする
                cell.selectionStyle = .none
                return cell
                
            }else{
                //テキストの場合
                //appDelegate.sendId = talkList[indexPath.row].target_user_id
                //cell.nameLabel.text = talkList[indexPath.row].tar_user_name
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyTalk") as! MyTalkViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                cell.textView.text = talkList[indexPath.row].value01.toHtmlString()
                cell.timeLabel.text = talkList[indexPath.row].ins_time
                
                // セルの選択不可にする
                cell.selectionStyle = .none
                return cell
            }
        //}else if(self.user_id == cell_target_user_id){
        }else{
            //相手の発言
            //appDelegate.sendId = talkList[indexPath.row].user_id
            //cell.nameLabel.text = talkList[indexPath.row].src_user_name

            if(talkList[indexPath.row].open_status == "3" && sendId != "0"){
                //未読かつモノポル公式でない場合(読むのにコインが必要)
                let cell = tableView.dequeueReusableCell(withIdentifier: "YourTalkNoread") as! YourTalkNoreadViewCell
                cell.clipsToBounds = true //bound外のものを表示しない
                //cell.textView.text = talkList[indexPath.row].value01

                //画像の選択
                var targetUserImage = ""

                //一般ユーザー画像の表示
                if(sendPhotoFlg == "1"){
                    //写真設定済み
                    //let photoUrl = "user_images/" + sendId + "_profile.jpg"
                    let photoUrl = "user_images/" + sendId + "/" + sendPhotoName + "_profile.jpg"

                    //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                    //    cell.yourImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                    //}
                    //画像キャッシュを使用
                    cell.yourImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                }else{
                    targetUserImage = "no_image"
                    // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                    let cellImage = UIImage(named: targetUserImage)
                    // UIImageをUIImageViewのimageとして設定
                    cell.yourImageView.image = cellImage
                }
                
                cell.yourImageView.isUserInteractionEnabled = true
                cell.yourImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
                
                //コインがあるかないかの判断
                if(self.myCoin < Util.READ_TALK_COIN){
                    //コインがない場合
                    cell.noCoinView.isHidden = false
                }else{
                    cell.noCoinView.isHidden = true
                }

                cell.timeLabel.text = talkList[indexPath.row].ins_time
                
                // セルの選択不可にする
                cell.selectionStyle = .none
                return cell
            }else{
                if(talkList[indexPath.row].photo_flg == "1"){
                    //画像かつ既読の場合
                    let cell = tableView.dequeueReusableCell(withIdentifier: "YourTalkPhoto") as! YourTalkPhotoCell
                    cell.clipsToBounds = true //bound外のものを表示しない
                    //cell.textView.text = talkList[indexPath.row].value01
                    
                    let photoUrl: String = "talk/"
                        + talkList[indexPath.row].user_id
                        + "/"
                        + talkList[indexPath.row].target_user_id
                        + "/"
                        + talkList[indexPath.row].rireki_id
                        + "_list.jpg"
                    
                    //print(photoUrl)
                    
                    //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                    //    cell.talkImageView.image = image?.resizeUIImageRatio(ratio: 50.0)
                    //}
                    
                    //画像キャッシュを使用
                    cell.talkImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"demo_noimage")
                    
                    cell.talkImageView.isUserInteractionEnabled = true
                    cell.talkImageView.tag = indexPath.row
                    cell.talkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(_:))))
                    
                    // 角丸
                    cell.talkImageView.layer.cornerRadius = 10
                    // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
                    cell.talkImageView.layer.masksToBounds = true
                    
                    //画像の選択
                    var targetUserImage = ""
                    if(sendId == "0"){
                        //モノポル公式
                        targetUserImage = "monopol_office"
                        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                        let cellImage = UIImage(named: targetUserImage)
                        // UIImageをUIImageViewのimageとして設定
                        cell.yourImageView.image = cellImage
                    }else{
                        //一般ユーザー画像の表示
                        if(sendPhotoFlg == "1"){
                            //写真設定済み
                            //let photoUrl = "user_images/" + sendId + "_profile.jpg"
                            let photoUrl = "user_images/" + sendId + "/" + sendPhotoName + "_profile.jpg"

                            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                            //    cell.yourImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                            //}
                            //画像キャッシュを使用
                            cell.yourImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                            
                        }else{
                            targetUserImage = "no_image"
                            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                            let cellImage = UIImage(named: targetUserImage)
                            // UIImageをUIImageViewのimageとして設定
                            cell.yourImageView.image = cellImage
                        }
                        
                        cell.yourImageView.isUserInteractionEnabled = true
                        cell.yourImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
                    }

                    cell.timeLabel.text = talkList[indexPath.row].ins_time
                    
                    // セルの選択不可にする
                    cell.selectionStyle = .none
                    return cell
                }else{
                    //テキストかつ既読の場合
                    let cell = tableView.dequeueReusableCell(withIdentifier: "YourTalk") as! YourTalkViewCell
                    cell.clipsToBounds = true //bound外のものを表示しない
                    cell.textView.text = talkList[indexPath.row].value01.toHtmlString()
                    
                    //画像の選択
                    var targetUserImage = ""
                    if(sendId == "0"){
                        //モノポル公式
                        targetUserImage = "monopol_office"
                        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                        let cellImage = UIImage(named: targetUserImage)
                        // UIImageをUIImageViewのimageとして設定
                        cell.yourImageView.image = cellImage
                    }else{
                        //一般ユーザー画像の表示
                        if(sendPhotoFlg == "1"){
                            //写真設定済み
                            //let photoUrl = "user_images/" + sendId + "_profile.jpg"
                            let photoUrl = "user_images/" + sendId + "/" + sendPhotoName + "_profile.jpg"

                            //UIImage.contentOfFIRStorage(path: photoUrl) { image in
                            //    cell.yourImageView.image = image?.resizeUIImageRatio(ratio: 90.0)
                            //}
                            //画像キャッシュを使用
                            cell.yourImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
                            
                        }else{
                            targetUserImage = "no_image"
                            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                            let cellImage = UIImage(named: targetUserImage)
                            // UIImageをUIImageViewのimageとして設定
                            cell.yourImageView.image = cellImage
                        }
                        
                        cell.yourImageView.isUserInteractionEnabled = true
                        cell.yourImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClickCastInfo(_:))))
                    }

                    cell.timeLabel.text = talkList[indexPath.row].ins_time
                    
                    // セルの選択不可にする
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
    }
    
    @objc func onClickCastInfo(_ sender: UITapGestureRecognizer){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender)
        //let buttonRow = sender.tag
        //let buttonRow = sender.view?.tag
        //キャストのuser_idを次の画面（キャスト詳細画面）へ渡す
        //sendIdはすでに指定済み
        UtilToViewController.toUserInfoViewController()
    }
    
    // 画像がタップされたら呼ばれる(相手の画像)
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view?.tag
        //print("タップ")
        //マイコレクションの個別画面へ渡す
        appDelegate.myCollectionType = "5"
        appDelegate.myCollectionSelectCastId = appDelegate.sendId//相手のID
        appDelegate.myCollectionSelectCastName = appDelegate.sendUserName//相手の名前
        appDelegate.myCollectionSelectInsTime = talkList[buttonRow!].ins_time
        appDelegate.myCollectionSelectPhotoFileName = talkList[buttonRow!].rireki_id
        
        UtilToViewController.toCollectionImageViewController(animated_flg:false)
    }
    
    // 画像がタップされたら呼ばれる(自分の画像)
    @objc func imageViewTappedMy(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view?.tag
        //print("タップ")
        //マイコレクションの個別画面へ渡す
        appDelegate.myCollectionType = "4"
        appDelegate.myCollectionSelectCastId = appDelegate.sendId//相手のID
        appDelegate.myCollectionSelectCastName = UserDefaults.standard.string(forKey: "myName")!//自分の名前
        appDelegate.myCollectionSelectInsTime = talkList[buttonRow!].ins_time
        appDelegate.myCollectionSelectPhotoFileName = talkList[buttonRow!].rireki_id
        
        UtilToViewController.toCollectionImageViewController(animated_flg:false)
    }
    
    // Cell が選択された場合
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {

        self.myCoin = UserDefaults.standard.double(forKey: "myPoint")
        
        let cell_user_id:Int = Int(talkList[indexPath.row].user_id)!
        let cell_talk_id:Int = Int(talkList[indexPath.row].rireki_id)!

        //print(String(cell_user_id))
        //print(String(cell_talk_id))
        
        if(self.user_id == cell_user_id || sendId == "0"){
            //自分の発言orモノポル公式
            //何もしない
        }else{
            //相手の発言
            if(talkList[indexPath.row].open_status == "3"){
                //未読
                //コインがあるかないかの判断
                if(self.myCoin < Util.READ_TALK_COIN){
                    //コインがない場合
                    //課金画面へ
                    //Util.toPurchaseViewController(animated_flg:false)
                    self.noCoinDialog.isHidden = false
                }else{
                    //コインがある場合は、開封しますかのダイアログ表示
                    let actionAlert = UIAlertController(title: Util.READ_TALK_STR, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                    
                    //UIAlertControllerにアクションを追加する
                    let modifyAction = UIAlertAction(title: "開封する", style: UIAlertAction.Style.default, handler: {
                        (action: UIAlertAction!) in
                        //選択された時の処理
                        
                        //未読・既読切り替え GET:talk_id,user_id,target_id,open_point,open_status
                        //Util.URL_MODIFY_TALK_OPENFLG
                        self.readTalk(talk_id: cell_talk_id,open_point: Int(Util.READ_TALK_COIN))
                        
                        //type= 1:マイコレクションMAX値 2:トーク開封 3:トーク送信(テキスト) 4: トーク送信(画像) 5:ライブ配信(1枠)
                        //let uuid = UserDefaults.standard.string(forKey: "uuid")
                        
                        /*************************************************************/
                        //コイン・ポイントなどの計算処理(トーク開封)
                        /*************************************************************/
                        //コインを消費
                        UtilFunc.pointUseDo(type:0, userId:self.user_id, point:Util.READ_TALK_COIN)
                        //コイン消費履歴に履歴を保存する
                        UtilFunc.writePointUseRireki(type:2,
                                                     point:Util.READ_TALK_COIN,
                                                     user_id:self.user_id,
                                                     target_user_id:cell_user_id)
                        
                        //絆レベルの更新
                        //connect_levelの更新、pair_month_rankingの更新が必要
                        //DM開封時の消費ポイント1コインにつき経験値は
                        //static let CONNECTION_POINT_DM_READ: Int = 1
                        //取得する絆レベルの経験値
                        let exp_temp = Int(Util.READ_TALK_COIN) * Util.CONNECTION_POINT_DM_READ

                        //絆レベルの更新・追加(更新後に何も処理をしない場合に使用)
                        //flg:1:値プラス、2:値マイナス
                        UtilFunc.saveConnectLevelNew(user_id:self.user_id, target_user_id:cell_user_id, exp:exp_temp, live_count:0, present_point:0, flg:1)
                        
                        let strConnectBonusRate = UserDefaults.standard.double(forKey:"sendConnectBonusRate")
                        
                        //ペアランキング(課金ポイント)の更新・追加(更新後に何も処理をしない場合に使用)
                        UtilFunc.savePairMonthRanking(user_id:self.user_id, cast_id:Int(self.sendId)!, exp:Int(Double(Util.READ_TALK_COIN)*strConnectBonusRate))
                        
                        //絆レベルなど相手との情報を取得
                        UtilFunc.getConnectInfo(my_user_id:self.user_id, target_user_id:Int(self.sendId)!)
                        //self.getConnectInfo()
                        
                        //ペアランキング(絆ランキング)の更新・追加(更新後に何も処理をしない場合に使用)
                        //flg:1:値プラス、2:値マイナス
                        //Util.savePairMonthRankingNew(user_id:self.user_id, cast_id:cell_user_id, exp:exp_temp, flg:1)
                        /*************************************************************/
                        //コイン・ポイントなどの計算処理(ここまで)
                        /*************************************************************/
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
                
            }else{
                //既読
                //何もしない
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(talkList[indexPath.row].photo_flg == "1"
            && (talkList[indexPath.row].open_status == "1" || self.user_id == Int(talkList[indexPath.row].user_id))){
            //「既読かつ写真」または自分の投稿写真の場合
            return 200
        }else{
            //それ以外
            return UITableView.automaticDimension //変更
        }
    }
 
    //tableviewの上部の空白を削除する(swift4)
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: UITextFieldDelegate
//キーボードが隠れてしまう問題の対応
extension TalkInfoViewController: UITextFieldDelegate {
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        if(self.keyboardFlg == 0){
            let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            UIView.animate(withDuration: duration!, animations: { () in
                let transform = CGAffineTransform(translationX: 0, y: -((rect?.size.height)! + 26))
                self.view.transform = transform
            })
            
            //self.sexBtn.isEnabled = false
            /*
             if coverView == nil {
             coverView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
             // coverViewの背景
             coverView.backgroundColor = UIColor.black
             // 透明度を設定
             coverView.alpha = 0.1
             coverView.isUserInteractionEnabled = true
             self.view.addSubview(coverView)
             }
             coverView.isHidden = false
             */
        }
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
        
        //self.sexBtn.isEnabled = true
        //coverView.isHidden = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
        return true
    }
    
    // became first responder
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //名前のところ
        //@IBOutlet weak var nameTextField: KeyBoard!
        //HPのところ
        //@IBOutlet weak var hpTextField: KeyBoard!
        //プロフィールのところ
        //@IBOutlet weak var profileTextView: PlaceHolderTextView!
        //if(textField.tag == 1 || textField.tag == 2 || textField.tag == 3){
        //    self.keyboardFlg = 1//キーボードを表示する場合に上にずらさない
        //}else{
        self.keyboardFlg = 0
        //}
    }
}
