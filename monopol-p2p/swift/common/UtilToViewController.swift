//
//  UtilToViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/10/30.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import Foundation
import UIKit

class UtilToViewController {

    //横スワイプを使用しているViewController
    //トップ(MainViewController)
    //MainReportViewController
    //MainPurchaseViewController
    //TimelineMainViewController
    //MainListenerViewController
    //MainRankingViewController
    
    //Baseを使用していないViewController
    //CollectionImageViewController
    
    static func toSplashViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let splashViewController: SplashViewController = storyboard.instantiateViewController(withIdentifier: "toSplashViewController") as! SplashViewController

        // 下記を追加する
        splashViewController.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(splashViewController, animated: false, completion: nil)
    }
    
    static func toSubMainViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "SubMain", bundle: nil)
        let subMainConnectionView: SubMainViewController = storyboard.instantiateViewController(withIdentifier: "SubMain") as! SubMainViewController
        
        // 下記を追加する
        subMainConnectionView.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(subMainConnectionView, animated: false, completion: nil)
    }
    
    static func toAppleLoginStartViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "SubMain", bundle: nil)
        let appleLoginStartConnectionView: AppleLoginStartViewController = storyboard.instantiateViewController(withIdentifier: "toAppleLoginStartViewController") as! AppleLoginStartViewController
        
        // 下記を追加する
        appleLoginStartConnectionView.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(appleLoginStartConnectionView, animated: false, completion: nil)
    }
    
    
    
    
    
    //ライブ配信画面への遷移処理
    static func toMediaConnectionViewController(){
        UserDefaults.standard.set(1, forKey: "selectedStreamerAuto")//1:通常、2:自動応答のどれを選んでいるか。
        //let selectedStreamerAuto = UserDefaults.standard.integer(forKey: "selectedStreamerAuto")
        
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mediaConnectionView: MediaConnectionViewController = storyboard.instantiateViewController(withIdentifier: "toMediaConnectionViewController") as! MediaConnectionViewController
        
        // 下記を追加する
        mediaConnectionView.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(mediaConnectionView, animated: false, completion: nil)
    }
    
    //ライブ配信画面への遷移処理(自動応答ユーザー用)
    static func toMediaConnectionViewControllerAuto(){
        UserDefaults.standard.set(2, forKey: "selectedStreamerAuto")//1:通常、2:自動応答のどれを選んでいるか。
        //let selectedStreamerAuto = UserDefaults.standard.integer(forKey: "selectedStreamerAuto")
        
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mediaConnectionView: MediaConnectionViewController = storyboard.instantiateViewController(withIdentifier: "toMediaConnectionViewController") as! MediaConnectionViewController
        
        // 下記を追加する
        mediaConnectionView.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(mediaConnectionView, animated: false, completion: nil)
    }
    
    /***************************************************************/
    /*共通(ネットワークエラー画面など)*****************************************************/
    /***************************************************************/
    static func toNetworkErrorViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let networkerr: NetworkErrorViewController = storyboard.instantiateViewController(withIdentifier: "toNetworkErrorViewController") as! NetworkErrorViewController
        
        // 下記を追加する
        networkerr.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(networkerr, animated: false, completion: nil)
    }
    
    /***************************************************************/
    /*登録時の画面*****************************************************/
    /***************************************************************/
    static func toNextInfoViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "SubMain", bundle: nil)
        let nextview: NextInfoViewController = storyboard.instantiateViewController(withIdentifier: "toNextInfoViewController") as! NextInfoViewController
        
        // 下記を追加する
        nextview.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(nextview, animated: false, completion: nil)
    }
    
    /***************************************************************/
    /*メンテ中の画面*****************************************************/
    /***************************************************************/
    static func toMaintenanceViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let maintenance: MaintenanceViewController = storyboard.instantiateViewController(withIdentifier: "toMaintenanceViewController") as! MaintenanceViewController
        
        // 下記を追加する
        maintenance.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(maintenance, animated: false, completion: nil)
    }
    
    /***************************************************************/
    /*ホーム画面*****************************************************/
    /***************************************************************/
    static func toMainViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modelList: MainViewController = storyboard.instantiateViewController(withIdentifier: "toMainViewController") as! MainViewController
        
        // 下記を追加する
        modelList.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(modelList, animated: false, completion: nil)
    }
    
    static func toMainCastSelectViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let castSelect: MainCastSelectViewController = storyboard.instantiateViewController(withIdentifier: "toMainCastSelectViewController") as! MainCastSelectViewController
        
        // 下記を追加する
        castSelect.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(castSelect, animated: false, completion: nil)
    }
    /*
     static func toCastSelectViewController(){
     //Storyboardを指定
     let storyboard = UIStoryboard(name: "Main", bundle: nil)
     let castSelect: CastSelectViewController = storyboard.instantiateViewController(withIdentifier: "toCastSelectViewController") as! CastSelectViewController
     
     // 下記を追加する
     castSelect.modalPresentationStyle = .fullScreen
     
     let topController = UIApplication.topViewController()
     topController?.present(castSelect, animated: false, completion: nil)
     }
     */
    
    static func toUserInfoViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let modelInfo: UserInfoViewController = storyboard.instantiateViewController(withIdentifier: "toUserInfoViewController") as! UserInfoViewController
        
        // 下記を追加する
        // 背景が真っ黒にならなくなる
        modelInfo.modalPresentationStyle = .overCurrentContext
        //modelInfo.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(modelInfo, animated: true, completion: nil)
    }
    
    static func toPurchaseCommonViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let purchaseCommon: PurchaseCommonViewController = storyboard.instantiateViewController(withIdentifier: "toPurchaseCommonViewController") as! PurchaseCommonViewController
        
        // 下記を追加する
        //purchaseCommon.modalPresentationStyle = .fullScreen
        purchaseCommon.modalPresentationStyle = .overCurrentContext
        
        let topController = UIApplication.topViewController()
        topController?.present(purchaseCommon, animated: true, completion: nil)
    }
    
    static func toMainListenerViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listener: MainListenerViewController = storyboard.instantiateViewController(withIdentifier: "toMainListenerViewController") as! MainListenerViewController
        
        // 下記を追加する
        listener.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(listener, animated: false, completion: nil)
    }
    
    static func toMainRankingViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ranking: MainRankingViewController = storyboard.instantiateViewController(withIdentifier: "toMainRankingViewController") as! MainRankingViewController
        
        // 下記を追加する
        ranking.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(ranking, animated: false, completion: nil)
    }
    
    static func toPairRankingViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pairRanking: PairRankingViewController = storyboard.instantiateViewController(withIdentifier: "toPairRankingViewController") as! PairRankingViewController
        
        // 下記を追加する
        pairRanking.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(pairRanking, animated: false, completion: nil)
    }
    
    static func toCastSearchViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let castSearch: CastSearchViewController = storyboard.instantiateViewController(withIdentifier: "toCastSearchViewController") as! CastSearchViewController
        
        // 下記を追加する
        castSearch.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(castSearch, animated: false, completion: nil)
    }
    
    /***************************************************************/
    /*タイムライン画面*************************************************/
    /***************************************************************/
    static func toTimelineViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
        let timeline: TimelineMainViewController = storyboard.instantiateViewController(withIdentifier: "toTimelineMainViewController") as! TimelineMainViewController
        
        // 下記を追加する
        timeline.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(timeline, animated: false, completion: nil)
    }
    
    //告知画面
    static func toNoticeViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
        let noticeView: NoticeViewController = storyboard.instantiateViewController(withIdentifier: "toNoticeViewController") as! NoticeViewController
        
        // 下記を追加する
        noticeView.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(noticeView, animated: false, completion: nil)
    }
    
    //いいね!ボタンを押した人のリスト画面
    static func toGoodListViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
        let goodListView: GoodListViewController = storyboard.instantiateViewController(withIdentifier: "toGoodListViewController") as! GoodListViewController
        
        // 下記を追加する
        goodListView.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(goodListView, animated: true, completion: nil)
    }
    
    /*
     //フォロー
     static func toFollowViewController(){
     //UserDefaults.standard.set(2, forKey: "userFollowMenu")//ユーザー側フォローメニュのサブメニュー 1:タイムライン
     //Storyboardを指定
     let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
     let followView: FollowViewController = storyboard.instantiateViewController(withIdentifier: "toFollowViewController") as! FollowViewController
     
     // 下記を追加する
     followView.modalPresentationStyle = .fullScreen
     
     let topController = UIApplication.topViewController()
     topController?.present(followView, animated: false, completion: nil)
     }
     
     //フォロワー
     static func toFollowerViewController(){
     //UserDefaults.standard.set(3, forKey: "userFollowMenu")//ユーザー側フォローメニュのサブメニュー 1:タイムライン
     //Storyboardを指定
     let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
     let followerView: FollowerViewController = storyboard.instantiateViewController(withIdentifier: "toFollowerViewController") as! FollowerViewController
     
     // 下記を追加する
     followerView.modalPresentationStyle = .fullScreen
     
     let topController = UIApplication.topViewController()
     topController?.present(followerView, animated: false, completion: nil)
     }
     */

    /***************************************************************/
    /*イベント作成画面********************************************/
    /***************************************************************/
    static func toCreateEventTopViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Wait", bundle: nil)
        let createEventTop: CreateEventTopViewController = storyboard.instantiateViewController(withIdentifier: "toCreateEventTopViewController") as! CreateEventTopViewController
        
        // 下記を追加する
        createEventTop.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(createEventTop, animated: false, completion: nil)
    }
    
    static func toCreateEventViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Wait", bundle: nil)
        let createEvent: CreateEventViewController = storyboard.instantiateViewController(withIdentifier: "toCreateEventViewController") as! CreateEventViewController
        
        // 下記を追加する
        createEvent.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(createEvent, animated: false, completion: nil)
    }

    static func toCreateEventCheckViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Wait", bundle: nil)
        let createEventCheck: CreateEventCheckViewController = storyboard.instantiateViewController(withIdentifier: "toCreateEventCheckViewController") as! CreateEventCheckViewController
        
        // 下記を追加する
        createEventCheck.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(createEventCheck, animated: false, completion: nil)
    }

    /***************************************************************/
    /*配信準備画面****************************************************/
    /***************************************************************/
    static func toWaitTopViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Wait", bundle: nil)
        //let waitTop: WaitTopViewController = storyboard.instantiateViewController(withIdentifier: "toWaitTopViewController") as! WaitTopViewController
        let waitTop: MainWaitTopViewController = storyboard.instantiateViewController(withIdentifier: "toMainWaitTopViewController") as! MainWaitTopViewController
        
        // 下記を追加する
        waitTop.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(waitTop, animated: false, completion: nil)
    }
    
    static func toWaitViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Wait", bundle: nil)
        let waitView: WaitViewController = storyboard.instantiateViewController(withIdentifier: "toWaitViewController") as! WaitViewController
        
        // 下記を追加する
        waitView.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(waitView, animated: false, completion: nil)
    }
    
    static func toScreenshotViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Wait", bundle: nil)
        let screenshotTop: ScreenshotViewController = storyboard.instantiateViewController(withIdentifier: "toScreenshotViewController") as! ScreenshotViewController
        
        // 下記を追加する
        screenshotTop.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(screenshotTop, animated: false, completion: nil)
    }
    
    /***************************************************************/
    /*トーク画面*****************************************************/
    /***************************************************************/
    static func toTalkTopViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Talk", bundle: nil)
        let talktop: TalkTopViewController = storyboard.instantiateViewController(withIdentifier: "toTalkTopViewController") as! TalkTopViewController
        
        // 下記を追加する
        talktop.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(talktop, animated: false, completion: nil)
    }
    
    static func toTalkInfoViewController(){
        //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
        UserDefaults.standard.set(4, forKey: "selectedMenuNum")
        
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Talk", bundle: nil)
        let talkinfo: TalkInfoViewController = storyboard.instantiateViewController(withIdentifier: "toTalkInfoViewController") as! TalkInfoViewController
        
        // 下記を追加する
        talkinfo.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(talkinfo, animated: false, completion: nil)
    }
    
    /***************************************************************/
    /*マイページ*****************************************************/
    /***************************************************************/
    //マイページ画面の遷移処理
    static func toMypageViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let mypage: MypageViewController = storyboard.instantiateViewController(withIdentifier: "toMypageViewController") as! MypageViewController
        
        // 下記を追加する
        mypage.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(mypage, animated: false, completion: nil)
    }
    
    //マイイベント画面の遷移処理
    static func toMyEventCheckViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let myevent: MyEventCheckViewController = storyboard.instantiateViewController(withIdentifier: "toMyEventCheckViewController") as! MyEventCheckViewController
        
        // 下記を追加する
        myevent.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(myevent, animated: animated_flg, completion: nil)
    }
    
    //マイコイン画面の遷移処理
    static func toPurchaseViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let purchase: MainPurchaseViewController = storyboard.instantiateViewController(withIdentifier: "toMainPurchaseViewController") as! MainPurchaseViewController
        
        // 下記を追加する
        purchase.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(purchase, animated: animated_flg, completion: nil)
    }
    
    //マイコレクション画面の遷移処理
    static func toMyCollectionViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let mycollection: MyCollectionViewController = storyboard.instantiateViewController(withIdentifier: "toMyCollectionViewController") as! MyCollectionViewController
        
        // 下記を追加する
        mycollection.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(mycollection, animated: animated_flg, completion: nil)
    }
    
    //視聴履歴の遷移処理
    static func toWatchRirekiViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let watchRireki: WatchRirekiViewController = storyboard.instantiateViewController(withIdentifier: "toWatchRirekiViewController") as! WatchRirekiViewController
        
        // 下記を追加する
        watchRireki.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(watchRireki, animated: animated_flg, completion: nil)
    }
    
    //マイコレクション個別画面の遷移処理
    static func toCollectionImageViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let collectionInfo: CollectionImageViewController = storyboard.instantiateViewController(withIdentifier: "toCollectionImageViewController") as! CollectionImageViewController
        
        // 下記を追加する
        collectionInfo.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(collectionInfo, animated: animated_flg, completion: nil)
    }
    
    //フォロー管理の遷移処理
    static func toFollowManageViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let followManage: FollowManageViewController = storyboard.instantiateViewController(withIdentifier: "toFollowManageViewController") as! FollowManageViewController
        
        // 下記を追加する
        followManage.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(followManage, animated: animated_flg, completion: nil)
    }
    
    //配信ランクの遷移処理
    static func toPriceSettingViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let priceSetting: PriceSettingViewController = storyboard.instantiateViewController(withIdentifier: "toPriceSettingViewController") as! PriceSettingViewController
        
        // 下記を追加する
        priceSetting.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(priceSetting, animated: animated_flg, completion: nil)
    }
    
    //配信ランクの遷移処理(配信LV10以上)
    static func toPriceSettingUpgradeViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let priceSettingUpgrade: PriceSettingUpgradeViewController = storyboard.instantiateViewController(withIdentifier: "toPriceSettingUpgradeViewController") as! PriceSettingUpgradeViewController
        
        // 下記を追加する
        priceSettingUpgrade.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(priceSettingUpgrade, animated: animated_flg, completion: nil)
    }
    
    //配信レポート画面の遷移処理
    static func toLiveReportViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let mainReport: MainReportViewController = storyboard.instantiateViewController(withIdentifier: "toMainReportViewController") as! MainReportViewController
        
        // 下記を追加する
        mainReport.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(mainReport, animated: animated_flg, completion: nil)
    }

    /*
    //リクエスト履歴画面の遷移処理
    static func toRequestRirekiViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let requestRireki: RequestRirekiViewController = storyboard.instantiateViewController(withIdentifier: "toRequestRirekiViewController") as! RequestRirekiViewController
        
        // 下記を追加する
        requestRireki.modalPresentationStyle = .fullScreen
     
        let topController = UIApplication.topViewController()
        topController?.present(requestRireki, animated: animated_flg, completion: nil)
    }
    */
    
    //スターを換金する画面の遷移処理
    static func toToYenViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let toYen: ToYenViewController = storyboard.instantiateViewController(withIdentifier: "toToYenViewController") as! ToYenViewController
        
        // 下記を追加する
        toYen.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(toYen, animated: animated_flg, completion: nil)
    }
    
    /*
    //スターをコインに変換する画面の遷移処理
    static func toToCoinViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let toCoin: ToCoinViewController = storyboard.instantiateViewController(withIdentifier: "toToCoinViewController") as! ToCoinViewController
        
        // 下記を追加する
        toCoin.modalPresentationStyle = .fullScreen
     
        let topController = UIApplication.topViewController()
        topController?.present(toCoin, animated: animated_flg, completion: nil)
    }
    */
    
    //本人確認手続の画面の遷移処理
    static func toIdentificationViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let identification: IdentificationViewController = storyboard.instantiateViewController(withIdentifier: "toIdentificationViewController") as! IdentificationViewController
        
        // 下記を追加する
        identification.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(identification, animated: animated_flg, completion: nil)
    }
    
    //支払いレポート画面の遷移処理
    static func toPayReportViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let payReport: PayReportViewController = storyboard.instantiateViewController(withIdentifier: "toPayReportViewController") as! PayReportViewController
        
        // 下記を追加する
        payReport.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(payReport, animated: animated_flg, completion: nil)
    }
    
    //プレゼントショップ画面の遷移処理
    static func toPresentShopViewController(animated_flg:Bool){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let presentShop: PresentShopViewController = storyboard.instantiateViewController(withIdentifier: "toPresentShopViewController") as! PresentShopViewController
        
        // 下記を追加する
        presentShop.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(presentShop, animated: animated_flg, completion: nil)
    }
    
    //自分のプロフィール確認画面への遷移処理
    static func toMyprofileInfoViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Mypage", bundle: nil)
        let myprofile: MyprofileInfoViewController = storyboard.instantiateViewController(withIdentifier: "toMyprofileInfoViewController") as! MyprofileInfoViewController
        
        // 下記を追加する
        myprofile.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(myprofile, animated: false, completion: nil)
    }

    /***************************************************************/
    /*マイページ＞設定*****************************************************/
    /***************************************************************/
    //設定の遷移処理
    static func toUserSettingViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let userSetting: UserSettingViewController = storyboard.instantiateViewController(withIdentifier: "toUserSettingViewController") as! UserSettingViewController
        
        // 下記を追加する
        userSetting.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(userSetting, animated: false, completion: nil)
    }
    
    //プロフィール編集の遷移処理
    static func toProfileSettingViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let profileSetting: ProfileSettingViewController = storyboard.instantiateViewController(withIdentifier: "toProfileSettingViewController") as! ProfileSettingViewController
        
        // 下記を追加する
        profileSetting.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(profileSetting, animated: false, completion: nil)
    }
    
    //アカウント設定の遷移処理
    static func toAccountEditViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let accountEdit: AccountEditViewController = storyboard.instantiateViewController(withIdentifier: "toAccountEditViewController") as! AccountEditViewController
        
        // 下記を追加する
        accountEdit.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(accountEdit, animated: false, completion: nil)
    }
    
    //ブラックリスト画面の遷移処理
    static func toBlackListViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let blacklist: BlackListViewController = storyboard.instantiateViewController(withIdentifier: "toBlackListViewController") as! BlackListViewController
        
        // 下記を追加する
        blacklist.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(blacklist, animated: false, completion: nil)
    }
    
    //リストア画面の遷移処理
    static func toRestoreViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let restore: RestoreViewController = storyboard.instantiateViewController(withIdentifier: "toRestoreViewController") as! RestoreViewController
        
        // 下記を追加する
        restore.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(restore, animated: false, completion: nil)
    }
    
    //通知設定画面の遷移処理
    static func toNotifySettingViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let notify: NotifySettingViewController = storyboard.instantiateViewController(withIdentifier: "toNotifySettingViewController") as! NotifySettingViewController
        
        // 下記を追加する
        notify.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(notify, animated: false, completion: nil)
    }
    
    //動画設定画面の遷移処理
    static func toMovieSettingViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let movie: MovieSettingViewController = storyboard.instantiateViewController(withIdentifier: "toMovieSettingViewController") as! MovieSettingViewController
        
        // 下記を追加する
        movie.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(movie, animated: false, completion: nil)
    }
    
    //利用規約画面の遷移処理
    static func toRuleViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let rule: RuleViewController = storyboard.instantiateViewController(withIdentifier: "toRuleViewController") as! RuleViewController
        
        // 下記を追加する
        rule.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(rule, animated: false, completion: nil)
    }
    
    //問い合わせ画面の遷移処理
    static func toContactUsViewController(){
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let rule: ContactUsViewController = storyboard.instantiateViewController(withIdentifier: "toContactUsViewController") as! ContactUsViewController
        
        // 下記を追加する
        rule.modalPresentationStyle = .fullScreen
        
        let topController = UIApplication.topViewController()
        topController?.present(rule, animated: false, completion: nil)
    }
    
    /*
     static func goModelList() -> Void {
     //メモリ解放(？)
     UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
     // 画面遷移
     //Storyboardを指定
     let storyboard = UIStoryboard(name: "Main", bundle: nil)
     //Viewcontrollerを指定
     //let initialViewController = storyboard.instantiateInitialViewController()
     let modelList: UIViewController = storyboard.instantiateViewController(withIdentifier: "modelList")
     
     // 下記を追加する
     modelList.modalPresentationStyle = .fullScreen
     
     modelList.present(modelList, animated: false, completion: nil)
     }
     */
}
