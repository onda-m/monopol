//
//  MyChatViewCell.swift
//  lime
//

import UIKit

class MyChatViewCell: UITableViewCell {
	//キャストが告知・つぶやいた時の吹き出しの部分
    
    @IBOutlet weak var castImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
	//@IBOutlet weak var timeLabel: UILabel!
	//@IBOutlet weak var readLabel: UILabel!
	
	@IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.backgroundColor = UIColor.clear
		self.textView.layer.cornerRadius = 10 // 角を丸める
		//addSubview(MyBalloonView(frame: CGRect(x: Int(frame.size.width+30), y: 0, width: 30, height: 30))) //吹き出しのようにするためにビューを重ねる
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

extension MyChatViewCell {
	func updateCell(text: String, time: String, isRead: Bool) {
		self.textView?.text = text
		//self.timeLabel?.text = time
		//self.readLabel?.isHidden = !isRead
		
		let frame = CGSize(width: self.frame.width - 8, height: CGFloat.greatestFiniteMagnitude)
		var rect = self.textView.sizeThatFits(frame)
		if(rect.width<30){
			rect.width=30
		}
		textViewWidthConstraint.constant = rect.width//テキストが短くても最小のビューの幅を30とする
	}
}

