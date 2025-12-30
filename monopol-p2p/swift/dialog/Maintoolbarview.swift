//
//  Maintoolbarview.swift
//  swift_skyway
//
//  Created by onda on 2018/05/02.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Onboard

class Maintoolbarview: UIView {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    //@IBOutlet weak var lineView: UIView!
    // 上に載せたボタンのCGRect
    //var rect_menubutton : CGRect?
    //var rect_pointbutton : CGRect?
    //var rect_monopolbutton : CGRect?

    @IBOutlet weak var mainToolbarView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    
    //コイン関連
    @IBOutlet weak var pointBtn: UIButton!
    //@IBOutlet weak var coinImageView: UIImageView!

    //タイムラインのみ表示
    @IBOutlet weak var tweetBtn: UIButton!
    
    @IBOutlet weak var monopolBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!

    //トップのみ表示
    @IBOutlet weak var monopolTopBtn: UIButton!
    @IBOutlet weak var rankingBtn: UIButton!
    @IBOutlet weak var tutorialBtn: UIButton!
    
    //プロフィール編集の完了ボタン
    @IBOutlet weak var settingOkBtn: UIButton!
    
    //プロフィール確認ページへのボタン
    @IBOutlet weak var profileImageView: EnhancedCircleImageView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //左上のメニューボタンは不採用のため非表示
        //menuBtn.isHidden = true
        
        //self.lineView.frame.size.height = 0.5
        
        //print(self.parentViewController()?.restorationIdentifier as Any)
        
        mainToolbarView.backgroundColor = Util.BAR_BG_COLOR
        //mainToolbarView.backgroundColor = UIColor.red
        
        //テキストの色
        settingOkBtn.setTitleColor(Util.TITLE_TEXT_COLOR, for: .normal)
        monopolBtn.setTitleColor(Util.TITLE_TEXT_COLOR, for: .normal)
        pointBtn.setTitleColor(Util.TITLE_TEXT_COLOR, for: .normal)
        
        //ラベルの枠を自動調節する
        monopolBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        monopolBtn.titleLabel?.minimumScaleFactor = 0.3

        //ラベルの枠を自動調節する
        pointBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        pointBtn.titleLabel?.minimumScaleFactor = 0.3//最小でも30%までしか縮小しない
        
        //所有しているコインの設定
        let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        pointBtn.setTitle(" " + UtilFunc.numFormatter(num: Int(myPoint)), for: .normal)
        
        // Drawing code
        //自分のプロフィール確認ページへのボタン
        profileImageView.isHidden = true//非表示
        
        if(self.parentViewController()?.restorationIdentifier == "toMainViewController"
            || self.parentViewController()?.restorationIdentifier == "toCastSearchViewController"){
            searchBtn.isHidden = false
            monopolBtn.isHidden = true
            pointBtn.isHidden = true
            settingOkBtn.isHidden = true
            //coinImageView.isHidden = true
            backBtn.isHidden = true
            tweetBtn.isHidden = true

            monopolTopBtn.isHidden = false
            rankingBtn.isHidden = false
            tutorialBtn.isHidden = false
        }else{
            searchBtn.isHidden = true
            monopolBtn.isHidden = false
            monopolTopBtn.isHidden = true
            rankingBtn.isHidden = true
            tutorialBtn.isHidden = true
            //monopolBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            //monopolBtn.titleLabel?.minimumScaleFactor = 0.3
            //yenAplusLbl.sizeToFit()

            //ホーム＞リスナー関連
            if((self.parentViewController()?.restorationIdentifier) == "toMainListenerViewController"){
                monopolBtn.setTitle(UtilFunc.strMin(str:appDelegate.sendNameByListenerList!.toHtmlString(), num:Util.NAME_MOJI_COUNT_SMALL) + "のリスナー", for: .normal)
                
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            //ホーム＞ランキング
            }else if((self.parentViewController()?.restorationIdentifier) == "toMainRankingViewController"){
                monopolBtn.setTitle("月間ランキング", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            //ホーム＞キャスト＞月間ペアランキング
            }else if((self.parentViewController()?.restorationIdentifier) == "toPairRankingViewController"){
                let strTemp = UtilFunc.strMin(str:appDelegate.sendNameByPairRanking!, num:6)
                monopolBtn.setTitle(strTemp + "月間ペアランキング", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            //タイムライン関連
            }else if((self.parentViewController()?.restorationIdentifier) == "toTimelineMainViewController"){
                monopolBtn.setTitle("タイムライン", for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = false
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            //}else if((self.parentViewController()?.restorationIdentifier) == "toFollowViewController"){
            //    monopolBtn.setTitle("タイムライン", for: .normal)
            //    backBtn.isHidden = true
            //    tweetBtn.isHidden = false
            //    pointBtn.isHidden = true
            //}else if((self.parentViewController()?.restorationIdentifier) == "toFollowerViewController"){
            //    monopolBtn.setTitle("タイムライン", for: .normal)
            //    backBtn.isHidden = true
            //    tweetBtn.isHidden = false
            //    pointBtn.isHidden = true
            //配信準備関連
            }else if((self.parentViewController()?.restorationIdentifier) == "toWaitTopViewController"){
                //monopolBtn.setTitle("ライブ配信準備", for: .normal)
                monopolBtn.setTitle("サシライブ配信準備", for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toScreenshotViewController"){
                monopolBtn.setTitle("スクショ管理", for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toMainWaitTopViewController"){
                monopolBtn.setTitle("サシライブ配信準備", for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            //トーク関連
            }else if((self.parentViewController()?.restorationIdentifier) == "toTalkTopViewController"){
                monopolBtn.setTitle("トーク", for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toTalkInfoViewController"){
                //トーク個別画面
                monopolBtn.setTitle(appDelegate.sendUserName!.toHtmlString(), for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            //マイページ関連
            }else if((self.parentViewController()?.restorationIdentifier) == "toMypageViewController"){
                let strTemp = UtilFunc.strMin(str:UserDefaults.standard.string(forKey: "myName")!, num:Util.NAME_MOJI_COUNT_BIG)
                monopolBtn.setTitle(strTemp.toHtmlString(), for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = true
                pointBtn.isHidden = false
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = false
                
                //マイプロフィール画面への遷移ボタン
                profileImageView.isHidden = false//表示
                profileImageView.isUserInteractionEnabled = true
                profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapProfileBtn(_:))))
                
            }else if((self.parentViewController()?.restorationIdentifier) == "toMyprofileInfoViewController"){
                monopolBtn.setTitle("プロフィール確認", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
                
            }else if((self.parentViewController()?.restorationIdentifier) == "toFollowManageViewController"){
                monopolBtn.setTitle("フォロー管理", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
                
            }else if((self.parentViewController()?.restorationIdentifier) == "toWatchRirekiViewController"){
                monopolBtn.setTitle("視聴履歴", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
                
            }else if((self.parentViewController()?.restorationIdentifier) == "toMyCollectionViewController"){
                monopolBtn.setTitle("マイコレクション", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toPresentShopViewController"){
                monopolBtn.setTitle("プレゼントショップ", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toCollectionImageViewController"){
                //CollectionImageViewControllerにてタイトルを設定している
                //monopolBtn.setTitle("", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
                
                //文字色設定
                monopolBtn.setTitleColor(UIColor.white, for: .normal)
                backBtn.setTitleColor(UIColor.white, for: .normal)
                
                //バーの色設定
                mainToolbarView.isOpaque = false // 不透明を false
                let rgba = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
                mainToolbarView.backgroundColor = rgba
                    //.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0) // alpha 0 で色を設定
                
            }else if((self.parentViewController()?.restorationIdentifier) == "toMainPurchaseViewController"){
                monopolBtn.setTitle("マイコイン", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toPriceSettingViewController"){
                //monopolBtn.setTitle("配信ランクの設定", for: .normal)
                monopolBtn.setTitle("サシライブの有料設定", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toPriceSettingUpgradeViewController"){
                //monopolBtn.setTitle("配信ランクの設定", for: .normal)
                monopolBtn.setTitle("サシライブの有料設定", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toMainReportViewController"){
                monopolBtn.setTitle("配信レポート", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toToYenViewController"){
                monopolBtn.setTitle("スターの換金", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toToCoinViewController"){
                monopolBtn.setTitle("スターをコインに変換", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
                
            }else if((self.parentViewController()?.restorationIdentifier) == "toIdentificationViewController"){
                monopolBtn.setTitle("本人確認手続き", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
                
            }else if((self.parentViewController()?.restorationIdentifier) == "toPayReportViewController"){
                monopolBtn.setTitle("支払いレポート", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toUserSettingViewController"){
                monopolBtn.setTitle("設定", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = false
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = false
            }else if((self.parentViewController()?.restorationIdentifier) == "toProfileSettingViewController"){
                monopolBtn.setTitle("プロフィールの編集", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = false
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toAccountEditViewController"){
                monopolBtn.setTitle("アカウントの設定", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toBlackListViewController"){
                monopolBtn.setTitle("ブラックリスト", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toRestoreViewController"){
                monopolBtn.setTitle("既存アカウントを引継ぐ", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toNotifySettingViewController"){
                monopolBtn.setTitle("通知設定", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toMovieSettingViewController"){
                monopolBtn.setTitle("動画アップロード", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toRuleViewController"){
                monopolBtn.setTitle("利用規約", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toContactUsViewController"){
                monopolBtn.setTitle("問い合わせフォーム", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toMyEventCheckViewController"){
                monopolBtn.setTitle("イベントの確認", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toCreateEventTopViewController"){
                monopolBtn.setTitle("イベント機能（β版）について", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toCreateEventViewController"){
                monopolBtn.setTitle("イベントの設定", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toCreateEventCheckViewController"){
                monopolBtn.setTitle("イベントの確認", for: .normal)
                backBtn.isHidden = false
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else if((self.parentViewController()?.restorationIdentifier) == "toCreateEventCompViewController"){
                monopolBtn.setTitle("イベントの確認", for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = true
                pointBtn.isHidden = true
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = true
            }else{
                monopolBtn.setTitle("monopol", for: .normal)
                backBtn.isHidden = true
                tweetBtn.isHidden = true
                pointBtn.isHidden = false
                settingOkBtn.isHidden = true
                //coinImageView.isHidden = false
            }
        }
        
        //横に線を引く
        //let path = UIBezierPath()
        /*
         path.move(to: CGPoint(x: 0, y: 53))
         path.addLine(to: CGPoint(x: 200, y: 53))
         path.lineWidth = 1.5 // 線の太さ
         UIColor.red.setStroke() // 色をセット
         path.stroke()
         */
        /*
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 74))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 74))
        path.lineWidth = 0.5 // 線の太さ
        path.close()
        
        UIColor.gray.setStroke()
        path.stroke()
         */
    }
    
    //@IBAction func tapProfileBtn(_ sender: Any) {
    // 画像がタップされたら呼ばれる
    @objc func tapProfileBtn(_ sender: UITapGestureRecognizer) {
        //プロフィール確認ページへ遷移
        UtilToViewController.toMyprofileInfoViewController()
    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        if((self.parentViewController()?.restorationIdentifier) == "toPriceSettingViewController"
            || (self.parentViewController()?.restorationIdentifier) == "toPriceSettingUpgradeViewController"
            || (self.parentViewController()?.restorationIdentifier) == "toMyCollectionViewController"
            || (self.parentViewController()?.restorationIdentifier) == "toMyEventCheckViewController"
            ){
            //配信ランクの設定、マイコレクション、イベント確認ページの場合は戻る先はマイページのトップ
            UtilToViewController.toMypageViewController()
        }else if((self.parentViewController()?.restorationIdentifier) == "toTalkInfoViewController"){
            //トーク個別画面から戻るとき
            //下記のようにしないと戻ったときにスクロールがおかしくなる（表示されているものが消えたりする）
            UtilToViewController.toTalkTopViewController()
        }else if((self.parentViewController()?.restorationIdentifier) == "toMainRankingViewController"){
            //ランキング画面から戻るとき>トップに戻す
            UtilToViewController.toMainViewController()
        }else{
            self.parentViewController()?.dismiss(animated: false, completion: nil)
        }
    }
    
    /*
    @IBAction func tapMonopol(_ sender: Any) {
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let modelList: MainViewController = storyboard.instantiateViewController(withIdentifier: "toMainViewController") as! MainViewController
        
        // 下記を追加する
        modelList.modalPresentationStyle = .fullScreen
     
        let topController = UIApplication.topViewController()
        topController?.present(modelList, animated: false, completion: nil)
        
        //ユーザー用：１　キャスト用：２
        if(UserDefaults.standard.integer(forKey: "user_flg") == 2){
            //Storyboardを指定
            let storyboard = UIStoryboard(name: "CastMain", bundle: nil)
            
            let castInfo: CastTopViewController = storyboard.instantiateViewController(withIdentifier: "toCastTopViewController") as! CastTopViewController
            
            // 下記を追加する
            castInfo.modalPresentationStyle = .fullScreen
     
            let topController = UIApplication.topViewController()
            topController?.present(castInfo, animated: false, completion: nil)
        }else{
            //Storyboardを指定
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
            let modelList: MainViewController = storyboard.instantiateViewController(withIdentifier: "toMainViewController") as! MainViewController
        
            // 下記を追加する
            modelList.modalPresentationStyle = .fullScreen
     
            let topController = UIApplication.topViewController()
            topController?.present(modelList, animated: false, completion: nil)
        }
    }
     */
    
    @IBAction func tapSearchBtn(_ sender: Any) {
        //検索画面へ
        self.appDelegate.searchString = ""//重要(検索文字列をクリア)
        UtilToViewController.toCastSearchViewController()
    }
    
    @IBAction func tapRanking(_ sender: Any) {
        self.appDelegate.searchString = ""//重要(検索文字列をクリア)
        self.appDelegate.viewCallFromViewControllerId = ""
        self.appDelegate.viewReloadFlg = 0
        
        UtilToViewController.toMainRankingViewController()
    }

    @IBAction func tapTutorial(_ sender: Any) {
        self.appDelegate.searchString = ""//重要(検索文字列をクリア)
        self.appDelegate.viewCallFromViewControllerId = ""
        self.appDelegate.viewReloadFlg = 0
        
        //UtilToViewController.toMainRankingViewController()
        //tutorial起動
        /**************************************************/
        /**************************************************/
        /**************************************************/
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
        //tutorial起動(ここまで)
        /**************************************************/
        /**************************************************/
        /**************************************************/
    }
    
    @IBAction func tapTweet(_ sender: Any) {
        UtilToViewController.toNoticeViewController()
    }
    
    @IBAction func tapMonopolBtn(_ sender: Any) {
        //マイページ関連＞プロフィール編集画面へ
        if((self.parentViewController()?.restorationIdentifier) == "toMypageViewController"){
            UtilToViewController.toProfileSettingViewController()
        }
    }
    
    @IBAction func tapPoint(_ sender: Any) {
        UtilToViewController.toPurchaseViewController(animated_flg:false)
    }
    
    /*
    @IBAction func tapMenu(_ sender: Any) {
        //self.performSegue(withIdentifier: "showMenu", sender: nil)

        //print("tapmenu")
        

        let menuView:Menuview = UINib(nibName: "Menuview", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! Menuview
        //ユーザー用：１　キャスト用：２
        menuView.menuViewSetting(user_flg: UserDefaults.standard.integer(forKey: "user_flg"))
        //画面サイズに合わせる(selfでなく、superviewにすることが重要)
        menuView.frame = (superview?.frame)!
        // 貼り付ける
        superview?.addSubview(menuView)
    }
 */
    
    //修正が必要
    func toolbarViewSetting(){
        //ポイントをセットする(残りポイント：＊＊＊＊ポイント)
        //let myPoint:Double = UserDefaults.standard.double(forKey: "myPoint")
        //let myLivePoint:Int = UserDefaults.standard.integer(forKey: "myLivePoint")
        //let userFlg:Int = UserDefaults.standard.integer(forKey: "user_flg")//ユーザー用：１　キャスト用：２
    
        /*
        if(userFlg == 2){
            //キャスト用
            pointBtn.setTitle("◆" + UtilFunc.numFormatter(num: myLivePoint) + "配信Pt", for: .normal)//◆5,000配信pt
        }else{
            pointBtn.setTitle("©️" + UtilFunc.numFormatter(num: myPoint), for: .normal)//c12,000
        }
        */
        
        // ポップアップビュー背景色
        let viewColor = UIColor.white
        // 半透明にして親ビューが見えるように。透過度はお好みで。
        self.backgroundColor = viewColor.withAlphaComponent(0.0)
        
        // ダイアログ背景色（白の部分）
        //let baseViewColor = UIColor.gray
        // ちょっとだけ透明にする
        //self.menuView.backgroundColor = baseViewColor.withAlphaComponent(1.0)
        // 角丸にする
        //self.menuView.layer.cornerRadius = 8.0
    }

    //自分自身はサワレナイ(下記を透過したいVIewに記述)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self {
            return nil
        }
        return view
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    /*
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // ステータスバーの高さを取得する
        //let statusBarHeight = UIApplication.shared.statusBarFrame.size.height

        //self.rect_menubutton = menuBtn.frame
        //メニューボタンがうまく押すことができない？
        self.rect_menubutton = CGRect(x:-50, y:-50, width:100, height:100 )
        self.rect_pointbutton = pointBtn.frame
        self.rect_monopolbutton = monopolBtn.frame

        let temp_point = point
        
        //iOS11以上でのみ(?)
        //if #available(iOS 11.0, *) {
        //temp_point.y -= statusBarHeight
        //}

        // 上のボタンの位置だったら透過させる
        if (rect_menubutton!.contains(temp_point) || rect_pointbutton!.contains(temp_point) || rect_monopolbutton!.contains(temp_point)) {
            return true
        }
        
        // それ以外は透過させない
        return false
    }
     */
}
