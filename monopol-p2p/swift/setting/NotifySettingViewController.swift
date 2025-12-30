//
//  NotifySettingViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/10/10.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class NotifySettingViewController: BaseViewController {
    
    @IBOutlet weak var notifyLbl: AutoShrinkLabel!
    @IBOutlet weak var notifySwitch: UISwitch!
    
    //くるくる表示開始
    let busyIndicator:BusyIndicator = UINib(nibName: "BusyIndicator", bundle: nil).instantiate(withOwner: self,options: nil)[0] as! BusyIndicator
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 角丸
        self.notifyLbl.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.notifyLbl.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        
        let notifyFlg = UserDefaults.standard.integer(forKey: "notify_flg")
        if(notifyFlg == 1){
            //初期状態をONに設定
            self.notifySwitch.isOn = true
        }else{
            //初期状態をOFFに設定
            self.notifySwitch.isOn = false
        }
        
        //swiが押された時の処理を設定
        self.notifySwitch.addTarget(self, action: #selector(self.switchClick(sender:)), for: UIControl.Event.valueChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //swiが押された時の処理の中身
    @objc func switchClick(sender: UISwitch){
        if sender.isOn {
            //print("On")
            self.modifyNotifyFlgDo(flg: 1, user_id: self.user_id)
        }else {
            //print("Off")
            self.modifyNotifyFlgDo(flg: 2, user_id: self.user_id)
        }
    }
    
    func modifyNotifyFlgDo(flg: Int!, user_id: Int!){
        //通知フラグを変更
        //flg = 1:オン 2:オフ
        var stringUrl = Util.URL_MODIFY_NOTIFY_FLG
        stringUrl.append("?user_id=")
        stringUrl.append(String(user_id))
        stringUrl.append("&flg=")
        stringUrl.append(String(flg))
        
        //くるくる表示開始
        //画面サイズに合わせる
        self.busyIndicator.frame = self.view.frame
        // 貼り付ける
        self.view.addSubview(self.busyIndicator)
        
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

                    dispatchGroup.leave()//サブタスク終了時に記述
                }
            })
            task.resume()
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {

            if(flg == 1){
                //状態をONに設定
                self.notifySwitch.isOn = true
                UserDefaults.standard.set("1", forKey: "notify_flg")
            }else{
                //状態をOFFに設定
                self.notifySwitch.isOn = false
                UserDefaults.standard.set("2", forKey: "notify_flg")
            }
            //くるくる表示終了
            self.busyIndicator.removeFromSuperview()
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

}
