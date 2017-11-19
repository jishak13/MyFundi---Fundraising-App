//
//  DetailsPageButton.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/29/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
//Class to handle the Details page Button UI Element
class DetailsPageButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        //change the shadow color to grey
        layer.shadowColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        //Set the opacity to 80%
        layer.shadowOpacity = 0.8
        //Set the shadow radius to 5
        layer.shadowRadius = 5.0
        //Set the shadow offset to 1 tall and 1 wide
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        //Set the corner radius to 2 giving a rounded edge
        layer.cornerRadius = 2
        //Set the background color to a hue of blue
        layer.backgroundColor = UIColor(displayP3Red: 96/255, green: 195/255, blue: 215/255, alpha: 1).cgColor
    }
    //Hide the button
    func HideButton(){
        layer.isHidden = true
    }
    //show the button
    func ShowButton() {
        layer.isHidden = false
    }
}
