//
//  ErrorProneDatePicker.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/22/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class ErrorProneDatePicker: UIDatePicker {

    @IBOutlet weak var endDonationDate: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func endDateError(){
        endDonationDate.layer.borderColor = UIColor.red as! CGColor
    }
    
    func noDateError(){
         endDonationDate.layer.borderColor = UIColor.black as! CGColor
    }

}
