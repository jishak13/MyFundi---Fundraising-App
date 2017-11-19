//
//  CircleView.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/2/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
//Class to handle the UI element of an Image
class CircleView: UIImageView {
   
    override func layoutSubviews() {
        //Set the Image to a circular image
        layer.cornerRadius = self.frame.width / 2
        //Set the clips to bound to true
        clipsToBounds = true
    }
}
