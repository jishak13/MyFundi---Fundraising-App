//
//  ProfileVC.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/15/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper



class ProfileVC: UIViewController,  UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editNameImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var tableSegment: UISegmentedControl!
    
    var imagePicker: UIImagePickerController!
    
    var posts = [Post]()
    var donations = [Donation]()
    var fundraiserKeys = [String]()
    var donationKeys = [String]()
    var editingName = false
    var userID: String = ""
    var count = 0
    var user : User!
    var userRef: DatabaseReference!
    var selectedPost: Post!
    var tmpPost: Post!

    override func viewDidLoad() {
        super.viewDidLoad()
}
    
    @IBAction func tableSwitched(_ sender: Any) {
        self.tableView.reloadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        posts = [Post]()
        fundraiserKeys = [String]()
        viewLoadSetup()
        self.tableView.reloadData()
        
        
    }
    
    func viewLoadSetup(){
        hideKeyboardWhenTappedAround()
        print("My View has loaded \(count) times")
        count = count + 1
        
        editNameImage.image = UIImage(named:"icons8-edit")!
        userID = (Auth.auth().currentUser?.uid)!
        userRef = DataService.ds.REF_USERS.child(self.userID)
        print("JOE Current user ID is: " + userID)
        //        var posts = [Post]()
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        nameTextField.isUserInteractionEnabled = false
//        nameTextField.isEnabled = false
//        nameTextField.allowsEditingTextAttributes = false
       
            
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? Dictionary<String,AnyObject> {
                    print ("JOE: USER DICT \(userDict)")
                    self.user = User(userKey: self.userID, userData: userDict)
                     self.configureUser(userName:self.user.Name,imageUrl: self.user.ImageUrl)
                    if let fundraisers =  userDict["fundraisers"] as? [String:AnyObject]  {
                        for fund in fundraisers{
                           self.fundraiserKeys.append(fund.key)
                            print("JOE: Fundraisers Found for User: \(fund.key)")
                        }
                      print("JOE TOtal fundraisers: \(self.fundraiserKeys.count)")
                        self.loadFundraisers()
                        
                        }
                    if let donations = userDict["donations"] as? [String:AnyObject] {
                        for donation in donations {
                            self.donationKeys.append(donation.key)
                            print("JOE: Donations found for user: \(donation.key)")
                            
                        }
                        self.loadDonations()
                    }
                }
                self.tableView.reloadData()
                
                
            })
        
        }
            

    @objc func reloadTableData(sender: AnyObject){
      self.tableView.reloadData()
    }
    func configureUser(userName: String, imageUrl:String) {
        
        print("JOE: Configuring user Profile")
        self.nameTextField.isEnabled = true
        self.nameTextField.text = userName
        let ref = Storage.storage().reference(forURL: imageUrl)
        ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("KHALID: Unable to download image from firebase storage")
            } else {
                print("KHALID: Image downloaded from firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.profileImage.image = img
                        
                    }
                }
            }
        })
    }
    
    @IBAction func editNameTapped(_ sender: Any) {
        if editingName == false{
            
            editNameImage.image = UIImage(named:"checkmark")!
            nameTextField.isUserInteractionEnabled = true
            nameTextField.allowsEditingTextAttributes = true
            nameTextField.becomeFirstResponder()
            editingName = true
        }
        else {
            
            editNameImage.image = UIImage(named:"icons8-edit")!
            nameTextField.isUserInteractionEnabled = false
            editingName = false
            updateFirebaseProfileName(name: nameTextField.text!)
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if tableSegment.selectedSegmentIndex == 0 {
            self.selectedPost = posts[indexPath.row]
            print("SELECTED POST: \(self.selectedPost.postKey)")
            performSegue(withIdentifier: "showFundraiserDetailsVC", sender: self)
        }
        else {
            print("Donation Selected")
        }
        
    }
    func loadDonations() {
        self.donations = [Donation]()
        DataService.ds.REF_DONATIONS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    for donateKey in self.donationKeys{
                        if snap.key == donateKey{
                            if let donateDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let donation = Donation(donationKey: key, donationDict: donateDict)
                                
                                self.donations.append(donation)
                                print("JOE: \(self.donations.count)")
                                
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    func loadFundraisers(){
     self.posts = [Post]()
    DataService.ds.REF_FUNDRAISERS.observe(.value, with: { (snapshot) in
        
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        for fundKey in self.fundraiserKeys{
                            if snap.key == fundKey{
                                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let post = Post(postKey: key, postData: postDict)
                                    self.posts.append(post)
                                    
                                }
                            }
                        }
                    }
                }
               self.tableView.reloadData()
            })
    
    }


    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableSegment.selectedSegmentIndex == 0{
            return posts.count
        }else{
            return donations.count
        }
   
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("JOE INDEX PATH: \(indexPath.row)")
        
        if tableSegment.selectedSegmentIndex == 0 {
            let post = posts[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHistoryCell") as? ProfileHistoryCell {
                
                cell.configureFundraiserCell(post: post)
                return cell
                
            } else {
                return PostCell()
            }
        } else {
            
            let donation = donations[indexPath.row]
            
            let postRef = DataService.ds.REF_FUNDRAISERS.child(donation.FundraiserKey)
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if  let postDict = snapshot.value as? Dictionary<String,AnyObject> {
                    
                   self.tmpPost = Post(postKey: donation.FundraiserKey, postData: postDict)
                    print("JOE: \(self.tmpPost.title)")
                }
            })
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHistoryCell") as? ProfileHistoryCell {
                
                cell.configureDonationCell(donation: donation)
                return cell
                
            } else {
                return PostCell()
            }
        }
        
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
        } else {
            print("KHALID: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let imgData = UIImageJPEGRepresentation(profileImage.image!, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_PROF_IMGS.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error  != nil {
                    print("Joe: unable to upload Profile image to firebase storage")
                } else {
                    print("Joe: Successfully uploaded Profile image to firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.updateFirebaseProfileImage(imgUrl: url)
                    }
                }
            }
        }
      
    }
    //Updates the user record when ever called
    func updateFirebaseProfileName(name: String) {
        
        let firebaseUser = DataService.ds.REF_USER_CURRENT
        firebaseUser.updateChildValues(["name" : name])
        print("JOE: \(userID)")
        
        
    }
    
    //Updates the user record when ever called
    func updateFirebaseProfileImage(imgUrl: String) {
        
        let firebaseUser = DataService.ds.REF_USER_CURRENT
        firebaseUser.updateChildValues(["imageUrl" : imgUrl])
        print("JOE: \(userID)")
        
        
    }
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("KHALID: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignInFromProf", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFundraiserDetailsVC" {
            if let profileDetails = segue.destination as? ProfileFundraiserDetailsVC {
                profileDetails.post = self.selectedPost
            }
        }
    }
   
   
}
    
  

