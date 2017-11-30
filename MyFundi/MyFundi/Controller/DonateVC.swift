//
//  DonateVC.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/3/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

//Class that handles the Donate View Controller
class DonateVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate,PayPalPaymentDelegate, PayPalFuturePaymentDelegate {

    //variable for the paypal environment
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    //Variable for the Pay pal configuration
    var payPalConfig = PayPalConfiguration() // default
    
    //IBOUTLETS for the controls on the Donate VC
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var raisedLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var donateAmountTextField: FancyField!
    @IBOutlet weak var payPalButton: DetailsPageButton!
    @IBOutlet weak var submitButton: DetailsPageButton!
    @IBOutlet weak var paymentSwitch: UISegmentedControl!
    @IBOutlet weak var cardPicker: UIPickerView!
    
    //Local Variables for the Donate VC
    var post: Post!
    var cards = [Card]()
    var userID: String!
    var userRef: DatabaseReference!
    var methodKeys = [String]()
    var cardPickerData = [String]()
    var currentCard: Card?
    var dateFormatter: DateFormatter!
    var donatingAmount: Double!
    var sender: String!
    let PP: String = "Pay Pal"
    var errorArray = [String]()
    
    //When the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true
        payPalConfig.merchantName = "MyFundi, Inc." // Here you can set the name of your company
        
        // The Url below are Paypal merchant policy
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        //Language settings for pay pal
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        //Address options
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        //Hide the keyboard when the use taps around it
        hideKeyboardWhenTappedAround()
        
        //Instantiate controls on the Donate Page
        titleLabel.text = post?.title
        raisedLabel.text = "$\(post.currentDonation)"
        goalLabel.text = "$\(post.donationGoal)"
        progressView.setProgress(Float((post?.currentDonation)!/(post?.donationGoal)!), animated: true)
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        titleLabel.text = post?.title
        
        //Set card picker  and donation text field delegate and datasource
        self.cardPicker.delegate = self
        self.cardPicker.dataSource = self
        donateAmountTextField.delegate = self
        
        //Get the user ID to set a reference to firebase
        self.userID = (Auth.auth().currentUser?.uid)!
        print("JOE: \(userID)")
        userRef = DataService.ds.REF_USERS.child(self.userID)
        
        //Reset the Method Keys array
        methodKeys = [String]()
        //View this user in Firebase
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //Create a dictionary object of this user
            if let userDict = snapshot.value as? Dictionary<String,AnyObject> {
                //Debug Message
                print ("JOE: USER DICT \(userDict)")
                //If the user has payment methods
                if let methods =  userDict["paymentMethods"] as? [String:AnyObject]  {
                    //For each method
                    for method in methods {
                        //Append the method to the MethodKeys array
                        self.methodKeys.append(method.key)
                        //Debug Message
                        print("JOE: Payment Found for User: \(method.key)")
                    }
                }
            }
        })
        //Call Load Payment Methods
        loadPaymentMethods()
    }
    
    //Function that handles the pay pal interface being canceled
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        //dismiss the payment View Controller
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    //Function that handles the pay pal payment view control
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        //Debug MEssage
        print("PayPal Payment Success !")
        //Dimiss the payment view controller
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            //Add the Pay Pal (1) payment to firebase
            self.addDonationToFirebase(type: 1)
        })
    }
    //Function that handles the future payment being cancled
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
        //Dismiss the payment view controller
        futurePaymentViewController.dismiss(animated: true, completion: nil)
    }
    
    //Function that handles the future payment controller
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        //Debug Message
        print("PayPal Future Payment Authorization Success!")
        // send authorization to your server to get refresh token.
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    //Function that hides keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Set editing to false
        self.view.endEditing(true)
        // return false
        return false
    }
   
    //function that adds a donation to firebase
    func addDonationToFirebase(type:Int) {
        //Create a Donation Dictionary object
        let donation: Dictionary<String, AnyObject> = [
            "donationAmount": (donateAmountTextField.text as! NSString).floatValue as AnyObject,
            "donationDate": dateFormatter.string(from: Date()) as AnyObject,
            "fundraiser": post?.postKey as AnyObject
        ]

        //Create a child in the donations table for this new donation
        let firebaseDonation = DataService.ds.REF_DONATIONS.childByAutoId()
        //Get the key of the new child
        var donKey = firebaseDonation.key
        //Set the donation key's value to the new donation
        firebaseDonation.setValue(donation)

        //If this is a card payment
        if type == 0 {
            //Debug Message
           print("\(userID)")
            //Add this donation to the user with the value being the card number
            DataService.ds.REF_USERS.child(self.userID).child("donations").child(donKey).setValue(currentCard?.CardKey)
        }
        else {
            //This is pay pal donation
            //Add the string pay pal to the value
            DataService.ds.REF_USERS.child(self.userID).child("donations").child(donKey).setValue(PP)
        }

        //Reset the new Amount
        let newAmount = ( (post?.currentDonation)! + self.donatingAmount)
        //Debug Message
        print("JOE: \(newAmount)")
        //Update the Firebase Fundraiser with the new amount
        DataService.ds.REF_FUNDRAISERS.child((post?.postKey)!).updateChildValues(["currentDonation": newAmount])
        //Update the progress view
        progressView.setProgress(Float(newAmount/(post?.donationGoal)!), animated: true)
        //Reset the raised amount label
        raisedLabel.text = "$\(newAmount)"
        //Reste the donation amount text field
        donateAmountTextField.text = nil
        
        
    }
    
    func successMessage() {
        let alertController = UIAlertController(title: "Successful Donation", message: "You have successfully donated to this campaign. Go to your My Fundi Page and view your Donations to confirm.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    //function that handles back being pressed
    @IBAction func backPressed(_ sender: Any) {
        //Dismiss the View Controller
        dismiss(animated: true, completion: nil)
    }
    //Function that handles Validating the Controls
    func validateFields() -> Bool {
        //Instantiate a new error array
        errorArray = [String]()
        //If the amount is  a Float Value
        if case let amount = (self.donateAmountTextField.text as! NSString).doubleValue {
            //If the amount is greater than 0
            if amount > 0 {
                //Valid input border
                donateAmountTextField.normalBorder()
                //Set the donating amount variable to amount
                self.donatingAmount = amount
               
            }
            //If ammount is less than or equal to 0
            if amount <= 0{
                //Invalid input border
                donateAmountTextField.errorBorder()
                //Append the error message saying its incorrect
                errorArray.append("-Donation must be numeric\n-Donation must be at least $1")
                
            }
        }
        //If there are no values in the error array
        if errorArray.count == 0 {
            //Return true = Valid
            return true
        }
        else{
            //initialize an error string
            var errorMessage: String = ""
            //For each error in the Error Array
            for errs in errorArray {
                //Append it to the Error message
                errorMessage += "\(errs)"
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
    //Function that handles donate now pressed
    @IBAction func donateNowPressed(_ sender: Any) {
        
        //If the fields are valid
        if validateFields() {

            //If current card is not nill
            if currentCard != nil {
                
                //Show a confirmation message about donation amount
                let dialogMessage = UIAlertController(title: "Donation Confirmation", message: "Are you sure you want to Donate this amount?", preferredStyle: UIAlertControllerStyle.alert)
                dialogMessage.addAction(UIAlertAction(title: "Proceed", style: .default,handler: {UIAlertAction in
                    
                   
                     //Add the donation to firebase with a Card(0)
                    self.addDonationToFirebase(type: 0)
                    //Present a Success Message
                    self.successMessage()
                    
                }))
                
                //Cancels action
                dialogMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: {UIAlertAction in
                    
                    
                    
                    
//                    self.dismiss(animated: true, completion: nil)
                    
                }))
                self.present(dialogMessage, animated: true, completion: nil)
                
                
                
               
            } else{
                //Present the error message saying the card is missing
                let alertController = UIAlertController(title: "Card Missing", message: "Please select a payment Method from the list. If you do not see any payment methods, navigate back to settings and Add a Card.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }

        }
        
        
      
    }
    
    
    //Function that handles the payment methods switching
    @IBAction func paymentMethodSwitched(_ sender: Any) {
        //If its on the first option
        if paymentSwitch.selectedSegmentIndex == 0 {
            //Initialize the cards array
            self.cards = [Card]()
            //Load the payments
            self.loadPaymentMethods()
            //Unhide the card picker
            cardPicker.isHidden = false
            //Hide the paypal button
            payPalButton.isHidden = true
            //Unhide the submit button
            submitButton.isHidden = false
            
        }else{//If its the second option
            //Hide the card picker
            cardPicker.isHidden = true
            //Unhide the pay pal button
            payPalButton.isHidden = false
            //Hide the submit button
            submitButton.isHidden = true
        }
    }
    
    //Function that handles the pay pal button pressed
    @IBAction func payPalPressed(_ sender: Any) {
        
        //If the fields are valid
         if validateFields() {
            //Set the item for pay pal
            let item1 = PayPalItem(name: "Donation Amount", withQuantity: 1, withPrice: NSDecimalNumber(string: donateAmountTextField.text), withCurrency: "USD", withSku: "Hip-0001")
            
            //Set items  to item 1
            let items = [item1]
            //Get the subtotal from paypal
            let subtotal = PayPalItem.totalPrice(forItems: items)
            
            // Optional: include payment details
            let shipping = NSDecimalNumber(string: "0.00")
            let tax = NSDecimalNumber(string: "0.00")
            let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
            
            //Get the total from paypal
            let total = subtotal.adding(shipping).adding(tax)
            //Get the payment details
            let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Donation", intent: .sale)
            
            //Set the payment items and details
            payment.items = items
            payment.paymentDetails = paymentDetails
            
            //Check if the paymentis processable
            if (payment.processable) {
                //Present payment details in the payment view controller
                let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
                present(paymentViewController!, animated: true, completion: nil)
            }
            else {
                // This particular payment will always be processable. If, for
                // example, the amount was negative or the shortDescription was
                // empty, this payment wouldn't be processable, and you'd want
                // to handle that here.
                print("Payment not processalbe: \(payment)")
            }
         }else{
            //If the amount is null
            let alertController = UIAlertController(title: "Amount Missing", message: "Amount is missing. Please add an amount before continuing.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    //Function that handles validating the dates on each card
    func validateCard(row: Int){
        //Get the current Cards expire date
        let cardDate = self.currentCard?.ExpireDate
        //Put the expirate date into an array of characters
        let chars = Array(cardDate!)
        //Debug Message
        print("JOE CHARS: \(chars)")
        //Initialize a new date string
        var newDate: String = ""
        //If the array contains 5 characters
        if chars.count == 5{
            //Set the new date to 11/14 =Example
              newDate = "\(chars[0])\(chars[1])-01-20\(chars[3])\(chars[4])"
        }else{
            //else se the new date to 09/14 = example
              newDate = "0\(chars[0])-01-20\(chars[2])\(chars[3])"
        }
        
        //Debug Message
        print("JOE: THE DATE \(newDate)")
        //Format the date
       let formattedExpire = dateFormatter.date(from: newDate)
        //If the date is before today's date
        if formattedExpire! < Date() {
            //Present that the card has expired
            let alertController = UIAlertController(title: "Card Has Expired", message: "Please select an card that has not expired.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            //remove the card from the card picker
            cardPickerData.remove(at: row)
            //remove the card from the cards array
            cards.remove(at: row)
            //reload the card picker
            self.cardPicker.reloadAllComponents()
        }
        else{
            
        }
    }
    
    //Function that handles the user selecting a card
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //If its not the first row
        if  row != 0{
            //Set the current card to cards array -1
            //We use the minus one to account for the first item in the card picker being
            //The Select a Card option
            currentCard  = cards[row-1]
            //Validate the Card
        self.validateCard(row: row)
        }
        else{
            currentCard = nil
        }
    }
    
    //Load the payment methods from firebase
    func loadPaymentMethods(){
        //Instantiate the cards
        self.cards = [Card]()
        //Instantiate the Card Picker Data
        self.cardPickerData = [String]()
        //append the please select a payment card to the card picker data
        cardPickerData.append("Please select a Payment Card")
        //Reference the payment methods from Firebase
        DataService.ds.REF_CARDS.observe(.value, with: { (snapshot) in
            //Instantiate a local cards array
            var cards = [Card]()
            //Create a snapshot
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                //For each Payment Card
                for snap in snapshot {
                    //Debug Mesage
                    print("JOE: \(snap.value)")
                    //For each key in the method keys
                    for methodKey in self.methodKeys{
                        //If the snap key is in the method key
                        if snap.key == methodKey{
                            //Create a dictionary object
                            if let cardDict = snap.value as? Dictionary<String, AnyObject> {
                                //Get the key and create a card ojbect
                                let key = snap.key
                                let  card = Card(cardKey: key, cardData: cardDict)
                                //Get a character array of the card number
                                let chars = Array("\(card.CardNumber)")
                                //Set the card number, hiding the first 12 characters
                                let cardNum = "xxxx-xxxx-xxxx-\(chars[12])\(chars[13])\(chars[14])\(chars[15])"
                                //Set the card date
                                let cardDate = card.ExpireDate
                                //Debug Message
                                print("JOE!@: \(cardNum)   \(cardDate)")
                                //append the data to the card picker
                                self.cardPickerData.append("\(cardNum)   \(cardDate)")
                                //Apend the data to the cards array
                                cards.append(card)
                                
                            }
                        }
                    }
                }
            }
            //Set the VC cards array
            self.cards = cards
            //Reload the card picker
          self.cardPicker.reloadAllComponents()
       
        })
        
    }
    //Function that sets the number of components in the card picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //return 1
        return 1
    }
    //function that sets the number of rown in the card picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //Return the total cards in the card picker
        return self.cardPickerData.count
    }
    //function that gets the card into the card picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return the card at this row
        return self.cardPickerData[row]
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let computationString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        // Take number of digits present after the decimal point.
        let arrayOfSubStrings = computationString.components(separatedBy: ".")
        
        if arrayOfSubStrings.count == 1 && computationString.characters.count > MAX_BEFORE_DECIMAL_DIGITS {
            return false
        } else if arrayOfSubStrings.count == 2 {
            let stringPostDecimal = arrayOfSubStrings[1]
            return stringPostDecimal.characters.count <= MAX_AFTER_DECIMAL_DIGITS
        }
        
        return true
    }
    

   

}
