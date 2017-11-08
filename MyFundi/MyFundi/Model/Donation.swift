//
//  Donations.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/27/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
import Firebase
class Donation {
    
    private var _donationkey: String!
    private var _donationAmount: Double!
    private var _fundriaserKey: String!
    private var _donationDate: String!
    
    private var _donationRef: DatabaseReference!
    
    var DonationKey: String{
        return _donationkey
    }
    
    var DonationAmount: Double {
        return _donationAmount
    }
    var FundraiserKey: String {
        return _fundriaserKey
    }
    var DonationDate: String {
        return _donationDate
    }
    
    init(donationKey: String, donationDict: Dictionary<String, AnyObject> ){
        self._donationkey = donationKey
        
        if let donationAmount = donationDict["donationAmount"] as? Double {
            _donationAmount = donationAmount
        }
        if let fundKey = donationDict["fundraiser"] as? String {
            _fundriaserKey = fundKey
        }
        if let donateDate = donationDict["donationDate"] as? String {
            _donationDate    = donateDate
        }
        self._donationRef = DataService.ds.REF_DONATIONS.child(self._donationkey)
    }
    
}
