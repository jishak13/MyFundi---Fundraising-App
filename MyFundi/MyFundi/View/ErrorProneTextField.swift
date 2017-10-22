//
//  ErrorProneTextField.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/22/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class ErrorProneTextField: UITextField {

    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var goalText: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(displayP3Red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 2.0
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 5)
    }
    
    func titleError(){
        
        titleText.layer.borderColor = UIColor.red as! CGColor
        titleText.layer.borderWidth = 1.0
    }
    func noTitleError() {
        titleText.layer.borderColor = UIColor.black as! CGColor

    }
    
    func goalError(){
        
        goalText.layer.borderColor = UIColor.red as! CGColor
        goalText.layer.borderWidth = 1.0
    }
    
    func noGoalError() {
        goalText.layer.borderColor = UIColor.black as! CGColor

    }
}
