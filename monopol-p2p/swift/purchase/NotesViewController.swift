//
//  NotesViewController.swift
//  swift_skyway
//
//  Created by onda on 2018/06/24.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var titleTextLbl: UILabel!
    @IBOutlet weak var notesTextLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 枠線の色
        mainView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        mainView.layer.borderWidth = 1
        // 角丸
        mainView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mainView.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        titleTextLbl.text = UtilStr.COIN_PAY_TITLE_STR
        
        var mainText = UtilStr.COIN_PAY_STR_00
        mainText.append(UtilStr.COIN_PAY_STR_01)
        mainText.append(UtilStr.COIN_PAY_STR_02)
        mainText.append(UtilStr.COIN_PAY_STR_03)
        mainText.append(UtilStr.COIN_PAY_STR_04)
        mainText.append(UtilStr.COIN_PAY_STR_05)
        mainText.append(UtilStr.COIN_PAY_STR_06)
        mainText.append(UtilStr.COIN_PAY_STR_07)
        mainText.append(UtilStr.COIN_PAY_STR_08)
        mainText.append(UtilStr.COIN_PAY_STR_09)
        mainText.append(UtilStr.COIN_PAY_STR_10)
        mainText.append(UtilStr.COIN_PAY_STR_11)
        mainText.append(UtilStr.COIN_PAY_STR_12)
        mainText.append(UtilStr.COIN_PAY_STR_13)
        mainText.append(UtilStr.COIN_PAY_STR_99)

        notesTextLbl.text = mainText

        // セットした文字からUILabelの幅と高さを算出
        let rect: CGSize = notesTextLbl.sizeThatFits(CGSize(width: notesTextLbl.frame.width, height: CGFloat.greatestFiniteMagnitude))
        // 算出された幅と高さをセット
        notesTextLbl.frame = CGRect(x: notesTextLbl.frame.minX, y: 0, width: rect.width, height: rect.height)
        //notesTextLbl.frame.size = CGSize(width: notesTextLbl.frame.width, height: 2700)
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: notesTextLbl.frame.height + 10)
    }

    @IBAction func tapCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
