//
//  FancyView.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 9/30/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

//Class to handle the UI of a View 
class FancyView: UIView {

    //When the control loads
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Give a shadow
        layer.shadowColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        //Set an 80% opacity
        layer.shadowOpacity = 0.8
        //round edges for the shadow
        layer.shadowRadius = 5.0
        //slight Offset
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        //Round edges for the control
        layer.cornerRadius = 2.0
    }

}
