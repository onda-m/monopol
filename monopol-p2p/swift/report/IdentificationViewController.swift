//
//  IdentificationViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/07/09.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import MessageUI

//リジェクトされたので、いったん未使用
class IdentificationViewController: BaseViewController, MFMailComposeViewControllerDelegate {
//本人確認手続きの画面
    
    @IBOutlet weak var identificationLabel: UILabel!
    
    @IBOutlet weak var identificationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 角丸
        self.identificationBtn.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.identificationBtn.layer.masksToBounds = true
        
        self.identificationLabel.text = UtilStr.IDENTIFICATION_STR
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapIdentificationBtn(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([UtilStr.CONFIRM_MAIL_ADDRESS]) // 宛先アドレス
            
            let next_id = UserDefaults.standard.string(forKey: "next_id")
            let myName = UserDefaults.standard.string(forKey: "myName")
            mail.setSubject(UtilStr.CONFIRM_MAIL_TITLE + next_id!) // 件名
            mail.setMessageBody(UtilStr.CONFIRM_MAIL_TEXT_01 + next_id! + UtilStr.CONFIRM_MAIL_TEXT_02 + myName! + UtilStr.CONFIRM_MAIL_TEXT_03, isHTML: false) // 本文
            
            // 下記を追加する
            mail.modalPresentationStyle = .fullScreen
            
            present(mail, animated: true, completion: nil)
        } else {
            //print("送信できません")
            showAlert()
        }
    }
    
    //数秒後に勝手に閉じる
    func showAlert() {
        // アラート作成
        let alert = UIAlertController(title: nil, message: "メーラーが正しく設定されていません。", preferredStyle: .alert)
        
        // 下記を追加する
        alert.modalPresentationStyle = .fullScreen
        
        // アラート表示
        self.present(alert, animated: true, completion: {
            // アラートを閉じる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
        default:
            print("送信失敗")
        }
        dismiss(animated: true, completion: nil)
    }
    
}
