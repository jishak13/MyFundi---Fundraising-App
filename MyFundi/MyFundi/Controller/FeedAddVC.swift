//
//  FeedAddVC.swift
//  MyFundi
//
//  Created by Joseph Ishak on 10/15/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

//Extension Class/ Method that enables the user to click outside the key board and hide the keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //Function that dismisses the keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//Public Class for the Feed Add Vc (Posting a Campaign)
class FeedAddVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UITextFieldDelegate {
    
    //Private IBOUTLETS/ Controls
    @IBOutlet weak var TitleTxt: FancyField!
    @IBOutlet weak var ImageChoose: UIImageView!
    @IBOutlet weak var DescriptionTxt: FancyTextView!
    @IBOutlet weak var NumOfRequest: FancyField!
    @IBOutlet weak var ExpDatePicker: UIDatePicker!
    @IBOutlet weak var ExpirationDate: FancyField!
    
    
    //Private Variables
    var userID: String = ""
    var errors = [String]()
    var posts = [Post]()
    let currDate = Date()
    var stringExpiration: String!
    var dateFormatter: DateFormatter!
    static var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    
    
    //When the View loads . . .
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the User Key from Firebase Authentication
        userID = (Auth.auth().currentUser?.uid)!
        
        //Enables this view controller to hide the keyboard when tapped around
        self.hideKeyboardWhenTappedAround()
        
        //Initialize the Date Formatter to save dates in the format Ex. 09-12-1992
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        
        //Sets the Text Box Delegates to this view controller
        self.TitleTxt.delegate = self
        self.NumOfRequest.delegate = self
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Method that handles the User Logging Out
    @IBAction func signOutTappedPost(_ sender: AnyObject) {
        //Set the Key Chain
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        //Debug Message
        print("KHALID: ID removed from keychain \(keychainResult)")
        //Try to sign out
        try! Auth.auth().signOut()
        //Go back to the sign in page
        performSegue(withIdentifier: "goToSignInFromPost", sender: nil)
    }
    
    //Method that enables the user to hit the return key and Exit the Keyboard on the screen
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Method to open the Camera
    @IBAction func openCameraButton(sender: AnyObject) {
        //If the user has allowed the application to use their camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //Initialize an image picker
            let imagePicker = UIImagePickerController()
            //Set the image picker attributes
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            //Present the image picker to the user
            self.present(imagePicker, animated: true, completion: nil)
            //Debug Message
            print("Khalid: Open camera")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       //If an image has been selected
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
           //Set the content mode of the photo chosen to Scale To Fit
            ImageChoose.contentMode = .scaleToFill
            //Set the image chosen to the Image Chose Control on the View Controller
            ImageChoose.image = selectedImage
        }
        //Discmiss the picker
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //Function to handle the Upload Image from Gallery
    @IBAction func editImageTapped(_ sender: Any) {
        //If the user has allowed the application to use their library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
           //Initialize an image picker
            let imagePicker = UIImagePickerController()
            //Set the image picker attributes
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            //Present the image picker to the View Controller
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //Function that Validates the Fields when a user tries to enter a Campaign
    func validateFields() -> Bool {
        //Initialize the Error Array
        errors = [String]()
        //Intiailize the string version of the expiration date
        stringExpiration = dateFormatter.string(from: ExpDatePicker.date)
     
        ///The Following Statements validate each control
        ///If the control is invalid the border of the control will turn red,
            ///The appropriate error message will be appended to the Error Array
        ///If the Controls are valid, the  normal border property will be set
        if TitleTxt.text == "" {
            TitleTxt.errorBorder()
            errors.append("Campaign must have a Title")
        }
        else {
            TitleTxt.normalBorder()
        }
        
        if DescriptionTxt.text == "" {
            DescriptionTxt.errorBorder()
              errors.append("Campaign must have a short Description")
        }
        else {
            DescriptionTxt.normalBorder()
        }
        if NumOfRequest.text == "" ||  (NumOfRequest.text as! NSString).floatValue <= 0{
            NumOfRequest.errorBorder()
              errors.append("Campaign must have an Amount to be Raised in a numerical format.")
        }
        else {
            NumOfRequest.normalBorder()
        }
        if ImageChoose.image == nil {
            errors.append("Campaign must have an Image")
            }
        //If the error array has 0 elements
        if errors.count == 0 {
            //Return True because the fields are VALID
            return true
        } else{//Else
            //initialize an error string
            var errorMessage: String = ""
            //For each error in the Error Array
            for errs in errors {
                //Append it to the Error message
                errorMessage += "\(errs)\n"
            }
            
            //Set the Alert controller with the error message
            let alertController = UIAlertController(title: "Fields Are Missing", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            //Present the  Alert
            self.present(alertController, animated: true, completion: nil)
            //Return False because at least one field is invalid
            return false
        }
    }
  
    
    
    //Method that handles the post button being tapped
    @IBAction func PostBtnTapped(_ sender: UIButton) {
        //If the fields are not valie
        if(self.validateFields()) {
            
            //Set a temporary image to the image in the Image Choose Control
            let img = ImageChoose.image!
            //If the image is JPEG
            if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                //Conver the Image to a String Representation
                let imgUid = NSUUID().uuidString
               //Set the meta data
                let metaData = StorageMetadata()
               //SEt the meta data type to image / jpeg
                metaData.contentType = "image/jpeg"
                
                //Access the Firebase Storage for Fundraiser Images
                DataService.ds.REF_FUND_IMGS.child(imgUid).putData(imgData, metadata: metaData) { (metaData, error) in
                    if error  != nil {
                        print("JOE: unable to upload  post image to firebase storage")
                    } else {
                        print("JOe: Successfully uploaded post image to firebase storage")
                        let downloadURL = metaData?.downloadURL()?.absoluteString
                        if let url = downloadURL {
                            //Post the image to firebase storage
                            self.postToFirebase(imgUrl: url)
                        }
                    }
                }//End the Fire base function
            }
            
        }
       
    }
    //Function to post the image to fire base
    func postToFirebase(imgUrl: String) {
            
            //Set the local variables for goal and current date
            var goal = (NumOfRequest.text as! NSString).floatValue
            var stringCurrDate = dateFormatter.string(from: currDate)
        //Create a Post Dictionary Object
        let post: Dictionary<String, AnyObject> = [
            "caption": DescriptionTxt.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "currentDonation": 0 as AnyObject,
            "donationGoal": goal as AnyObject,
            "expirationDate": stringExpiration as AnyObject,
            "date": stringCurrDate as AnyObject,
            "title": TitleTxt.text!  as AnyObject
        ]
        //Create an autogenerated Key for the Post
        let firebasePost = DataService.ds.REF_FUNDRAISERS.childByAutoId()
        //Get a local variable for the fundraiser key
        var fundKey = firebasePost.key
       //Set the value for the post
        firebasePost.setValue(post)
        
        //Reset the controls
        TitleTxt.text = ""
        ImageChoose.image = UIImage(named: "add-image")
        NumOfRequest.text = ""
        DescriptionTxt.text = ""
        
        //Update Firebase User Function Sending the fundraiser key crated as a parameter
        DataService.ds.REF_USERS.child(userID).child("fundraisers").child(fundKey).setValue(true)

        //Alert the User the Campaign was Posted Successfully
        let alertController = UIAlertController(title: "Campaign Posted Succesfully", message: "Your campaign is now live. To update or modify your campaign, please navigate to your profile.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
        self.present(alertController, animated: true, completion: nil)
        
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

