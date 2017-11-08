//
//  Notification.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/7/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
class Notification {
    
    private  var _user: User
    private  var _post: Post
    private  var _type: String
    
    var User: User {
        return _user
    }
    
    var Post: Post {
        return _post
    }
    var NType: String {
        return _type
    }
    
    init(user: User, post: Post, type: String) {
      
            self._user = user
            self._post = post
            self._type = type

    }
    
}
