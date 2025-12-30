//
//  YourChatViewCell.swift
//  lime
//

import UIKit

class YourChatViewCell: UITableViewCell {
    //ユーザーから見たキャストの告知(テキストのみ)
    
    //@IBOutlet weak var iineLblBtn: UIButton!
    @IBOutlet weak var iineBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var kokuchiBtn: UIButton!
    @IBOutlet weak var castImageView: EnhancedCircleImageView!
    @IBOutlet weak var textView: UITextView!
	@IBOutlet weak var castNameLabel: UILabel!
	@IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
	
    //@IBOutlet weak var iineTextView: UITextView!//自分のタイムラインにいいねをした人のリストを表示
    
	override func awakeFromNib() {
		super.awakeFromNib()
		self.backgroundColor = UIColor.clear
		self.textView.layer.cornerRadius = 10// 角を丸める
		//self.addSubview(YourBalloonView(frame: CGRect(x: textView.frame.minX-10, y: textView.frame.minY-10, width: 50, height: 50)))//吹き出しのようにするためにビューを重ねる
        
        //paddingの指定(top,left,bottom,right)
        self.textView.textContainerInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        //ラベルの枠を自動調節する
        dateLbl.adjustsFontSizeToFitWidth = true
        dateLbl.minimumScaleFactor = 0.3
        
        //castNameLabel.adjustsFontSizeToFitWidth = true
        //castNameLabel.minimumScaleFactor = 0.3
        
        // 枠線の色
        //rankFView.layer.borderColor = UIColor.lightGray.cgColor
        // 枠線の太さ
        //rankFView.layer.borderWidth = 1
        // 角丸
        followBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        followBtn.layer.masksToBounds = true
        
        // 角丸
        kokuchiBtn.layer.cornerRadius = 4
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        kokuchiBtn.layer.masksToBounds = true
        
        // 角丸
        //iineTextView.layer.cornerRadius = 2
        // 角丸にした部分のはみ出し許可 false:はみ出し可 true:はみ出し不可
        //iineTextView.layer.masksToBounds = true
	}
	
    
    
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		// Configure the view for the selected state
	}

}

extension YourChatViewCell {
	func updateCell(name: String, text: String, time: String) {
		self.textView?.text = text
        self.dateLbl?.text = time
		self.castNameLabel?.text = name
		
		//let frame = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let frame = CGSize(width: self.frame.width + 8, height: CGFloat.greatestFiniteMagnitude)
		var rect = self.textView.sizeThatFits(frame)
		if(rect.width<30){
			rect.width=30
		}
		textViewWidthConstraint.constant = rect.width//テキストが短くても最小のビューの幅を30とする
	}
}

