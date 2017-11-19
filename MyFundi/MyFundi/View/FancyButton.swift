//
//  FancyButton.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 9/30/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
//Class to change the UI of a Button
class FancyButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        //Set the shadow color  to grey
        layer.shadowColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        //Set the opacity to 80%
        layer.shadowOpacity = 0.8
        //Set the shadow radius to round
        layer.shadowRadius = 5.0
        //Set the shadow offset to 1 high and 1 wide
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        //Set the corner radius to 2
        layer.cornerRadius = 2
        //Set the background color to the a hue of blu
        layer.backgroundColor = UIColor(displayP3Red: 96/255, green: 195/255, blue: 215/255, alpha: 1).cgColor
    }
    
    func error() {
        //Set the border to Red
        layer.borderColor = UIColor.red.cgColor
        //Set the width of the border to 1
        layer.borderWidth = 1
    }

}
