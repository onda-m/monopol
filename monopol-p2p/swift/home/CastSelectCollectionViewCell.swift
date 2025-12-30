//
//  CastSelectCollectionViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/07/09.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit
import AVFoundation

class CastSelectCollectionViewCell: UICollectionViewCell {
    
    //var playerLayer = AVPlayerLayer()
    
    //下のグラデーション部分
    //@IBOutlet weak var downGradientView: UIView!
    
    //初期化(動画再生用)
    //var player:AVPlayer? = nil
    //var playerLayer:AVPlayerLayer? = nil
    //@IBOutlet weak var castMovieView: UIView!
    //フォローボタン
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileBtnImage: UIImageView!
    @IBOutlet weak var freetextBtn: UIButton!
    
    @IBOutlet weak var castImageView: UIImageView!
    @IBOutlet weak var castBackImageView: UIImageView!
    @IBOutlet weak var castProfileImageView: EnhancedCircleImageView!
    
    @IBOutlet weak var liveStartBtn: UIButton!
    
    //イベント関連(現在イベント中の時に表示)
    @IBOutlet weak var eventNowImageView: UIImageView!
    
    //イベント関連(キャッシュバックイベントなど)
    @IBOutlet weak var eventImageBtn: UIButton!
    @IBOutlet weak var eventTextImageView: UIImageView!
    
    //名前ラベルのところ
    @IBOutlet weak var userNameLabel: UILabel!
    
    //待機中の帯のところ
    //@IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!

    //パスワードのところ
    @IBOutlet weak var passwordView: UIImageView!
    
    //公式のところ
    @IBOutlet weak var officialLabel: UILabel!
    
    //右下のプレミアムアイコンのところ
    @IBOutlet weak var premiumImageView: UIImageView!
    
    //予約可のところ
    @IBOutlet weak var reserveLabel: UILabel!
    
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var downGradationView: UIView!
    @IBOutlet weak var downView: UIView!
    
    //左が視聴レベル、右が配信レベル
    @IBOutlet weak var watchLevelLbl: UILabel!
    @IBOutlet weak var liveLevelLbl: UILabel!
    
    //イベントボタンのところ
    @IBOutlet weak var userEventBtn: UIButton!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    @IBAction func eventImageViewTapped(_ sender: Any) {
        self.eventTextImageView.image = UIImage(named:"event_cb_text2")
        self.eventTextImageView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // 3秒後に実行したい処理
            self.eventTextImageView.isHidden = true
        }
    }

    /*
    // 画像がタップされたら呼ばれる
    @objc func eventImageViewTapped(_ sender: UITapGestureRecognizer) {
        self.eventTextImageView.image = UIImage(named:"event_cb_text")
        self.eventTextImageView.isHidden = false
    }
    */
    
    override func prepareForReuse(){
        //print("clear")
        self.castImageView.image = nil
        self.castBackImageView.image = nil
        self.castProfileImageView.image = nil
        //self.player = nil
        //self.playerLayer?.removeFromSuperlayer()
        //self.playerLayer = nil
        
        //self.downView.
        //self.bringSubviewToFront(downView)
        //self.eventImageView.isUserInteractionEnabled = true
        //self.eventImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.eventImageViewTapped(_:))))
        
        /*****************************/
        //グラデーション(画面の下部分)
        /*****************************/
        /*
        //グラデーションの開始色
        //let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
        let topColorDown = Util.CAST_SELECT_GRAD_END
        //グラデーションの開始色
        //let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        let bottomColorDown = Util.CAST_SELECT_GRAD_START
        //グラデーションの色を配列で管理
        let gradientColorsDown: [CGColor] = [topColorDown.cgColor, bottomColorDown.cgColor]
        
        //グラデーションの色をレイヤーに割り当てる
        self.gradientLayerDown.colors = gradientColorsDown

        //グラデーションレイヤーをスクリーンサイズにする
        //gradientLayer.frame = self.view.bounds
        self.downGradientView.layer.insertSublayer(gradientLayerDown,at:0)
        //self.downGradientView = self.gradientLayerDown
        //self.gradientLayerDown.frame = CGRect(x:0, y:self.frame.height - 80, width:self.frame.width, height:80)
         */
        
        /*
        //downViewの真上のグラデーション部分
        //グラデーションの開始色
        let topColor = UIColor(red:0.07, green:0.13, blue:0.26, alpha:1)
        //let topColorUp = Util.CAST_SELECT_GRAD_DOWN_START
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:1)
        //let bottomColorUp = Util.CAST_SELECT_GRAD_DOWN_END
        //グラデーションの色を配列で管理
        let gradientColorsBottom: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        //let gradientColorsBottom: [CGColor] = [Util.CAST_SELECT_GRAD_DOWN_START.cgColor, Util.CAST_SELECT_GRAD_DOWN_END.cgColor]
        //グラデーションレイヤーを作成
        let gradientLayerBottom: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayerBottom.colors = gradientColorsBottom
        //グラデーションレイヤーをスクリーンサイズにする
        //gradientLayerBottom.frame = testCell.downGradationView.frame
        gradientLayerBottom.frame = CGRect(x:0, y:0, width:self.frame.width, height:101)
        
        //self.view.layer.insertSublayer(gradientLayer, at: 0)
        self.downGradationView.layer.addSublayer(gradientLayerBottom)
         */
    }
}
