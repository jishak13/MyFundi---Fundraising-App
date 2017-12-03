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

//Class to handle the Feedd of Fundraisers 
class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //IBOUTLETS for the table view and the filter control
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var feelFilter: UISegmentedControl!
    
    //Static variables for images cache for fundraisers and users
    static var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    static var profileImageCache: NSCache<AnyObject, UIImage> = NSCache()
    
    //Local variables for the Feed
    var posts = [Post]()
    var users = [User]()
    var user: User!
    var donatePost:Post!
    var dateFormatter: DateFormatter!
    
    //When the View Loads
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the Feed Filter selected Index
        feelFilter.selectedSegmentIndex = 1
        //Initialize the date formatter and the format for this application
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy" //Your date format
        //Get the current userId
        let userID = (Auth.auth().currentUser?.uid)
        //Set the table view properties for delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        //Observe the all users in firebase at for populating the Feed
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                //Initialize a new user Array
                var users = [User]()
                //for each snapshot in Firebase
                for snap in snapshot{
                    //If the snapshot is not empy
                    if let userDict = snap.value as? Dictionary<String,AnyObject> {
                        //Get the key and create a new user object
                        let key = snap.key
                        let user = User(userKey: key, userData: userDict)
                        //Add the new object to the local user Array
                        users.append(user)
                    }
                }
                //Set the local users array to the class wide user array
                //This is done so that no fundraisers are repeated in the feed
                self.users = users
            }
        })
        
        //Observe all the fundriasers  to populate the Campaign Posts
        DataService.ds.REF_FUNDRAISERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                //Initialize a new post array
                var posts = [Post]()
                //for each snapshot in Firebase
                for snap in snapshot {
                    //Debug message
                    print("SNAP: \(snap)")
                    //If the snapshot is not empty
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                       //Get the key and create a new post object
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        //Add the new object to the local post Array
                        posts.append(post)
                    }
                }
                //Set the local posts array to the class wide post array
                //this is done so that no fundriasers are repeated in the feed
                self.posts = posts
                //Reload the table view
                self.tableView.reloadData()
            }
        })
    }
    
    
    @IBAction func shareTapped(_ sender: Any) {
        let feedVC = UIActivityViewController(activityItems: ["myfundi.com"], applicationActivities: nil)
        feedVC.popoverPresentationController?.sourceView = self.view
        
        self.present(feedVC, animated: true, completion: nil)
    }
    
    
    
    //Method to handle a user pressing down on "Donate Now" in each individual post
    @IBAction func donatePressed(_ sender: AnyObject) {
        //Debug Message
        print("JOE12: \(sender.tag)")
        //get the donate post according to the senders.tag
        donatePost = posts[sender.tag]
        //Perform the segue that brings up the Donation Page
        performSegue(withIdentifier: "goToDonateVC", sender: self)
    }
    
    //When the feed Filter changes
    @IBAction func feedFilterChanged(_ sender: Any) {
        //If the selected index is 0
        //Sort the array by date posted
        if( self.feelFilter.selectedSegmentIndex == 0) {
      
            self.posts.sort(){ dateFormatter.date(from: $0.StartDate)! > dateFormatter.date(from: $1.StartDate)!
            }
            
        }
        //reload the table view
        tableView.reloadData()
    }
    
    //Method to prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       //If the segue to be performed is going to Donation VC
        if segue.identifier == "goToDonateVC" {
            //set donate to an instance of DonateVC
            if let donate = segue.destination as? DonateVC {
                //set the post object in donate vc
                donate.post = self.donatePost
                //Set the sender as Feed
                donate.sender = "Feed"
            }
        }
    }
    
    //function to handle the ttable views number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        //one section in this table view
        return 1
    }
    
    //function to handle the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      //As many rows as there are post objects in the array
        return posts.count
    }
    
    //get the current cell object for this table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Initialize a  post object from the post array at this index path row
        let post = posts[indexPath.row]
        //Get the user object who posted this post
        self.getUser(post: post.postKey)
        
        //Create a Post Cell Object
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            //Set the target for donatebutton
            cell.donateButton.addTarget(self, action: #selector(donatePressed(_:)), for: .touchUpInside)
            //Set a tag for the donate button equal to the index path
            cell.donateButton.tag = indexPath.row
            //Create an img based on the cache
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as AnyObject){
               //If one exists use the image
                cell.configureCell(post: post,user: self.user, img: img)
            } else {
                //Else let the Post Cell View find the image
                cell.configureCell(post: post, user: self.user)
            }
            //return the cell
            return cell
            //If no instance of Post Cell is returned
        } else {
            //Return the default post cell
            return PostCell()
        }
    }

    //function to set the class user variable
    func getUser(post: String) {

        //for each user is the user array
        for user in users {
            //for each fundraiser in the user array
            for funds in user.FundraiserKeys{
                //if the post parameter( which is a key) is equal to the fundraiser key
                if post == funds{
                    //set the class user to this user
                    self.user = user
                }
            }
        }
      
    }
    //When the search button is tapped
    @IBAction func searchButtonTapped(_ sender: Any) {
        //Perform the segue search result segue...Takes you to search page
        performSegue(withIdentifier: "searchResultSegue", sender: nil)
    }
    
    //when the sign out button is tapped
    @IBAction func signOutTapped(_ sender: AnyObject) {
        //Remove the use from the keychaing
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        //Debug message
        print("KHALID: ID removed from keychain \(keychainResult)")
        //Sign out of firebase authentication
        try! Auth.auth().signOut()
        //Go back to the sign in page
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
}
