//
//  ProfileSettingViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/27.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class ProfileSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITabBarDelegate{

    private var myTabBar:UITabBar!
    //var coverView: UIView!//キーボード以外を覆うVIEW
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var keyboardFlg = 0//1の時はキーボードをずらさずに表示する
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
    var selected_menu_num = 5
    
    // 選択肢
    let dataList = ["女性", "男性"]
    var sexCd: Int = 0
    
    //IDのところ
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var idLbl: UILabel!
    
    //名前のところ
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextField: KeyBoard!

    //HPのところ
    @IBOutlet weak var hpView: UIView!
    @IBOutlet weak var hpTextField: KeyBoard!
    
    //プロフィールのところ
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileTextView: PlaceHolderTextView!
    
    //性別のところ
    @IBOutlet weak var sexView: UIView!
    @IBOutlet weak var sexBtn: UIButton!
    
    //Twitterのところ
    @IBOutlet weak var twitterView: UIView!
    @IBOutlet weak var twitterTextField: KeyBoard!

    //Facebookのところ
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var facebookTextField: KeyBoard!
    
    //Instagramのところ
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var instagramTextField: KeyBoard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ステタースバーの背景を直接操作する方法はないので、同サイズのViewを敷きつめることにより実現
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 50.0))
        statusBar.backgroundColor = Util.BAR_BG_COLOR
        view.addSubview(statusBar)

        /***********************************************************/
        //  MenuToolbar
        /***********************************************************/
        let mainToolbarView:Maintoolbarview = UINib(nibName: "Maintoolbarview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Maintoolbarview
        mainToolbarView.toolbarViewSetting()
        //画面サイズに合わせる
        mainToolbarView.frame = self.view.frame
        
        // タップされたときのaction
        mainToolbarView.settingOkBtn.addTarget(self,
                         action: #selector(self.tapSettingOkBtn(sender:)),
                         for: .touchUpInside)
        
        // 貼り付ける
        self.view.addSubview(mainToolbarView)
        /***********************************************************/
        /***********************************************************/
        
        //BaseViewControllerと同じ
        let width = self.view.frame.width
        let height = self.view.frame.height
        //デフォルトは49
        let tabBarHeight:CGFloat = Util.TAB_BAR_HEIGHT
        
        /**   TabBarを設置   **/
        myTabBar = UITabBar()
        myTabBar.frame = CGRect(x:0,y:height - tabBarHeight,width:width,height:tabBarHeight)
        //バーの色
        myTabBar.barTintColor = UIColor.white
        myTabBar.backgroundColor = Util.BAR_BG_COLOR
        // ツールバーの背景の色を設定
        //myTabBar.backgroundColor = UIColor.lightGray
        //myTabBar.backgroundColor = UIColor.white
        //選択されていないボタンの色
        //myTabBar.unselectedItemTintColor = UIColor.black
        //ボタンを押した時の色
        //myTabBar.tintColor = UIColor.black
        
        //もともと用意されているものを使用
        //let more:UITabBarItem = UITabBarItem(tabBarSystemItem: .more,tag:5)
        //画像だけ
        //let config:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"config.png"), tag: 6)
        //文字と画像
        //let config2:UITabBarItem = UITabBarItem(title: "config", image: UIImage(named:"config.png"), tag: 7)
        //myTabBar.items = [more,config,config2]
        
        /***********************************************************/
        /***********************************************************/
        //選択中・未選択状態の切り替えもここで
        //ボタンを生成(ホーム)
        let homeBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"home_off"), tag: 1)
        homeBtn.image = UIImage(named: "home_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        homeBtn.selectedImage = UIImage(named: "home_on")
        
        //ボタンを生成(タイムライン)
        let timelineBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"timeline_off"), tag: 2)
        timelineBtn.image = UIImage(named: "timeline_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        timelineBtn.selectedImage = UIImage(named: "timeline_on")
        
        //ボタンを生成(配信準備)
        let liveBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"live_off"), tag: 3)
        liveBtn.image = UIImage(named: "live_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //ここだけ特別な処理(ダイアログを被せるため)
        //liveBtn.selectedImage = UIImage(named: "live_on")
        
        //ボタンを生成(トーク)
        let dmBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"dm_off"), tag: 4)
        dmBtn.image = UIImage(named: "dm_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        dmBtn.selectedImage = UIImage(named: "dm_on")
        
        //ボタンを生成(マイページ)
        let myPageBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"mypage_on"), tag: 5)
        myPageBtn.image = UIImage(named: "mypage_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //myPageBtn.selectedImage = UIImage(named: "mypage_on")
        //選択中・未選択状態の切り替えもここで(ここまで)
        /***********************************************************/
        /***********************************************************/
        
        //ボタンをタブバーに配置する
        myTabBar.items = [homeBtn,timelineBtn,liveBtn,dmBtn,myPageBtn]
        //デリゲートを設定する
        myTabBar.delegate = self
        
        //画像位置をtabbarの高さ中央に配置
        let insets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        myTabBar.items![0].imageInsets = insets
        myTabBar.items![1].imageInsets = insets
        myTabBar.items![2].imageInsets = insets
        myTabBar.items![3].imageInsets = insets
        myTabBar.items![4].imageInsets = insets
        
        //区切り線
        //myTabBar.shadowImage = UIImage.colorForTabBar(color: UIColor.gray)
        myTabBar.shadowImage = UIImage.colorForTabBar(color: Util.BAR_BG_COLOR)
        myTabBar.backgroundImage = UIImage() //0x0のUIImage
        
        self.view.addSubview(myTabBar)
        

        //現在の設定をロードする
        self.nameTextField.text = UserDefaults.standard.string(forKey: "myName")
        if(self.nameTextField.text == "0"){
            self.nameTextField.text = ""
        }
        
        self.sexCd = UserDefaults.standard.integer(forKey: "sex_cd")
        if(self.sexCd == 0){
            self.sexBtn.setTitle("未選択", for: .normal) // ボタンのタイトル
        }else if(self.sexCd == 1){
            self.sexBtn.setTitle("男性", for: .normal) // ボタンのタイトル
        }else if(self.sexCd == 2){
            self.sexBtn.setTitle("女性", for: .normal) // ボタンのタイトル
        }
        
        self.profileTextView.text = UserDefaults.standard.string(forKey: "freetext")
        if(self.profileTextView.text == "0" || self.profileTextView.text == "'0'"){
            self.profileTextView.text = ""
        }
        
        self.hpTextField.text = UserDefaults.standard.string(forKey: "homepage")
        if(self.hpTextField.text == "0"){
            self.hpTextField.text = ""
        }
        
        self.twitterTextField.text = UserDefaults.standard.string(forKey: "twitter")
        if(self.twitterTextField.text == "0"){
            self.twitterTextField.text = ""
        }
        
        self.facebookTextField.text = UserDefaults.standard.string(forKey: "facebook")
        if(self.facebookTextField.text == "0"){
            self.facebookTextField.text = ""
        }
        
        self.instagramTextField.text = UserDefaults.standard.string(forKey: "instagram")
        if(self.instagramTextField.text == "0"){
            self.instagramTextField.text = ""
        }
        
        //モノポルIDの設定
        let next_id = UserDefaults.standard.string(forKey: "next_id")
        self.idLbl.text = "ID：" + next_id!
        
        // 枠線の色
        idView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        idView.layer.borderWidth = 1
        // 角丸
        idView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        idView.layer.masksToBounds = true
        
        // 枠線の色
        nameView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        nameView.layer.borderWidth = 1
        // 角丸
        nameView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        nameView.layer.masksToBounds = true
        
        // 枠線の色
        hpView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        hpView.layer.borderWidth = 1
        // 角丸
        hpView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        hpView.layer.masksToBounds = true
        
        // 枠線の色
        profileView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        profileView.layer.borderWidth = 1
        // 角丸
        profileView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        profileView.layer.masksToBounds = true
        
        // 枠線の色
        sexView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        sexView.layer.borderWidth = 1
        // 角丸
        sexView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        sexView.layer.masksToBounds = true
        
        // 枠線の色
        twitterView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        twitterView.layer.borderWidth = 1
        // 角丸
        twitterView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        twitterView.layer.masksToBounds = true
        
        // 枠線の色
        facebookView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        facebookView.layer.borderWidth = 1
        // 角丸
        facebookView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        facebookView.layer.masksToBounds = true
        
        // 枠線の色
        instagramView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        instagramView.layer.borderWidth = 1
        // 角丸
        instagramView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        instagramView.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        
        // スクロールの高さを変更
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width
            , height: 560)
        
        //キーボード対応
        self.configureObserver()
    }

    //BaseViewControllerと同じ
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        UtilFunc.tabBarDo(selected_menu_num: self.selected_menu_num, item: item, myController:self)
    }

    //プロフィール編集完了ボタンを押した時
    @objc func tapSettingOkBtn(sender : AnyObject) {
        //一度データを待機
        let tempUserName = self.nameTextField.text
        let tempSex = self.sexCd
        let tempFreetext = self.profileTextView.text
        let tempHomepage = self.hpTextField.text
        let tempTwitter = self.twitterTextField.text
        let tempFacebook = self.facebookTextField.text
        let tempInstagram = self.instagramTextField.text
        
        if(tempUserName != nil && tempUserName != ""){
            //UUIDを取得
            //let phonedeviceId = UIDevice.current.identifierForVendor!.uuidString
            //let phonedeviceId = UUID().uuidString
            let user_id = UserDefaults.standard.integer(forKey: "user_id")
            
            let post_url = URL(string: Util.URL_MODIFY_PROFILE)
            // Swift4からは書き方が変わりました。
            //let post_url = URL(string: url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            //let decodedString:String = text.removingPercentEncoding!
            var req = URLRequest(url: post_url!)
            
            //ユーザーの情報を変更
            var stringUrl = "user_id="
            stringUrl.append(String(user_id))
            stringUrl.append("&user_name=")
            stringUrl.append(tempUserName!)
            stringUrl.append("&sex=")
            stringUrl.append(String(tempSex))
            stringUrl.append("&freetext=")
            stringUrl.append(tempFreetext!)
            stringUrl.append("&homepage=")
            stringUrl.append(tempHomepage!)
            stringUrl.append("&twitter=")
            stringUrl.append(tempTwitter!)
            stringUrl.append("&facebook=")
            stringUrl.append(tempFacebook!)
            stringUrl.append("&instagram=")
            stringUrl.append(tempInstagram!)
            
            print(stringUrl)
            //GETとの違い(ここから)
            // POSTを指定
            req.httpMethod = "POST"
            // POSTするデータをBodyとして設定
            req.httpBody = stringUrl.data(using: .utf8)
            //GETとの違い(ここまで)
            
            //非同期処理を行う
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
            
            dispatchGroup.enter()
            dispatchQueue.async {
                let task = URLSession.shared.dataTask(with: req, completionHandler: {
                    (data, res, err) in
                    //do{
                    
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
                //ユーザー情報を更新
                UtilFunc.setMyInfo()
                
                UtilFunc.showAlert(message:"プロフィールの編集が完了しました", vc:self, sec:2.0)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        //safearea取得用
        //var topSafeAreaHeight: CGFloat = 0
        var bottomSafeAreaHeight: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            //topSafeAreaHeight = self.view.safeAreaInsets.top
            bottomSafeAreaHeight = self.view.safeAreaInsets.bottom
            //print("in viewDidLayoutSubviews")
            //print(topSafeAreaHeight)    // iPhoneXなら44, その他は20.0
            //print(bottomSafeAreaHeight) // iPhoneXなら34,  その他は0
            
            //safeareaのボトムの調整値を保存
            UserDefaults.standard.set(bottomSafeAreaHeight, forKey: "bottomSafeAreaHeight")
            
            //safeareaを考慮
            let width = self.view.frame.width
            let height = self.view.frame.height
            //デフォルトは49
            let tabBarHeight:CGFloat = Util.TAB_BAR_HEIGHT
            
            self.myTabBar.frame = CGRect(x:0,y:height - tabBarHeight - bottomSafeAreaHeight,width:width,height:tabBarHeight + bottomSafeAreaHeight)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSexBtn(_ sender: Any) {
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        
        // プロトコルの設定
        picker.delegate = self
        picker.dataSource = self
        
        // はじめに表示する項目を指定
        if(self.sexCd == 1){
            //男性を選択時
            picker.selectRow(1, inComponent: 0, animated: true)
        }else if(self.sexCd == 2){
            //女性を選択時
            picker.selectRow(0, inComponent: 0, animated: true)
        }
        
        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        //nextBtn.isEnabled = false
        //saveInfoBtn.isEnabled = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 表示する列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // アイテム表示個数を返す
        return dataList.count
    }
    
    // UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        //画面上のボタンを有効にする
        //nextBtn.isEnabled = true
        //saveInfoBtn.isEnabled = true
        
        pickerView.removeFromSuperview()
        print(dataList[row])
        
        //if(row == 0){
            //未選択
        //    self.sexBtn.setTitle("▼性別", for: .normal)
        //    self.sexCd = 0
        //}else if(row == 1){
        if(row == 0){
            //女性を選択
            self.sexBtn.setTitle("女性", for: .normal)
            self.sexCd = 2
        }else if(row == 1){
            //男性を選択
            self.sexBtn.setTitle("男性", for: .normal)
            self.sexCd = 1
        }
    }
    
    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//キーボードが隠れてしまう問題の対応
extension ProfileSettingViewController: UITextFieldDelegate {
    
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
                let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
                self.view.transform = transform
                
            })
            
            self.sexBtn.isEnabled = false
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
        
        self.sexBtn.isEnabled = true
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
        if(textField.tag == 1 || textField.tag == 2 || textField.tag == 3){
            self.keyboardFlg = 1//キーボードを表示する場合に上にずらさない
        }else{
            self.keyboardFlg = 0
        }
    }
}
