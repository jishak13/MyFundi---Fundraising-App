//
//  ProfileFundraiserDetailsVCViewController.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/25/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

//Class for the Fundraiser details VC from the profile
class ProfileFundraiserDetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //IBOUTLETS for the controls on the Fundraiser Details Page
    @IBOutlet weak var titleTextField: FancyField!
    @IBOutlet weak var fundraiserImage: UIImageView!
    @IBOutlet weak var captionTextView: FancyTextView!
    @IBOutlet weak var expirationDateTime: UIDatePicker!
    @IBOutlet weak var editImage: FancyButton!
    @IBOutlet weak var goalTextField: FancyField!
    @IBOutlet weak var editPostImage: UIImageView!
    
    //Variables for the VC
    var imagePicker: UIImagePickerController!
    var post: Post?
    var dateFormatter: DateFormatter!
    var detailsButton: DetailsPageButton!
    var editMode: Bool  = false
    var stringExpiration: String!
    var newImageUrl: String!
    
    //When the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        //Allow the user to tap around the keyboard to dismiss it
        hideKeyboardWhenTappedAround()
        //Initialize the date formatter to format dates for this application
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        //Initialize the image PIcker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        //Set the fields from the post sent in from profile
        self.setFields()
        // Do any additional setup after loading the view.
    }
    
    func setFields() {
        //Set the controls text
        titleTextField.text  = post?.title
        captionTextView.text = post?.caption
        goalTextField.text = "\(post!.donationGoal)"
        //Set the profile image from firebase
        let ref = Storage.storage().reference(forURL: (post?.imageUrl)!)
        ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("KHALID: Unable to download image from firebase storage")
            } else {
                print("KHALID: Image downloaded from firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.fundraiserImage.image = img
                        
                    }
                }
            }
        })
        
        expirationDateTime.date = dateFormatter.date(from: (post?.EndDate)!)!
    }
    //Function that opens the camera
    @IBAction func openCameraButton(sender: AnyObject) {
        //If the user has granted access to app to use the camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //Initialize the image picker
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            //Present the image picker
            self.present(imagePicker, animated: true, completion: nil)
            //Debug Message
            print("Khalid: Open camera")
        }
    }
    //Function for when the edit image gallery is pressed
    @IBAction func editImagePressed(_ sender: Any) {
        //Present the image picker
        present(imagePicker, animated: true, completion: nil)
    }
    
    //function for the user finishes picking a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //If the user selected an image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //set the fundraiser image
            fundraiserImage.image = image
            fundraiserImage.contentMode = .scaleToFill
        } else {
            //Debug Message
            print("KHALID: A valid image wasnt selected")
            
        }
        //Dismiss the image picker
        picker.dismiss(animated: true, completion: nil)
        //Get the image data for firebase
        if let imgData = UIImageJPEGRepresentation(fundraiserImage.image!, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            //Upload the photo to fire base
            DataService.ds.REF_FUND_IMGS.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in //Handle the error
                if error  != nil {
                    print("Joe: unable to upload Fundraiser image to firebase storage")
                    
                } else { //Successfully uploaded
                    print("Joe: Successfully uploaded Fundraiser image to firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    //Update the image url
                    if let url = downloadURL {
                   self.newImageUrl = url
                        
                    }
                }
            }
        }
    }
    //Function for when the user
    @IBAction func editFundraiserTapped(_ sender: Any) {
        //If the page is not in edit more
        if !editMode {
            //Set edit mode to true
            editMode  = true
            //Allow user interaction on all controls
            titleTextField.isUserInteractionEnabled = true
            captionTextView.isUserInteractionEnabled = true
            captionTextView.isEditable = true
            goalTextField.isUserInteractionEnabled = true
            expirationDateTime.isUserInteractionEnabled = true
            editImage.isUserInteractionEnabled = true
            //Set focus to Title
            titleTextField.becomeFirstResponder()
            //SEt the confirmation image 'CheckMark'
            editPostImage.image = UIImage(named: "check-icon-blue")
        
        }else //Page is in edit mode
        {
            //Set edit mode to true
            editMode = false
            //Disable all controls
            titleTextField.isUserInteractionEnabled = false
            captionTextView.isUserInteractionEnabled = false
            goalTextField.isUserInteractionEnabled = false
            expirationDateTime.isUserInteractionEnabled = false
            editImage.isUserInteractionEnabled = false
            editPostImage.image = UIImage(named: "pencil-icon-blue")
            //Update the firebase fundriaser
            self.updateFirebaseFundraiser()
        }
        
    }
    
    func validateFields() -> Bool {
        //valid and errors variable
        var valid: Bool = false
        var errorArray = [String]()
        
        //Test the title field for nulls
        if titleTextField.text == "" {
            //Red border for error
            titleTextField.errorBorder()
            //Add an error Message
            errorArray.append("Title can not be empty")
        }
        else {
            //Black border for valid field
            titleTextField.normalBorder()
        }
        
        if captionTextView.text == "" {
            //Red border for error
            captionTextView.errorBorder()
            //Add an error message
            errorArray.append("Caption/Description can not be empty")
        }
        else {
            //Black border for valid field
            captionTextView.normalBorder()
        }
        
        if goalTextField.text == "" ||  (goalTextField.text as! NSString).floatValue <= 0 {
           //Red border for error
            goalTextField.errorBorder()
            //Add an error message
            errorArray.append("Caption/Description can not be empty")
        }
        else {
            //Black border for valid field
            goalTextField.normalBorder()
        }
       
        if fundraiserImage.image == nil {
            //Add an error message
           errorArray.append("Campaign must have an image")
            
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
            let alertController = UIAlertController(title: "Fields Are Missing", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            //Present the  Alert
            self.present(alertController, animated: true, completion: nil)
            //Return False because at least one field is invalid
            return false
        }
    }
    
    //function to update the firebase user
    func updateFirebaseFundraiser() {
        
     //Initialize string format of the expiration date
     stringExpiration = dateFormatter.string(from: expirationDateTime.date)
    //Set the numeric format of goal
     let goal = (goalTextField.text as! NSString).floatValue
      //If the fields/controls are valid
        if validateFields() {
        //Set the title
        DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["title":titleTextField.text])
            //If the image url is nill
            if newImageUrl == nil{
               //Use the old image url
                DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["imageUrl":self.post!.imageUrl])
            }else{
               //Use the new image url
                DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["imageUrl":newImageUrl])

            }
           //Set the caption in firebase
            DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["caption":captionTextView.text])
           //Set the donation goal in firebase
            DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["donationGoal":goal])
           //Set the expiration date in firebase
            DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["expirationDate":stringExpiration])
        }
    }
    //function to delete a fundriaser
    @IBAction func deleteFundraiserTapped(_ sender: Any) {
        //Get the amount recieved
        let received = self.post!.currentDonation
        //If the have received any donations
        if received > 0 {
            //Aler the user they cannot delete because they received donations
            let alertController = UIAlertController(title: "Cancel Fundraiser Error", message: "You cannot delete the fundraiser becuase you have already received $\(received) in donations.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }else{
       
            //Show a sucessfully deleted message
            let alertController = UIAlertController(title: "Deleting Fundraiser", message: "Are you sure you want to delete this fundraiser", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: {UIAlertAction in
                //Delete the post from fire base
                self.deletePost()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            if alertController.isBeingDismissed{
                  self.dismiss(animated: true, completion: nil)
            }
          
        }
        
    }
    //Function to delete the post from firebase
    func deletePost() {
        //Get the user id and storage reference for the image
        let uid = Auth.auth().currentUser!.uid
        let storage = Storage.storage().reference(forURL: (self.post?.imageUrl)!)
        
        // Remove the post from the DB
        DataService.ds.REF_FUNDRAISERS.child((self.post?.postKey)!).removeValue()
        
        // Get a reference to the image from storage
        let ref = Storage.storage().reference(forURL: (post?.imageUrl)!)
        //Delete the image in firebase storage
       ref.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
        //Remove the post from firebase fundraisers
        DataService.ds.REF_USERS.child(uid).child("fundraisers").child((self.post?.postKey)!).removeValue()
        titleTextField.text = nil
        goalTextField.text = nil
        captionTextView.text = nil
        fundraiserImage.image = nil
        
    }
    //Dismiss the VC
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
