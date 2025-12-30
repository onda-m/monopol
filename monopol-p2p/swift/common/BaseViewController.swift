//
//  BaseViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/31.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Reachability

class BaseViewController: UIViewController,UITabBarDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var mainToolbarView:Maintoolbarview!
    private var myTabBar:UITabBar!
    
    //safearea取得用
    var topSafeAreaHeight: CGFloat = 0
    var bottomSafeAreaHeight: CGFloat = 0
    
    //自分のuser_idを指定
    var user_id:Int = 0
    //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
    var selected_menu_num = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //  メンテナンス中かの判断(メンテナンス画面の中では直接記述すること)
        UtilFunc.maintenanceCheck()
        
        //ステタースバーの背景を直接操作する方法はないので、同サイズのViewを敷きつめることにより実現
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 50.0))
        statusBar.backgroundColor = Util.BAR_BG_COLOR
        view.addSubview(statusBar)
        
        UtilFunc.setMyInfo()
        
        // Do any additional setup after loading the view.
        /***********************************************************/
        //  オフラインかの判断
        /***********************************************************/
        do {
            //オンライン・オフラインの判断用
            let reachability = try! Reachability()
            
            reachability.whenUnreachable = { reachability in
                //オフラインになった時に実行される
                //print(reachability.connection)
                UtilToViewController.toNetworkErrorViewController()
            }
            try! reachability.startNotifier()
        }
        /***********************************************************/
        //  オフラインかの判断
        /***********************************************************/
        
        /***********************************************************/
        //  MenuToolbar
        /***********************************************************/
        self.mainToolbarView = UINib(nibName: "Maintoolbarview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as? Maintoolbarview
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
        self.getBlackListByUser(user_id:self.user_id)
        
        //ログオフ状態に変更
        //3:キャスト-ログオフ状態
        UtilFunc.loginDo(user_id:user_id, status:3, live_user_id:0, reserve_flg:Int(self.appDelegate.reserveFlg)!, max_reserve_count:Int(self.appDelegate.reserveMaxCount)!, password:"0")
        
        //マイコレクションの個別画面には下部のタブバーは不要
        if(self.restorationIdentifier != "toCollectionImageViewController"){
            /**   TabBarを設置   **/
            myTabBar = UITabBar()
            
            //バーの色
            myTabBar.barTintColor = UIColor.white
            
            //let colorBg = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
            //UITabBar.appearance().barTintColor = colorBg
            
            // ツールバーの背景の色を設定
            //myTabBar.backgroundColor = UIColor.red
            myTabBar.backgroundColor = Util.BAR_BG_COLOR
            
            //選択されていないボタンの色
            //myTabBar.unselectedItemTintColor = UIColor.black
            //myTabBar.unselectedItemTintColor = UIColor.white
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
            let homeBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"home_off"), tag: 1)
            homeBtn.image = UIImage(named: "home_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            //選択中の時
            if(self.restorationIdentifier == "toPairRankingViewController"
                || self.restorationIdentifier == "toCastSearchViewController"){
                homeBtn.image = UIImage(named: "home_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
            
            if(self.selected_menu_num != 1){
                //選択中のアイテムの画像はレンダリングモードを指定しない。
                homeBtn.selectedImage = UIImage(named: "home_on")
            }
            
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
            //選択中の時
            if(self.restorationIdentifier == "toWaitTopViewController"
                || self.restorationIdentifier == "toScreenshotViewController"){
                liveBtn.image = UIImage(named: "live_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
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
            //選択中の時
            if(self.restorationIdentifier == "toTalkTopViewController"
                || self.restorationIdentifier == "toTalkInfoViewController"){
                dmBtn.image = UIImage(named: dmOnBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
            if(self.selected_menu_num != 4){
                //選択中のアイテムの画像はレンダリングモードを指定しない。
                dmBtn.selectedImage = UIImage(named: dmOnBtnName)
            }
            
            //ボタンを生成(マイページ)
            //let myPageBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"mypage_off"), tag: 5)
            //myPageBtn.image = UIImage(named: "mypage_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            let myPageBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:mypageOffBtnName), tag: 5)
            myPageBtn.image = UIImage(named: mypageOffBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            //選択中の時
            if(self.restorationIdentifier == "toMypageViewController"
                || self.restorationIdentifier == "toWatchRirekiViewController"
                || self.restorationIdentifier == "toMyCollectionViewController"
                || self.restorationIdentifier == "toPurchaseViewController"
                || self.restorationIdentifier == "toFollowManageViewController"
                || self.restorationIdentifier == "toPayReportViewController"
                || self.restorationIdentifier == "toToYenViewController"
                || self.restorationIdentifier == "toToCoinViewController"
                //|| self.restorationIdentifier == "toMainPurchaseViewController"
                || self.restorationIdentifier == "toIdentificationViewController"
                || self.restorationIdentifier == "toPriceSettingViewController"
                || self.restorationIdentifier == "toPriceSettingUpgradeViewController"
                || self.restorationIdentifier == "toUserSettingViewController"
                || self.restorationIdentifier == "toProfileSettingViewController"
                || self.restorationIdentifier == "toAccountEditViewController"
                || self.restorationIdentifier == "toBlackListViewController"
                || self.restorationIdentifier == "toRestoreViewController"
                || self.restorationIdentifier == "toNotifySettingViewController"
                || self.restorationIdentifier == "toMovieSettingViewController"
                || self.restorationIdentifier == "toRuleViewController"
                || self.restorationIdentifier == "toContactUsViewController"
                || self.restorationIdentifier == "toPresentShopViewController"
                || self.restorationIdentifier == "toMyEventCheckViewController"
                ){
                myPageBtn.image = UIImage(named: mypageOnBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
            
            if(self.selected_menu_num != 5){
                //選択中のアイテムの画像はレンダリングモードを指定しない。
                myPageBtn.selectedImage = UIImage(named: mypageOnBtnName)
            }
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
            
            //区切り線(2022-11-18 修正)
            //myTabBar.shadowImage = UIImage.colorForTabBar(color: UIColor.gray)
            myTabBar.shadowImage = UIImage.colorForTabBar(color: Util.BAR_BG_COLOR)
            myTabBar.backgroundImage = UIImage() //0x0のUIImage
            
            self.view.addSubview(myTabBar)
            //最前面に
            self.view.bringSubviewToFront(myTabBar)
        }//タブバーここまで
        
        /***********************************************************/
        //  予約テーブルのクリア処理（異常終了した場合アプリ起動時に予約情報をクリアしたいのでここで処理する）
        /***********************************************************/
        //予約情報をクリア(Newシステム)
        //UtilFunc.reserveListClearByCastId(cast_id:user_id, status:0)
        //GET: cast_id, flg=1:追加（プラス１） 2:削除(マイナス１) 3:クリア（ゼロにする）
        //UtilFunc.modifyReserveTotalCount(cast_id:user_id, flg:3)
        
        let login_status:Int = UserDefaults.standard.integer(forKey: "login_status")
        print("status = " + String(login_status))
        
        //凍結されている時に表示
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
            //print(comp.year as Any)
            //print(comp.month as Any)
            //print(comp.day as Any)
            
            //規約に同意しているかのチェック
            //規約同意チェックフラグ：１＝チェック済
            let rule_check_flg = UserDefaults.standard.integer(forKey: "rule_check_flg")
            
            if(self.user_id == 0 || rule_check_flg != 1){
                //何もしない
            }else if(temp_year == comp.year && temp_month == comp.month && temp_day == comp.day){
                //テスト用
                //if(temp_year == comp.year && temp_month == comp.month && temp_day != comp.day){
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
        }
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        UtilFunc.tabBarDo(selected_menu_num: selected_menu_num, item: item, myController:self)
        
        /*
        switch item.tag{
        case 1:
            if(self.selected_menu_num != 1){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(1, forKey: "selectedMenuNum")
                //ホーム画面へ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                Util.toMainViewController()
            }
        case 2:
            if(self.selected_menu_num != 2){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(2, forKey: "selectedMenuNum")
                //タイムライン画面へ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                Util.toTimelineViewController()
            }
        case 3:
            //ライブ待ち画面へ(ダイアログを重ねる)
            UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
            let waitDialog:WaitTopDialog = UINib(nibName: "WaitTopDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! WaitTopDialog

            waitDialog.waitTopDialogSetting()

            //画面サイズに合わせる(selfでなく、superviewにすることが重要)
            waitDialog.frame = self.view.frame
            // 貼り付ける
            self.view.addSubview(waitDialog)
        case 4:
            if(self.selected_menu_num != 4){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(4, forKey: "selectedMenuNum")
                //トーク画面へ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                Util.toTalkTopViewController()
            }
        case 5:
            if(self.selected_menu_num != 5){
                //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
                UserDefaults.standard.set(5, forKey: "selectedMenuNum")
                //マイページへ
                UserDefaults.standard.set(1, forKey: "selectedSubMenu")//0:フォロー、1:注目、2:最新のどれを選んでいるか。
                Util.toMypageViewController()
            }
        default : return
            
        }
         */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            topSafeAreaHeight = self.view.safeAreaInsets.top
            bottomSafeAreaHeight = self.view.safeAreaInsets.bottom
            //print("in viewDidLayoutSubviews")
            //print(topSafeAreaHeight)    // iPhoneXなら44, その他は20.0
            //print(bottomSafeAreaHeight) // iPhoneXなら34,  その他は0
            
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
                        /*
                         let strFromUserId = obj.from_user_id
                         let strToUserId = obj.to_user_id
                         let strInsTime = obj.ins_time
                         let strUserName = obj.user_name.toHtmlString()
                         let strPhotoFlg = obj.photo_flg
                         let strPhotoName = obj.photo_name
                         */
                        
                        /*
                        let black_info = (obj.from_user_id
                            ,obj.to_user_id
                            ,obj.ins_time
                            ,obj.user_name.toHtmlString()
                            ,obj.photo_flg
                            ,obj.photo_name)
                        
                        //配列へ追加
                        self.blackList.append(black_info)
                        self.blackListTemp.append(black_info)
                         */
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
}
