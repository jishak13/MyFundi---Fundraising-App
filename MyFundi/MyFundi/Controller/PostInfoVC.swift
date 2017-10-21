//
//  PostInfoVC.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/19/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class PostInfoVC: UIViewController {

    var loggedInUser: Auth?
    var otherUser: NSDictionary?
    var loggedInUserData: NSDictionary?
    var postInfo = [PostInfo]()
    var postKey: String!
    var userKey: String!
    
    @IBOutlet weak var postLbl: UILabel!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var currentLbl: UILabel!
    @IBOutlet weak var goalLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var captionLbl: UITextView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var userImg: CircleView!
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    @IBAction func donateBtn(_ sender: Any) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var userID = (Auth.auth().currentUser?.uid)!
        
        DataService.ds.REF_FUNDRAISERS.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
//                self.postInfo = [self.postInfo]
                
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postInfoDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        self.postKey = snap.key
                        
                        
//                        let postInfo = PostInfo(postKey: <#T##String#>, userKey: <#T##String#>, postData: <#T##Dictionary<String, AnyObject>#>, userData: <#T##Dictionary<String, AnyObject>#>)
                        
                    }
                    
                }
                
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let showSearchViewViewController = SearchedDetailsTableViewController.self
//        
//        //showSearchViewViewController.loggedInUser = self.loggedInUser as Auth?
//    }
    
    func loadPostInfo() {
        let user = DataService.ds.REF_USERS.observe(.value, with:{ (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    let userPost = DataService.ds.REF_USERS.child(snap.key).child("fundraisers").child(self.postKey).key
                    print("Khalid: User key for this snap is \(userPost)")
                }
            }
        })
    }
    
    
}


