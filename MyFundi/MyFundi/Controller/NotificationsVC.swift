//
//  NotificationsVC.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/7/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
//Class that handles the Notifications VC
class NotificationsVC: UITableViewController  {
   
    //Local variables for the notification VC
    var notifications = [Notification]()
    var userID: String = ""
    var user : User!
    var userRef: DatabaseReference!
    var fundraiserKeys = [String]()
    var donationKeys =  [String]()
    var user1: User?
    var post: Post?
    
    //when the View Loads
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the table view properties for delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        //Get the user id
        //Set the userRef for Firebase Table
        userID = (Auth.auth().currentUser?.uid)!
        userRef = DataService.ds.REF_USERS.child(self.userID)
        //Initialize the fundraiser keys
        self.fundraiserKeys = [String]()
        //Ovserver this single user in firebase
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? Dictionary<String,AnyObject> {
                print ("JOE: USER DICT \(userDict)")
                //Create a user object for this user
                self.user = User(userKey: self.userID, userData: userDict)
                // IF the user has fundraisers
                if let fundraisers =  userDict["fundraisers"] as? [String:AnyObject]  {
                    //Get each fundraiser key
                    for fund in fundraisers{
                        self.fundraiserKeys.append(fund.key)
                        print("JOE: Fundraisers Found for User: \(fund.key)")
                    }
                }
            }
        })
        
        // For all users reference
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                //For each user
                for snap in snapshot {
                    //Debug Message
                    print("SNAP: \(snap)")
                    //Create a dictionary object
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                        //If the user has donations
                        if let donations = userDict["donations"] as? [String:AnyObject] {
                            //for each donations
                            for don in donations {
                                //If the user fundriasers are contained in this users donations
                                if self.fundraiserKeys.contains(don.key){
                                    //Debug Message
                                    print("JOE: USER DONATED TO YOUR FUNDRAISER!")
                                    //Get the user who donated
                                     self.user1 = User(userKey: snap.key,userData: userDict)
                                    //Get the fundraiser object from firebase
                                    DataService.ds.REF_FUNDRAISERS.child(don.key).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let postDict = snapshot.value as? Dictionary<String,AnyObject> {
                                            //Create the post object found
                                            self.post = Post(postKey: don.key,postData: postDict)
                                            //Create a notification object with the user who donated and post they donated too
                                            var notification = Notification(user: self.user1!, post: self.post!,type: "Donate")
                                            //Apend this notification object to the notifications
                                            self.notifications.append(notification)
                                        }
                                    })
                                }
                            }
                        }
                        //If the user has any likes
                        if let likes =  userDict["likes"] as? [String:AnyObject] {
                            //For each like
                            for like in likes {
                                //If they liked one of this users posts
                                if self.fundraiserKeys.contains(like.key) {
                                    //Debug Message
                                    print("JOE: USER LIKED TO YOUR FUNDRAISER!")
                                    //Create a user
                                    self.user1 = User(userKey:snap.key,userData: userDict)
                                    //Find the post they liked in firebase
                                    DataService.ds.REF_FUNDRAISERS.child(like.key).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let postDict = snapshot.value as? Dictionary<String,AnyObject> {
                                            //Create a post object
                                            self.post = Post(postKey: like.key,postData: postDict)
                                            //create a notification object for the user who liked and what post they liked
                                            var notification = Notification(user: self.user1!, post: self.post!,type: "Like")
                                            //Append the notification to notifications
                                            self.notifications.append(notification)
                                        }
                                    })
                                    
                                }
                            }
                        }
                    }
                }
            }
            //Refresh
            self.handleRefresh(self)
        })
    }
    //Handle the refresh
    @IBAction func handleRefresh(_ sender: Any) {
        //reload the table view
        self.tableView.reloadData()
        //Stop refreshing
        refreshControl?.endRefreshing()
    }
    //Create a cell in the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get the notification at this index path . row
        let not = self.notifications[indexPath.row]
        //Create a new cell
        var newCell = UITableViewCell()
        //If the notification is a like
        if not.NType == "Like" {
            //Create Likes cell
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LikesCell") as? LikesCell {
                //Configure the likes notification
                cell.ConfigureCell(notification: not)
                //Set new cell to this cell
              newCell = cell
            }
        } else if not.NType == "Donate" { //If the notification is a donation
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DonateCell") as? DonateCell {
                //Configure the notification
                cell.ConfigureCell(notification: not)
                //Set new cell to this cell
              newCell =  cell
            }
        }
        //Return the new cell
      return newCell
    }
    
    //Function to get the amount of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      //Return how many objects are in the array notifications
        return notifications.count
    }
}

