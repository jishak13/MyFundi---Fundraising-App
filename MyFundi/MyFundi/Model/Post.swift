//
//  Post.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/2/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _currentDonation: Float!
    private var _donationGoal: Float!
    private var _title: String!
    private var _startDate: String!
    private var _endDate: String!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
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
    
    var title: String {
        return _title
    }
    
    var postKey: String {
        return _postKey
    }
    var StartDate: String {
        return _startDate
    }
    
    var EndDate: String {
        return _endDate
    }
    
    init(caption: String, imageUrl: String, likes: Int, currentDonation: Float, donationGoal: Float, title: String,startDate:String,endDate:String) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._currentDonation = currentDonation
        self._donationGoal = donationGoal
        self._title = title
        self._startDate = startDate
        self._endDate = endDate
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
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
        
        if let title = postData["title"] as? String {
            self._title = title
        }
        if let startDate = postData["date"] as? String {
            self._startDate = startDate
        }
        if let endDate = postData["expirationDate"] as? String {
            self._endDate = endDate
        }
        _postRef = DataService.ds.REF_FUNDRAISERS.child(_postKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes =  _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
        
    }
    
}
