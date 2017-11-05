//
//  AddCardVC.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/31/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
class AddCardVC: UIViewController, UITableViewDelegate , UITableViewDataSource{

  
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var firstNameTextBox: FancyField!
    
    @IBOutlet weak var cardNumberTextBox: FancyField!
    
    @IBOutlet weak var expireDateTextBox: FancyField!
    
    @IBOutlet weak var cvvTextBox: FancyField!
    
    @IBOutlet weak var zipTextBox: FancyField!
    
    
    var cards = [Card]()
    var userID: String = ""
    var user: User!
    var userRef: DatabaseReference!
    var methodKeys = [String]()
    var count: Int = 0
    
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submitPressed(_ sender: Any) {
        if validateValues() {
            let card: Dictionary<String, AnyObject> = [
                "cardName": firstNameTextBox.text as AnyObject,
                "cardNumber": (cardNumberTextBox.text as! NSString).longLongValue as AnyObject,
                "billingZip": (zipTextBox.text as! NSString).longLongValue as AnyObject,
                "cvv": (cvvTextBox.text as! NSString).intValue as AnyObject,
                "expirationDate": expireDateTextBox.text as AnyObject
                
            ]
            
            let firebaseCard = DataService.ds.REF_CARDS.childByAutoId()
            var cardKey = firebaseCard.key
            firebaseCard.setValue(card)
            
            firstNameTextBox.text = ""
            cardNumberTextBox.text = ""
            zipTextBox.text = ""
            cvvTextBox.text = ""
            expireDateTextBox.text = ""
            UpdateFireBaseUser(cardKey: cardKey)
        }else {
            let alertController = UIAlertController(title: "Payment Method Error", message: "Please enter the fields noted", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func UpdateFireBaseUser(cardKey: String){
        
        print("JOE!: \(cardKey)")
        print("JOE!: \(self.userID)")
    DataService.ds.REF_USERS.child(self.userID).child("paymentMethods").child(cardKey).setValue(true)
        
        viewDidLoad()
        
    }
    @IBAction func numberPressed(_ sender: Any) {
        let chars = Array(expireDateTextBox.text!)
        if chars.count == 2 {
            expireDateTextBox.text?.append("/")
        }else  if chars.count >= 4{
            expireDateTextBox.text?.append("")
        }
    
      
        
    }
    @IBAction func finishedEditing(_ sender: Any) {
        count = 0
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
                  
                    self.loadPaymentMethods()
                    
                }
              
            }
            self.tableView.reloadData()
            
            
        })
        
        
        
        
    }
    func validateValues() ->Bool {
        var nameIsValid :Bool = false
         var dateIsValid :Bool = false
         var numberIsValid :Bool = false
         var cvvIsValid :Bool = false
         var zipIsValid :Bool = false
        
        let cardArr = Array(cardNumberTextBox.text!)
        let dateArr = Array(expireDateTextBox.text!)
        
        if firstNameTextBox.text == "" {
            firstNameTextBox.errorBorder()
             nameIsValid = false
        } else{
            nameIsValid = true
            firstNameTextBox.normalBorder()
        }
        if cardNumberTextBox.text == "" || cardArr.count != 16  {
            numberIsValid = false
            cardNumberTextBox.errorBorder()
        }else{
            numberIsValid = true
            cardNumberTextBox.normalBorder()
        }
        if expireDateTextBox.text ==  "" || dateArr.count != 5{
            dateIsValid = false
            expireDateTextBox.errorBorder()
        } else {
            dateIsValid = true
            expireDateTextBox.normalBorder()
        }
        if zipTextBox.text == "" {
            zipIsValid = false
            zipTextBox.errorBorder()
        } else {
            zipIsValid = true
            zipTextBox.normalBorder()
        }
        if cvvTextBox.text == "" {
            cvvIsValid = false
            cvvTextBox.errorBorder()
        } else {
            cvvIsValid = true
            cvvTextBox.normalBorder()
        }
        if zipIsValid, dateIsValid, numberIsValid, nameIsValid,cvvIsValid {
            return true
        } else {
            return false
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = cards[indexPath.row]
    
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CardPaymentCell") as? CardPaymentCell {
            

             cell.configureCell(card: card)
                return cell
            }
            else{
                return CardPaymentCell()
            }
         
}
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return cards.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPaymentMethods(){
       
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
                               cards.append(card)
                                
                            }
                        }
                    }
                }
            }
            self.cards = cards
            self.tableView.reloadData()
        })
        
    }

}
