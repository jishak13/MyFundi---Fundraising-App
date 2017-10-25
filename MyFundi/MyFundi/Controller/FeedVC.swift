//
//  FeedVC.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/1/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    static var profileImageCache: NSCache<AnyObject,UIImage> = NSCache()
    var imageSelected = false
    var user: User!
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userID = (Auth.auth().currentUser?.uid)
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
                
        self.getUsers()
        print("JOE: \(users)")
        self.getFundraisers()
        
  
    }
    func getFundraisers()  {
        
        DataService.ds.REF_FUNDRAISERS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = Post(postKey: key, postData: postDict)
                                self.posts.append(post)
                                
                         
                    }
                }
            }
            self.tableView.reloadData()
        })
        
       
    }
    
    
    func getUsers() {
 
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var users = [User]()
                for snap in snapshot {
                    
                    let newUser = snap.value as? Dictionary<String,AnyObject>
                    var user = User(userKey: snap.key, userData: newUser!)
                    
                    self.users.append(user)
                    print("USER: \(user.FundraiserKeys)")
                }
                
            }
          
            
        })
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        var userImageUrl: String
    
        
       userImageUrl =  self.getProfileImageForPost(postkey: post.postKey)
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {

            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as AnyObject) {
                print("JOE: \(userImageUrl)")
                cell.configureCell(post: post, img: img,profImage: userImageUrl)
            } else {
                 print("JOE: \(userImageUrl)")
                cell.configureCell(post: post,profImage: userImageUrl)
            }
            return cell
        } else {
            return PostCell()
        }
    }

    func getProfileImageForPost(postkey: String) -> String {
        var image : String = ""
        for user in users {
            for funds in user.FundraiserKeys {
                if funds == postkey {
                    image = user.ImageUrl
                }
            }
        }
        return image
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("KHALID: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
   
    @IBAction func plusTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToAddNewPostFromFeed", sender: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "searchResultSegue", sender: nil)
    }
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        guard let caption = captionField.text, caption != "" else {
            print("KHALID: Caption must be entered...")
            return
        }
        guard let img = addImage.image, imageSelected == true else {
            print("KHALID: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_FUND_IMGS.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error  != nil {
                    print("KHALID: unable to upload image to firebase storage")
                } else {
                    print("KHALID: Successfully uploaded image to firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject,
            "currentDonation": 0 as AnyObject,
            "donationGoal": 0 as AnyObject,
            "title": "Test" as AnyObject
        ]
        
        let firebasePost = DataService.ds.REF_FUNDRAISERS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        addImage.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }
    
    @IBAction func profileImageTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToProfFromFeed", sender: nil)
    }
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("KHALID: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
}
