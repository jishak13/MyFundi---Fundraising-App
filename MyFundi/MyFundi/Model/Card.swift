//
//  Card.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/31/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import Foundation
import Firebase

class Card {
    
    private var _cardKey: String
    private var _cardHolderName: String
    private var _cardNumber: Int
    private var _expireDate: String
    private var _cvv: Int
    private var _zipCode: Int
    private var _cardRef: DatabaseReference!
    
    var CardKey: String
    {
        return _cardKey
    }
    
    var CardHolderName: String{
        return _cardHolderName
    }
    var CardNumber: Int {
        return _cardNumber
    }
    
    var ExpireDate: String {
        return _expireDate
    }
    
    var CVV: Int {
        return _cvv
    }
    
    var ZipCode: Int {
        return _cvv
    }
    
    init(cardKey: String, cardData: Dictionary<String,AnyObject>) {
        
        self._cardKey = cardKey
        self._cardHolderName = cardData["cardName"] as? String ?? ""
        self._cardNumber = cardData["cardNumber"] as? Int ?? 0
        self._expireDate = cardData["expirationDate"] as? String ?? ""
        self._cvv = cardData["cvv"] as? Int ?? 0
        self._zipCode = cardData["billingzip"] as? Int ?? 0
        self._cardRef = DataService.ds.REF_CARDS.child(_cardKey)

        
    }
    
    
    
}
