//
//  ProductTableViewCell.swift
//  swift_skyway
//
//  Created by onda on 2018/08/31.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productMainView: UIView!
    @IBOutlet weak var productNoteLabel: UILabel!
    @IBOutlet weak var productNameLabel:UILabel!
    @IBOutlet weak var purchaseButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
