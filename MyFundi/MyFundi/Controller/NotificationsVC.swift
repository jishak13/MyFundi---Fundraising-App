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
class NotificationsVC: UITableViewController  {
    
    var notifications = [Notification]()
    var userID: String = ""
    var user : User!
    var userRef: DatabaseReference!
    var fundraiserKeys = [String]()
    var donationKeys =  [String]()
    var user1: User?
    var post: Post?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        userID = (Auth.auth().currentUser?.uid)!
        userRef = DataService.ds.REF_USERS.child(self.userID)
        
//        refreshControl = UIRefreshControl()
//        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
//
//        tableView.addSubview(refreshControl!)

        

        self.fundraiserKeys = [String]()
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? Dictionary<String,AnyObject> {
                print ("JOE: USER DICT \(userDict)")
                self.user = User(userKey: self.userID, userData: userDict)
               
                if let fundraisers =  userDict["fundraisers"] as? [String:AnyObject]  {
                    for fund in fundraisers{
                        self.fundraiserKeys.append(fund.key)
                        print("JOE: Fundraisers Found for User: \(fund.key)")
                    }
                
                 
                }
            }
        })

//        DataService.ds.REF_DONATIONS.observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//
//                var donationKeys = [String]()
//
//                for snap in snapshot {
//                    print("SNAP: \(snap)")
//
//                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                        let key = snap.key
//                        for keys in self.fundraiserKeys{
//                            if keys == postDict["fundraiser"] as! String{
//                                donationKeys.append(keys)
//                            }
//                        }
//                    }
//                }
//            }
//        })
////
//        var notifs = [Notification]()
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
               
                
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                        if let donations = userDict["donations"] as? [String:AnyObject] {
                            for don in donations {
                                if self.fundraiserKeys.contains(don.key){
                                    print("JOE: USER DONATED TO YOUR FUNDRAISER!")
                                     self.user1 = User(userKey: snap.key,userData: userDict)
                                     DataService.ds.REF_FUNDRAISERS.child(don.key).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let postDict = snapshot.value as? Dictionary<String,AnyObject> {
                                            self.post = Post(postKey: don.key,postData: postDict)
                                            var notification = Notification(user: self.user1!, post: self.post!,type: "Donate")
                                            
                                            self.notifications.append(notification)
                                        }
                                    })
                                }
                            }
                        }
                        if let likes =  userDict["likes"] as? [String:AnyObject] {
                            for like in likes {
                                if self.fundraiserKeys.contains(like.key) {
                                    print("JOE: USER LIKED TO YOUR FUNDRAISER!")
                                    self.user1 = User(userKey:snap.key,userData: userDict)
                                    DataService.ds.REF_FUNDRAISERS.child(like.key).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let postDict = snapshot.value as? Dictionary<String,AnyObject> {
                                            self.post = Post(postKey: like.key,postData: postDict)
                                            var notification = Notification(user: self.user1!, post: self.post!,type: "Like")
                                            self.notifications.append(notification)
                                        }
                                    })
                                    
                                }
                            }
                        }
                    }
                }
            }
            self.handleRefresh(self)
        })
    }
    
    @IBAction func handleRefresh(_ sender: Any) {
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

}
    
    
    @IBAction func signOutTappedTVC(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("KHALID: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignInFromNotification", sender: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let not = self.notifications[indexPath.row]
        var newCell = UITableViewCell()
        if not.NType == "Like" {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LikesCell") as? LikesCell {
                cell.ConfigureCell(notification: not)
              newCell = cell
            }
        } else if not.NType == "Donate" {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DonateCell") as? DonateCell {
                
                cell.ConfigureCell(notification: not)
              newCell =  cell
            }
        }
      return newCell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
}

