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
    private var _fundraiserKeys: [String]!
    private var _name: String!
    private var _imageUrl: String!
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
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let fundraiserKeys = userData["fundraisers"] as? [String] {
            self._fundraiserKeys = fundraiserKeys
        }
        if let imageUrl = userData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        if let name = userData["name"] as? String {
            self._name = name
        }
        self._userRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
}
