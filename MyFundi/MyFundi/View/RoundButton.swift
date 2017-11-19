//
//  RoundButton.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 9/30/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

//Class to handle to UI of a Round Button
class RoundButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        //Set the shadow color
        layer.shadowColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        //SET THE SHADOW opacity to 80%
        layer.shadowOpacity = 0.8
        //Set the shadow radius to be round
        layer.shadowRadius = 5.0
        //Set the shadow offset to 1 pixel high and wide
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        //Set the Image View to scale aspect fit
        imageView?.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Give the layer a round shape
        layer.cornerRadius = self.frame.width / 2
    }
    

}
