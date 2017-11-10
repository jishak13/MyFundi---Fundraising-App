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

//extension UIViewController {
//    func hideKeyboardWhenTappedAroundCreditCardForm() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardfromCredit))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc func dismissKeyboardfromCredit() {
//        view.endEditing(true)
//    }
//}


class CreditCardFormVC: UIViewController, STPPaymentCardTextFieldDelegate {
    
    @IBOutlet weak var creditCardForm: CreditCardFormView!
    
    @IBOutlet weak var firstNameTextField: FancyField!
    
    @IBOutlet weak var zipTextField: FancyField!
    
    let paymentTextField = STPPaymentCardTextField()
    
    var cardNumber: String = ""
    var expireDate: String = ""
    var cvv: String = ""
    var name: String = ""
    var zip: String = ""
    var userID: String = ""
    var user: User!
    var userRef: DatabaseReference!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Set up stripe textfield
        hideKeyboardWhenTappedAround()
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.delegate = self
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        
        view.addSubview(paymentTextField)
        
        
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: creditCardForm.bottomAnchor, constant: 50),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        self.userID = (Auth.auth().currentUser?.uid)!
        print("JOE: \(userID)")
        userRef = DataService.ds.REF_USERS.child(self.userID)
        // Do any additional setup after loading the view.
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
        
        cardNumber = (textField.cardNumber as! String)
        
//
//
//        cvv = (textField.cvc as! String)
        
//        print("CARD NUMBER:\(cardNumber) DATE: \(expireDate) CVC:\(cvv)")
        
    }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingExpiration(expirationYear: textField.expirationYear)
        
        expireDate = "\(textField.expirationMonth)/\(textField.expirationYear)"
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardForm.paymentCardTextFieldDidEndEditingCVC()
        cvv = textField.cvc as! String
//        print("CARD NUMBER:\(cardNumber) DATE: \(expireDate) CVC:\(cvv)")
    }
    
    func validateValues() ->Bool {
       
        var nameIsValid :Bool = false
        var dateIsValid :Bool = false
        var numberIsValid :Bool = false
        var cvvIsValid :Bool = false
        var zipIsValid :Bool = false
        
        let cardArr = Array(cardNumber)
        let dateArr = Array(expireDate)
        
        if firstNameTextField.text == "" {
            firstNameTextField.errorBorder()
            nameIsValid = false
        } else{
            nameIsValid = true
            firstNameTextField.normalBorder()
            if let theName = firstNameTextField.text {
                name = theName
            }
        }
        if cardNumber == "" || cardArr.count != 16  {
            numberIsValid = false
          
        }else{
            numberIsValid = true
        
        }
        if expireDate ==  "" {
            dateIsValid = false
        
        } else {
            dateIsValid = true
          
        }
        if zipTextField.text == "" {
            zipIsValid = false
            zipTextField.errorBorder()
            
        } else {
            zipIsValid = true
            zipTextField.normalBorder()
            if let theZip = zipTextField.text {
                zip = theZip
            }
        }
        if cvv == "" {
            cvvIsValid = false
        
        } else {
            cvvIsValid = true
     
        }
        if zipIsValid, dateIsValid, numberIsValid, nameIsValid,cvvIsValid {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submitPressed(_ sender: Any) {
        if validateValues() {
            let card: Dictionary<String, AnyObject> = [
                "cardName": name as AnyObject,
                "cardNumber": (cardNumber as! NSString).longLongValue as AnyObject,
                "billingZip": (zip as! NSString).longLongValue as AnyObject,
                "cvv": (cvv as! NSString).intValue as AnyObject,
                "expirationDate": expireDate as AnyObject
                
            ]
            
            let firebaseCard = DataService.ds.REF_CARDS.childByAutoId()
            var cardKey = firebaseCard.key
            firebaseCard.setValue(card)
            
            firstNameTextField.text = ""
            zipTextField.text = ""
            
            
            

            UpdateFireBaseUser(cardKey: cardKey)
            self.dismiss(animated: true, completion: nil)
        }else {
            let alertController = UIAlertController(title: "Payment Method Error", message: "Please enter field correctly", preferredStyle: UIAlertControllerStyle.alert)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
