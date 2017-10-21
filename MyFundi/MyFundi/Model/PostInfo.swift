//
//  PostInfo.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/21/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
import Firebase

class PostInfo {
    private var _title: String!
    private var _caption: String!
    private var _username: String!
    private var _likes: Int!
    private var _currentDonation: Float!
    private var _donationGoal: Float!
    private var _imageUrl: String!
    private var _profileImgUrl: String!
    private var _dateCreated: String!
    private var _endDate: String!
    private var _postKey: String!
    private var _userKey: String!
    private var _postRef: DatabaseReference!
    private var _userRef: DatabaseReference!
    
    var title: String {
        return _title
    }
    
    var caption: String {
        return _caption
    }
    
    var username: String {
        return _username
    }
    
    var likes: Int {
        return _likes
    }
    
    var currentDonation: Float {
        return _currentDonation
    }
    
    var donationGoal: Float {
        return _donationGoal
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var profileImgUrl: String {
        return _profileImgUrl
    }
    
    var dateCreated: String {
        return _dateCreated
    }
    
    var endDate: String {
        return _endDate
    }
    
    var postKey: String {
        return _postKey
    }
    
    var userKey: String {
        return _userKey
    }
    
    init(title: String, caption: String, username: String, likes: Int, currentDonation: Float, donationGoal: Float, imageUrl: String, profileImgUrl: String, dateCreated: String, endDate: String) {
        
        self._title = title
        self._caption = caption
        self._username = username
        self._likes = likes
        self._currentDonation = currentDonation
        self._donationGoal = donationGoal
        self._imageUrl = imageUrl
        self._profileImgUrl = profileImgUrl
        self._dateCreated = dateCreated
        self._endDate = endDate

    }
    
    init(postKey: String, userKey: String, postData: Dictionary<String, AnyObject>, userData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        self._userKey = userKey
        
        if let title = postData["title"] as? String {
            self._title = title
        }
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let username = userData["name"] as? String {
            self._username = username
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let currentDonation = postData["currentDonation"] as? Float {
            self._currentDonation = currentDonation
        }
        
        if let donationGoal = postData["donationGoal"] as? Float {
            self._donationGoal = donationGoal
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let profileImgUrl = userData["imageUrl"] as? String {
            self._profileImgUrl = profileImgUrl
        }
        
        if let dateCreated = postData["date"] as? String {
            self._dateCreated = dateCreated
        }
        
        if let endDate = postData["endingDate"] as? String {
            self._endDate = endDate
        }
        
        self._postRef = DataService.ds.REF_FUNDRAISERS.child(_postKey)
        self._userRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
    
}
