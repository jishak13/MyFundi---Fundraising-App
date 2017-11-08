//
//  DonateVC.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/3/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class DonateVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

   
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var raisedLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var donateAmountTextField: FancyField!
    
    
    var post: Post!
    
    @IBOutlet weak var cardPicker: UIPickerView!
    var cards = [Card]()
    var userID: String = ""
    var userRef: DatabaseReference!
    var methodKeys = [String]()
    var cardPickerData = [String]()
//    var amountCount : Int
    var currentCard: Card?
       var dateFormatter: DateFormatter!
    var donatingAmount: Float!
    var sender: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = post?.title
        raisedLabel.text = "$\(post.currentDonation)"
        goalLabel.text = "$\(post.donationGoal)"
        progressView.setProgress((post?.currentDonation)!/(post?.donationGoal)!, animated: true)
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        titleLabel.text = post?.title
        self.cardPicker.delegate = self
        self.cardPicker.dataSource = self
        
        
        
        donateAmountTextField.delegate = self
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        tap.cancelsTouchesInView = false
//
//        view.addGestureRecognizer(tap)

       
        self.userID = (Auth.auth().currentUser?.uid)!
        print("JOE: \(userID)")
        userRef = DataService.ds.REF_USERS.child(self.userID)
        
        methodKeys = [String]()
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? Dictionary<String,AnyObject> {
                print ("JOE: USER DICT \(userDict)")
                if let methods =  userDict["paymentMethods"] as? [String:AnyObject]  {
                    for method in methods {
                        self.methodKeys.append(method.key)
                        print("JOE: Payment Found for User: \(method.key)")
                    }
                    
                    
                }
                
            }
         
            
            
        })
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
   
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func validateFields() -> Bool {
        
        if case let amount = (self.donateAmountTextField.text as! NSString).floatValue{
            if amount > 0 {
                donateAmountTextField.normalBorder()
                self.donatingAmount = amount
                return true
            }
            else {
                donateAmountTextField.errorBorder()
                return false
            }
        }else{
            donateAmountTextField.errorBorder()
            return false
        }
    }
    @IBAction func donateNowPressed(_ sender: Any) {
        
        if validateFields() {
            let donation: Dictionary<String, AnyObject> = [
                "donationAmount": (donateAmountTextField.text as! NSString).floatValue as AnyObject,
                "donationDate": dateFormatter.string(from: Date()) as AnyObject,
                "fundraiser": post?.postKey as AnyObject
            ]
          
            let firebaseDonation = DataService.ds.REF_DONATIONS.childByAutoId()
            var donKey = firebaseDonation.key
            firebaseDonation.setValue(donation)
        DataService.ds.REF_USERS.child(userID).child("donations").child(donKey).setValue(currentCard?.CardKey)
            
            let newAmount = ( (post?.currentDonation)! + self.donatingAmount)
            print("JOE: \(newAmount)")
            DataService.ds.REF_FUNDRAISERS.child((post?.postKey)!).updateChildValues(["currentDonation": newAmount])
            progressView.setProgress(newAmount/(post?.donationGoal)!, animated: true)
            raisedLabel.text = "$\(newAmount)"
            donateAmountTextField.text = nil
            cardPicker.isHidden = true
        }
        else{
            
        }
    }
    
    func validateCard(){
        var cardDate = self.currentCard?.ExpireDate
        var chars = Array(cardDate!)
        var newDate = "\(chars[0])\(chars[1])-01-20\(chars[3])\(chars[4])"
        print("JOE: THE DATE \(newDate)")
       var formattedExpire = dateFormatter.date(from: newDate)
        if formattedExpire! <= Date() {
            let alertController = UIAlertController(title: "Card Has Expires", message: "Please select an card that has not expired.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentCard  = cards[row]
        self.validateCard()
        
    }
    @IBAction func chooseMethodPressed(_ sender: Any) {
        
        self.cards = [Card]()
        self.loadPaymentMethods()
        print("JOE: \(self.cards.count)")
        self.cardPicker.isHidden = false
        
    }
    
    
    @IBAction func amountValueChanged(_ sender: Any) {

        
        
    }
    

    
    func loadPaymentMethods(){
        self.cards = [Card]()
        self.cardPickerData = [String]()
        DataService.ds.REF_CARDS.observe(.value, with: { (snapshot) in
            var cards = [Card]()
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("JOE: \(snap.value)")
                    for methodKey in self.methodKeys{
                        if snap.key == methodKey{
                            if let cardDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let  card = Card(cardKey: key, cardData: cardDict)
                                let chars = Array("\(card.CardNumber)")
                                //        cardNameLabel.text  = card.CardHolderName
                                let cardNum = "xxxx-xxxx-xxxx-\(chars[12])\(chars[13])\(chars[14])\(chars[15])"
                                let cardDate = card.ExpireDate
                                print("JOE!@: \(cardNum)   \(cardDate)")
                                self.cardPickerData.append("\(cardNum)   \(cardDate)")
                                cards.append(card)
                                
                            }
                        }
                    }
                }
            }
            self.cards = cards
          self.cardPicker.reloadAllComponents()
       
        })
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.cardPickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.cardPickerData[row]
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
