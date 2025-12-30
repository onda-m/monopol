//
//  CreateEventViewController.swift
//  swift_skyway
//
//  Created by dev monopol on 2021/08/23.
//  Copyright © 2021 worldtrip. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITabBarDelegate{
 
    let iconSize: CGFloat = 16.0

    //イベント送信完了用(id_tempはイベントID)
    struct ResultJson: Codable {
        let id_temp: Int
        //let result: [UserResult]
    }
    var temp_id: Int = 0
    
    private var myTabBar:UITabBar!
    var coverView: UIView!//キーボード以外を覆うVIEW
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var keyboardFlg = 0//1の時はキーボードをずらさずに表示する
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    //イベントの価格設定リスト用
    var eventStarPriceList: [(id:String, star:String, price:String, value01:String, order_cd:String, status:String)] = []
    var eventStarPriceListTemp: [(id:String, star:String, price:String, value01:String, order_cd:String, status:String)] = []
    
    //1:ホーム、2:タイムライン、3:配信 4:トーク 5:マイページ
    var selected_menu_num = 3
    
    /*
    // 選択肢(価格の設定)
    let priceRangeList = ["未選択", "5,000円", "1,0000円", "2,0000円"]
    var priceRangeCd: Int = 0

    // 選択肢(獲得スターの設定)
    let starRangeList = ["未選択", "1,000スター", "2,000スター", "3,000スター"]
    var starRangeCd: Int = 0
    */
    
    // 選択肢(1枠のサシライブ時間)
    let eventOneFrameTimeList = ["未選択", "10分", "20分", "30分", "40分", "50分", "1時間"]
    var eventOneFrameTimeCd: Int = 0
    //DBインサート時のマッピング用
    let eventOneFrameTimeMappingList = ["0", "10", "20", "30", "40", "50", "60"]
    
    // 選択肢(イベント価格設定のプルダウン配列)
    //var eventStarPriceArray = [String]()
    var eventStarPriceCd: Int = 0
    
    //1回目イベントの実施日
    var event01YearCd: Int = 0
    var event01MonthCd: Int = 0
    var event01DayCd: Int = 0
    var event01Date = Date()//イベントの実施日(予約開始日（1週間前）の計算用)
    var event01ReserveDate = Date()//予約開始日
    //2回目イベントの実施日
    var event02YearCd: Int = 0
    var event02MonthCd: Int = 0
    var event02DayCd: Int = 0
    var event02Date = Date()//イベントの実施日(予約開始日（1週間前）の計算用)
    var event02ReserveDate = Date()//予約開始日

    //1回目イベントの始めたい時間
    var event01StartTimeCd: Int = 0
    //2回目イベントの始めたい時間
    var event02StartTimeCd: Int = 0
    // 選択肢(始めたい時間)
    let eventStartTimeList = ["未選択", "00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30",
                              "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30",
                              "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30",
                              "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30",
                              "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"]
    //DBインサート時のマッピング用
    let eventStartTimeMappingHourList = ["99", "0", "0", "1", "1", "2", "2", "3", "3", "4", "4", "5", "5"
                                         , "6", "6", "7", "7", "8", "8", "9", "9", "10", "10"
                                         , "11", "11", "12", "12", "13", "13", "14", "14", "15", "15"
                                         , "16", "16", "17", "17", "18", "18", "19", "19", "20", "20"
                                         , "21", "21", "22", "22", "23", "23"]
    let eventStartTimeMappingMinuteList = ["99", "0", "30", "0", "30", "0", "30", "0", "30", "0", "30", "0", "30"
                                           , "0", "30", "0", "30", "0", "30", "0", "30", "0", "30"
                                           , "0", "30", "0", "30", "0", "30", "0", "30", "0", "30"
                                           , "0", "30", "0", "30", "0", "30", "0", "30", "0", "30"
                                           , "0", "30", "0", "30", "0", "30"]
    
    //1回目イベントの枠数
    var event01SumFrameCd: Int = 0
    //2回目イベントの枠数
    var event02SumFrameCd: Int = 0
    // 選択肢(イベント枠数)
    let eventSumFrameList = ["未選択", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    //1回目イベントのインターバル
    var event01IntervalCd: Int = 0
    //2回目イベントのインターバル
    var event02IntervalCd: Int = 0
    // 選択肢(イベントのインターバル)
    let eventIntervalList = ["未選択", "2分", "3分", "4分", "5分", "6分", "7分", "8分", "9分", "10分"]
    //DBインサート時のマッピング用
    let eventIntervalMappingList = ["0", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    //1回目イベントの予約開始日(ドラム項目の何番目を選択しているか)
    var event01ReserveStartYearCd: Int = 0
    var event01ReserveStartMonthCd: Int = 0
    var event01ReserveStartDayCd: Int = 0
    var event01ReserveStartHourCd: Int = 0
    var event01ReserveStartMinuteCd: Int = 0
    //2回目イベントの予約開始日(ドラム項目の何番目を選択しているか)
    var event02ReserveStartYearCd: Int = 0
    var event02ReserveStartMonthCd: Int = 0
    var event02ReserveStartDayCd: Int = 0
    var event02ReserveStartHourCd: Int = 0
    var event02ReserveStartMinuteCd: Int = 0
    
    /*
    // 選択肢(イベント開始日の設定)
    let eventStartMonthList = ["-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    
    let eventStartDayList = ["-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    var eventStartDayCd: Int = 0
    
    // 選択肢(イベント終了日の設定)
    let eventEndMonthList = ["-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    var eventEndMonthCd: Int = 0
    
    let eventEndDayList = ["-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    var eventEndDayCd: Int = 0
    
    // 選択肢(イベント合計時間)
    //let eventSumTimeList = ["未選択", "30分", "1時間", "1時間30分", "2時間", "2時間30分", "3時間"]
    //var eventSumTimeCd: Int = 0

    // 選択肢(予約開始日の設定)
    let eventReserveStartMonthList = ["-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    var eventReserveStartMonthCd: Int = 0
    
    let eventReserveStartDayList = ["-", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    var eventReserveStartDayCd: Int = 0
    */
    
    //選択肢(価格の設定)
    //@IBOutlet weak var sexView: UIView!
    //@IBOutlet weak var priceRangeBtn: UIButton!
    //@IBOutlet weak var eventOneFrameTimeBtn: UIButton!
    //@IBOutlet weak var starPriceRangeBtn: UIButton!
    @IBOutlet weak var eventOneFrameTimeTextField: UITextField!
    @IBOutlet weak var starPriceRangeTextField: UITextField!
    @IBOutlet weak var eventStartTime01TextField: UITextField!//1回目の開始時間
    @IBOutlet weak var eventStartTime02TextField: UITextField!//2回目の開始時間
    
    @IBOutlet weak var eventSumFrame01TextField: UITextField!//1回目の合計枠数
    @IBOutlet weak var eventSumFrame02TextField: UITextField!//2回目の合計枠数
    @IBOutlet weak var eventInterval01TextField: UITextField!//1回目のインターバル1-10分を指定
    @IBOutlet weak var eventInterval02TextField: UITextField!//2回目のインターバル1-10分を指定
    
    @IBOutlet weak var eventDay01Btn: UIButton!//1回目のイベント実施日ボタン
    @IBOutlet weak var eventDay02Btn: UIButton!//2回目のイベント実施日ボタン
    
    //●1回目 00月00日のイベント開始時間
    @IBOutlet weak var eventDay01Lbl: UILabel!//1回目のイベント開始ラベル
    //●2回目 00月00日のイベント開始時間
    @IBOutlet weak var eventDay02Lbl: UILabel!//2回目のイベント開始ラベル
    
    @IBOutlet weak var titleLabel01: UILabel!//「1枠のサシライブ時間」のラベル
    @IBOutlet weak var titleLabel02: UILabel!//「価格の設定」のラベル
    @IBOutlet weak var titleLabel03: UILabel!//「イベントの日程」のラベル
    @IBOutlet weak var eventNoteLabel: UILabel!//「イベントの特典」のラベル
    
//    @IBOutlet weak var eventStartMonthBtn: UIButton!
//    @IBOutlet weak var eventStartDayBtn: UIButton!
//    @IBOutlet weak var eventEndMonthBtn: UIButton!
//    @IBOutlet weak var eventEndDayBtn: UIButton!
//    @IBOutlet weak var eventStartTime01Btn: UIButton!//1回目の開始時間
//    @IBOutlet weak var eventSumFrame01Btn: UIButton!//合計枠数
//    @IBOutlet weak var eventInterval01Btn: UIButton!//インターバル1-10分を指定
//    @IBOutlet weak var eventStartTime02Btn: UIButton!//2回目の開始時間
//    @IBOutlet weak var eventSumFrame02Btn: UIButton!//合計枠数
//    @IBOutlet weak var eventInterval02Btn: UIButton!//インターバル1-10分を指定
    
    @IBOutlet weak var eventReserveStart01Btn: UIButton!//1回目の予約開始日ボタン
    @IBOutlet weak var eventReserveStart02Btn: UIButton!//2回目の予約開始日ボタン
    
    //●1回目 00月00日の予約開始日
    @IBOutlet weak var eventReserveStart01Lbl: UILabel!//1回目の予約開始日ラベル
    //●2回目 00月00日の予約開始日
    @IBOutlet weak var eventReserveStart02Lbl: UILabel!//2回目の予約開始日ラベル
    
    @IBOutlet weak var eventNoteTextView: PlaceHolderTextView!
    @IBOutlet weak var eventCreateNextBtn: UIButton!
    
    @IBOutlet weak var eventDateSelectView: UIView!
    @IBOutlet weak var eventDateSelectSubView: UIView!
    @IBOutlet weak var eventStartDatePicker: UIDatePicker!
    @IBOutlet weak var eventDateCompBtn: UIButton!
    @IBOutlet weak var eventDateClearBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.eventDateSelectView.isHidden = true
//        self.eventDateSelectView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
//        self.eventDateSelectSubView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
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
        //mainToolbarView.settingOkBtn.addTarget(self,
        //                 action: #selector(self.tapSettingOkBtn(sender:)),
        //                 for: .touchUpInside)
        
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
        let liveBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"live_on"), tag: 3)
        liveBtn.image = UIImage(named: "live_on")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        //ここだけ特別な処理(ダイアログを被せるため)
        //liveBtn.selectedImage = UIImage(named: "live_on")
        
        //ボタンを生成(トーク)
        let dmBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"dm_off"), tag: 4)
        dmBtn.image = UIImage(named: "dm_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        dmBtn.selectedImage = UIImage(named: "dm_on")
        
        //ボタンを生成(マイページ)
        let myPageBtn:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named:"mypage_off"), tag: 5)
        myPageBtn.image = UIImage(named: "mypage_off")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        //選択中のアイテムの画像はレンダリングモードを指定しない。
        myPageBtn.selectedImage = UIImage(named: "mypage_on")
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
        
        /*
        self.sexCd = UserDefaults.standard.integer(forKey: "sex_cd")
        if(self.sexCd == 0){
            self.sexBtn.setTitle("未選択", for: .normal) // ボタンのタイトル
        }else if(self.sexCd == 1){
            self.sexBtn.setTitle("男性", for: .normal) // ボタンのタイトル
        }else if(self.sexCd == 2){
            self.sexBtn.setTitle("女性", for: .normal) // ボタンのタイトル
        }
        */
        
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.eventDay01Lbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-4 ,string: "1回目のイベント設定", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//1回目のイベント開始ラベル
        self.eventDay02Lbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-4 ,string: "2回目のイベント設定（任意）", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//2回目のイベント開始ラベル
        self.titleLabel01.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-4 ,string: "1枠のサシライブ時間", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//「1枠のサシライブ時間」のラベル
        self.titleLabel02.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-4 ,string: "価格の設定", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//「価格の設定」のラベル
        self.titleLabel03.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-4 ,string: "イベントの日程", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//「イベントの日程」のラベル
        self.eventNoteLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-4 ,string: "イベント特典を入力（任意）", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//「イベントの特典」のラベル

        //初期値
        // 選択肢(1枠のサシライブ時間)
        self.eventOneFrameTimeCd = appDelegate.eventOneFrameTimeCd
        // 選択肢(価格の設定)
        self.eventStarPriceCd = appDelegate.starPriceRangeCd
        // 選択肢(1回目イベントの実施日)
        self.event01YearCd = appDelegate.event01YearCd
        self.event01MonthCd = appDelegate.event01MonthCd
        self.event01DayCd = appDelegate.event01DayCd
        // 選択肢(2回目イベントの実施日)
        self.event02YearCd = appDelegate.event02YearCd
        self.event02MonthCd = appDelegate.event02MonthCd
        self.event02DayCd = appDelegate.event02DayCd
        //1回目イベントの始めたい時間
        self.event01StartTimeCd = appDelegate.event01StartTimeCd
        //2回目イベントの始めたい時間
        self.event02StartTimeCd = appDelegate.event02StartTimeCd
        //1回目イベントの枠数
        self.event01SumFrameCd = appDelegate.event01SumFrameCd
        //2回目イベントの枠数
        self.event02SumFrameCd = appDelegate.event02SumFrameCd
        //1回目イベントのインターバル
        self.event01IntervalCd = appDelegate.event01IntervalCd
        //2回目イベントのインターバル
        self.event02IntervalCd = appDelegate.event02IntervalCd
        // 1回目イベントの予約開始日
        self.event01ReserveStartYearCd = appDelegate.event01ReserveStartYearCd
        self.event01ReserveStartMonthCd = appDelegate.event01ReserveStartMonthCd
        self.event01ReserveStartDayCd = appDelegate.event01ReserveStartDayCd
        self.event01ReserveStartHourCd = appDelegate.event01ReserveStartHourCd
        self.event01ReserveStartMinuteCd = appDelegate.event01ReserveStartMinuteCd
        // 2回目イベントの予約開始日
        self.event02ReserveStartYearCd = appDelegate.event02ReserveStartYearCd
        self.event02ReserveStartMonthCd = appDelegate.event02ReserveStartMonthCd
        self.event02ReserveStartDayCd = appDelegate.event02ReserveStartDayCd
        self.event02ReserveStartHourCd = appDelegate.event02ReserveStartHourCd
        self.event02ReserveStartMinuteCd = appDelegate.event02ReserveStartMinuteCd
        //初期値ここまで
        
        //テキストフィールドの設定
        self.eventOneFrameTimeTextField.tag = 1
        let pickerView01 = UIPickerView()
        pickerView01.center = self.view.center
        pickerView01.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView01.delegate = self
        pickerView01.dataSource = self
        // はじめに表示する項目を指定
        pickerView01.selectRow(self.eventOneFrameTimeCd, inComponent: 0, animated: true)
        pickerView01.tag = 1;
        self.eventOneFrameTimeTextField.inputView = pickerView01
        
        let toolBar01 = UIToolbar()
        toolBar01.sizeToFit()
        let button01 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button01.tag = 1
        toolBar01.setItems([button01], animated: true)
        toolBar01.isUserInteractionEnabled = true
        self.eventOneFrameTimeTextField.inputAccessoryView = toolBar01
        
        // 枠線の太さ
        self.eventOneFrameTimeTextField.layer.borderWidth = 0
        // 角丸
        self.eventOneFrameTimeTextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventOneFrameTimeTextField.layer.masksToBounds = true
        //背景色
        self.eventOneFrameTimeTextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.eventOneFrameTimeTextField.tintColor = UIColor.clear
        
        //テキストフィールドの設定
        self.starPriceRangeTextField.tag = 2
        let pickerView02 = UIPickerView()
        pickerView02.center = self.view.center
        pickerView02.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView02.delegate = self
        pickerView02.dataSource = self
        // はじめに表示する項目を指定
        pickerView02.selectRow(self.eventStarPriceCd, inComponent: 0, animated: true)
        pickerView02.tag = 2;
        self.starPriceRangeTextField.inputView = pickerView02
        
        let toolBar02 = UIToolbar()
        toolBar02.sizeToFit()
        let button02 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button02.tag = 2
        toolBar02.setItems([button02], animated: true)
        toolBar02.isUserInteractionEnabled = true
        self.starPriceRangeTextField.inputAccessoryView = toolBar02
        
        // 枠線の太さ
        self.starPriceRangeTextField.layer.borderWidth = 0
        // 角丸
        self.starPriceRangeTextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.starPriceRangeTextField.layer.masksToBounds = true
        //背景色
        self.starPriceRangeTextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.starPriceRangeTextField.tintColor = UIColor.clear
        
        //1回目の開始時間
        //テキストフィールドの設定
        self.eventStartTime01TextField.tag = 5
        let pickerView05 = UIPickerView()
        pickerView05.center = self.view.center
        pickerView05.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView05.delegate = self
        pickerView05.dataSource = self
        // はじめに表示する項目を指定
        //pickerView05.selectRow(self.event01StartTimeCd, inComponent: 0, animated: true)
        pickerView05.selectRow(33, inComponent: 0, animated: true)
        pickerView05.tag = 5;
        self.eventStartTime01TextField.inputView = pickerView05
        
        let toolBar05 = UIToolbar()
        toolBar05.sizeToFit()
        let button05 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button05.tag = 5
        toolBar05.setItems([button05], animated: true)
        toolBar05.isUserInteractionEnabled = true
        self.eventStartTime01TextField.inputAccessoryView = toolBar05
        
        // 枠線の太さ
        self.eventStartTime01TextField.layer.borderWidth = 0
        // 角丸
        self.eventStartTime01TextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventStartTime01TextField.layer.masksToBounds = true
        //背景色
        self.eventStartTime01TextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.eventStartTime01TextField.tintColor = UIColor.clear
        
        
        //2回目の開始時間
        //テキストフィールドの設定
        self.eventStartTime02TextField.tag = 9
        let pickerView09 = UIPickerView()
        pickerView09.center = self.view.center
        pickerView09.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView09.delegate = self
        pickerView09.dataSource = self
        // はじめに表示する項目を指定
        pickerView09.selectRow(self.event02StartTimeCd, inComponent: 0, animated: true)
        pickerView09.tag = 9;
        self.eventStartTime02TextField.inputView = pickerView09
        
        let toolBar09 = UIToolbar()
        toolBar09.sizeToFit()
        let button09 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button09.tag = 9
        toolBar09.setItems([button09], animated: true)
        toolBar09.isUserInteractionEnabled = true
        self.eventStartTime02TextField.inputAccessoryView = toolBar09
        
        // 枠線の太さ
        self.eventStartTime02TextField.layer.borderWidth = 0
        // 角丸
        self.eventStartTime02TextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventStartTime02TextField.layer.masksToBounds = true
        //背景色
        self.eventStartTime02TextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.eventStartTime02TextField.tintColor = UIColor.clear
        
        
        // 枠線の色
        //self.eventDay01Btn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventDay01Btn.layer.borderWidth = 0
        // 角丸
        self.eventDay01Btn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventDay01Btn.layer.masksToBounds = true
        //背景色
        self.eventDay01Btn.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        
        // 枠線の色
        //self.eventDay02Btn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventDay02Btn.layer.borderWidth = 0
        // 角丸
        self.eventDay02Btn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventDay02Btn.layer.masksToBounds = true
        //背景色
        self.eventDay02Btn.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        
        
        //1回目の合計枠数(tag=6)
        //テキストフィールドの設定
        self.eventSumFrame01TextField.tag = 6
        let pickerView06 = UIPickerView()
        pickerView06.center = self.view.center
        pickerView06.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView06.delegate = self
        pickerView06.dataSource = self
        // はじめに表示する項目を指定
        pickerView06.selectRow(self.event01SumFrameCd, inComponent: 0, animated: true)
        pickerView06.tag = 6;
        self.eventSumFrame01TextField.inputView = pickerView06
        
        let toolBar06 = UIToolbar()
        toolBar06.sizeToFit()
        let button06 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button06.tag = 6
        toolBar06.setItems([button06], animated: true)
        toolBar06.isUserInteractionEnabled = true
        self.eventSumFrame01TextField.inputAccessoryView = toolBar06
        
        // 枠線の太さ
        self.eventSumFrame01TextField.layer.borderWidth = 0
        // 角丸
        self.eventSumFrame01TextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventSumFrame01TextField.layer.masksToBounds = true
        //背景色
        self.eventSumFrame01TextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.eventSumFrame01TextField.tintColor = UIColor.clear
        
        //2回目の合計枠数(tag=10)
        //テキストフィールドの設定
        self.eventSumFrame02TextField.tag = 10
        let pickerView10 = UIPickerView()
        pickerView10.center = self.view.center
        pickerView10.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView10.delegate = self
        pickerView10.dataSource = self
        // はじめに表示する項目を指定
        pickerView10.selectRow(self.event02SumFrameCd, inComponent: 0, animated: true)
        pickerView10.tag = 10;
        self.eventSumFrame02TextField.inputView = pickerView10
        
        let toolBar10 = UIToolbar()
        toolBar10.sizeToFit()
        let button10 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button10.tag = 10
        toolBar10.setItems([button10], animated: true)
        toolBar10.isUserInteractionEnabled = true
        self.eventSumFrame02TextField.inputAccessoryView = toolBar10
        
        // 枠線の太さ
        self.eventSumFrame02TextField.layer.borderWidth = 0
        // 角丸
        self.eventSumFrame02TextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventSumFrame02TextField.layer.masksToBounds = true
        //背景色
        self.eventSumFrame02TextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.eventSumFrame02TextField.tintColor = UIColor.clear
        
        
        //1回目のインターバル(tag=7)
        //テキストフィールドの設定
        self.eventInterval01TextField.tag = 7
        let pickerView07 = UIPickerView()
        pickerView07.center = self.view.center
        pickerView07.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView07.delegate = self
        pickerView07.dataSource = self
        // はじめに表示する項目を指定
        pickerView07.selectRow(self.event01IntervalCd, inComponent: 0, animated: true)
        pickerView07.tag = 7;
        self.eventInterval01TextField.inputView = pickerView07
        
        let toolBar07 = UIToolbar()
        toolBar07.sizeToFit()
        let button07 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button07.tag = 7
        toolBar07.setItems([button07], animated: true)
        toolBar07.isUserInteractionEnabled = true
        self.eventInterval01TextField.inputAccessoryView = toolBar07
        
        // 枠線の太さ
        self.eventInterval01TextField.layer.borderWidth = 0
        // 角丸
        self.eventInterval01TextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventInterval01TextField.layer.masksToBounds = true
        //背景色
        self.eventInterval01TextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.eventInterval01TextField.tintColor = UIColor.clear
        
        //2回目のインターバル(tag=11)
        //テキストフィールドの設定
        self.eventInterval02TextField.tag = 11
        let pickerView11 = UIPickerView()
        pickerView11.center = self.view.center
        pickerView11.backgroundColor = UIColor.white
        // プロトコルの設定
        pickerView11.delegate = self
        pickerView11.dataSource = self
        // はじめに表示する項目を指定
        pickerView11.selectRow(self.event02IntervalCd, inComponent: 0, animated: true)
        pickerView11.tag = 11;
        self.eventInterval02TextField.inputView = pickerView11
        
        let toolBar11 = UIToolbar()
        toolBar11.sizeToFit()
        let button11 = UIBarButtonItem(title:"確定",style:.plain,target:self,action:#selector(self.action))
        button11.tag = 11
        toolBar11.setItems([button11], animated: true)
        toolBar11.isUserInteractionEnabled = true
        self.eventInterval02TextField.inputAccessoryView = toolBar11
        
        // 枠線の太さ
        self.eventInterval02TextField.layer.borderWidth = 0
        // 角丸
        self.eventInterval02TextField.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventInterval02TextField.layer.masksToBounds = true
        //背景色
        self.eventInterval02TextField.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        //カーソル（青い縦棒）非表示
        self.eventInterval02TextField.tintColor = UIColor.clear
        

        //予約開始日関連
        // 枠線の色
        //self.eventReserveStart01Btn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventReserveStart01Btn.layer.borderWidth = 0
        // 角丸
        self.eventReserveStart01Btn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventReserveStart01Btn.layer.masksToBounds = true
        //背景色
        self.eventReserveStart01Btn.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        
        // 枠線の色
        //self.eventReserveStart02Btn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventReserveStart02Btn.layer.borderWidth = 0
        // 角丸
        self.eventReserveStart02Btn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventReserveStart02Btn.layer.masksToBounds = true
        //背景色
        self.eventReserveStart02Btn.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        
        // 枠線の色
        //self.eventNoteTextView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventNoteTextView.layer.borderWidth = 0
        // 角丸
        self.eventNoteTextView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventNoteTextView.layer.masksToBounds = true
        //背景色
        self.eventNoteTextView.backgroundColor = Util.EVENT_CREATE_BTN_BG_COLOR
        
        //日付ピッカーの確定ボタン
        // 枠線の色
        //self.eventDateCompBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventDateCompBtn.layer.borderWidth = 0
        // 角丸
        self.eventDateCompBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventDateCompBtn.layer.masksToBounds = true
        //背景色
        self.eventDateCompBtn.backgroundColor = Util.EVENT_CREATE_NEXT_BTN_BG_COLOR
        
        //日付ピッカーのクリアボタン
        // 枠線の色
        //self.eventDateClearBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventDateClearBtn.layer.borderWidth = 0
        // 角丸
        self.eventDateClearBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventDateClearBtn.layer.masksToBounds = true
        //背景色
        self.eventDateClearBtn.backgroundColor = Util.EVENT_CREATE_NEXT_BTN_BG_COLOR
        
        //次へボタン
        // 枠線の色
        //self.eventCreateNextBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.eventCreateNextBtn.layer.borderWidth = 0
        // 角丸
        self.eventCreateNextBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.eventCreateNextBtn.layer.masksToBounds = true
        //背景色
        self.eventCreateNextBtn.backgroundColor = Util.EVENT_CREATE_NEXT_BTN_BG_COLOR

        //初期表示
        // 選択肢(1枠のサシライブ時間)
        self.eventOneFrameTimeTextField.text = self.eventOneFrameTimeList[self.eventOneFrameTimeCd]
        
        // 選択肢(価格の設定)
        //self.starPriceRangeTextField.text = self.eventStarPriceList[self.eventStarPriceCd].value01
        //＞価格の設定をDBから取得取得した後に初期値設定
        
        if(appDelegate.event01MonthCd == 0 || appDelegate.event01DayCd == 0){
            //1回目イベント実施日
            self.eventDay01Btn.setTitle("未選択", for: .normal)
        }else{
            //イベントの開始日
            var stringEventStart01 = ""
            stringEventStart01.append(String(self.appDelegate.event01YearCd))
            stringEventStart01.append("年")
            stringEventStart01.append(String(self.appDelegate.event01MonthCd))
            stringEventStart01.append("月")
            stringEventStart01.append(String(self.appDelegate.event01DayCd))
            stringEventStart01.append("日")
            self.eventDay01Btn.setTitle(stringEventStart01, for: .normal)
        }

        if(appDelegate.event02MonthCd == 0 || appDelegate.event02DayCd == 0){
            //2回目イベント実施日
            self.eventDay02Btn.setTitle("未選択", for: .normal)
        }else{
            var stringEventStart02 = ""
            stringEventStart02.append(String(self.appDelegate.event02YearCd))
            stringEventStart02.append("年")
            stringEventStart02.append(String(self.appDelegate.event02MonthCd))
            stringEventStart02.append("月")
            stringEventStart02.append(String(self.appDelegate.event02DayCd))
            stringEventStart02.append("日")
            self.eventDay02Btn.setTitle(stringEventStart02, for: .normal)
        }

        //1回目イベントの始めたい時間
        /*
        if(self.appDelegate.eventStartTime01FirstFlg == 0){
            //初回のみ実行
            self.eventStartTime01TextField.text = "未選択"
            self.appDelegate.eventStartTime01FirstFlg = 1
            pickerView05.selectRow(33, inComponent: 0, animated: true)
        }else{
            self.eventStartTime01TextField.text = self.eventStartTimeList[self.event01StartTimeCd]
        }*/

        //1回目イベントの始めたい時間
        self.eventStartTime01TextField.text = self.eventStartTimeList[self.event01StartTimeCd]
        //2回目イベントの始めたい時間
        self.eventStartTime02TextField.text = self.eventStartTimeList[self.event02StartTimeCd]
        
        //1回目イベントの枠数
        self.eventSumFrame01TextField.text = self.eventSumFrameList[self.event01SumFrameCd]
        //2回目イベントの枠数
        self.eventSumFrame02TextField.text = self.eventSumFrameList[self.event02SumFrameCd]
        //1回目イベントのインターバル
        self.eventInterval01TextField.text = self.eventIntervalList[self.event01IntervalCd]
        //2回目イベントのインターバル
        self.eventInterval02TextField.text = self.eventIntervalList[self.event02IntervalCd]
        
        if(appDelegate.event01ReserveStartMonthCd == 0 || appDelegate.event01ReserveStartDayCd == 0){
            //1回目イベント予約開始日
            self.eventReserveStart01Btn.setTitle("未選択", for: .normal)
        }else{
            var stringReserveStart01 = ""
            stringReserveStart01.append(String(self.event01ReserveStartYearCd))
            stringReserveStart01.append("年")
            stringReserveStart01.append(String(self.event01ReserveStartMonthCd))
            stringReserveStart01.append("月")
            stringReserveStart01.append(String(self.event01ReserveStartDayCd))
            stringReserveStart01.append("日")
            stringReserveStart01.append(String(self.event01ReserveStartHourCd))
            stringReserveStart01.append("時")
            stringReserveStart01.append(String(self.event01ReserveStartMinuteCd))
            stringReserveStart01.append("分")
            self.eventReserveStart01Btn.setTitle(stringReserveStart01, for: .normal)
        }

        if(appDelegate.event02ReserveStartMonthCd == 0 || appDelegate.event02ReserveStartDayCd == 0){
            //2回目イベント予約開始日
            self.eventReserveStart02Btn.setTitle("未選択", for: .normal)
        }else{
            var stringReserveStart02 = ""
            stringReserveStart02.append(String(self.event02ReserveStartYearCd))
            stringReserveStart02.append("年")
            stringReserveStart02.append(String(self.event02ReserveStartMonthCd))
            stringReserveStart02.append("月")
            stringReserveStart02.append(String(self.event02ReserveStartDayCd))
            stringReserveStart02.append("日")
            stringReserveStart02.append(String(self.event02ReserveStartHourCd))
            stringReserveStart02.append("時")
            stringReserveStart02.append(String(self.event02ReserveStartMinuteCd))
            stringReserveStart02.append("分")
            self.eventReserveStart02Btn.setTitle(stringReserveStart02, for: .normal)
        }

        //self.eventNoteTextView.text = self.appDelegate.eventNote
        //if(self.profileTextView.text == "0" || self.profileTextView.text == "'0'"){
        //    self.profileTextView.text = ""
        //}
        //初期表示ここまで
        
        self.getEventStarPriceList()
        
        // スクロールの高さを変更
        self.mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: 620)
        
        //キーボード対応
        self.configureObserver()
    }

    //BaseViewControllerと同じ
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        UtilFunc.tabBarDo(selected_menu_num: self.selected_menu_num, item: item, myController:self)
    }

    func getEventStarPriceList(){
        //クリアする
        self.eventStarPriceListTemp.removeAll()
        //リスト取得
        var stringUrl = Util.URL_GET_EVENT_PUBCODE_STAR_PRICE_LIST
        stringUrl.append("?status=1")
        
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
                    let json = try decoder.decode(UtilStruct.ResultEventStarPriceJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        let strId = obj.id
                        let strStar = obj.star
                        let strPrice = obj.price
                        let strValue01 = obj.value01
                        let strOrderCd = obj.order_cd
                        let strStatus = obj.status
                        
                        //配列へ追加
                        let eventStarPrice = (strId,strStar,strPrice,strValue01,strOrderCd,strStatus)
                        self.eventStarPriceList.append(eventStarPrice)
                        self.eventStarPriceListTemp.append(eventStarPrice)
                    }
                    
                    dispatchGroup.leave()
                    //self.CollectionView.reloadData()
                    //print(json.result)
                }catch{
                    //エラー処理
                    //print("エラーが出ました")
                    //print(err.debugDescription)
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            //コピーする
            self.eventStarPriceList = self.eventStarPriceListTemp
            //ボタンへの文字列表示
//            self.starPriceRangeBtn.setTitle(self.eventStarPriceList[self.eventStarPriceCd].value01, for: .normal) // ボタンのタイトル
            self.starPriceRangeTextField.text = self.eventStarPriceList[self.eventStarPriceCd].value01

            //先頭を初期値とする
            //self.eventStarPriceCd = 0
            //self.appDelegate.starPriceRangeCd = 0//選択した項目
            //self.appDelegate.starPriceRangeStr = self.eventStarPriceList[0].value01
            //self.appDelegate.eventPrice = Int(self.eventStarPriceList[0].price)!//実際の価格(DBに格納用)
            //self.appDelegate.eventStar = Int(self.eventStarPriceList[0].star)!//実際の獲得スター(DBに格納用)
        }
    }
    
    //ピッカーで確定を押した時
    @objc func action(_ sender: UITextField) {
        self.view.endEditing(true)
    }
    
    /*
    func createDatePicker(){
         // DatePickerModeをDate(日付)に設定
         datePicker.datePickerMode = .date

         // DatePickerを日本語化
         datePicker.locale = NSLocale(localeIdentifier: "ja_JP") as Locale

         // textFieldのinputViewにdatepickerを設定
        //eventStartMonthBtn.inputView = datePicker

         // UIToolbarを設定
         let toolbar = UIToolbar()
         toolbar.sizeToFit()

         // Doneボタンを設定(押下時doneClickedが起動)
         let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClicked))

         // Doneボタンを追加
         toolbar.setItems([doneButton], animated: true)

         // FieldにToolbarを追加
        //eventStartMonthBtn.inputAccessoryView = toolbar
     }

     @objc func doneClicked(){
         let dateFormatter = DateFormatter()

         // 持ってくるデータのフォーマットを設定
         dateFormatter.dateStyle = .medium
         dateFormatter.timeStyle = .none
         dateFormatter.locale    = NSLocale(localeIdentifier: "ja_JP") as Locale
         dateFormatter.dateStyle = DateFormatter.Style.medium

         // textFieldに選択した日付を代入
        //eventStartDateTextField.text = dateFormatter.string(from: datePicker.date
        //eventStartMonthBtn.text = dateFormatter.string(from: datePicker.date)

         // キーボードを閉じる
         self.view.endEditing(true)
     }
    */
    
    func createEvent() {
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //プルダウン以外の値の格納
        self.appDelegate.eventNote = self.eventNoteTextView.text
        
        let post_url = URL(string: Util.URL_ADD_EVENT_BY_USERID)
        var req = URLRequest(url: post_url!)
        
        //1枠のサシライブ時間のマッピング
        //let eventOneFrameTimeList = ["未選択", "10分", "20分", "30分", "40分", "50分", "1時間"]
        //var eventOneFrameTimeCd: Int = 0
        let tempOneFrameTime = eventOneFrameTimeMappingList[self.appDelegate.eventOneFrameTimeCd]
        //1回目イベントの始めたい時間のマッピング
        //let eventStartTimeList = ["未選択", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"]
        let tempEvent01StartHour = eventStartTimeMappingHourList[self.appDelegate.event01StartTimeCd]
        let tempEvent01StartMinute = eventStartTimeMappingMinuteList[self.appDelegate.event01StartTimeCd]
        //2回目イベントの始めたい時間のマッピング
        let tempEvent02StartHour = eventStartTimeMappingHourList[self.appDelegate.event02StartTimeCd]
        let tempEvent02StartMinute = eventStartTimeMappingMinuteList[self.appDelegate.event02StartTimeCd]
        //1回目イベントの実施日
        let tempEvent01YearCd = self.appDelegate.event01YearCd
        let tempEvent01MonthCd = self.appDelegate.event01MonthCd
        let tempEvent01DayCd = self.appDelegate.event01DayCd
        //2回目イベントの実施日
        let tempEvent02YearCd = self.appDelegate.event02YearCd
        let tempEvent02MonthCd = self.appDelegate.event02MonthCd
        let tempEvent02DayCd = self.appDelegate.event02DayCd
        //1回目イベントの枠数
        let tempEvent01SumFrameCd = self.appDelegate.event01SumFrameCd
        //2回目イベントの枠数
        let tempEvent02SumFrameCd = self.appDelegate.event02SumFrameCd
        //1回目イベントのインターバル
        let tempEvent01IntervalCd = eventIntervalMappingList[self.appDelegate.event01IntervalCd]//0:未選択
        //2回目イベントのインターバル
        let tempEvent02IntervalCd = eventIntervalMappingList[self.appDelegate.event02IntervalCd]//0:未選択
        // 1回目イベントの予約開始日
        let tempEvent01ReserveStartYearCd = self.appDelegate.event01ReserveStartYearCd
        let tempEvent01ReserveStartMonthCd = self.appDelegate.event01ReserveStartMonthCd
        let tempEvent01ReserveStartDayCd = self.appDelegate.event01ReserveStartDayCd
        let tempEvent01ReserveStartHourCd = self.appDelegate.event01ReserveStartHourCd
        let tempEvent01ReserveStartMinuteCd = self.appDelegate.event01ReserveStartMinuteCd
        // 2回目イベントの予約開始日
        let tempEvent02ReserveStartYearCd = self.appDelegate.event02ReserveStartYearCd
        let tempEvent02ReserveStartMonthCd = self.appDelegate.event02ReserveStartMonthCd
        let tempEvent02ReserveStartDayCd = self.appDelegate.event02ReserveStartDayCd
        let tempEvent02ReserveStartHourCd = self.appDelegate.event02ReserveStartHourCd
        let tempEvent02ReserveStartMinuteCd = self.appDelegate.event02ReserveStartMinuteCd
        
        //イベントの作成
        var stringUrl = "event_type="
        stringUrl.append("1")
        stringUrl.append("&user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&event_title=")
        stringUrl.append("イベントのタイトル")
        stringUrl.append("&event_note=")
        stringUrl.append(self.appDelegate.eventNote)
        stringUrl.append("&event01_start_hour=")
        stringUrl.append(tempEvent01StartHour)
        stringUrl.append("&event01_start_minute=")
        stringUrl.append(tempEvent01StartMinute)
        stringUrl.append("&event02_start_hour=")
        stringUrl.append(tempEvent02StartHour)
        stringUrl.append("&event02_start_minute=")
        stringUrl.append(tempEvent02StartMinute)
        stringUrl.append("&event01_year=")
        stringUrl.append(String(tempEvent01YearCd))//1回目イベントの実施日
        stringUrl.append("&event01_month=")
        stringUrl.append(String(tempEvent01MonthCd))//1回目イベントの実施日
        stringUrl.append("&event01_day=")
        stringUrl.append(String(tempEvent01DayCd))//1回目イベントの実施日
        stringUrl.append("&event02_year=")
        stringUrl.append(String(tempEvent02YearCd))//2回目イベントの実施日
        stringUrl.append("&event02_month=")
        stringUrl.append(String(tempEvent02MonthCd))//2回目イベントの実施日
        stringUrl.append("&event02_day=")
        stringUrl.append(String(tempEvent02DayCd))//2回目イベントの実施日
        stringUrl.append("&event01_sum_frame=")
        stringUrl.append(String(tempEvent01SumFrameCd))//1回目イベントの枠数
        stringUrl.append("&event02_sum_frame=")
        stringUrl.append(String(tempEvent02SumFrameCd))//2回目イベントの枠数
        stringUrl.append("&event01_interval=")
        stringUrl.append(String(tempEvent01IntervalCd))//1回目イベントのインターバル
        stringUrl.append("&event02_interval=")
        stringUrl.append(String(tempEvent02IntervalCd))//2回目イベントのインターバル
        stringUrl.append("&event01_reserve_start_year=")
        stringUrl.append(String(tempEvent01ReserveStartYearCd))// 1回目イベントの予約開始日
        stringUrl.append("&event01_reserve_start_month=")
        stringUrl.append(String(tempEvent01ReserveStartMonthCd))// 1回目イベントの予約開始日
        stringUrl.append("&event01_reserve_start_day=")
        stringUrl.append(String(tempEvent01ReserveStartDayCd))// 1回目イベントの予約開始日
        stringUrl.append("&event01_reserve_start_hour=")
        stringUrl.append(String(tempEvent01ReserveStartHourCd))// 1回目イベントの予約開始日
        stringUrl.append("&event01_reserve_start_minute=")
        stringUrl.append(String(tempEvent01ReserveStartMinuteCd))// 1回目イベントの予約開始日
        stringUrl.append("&event02_reserve_start_year=")
        stringUrl.append(String(tempEvent02ReserveStartYearCd))// 2回目イベントの予約開始日
        stringUrl.append("&event02_reserve_start_month=")
        stringUrl.append(String(tempEvent02ReserveStartMonthCd))// 2回目イベントの予約開始日
        stringUrl.append("&event02_reserve_start_day=")
        stringUrl.append(String(tempEvent02ReserveStartDayCd))// 2回目イベントの予約開始日
        stringUrl.append("&event02_reserve_start_hour=")
        stringUrl.append(String(tempEvent02ReserveStartHourCd))// 2回目イベントの予約開始日
        stringUrl.append("&event02_reserve_start_minute=")
        stringUrl.append(String(tempEvent02ReserveStartMinuteCd))// 2回目イベントの予約開始日
        stringUrl.append("&event_oneframe_time=")
        stringUrl.append(tempOneFrameTime)
        stringUrl.append("&star=")
        stringUrl.append(String(self.appDelegate.eventStar))
        stringUrl.append("&price=")
        stringUrl.append(String(self.appDelegate.eventPrice))
        stringUrl.append("&open_status=")
        stringUrl.append("1")
        stringUrl.append("&status=")
        stringUrl.append("3")//保留状態で一旦作成
        
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
            self.temp_id = json_result!.id_temp
            self.appDelegate.createEventId = self.temp_id
            
            //イベント作成の確認ページへ
            UtilToViewController.toCreateEventCheckViewController()
        }
    }

    @IBAction func createEventCheck(_ sender: Any) {
        //イベントを仮作成し、イベント作成の確認ページへ
        var errorFlg = 0//1何らかのエラー
        var stringError = "未選択の項目があります。"

        if(self.appDelegate.eventOneFrameTimeCd == 0){
            //1枠のサシライブ時間
            stringError.append("\n・1枠のサシライブ時間")
            errorFlg = 1
        }
        
        if(self.appDelegate.eventStar == 0 || self.appDelegate.eventPrice == 0){
            //イベント価格設定
            stringError.append("\n・価格の設定")
            errorFlg = 1
        }
        
        //必須チェック
        if(self.appDelegate.event01YearCd == 0
            || self.appDelegate.event01MonthCd == 0
            || self.appDelegate.event01DayCd == 0){
            //1回目イベントの実施日
            stringError.append("\n・イベント日程(1回目)")
            errorFlg = 1
        }
        if(self.appDelegate.event01StartTimeCd == 0){
            //1回目イベントの開始時間
            stringError.append("\n・開始時間(1回目)")
            errorFlg = 1
        }
        if(self.appDelegate.event01SumFrameCd == 0){
            //1回目イベントの合計枠数
            stringError.append("\n・合計枠数(1回目)")
            errorFlg = 1
        }
        if(self.appDelegate.event01IntervalCd == 0){
            //1回目イベントの合計枠数
            stringError.append("\n・枠間の休憩時間(1回目)")
            errorFlg = 1
        }
        if(self.appDelegate.event01ReserveStartYearCd == 0
            || self.appDelegate.event01ReserveStartMonthCd == 0
            || self.appDelegate.event01ReserveStartDayCd == 0){
            //1回目イベントの予約受付の開始日
            stringError.append("\n・予約開始日(1回目)")
            errorFlg = 1
        }
        
        //必須チェック
        if(self.appDelegate.event02YearCd == 0
            || self.appDelegate.event02MonthCd == 0
            || self.appDelegate.event02DayCd == 0){
            /*
            //2回目イベントの実施日が設定されてない場合に、開始時間などが設定されている場合
            if(self.appDelegate.event02StartTimeCd != 0
                || self.appDelegate.event02SumFrameCd != 0
                || self.appDelegate.event02IntervalCd != 0){
                stringError.append("\n・イベント日程(2回目)")
                errorFlg = 1
            }
             */
        }else{
            //2回目イベントの実施日が設定されている場合
            if(self.appDelegate.event02StartTimeCd == 0){
                //2回目イベントの開始時間
                stringError.append("\n・開始時間(2回目)")
                errorFlg = 1
            }
            if(self.appDelegate.event02SumFrameCd == 0){
                //2回目イベントの合計枠数
                stringError.append("\n・合計枠数(2回目)")
                errorFlg = 1
            }
            if(self.appDelegate.event02IntervalCd == 0){
                //2回目イベントの合計枠数
                stringError.append("\n・枠間の休憩時間(2回目)")
                errorFlg = 1
            }
            if(self.appDelegate.event02ReserveStartYearCd == 0
                || self.appDelegate.event02ReserveStartMonthCd == 0
                || self.appDelegate.event02ReserveStartDayCd == 0){
                //2回目イベントの予約受付の開始日
                stringError.append("\n・予約開始日(2回目)")
                errorFlg = 1
            }
        }
        
        if(errorFlg == 0){
            //予約開始日がイベントの実施日の1週間前かのチェック
            //event01Date = Date()//イベントの実施日(予約開始日（1週間前）の計算用)
            //event01ReserveDate = Date()//予約開始日
            var errorDateFlg = 0
            let tempNowDate = Date()//現在
            
            let event01DateBeforeWeek = Calendar.current.date(byAdding: .day, value: -7, to: self.event01Date)!//1週間前
            if(event01DateBeforeWeek >= self.event01ReserveDate){
                //OK
                if(tempNowDate >= self.event01ReserveDate){
                    //予約開始日に過去日が設定されている
                    errorDateFlg = 2//NG
                }
            }else{
                errorDateFlg = 1//NG
            }
            
            //イベント2回目
            if(self.appDelegate.event02YearCd == 0
                || self.appDelegate.event02MonthCd == 0
                || self.appDelegate.event02DayCd == 0){
                //設定されていない場合は何もしない
            }else{
                let event02DateBeforeWeek = Calendar.current.date(byAdding: .day, value: -7, to: self.event02Date)!//1週間前
                if(event02DateBeforeWeek >= self.event02ReserveDate){
                    //OK
                    if(tempNowDate >= self.event02ReserveDate){
                        //予約開始日に過去日が設定されている
                        errorDateFlg = 2//NG
                    }
                }else{
                    errorDateFlg = 1//NG
                }
            }

            if(errorDateFlg == 0){
                //１回目と２回目のイベント日の整合性チェック（日程が逆転していないか）
                if(self.event01Date < self.event02Date
                    || self.appDelegate.event02YearCd == 0
                    || self.appDelegate.event02MonthCd == 0
                    || self.appDelegate.event02DayCd == 0){
                    //OK
                    //イベント作成へ
                    self.createEvent()
                }else{
                    //NG
                    //アラート表示
                    let alert = UIAlertController(title: "", message: "2回目のイベント日を修正してください。1回目のイベント日より後の日程を設定する必要があります。", preferredStyle: .alert)
                    //ここから追加
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        //マイページへ
                        //UtilToViewController.toMypageViewController()
                    }
                    alert.addAction(ok)
                    //ここまで追加
                    self.present(alert, animated: true, completion: nil)
                }
                
            }else if(errorDateFlg == 1){
                //エラーメッセージ
                //アラート表示
                let alert = UIAlertController(title: "", message: "予約開始日の設定を修正してください。予約開始日は最低1週間以上空ける必要があります。", preferredStyle: .alert)
                //ここから追加
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    //マイページへ
                    //UtilToViewController.toMypageViewController()
                }
                alert.addAction(ok)
                //ここまで追加
                self.present(alert, animated: true, completion: nil)
                
            }else if(errorDateFlg == 2){
                //エラーメッセージ
                //アラート表示
                let alert = UIAlertController(title: "", message: "予約開始日の設定を修正してください。現在以降を指定する必要があります。", preferredStyle: .alert)
                //ここから追加
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    //マイページへ
                    //UtilToViewController.toMypageViewController()
                }
                alert.addAction(ok)
                //ここまで追加
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            UtilFunc.showAlert(message:stringError, vc:self, sec:3.0)
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
    
    //イベント実施日(1回目)
    @IBAction func tapEventDay01Btn(_ sender: Any) {
        self.eventStartDatePicker.minimumDate = Date()//過去は選択できないようにする
        self.eventStartDatePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 365, to: Date())!//1年後
        self.eventStartDatePicker.datePickerMode = .date
        self.eventStartDatePicker.tag = 3
        self.eventDateCompBtn.tag = 3
        self.eventDateSelectView.isHidden = false
        self.view.bringSubviewToFront(self.eventDateSelectView)
        
        if(self.event01YearCd == 0 || self.event01MonthCd == 0 || self.event01DayCd == 0){
            //初回選択時
            self.eventStartDatePicker.date = Date()
        }else{
            self.eventStartDatePicker.date = self.event01Date
        }
    }

    //イベント実施日(2回目)
    @IBAction func tapEventDay02Btn(_ sender: Any) {
        self.eventStartDatePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: self.event01Date)!//1回目の日付+１が最小
        self.eventStartDatePicker.maximumDate = Calendar.current.date(byAdding: .day, value: 365, to: self.event01Date)!//1年後
        self.eventStartDatePicker.datePickerMode = .date
        self.eventStartDatePicker.tag = 4
        self.eventDateCompBtn.tag = 4
        self.eventDateSelectView.isHidden = false
        self.view.bringSubviewToFront(self.eventDateSelectView)
        
        if(self.event02YearCd == 0 || self.event02MonthCd == 0 || self.event02DayCd == 0){
            //初回選択時
            self.eventStartDatePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: self.event01Date)!//1回目の日付+１
        }else{
            self.eventStartDatePicker.date = self.event02Date
        }
    }
    
    /**************************************************************/
    /**************************************************************/
    /**************************************************************/
    //予約開始日(1回目)
    @IBAction func tapEventReserveStart01Btn(_ sender: Any) {
        self.eventStartDatePicker.minimumDate = Date()//過去は選択できないようにする
        //let modifiedDate = Calendar.current.date(byAdding: .day, value: -7, to: self.event01Date)!//1週間前
        
        if(self.event01YearCd == 0 || self.event01MonthCd == 0 || self.event01DayCd == 0){
            //Maxは指定しない
        }else{
            self.eventStartDatePicker.maximumDate = Calendar.current.date(byAdding: .day, value: -7, to: self.event01Date)!//1週間前
        }
        
        self.eventStartDatePicker.datePickerMode = .dateAndTime
        self.eventStartDatePicker.minuteInterval = 30
        self.eventStartDatePicker.tag = 8
        self.eventDateCompBtn.tag = 8
        self.eventDateSelectView.isHidden = false
        self.view.bringSubviewToFront(self.eventDateSelectView)
        
        if(self.event01ReserveStartYearCd == 0 || self.event01ReserveStartMonthCd == 0 || self.event01ReserveStartDayCd == 0){
            //初回選択時
            self.eventStartDatePicker.date = Date()
        }else{
            self.eventStartDatePicker.date = self.event01ReserveDate
        }
        
        /*
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        // プロトコルの設定
        picker.delegate = self
        picker.dataSource = self
        
        // はじめに表示する項目を指定
        picker.selectRow(self.eventReserveStartMonthCd, inComponent: 0, animated: true)
        picker.tag = 11;

        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        //nextBtn.isEnabled = false
        //saveInfoBtn.isEnabled = false
         */
    }

    //予約開始日(2回目)
    @IBAction func tapEventReserveStart02Btn(_ sender: Any) {
        self.eventStartDatePicker.minimumDate = Date()//過去は選択できないようにする
        
        if(self.event02YearCd == 0 || self.event02MonthCd == 0 || self.event02DayCd == 0){
            //Maxは指定しない
        }else{
            self.eventStartDatePicker.maximumDate = Calendar.current.date(byAdding: .day, value: -7, to: self.event02Date)!//1週間前
        }
        
        self.eventStartDatePicker.datePickerMode = .dateAndTime
        self.eventStartDatePicker.minuteInterval = 30
        self.eventStartDatePicker.tag = 12
        self.eventDateCompBtn.tag = 12
        self.eventDateSelectView.isHidden = false
        self.view.bringSubviewToFront(self.eventDateSelectView)
        
        if(self.event02ReserveStartYearCd == 0 || self.event02ReserveStartMonthCd == 0 || self.event02ReserveStartDayCd == 0){
            //初回選択時
            self.eventStartDatePicker.date = Date()
        }else{
            self.eventStartDatePicker.date = self.event02ReserveDate
        }
        
        /*
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        // プロトコルの設定
        picker.delegate = self
        picker.dataSource = self
        
        // はじめに表示する項目を指定
        picker.selectRow(self.eventReserveStartMonthCd, inComponent: 0, animated: true)
        picker.tag = 11;

        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        //nextBtn.isEnabled = false
        //saveInfoBtn.isEnabled = false
         */
    }
    /**************************************************************/
    /**************************************************************/
    /**************************************************************/
    
    @IBAction func tapEventDateCompBtn(_ sender: Any) {
        //日付ピッカーから「日付選択」ボタンを押した時に呼ばれる
        
        //日付の取得
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let tempYear = "\(formatter.string(from: self.eventStartDatePicker.date))"
        formatter.dateFormat = "M"
        let tempMonth = "\(formatter.string(from: self.eventStartDatePicker.date))"
        formatter.dateFormat = "d"
        let tempDay = "\(formatter.string(from: self.eventStartDatePicker.date))"
        formatter.dateFormat = "H"
        let tempHour = "\(formatter.string(from: self.eventStartDatePicker.date))"
        formatter.dateFormat = "mm"
        var tempMinute = "\(formatter.string(from: self.eventStartDatePicker.date))"
        //現在の分数が0 or 30以外の場合の調整
        if(Int(tempMinute)! >= 0 && Int(tempMinute)! < 30){
            tempMinute = "00"
        }else{
            tempMinute = "30"
        }
        
        let selectDate = self.eventStartDatePicker.date//選択した日付
        
        //"yyyy年MM月dd日"を"yyyy/MM/dd"したりして出力の仕方を好きに変更できる
        //formatter.dateFormat = "yyyy年MM月dd日"
        //(from: datePicker.date))を指定してあげることで
        //datePickerで指定した日付が表示される
        //dateField.text = "\(formatter.string(from: datePicker.date))"
        //"\(self.eventStartDatePicker.date)"

        if(self.eventStartDatePicker.tag == 3){
            //イベント実施日(1回目)
            //●1回目 00月00日のイベント開始時間
            //self.eventDay01Lbl.text = "●イベント1回目 " + tempMonth + "月" + tempDay + "日の開始時間"
            self.eventDay01Lbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-5 ,string: tempMonth + "月" + tempDay + "日のイベント設定", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//1回目のイベント開始ラベル
            self.eventDay01Btn.setTitle(tempYear + "年" + tempMonth + "月" + tempDay + "日", for: .normal)
            
            //値の保存
            self.event01YearCd = Int(tempYear)!
            self.appDelegate.event01YearCd = Int(tempYear)!
            
            self.event01MonthCd = Int(tempMonth)!
            self.appDelegate.event01MonthCd = Int(tempMonth)!
            
            self.event01DayCd = Int(tempDay)!
            self.appDelegate.event01DayCd = Int(tempDay)!

            self.event01Date = selectDate
            
        }else if(self.eventStartDatePicker.tag == 4){
            //イベント実施日(2回目)
            //●2回目 00月00日のイベント開始時間
            //self.eventDay02Lbl.text = "●イベント2回目 " + tempMonth + "月" + tempDay + "日の開始時間"
            self.eventDay02Lbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-5 ,string: tempMonth + "月" + tempDay + "日のイベント設定", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//2回目のイベント開始ラベル
            self.eventDay02Btn.setTitle(tempYear + "年" + tempMonth + "月" + tempDay + "日", for: .normal)
            
            //●2回目 00月00日の予約開始日
            //self.eventReserveStart02Lbl.text = "●イベント2回目 " + tempMonth + "月" + tempDay + "日の予約開始日"
            
            //値の保存
            self.event02YearCd = Int(tempYear)!
            self.appDelegate.event02YearCd = Int(tempYear)!
            
            self.event02MonthCd = Int(tempMonth)!
            self.appDelegate.event02MonthCd = Int(tempMonth)!
            
            self.event02DayCd = Int(tempDay)!
            self.appDelegate.event02DayCd = Int(tempDay)!
            
            self.event02Date = selectDate
            
        }else if(self.eventStartDatePicker.tag == 8){
            //予約開始日(1回目)
            //現在の分数が0 or 30以外の場合の調整
            /*
            var tempMinuteSelect = "00"
            if(Int(tempMinute)! >= 0 && Int(tempMinute)! < 30){
                tempMinuteSelect = "00"
            }else{
                tempMinuteSelect = "30"
            }*/
            self.eventReserveStart01Btn.setTitle(tempYear + "年" + tempMonth + "月" + tempDay + "日" + tempHour + "時" + tempMinute + "分", for: .normal)
            
            //値の保存
            self.event01ReserveStartYearCd = Int(tempYear)!
            self.appDelegate.event01ReserveStartYearCd = Int(tempYear)!
            
            self.event01ReserveStartMonthCd = Int(tempMonth)!
            self.appDelegate.event01ReserveStartMonthCd = Int(tempMonth)!
            
            self.event01ReserveStartDayCd = Int(tempDay)!
            self.appDelegate.event01ReserveStartDayCd = Int(tempDay)!
            
            self.event01ReserveStartHourCd = Int(tempHour)!
            self.appDelegate.event01ReserveStartHourCd = Int(tempHour)!
            
            self.event01ReserveStartMinuteCd = Int(tempMinute)!
            self.appDelegate.event01ReserveStartMinuteCd = Int(tempMinute)!
            
            self.event01ReserveDate = selectDate
            
        }else if(self.eventStartDatePicker.tag == 12){
            //予約開始日(2回目)
            //現在の分数が0 or 30以外の場合の調整
            /*
            var tempMinuteSelect = "00"
            if(Int(tempMinute)! >= 0 && Int(tempMinute)! < 30){
                tempMinuteSelect = "00"
            }else{
                tempMinuteSelect = "30"
            }*/
            self.eventReserveStart02Btn.setTitle(tempYear + "年" + tempMonth + "月" + tempDay + "日" + tempHour + "時" + tempMinute + "分", for: .normal)
            
            //値の保存
            self.event02ReserveStartYearCd = Int(tempYear)!
            self.appDelegate.event02ReserveStartYearCd = Int(tempYear)!
            
            self.event02ReserveStartMonthCd = Int(tempMonth)!
            self.appDelegate.event02ReserveStartMonthCd = Int(tempMonth)!
            
            self.event02ReserveStartDayCd = Int(tempDay)!
            self.appDelegate.event02ReserveStartDayCd = Int(tempDay)!
            
            self.event02ReserveStartHourCd = Int(tempHour)!
            self.appDelegate.event02ReserveStartHourCd = Int(tempHour)!

            self.event02ReserveStartMinuteCd = Int(tempMinute)!
            self.appDelegate.event02ReserveStartMinuteCd = Int(tempMinute)!
            
            self.event02ReserveDate = selectDate
        }
        
        self.eventDateSelectView.isHidden = true
    }
    
    @IBAction func tapEventDateClearBtn(_ sender: Any) {
        //日付ピッカーから「日付クリア」ボタンを押した時に呼ばれる
        if(self.eventStartDatePicker.tag == 3){
            //イベント実施日(1回目)
            //●1回目 00月00日のイベント開始時間
            //self.eventDay01Lbl.text = "●イベント1回目 " + tempMonth + "月" + tempDay + "日の開始時間"
            self.eventDay01Lbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-5 ,string: "1回目のイベント設定", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//1回目のイベント開始ラベル
            self.eventDay01Btn.setTitle("未選択", for: .normal)
            
            //値の保存
            self.event01YearCd = 0
            self.appDelegate.event01YearCd = 0
            
            self.event01MonthCd = 0
            self.appDelegate.event01MonthCd = 0
            
            self.event01DayCd = 0
            self.appDelegate.event01DayCd = 0
            
            self.event01Date = Date()//イベントの実施日(予約開始日（1週間前）の計算用)

        }else if(self.eventStartDatePicker.tag == 4){
            //イベント実施日(2回目)
            //●2回目 00月00日のイベント開始時間
            //self.eventDay02Lbl.text = "●イベント2回目 " + tempMonth + "月" + tempDay + "日の開始時間"
            self.eventDay02Lbl.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-5 ,string: "2回目のイベント設定（任意）", iconImage: UIImage(named:"arrow_circle_left_ico")!, iconSize: self.iconSize)//2回目のイベント開始ラベル
            self.eventDay02Btn.setTitle("未選択", for: .normal)
            
            //値の保存
            self.event02YearCd = 0
            self.appDelegate.event02YearCd = 0
            
            self.event02MonthCd = 0
            self.appDelegate.event02MonthCd = 0
            
            self.event02DayCd = 0
            self.appDelegate.event02DayCd = 0

            self.event02Date = Date()//イベントの実施日(予約開始日（1週間前）の計算用)
            
        }else if(self.eventStartDatePicker.tag == 8){
            //予約開始日(1回目)
            self.eventReserveStart01Btn.setTitle("未選択", for: .normal)
            
            //値の保存
            self.event01ReserveStartYearCd = 0
            self.appDelegate.event01ReserveStartYearCd = 0
            
            self.event01ReserveStartMonthCd = 0
            self.appDelegate.event01ReserveStartMonthCd = 0
            
            self.event01ReserveStartDayCd = 0
            self.appDelegate.event01ReserveStartDayCd = 0
            
            self.event01ReserveStartHourCd = 0
            self.appDelegate.event01ReserveStartHourCd = 0
            
            self.event01ReserveStartMinuteCd = 0
            self.appDelegate.event01ReserveStartMinuteCd = 0
            
            self.event01ReserveDate = Date()//予約開始日
            
        }else if(self.eventStartDatePicker.tag == 12){
            //予約開始日(2回目)
            self.eventReserveStart02Btn.setTitle("未選択", for: .normal)
            
            //値の保存
            self.event02ReserveStartYearCd = 0
            self.appDelegate.event02ReserveStartYearCd = 0
            
            self.event02ReserveStartMonthCd = 0
            self.appDelegate.event02ReserveStartMonthCd = 0
            
            self.event02ReserveStartDayCd = 0
            self.appDelegate.event02ReserveStartDayCd = 0
            
            self.event02ReserveStartHourCd = 0
            self.appDelegate.event02ReserveStartHourCd = 0

            self.event02ReserveStartMinuteCd = 0
            self.appDelegate.event02ReserveStartMinuteCd = 0
            
            self.event02ReserveDate = Date()//予約開始日
        }
        
        self.eventDateSelectView.isHidden = true
    }
    
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 表示する列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // アイテム表示個数を返す
        var itemCount = 0;
        
        if(pickerView.tag == 1){
            //１枠のサシライブ時間
            itemCount = eventOneFrameTimeList.count;
        }else if(pickerView.tag == 2){
            //獲得スターと価格の設定
            itemCount = eventStarPriceList.count;
        //}else if(pickerView.tag == 3){
        //    itemCount = eventStartMonthList.count;
        //}else if(pickerView.tag == 4){
        //    itemCount = eventStartDayList.count;
        }else if(pickerView.tag == 5){
            //始めたい時間(1回目)
            itemCount = eventStartTimeList.count;
        }else if(pickerView.tag == 6){
            //イベント合計枠数(1回目)
            itemCount = eventSumFrameList.count;
        }else if(pickerView.tag == 7){
            //インターバル(1回目)
            itemCount = eventIntervalList.count;
        //}else if(pickerView.tag == 8){
        //    itemCount = eventSumTimeList.count;
        }else if(pickerView.tag == 9){
            //始めたい時間(2回目)
            itemCount = eventStartTimeList.count;
        }else if(pickerView.tag == 10){
            //イベント合計枠数(2回目)
            itemCount = eventSumFrameList.count;
        }else if(pickerView.tag == 11){
            //インターバル(2回目)
            itemCount = eventIntervalList.count;
        //}else if(pickerView.tag == 12){
        //    itemCount = eventReserveStartDayList.count;
        }
        
        return itemCount
    }
    
    // UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        var returnStr = "";
        
        if(pickerView.tag == 1){
            //１枠のサシライブ時間
            returnStr = eventOneFrameTimeList[row];
        }else if(pickerView.tag == 2){
            //獲得スターと価格の設定
            returnStr = eventStarPriceList[row].value01;
        }else if(pickerView.tag == 5){
            //始めたい時間(1回目)
            returnStr = eventStartTimeList[row];
        }else if(pickerView.tag == 6){
            //イベント合計枠数(1回目)
            returnStr = eventSumFrameList[row];
        }else if(pickerView.tag == 7){
            //インターバル(1回目)
            returnStr = eventIntervalList[row];
        //}else if(pickerView.tag == 8){
        //    returnStr = eventSumTimeList[row];
        }else if(pickerView.tag == 9){
            //始めたい時間(2回目)
            returnStr = eventStartTimeList[row];
        }else if(pickerView.tag == 10){
            //イベント合計枠数(2回目)
            returnStr = eventSumFrameList[row];
        }else if(pickerView.tag == 11){
            //インターバル(2回目)
            returnStr = eventIntervalList[row];
        //}else if(pickerView.tag == 12){
        //    returnStr = eventReserveStartDayList[row];
        }
        
        return returnStr
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        /*
        //テキストフィールドを無効に
        self.eventOneFrameTimeTextField.isEnabled = false
        self.starPriceRangeTextField.isEnabled = false
        self.eventStartTime01TextField.isEnabled = false//1回目の開始時間
        self.eventStartTime02TextField.isEnabled = false//2回目の開始時間
        self.eventSumFrame01TextField.isEnabled = false//1回目の合計枠数
        self.eventSumFrame02TextField.isEnabled = false//2回目の合計枠数
        self.eventInterval01TextField.isEnabled = false//1回目のインターバル1-10分を指定
        self.eventInterval02TextField.isEnabled = false//2回目のインターバル1-10分を指定
        //以下はボタンを無効に
        self.eventDay01Btn.isEnabled = false//1回目のイベント実施日ボタン
        self.eventDay02Btn.isEnabled = false//2回目のイベント実施日ボタン
        self.eventReserveStart01Btn.isEnabled = false//1回目の予約開始日ボタン
        self.eventReserveStart02Btn.isEnabled = false//2回目の予約開始日ボタン
        */
        //選択肢の長い場合の処理
        // 表示する文字列を返す
        var returnStr = "";
        
        if(pickerView.tag == 1){
            //１枠のサシライブ時間
            returnStr = eventOneFrameTimeList[row];
        }else if(pickerView.tag == 2){
            //獲得スターと価格の設定
            returnStr = eventStarPriceList[row].value01;
        }else if(pickerView.tag == 5){
            //始めたい時間(1回目)
            returnStr = eventStartTimeList[row];
        }else if(pickerView.tag == 6){
            //イベント合計枠数(1回目)
            returnStr = eventSumFrameList[row];
        }else if(pickerView.tag == 7){
            //インターバル(1回目)
            returnStr = eventIntervalList[row];
        //}else if(pickerView.tag == 8){
        //    returnStr = eventSumTimeList[row];
        }else if(pickerView.tag == 9){
            //始めたい時間(2回目)
            returnStr = eventStartTimeList[row];
        }else if(pickerView.tag == 10){
            //イベント合計枠数(2回目)
            returnStr = eventSumFrameList[row];
        }else if(pickerView.tag == 11){
            //インターバル(2回目)
            returnStr = eventIntervalList[row];
        //}else if(pickerView.tag == 12){
        //    returnStr = eventReserveStartDayList[row];
        }
        
        let label = (view as? UILabel) ?? UILabel()
        label.text = returnStr
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }
 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        //画面上のボタンを有効にする
        //nextBtn.isEnabled = true
        //saveInfoBtn.isEnabled = true
        //print(priceRangeList[row])
        /*
        //テキストフィールドを有効に
        self.eventOneFrameTimeTextField.isEnabled = true
        self.starPriceRangeTextField.isEnabled = true
        self.eventStartTime01TextField.isEnabled = true//1回目の開始時間
        self.eventStartTime02TextField.isEnabled = true//2回目の開始時間
        self.eventSumFrame01TextField.isEnabled = true//1回目の合計枠数
        self.eventSumFrame02TextField.isEnabled = true//2回目の合計枠数
        self.eventInterval01TextField.isEnabled = true//1回目のインターバル1-10分を指定
        self.eventInterval02TextField.isEnabled = true//2回目のインターバル1-10分を指定
        //以下はボタンを有効に
        self.eventDay01Btn.isEnabled = true//1回目のイベント実施日ボタン
        self.eventDay02Btn.isEnabled = true//2回目のイベント実施日ボタン
        self.eventReserveStart01Btn.isEnabled = true//1回目の予約開始日ボタン
        self.eventReserveStart02Btn.isEnabled = true//2回目の予約開始日ボタン
        */
        if(pickerView.tag == 1){
            //self.eventOneFrameTimeBtn.setTitle(eventOneFrameTimeList[row], for: .normal)
            self.eventOneFrameTimeTextField.text = eventOneFrameTimeList[row]
            self.eventOneFrameTimeCd = row
            self.appDelegate.eventOneFrameTimeCd = row
        }else if(pickerView.tag == 2){
            //self.starPriceRangeBtn.setTitle(eventStarPriceList[row].value01, for: .normal)
            self.starPriceRangeTextField.text = eventStarPriceList[row].value01
            self.eventStarPriceCd = row
            self.appDelegate.starPriceRangeCd = row//選択した項目
            //self.appDelegate.starPriceRangeStr = eventStarPriceList[row].value01
            self.appDelegate.eventPrice = Int(eventStarPriceList[row].price)!//実際の価格(DBに格納用)
            self.appDelegate.eventStar = Int(eventStarPriceList[row].star)!//実際の獲得スター(DBに格納用)
//        }else if(pickerView.tag == 3){
//            self.eventStartMonthBtn.setTitle(eventStartMonthList[row], for: .normal)
//            self.eventStartMonthCd = row
//            self.appDelegate.eventStartMonthCd = row
//        }else if(pickerView.tag == 4){
//            self.eventStartDayBtn.setTitle(eventStartDayList[row], for: .normal)
//            self.eventStartDayCd = row
//            self.appDelegate.eventStartDayCd = row
//
//            pickerView.selectRow(self.appDelegate.eventStartDayCd, inComponent: 0, animated: true)

        }else if(pickerView.tag == 5){
            //選択している項目の設定
            pickerView.selectRow(row, inComponent: 0, animated: true)
            //pickerView.removeFromSuperview()
            //始めたい時間(1回目)
            //self.eventStartTime01Btn.setTitle(eventStartTimeList[row], for: .normal)
            self.eventStartTime01TextField.text = eventStartTimeList[row]
            self.event01StartTimeCd = row
            self.appDelegate.event01StartTimeCd = row
        }else if(pickerView.tag == 6){
            //選択している項目の設定
            pickerView.selectRow(row, inComponent: 0, animated: true)
            //pickerView.removeFromSuperview()
            //イベント合計枠数(1回目)
            //self.eventSumFrame01Btn.setTitle(eventSumFrameList[row], for: .normal)
            self.eventSumFrame01TextField.text = eventSumFrameList[row]
            self.event01SumFrameCd = row
            self.appDelegate.event01SumFrameCd = row
        }else if(pickerView.tag == 7){
            //選択している項目の設定
            pickerView.selectRow(row, inComponent: 0, animated: true)
            //pickerView.removeFromSuperview()
            //インターバル(1回目)
            //self.eventInterval01Btn.setTitle(eventIntervalList[row], for: .normal)
            self.eventInterval01TextField.text = eventIntervalList[row]
            self.event01IntervalCd = row
            self.appDelegate.event01IntervalCd = row
        //}else if(pickerView.tag == 8){
        //    self.eventSumTimeBtn.setTitle(eventSumTimeList[row], for: .normal)
        //    self.eventSumTimeCd = row
        //    self.appDelegate.eventSumTimeCd = row
        }else if(pickerView.tag == 9){
            //選択している項目の設定
            pickerView.selectRow(row, inComponent: 0, animated: true)
            //pickerView.removeFromSuperview()
            //始めたい時間(2回目)
            //self.eventStartTime02Btn.setTitle(eventStartTimeList[row], for: .normal)
            self.eventStartTime02TextField.text = eventStartTimeList[row]
            self.event02StartTimeCd = row
            self.appDelegate.event02StartTimeCd = row
        }else if(pickerView.tag == 10){
            //選択している項目の設定
            pickerView.selectRow(row, inComponent: 0, animated: true)
            //pickerView.removeFromSuperview()
            //イベント合計枠数(2回目)
            //self.eventSumFrame02Btn.setTitle(eventSumFrameList[row], for: .normal)
            self.eventSumFrame02TextField.text = eventSumFrameList[row]
            self.event02SumFrameCd = row
            self.appDelegate.event02SumFrameCd = row
        }else if(pickerView.tag == 11){
            //選択している項目の設定
            pickerView.selectRow(row, inComponent: 0, animated: true)
            //pickerView.removeFromSuperview()
            //インターバル(2回目)
            //self.eventInterval02Btn.setTitle(eventIntervalList[row], for: .normal)
            self.eventInterval02TextField.text = eventIntervalList[row]
            self.event02IntervalCd = row
            self.appDelegate.event02IntervalCd = row
//        }else if(pickerView.tag == 12){
//            self.eventReserveStartDayBtn.setTitle(eventReserveStartDayList[row], for: .normal)
//            self.eventReserveStartDayCd = row
//            self.appDelegate.eventReserveStartDayCd = row
        }
    }
    
    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//キーボードが隠れてしまう問題の対応
extension CreateEventViewController: UITextFieldDelegate {
    
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
        }
//        if(self.keyboardFlg == 0){
//            let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
//            let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
//            UIView.animate(withDuration: duration!, animations: { () in
//                let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)!)
//                self.view.transform = transform
                
//            })
            
            //self.priceRangeBtn.isEnabled = false
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
//        }
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        
        // スクロールの高さを変更
        self.mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: 620)
        coverView.isHidden = true
        
//        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
//        UIView.animate(withDuration: duration!, animations: { () in
            
//            self.view.transform = CGAffineTransform.identity
//        })
        
        //self.priceRangeBtn.isEnabled = true
        //coverView.isHidden = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
        
        return true
    }
    
    // became first responder
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.keyboardFlg = 0
        //名前のところ
        //@IBOutlet weak var nameTextField: KeyBoard!
        //HPのところ
        //@IBOutlet weak var hpTextField: KeyBoard!
        //プロフィールのところ
        //@IBOutlet weak var profileTextView: PlaceHolderTextView!
        /*
        if(textField.tag == 1 || textField.tag == 2 || textField.tag == 3){
            self.keyboardFlg = 1//キーボードを表示する場合に上にずらさない
        }else{
            self.keyboardFlg = 0
        }*/
    }
}

/*
//スクロールバーを常に表示
//https://qiita.com/MilanistaDev/items/8151dd2544b2eda9353b
extension CreateEventViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロールバーに画像をセット
        if let verticalScrollIndicator: UIView = scrollView.subviews.last {
            // 追加した画像があれば削除
            let subviews = verticalScrollIndicator.subviews
            for subview in subviews {
                subview.removeFromSuperview()
            }
            let scrollBarImageView = UIImageView.init(frame: .zero)
            scrollBarImageView.contentMode = .scaleToFill
            scrollBarImageView.image = UIImage(named: "scrollbar_image")
            scrollBarImageView.translatesAutoresizingMaskIntoConstraints = false
            verticalScrollIndicator.addSubview(scrollBarImageView)
            // ScrollBar いっぱいに画像を設置
            scrollBarImageView.leadingAnchor.constraint(
                equalTo: verticalScrollIndicator.leadingAnchor,
                constant: 0.0
                ).isActive = true
            scrollBarImageView.bottomAnchor.constraint(
                equalTo: verticalScrollIndicator.bottomAnchor,
                constant: 0.0
                ).isActive = true
            scrollBarImageView.trailingAnchor.constraint(
                equalTo: verticalScrollIndicator.trailingAnchor,
                constant: 0.0
                ).isActive = true
            scrollBarImageView.topAnchor.constraint(
                equalTo: verticalScrollIndicator.topAnchor,
                constant: 0.0
            ).isActive = true
        }
    }
}
*/
