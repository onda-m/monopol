//
//  MainViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/04/13.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit
import XLPagerTabStrip
import Onboard

class MainViewController: ButtonBarPagerTabStripViewController, UITabBarDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var myTabBar:UITabBar!
    
    //自分のuser_idを指定
    var user_id:Int = 0
    //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
    var selected_menu_num = 1
    
    //ライブ配信の復帰をするかの確認をするダイアログ
    let liveReturnDialog:LiveReturnDialog = UINib(nibName: "LiveReturnDialog", bundle: nil).instantiate(withOwner: self ,options: nil)[0] as! LiveReturnDialog

    override func viewDidLoad() {
        //  メンテナンス中かの判断(メンテナンス画面の中では直接記述すること)
        UtilFunc.maintenanceCheck()

        //1:2回目以降起動
        let firstLaunch = UserDefaults.standard.integer(forKey: "firstLaunch")
        
        if(firstLaunch == 1){
            self.startDo()
        }else{
            
            if true {
                
                //let cell_hi: CGFloat = 1.3//160:208
                let mainBoundSize: CGSize = UIScreen.main.bounds.size
                //let image_hi:CGFloat = 0.5633 //幅　/　高さ(画像の縦横比)
                let tempHeight:CGFloat  = mainBoundSize.height
                //let image_hi:CGFloat = 1.775 //高さ　/　幅(画像の縦横比)
                let image_hi:CGFloat = 1.5 //高さ　/　幅(画像の縦横比)
                //let tempImageWidth:CGFloat  = mainBoundSize.width - 10.0
                let tempImageWidth:CGFloat  = mainBoundSize.width * 0.9
                let tempImageHeight:CGFloat = tempImageWidth * image_hi
                let tempTopPadding = (tempHeight - tempImageHeight) / 2
                
                //初回起動
                let content1 = OnboardingContentViewController(
                    title: "",
                    body: "",
                    //image: UIImage(named: "tutorial01_sample"),
                    image: UIImage(named: "tutorial_01"),
                    //image: nil,
                    buttonText: "",
                    action: nil
                )
                let content2 = OnboardingContentViewController(
                    title: "",
                    body: "",
                    //image: UIImage(named: "tutorial02_sample"),
                    image: UIImage(named: "tutorial_02"),
                    buttonText: "",
                    action: nil
                )
                let content3 = OnboardingContentViewController(
                    title: "",
                    body: "",
                    //image: UIImage(named: "tutorial02_sample"),
                    image: UIImage(named: "tutorial_03"),
                    buttonText: "",
                    action: nil
                )
                let content4 = OnboardingContentViewController(
                    title: "",
                    body: "",
                    //image: UIImage(named: "tutorial03_sample"),
                    image: UIImage(named: "tutorial_04"),
                    //image: nil,
                    buttonText: "閉じる",
                    action: {
                    //初回起動ではなくす
                    UserDefaults.standard.set(1, forKey: "firstLaunch")
                    UtilToViewController.toMainViewController()
                    //self.startDo()
                    //UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
                    }
                )

                //画像のサイズ調整
                content1.topPadding = tempTopPadding
                content1.iconHeight = tempImageHeight
                content1.iconWidth = tempImageWidth
                
                content2.topPadding = tempTopPadding
                content2.iconHeight = tempImageHeight
                content2.iconWidth = tempImageWidth
                
                content3.topPadding = tempTopPadding
                content3.iconHeight = tempImageHeight
                content3.iconWidth = tempImageWidth
                
                content4.topPadding = tempTopPadding
                content4.iconHeight = tempImageHeight
                content4.iconWidth = tempImageWidth
                //content3.underIconPadding = 0
                //content3.underTitlePadding = 0
                //content3.bottomPadding = 0
                
                //let bgImageURL = NSURL(string: "https://www.pakutaso.com/shared/img/thumb/KAZ_hugyftdrftyg_TP_V.jpg")!
                //let bgImage = UIImage(data: NSData(contentsOf: bgImageURL as URL)! as Data)
                //let bgImage = UIImage(named: "splash_base_3")
                let vc = OnboardingViewController(
                    //backgroundImage: bgImage,
                    //backgroundImage: self.toumeiImage(size: mainBoundSize),
                    backgroundImage: nil,
                    contents: [content1, content2, content3, content4]
                )

                vc!.shouldMaskBackground = true
                vc!.allowSkipping = false
                //vc!.backgroundImage = self.toumeiImage(size: mainBoundSize)

                //vc!.bottomPadding = 10
                //vc!.skipHandler = {
                //    // Dismiss, fade out, etc...
                //    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
                //}

                ////UIApplication.shared.keyWindow?.rootViewController = vc
                //window?.rootViewController = vc

                // 背景が真っ黒にならなくなる
                vc!.modalPresentationStyle = .overCurrentContext
                //modelInfo.modalPresentationStyle = .fullScreen
                
                let topController = UIApplication.topViewController()
                topController!.present(vc!, animated: true, completion: nil)
            }
        }
    }

    func startDo(){
        //現在選択されているメニュー：初期化すること
        UserDefaults.standard.set(1, forKey: "selectedMenuNum")
        
        //ステータスバーの背景を直接操作する方法はないので、同サイズのViewを敷きつめることにより実現
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 50.0))
        statusBar.backgroundColor = Util.BAR_BG_COLOR
        view.addSubview(statusBar)
        
        /*
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 73/255, green: 72/255, blue: 62/255, alpha: 1)
        //セルの文字色
        settings.style.buttonBarItemTitleColor = UIColor.white
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = UIColor(red: 254/255, green: 0, blue: 124/255, alpha: 1)
         */
        
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        //セルの文字色
        settings.style.buttonBarItemTitleColor = Util.BASE_TEXT_COLOR
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = Util.BASE_TEXT_COLOR

        settings.style.buttonBarHeight = 20.0
        
        // タブの文字サイズ
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
        
        //3つのボタンの幅
        settings.style.buttonBarMinimumLineSpacing = 10.0
        //左側のマージン
        settings.style.buttonBarLeftContentInset = 30.0
        //右側のマージン
        settings.style.buttonBarRightContentInset = 30.0
        //選択バーの高さ
        settings.style.selectedBarHeight = 2.0
        
        super.viewDidLoad()

        /***********************************************************/
        //  MenuToolbar
        /***********************************************************/
        let mainToolbarView:Maintoolbarview = UINib(nibName: "Maintoolbarview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Maintoolbarview
        mainToolbarView.toolbarViewSetting()
        //画面サイズに合わせる
        mainToolbarView.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(mainToolbarView)
        /***********************************************************/
        /***********************************************************/

        user_id = UserDefaults.standard.integer(forKey: "user_id")
        //現在選択中のメニュー
        //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
        selected_menu_num = UserDefaults.standard.integer(forKey: "selectedMenuNum")
        
        //トークの未読数
        //UserDefaults.standard.set(, forKey: "talkNoreadCount")
        UtilFunc.getNoreadCount(user_id: user_id)
        let talkNoreadCount = UserDefaults.standard.integer(forKey: "talkNoreadCount")
        let officialReadFlg = UserDefaults.standard.integer(forKey: "official_read_flg")
        
        //リクエスト未読数取得
        //type=1:リスナーによる配信リクエスト
        UtilFunc.getLiveRequestNoreadCount(type:1, user_id:user_id)
        let requestRirekiNoreadCount = UserDefaults.standard.integer(forKey: "requestRirekiNoreadCount")
        
        //ブラックリストの内部配列を更新
        self.getBlackListByUser(user_id:user_id)
        
        //ログオフ状態に変更
        //3:キャスト-ログオフ状態
        UtilFunc.loginDo(user_id:user_id, status:3, live_user_id:0, reserve_flg:Int(self.appDelegate.reserveFlg)!, max_reserve_count:Int(self.appDelegate.reserveMaxCount)!, password:"0")
        
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
        // ツールバーの背景の色を設定
        //myTabBar.backgroundColor = UIColor.lightGray
        myTabBar.backgroundColor = Util.BAR_BG_COLOR
        //選択されていないボタンの色
        //myTabBar.unselectedItemTintColor = UIColor.black
        //ボタンを押した時の色(これを指定しないと押したときに一瞬青くなる)
        myTabBar.tintColor = UIColor.black
        
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
        let homeBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"home_on"), tag: 1)
        homeBtn.image = UIImage(named: "home_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //homeBtn.selectedImage = UIImage(named: "home_on")
        
        //ボタンを生成(タイムライン)
        //タイムラインを初回見たかのフラグ
        //1:見た
        //UserDefaults.standard.set(0, forKey: "timelineFirstFlg")
        let timelineFirstFlg = UserDefaults.standard.integer(forKey: "timelineFirstFlg")
        
        //FIRST_FLG02:初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
        let first_flg02 = UserDefaults.standard.integer(forKey: "first_flg02")
        
        //timeline_on_notice
        var timelineOffBtnName = "timeline_off"
        var timelineOnBtnName = "timeline_on"
        if(timelineFirstFlg == 1 && first_flg02 != 1){
            //すでにタイムラインを見た
            timelineOffBtnName = "timeline_off"
            timelineOnBtnName = "timeline_on"
        }else{
            //まだ見ていない
            timelineOffBtnName = "timeline_off_notice"
            timelineOnBtnName = "timeline_on_notice"
        }
        
        let timelineBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:timelineOffBtnName), tag: 2)
        timelineBtn.image = UIImage(named: timelineOffBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中の時
        if(self.restorationIdentifier == "toTimelineViewController"
            || self.restorationIdentifier == "toFollowViewController"
            || self.restorationIdentifier == "toFollowerViewController"){
            timelineBtn.image = UIImage(named: timelineOnBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            //timelineBtn.image = UIImage(named:"timeline_on")
        }
        
        if(self.selected_menu_num != 2){
            //選択中のアイテムの画像はレンダリングモードを指定しない。
            timelineBtn.selectedImage = UIImage(named: timelineOnBtnName)
        }
        //ボタンを生成(タイムライン)
        //ここまで
        
        //ボタンを生成(配信準備)
        let liveBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"live_off"), tag: 3)
        liveBtn.image = UIImage(named: "live_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //ここだけ特別な処理(ダイアログを被せるため)
        //liveBtn.selectedImage = UIImage(named: "live_on")
        
        var dmOffBtnName = "dm_off"
        var dmOnBtnName = "dm_on"
        if(talkNoreadCount > 0 || officialReadFlg == 1){
            //未読あり
            dmOffBtnName = "dm_off_notice"
            dmOnBtnName = "dm_on_notice"
        }else{
            //未読なし
            dmOffBtnName = "dm_off"
            dmOnBtnName = "dm_on"
        }
        
        //リクエストのon/offの切り替え
        //requestRirekiNoreadCount
        var mypageOffBtnName = "mypage_off"
        var mypageOnBtnName = "mypage_on"
        if(requestRirekiNoreadCount > 0){
            //未読あり
            mypageOffBtnName = "mypage_off_notice"
            mypageOnBtnName = "mypage_on_notice"
        }else{
            //未読なし
            mypageOffBtnName = "mypage_off"
            mypageOnBtnName = "mypage_on"
        }
        
        //ボタンを生成(トーク)
        let dmBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:dmOffBtnName), tag: 4)
        dmBtn.image = UIImage(named: dmOffBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        dmBtn.selectedImage = UIImage(named: dmOnBtnName)
        
        //ボタンを生成(マイページ)
        let myPageBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:mypageOffBtnName), tag: 5)
        myPageBtn.image = UIImage(named: mypageOffBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        myPageBtn.selectedImage = UIImage(named: mypageOnBtnName)
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
        
        /***********************************************************/
        //ライブ配信の復帰ダイアログ(この位置でないと全画面にならない)
        /***********************************************************/
        self.liveReturnDialog.isHidden = true//非表示にしておく
        //画面サイズに合わせる
        self.liveReturnDialog.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.liveReturnDialog)
        
        /***********************************************************/
        //  予約テーブルのクリア処理（異常終了した場合アプリ起動時に予約情報をクリアしたいのでここで処理する）
        /***********************************************************/
        //予約情報をクリア(Newシステム)
        //UtilFunc.reserveListClearByCastId(cast_id:user_id, status:0)
        //GET: cast_id, flg=1:追加（プラス１） 2:削除(マイナス１) 3:クリア（ゼロにする）
        //UtilFunc.modifyReserveTotalCount(cast_id:user_id, flg:3)

        //凍結されている時に表示
        let login_status:Int = UserDefaults.standard.integer(forKey: "login_status")
        if(login_status == 97){
            let noUserView:NgUserDialog = UINib(nibName: "NgUserDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! NgUserDialog
            // ポップアップビューを画面サイズに合わせる
            noUserView.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(noUserView)
        }else{
            /***********************************************************/
            //  毎日のプレゼント処理
            /***********************************************************/
            //保持しているログイン日時データ
            let temp_year = UserDefaults.standard.integer(forKey: "today_year")
            let temp_month = UserDefaults.standard.integer(forKey: "today_month")
            let temp_day = UserDefaults.standard.integer(forKey: "today_day")
            
            //print(temp_year as Any)
            //print(temp_month as Any)
            //print(temp_day as Any)
            
            //現在時刻
            let nowDate = NSDate()
            let comp = Calendar.current.dateComponents([.year, .month, .day], from:nowDate as Date)
            
            //規約に同意しているかのチェック
            //規約同意チェックフラグ：１＝チェック済
            let rule_check_flg = UserDefaults.standard.integer(forKey: "rule_check_flg")
            
            if(self.user_id == 0 || rule_check_flg != 1){
                //何もしない
            }else if(temp_year == comp.year && temp_month == comp.month && temp_day == comp.day){
                //すでにプレゼントをもらっている
            }else{
                //プレゼントの取得処理
                //GET:user_id,target_id,present_id,status
                var stringUrl = Util.URL_PRESENT_DO
                stringUrl.append("?user_id=")
                stringUrl.append(String(user_id))
                stringUrl.append("&target_id=0&present_id=901&status=1")
                
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
                    //毎日のプレゼント用にアプリアクセス日を保持
                    UserDefaults.standard.set(comp.year, forKey: "today_year")
                    UserDefaults.standard.set(comp.month, forKey: "today_month")
                    UserDefaults.standard.set(comp.day, forKey: "today_day")
                    
                    let loginPresentView:LoginPresentDialog = UINib(nibName: "LoginPresentDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! LoginPresentDialog
                    // ポップアップビュー背景色
                    //let viewColor = UIColor.black
                    // 半透明にして親ビューが見えるように。透過度はお好みで。
                    //loginPresentView.backgroundColor = viewColor.withAlphaComponent(0.5)
                    // ポップアップビューを画面サイズに合わせる
                    loginPresentView.frame = self.view.frame
                    
                    /*
                    // ダイアログ背景色（白の部分）
                    let baseViewColor = UIColor.white
                    // ちょっとだけ透明にする
                    loginPresentView.mainView.backgroundColor = baseViewColor.withAlphaComponent(1.0)
                    // 角丸にする
                    loginPresentView.mainView.layer.cornerRadius = 4.0
                     */
                    // 貼り付ける
                    self.view.addSubview(loginPresentView)
                }
            }
            /***********************************************************/
            /***********************************************************/

            //同意確認がされていない場合は、RuleCheckViewを重ねる
            if(rule_check_flg != 1){
                let ruleCheckView:RuleCheckView = UINib(nibName: "RuleCheckView", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! RuleCheckView
                //mainToolbarView.toolbarViewSetting()
                //画面サイズに合わせる
                ruleCheckView.frame = self.view.frame
                // 貼り付ける
                self.view.addSubview(ruleCheckView)
            }
        }
    }
    
    //双方のブラックリストの配列をアプリ内に記憶する
    func getBlackListByUser(user_id:Int){
        //クリアする
        self.appDelegate.array_black_list.removeAll()
        
        //リスト取得
        var stringUrl = Util.URL_GET_BLACKLIST_BOTH
        stringUrl.append("?order=1&user_id=")
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
                    let json = try decoder.decode(UtilStruct.ResultBlackJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        if(Int(obj.from_user_id) != self.user_id){
                            self.appDelegate.array_black_list.append(Int(obj.from_user_id)!)
                        }else if(Int(obj.to_user_id) != self.user_id){
                            self.appDelegate.array_black_list.append(Int(obj.to_user_id)!)
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
        }
    }
    
    //BaseViewControllerと同じ
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        UtilFunc.tabBarDo(selected_menu_num: self.selected_menu_num, item: item, myController:self)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
    
        //管理されるViewControllerを返す処理
        let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "modelList")
        let secondVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "modelList2")
        let thirdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "modelList3")

        //タブメニュの切り替えの画面一覧
        let childViewControllers:[UIViewController] = [firstVC, secondVC, thirdVC]
        
        //let childViewControllers:[UIViewController] = [firstVC]
        return childViewControllers
    }

    //初期の選択
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if(self.appDelegate.sendSubMenu == "99"){
            let selectedSubMenu = UserDefaults.standard.integer(forKey: "selectedSubMenu")
            self.moveToViewController(at: selectedSubMenu, animated: false)
            //self.moveToViewController(at: 1, animated: false)
        }else{
            self.moveToViewController(at: Int(self.appDelegate.sendSubMenu)!, animated: false)
            self.appDelegate.sendSubMenu = "99"
        }
        
        //safearea取得用
        var topSafeAreaHeight: CGFloat = 0
        var bottomSafeAreaHeight: CGFloat = 0

        if #available(iOS 11.0, *) {
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            topSafeAreaHeight = self.view.safeAreaInsets.top
            bottomSafeAreaHeight = self.view.safeAreaInsets.bottom
            //print("in viewDidLayoutSubviews")
            //print(topSafeAreaHeight)    // iPhoneXなら44, その他は20.0
            //print(bottomSafeAreaHeight) // iPhoneXなら34,  その他は0
            
            //safeareaの調整値を保存
            UserDefaults.standard.set(topSafeAreaHeight, forKey: "topSafeAreaHeight")
            UserDefaults.standard.set(bottomSafeAreaHeight, forKey: "bottomSafeAreaHeight")

            //safeareaを考慮
            let width = self.view.frame.width
            let height = self.view.frame.height
            //デフォルトは49
            let tabBarHeight:CGFloat = Util.TAB_BAR_HEIGHT
            
            self.myTabBar.frame = CGRect(x:0,y:height - tabBarHeight - bottomSafeAreaHeight,width:width,height:tabBarHeight + bottomSafeAreaHeight)
            
            /*
             let width:CGFloat = self.view.frame.width
             let height:CGFloat = self.view.frame.height
             let labelHeight:CGFloat = 50
             
             topSafeAreaLabel.frame = CGRect(
             x: 0, y: topSafeAreaHeight,
             width: width, height: labelHeight)
             bottomSafeAreaLabel.frame = CGRect(
             x: 0, y: height - (labelHeight + bottomSafeAreaHeight),
             width: width, height: labelHeight)
             */
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if(self.appDelegate.listener_live_close_btn_tap_flg == 0){
            //バツボタンを押して終了した場合は何も出さないに変更
            //ゼロでなければ、直前にライブ配信を行っていたことになる
            //UserDefaults.standard.set(self.liveCastId, forKey: "live_cast_id")
            let liveCastIdTemp = UserDefaults.standard.integer(forKey: "live_cast_id")
            //UserDefaults.standard.set(0, forKey: "live_cast_id")
            if(liveCastIdTemp > 0){
                //復帰しますかのダイアログを表示。
                // backgroundColorを使って透過させる。
                self.liveReturnDialog.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
                
                self.liveReturnDialog.isHidden = false//表示
                self.liveReturnDialog.setLabel()
                //self.myTabBar.isUserInteractionEnabled = false
            }else{
                self.liveReturnDialog.isHidden = true//非表示
                //self.myTabBar.isUserInteractionEnabled = true
            }
        }else{
            //バツボタンを押して終了した場合
            //直前のライブ配信のキャストIDをクリアする
            UserDefaults.standard.set(0, forKey: "live_cast_id")
            UserDefaults.standard.set("", forKey: "live_cast_name")
            
            self.appDelegate.listener_live_close_btn_tap_flg = 0
        }
    }
    
    /*
    // Segue を呼び出す
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toMainTelViewController") {
            let _: MainViewController = (segue.destination as? MainViewController)!
        }else if(segue.identifier == "toMediaConnectionViewController") {
            let subVC: MediaConnectionViewController = (segue.destination as? MediaConnectionViewController)!
            subVC.sendId = "99"
        }else if(segue.identifier == "toDataConnectionViewController") {
            let subVC: DataConnectionViewController = (segue.destination as? DataConnectionViewController)!
            subVC.sendId = "99"
        }
    }
    */
    
    /////////追加(ここまで)////////////////////////////
}
