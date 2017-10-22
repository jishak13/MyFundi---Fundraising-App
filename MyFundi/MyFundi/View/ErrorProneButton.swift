//
//  ErrorProneButton.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/22/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class ErrorProneButton: UIButton {

    @IBOutlet weak var imageSelector: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 2
    }
    
    func imageSelectorError() {
     imageSelector.layer.borderColor = UIColor.red as! CGColor
    }
    
    func noImageSelectorError() {
        imageSelector.layer.borderColor = UIColor.black as! CGColor

    }
}
