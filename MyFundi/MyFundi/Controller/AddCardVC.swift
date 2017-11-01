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
    
    @IBOutlet weak var firstNameTextBox: UITextField!
    
    @IBOutlet weak var cardNumberTextBox: UITextField!
    
    @IBOutlet weak var expireDateTextBox: UITextField!
    
    @IBOutlet weak var cvvTextBox: UITextField!
    
    @IBOutlet weak var zipTextBox: UITextField!
    
    
    var cards = [Card]()
    var userID: String = ""
    var user: User!
    var userRef: DatabaseReference!
    var methodKeys = [String]()
    var count: Int = 0
    @IBAction func submitPressed(_ sender: Any) {
    }
    @IBAction func numberPressed(_ sender: Any) {
        if count == 1{
            expireDateTextBox.text?.append("/")
        }
        count = count + 1
    }
    @IBAction func numberEntered(_ sender: Any) {
        if count == 1{
            expireDateTextBox.text?.append("/")
        }
        count = count + 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        userID = (Auth.auth().currentUser?.uid)!
        userRef = DataService.ds.REF_USERS.child(self.userID)

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
        self.cards = [Card]()
        DataService.ds.REF_CARDS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    print("JOE: \(snap.value)")
                    for methodKey in self.methodKeys{
                        if snap.key == methodKey{
                            if let cardDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let  card = Card(cardKey: key, cardData: cardDict)
                                self.cards.append(card)
                                
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

}
