//
//  Post.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/2/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
import Firebase

//Public class for a Post Object
class Post {
    //Private Variables/Fields for a post
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _currentDonation: Double!
    private var _donationGoal: Double!
    private var _title: String!
    private var _startDate: String!
    private var _endDate: String!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    
    //Public Properties for a Post
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var currentDonation: Double {
        return _currentDonation
    }
    
    var donationGoal: Double {
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
    
    //Initializer for a Post taking in all fields/variables
    init(caption: String, imageUrl: String, likes: Int, currentDonation: Double, donationGoal: Double, title: String,startDate:String,endDate:String) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._currentDonation = currentDonation
        self._donationGoal = donationGoal
        self._title = title
        self._startDate = startDate
        self._endDate = endDate
    }
    //Initializer for a Post taking in a Post Dictionary from Firebase, and post ID
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
        
        if let currentDonation = postData["currentDonation"] as? Double {
            self._currentDonation = currentDonation
        }
        
        if let donationGoal = postData["donationGoal"] as? Double {
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
    //Function to adjust the likes for a Post in firebase
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes =  _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
        
    }
    
}
