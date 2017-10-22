//
//  Error.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/22/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class Error: UIView {


    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func errorBorder(object: AnyObject){
        object.layer.borderColor = UIColor.red as! CGColor
    }
}
