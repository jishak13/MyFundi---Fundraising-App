//
//  donateCardPaymentsCell.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/3/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class donateCardPaymentsCell: UITableViewCell {

    @IBOutlet weak var cardExpireDateLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(card: Card){
        
        let chars = Array("\(card.CardNumber)")
//        cardNameLabel.text  = card.CardHolderName
        cardNumberLabel.text = "xxxx-xxxx-xxxx-\(chars[12])\(chars[13])\(chars[14])\(chars[15])"
        cardExpireDateLabel.text = card.ExpireDate
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
