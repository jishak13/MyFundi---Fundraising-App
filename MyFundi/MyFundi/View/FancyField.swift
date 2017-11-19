//
//  FancyField.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 9/30/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

//Class to handle the UI of a Text Field
class FancyField: UITextField,UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        //set the delegate to itself
        self.delegate = self
        //Give the text field a border
        layer.borderColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        //Set the border width
        layer.borderWidth = 1
        //Give the field a round edge
        layer.cornerRadius = 2.0
    }

    func normalBorder() {
        //set the border back to black
        layer.borderColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        //set the border width to 1
        layer.borderWidth = 1
    }
    func errorBorder(){
        //Set the border color to red
        layer.borderColor = UIColor.red.cgColor
        //set the border width to 1
        layer.borderWidth = 1
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        //Set the bounds to 10 wide and 5 tall
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        //Set the bounds to 10 wide and 5 tall
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Remove the key board
        self.endEditing(true)
        return false
    }
    
}
