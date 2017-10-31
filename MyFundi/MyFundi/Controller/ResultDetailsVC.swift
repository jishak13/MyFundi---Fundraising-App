//
//  ResultDetailsVC.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/29/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class ResultDetailsVC: UIViewController {

    var post: Post?
    var user: User!
  
    @IBOutlet weak var profileImage: CircleView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var fundraiserTitleLabel: UILabel!
    
    @IBOutlet weak var fundraiserImage: UIImageView!
    
    @IBOutlet weak var captionTextView: FancyTextView!
    
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var expireDateLabel: UILabel!
    
    
    @IBOutlet weak var raisedAmountLabel: UILabel!
    
    @IBOutlet weak var goalAmountLabel: UILabel!
    
    
    @IBOutlet weak var currentRaisedProgress: UIProgressView!
   
    @IBAction func donateNowPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JOE: \(post?.caption)")
        
        searchUser(postKey: (post?.postKey)!)
        print("KHALID3: \(user?.Name)")
        
        
        configureInfo(post: post!)
        
        
        
    }

    func searchUser(postKey: String) {
        print("Khalid1: \(postKey)")
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                var user = [User]()
                for snap in snapshot{
                    print("KHALID2: \(snap.value)")
                    if let userDict = snap.value as? Dictionary<String,AnyObject> {
                        for fund in (userDict["fundraisers"] as? [String:AnyObject])! {
                            if fund.key == postKey {
                                let key = snap.key
                                let user = User(userKey: key, userData: userDict)
                                self.user = user
                                print("KHALID4: \(self.user?.Name)")
                            }
                        }

                    }
                }
            }
        })
    }
    
    func configureInfo(post: Post, user: User? = nil, fundraiserImg: UIImage? = nil, profileImg: UIImage? = nil) {
        self.post = post
        self.user = user
        
        
        self.captionTextView.text = post.caption
        self.fundraiserTitleLabel.text = post.title
        self.userNameLabel.text = user?.Name
        self.postDateLabel.text = post.StartDate
        self.expireDateLabel.text = post.EndDate
        self.raisedAmountLabel.text = "\(post.currentDonation)"
        self.goalAmountLabel.text = "\(post.donationGoal)"
        self.currentRaisedProgress.setProgress((post.currentDonation/post.donationGoal), animated: true)
 
        let ref = Storage.storage().reference(forURL: post.imageUrl)
        ref.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("KHALID: unable to download image from Firebase storage")
            } else {
                print("KHALID: Image downloaded from Firebase Storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.fundraiserImage.image = img
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

}
