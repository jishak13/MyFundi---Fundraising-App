//
//  ProfileFundraiserDetailsVCViewController.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/25/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class ProfileFundraiserDetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var titleTextField: FancyField!
    
    @IBOutlet weak var fundraiserImage: UIImageView!
    
    @IBOutlet weak var captionTextView: FancyTextView!
    
    @IBOutlet weak var expirationDateTime: UIDatePicker!
    
    @IBOutlet weak var editImage: FancyButton!
    
    @IBOutlet weak var goalTextField: FancyField!
    
    @IBOutlet weak var editPostImage: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var post: Post?
    var dateFormatter: DateFormatter!
    var detailsButton: DetailsPageButton!
    var editMode: Bool  = false
    var stringExpiration: String!
    var newImageUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.setFields()
        // Do any additional setup after loading the view.
    }
    
    func setFields() {
        
        titleTextField.text  = post?.title
        captionTextView.text = post?.caption
        goalTextField.text = "\(post!.donationGoal)"
        
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
    
   
    
    @IBAction func editImagePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            fundraiserImage.image = image
            
        } else {
            print("KHALID: A valid image wasnt selected")
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
        if let imgData = UIImageJPEGRepresentation(fundraiserImage.image!, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_FUND_IMGS.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error  != nil {
                    print("Joe: unable to upload Fundraiser image to firebase storage")
                    
                } else {
                    print("Joe: Successfully uploaded Fundraiser image to firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                   self.newImageUrl = url
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    @IBAction func editFundraiserTapped(_ sender: Any) {
      
        if !editMode {
            editMode  = true
            titleTextField.isUserInteractionEnabled = true
            captionTextView.isUserInteractionEnabled = true
            goalTextField.isUserInteractionEnabled = true
            expirationDateTime.isUserInteractionEnabled = true
            editImage.isUserInteractionEnabled = true
            titleTextField.becomeFirstResponder()
            editPostImage.image = UIImage(named: "checkmark")
        
        }else
        {
            titleTextField.isUserInteractionEnabled = false
            captionTextView.isUserInteractionEnabled = false
            goalTextField.isUserInteractionEnabled = false
            expirationDateTime.isUserInteractionEnabled = false
            editImage.isUserInteractionEnabled = false
            editPostImage.image = UIImage(named: "icons8-edit")
            editMode = false
            self.updateFirebaseFundraiser()
        }
        
    }
    
    func validateFields() -> Bool {
        
        
        var valid: Bool = false
        
        if titleTextField.text == "" {
            titleTextField.errorBorder()
            
            
        }
        else {
            valid = true
            titleTextField.normalBorder()
        }
        
        if captionTextView.text == "" {
            captionTextView.errorBorder()
            
        }
        else {
            valid = true
            captionTextView.normalBorder()
        }
        
        
        if goalTextField.text == "" {
            goalTextField.errorBorder()
            
        }
        else {
            valid = true
            goalTextField.normalBorder()
        }
        
        if fundraiserImage.image == nil {
            
            let alertController = UIAlertController(title: "Campaign Field Missing", message: "Please select an image", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else
        {
            valid = true
        }
        
        return valid
    }
    
    func updateFirebaseFundraiser() {
        
     stringExpiration = dateFormatter.string(from: expirationDateTime.date)
        let goal = (goalTextField.text as! NSString).floatValue
        if validateFields() {
            
            
            DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["title":titleTextField.text])
            if newImageUrl == nil{
                DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["imageUrl":self.post!.imageUrl])
            }else{
                DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["imageUrl":newImageUrl])

            }
            DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["caption":captionTextView.text])
            DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["donationGoal":goal])
            DataService.ds.REF_FUNDRAISERS.child(self.post!.postKey).updateChildValues(["expirationDate":stringExpiration])
            
            
           
            
        }
        
    }
    @IBAction func deleteFundraiserTapped(_ sender: Any) {
        
        let received = self.post!.currentDonation

        if received > 0 {
            let alertController = UIAlertController(title: "Cancel Fundraiser Error", message: "You cannot delete the fundraiser becuase you have already received $\(received) in donations.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }else{
         deletePost()
            let alertController = UIAlertController(title: "Deleted Fundraiser", message: "The fundraiser was deleted sucessfully", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
//        backPressed(self)
    }
    func deletePost() {
        let uid = Auth.auth().currentUser!.uid
        let storage = Storage.storage().reference(forURL: (self.post?.imageUrl)!)
        
        // Remove the post from the DB
        DataService.ds.REF_FUNDRAISERS.child((self.post?.postKey)!).removeValue()
        
        // Remove the image from storage
        let ref = Storage.storage().reference(forURL: (post?.imageUrl)!)

       ref.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
        
        DataService.ds.REF_USERS.child(uid).child("fundraisers").child((self.post?.postKey)!).removeValue()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
