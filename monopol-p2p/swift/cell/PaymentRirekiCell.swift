//
//  PaymentRirekiCell.swift
//  swift_skyway
//
//  Created by onda on 2018/09/22.
//  Copyright © 2018年 worldtrip. All rights reserved.
//

import UIKit

class PaymentRirekiCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var yenLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
