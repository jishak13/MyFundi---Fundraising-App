//
//  FancyTextView.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/22/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

//Class to handle the TextView UI Element
class FancyTextView: UITextView {

   
    override func awakeFromNib() {
        super.awakeFromNib()
        //Set the border color to grey
        layer.borderColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        //Set the border width to 1
        layer.borderWidth = 1
        //Give a slightly rounded corner to the text view
        layer.cornerRadius = 2.0
    }
    //Method to set the border back to black
    func normalBorder() {
        //Valid
        layer.borderColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        layer.borderWidth = 1
    }
    //Method to set the borde rbak to red
    func errorBorder(){
        //Error
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
    }

}
