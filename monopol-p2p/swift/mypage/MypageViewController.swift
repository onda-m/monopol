//
//  MypageViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/03.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
//import Alamofire
//import FirebaseStorage

class MypageViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let iconSize: CGFloat = 12.0
    //let iconSize2: CGFloat = 14.0
    //let FOLLOW_VIEW_Y = 310//フォロー関連のVIEWのY座標
    //let MENU_VIEW_Y = 376//メニュー関連のVIEWのY座標
    //let SCROLL_VIEW_HEIGHT = 142//スクロール部分の高さ
    //let SCROLL_VIEW_ALL = 46 * 8//スクロール部分の高さ

    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 画像のupload・表示用
    //let storageRef = Storage.storage().reference(forURL: Util.URL_FIREBASE)

    @IBOutlet weak var mypageMenuTable: UITableView!
    @IBOutlet weak var noTextMypageMenuTable: UITableView!
    
    @IBOutlet weak var userImageView: EnhancedCircleImageView!
    @IBOutlet weak var nameLbl: UILabel!
    //@IBOutlet weak var mainScrollView: UIScrollView!
    
    //フリーテキスト
    @IBOutlet weak var freetextTextView: UITextView!
    
    /*
    @IBOutlet weak var homepageBtn: UIButton!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    */
    
    //右：視聴レベル
    @IBOutlet weak var watchLvLbl: UILabel!
    //左：配信レベル
    @IBOutlet weak var liveLvLbl: UILabel!
    
    //フリーテキストがありの場合用
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followerCountLbl: UILabel!
    @IBOutlet weak var followCountLbl: UILabel!
    
    @IBOutlet weak var noTextMainView: UIView!
    @IBOutlet weak var noTextFollowerView: UIView!
    @IBOutlet weak var noTextFollowView: UIView!
    @IBOutlet weak var noTextFollowerCountLbl: UILabel!
    @IBOutlet weak var noTextFollowCountLbl: UILabel!
    
    //メニューの配列
    //let mypageMenuStr = ["視聴履歴","マイコイン","フォロー管理","マイコレクション","プレゼントショップ","配信ランクの設定","配信レポート","プレミアムアカウント","設定"]
    //let mypageMenuStr = ["視聴履歴","マイコイン","フォロー管理","マイコレクション","プレゼントショップ","配信ランクの設定","配信レポート","設定"]
    //let mypageMenuStr = ["視聴履歴","マイコイン","フォロー管理","プレゼントショップ","配信ランクの設定","配信レポート","設定"]
    let mypageMenuStr = ["視聴履歴","マイコイン","フォロー管理","プレゼントショップ","サシライブの有料設定","配信レポート","イベント確認","設定"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        //引き継ぎ後に戻ってきたときに画像が表示されなかったので下記を追加
        //画像が設定されていたら表示
        let photoFlg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
        let photoName = UserDefaults.standard.string(forKey: "myPhotoName")
        
        if(photoFlg == 1){
            //写真設定済み
            let photoUrl = "user_images/" + String(self.user_id) + "/" + photoName! + "_profile.jpg"
            //画像キャッシュを使用
            self.userImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
            //ツールバー上のプロフィール画像をセット
            self.mainToolbarView.profileImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
            self.mainToolbarView.profileImageView.isHidden = false
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            self.userImageView.image = cellImage
            
            //ツールバー上のプロフィール画像をセット
            //self.mainToolbarView.profileImageView.image = cellImage
            self.mainToolbarView.profileImageView.isHidden = true
        }
         */
    }

    // 画像がタップされたら呼ばれる
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        
        //アルバムへのアクセス許可
        //UtilFunc.checkPermissionAlbumn()
        
        let photoLibraryManager = PhotoLibraryManager.init(parentViewController: self)
        //photoLibraryManager.requestAuthorizationOn()
        photoLibraryManager.callPhotoLibrary()
        
        /*
        // アルバム(Photo liblary)の閲覧権限の確認
        Util.checkPermission()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            // 下記を追加する
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
        */
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //コインの数を更新
        //所有しているコインの設定
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        //self.mainToolbarView.pointBtn.setTitle(UtilFunc.numFormatter(num: Int(myPoint)), for: .normal)
        self.mainToolbarView.pointBtn.setTitle(" " + UtilFunc.numFormatter(num: Int(myPoint)), for: .normal)
        
        //テーブルの区切り線を非表示
        //self.noticeTableView.separatorColor = UIColor.clear
        self.mypageMenuTable.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.mypageMenuTable.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        //self.mypageMenuTable.allowsSelection = true // 選択を可にする
        self.mypageMenuTable.isScrollEnabled = true
        self.mypageMenuTable.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        //tableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.mypageMenuTable.register(UINib(nibName: "MypageMenuViewCell", bundle: nil), forCellReuseIdentifier: "MypageMenuViewCell")
        //self.bottomView = ChatRoomInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)) // 下部に表示するテキストフィールドを設定
        //CollectionView.reloadData()
        
        //テーブルの区切り線を非表示
        //self.noticeTableView.separatorColor = UIColor.clear
        self.noTextMypageMenuTable.estimatedRowHeight = 10000 // セルが高さ以上になった場合バインバインという動きをするが、それを防ぐために大きな値を設定
        self.noTextMypageMenuTable.rowHeight = UITableView.automaticDimension // Contentに合わせたセルの高さに設定
        //self.noTextMypageMenuTable.allowsSelection = true // 選択を可にする
        self.noTextMypageMenuTable.isScrollEnabled = true
        self.noTextMypageMenuTable.keyboardDismissMode = .interactive // テーブルビューをキーボードをまたぐように下にスワイプした時にキーボードを閉じる
        //tableView.register(UINib(nibName: "YourChatViewCell", bundle: nil), forCellReuseIdentifier: "YourChat")
        self.noTextMypageMenuTable.register(UINib(nibName: "MypageMenuViewCell", bundle: nil), forCellReuseIdentifier: "MypageMenuViewCell")
        //self.bottomView = ChatRoomInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)) // 下部に表示するテキストフィールドを設定
        //CollectionView.reloadData()
        
        //--の配信ルーム
        //名前をセットする
        nameLbl.text = UserDefaults.standard.string(forKey: "myName")!
        //ラベルの枠を自動調節する
        nameLbl.adjustsFontSizeToFitWidth = true
        nameLbl.minimumScaleFactor = 0.3
        
        //フォロー数、フォロワー数の設定
        //UserDefaults.standard.set(0, forKey: "follow_num")
        //UserDefaults.standard.set(0, forKey: "follower_num")
        let follow_num: Int = UserDefaults.standard.integer(forKey: "follow_num")
        let follower_num: Int = UserDefaults.standard.integer(forKey: "follower_num")
        followCountLbl.text = String(follow_num)
        followerCountLbl.text = String(follower_num)
        noTextFollowCountLbl.text = String(follow_num)
        noTextFollowerCountLbl.text = String(follower_num)
        
        //左が配信レベル、右が視聴レベル
        // 角丸
        self.watchLvLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.watchLvLbl.layer.masksToBounds = true
        self.watchLvLbl.backgroundColor = Util.CAST_INFO_COLOR_WATCH_LV_LABEL
        //ラベルの枠を自動調節する
        self.watchLvLbl.adjustsFontSizeToFitWidth = true
        self.watchLvLbl.minimumScaleFactor = 0.3
        
        // 角丸
        self.liveLvLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.liveLvLbl.layer.masksToBounds = true
        self.liveLvLbl.backgroundColor = Util.CAST_INFO_COLOR_LIVE_LV_LABEL
        //ラベルの枠を自動調節する
        self.liveLvLbl.adjustsFontSizeToFitWidth = true
        self.liveLvLbl.minimumScaleFactor = 0.3
        
        //UserDefaults.standard.set(strWatchLevel, forKey: "myWatchLevel")
        //UserDefaults.standard.set(strLiveLevel, forKey: "myLiveLevel")
        let watch_level: Int = UserDefaults.standard.integer(forKey: "myWatchLevel")
        let live_level: Int = UserDefaults.standard.integer(forKey: "myLiveLevel")
        //watchLvLbl.text = "Lv:" + String(watch_level)
        //liveLvLbl.text = "Lv:" + String(live_level)
        
        //self.liveLevelLbl.text = "Lv:" + Util.numFormatter(num:Int(self.strLiveLevel)!)
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.liveLvLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:live_level), iconImage: UIImage(named:"castinfo_live_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
        
        //self.watchLevelLbl.text = "Lv:" + Util.numFormatter(num:Int(self.strWatchLevel)!)
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.watchLvLbl.attributedText = UtilFunc.getInsertIconString(string: UtilFunc.numFormatter(num:watch_level), iconImage: UIImage(named:"castinfo_viewing_lv")!, iconSize: self.iconSize, lineHeight: 1.0)
        
        // 角丸
        //freetextTextView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //freetextTextView.layer.masksToBounds = true
        
        // 枠線の色
        self.followerView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOWER_FRAME.cgColor
        // 枠線の太さ
        self.followerView.layer.borderWidth = 0.5
        // 角丸
        self.followerView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.followerView.layer.masksToBounds = true
        
        // 枠線の色
        self.followView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        self.followView.layer.borderWidth = 0.5
        // 角丸
        self.followView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.followView.layer.masksToBounds = true
        
        // 枠線の色
        self.noTextFollowerView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOWER_FRAME.cgColor
        // 枠線の太さ
        self.noTextFollowerView.layer.borderWidth = 0.5
        // 角丸
        self.noTextFollowerView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.noTextFollowerView.layer.masksToBounds = true
        
        // 枠線の色
        self.noTextFollowView.layer.borderColor = Util.CAST_INFO_COLOR_FOLLOW_FRAME.cgColor
        // 枠線の太さ
        self.noTextFollowView.layer.borderWidth = 0.5
        // 角丸
        self.noTextFollowView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.noTextFollowView.layer.masksToBounds = true
        
        //画像が設定されていたら表示
        let photoFlg = UserDefaults.standard.integer(forKey: "myPhotoFlg")
        let photoName = UserDefaults.standard.string(forKey: "myPhotoName")
        
        if(photoFlg == 1){
            //写真設定済み
            let photoUrl = "user_images/" + String(self.user_id) + "/" + photoName! + "_profile.jpg"
            //画像キャッシュを使用
            self.userImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
            //ツールバー上のプロフィール画像をセット
            self.mainToolbarView.profileImageView.setImageListByPINRemoteImage(ratio: 0.0, path: photoUrl, no_image_named:"no_image")
            
            self.mainToolbarView.profileImageView.isHidden = false
        }else{
            let cellImage = UIImage(named:"no_image")
            // UIImageをUIImageViewのimageとして設定
            self.userImageView.image = cellImage
            
            //ツールバー上のプロフィール画像をセット
            //self.mainToolbarView.profileImageView.image = cellImage
            self.mainToolbarView.profileImageView.isHidden = true
        }
        
        self.viewLoad()
    }
    
    func viewLoad(){
        //フリーテキストのところ
        let strFreetext = UserDefaults.standard.string(forKey: "freetext")!
        let strHomepage = UserDefaults.standard.string(forKey: "homepage")!
        let strTwitter = UserDefaults.standard.string(forKey: "twitter")!
        let strFacebook = UserDefaults.standard.string(forKey: "facebook")!
        let strInstagram = UserDefaults.standard.string(forKey: "instagram")!
        
        var strFreeTextTemp = ""
        if(strFreetext != "" && strFreetext != "0" && strFreetext != "'0'"){
            strFreeTextTemp = strFreetext
        }
        if(strHomepage != "" && strHomepage != "0"){
            strFreeTextTemp.append("\n")
            strFreeTextTemp.append(strHomepage)
        }
        if(strTwitter != "" && strTwitter != "0"){
            strFreeTextTemp.append("\n")
            strFreeTextTemp.append(strTwitter)
        }
        if(strFacebook != "" && strFacebook != "0"){
            strFreeTextTemp.append("\n")
            strFreeTextTemp.append(strFacebook)
        }
        if(strInstagram != "" && strInstagram != "0"){
            strFreeTextTemp.append("\n")
            strFreeTextTemp.append(strInstagram)
        }
        
        //テスト用
        //strFreeTextTemp = "aiueoaiueo https://abd.jp"
        
        self.freetextTextView.text = strFreeTextTemp
        // リンクを自動的に検出してリンクに変換する
        // 編集不可にする
        self.freetextTextView.isEditable = false
        // textViewのtextにURLの文字列があればリンクとして認識する
        self.freetextTextView.dataDetectorTypes = .link
        
        /*
         if(strFreeTextTemp == ""){
         self.freetextTextView.isHidden = true
         //上に詰める処理
         //self.upView.frame = CGRect(x: self.upView.frame.origin.x, y: self.upView.frame.origin.y, width: self.upView.frame.width, height: self.upView.frame.height)
         self.mainScrollView.frame = CGRect(x: self.mainScrollView.frame.origin.x, y: self.mainScrollView.frame.origin.y - 90, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
         
         self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height + 160)
         }else{
         self.freetextTextView.isHidden = false
         
         self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height + 240)
         }
         */
        
        //プレミアムアカウントをコメントアウトしたVer
        if(strFreeTextTemp == ""){
            self.freetextTextView.isHidden = true
            self.mainView.isHidden = true
            self.noTextMainView.isHidden = false
            //上に詰める処理
            //self.upView.frame = CGRect(x: self.upView.frame.origin.x, y: self.upView.frame.origin.y, width: self.upView.frame.width, height: self.upView.frame.height)
            
            /*
            self.followerView.frame = CGRect(x: self.followerView.frame.origin.x, y: CGFloat(FOLLOW_VIEW_Y) - 90, width: self.followerView.frame.width, height: self.followerView.frame.height)
            
            self.followView.frame = CGRect(x: self.followView.frame.origin.x, y: CGFloat(FOLLOW_VIEW_Y) - 90, width: self.followView.frame.width, height: self.followView.frame.height)
            
            self.mypageMenuTable.frame = CGRect(x: 0, y: 0, width: self.mypageMenuTable.frame.width, height: CGFloat(SCROLL_VIEW_HEIGHT) + 90)
            
            self.mainScrollView.frame = CGRect(x: self.mainScrollView.frame.origin.x, y: CGFloat(MENU_VIEW_Y) - 90, width: self.mainScrollView.frame.width, height: CGFloat(SCROLL_VIEW_HEIGHT) + 90)
            */
            //self.mypageMenuTable.contentSize = CGSize(width: self.mypageMenuTable.frame.width, height: CGFloat(self.mypageMenuStr.count) * 46 + )
        }else{
            //自己紹介がある場合(自己紹介を編集して戻ってきた場合のためにここで画面サイズの調整をする)
            self.freetextTextView.isHidden = false
            self.mainView.isHidden = false
            self.noTextMainView.isHidden = true
            
            /*
            self.followerView.frame = CGRect(x: self.followerView.frame.origin.x, y: CGFloat(FOLLOW_VIEW_Y), width: self.followerView.frame.width, height: self.followerView.frame.height)
                
            self.followView.frame = CGRect(x: self.followView.frame.origin.x, y: CGFloat(FOLLOW_VIEW_Y), width: self.followView.frame.width, height: self.followView.frame.height)
                
            self.mypageMenuTable.frame = CGRect(x: 0, y: 0, width: self.mypageMenuTable.frame.width, height: CGFloat(SCROLL_VIEW_HEIGHT))

            self.mainScrollView.frame = CGRect(x: self.mainScrollView.frame.origin.x, y: CGFloat(MENU_VIEW_Y), width: self.mainScrollView.frame.width, height: CGFloat(SCROLL_VIEW_HEIGHT))
            */
            //self.mypageMenuTable.contentSize = CGSize(width: self.mypageMenuTable.frame.width, height: CGFloat(self.mypageMenuStr.count) * 46)
        }
        
        //print(self.mypageMenuTable.contentSize)
        
        //self.mainScrollView.contentSize = CGSize(width: self.mainScrollView.frame.width, height: CGFloat(self.mypageMenuStr.count) * 46)
        
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MypageViewController.imageViewTapped(_:))))

    }
    
    /*
    @IBAction func tapHomepageBtn(_ sender: Any) {
        let strHomepage = UserDefaults.standard.string(forKey: "homepage")!
        let url = NSURL(string: strHomepage)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func tapTwitterBtn(_ sender: Any) {
        let strTwitter = UserDefaults.standard.string(forKey: "twitter")!
        let url = NSURL(string: strTwitter)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func tapFacebookBtn(_ sender: Any) {
        let strFacebook = UserDefaults.standard.string(forKey: "facebook")!
        let url = NSURL(string: strFacebook)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func tapInstagramBtn(_ sender: Any) {
        let strInstagram = UserDefaults.standard.string(forKey: "instagram")!
        let url = NSURL(string: strInstagram)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            //let fileName = String(user_id) + "_profile.jpg"
            let fileName = file_name_temp + "_profile.jpg"

            //let body = Util.httpBody(profiledata,fileName: fileName)
            let body = UtilFunc.httpBodyAlpha(profiledata, fileName: fileName, castId: "0", userId: String(user_id))

            //let url = URL(string: Util.URL_SAVE_PHOTO)!
            UtilFunc.fileUpload(URL(string: Util.URL_SAVE_PHOTO)!, data: body) {(data, response, error) in
                if let response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                    if response.statusCode == 200 {
                        //print("Upload done")
                        //ボタンの背景に選択した画像を設定
                        self.userImageView.image = profileImage
                        //ツールバー上のプロフィール画像をセット
                        self.mainToolbarView.profileImageView.image = profileImage
                        //self.mainToolbarView.profileImageView.isHidden = false

                        DispatchQueue.main.async {
                            // このタイミングでモーダルビューを閉じる
                            self.mainToolbarView.profileImageView.isHidden = false
                            self.dismiss(animated: true, completion: nil)
                            //UtilToViewController.toMypageViewController()
                        }

                    } else {
                        //self.mainToolbarView.profileImageView.isHidden = true
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
                        //print("Upload done")
                        //ボタンの背景に選択した画像を設定
                        //self.userImageView.image = profileImage
                        //ツールバー上のプロフィール画像をセット
                        //self.mainToolbarView.profileImageView.image = profileImage
                    } else {
                        //self.mainToolbarView.profileImageView.isHidden = true
                        //print(response.statusCode)
                    }
                }
            }
        }

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
                        UtilFunc.modifyPhotoFlg(user_id:self.user_id, photo_flg:1, photo_name: file_name_temp)
                        UserDefaults.standard.set(1, forKey: "myPhotoFlg")
                        UserDefaults.standard.set(file_name_temp, forKey: "myPhotoName")

                        //ボタンの背景に選択した画像を設定
                        self.userImageView.image = profileImage
                        //ツールバー上のプロフィール画像をセット
                        self.mainToolbarView.profileImageView.image = profileImage
                    } else {
                        //self.mainToolbarView.profileImageView.isHidden = true
                        //print(response.statusCode)
                    }
                }
            }
        }
    }
    
    //UIImagePickerControllerのデリゲートメソッド
    //画像が選択された時に呼ばれる.
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //サーバーに転送
            imageUpload(image: image, user_id: self.user_id)
        } else{
            print("Error")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //キャンセルした時、アルバム画面を閉じます
        picker.dismiss(animated: true, completion: nil);
        //print("cancel")
        
        //self.viewLoad()
        UtilToViewController.toMypageViewController()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //TableViewのdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //マイページ-メニューの総数
        return mypageMenuStr.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示する1行を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "MypageMenuViewCell") as! MypageMenuViewCell
        cell.clipsToBounds = true //bound外のものを表示しない
        cell.mypageMenuLbl.text = mypageMenuStr[indexPath.row]
        
        if(indexPath.row == 0){
            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
            let cellImage = UIImage(named: "mypage_01_live_history")
            cell.mypageImageIcon.image = cellImage
        }else if(indexPath.row == 1){
            let cellImage = UIImage(named: "mypage_02_my_coin")
            cell.mypageImageIcon.image = cellImage
        }else if(indexPath.row == 2){
            let cellImage = UIImage(named: "mypage_03_follow_setting")
            cell.mypageImageIcon.image = cellImage
        //}else if(indexPath.row == 3){
        //    let cellImage = UIImage(named: "mypage_04_my_collection")
        //    cell.mypageImageIcon.image = cellImage
        }else if(indexPath.row == 3){
            let cellImage = UIImage(named: "mypage_05_gift_shop")
            cell.mypageImageIcon.image = cellImage
        }else if(indexPath.row == 4){
            let cellImage = UIImage(named: "mypage_06_live_rank")
            cell.mypageImageIcon.image = cellImage
        }else if(indexPath.row == 5){
            
            let requestRirekiNoreadCount = UserDefaults.standard.integer(forKey: "requestRirekiNoreadCount")
            
            if(requestRirekiNoreadCount > 0){
                //未読があればこちらの画像
                let cellImage = UIImage(named: "mypage_07_live_report_notice")
                cell.mypageImageIcon.image = cellImage
            }else{
                let cellImage = UIImage(named: "mypage_07_live_report")
                cell.mypageImageIcon.image = cellImage
            }
        }else if(indexPath.row == 6){
            let cellImage = UIImage(named: "mypage_09_event_info")
            cell.mypageImageIcon.image = cellImage
        }else if(indexPath.row == 7){
            let cellImage = UIImage(named: "mypage_08_setting")
            cell.mypageImageIcon.image = cellImage
        }
        
        //ボタンを隠す
        //cell.followBtn.isHidden = true
        //cell.kokuchiBtn.isHidden = true
        
        // 選択された背景色
        //let cellSelectedBgView = UIView()
        //cellSelectedBgView.backgroundColor = UIColor.clear
        //cell.selectedBackgroundView = cellSelectedBgView
        
        if(mypageMenuStr.count == indexPath.row + 1){
            //最終行の下には横のラインは不要
            cell.lineView.isHidden = true
        }else{
            cell.lineView.isHidden = false
        }

        cell.selectBtn.tag = indexPath.row
        //ボタンを押した時の処理
        cell.selectBtn.addTarget(self, action: #selector(onClickSelectBtn(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    @objc func onClickSelectBtn(sender: UIButton){
        //ボタンが押されるとこの関数が呼ばれる
        
        //print(sender.tag)
        // [indexPath.row] から画面IDを探し、画面遷移
        let selected = sender.tag
        if(selected == 0){
            //視聴履歴へ
            UtilToViewController.toWatchRirekiViewController(animated_flg:false)
        }else if(selected == 1){
            //マイコインへ
            UtilToViewController.toPurchaseViewController(animated_flg:false)
        }else if(selected == 2){
            //フォロー管理へ
            UtilToViewController.toFollowManageViewController(animated_flg:false)
        //}else if(selected == 3){
        //    //マイコレクションへ
        //    UtilToViewController.toMyCollectionViewController(animated_flg:false)
        }else if(selected == 3){
            //プレゼントショップへ
            UtilToViewController.toPresentShopViewController(animated_flg:false)
        }else if(selected == 4){
            //配信ランクの設定へ
            //配信レベル
            let myLiveLevel = UserDefaults.standard.integer(forKey: "myLiveLevel")
            //現在の配信ポイント(累計)
            let myLivePoint = UserDefaults.standard.integer(forKey: "myLivePoint")
            
            //個別設定の有無
            //個別設定がしてある場合は強制的に「有料サシライブ」の方へ
            //個別設定がされているかのフラグ（１：されている　２：されていない）
            //UserDefaults.standard.set("1", forKey: "streamer_individual_setting_flg")
            //let streamerIndividualSettingFlg = UserDefaults.standard.integer(forKey: "streamer_individual_setting_flg")
            
            //1個別設定有効2無効3設定済み無効
            //UserDefaults.standard.set(strExStatus, forKey: "ex_status")
            let exStatus = UserDefaults.standard.integer(forKey: "ex_status")
            
            if(exStatus == 1 || exStatus == 3){
                //個別設定されている
                UtilToViewController.toPriceSettingUpgradeViewController(animated_flg: false)
            }else{
                //レベルが１０以上か、配信ポイントが３０００以上
                if(myLiveLevel >= 10 || myLivePoint > Util.FREE_LIVE_POINT_MAX){
                    UtilToViewController.toPriceSettingUpgradeViewController(animated_flg: false)
                }else{
                    UtilToViewController.toPriceSettingViewController(animated_flg:false)
                }
            }
        }else if(selected == 5){
            //配信レポートへ
            UtilToViewController.toLiveReportViewController(animated_flg:false)
        }else if(selected == 6){
            //イベント確認画面へ
            UtilToViewController.toMyEventCheckViewController(animated_flg:false)
        }else if(selected == 7){
            //設定へ
            UtilToViewController.toUserSettingViewController()
        }
    }
}

/*
//tableviewの上部の空白を削除する(swift4)
// MARK: - UITableViewDelegate
extension MypageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
*/
