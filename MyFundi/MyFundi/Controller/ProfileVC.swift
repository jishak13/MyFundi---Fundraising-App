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

//Class that handles the Profile View Controller
class ProfileVC: UIViewController,  UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //IBOUTLETS for the controls on the Profile VC
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editNameImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableSegment: UISegmentedControl!
    
    //Local Variables for the Profile VC
    var imagePicker: UIImagePickerController!
    var posts = [Post]()
    var donations = [Donation]()
    var fundraiserKeys = [String]()
    var donationKeys = [String]()
    var editingName = false
    var userID: String = ""
    var user : User!
    var userRef: DatabaseReference!
    var selectedPost: Post!
    var tmpPost: Post!
    var dateFormatter: DateFormatter!

    //When the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        //Method call to hide the key board when tapped around it
        hideKeyboardWhenTappedAround()
        //initialize the date formatter and set the format for this applications date
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
}
    
    //When the Fundraiser/Donation Table View Filter is switched
    @IBAction func tableSwitched(_ sender: Any) {
        //Reload the data
        self.tableView.reloadData()
        
    }
    //When the View Appeards
    override func viewWillAppear(_ animated: Bool) {
        //Appear animated
        super.viewWillAppear(animated)
        //Initialize local variables
        self.posts = [Post]()
        self.donations = [Donation]()
        self.fundraiserKeys = [String]()
        self.donationKeys = [String]()
        self.tableView.reloadData()
        
        //Set up the View Controller
        viewLoadSetup()
    }
    
    //Method to sign the user out when the sign out button is presed
    @IBAction func signOutTappedProfile(_ sender: AnyObject) {
        //Remove user from key chain
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        //Debug message
        print("KHALID: ID removed from keychain \(keychainResult)")
        //Sign out from firebase
        try! Auth.auth().signOut()
        //go back to sign In VC
        performSegue(withIdentifier: "goToSignInFromProf", sender: nil)
    }
    
    //function that handles setting up the profile
    func viewLoadSetup(){
//        hideKeyboardWhenTappedAround()
        
        //Set the profile gallery photo image
        editNameImage.image = UIImage(named:"icons8-edit")!
        //Get this users ID
        userID = (Auth.auth().currentUser?.uid)!
        //Set a reference to Firebase
        userRef = DataService.ds.REF_USERS.child(self.userID)
        //Debug Message
        print("JOE Current user ID is: " + userID)
        //Initialize the table views properties delegate, and data source
        tableView.delegate = self
        tableView.dataSource = self
        //Initialize the image Picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        //Initialize the name Control to not allow user interaction until the edit pencil is pressed
        nameTextField.isUserInteractionEnabled = false

       
            //Obser this single user
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDict = snapshot.value as? Dictionary<String,AnyObject> {
                    //Debug message
                    print ("JOE: USER DICT \(userDict)")
                    //Create a user object using this users key and user dictionary object
                    self.user = User(userKey: self.userID, userData: userDict)
                    //Call the method that populatexs user data to this VC
                     self.configureUser(userName:self.user.Name,imageUrl: self.user.ImageUrl)
                    //Get all the fundraiser keys for this user
                    if let fundraisers =  userDict["fundraisers"] as? [String:AnyObject]  {
                        for fund in fundraisers{
                           self.fundraiserKeys.append(fund.key)
                            //Debug MEssage
                            print("JOE: Fundraisers Found for User: \(fund.key)")
                        }
                        //Debug Message
                      print("JOE TOtal fundraisers: \(self.fundraiserKeys.count)")
                        //Load the fundraisers into an array
                        self.loadFundraisers()
                        
                        }
                    //Get all the donations keys for this user
                    if let donations = userDict["donations"] as? [String:AnyObject] {
                        for donation in donations {
                            //Append the donation keys to the donationKeys Array
                            self.donationKeys.append(donation.key)
                            //Debug Message
                            print("JOE: Donations found for user: \(donation.key)")
                            
                        }
                        //Load the donations into an array
                        self.loadDonations()
                    }
                }
                //Sort the posts by date posted
                self.posts.sort(by: { self.dateFormatter.date(from: $0.StartDate)! > self.dateFormatter.date(from: $1.StartDate)!
                })
                //Sort the donations by date donated
                self.donations.sort(by: { self.dateFormatter.date(from: $0.DonationDate)! > self.dateFormatter.date(from: $1.DonationDate)!
                })
                
                //Reload the table view
                self.tableView.reloadData()
            })
        }
            
    //Function to reload the table data
    @objc func reloadTableData(sender: AnyObject){
      self.tableView.reloadData()
    }
    
    //Method to cofigure user details on the profile, paramater is the user name and image
    func configureUser(userName: String, imageUrl:String) {
        //Debug Message
        print("JOE: Configuring user Profile")
        //SEt the name text field to enabled then change its text
        self.nameTextField.isEnabled = true
        self.nameTextField.text = userName
        //Get a reference to thie Profile Image Storage in Firebase
        if user.ImageUrl != ""{
            let ref = Storage.storage().reference(forURL: imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                //If the error is not empty
                if error != nil {
                    print("KHALID: Unable to download image from firebase storage")
                } else { //If the error is empty
                    print("KHALID: Image downloaded from firebase storage")
                    if let imgData = data {
                        //Set the profile image
                        if let img = UIImage(data: imgData) {
                            self.profileImage.image = img
                        }
                    }
                }
            })
        }
        
    }
    
    //MEthod when the edit (Pencil) Is tapped
    @IBAction func editNameTapped(_ sender: Any) {
        //If the user is editing
        if editingName == false{
            //SEt the editing image to a checkmark for confirmation
            editNameImage.image = UIImage(named:"checkmark")!
            //Allow user interaction and editing to the name field
            nameTextField.isUserInteractionEnabled = true
            nameTextField.allowsEditingTextAttributes = true
            //Set focus to the name
            nameTextField.becomeFirstResponder()
            //Set editing to true
            editingName = true
        }
        else {
            //Set the editing image back to the pencil
            editNameImage.image = UIImage(named:"icons8-edit")!
            //Dis-allow all interaction
            nameTextField.isUserInteractionEnabled = false
            //Set editing to false
            editingName = false
            //Update the firebase User Profile Name
            updateFirebaseProfileName(name: nameTextField.text!)
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If the user selects a fundraiser
        if tableSegment.selectedSegmentIndex == 0 {
            //Set the selected post to the one at this index path
            self.selectedPost = posts[indexPath.row]
            print("SELECTED POST: \(self.selectedPost.postKey)")
            //Perform the segue that takes this post to the fundraiser details
            performSegue(withIdentifier: "showFundraiserDetailsVC", sender: self)
        }
        else {
            //Donation was selected, do nothing
            print("Donation Selected")
        }
        
    }
    //function that loads the donations into the donation array
    func loadDonations() {
        //Create a new local donation array
        var dons = [Donation]()
        //Get a reference to the donations
        DataService.ds.REF_DONATIONS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                //for each donation
                for snap in snapshot {
                    //get the donation key
                    for donateKey in self.donationKeys{
                        //If its not empty
                        if snap.key == donateKey{
                            //Create a dictionary object for this key
                            if let donateDict = snap.value as? Dictionary<String, AnyObject> {
                                //Create a key and donation object
                                let key = snap.key
                                let donation = Donation(donationKey: key, donationDict: donateDict)
                                //Append to the method array dons
                                dons.append(donation)
                                //Debug Message
                                print("JOE: \(self.donations.count)")
                            }
                        }
                    }
                }
            }
            //Set the donations to the local dons
            self.donations = dons
            //reload the table view
            self.tableView.reloadData()
        })
    }
    
    //Method to load the fundraisers into Fundraiser Array
    func loadFundraisers(){

    //Set the posts to a new object
    self.posts = [Post]()
    //Create a reference to the fundraisers in firebase
    DataService.ds.REF_FUNDRAISERS.observe(.value, with: { (snapshot) in
        
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    //For each Fundraiser
                    for snap in snapshot {
                        //for each key in the fundraiser
                        for fundKey in self.fundraiserKeys{
                            //If the key is not empty
                            if snap.key == fundKey{
                                //Create a post dictionary
                                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                    //Create a fundraiser key and Post Object
                                    let key = snap.key
                                    let post = Post(postKey: key, postData: postDict)
                                    //Append to posts
                                    self.posts.append(post)
                                    
                                }
                            }
                        }
                    }
                }
                //Reload the table view
               self.tableView.reloadData()
            })
    
    }

    //Method to set the number of sections in the table view
    func numberOfSections(in tableView: UITableView) -> Int {
        //Number of sections is 1
       return 1
    }
    
    //Method to tell the table view how many rows their are
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //If fundraisers is selected
        if tableSegment.selectedSegmentIndex == 0{
            //Return the amount of fundraisers that are in the aray
            return posts.count
        }else{
            //Return the amount of donations that in the array
            return donations.count
        }
   
    }
    
    //Method to create the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Debug Message
        print("JOE INDEX PATH: \(indexPath.row)")
        //If fundraisers is selected
        if tableSegment.selectedSegmentIndex == 0 {
            //Set the post from the posts array at this index
            let post = posts[indexPath.row]
            //If there is a Profile History Cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHistoryCell") as? ProfileHistoryCell {
                //Configure a fundraiser cell
                cell.configureFundraiserCell(post: post)
                //Return that cell
                return cell
                
            } else {
                //Return a post Cell
                return ProfileHistoryCell()
            }
        } else {
            //If donations is selected
            //Set the donation from the donations array at this index
            let donation = donations[indexPath.row]
            //Get a reference to fundraisers
            let postRef = DataService.ds.REF_FUNDRAISERS.child(donation.FundraiserKey)
            //view this post in the fundraiser
            postRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //Create a dictionary for this post object
                if  let postDict = snapshot.value as? Dictionary<String,AnyObject> {
                    //Set the temporary post
                   self.tmpPost = Post(postKey: donation.FundraiserKey, postData: postDict)
                    //Debug Message
                    print("JOE: \(self.tmpPost.title)")
                }
            })
            //If there is a profile history cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHistoryCell") as? ProfileHistoryCell {
                //Configure the cell with this donation
                cell.configureDonationCell(donation: donation)
                //Return that cell
                return cell
                
            } else {
                //Return a profile history cell
                return ProfileHistoryCell()
            }
        }
        
    }
    //function to open the camera
    @IBAction func openCameraButton(sender: AnyObject) {
        //If the user has allowed the application to use their camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //Initialize an image picker and set its properties
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
   //Method to handle the user picking a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //If they did select an image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //Set that image as their profile image
            profileImage.image = image
            profileImage.contentMode = .scaleToFill
        } else {
            print("KHALID: A valid image wasnt selected")
        }
        //Dimiss the image picker
        picker.dismiss(animated: true, completion: nil)
        //If the image is valid
        if let imgData = UIImageJPEGRepresentation(profileImage.image!, 0.2) {
            //Convert the image to a url base string
            let imgUid = NSUUID().uuidString
            //Set the image data
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            //Get a referene to profile images in the firebase storage
            DataService.ds.REF_PROF_IMGS.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                //If there is an error
                if error  != nil {
                    print("Joe: unable to upload Profile image to firebase storage")
                } else { //No Error....NICE!
                    print("Joe: Successfully uploaded Profile image to firebase storage")
                    //Create a download url
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        //Update the Profile Storage url for this user
                        self.updateFirebaseProfileImage(imgUrl: url)
                    }
                }
            }
        }
      
    }
    //Updates the user record when ever called
    func updateFirebaseProfileName(name: String) {
        //Get a reference for this current user in firebase
        let firebaseUser = DataService.ds.REF_USER_CURRENT
        //Update the Name value to the name passed in
        firebaseUser.updateChildValues(["name" : name])
        //Debug MEssage
        print("JOE: \(userID)")
        
        
    }
    
    //Updates the user record when ever called
    func updateFirebaseProfileImage(imgUrl: String) {
        //Get a reference for this current user in firebase
        let firebaseUser = DataService.ds.REF_USER_CURRENT
        //Update the imageUrl value to the image url passed in
        firebaseUser.updateChildValues(["imageUrl" : imgUrl])
        //Debug Message
        print("JOE: \(userID)")
        
        
    }
    @IBAction func addImageTapped(_ sender: Any) {
        //When the user wants to add an image, present the image picker
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("KHALID: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignInFromProf", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Get ready for taking the fundraiser to Details VC
        if segue.identifier == "showFundraiserDetailsVC" {
            //If the instance of fundraiser Details VC can be created
            if let profileDetails = segue.destination as? ProfileFundraiserDetailsVC {
                //Set its post object to this VC selected post
                profileDetails.post = self.selectedPost
            }
        }
    }
}
    
  

