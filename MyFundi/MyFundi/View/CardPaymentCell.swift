//
//  CardPaymentCell.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/31/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class CardPaymentCell: UITableViewCell {

    
    @IBOutlet weak var cardNameLabel: UILabel!
    
    @IBOutlet weak var cardNumberLabel: UILabel!
    
    @IBOutlet weak var expireDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(card: Card){
        
        let chars = Array("\(card.CardNumber)")
        cardNameLabel.text  = card.CardHolderName
        cardNumberLabel.text = "xxxx-xxxx-xxxx-\(chars[12])\(chars[13])\(chars[14])\(chars[15])"
        expireDateLabel.text = card.ExpireDate
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
