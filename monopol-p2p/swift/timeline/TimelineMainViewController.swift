//
//  TimelineMainViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/18.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TimelineMainViewController: ButtonBarPagerTabStripViewController, UITabBarDelegate{

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var myTabBar:UITabBar!
    
    //自分のuser_idを指定
    var user_id:Int = 0
    //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
    var selected_menu_num = 2
    
    override func viewDidLoad() {
        //  メンテナンス中かの判断(メンテナンス画面の中では直接記述すること)
        UtilFunc.maintenanceCheck()
        
        //初期の選択
        UserDefaults.standard.set(0, forKey: "selectedSubMenuTimeline")
        
        //ステタースバーの背景を直接操作する方法はないので、同サイズのViewを敷きつめることにより実現
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 50.0))
        statusBar.backgroundColor = Util.BAR_BG_COLOR
        view.addSubview(statusBar)
        
        //バーの色
        settings.style.buttonBarBackgroundColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1)
        //ボタンの色
        settings.style.buttonBarItemBackgroundColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1)
        //バーの色
        //settings.style.buttonBarBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        //ボタンの色
        //settings.style.buttonBarItemBackgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        //セルの文字色
        settings.style.buttonBarItemTitleColor = Util.BASE_TEXT_COLOR
        //セレクトバーの色
        settings.style.selectedBarBackgroundColor = Util.BASE_TEXT_COLOR
        
        settings.style.buttonBarHeight = 14.0
        
        //3つのボタンの幅
        settings.style.buttonBarMinimumLineSpacing = 10.0
        //左側のマージン
        settings.style.buttonBarLeftContentInset = 30.0
        //右側のマージン
        settings.style.buttonBarRightContentInset = 30.0
        //選択バーの高さ
        settings.style.selectedBarHeight = 2.0
        
        //フォントの設定
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
        
        super.viewDidLoad()
    }
    
    //注意：タイムラインを投稿後に戻ってくるため、ここに記述
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        let homeBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"home_off"), tag: 1)
        homeBtn.image = UIImage(named: "home_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        homeBtn.selectedImage = UIImage(named: "home_on")
        
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
        
        let timelineBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:timelineOffBtnName), tag: 2)
        
        if(timelineFirstFlg == 1 && first_flg02 != 1){
            //すでにタイムラインを見た
            timelineOffBtnName = "timeline_off"
            timelineOnBtnName = "timeline_on"
            
            //選択中の時
            timelineBtn.image = UIImage(named: timelineOnBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }else{
            //まだ見ていない
            timelineOffBtnName = "timeline_off_notice"
            timelineOnBtnName = "timeline_on_notice"
            
            //選択中の時
            timelineBtn.image = UIImage(named: timelineOnBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            //0.3秒後くらいに下部のメニューアイコンを変更(赤印を消す)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
              //ボタンを生成(タイムライン)
              //タイムラインを初回見たかのフラグ
                timelineBtn.image = UIImage(named: "timeline_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
        }
        
        //timelineBtn.image = UIImage(named: timelineOffBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)

        //if(self.restorationIdentifier == "toTimelineViewController"
        //    || self.restorationIdentifier == "toFollowViewController"
        //    || self.restorationIdentifier == "toFollowerViewController"){
        //    timelineBtn.image = UIImage(named: timelineOnBtnName)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            //timelineBtn.image = UIImage(named:"timeline_on")
        //}
        
        //if(self.selected_menu_num != 2){
            //選択中のアイテムの画像はレンダリングモードを指定しない。
        //    timelineBtn.selectedImage = UIImage(named: timelineOnBtnName)
        //}
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
        
        /**************************************************************/
        //10フォローしたら130コイン
        //初回フラグ(1:10人フォロー達成済 2:達成後コイン受取済)
        //UserDefaults.standard.set(strFirstFlg02, forKey: "first_flg02")
        /**************************************************************/
        //let first_flg02 = UserDefaults.standard.integer(forKey: "first_flg02")
        if(first_flg02 == 1){
            //10フォローしたら130コイン達成のダイアログの宣言
            let firstFollowView = UINib(nibName: "FirstFollowView", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! FirstFollowView
            
            firstFollowView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
         
            if(firstFollowView.isDescendant(of: self.view)){
                //すでに追加(addsubview)済み
                //何もしない
            }else{
                //画面サイズに合わせる
                firstFollowView.frame = self.view.frame
                // 貼り付ける
                self.view.addSubview(firstFollowView)//画面から離れる時に解放する必要がある
            }
            firstFollowView.isHidden = false//表示
        }
        /**************************************************************/
        //10フォローしたら130コイン(ここまで)
        /**************************************************************/
        
        //タイムラインを初回見たかのフラグ(1:すでに見た)
        UserDefaults.standard.set(1, forKey: "timelineFirstFlg")
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
        let firstVC = UIStoryboard(name: "Timeline", bundle: nil).instantiateViewController(withIdentifier: "toTimelineViewController")
        let secondVC = UIStoryboard(name: "Timeline", bundle: nil).instantiateViewController(withIdentifier: "toFollowViewController")
        let thirdVC = UIStoryboard(name: "Timeline", bundle: nil).instantiateViewController(withIdentifier: "toFollowerViewController")
        
        //タブメニュの切り替えの画面一覧
        let childViewControllers:[UIViewController] = [firstVC, secondVC, thirdVC]
        
        //let childViewControllers:[UIViewController] = [firstVC]
        return childViewControllers
    }

    //初期の選択
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.moveToViewController(at: 0, animated: false)
        
        //UserDefaults.standard.set(2, forKey: "selectedSubMenuTimeline")
        let selectedSubMenuTimeline = UserDefaults.standard.integer(forKey: "selectedSubMenuTimeline")
        self.moveToViewController(at: selectedSubMenuTimeline, animated: false)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
