//
//  DonateVC.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/3/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
class DonateVC: UIViewController, PayPalPaymentDelegate, PayPalFuturePaymentDelegate{

    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var payPalConfig = PayPalConfiguration() // default
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var raisedLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var donateAmountTextField: FancyField!
    
    
    var post: Post!
    
   
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
        
        // Do any additional setup after loading the view.
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true
        payPalConfig.merchantName = "MyFundi, Inc." // Here you can set the name of your company
        
        // The Url below are Paypal merchant policy
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        
        titleLabel.text = post?.title
        raisedLabel.text = "$\(post.currentDonation)"
        goalLabel.text = "$\(post.donationGoal)"
        progressView.setProgress((post?.currentDonation)!/(post?.donationGoal)!, animated: true)
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        titleLabel.text = post?.title
       
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: environment)
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
    
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
        })
    }
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
        futurePaymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        print("PayPal Future Payment Authorization Success!")
        // send authorization to your server to get refresh token.
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
        })
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
    
    @IBAction func chooseMethodPressed(_ sender: Any) {
    
        // These are just some example items, adjust them if you want
        // Sku should be the item id
        let item1 = PayPalItem(name: "Donation Amount", withQuantity: 1, withPrice: NSDecimalNumber(string: donateAmountTextField.text), withCurrency: "USD", withSku: "Hip-0001")
        /*let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "Hip-00066")
         let item3 = PayPalItem(name: "Long-sleeve plaid shirt (mustache not included)", withQuantity: 1, withPrice: NSDecimalNumber(string: "37.99"), withCurrency: "USD", withSku: "Hip-00291")
         */
        
        let items = [item1]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Donation", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
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
        /*
        self.cards = [Card]()
        self.loadPaymentMethods()
        print("JOE: \(self.cards.count)")
        self.cardPicker.isHidden = false
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
