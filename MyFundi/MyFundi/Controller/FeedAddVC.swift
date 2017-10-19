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

class FeedAddVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    @IBOutlet weak var TitleTxt: FancyField!
    @IBOutlet weak var ImageChoose: UIImageView!
//    @IBOutlet weak var DescriptionTxt: FancyTextView!
    @IBOutlet weak var NumOfRequest: FancyField!
    @IBOutlet weak var ExpirationDate: FancyField!
    
    var posts = [Post]()
    static var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    
    @IBAction func ImageChooseTapped(_ sender: UITapGestureRecognizer) {
        let imagePickerControl = UIImagePickerController()
        imagePickerControl.allowsEditing = true
        imagePickerControl.sourceType = .photoLibrary
        imagePickerControl.delegate = self
        present(imagePickerControl, animated: true, completion: nil)
    }
    
    @IBAction func PostBtnTapped(_ sender: UIButton) {
        guard let title = TitleTxt.text else {
            print("Title must be entered.")
            return
        }
        
        guard let img = ImageChoose.image else {
            print("Image must be selected.")
            return
        }
        
//        guard let description = DescriptionTxt.text else  {
//            print("Description must be entered.")
//            return
//        }
        
        guard let request = NumOfRequest.text else {
            print("Donation Goal must be entered.")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            DataService.ds.REF_FUND_IMGS.child(imgUid).putData(imgData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    print("Joe: Unable to upload image to firebase storage")} else {
                    print("Joe: Succesfully uploaded images to firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
//                    postToFirebase(imgUrl: downloadURL)
                }
                
            
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": TitleTxt.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "currentDonation": 0 as AnyObject,
            "donationGoal": NumOfRequest.text! as AnyObject,
//            "title": DescriptionTxt.text! as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_FUNDRAISERS.childByAutoId()
        firebasePost.setValue(post)
        
        TitleTxt.text = ""
        ImageChoose.image = UIImage(named: "add-image")
        NumOfRequest.text = ""
//        DescriptionTxt.text = ""
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
}
