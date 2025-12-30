//
//  CreateEventCompViewController.swift
//  swift_skyway
//
//  Created by dev monopol on 2021/08/28.
//  Copyright © 2021 worldtrip. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CreateEventCompViewController: BaseViewController {
    //イベント告知ページを確認ボタン
    @IBOutlet weak var eventCompKokuchiPageBtn: UIButton!
    
    //イベント申込ページを確認ボタン
    @IBOutlet weak var eventCompJoinPageBtn: UIButton!
    
    @IBOutlet weak var detailLabel: UILabel!//イベントの説明のところ
    @IBOutlet weak var aboutView: UIView!
    
    //@IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        eventCompKokuchiPageBtn.titleLabel?.numberOfLines = 0
        eventCompKokuchiPageBtn.setTitle("イベント告知ページを\n確認", for: .normal)
        
        eventCompJoinPageBtn.titleLabel?.numberOfLines = 0
        eventCompJoinPageBtn.setTitle("イベント申込ページを\n確認", for: .normal)
        
        // スクロールの高さを変更
        //mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width, height: 700)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createEventKokuchiPage(_ sender: Any) {
        //イベント告知
        //外部ブラウザでURLを開く
        var stringUrl = Util.URL_EVENT_URL
        stringUrl.append(String(self.appDelegate.createEventId))
        
        let url = NSURL(string: stringUrl)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func createEventJoinPage(_ sender: Any) {
        //イベント申込
        //外部ブラウザでURLを開く
        var stringUrl = Util.URL_EVENT_APPLY_URL
        stringUrl.append(String(self.appDelegate.createEventId))
        
        let url = NSURL(string: stringUrl)
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
}
