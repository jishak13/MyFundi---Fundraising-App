//
//  Notification.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/7/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
//Public Class for a Notification Object
class Notification {
    
    //Private Variables/Fields for a Notification Object
    private  var _user: User
    private  var _post: Post
    private  var _type: String
    
    //Public Properties for a Notification
    var User: User {
        return _user
    }
    
    var Post: Post {
        return _post
    }
    var NType: String {
        return _type
    }
    //Initializer for a Notification taking in a User, Post and the Type (Like or Donation)
    init(user: User, post: Post, type: String) {
      
            self._user = user
            self._post = post
            self._type = type

    }
    
}
