//
//  TimelineHeaderView.swift
//  swift_skyway
//
//  Created by onda on 2018/05/15.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

//参考
//https://qiita.com/sachiko-kame/items/ed81817a83e174e16bea

import UIKit

class TimelineHeaderView: UIView {
    
    @IBOutlet weak var timelineBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var mainView: UIView!

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        //let selfheight:CGFloat = 46
        //let selfwidth:CGFloat = 343
        
        //self.frame.size.height = selfheight
        //self.frame.size.width = selfwidth
        
        //フォロワー:--
        let follow_num = UserDefaults.standard.integer(forKey: "follow_num")
        let follower_num = UserDefaults.standard.integer(forKey: "follower_num")
        
        followBtn.setTitle("フォロー:"+String(follow_num), for: .normal) // ボタンのタイトル
        //followBtn.setTitleColor(UIColor.red, for: .normal) // タイトルの色
        
        followerBtn.setTitle("フォロワー:"+String(follower_num), for: .normal) // ボタンのタイトル
        //followerBtn.setTitleColor(UIColor.red, for: .normal) // タイトルの色

        let sel_menu_num = UserDefaults.standard.integer(forKey: "userFollowMenu")
        
        if(sel_menu_num == 1){
            timelineBtn.setTitleColor(UIColor.blue, for: .normal)
            followBtn.setTitleColor(UIColor.darkText, for: .normal)
            followerBtn.setTitleColor(UIColor.darkText, for: .normal)
        }else if(sel_menu_num == 2){
            timelineBtn.setTitleColor(UIColor.darkText, for: .normal)
            followBtn.setTitleColor(UIColor.blue, for: .normal)
            followerBtn.setTitleColor(UIColor.darkText, for: .normal)
        }else if(sel_menu_num == 3){
            timelineBtn.setTitleColor(UIColor.darkText, for: .normal)
            followBtn.setTitleColor(UIColor.darkText, for: .normal)
            followerBtn.setTitleColor(UIColor.blue, for: .normal)
        }else{
            timelineBtn.setTitleColor(UIColor.blue, for: .normal)
            followBtn.setTitleColor(UIColor.darkText, for: .normal)
            followerBtn.setTitleColor(UIColor.darkText, for: .normal)
        }
        
        let superScreen:CGRect = (self.window?.screen.bounds)!
        
        //self.frame.origin.x = (superScreen.width/2) - (selfwidth/2)
        //self.frame.origin.y = (superScreen.height/2) - (selfheight/2)
        
        // 角丸
        mainView.layer.cornerRadius = 8
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        mainView.layer.masksToBounds = true
        
        //AutoLayout解除
        mainView.translatesAutoresizingMaskIntoConstraints = true
        mainView.frame = CGRect(x:((superScreen.width-280)/2),y:72,width:280,height:38)
        
    }
    
    @IBAction func timelineBtnTap(_ sender: Any) {
        UserDefaults.standard.set(1, forKey: "userFollowMenu")//ユーザー側フォローメニュのサブメニュー 1:タイムライン
        UtilToViewController.toTimelineViewController()
    }
    
    @IBAction func followBtnTap(_ sender: Any) {
        UserDefaults.standard.set(2, forKey: "userFollowMenu")//ユーザー側フォローメニュのサブメニュー 1:タイムライン
        //Util.toFollowViewController()
    }
    
    @IBAction func followerBtnTap(_ sender: Any) {
        UserDefaults.standard.set(3, forKey: "userFollowMenu")//ユーザー側フォローメニュのサブメニュー 1:タイムライン
        //Util.toFollowerViewController()
    }

    //自分自身はサワレナイ(下記を透過したいVIewに記述)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self {
            return nil
        }
        return view
    }
    
}
