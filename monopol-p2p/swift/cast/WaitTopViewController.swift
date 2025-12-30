//
//  WaitTopViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/05/07.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import XLPagerTabStrip

class WaitTopViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, IndicatorInfoProvider {

    let iconSize: CGFloat = 20.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ここがボタンのタイトルに利用されます
    var itemInfo: IndicatorInfo = "サシライブ準備"
    
    //自分のuser_idを指定
    var user_id:Int = 0
    
    // データベースへの参照
    var rootRef = Database.database().reference()
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    // プルダウン選択肢(最大待機時間)
    //例：10分を選択した場合は、５分経過時までライブ開始が可能(ひと枠分のライブ配信が可能)。
    //それ以降は待機が解除される。
    //let waitTimeList = ["60分", "30分", "10分"]
    //let waitTimeData = ["60", "30", "10"]//次の画面に渡す用
    //var waitTimeCd: Int = 0
    let reserveFlgList = ["予約を許可する", "予約を許可しない"]
    let maxReserveCountList = ["5","10","20","30","40","50","75","100","120","140","160","180","200","300","無制限"]
    //var reserveFlgCd: Int = 0//1:予約できない
    
    // プルダウン選択肢(枠の延長リクエスト)
    //let frameRequestList = ["リクエスト時に毎回確認", "常に許可(確認不要)", "枠の延長リクエストを受け付けない"]
    //var frameRequestCd: Int = 0
    
    var passwordTextFieldFlg: Int = 0//パスワード不要
    
    //let selectFrameNumList = [1, 2, 3, 4, 5]
    @IBOutlet weak var reserveFlgLbl: UILabel!
    @IBOutlet weak var maxReserveCountLbl: UILabel!
    @IBOutlet weak var passwordLiveLbl: UILabel!
    @IBOutlet weak var reserveFlgBtn: UIButton!
    
    @IBOutlet weak var maxReserveCountBtn: UIButton!
    @IBOutlet weak var passwordLiveBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var detailLabel: UILabel!//ライブについての説明のところ
    @IBOutlet weak var aboutLabel: UILabel!//サシライブについてのタイトルのところ
    @IBOutlet weak var aboutView: UIView!
    
//    @IBOutlet weak var aboutEventLabel: UILabel!
//    @IBOutlet weak var aboutEventView: UIView!
    
    //ライブ配信待機！のボタン
    @IBOutlet weak var waitBtn: UIButton!
    //ライブ配信待機！のボタン(画像ボタン)
    //@IBOutlet weak var waitTempBtn: UIButton!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    //イベント作成ボタン
    //@IBOutlet weak var createEventBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.user_id = UserDefaults.standard.integer(forKey: "user_id")
        
        //先頭にアイコン画像をつけたい文字列とアイコン画像を引数で渡します
        self.aboutLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-5 ,string: "サシライブについて", iconImage: UIImage(named:"cast_list_onlive")!, iconSize: self.iconSize)
        self.aboutLabel.textColor = Util.LIVE_WAIT_ABOUT_TITLE_COLOR
        //説明文を設定
        self.detailLabel.text = UtilStr.WAIT_TOP_DETAIL_STR
        //ラベルの枠を自動調節する
        self.detailLabel.adjustsFontSizeToFitWidth = true
        self.detailLabel.minimumScaleFactor = 0.3
        
//        self.aboutEventLabel.attributedText = UtilFunc.getInsertIconStringTitle(y_height:-5 ,string: "上級者向け", iconImage: UIImage(named:"cast_list_onlive")!, iconSize: self.iconSize)

        //選択できないように
        //self.oneFrameTimeBtn.isEnabled = false
        
        //パスワードのところは非表示＞実装しない
        self.passwordLiveLbl.isHidden = true
        self.passwordLiveBtn.isHidden = true
        self.passwordTextField.isHidden = true
        /*
        self.passwordTextField.placeholder = "パスワードを設定してください"
        
        if(self.passwordTextFieldFlg == 0){
            self.passwordLiveBtn.setTitle("オフ", for: .normal)
            self.passwordTextField.isHidden = true
        }else if(self.passwordTextFieldFlg == 1){
            self.passwordLiveBtn.setTitle("オン", for: .normal)
            self.passwordTextField.isHidden = false
        }*/
        
        if(self.appDelegate.reserveFlg == "0"){
            self.reserveFlgBtn.setTitle(self.reserveFlgList[0], for: .normal)
            //self.reserveFlgBtn.isHidden = true
        }else if(self.appDelegate.reserveFlg == "1"){
            self.reserveFlgBtn.setTitle(self.reserveFlgList[1], for: .normal)
            //self.reserveFlgBtn.isHidden = false
        }
        
        if(self.appDelegate.reserveMaxCount == "5"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[0], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "10"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[1], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "20"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[2], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "30"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[3], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "40"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[4], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "50"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[5], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "75"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[6], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "100"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[7], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "120"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[8], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "140"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[9], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "160"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[10], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "180"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[11], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "200"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[12], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "300"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[13], for: .normal)
        }else if(self.appDelegate.reserveMaxCount == "999999"){
            self.maxReserveCountBtn.setTitle(self.maxReserveCountList[14], for: .normal)
        }
        
        aboutView.backgroundColor = Util.LIVE_WAIT_ABOUT_VIEW_BG_COLOR
        // 角丸
        aboutView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        aboutView.layer.masksToBounds = true
        
        //ラベルの整形
        // 角丸
        reserveFlgLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        reserveFlgLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        reserveFlgLbl.adjustsFontSizeToFitWidth = true
        reserveFlgLbl.minimumScaleFactor = 0.3
        reserveFlgLbl.backgroundColor = Util.LIVE_WAIT_LABEL_BG_COLOR
        
        //ラベルの整形
        // 角丸
        maxReserveCountLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        maxReserveCountLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        maxReserveCountLbl.adjustsFontSizeToFitWidth = true
        maxReserveCountLbl.minimumScaleFactor = 0.3
        maxReserveCountLbl.backgroundColor = Util.LIVE_WAIT_LABEL_BG_COLOR
        
        /*
        // 角丸
        oneFrameTimeLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        oneFrameTimeLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        oneFrameTimeLbl.adjustsFontSizeToFitWidth = true
        oneFrameTimeLbl.minimumScaleFactor = 0.3
        
        // 角丸
        frameRequestLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        frameRequestLbl.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        frameRequestLbl.adjustsFontSizeToFitWidth = true
        frameRequestLbl.minimumScaleFactor = 0.3
        */
        
        /*パスワードのところは実装しない
        //ラベルの枠を自動調節する
        passwordLiveLbl.adjustsFontSizeToFitWidth = true
        passwordLiveLbl.minimumScaleFactor = 0.3
        
        // 角丸
        passwordLiveLbl.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        passwordLiveLbl.layer.masksToBounds = true
        passwordLiveLbl.backgroundColor = Util.LIVE_WAIT_LABEL_BG_COLOR
        */
        
        /*
        //ボタンの整形
        // 枠線の色
        maxWaitTimeBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        maxWaitTimeBtn.layer.borderWidth = 0.5
        // 角丸
        maxWaitTimeBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        maxWaitTimeBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        maxWaitTimeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        maxWaitTimeBtn.titleLabel?.minimumScaleFactor = 0.3
        */
        
        /*
        // 枠線の色
        oneFrameTimeBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        oneFrameTimeBtn.layer.borderWidth = 1
        // 角丸
        oneFrameTimeBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        oneFrameTimeBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        oneFrameTimeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        oneFrameTimeBtn.titleLabel?.minimumScaleFactor = 0.3
        
        // 枠線の色
        frameRequestBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        frameRequestBtn.layer.borderWidth = 1
        // 角丸
        frameRequestBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        frameRequestBtn.layer.masksToBounds = true
        //ラベルの枠を自動調節する
        frameRequestBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        frameRequestBtn.titleLabel?.minimumScaleFactor = 0.3
         */
        
        // 枠線の色
        reserveFlgBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        reserveFlgBtn.layer.borderWidth = 1
        // 角丸
        reserveFlgBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        reserveFlgBtn.layer.masksToBounds = true

        // 枠線の色
        maxReserveCountBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        maxReserveCountBtn.layer.borderWidth = 1
        // 角丸
        maxReserveCountBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        maxReserveCountBtn.layer.masksToBounds = true
        
        /*パスワードのところは実装しない
        // 枠線の色
        passwordLiveBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        passwordLiveBtn.layer.borderWidth = 1
        // 角丸
        passwordLiveBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        passwordLiveBtn.layer.masksToBounds = true
        
        // 入力された文字を非表示モードにする.
        passwordTextField.isSecureTextEntry = true
        */
        
        // 枠線の色
        waitBtn.layer.borderColor = Util.TIMELINE_OFF_FRAME_COLOR.cgColor
        // 枠線の太さ
        waitBtn.layer.borderWidth = 1
        // 角丸
        waitBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        waitBtn.layer.masksToBounds = true
        waitBtn.setTitleColor(Util.LIVE_WAIT_STRING_COLOR, for: .normal)
        
        //self.view.bringSubviewToFront(self.waitBtn)
        
        // Do any additional setup after loading the view.
        
        UtilFunc.checkPermission()
        //self.checkPermissionMicrophone()
        //UtilFunc.checkPermissionCamera()
        
        // スクロールの高さを変更
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: 800)
    }

    //必須
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //くるくる表示終了
        self.busyIndicator.removeFromSuperview()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        UtilLog.printf(str:"WaitTopViewController - MemoryWarning")
    }

    //予約の可否ボタン
    @IBAction func tapReserveFlgBtn(_ sender: Any) {
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        
        // プロトコルの設定
        picker.tag = 1
        picker.delegate = self
        picker.dataSource = self
        
        // はじめに表示する項目を指定
        //picker.selectRow(self.reserve_FlgCd, inComponent: 0, animated: true)
        picker.selectRow(Int(self.appDelegate.reserveFlg)!, inComponent: 0, animated: true)
        
        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        waitBtn.isEnabled = false
        maxReserveCountBtn.isEnabled = false
        passwordLiveBtn.isEnabled = false
        //frameRequestBtn.isEnabled = false
        //oneFrameTimeBtn.isEnabled = false
        reserveFlgBtn.isEnabled = false
    }
    
    /*
    //最大待機時間
    @IBAction func tapMaxWaitTimeBtn(_ sender: Any) {
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        
        // プロトコルの設定
        picker.tag = 1
        picker.delegate = self
        picker.dataSource = self

        // はじめに表示する項目を指定
        picker.selectRow(self.waitTimeCd, inComponent: 0, animated: true)
        
        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        waitBtn.isEnabled = false
        passwordLiveBtn.isEnabled = false
        //frameRequestBtn.isEnabled = false
        //oneFrameTimeBtn.isEnabled = false
        maxWaitTimeBtn.isEnabled = false
    }
    */
    
    /*
    @IBAction func tapFrameRequestBtn(_ sender: Any) {
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        
        // プロトコルの設定
        picker.tag = 2
        picker.delegate = self
        picker.dataSource = self
        
        // はじめに表示する項目を指定
        picker.selectRow(self.frameRequestCd, inComponent: 0, animated: true)
        
        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        waitBtn.isEnabled = false
        passwordLiveBtn.isEnabled = false
        frameRequestBtn.isEnabled = false
        //oneFrameTimeBtn.isEnabled = false
        maxWaitTimeBtn.isEnabled = false
    }
    */
    
    /*
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 表示する列数
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // アイテム表示個数を返す
        return selectFrameList.count
    }
    
    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return selectFrameList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        //print(selectFrameList[row])
        //配信枠を設定
        //appDelegate.waitWaku = selectFrameNumList[row]
    }
*/

    // UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 表示する列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // アイテム表示個数を返す
        if(pickerView.tag == 1){
            return reserveFlgList.count
        }else if(pickerView.tag == 2){
            return maxReserveCountList.count
        }else{
            return 0
        }
    }
    
    // UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        if(pickerView.tag == 1){
            return reserveFlgList[row]
        }else if(pickerView.tag == 2){
            return maxReserveCountList[row]
        }else{
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        //画面上のボタンを有効にする
        waitBtn.isEnabled = true
        maxReserveCountBtn.isEnabled = true
        passwordLiveBtn.isEnabled = true
        //frameRequestBtn.isEnabled = true
        //oneFrameTimeBtn.isEnabled = true
        //maxWaitTimeBtn.isEnabled = true
        reserveFlgBtn.isEnabled = true
        
        if(pickerView.tag == 1){
            //予約の可否
            if(row == 0){
                self.reserveFlgBtn.setTitle(self.reserveFlgList[0], for: .normal)
                self.appDelegate.reserveFlg = "0"
            }else if(row == 1){
                self.reserveFlgBtn.setTitle(self.reserveFlgList[1], for: .normal)
                self.appDelegate.reserveFlg = "1"
            }
        }else if(pickerView.tag == 2){
            //["5","10","20","30","40","50","75","100","120","140","160","180","200","300","無制限"]
            //予約可能人数
            if(row == 0){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[0], for: .normal)
                self.appDelegate.reserveMaxCount = "5"
            }else if(row == 1){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[1], for: .normal)
                self.appDelegate.reserveMaxCount = "10"
            }else if(row == 2){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[2], for: .normal)
                self.appDelegate.reserveMaxCount = "20"
            }else if(row == 3){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[3], for: .normal)
                self.appDelegate.reserveMaxCount = "30"
            }else if(row == 4){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[4], for: .normal)
                self.appDelegate.reserveMaxCount = "40"
            }else if(row == 5){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[5], for: .normal)
                self.appDelegate.reserveMaxCount = "50"
            }else if(row == 6){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[6], for: .normal)
                self.appDelegate.reserveMaxCount = "75"
            }else if(row == 7){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[7], for: .normal)
                self.appDelegate.reserveMaxCount = "100"
            }else if(row == 8){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[8], for: .normal)
                self.appDelegate.reserveMaxCount = "120"
            }else if(row == 9){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[9], for: .normal)
                self.appDelegate.reserveMaxCount = "140"
            }else if(row == 10){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[10], for: .normal)
                self.appDelegate.reserveMaxCount = "160"
            }else if(row == 11){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[11], for: .normal)
                self.appDelegate.reserveMaxCount = "180"
            }else if(row == 12){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[12], for: .normal)
                self.appDelegate.reserveMaxCount = "200"
            }else if(row == 13){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[13], for: .normal)
                self.appDelegate.reserveMaxCount = "300"
            }else if(row == 14){
                self.maxReserveCountBtn.setTitle(self.maxReserveCountList[14], for: .normal)
                self.appDelegate.reserveMaxCount = "999999"//無制限
            }
            /*
            if(row == 0){
                self.maxWaitTimeBtn.setTitle("▼" + self.waitTimeList[0], for: .normal)
                self.waitTimeCd = 0
            }else if(row == 1){
                self.maxWaitTimeBtn.setTitle(self.waitTimeList[1], for: .normal)
                self.waitTimeCd = 1
            }else if(row == 2){
                self.maxWaitTimeBtn.setTitle(self.waitTimeList[2], for: .normal)
                self.waitTimeCd = 2
            }else if(row == 3){
                self.maxWaitTimeBtn.setTitle(self.waitTimeList[3], for: .normal)
                self.waitTimeCd = 3
            }*/
        }else{
        }
        
        /*
        if(pickerView.tag == 1){
            //最大待機時間
            if(row == 0){
                self.maxWaitTimeBtn.setTitle("▼" + self.waitTimeList[0], for: .normal)
                self.waitTimeCd = 0
            }else if(row == 1){
                self.maxWaitTimeBtn.setTitle(self.waitTimeList[1], for: .normal)
                self.waitTimeCd = 1
            }else if(row == 2){
                self.maxWaitTimeBtn.setTitle(self.waitTimeList[2], for: .normal)
                self.waitTimeCd = 2
            }else if(row == 3){
                self.maxWaitTimeBtn.setTitle(self.waitTimeList[3], for: .normal)
                self.waitTimeCd = 3
            }
            
        }else if(pickerView.tag == 2){
            //枠の延長リクエスト
            if(row == 0){
                self.frameRequestBtn.setTitle("▼" + self.frameRequestList[0], for: .normal)
                self.frameRequestCd = 0
            }else if(row == 1){
                self.frameRequestBtn.setTitle(self.frameRequestList[1], for: .normal)
                self.frameRequestCd = 1
            }else if(row == 2){
                self.frameRequestBtn.setTitle(self.frameRequestList[2], for: .normal)
                self.frameRequestCd = 2
            }
        }else{
            
        }
        */
        
        pickerView.removeFromSuperview()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */

    @IBAction func tapMaxReserveCount(_ sender: Any) {
        // ピッカーの作成
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        picker.center = self.view.center
        picker.backgroundColor = UIColor.white
        
        // プロトコルの設定
        picker.tag = 2
        picker.delegate = self
        picker.dataSource = self
        
        // はじめに表示する項目を指定
        //picker.selectRow(self.reserve_FlgCd, inComponent: 0, animated: true)
        picker.selectRow(Int(self.appDelegate.reserveMaxCount)!, inComponent: 0, animated: true)
        
        // 画面にピッカーを追加
        self.view.addSubview(picker)
        
        //画面上のボタンを無効にする
        waitBtn.isEnabled = false
        maxReserveCountBtn.isEnabled = false
        passwordLiveBtn.isEnabled = false
        //frameRequestBtn.isEnabled = false
        //oneFrameTimeBtn.isEnabled = false
        reserveFlgBtn.isEnabled = false
    }
    
    @IBAction func tapPasswordLiveBtn(_ sender: Any) {
        //オン・オフの切り替え
        if(self.passwordTextFieldFlg == 1){
            //パスワードフォームの表示
            self.passwordTextFieldFlg = 0
            self.passwordTextField.isHidden = true
            self.passwordLiveBtn.setTitle("オフ", for: .normal)
            self.passwordLiveBtn.setTitleColor(UIColor.darkGray, for: .normal) // タイトルの色
            self.passwordLiveBtn.backgroundColor = UIColor.white // 背景色
            
            // 枠線の色
            self.passwordLiveBtn.layer.borderColor = UIColor.lightGray.cgColor
            // 枠線の太さ
            self.passwordLiveBtn.layer.borderWidth = 0.5
            
        }else{
            self.passwordTextFieldFlg = 1
            self.passwordTextField.isHidden = false
            self.passwordLiveBtn.setTitle("オン", for: .normal)
            self.passwordLiveBtn.setTitleColor(UIColor.white, for: .normal) // タイトルの色
            self.passwordLiveBtn.backgroundColor = Util.LIVE_WAIT_ON_BG_COLOR // 背景色
            
            // 枠線の色
            //self.passwordLiveBtn.layer.borderColor = UIColor.lightGray.cgColor
            // 枠線の太さ
            self.passwordLiveBtn.layer.borderWidth = 0
        }
    }
    
    @IBAction func waitStartSingle(_ sender: Any) {
        //待機する時に、ここは必ず通る
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        //自分のuser_idを指定
        //let user_id = UserDefaults.standard.integer(forKey: "user_id")

        //print("1度タイムアウトしてからの2度目のリクエスト時に通るか555")
        //DB(mysql)更新
        //待機時には、いったんFireBaseのデータを削除する
        //var rootRef = Database.database().reference()
        Database.database().reference().child(Util.INIT_FIREBASE + "/" + String(self.user_id)).removeValue()
        
        //ステータスなどを初期化
        UtilFunc.liveModifyStatusDo(user_id:self.user_id, status:1, live_user_id: 0, reserve_flg: Int(self.appDelegate.reserveFlg)!, max_reserve_count: Int(self.appDelegate.reserveMaxCount)!, password: "0")
        
        //予約情報をクリア(Newシステム)
        //UtilFunc.reserveListClearByCastId(cast_id:self.user_id, status:0)
        //GET: cast_id, flg=1:追加（プラス１） 2:削除(マイナス１) 3:クリア（ゼロにする）
        //UtilFunc.modifyReserveTotalCount(cast_id:self.user_id, flg:3)
        
        self.appDelegate.reserveStatus = "1"//待機状態
        //self.appDelegate.reserveFlg = //予約の可否
        
        /***************************************************************/
        //フォロワーにリモート通知を送る
        /***************************************************************/
        //リスト取得(自分以外のリストを取得)
        var stringUrl = Util.URL_GET_FOLLOW_LIST
        stringUrl.append("?to_user_id=")
        stringUrl.append(String(self.user_id))
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
        // Swift4からは書き方が変わりました。
        let url = URL(string: stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        let req = URLRequest(url: url)
        //print("aaaa")
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
                    let json = try decoder.decode(UtilStruct.ResultFollowerJson.self, from: data!)
                    //self.idCount = json.count
                    
                    //表示する通知・告知リストを配列にする。
                    for obj in json.result {
                        /*
                        let follower = (obj.from_user_id,
                                        obj.from_user_name.toHtmlString(),
                                        obj.from_notice_type,
                                        obj.from_notice_text.htmlDecoded,
                                        obj.from_notice_rireki_id,
                                        obj.from_notice_rireki_ins_time,
                                        obj.value01,
                                        obj.mod_time,
                                        obj.from_photo_flg,
                                        obj.from_photo_name,
                                        obj.each_other_flg)
                         */
                        //配列へ追加
                        //self.followerList.append(follower)
                        //self.followerListTemp.append(follower)
                        
                        //obj.value01 = 0:無効なフォロー 1:待機通知オン 2:待機通知オフ
                        
                        //リモート通知処理
                        //ブラックリストの配列にない場合はnilが返される
                        if(self.appDelegate.array_black_list.index(of: Int(obj.from_user_id)!) == nil) {
                            //print("nilが返されました。")
                            
                            if(obj.value01 == "1"){
                                //フォローしている、かつ待機通知オンのリスナーへリアルタイム通知
                                //UtilFunc.liveRequestDo(type:Int, from_user_id:Int, to_user_id: Int, token: String)
                                UtilFunc.castWaitNotifyDo(type:1
                                    , from_user_id: self.user_id
                                    , to_user_id: Int(obj.from_user_id)!
                                    , token: Util.serverKey)
                            }

                        }else{
                            //ブラックリストにある場合は何もしない
                        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // 0.5秒後に実行したい処理
                /*
                 if(self.passwordTextFieldFlg == 1
                 && self.passwordTextField.text != ""
                 && self.passwordTextField.text != "0"
                 && self.passwordTextField.text != nil){
                 //パスワード必要
                 self.appDelegate.live_password = self.passwordTextField.text
                 self.appDelegate.live_password_flg = 1
                 //self.liveDo(status:1, password: self.passwordTextField.text!)
                 UtilFunc.liveStartDo(user_id:self.user_id, status:1, password: self.passwordTextField.text!, reserve_flg: Int(self.appDelegate.reserveFlg)!)
                 }else{
                 //パスワードなし
                 self.appDelegate.live_password = ""
                 self.appDelegate.live_password_flg = 0
                 //self.liveDo(status:1, password: "0")
                 UtilFunc.liveStartDo(user_id:self.user_id, status:1, password: "0", reserve_flg: Int(self.appDelegate.reserveFlg)!)
                 }*/
                
                //相手の名前を共通変数に格納しておく(クリア)
                self.appDelegate.live_target_user_name = ""
                self.appDelegate.live_target_user_id = 0
                
                //予約が入った場合の残りの秒数（5分からスタートとなる）バッファは含まれない。
                //self.appDelegate.reserve_wait_time = 0
                //self.appDelegate.live_reserve_count = 0//予約の人数を初期化
                self.appDelegate.count = 0//ライブ経過時間の秒数
                /*予約関連(相手の情報)*/
                //            self.appDelegate.reserveUserId = "0"
                //            self.appDelegate.reservePeerId = "0"
                //            self.appDelegate.reserveUserName = ""
                //            self.appDelegate.reservePhotoFlg = "0"
                //            self.appDelegate.reservePhotoName = ""
                //self.appDelegate.reserveFlg = ""
                
                //ライブ中のエフェクト用(初期化)
                self.appDelegate.live_effect_id = 0//ライブ配信で設定したエフェクトID
                self.appDelegate.live_effect_id_before = 0//ライブ配信で設定したエフェクトID(直前の比較用)
                
                //self.appDelegate.peerFlg = 1
                UtilToViewController.toWaitViewController()
            }
        }
    }

    /*
    @IBAction func createEventTop(_ sender: Any) {
        //イベント作成の直前ページへ
        UtilToViewController.toCreateEventTopViewController()
    }*/

    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
