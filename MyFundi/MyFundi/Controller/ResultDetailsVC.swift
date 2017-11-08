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
    var currentUser: User!
  
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
   
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBAction func donateNowPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToDonateFromSearch", sender: self)
     
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDonateFromSearch" {
            if let donate = segue.destination as? DonateVC {
                donate.post = self.post
                donate.sender = "Results"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JOE: \(post?.caption)")
        // Do any additional setup after loading the view.
        print("JOE: \(post?.caption)")
        
        
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot{
                    if let userDict = snap.value as? Dictionary<String,AnyObject> {
                        for fund in (userDict["fundraisers"] as? [String:AnyObject])! {
                            if fund.key == self.post?.postKey {
                                let key = snap.key
                                let  user = User(userKey: key, userData: userDict)
                                self.configureInfo(post: self.post!,user: user)
                                
                                
                              
                            }
                        }
                        
                    }
                }
            }
        })
        
        
      
        
        
      
        

    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func searchUser(postKey: String) {
        print("Khalid1: \(postKey)")
        
   
    }
    
    func configureInfo(post: Post, user: User? = nil, fundraiserImg: UIImage? = nil, profileImg: UIImage? = nil) {
       
      
        
        
        self.captionTextView.text = post.caption
        self.fundraiserTitleLabel.text = post.title
        self.userNameLabel.text = user?.Name
        self.postDateLabel.text = post.StartDate
        self.expireDateLabel.text = post.EndDate
        self.raisedAmountLabel.text = "\(post.currentDonation)"
        self.goalAmountLabel.text = "\(post.donationGoal)"
        self.percentageLabel.text = "\((post.currentDonation/post.donationGoal)*100)%"
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
        
        let ref1 = Storage.storage().reference(forURL: (user?.ImageUrl)!)
        ref1.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("KHALID: unable to download image from Firebase storage")
            } else {
                print("KHALID: Image downloaded from Firebase Storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.profileImage.image = img
                    }
                }
            }
        }
        
        
        
    }
    
    
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    


}
