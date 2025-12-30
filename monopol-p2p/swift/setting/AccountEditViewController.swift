//
//  AccountEditViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/10/01.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class AccountEditViewController: BaseViewController {

    var coverView: UIView!//キーボード以外を覆うVIEW
    
    //パスワード設定ダイアログのところ
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var passwordTextField: KeyBoard!
    @IBOutlet weak var rePasswordTextField: KeyBoard!
    
    //引継ぎ設定が完了していますのところ
    @IBOutlet weak var nextOkView: UIView!
    //パスワードが一致しませんでした。のところ
    @IBOutlet weak var nextNgView: UIView!
    
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!

    //let nextSettingDialog:NextSettingDialog = UINib(nibName: "NextSettingDialog", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! NextSettingDialog
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //キーボード対応
        self.configureObserver()
        
        self.nextNgView.isHidden = true
        self.dialogView.isHidden = true
        
        // Do any additional setup after loading the view.
        let id_temp = UserDefaults.standard.string(forKey: "next_id")
        self.idLbl.text = "ID：" + id_temp!
        
        //lineid
        let sns_userid01_temp = UserDefaults.standard.string(forKey: "sns_userid01")
        //appleid
        let sns_userid02_temp = UserDefaults.standard.string(forKey: "sns_userid02")
        
        self.settingBtn.isHidden = false
        
        if(sns_userid01_temp != "0" && sns_userid01_temp != ""){
            //lineidが設定されている場合
            self.statusLbl.text = "LINE IDで設定済"
            self.statusLbl.textColor = UIColor.blue
            self.nextOkView.isHidden = true
            self.settingBtn.isHidden = true
        }else if(sns_userid02_temp != "0" && sns_userid02_temp != ""){
            //appleidが設定されている場合
            self.statusLbl.text = "APPLE IDで設定済"
            self.statusLbl.textColor = UIColor.blue
            self.nextOkView.isHidden = true
            self.settingBtn.isHidden = true
        }else{
            // 入力された文字を非表示モードにする.
            let password_temp = UserDefaults.standard.string(forKey: "next_pass")
            if(password_temp == "0" || password_temp == ""){
                //パスワードが設定されていない場合
                self.statusLbl.text = "未設定"
                //password_temp = ""
                self.statusLbl.textColor = UIColor.red
                self.nextOkView.isHidden = true
                self.settingBtn.isHidden = false
            }else{
                self.statusLbl.text = "パスワード設定済"
                self.statusLbl.textColor = UIColor.blue
                self.nextOkView.isHidden = false
                self.settingBtn.isHidden = false
            }
        }

        // 枠線の色
        //settingBtn.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //settingBtn.layer.borderWidth = 1
        // 角丸
        self.settingBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.settingBtn.layer.masksToBounds = true
        
        //self.passwordTextField.text = password_temp
        //self.passwordTextField.isSecureTextEntry = true
        
        //self.passwordTextField.delegate = self
        //self.rePasswordTextField.delegate = self
        
        // 枠線の色
        self.idView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.idView.layer.borderWidth = 1
        // 角丸
        self.idView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.idView.layer.masksToBounds = true
        
        // 枠線の色
        self.statusView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.statusView.layer.borderWidth = 1
        // 角丸
        self.statusView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.statusView.layer.masksToBounds = true
        
        
        /************************************/
        //パスワード設定のダイアログ関連
        /************************************/
        // 枠線の色
        self.dialogView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        self.dialogView.layer.borderWidth = 2
        // 角丸
        self.dialogView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.dialogView.layer.masksToBounds = true
        
        // 角丸
        self.okBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.okBtn.layer.masksToBounds = true
        
        // 角丸
        self.cancelBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.cancelBtn.layer.masksToBounds = true
        
        //placeholderの設定
        self.passwordTextField.isSecureTextEntry = true
        self.rePasswordTextField.isSecureTextEntry = true

        self.passwordTextField.text = ""
        self.rePasswordTextField.text = ""
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "6~10文字の半角英数字を入力してください", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: 10.0)
            ])
        self.rePasswordTextField.attributedPlaceholder = NSAttributedString(string: "確認のためパスワードを再入力してください", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: 10.0)
            ])
        /************************************/
        //パスワード設定のダイアログ関連(ここまで)
        /************************************/

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapSettingBtn(_ sender: Any) {
        //画面サイズに合わせる
        //self.nextSettingDialog.frame = self.view.frame
        
        //self.nextSettingDialog.nextSettingDialogSetting()
        
        // 貼り付ける
        //self.view.addSubview(self.nextSettingDialog)
        
        self.passwordTextField.text = ""
        self.rePasswordTextField.text = ""
        self.dialogView.isHidden = false
    }
    
    @IBAction func tapOkBtn(_ sender: Any) {
        let user_id = UserDefaults.standard.integer(forKey: "user_id")
        let next_id = UserDefaults.standard.string(forKey: "next_id")
        self.savePassword(user_id:String(user_id), next_id:next_id!)
    }
    
    @IBAction func tapCancelBtn(_ sender: Any) {
        self.dialogView.isHidden = true
    }
    
    func savePassword(user_id:String, next_id:String){
        let strPassword = passwordTextField.text
        let strRePassword = rePasswordTextField.text
        
        if(strPassword == strRePassword){
            if(strPassword != nil && strPassword != "" && strRePassword != nil && strRePassword != ""){
                
                //let user_id = UserDefaults.standard.integer(forKey: "user_id")
                //let next_id = UserDefaults.standard.string(forKey: "next_id")
                
                //パスワードを変更
                //GET: password, user_id, next_id
                var stringUrl = Util.URL_MODIFY_PASSWORD
                stringUrl.append("?user_id=")
                stringUrl.append(String(user_id))
                stringUrl.append("&next_id=")
                stringUrl.append(next_id)
                stringUrl.append("&password=")
                stringUrl.append(strPassword!)
                
                //print(stringUrl)
                
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
                    UserDefaults.standard.set(strPassword, forKey: "next_pass")
                    self.statusLbl.text = "パスワード設定済"
                    self.statusLbl.textColor = UIColor.blue
                    self.nextOkView.isHidden = false
                    
                    self.nextOkView.isHidden = false
                    self.nextNgView.isHidden = true
                    self.dialogView.isHidden = true
                    
                    //showalert
                    UtilFunc.showAlert(message:"パスワードの設定が完了しました", vc:self, sec:2.0)
                }
            }else{
                self.nextOkView.isHidden = true
                self.nextNgView.isHidden = false
                self.dialogView.isHidden = true
            }
        }else{
            self.nextOkView.isHidden = true
            self.nextNgView.isHidden = false
            self.dialogView.isHidden = true
        }
    }
    /*
    func nextSettingDialogSetting(){
        // ポップアップビュー背景色
        let viewColor = UIColor.white
        // 半透明にして親ビューが見えるように。透過度はお好みで。
        self.backgroundColor = viewColor.withAlphaComponent(0.85)
    }
     */
    
}

// MARK: UITextFieldDelegate
//キーボードが隠れてしまう問題の対応
extension AccountEditViewController: UITextFieldDelegate {
    
    // Notificationを設定
    func configureObserver() {
        
        let notification = NotificationCenter.default
        
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        notification.addObserver(self, selector: #selector(textFieldDidChange(notification:)), name: UITextField.textDidChangeNotification, object: self.passwordTextField)
    }
    
    // Notificationを削除
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    @objc func textFieldDidChange(notification: Notification?) {
        let textField = notification?.object as! UITextField
        if let text = textField.text {
            //6文字以上10文字以下、半角英数の時だけボタンを押せるようにする
            if (text.count >= 6 && text.count <= 10 && text.isAlphanumeric() == true) {
                //textField.text = text.substringToIndex(text.startIndex.advancedBy(3))
                self.okBtn.isEnabled = true
                self.okBtn.backgroundColor = UIColor.blue
                //self.okBtn.isHidden = true
            }else{
                self.okBtn.isEnabled = false
                self.okBtn.backgroundColor = UIColor.lightGray
                //self.okBtn.isHidden = false
            }
        }
    }
    
    // キーボードが現れた時に、画面全体をずらす。
    @objc func keyboardWillShow(notification: Notification?) {
        
        let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect?.size.height)! + 24)
            self.view.transform = transform
            
        })
        
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
        self.view.bringSubviewToFront(passwordTextField)
        self.view.bringSubviewToFront(rePasswordTextField)
    }
    
    // キーボードが消えたときに、画面を戻す
    @objc func keyboardWillHide(notification: Notification?) {
        
        let duration: TimeInterval? = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            self.view.transform = CGAffineTransform.identity
        })
        
        coverView.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Returnキーを押したときにキーボードを下げる
        return true
    }
}
