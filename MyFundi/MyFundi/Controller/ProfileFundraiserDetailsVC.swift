//
//  ProfileFundraiserDetailsVCViewController.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/25/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class ProfileFundraiserDetailsVC: UIViewController {

    @IBOutlet weak var titleTextField: FancyField!
    
    @IBOutlet weak var fundraiserImage: UIImageView!
    
    @IBOutlet weak var captionTextView: FancyTextView!
    
    @IBOutlet weak var expirationDateTime: UIDatePicker!
    
    @IBOutlet weak var editImage: FancyButton!
    @IBOutlet weak var goalTextField: FancyField!
    
    @IBOutlet weak var editPostImage: UIImageView!
    var post: Post?
    var dateFormatter: DateFormatter!
    var detailsButton: DetailsPageButton!
    var editMode: Bool  = false
    var stringExpiration: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        self.setFields()
        let submit = UIButton.self as? DetailsPageButton
        submit?.HideButton()
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
        
        stringExpiration = dateFormatter.string(from: expirationDateTime.date)
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
    
    func updateFirebaseFundraiser(){
        
        if validateFields() {
            
        }
    }
    @IBAction func deleteFundraiserTapped(_ sender: Any) {
        
        
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
