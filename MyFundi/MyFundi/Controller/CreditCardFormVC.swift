//
//  StripeTestVC.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 11/5/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//
// they testing this 


import UIKit
import Stripe
import CreditCardForm
import Firebase

//Class for the Credit Card Form VC
class CreditCardFormVC: UIViewController, STPPaymentCardTextFieldDelegate {
    
    //IBOUTLETS for the Credit Card Form
    @IBOutlet weak var creditCardForm: CreditCardFormView!
    @IBOutlet weak var firstNameTextField: FancyField!
    @IBOutlet weak var zipTextField: FancyField!
    
    //Local Variables for this VC
    let paymentTextField = STPPaymentCardTextField()
    var cardNumber: String = ""
    var expireDate: String = ""
    var cvv: String = ""
    var name: String = ""
    var zip: String = ""
    var userID: String = ""
    var user: User!
    var userRef: DatabaseReference!
    
 
    //When the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Set up stripe textfield
        hideKeyboardWhenTappedAround()
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.delegate = self
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        
        //Set up the stripe card
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        //Add the stripe fields to the view
        view.addSubview(paymentTextField)
        
        //Set constraints for the Stripe API
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: creditCardForm.bottomAnchor, constant: 50),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        //Get the current user ID
        self.userID = (Auth.auth().currentUser?.uid)!
        //Debug Message
        print("JOE: \(userID)")
        //Get a reference to the User in Firebase
        userRef = DataService.ds.REF_USERS.child(self.userID)
        // Do any additional setup after loading the view.
    }
    //function that handles the  card text field changing
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
        //Set the card number when the field changes
        cardNumber = (textField.cardNumber as! String)
    }
    //function that handles the card number  text field ending editing
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingExpiration(expirationYear: textField.expirationYear)
        //Set the expire date
        expireDate = "\(textField.expirationMonth)/\(textField.expirationYear)"
    }
    //Function that handles the CVC editing
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingCVC()
         //Set the CVC
        if textField.cvc as! String != nil {
             cvv = textField.cvc as! String
        }
       
    }
    
    func validateValues() ->Bool {
       
       //Local Variables for error handling
        var errorArray = [String]()
        let cardArr = Array(cardNumber)
        let dateArr = Array(expireDate)
        
        //Test if the name is invalid
        if firstNameTextField.text == "" {
            firstNameTextField.errorBorder()
            errorArray.append("Enter a name for the card holder")
        } else{
            firstNameTextField.normalBorder()
            //get the name
            if let theName = firstNameTextField.text {
                name = theName
            }
        }
        //Test if the card number is invalid
        if cardNumber == "" || cardArr.count != 16  {
            errorArray.append("Invalid Card Number")
          
        }
        //Test if the expire date is invalid
        if expireDate ==  "" {
            errorArray.append("Invalid Expiration Date")
    
        
        }
        //test if the zip is invalid
        if zipTextField.text == "" {
            errorArray.append("Invalid Zip Code")
            zipTextField.errorBorder()
            
        } else {

            zipTextField.normalBorder()
            //Set the Zip
            if let theZip = zipTextField.text {
                zip = theZip
            }
        }
        //Test if the CVV is inavlid
        if cvv == "" {
      
            errorArray.append("Invalid CVV")
        
        }
        
        //If the error array has 0 elements
        if errorArray.count == 0 {
            //Return True because the fields are VALID
            return true
        } else{//Else
            //initialize an error string
            var errorMessage: String = ""
            //For each error in the Error Array
            for errs in errorArray {
                //Append it to the Error message
                errorMessage += "\(errs)\n"
            }
            
            //Set the Alert controller with the error message
            let alertController = UIAlertController(title: "Fields Are Missing or Incorrect", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            //Present the  Alert
            self.present(alertController, animated: true, completion: nil)
            //Return False because at least one field is invalid
            return false
        }
    }
    //When back is pressed
    @IBAction func backPressed(_ sender: Any) {
        //dismiss the VC
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submitPressed(_ sender: Any) {
        //If the fields are valid
        if validateValues() {
            //Create a card dictionary object for firebase
            let card: Dictionary<String, AnyObject> = [
                "cardName": name as AnyObject,
                "cardNumber": (cardNumber as! NSString).longLongValue as AnyObject,
                "billingZip": (zip as! NSString).longLongValue as AnyObject,
                "cvv": (cvv as! NSString).intValue as AnyObject,
                "expirationDate": expireDate as AnyObject
                
            ]
            //Create a new card in Firebase
            let firebaseCard = DataService.ds.REF_CARDS.childByAutoId()
            //get eh key
            var cardKey = firebaseCard.key
            //Set the value of this firebase card to the card dictionary
            firebaseCard.setValue(card)
            //Reset the values
            firstNameTextField.text = ""
            zipTextField.text = ""
            //Update the firebase user
            UpdateFireBaseUser(cardKey: cardKey)
            let alertController = UIAlertController(title: "Payment Method Added Successfully", message: "Your payment method was added successfully. You will now see it when trying to donate to a campaign. ", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: {
                _ in self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        
        
    }
    //Function to update the firebase user
    func UpdateFireBaseUser(cardKey: String){
        //Debug messages
        print("JOE!: \(cardKey)")
        print("JOE!: \(self.userID)")
        //Add a new card for this user
        DataService.ds.REF_USERS.child(self.userID).child("paymentMethods").child(cardKey).setValue(true)
    }
}
