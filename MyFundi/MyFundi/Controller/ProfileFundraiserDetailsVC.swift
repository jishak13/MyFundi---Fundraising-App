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
    
    @IBOutlet weak var goalTextField: FancyField!
    
     var post: Post?
    var dateFormatter: DateFormatter!
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        self.setFields()
       
        // Do any additional setup after loading the view.
    }
    func setFields() {
        
        titleTextField.text  = post?.title
        captionTextView.text = post?.caption
        goalTextField.text = "\(post?.donationGoal)"
        
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
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
