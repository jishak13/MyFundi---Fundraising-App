//
//  DetailsPageButton.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/29/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class DetailsPageButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 2
        layer.backgroundColor = UIColor(displayP3Red: 96/255, green: 195/255, blue: 215/255, alpha: 1).cgColor
    }
    
    func HideButton(){
        layer.isHidden = true
    }
    func ShowButton() {
        layer.isHidden = false
    }
}
