//
//  ResultDetailsVC.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/29/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
//Class that handles the Results View of a Search VC
class ResultDetailsVC: UIViewController {

  
    //IBOUTLETS for the view controller Results
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
    
    //Local Variables for VC
    var post: Post?
    var currentUser: User!
    //When the donate button is pressed
    @IBAction func donateNowPressed(_ sender: Any) {
        //take the user to the donate page
        performSegue(withIdentifier: "goToDonateFromSearch", sender: self)
     
    }
    //Before the use is taken to the Donate VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If the segue is taking the user to the donation page
        if segue.identifier == "goToDonateFromSearch" {
            if let donate = segue.destination as? DonateVC {
                //Set the post in the donation page to this selected post
                //And set the sender as this page
                donate.post = self.post
                donate.sender = "Results"
            }
        }
    }
    //When the View Loads
    override func viewDidLoad() {
        super.viewDidLoad()
        //Debug Messages
        print("JOE: \(post?.caption)")
  
        //Get the user for this fundriaser in firebase
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot{
                    if let userDict = snap.value as? Dictionary<String,AnyObject> {
                        if  let _ = userDict["fundraisers"] {
                            for fund in  (userDict["fundraisers"] as? [String:AnyObject])!{
                                //If this post key matches on in this current users record
                                if fund.key == self.post?.postKey {
                                    //configure this results page based on this user and the post selected
                                    let key = snap.key
                                    let  user = User(userKey: key, userData: userDict)
                                    self.configureInfo(post: self.post!,user: user)
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    //When the back button is pressed
    @IBAction func backBtn(_ sender: Any) {
        //Dismiss the VC, Back to search
        self.dismiss(animated: true, completion: nil)
    }
    //Function to configure the info on this page
    func configureInfo(post: Post, user: User? = nil, fundraiserImg: UIImage? = nil, profileImg: UIImage? = nil) {
       
        //Set the controls on this page to the user and post information
        self.captionTextView.text = post.caption
        self.fundraiserTitleLabel.text = post.title
        self.userNameLabel.text = user?.Name
        self.postDateLabel.text = post.StartDate
        self.expireDateLabel.text = post.EndDate
        self.raisedAmountLabel.text = "$\(post.currentDonation)"
        self.goalAmountLabel.text = "$\(post.donationGoal)"
        self.percentageLabel.text = "\(round((post.currentDonation/post.donationGoal)*100))%"
        self.currentRaisedProgress.setProgress((Float(post.currentDonation/post.donationGoal)), animated: true)
 
        //Get the fundraiser image from firebase
        let ref = Storage.storage().reference(forURL: post.imageUrl)
        ref.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("KHALID: unable to download image from Firebase storage")
            } else {
                print("KHALID: Image downloaded from Firebase Storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        //If found set the image for fundriaser
                        self.fundraiserImage.image = img
                    }
                }
            }
        }
        //if the user image isnt null
        if user?.ImageUrl != ""{
            //Get a reference to the user image
            let ref1 = Storage.storage().reference(forURL: (user?.ImageUrl)!)
            ref1.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
                if error != nil {
                    print("KHALID: unable to download image from Firebase storage")
                } else {
                    print("KHALID: Image downloaded from Firebase Storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            //SEt the profile image
                            self.profileImage.image = img
                        }
                    }
                }
                
            }
        }
        else{
            //Handle no image found here
            }
    } 
}
