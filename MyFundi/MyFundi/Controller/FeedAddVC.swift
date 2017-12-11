//
//  FeedAddVC.swift
//  MyFundi
//
//  Created by Ivy JianG on 10/15/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}





class FeedAddVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    @IBOutlet weak var TitleTxt: FancyField!
    @IBOutlet weak var ImageChoose: UIImageView!
    @IBOutlet weak var DescriptionTxt: FancyTextView!
    @IBOutlet weak var NumOfRequest: FancyField!
    
    @IBOutlet weak var ExpDatePicker: UIDatePicker!
    @IBOutlet weak var ExpirationDate: FancyField!
    
    
    var userID: String = ""
    
    var posts = [Post]()
//    var formattedDate: Date!
    let currDate = Date()
    var stringExpiration: String!
    var dateFormatter: DateFormatter!
    
    static var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userID = (Auth.auth().currentUser?.uid)!
        
        self.hideKeyboardWhenTappedAround()

       dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
     //Current time zone
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        ImageChoose.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editImageTapped(_ sender: Any) {
        let imagePickerControl = UIImagePickerController()
        imagePickerControl.allowsEditing = true
        imagePickerControl.sourceType = .photoLibrary
        imagePickerControl.delegate = self
        present(imagePickerControl, animated: true, completion: nil)
    }
    
    func validateFields() -> Bool {
        
        stringExpiration = dateFormatter.string(from: ExpDatePicker.date)
        var valid: Bool = false
        
        if TitleTxt.text == "" {
            TitleTxt.errorBorder()
            
            
        }
        else {
            valid = true
            TitleTxt.normalBorder()
        }
        
        if DescriptionTxt.text == "" {
            DescriptionTxt.errorBorder()
            
        }
        else {
            valid = true
            DescriptionTxt.normalBorder()
        }
        
        
        if NumOfRequest.text == "" {
            NumOfRequest.errorBorder()
            
        }
        else {
            valid = true
            NumOfRequest.normalBorder()
        }
        
        if ImageChoose.image == nil {
                
            let alertController = UIAlertController(title: "Campaign Field Missing", message: "Please select an image", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            } else
        {
            valid = true
        }
        
          return valid
        }
  
    
    
    
    @IBAction func PostBtnTapped(_ sender: UIButton) {
        
        if(self.validateFields()) {
            
            
            let img = ImageChoose.image!
            if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                let imgUid = NSUUID().uuidString
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                
                DataService.ds.REF_FUND_IMGS.child(imgUid).putData(imgData, metadata: metaData) { (metaData, error) in
                    if error  != nil {
                        print("JOE: unable to upload  post image to firebase storage")
                    } else {
                        print("JOe: Successfully uploaded post image to firebase storage")
                        let downloadURL = metaData?.downloadURL()?.absoluteString
                        if let url = downloadURL {
                            self.postToFirebase(imgUrl: url)
                        }
                    }
                }
            }
            
        }
       
    }

        func postToFirebase(imgUrl: String) {
            
            var goal = (NumOfRequest.text as! NSString).floatValue
            var stringCurrDate = dateFormatter.string(from: currDate)
       
//
//            print("JOE the date in a string format is \(stringExpiration)")
//
//
//
//            print("JOE: GOAL \(goal)")
//
//            print("JOE: Current Date is \(stringCurrDate)")
            
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
        
        let firebasePost = DataService.ds.REF_FUNDRAISERS.childByAutoId()
       var fundKey = firebasePost.key
        firebasePost.setValue(post)
        
        
        TitleTxt.text = ""
        ImageChoose.image = UIImage(named: "add-image")
        NumOfRequest.text = ""
        DescriptionTxt.text = ""
            
        UpdateFireBaseUser(fundKey:fundKey)
        
    }
       
        func dateformatterDateString(dateString: String) -> NSDate? {
            
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "mm-dd-yyyy"
            if dateFormatter.date(from: dateString) != nil {
                return dateFormatter.date(from: dateString)! as NSDate
            } else{
                print("The date was in an incorrect format")
                return NSDate()
            }
        }
    
        func UpdateFireBaseUser(fundKey: String){
            
   
            DataService.ds.REF_USERS.child(userID).child("fundraisers").child(fundKey).setValue(true)
        


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

