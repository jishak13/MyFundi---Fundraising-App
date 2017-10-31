//
//  User.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/15/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    private var _userKey: String!
    private var _fundraiserKeys: [String] = [""]
    private var _name: String!
    private var _imageUrl: String!
    private var _donations: [String] = [""]
    private var _paymentMethods: [String] = [""]
    private var _likes: [String]! = [""]
    private var _userRef: DatabaseReference!

    var UserKey: String{
        return _userKey
    }
    var FundraiserKeys: [String]{
        return _fundraiserKeys
    }
    var Name: String{
        return _name
    }
    
    var ImageUrl: String{
        return _imageUrl
    }
    var Donations : [String] {
        return _donations
    }
    var PaymentMethods: [String] {
        return _paymentMethods
    }
    var Likes: [String] {
        return _likes
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        self._imageUrl = userData["imageUrl"] as? String ?? ""
        self._name =  userData["name"] as? String ?? ""
        

        if let fundraisers = userData["fundraisers"] as? [String:AnyObject] {
            for funds in fundraisers {
            self._fundraiserKeys.append(funds.key)
            }
            
        }
        
        if let donations = userData["donations"] as? [String:AnyObject] {
            for donat in donations {
                self._donations.append(donat.key)
            }
            
        }
        
        if let likes = userData["likes"] as? [String:AnyObject] {
            for like in likes {
               self._likes.append(like.key)
            }
            
        }
        if let payments = userData["paymentMethods"] as? [String:AnyObject] {
            for method in payments {
               self._paymentMethods.append(method.key)
            }
            
        }
        
        self._userRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
}
