//
//  CreateEventTopViewController.swift
//  swift_skyway
//
//  Created by dev monopol on 2021/08/23.
//  Copyright © 2021 worldtrip. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CreateEventTopViewController: BaseViewController {
 
    //イベント作成ボタン
    @IBOutlet weak var createEventBtn: UIButton!
    
    //@IBOutlet weak var detailLabel: UILabel!//イベントの説明のところ
    //@IBOutlet weak var aboutView: UIView!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
/*
        //説明文を設定
        self.detailLabel.text = UtilStr.EVENT_TOP_DETAIL_STR
        
        self.aboutView.backgroundColor = Util.LIVE_WAIT_ABOUT_VIEW_BG_COLOR
        // 角丸
        self.aboutView.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        self.aboutView.layer.masksToBounds = true
*/
        // スクロールの高さを変更
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.width
            , height: 650)
    }

    @IBAction func createEvent(_ sender: Any) {
        //イベント作成のページへ
        UtilToViewController.toCreateEventViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
