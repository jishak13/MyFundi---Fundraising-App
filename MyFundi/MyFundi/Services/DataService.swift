//
//  DataService.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/2/17.
//  Copyright © 2017 Bachmanity. All rights reserved.



import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // DB references
    private var _REF_BASE = DB_BASE
    private var _REF_FUNDRAISERS = DB_BASE.child("fundraisers")
    private var _REF_DONATIONS = DB_BASE.child("donations")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_CARDS = DB_BASE.child("paymentMethods")
    
    // Storage references
    private var _REF_FUND_IMGS = STORAGE_BASE.child("fundraiser-pics")
    private var _REF_PROF_IMGS = STORAGE_BASE.child("user-pics")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_FUNDRAISERS: DatabaseReference {
        return _REF_FUNDRAISERS
    }
    
    var REF_DONATIONS: DatabaseReference {
        return _REF_DONATIONS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    var REF_CARDS: DatabaseReference {
        return _REF_CARDS
    }
    
    var REF_FUND_IMGS: StorageReference {
        return _REF_FUND_IMGS
    }
    var REF_PROF_IMGS: StorageReference {
        return _REF_PROF_IMGS
    }
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }

}
