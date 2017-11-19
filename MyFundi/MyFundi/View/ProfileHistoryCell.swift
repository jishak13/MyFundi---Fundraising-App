//
//  ProfileHistoryCell.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/15/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
//Class  to handle Profile History Cell UI Element
class ProfileHistoryCell: UITableViewCell {
    
    //IBOUTLET for the Profile History Cell
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateTypeLabel: UILabel!
   
    //Local Variables for the profile history post and donation object
    var post: Post!
    var donation: Donation!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //Method to configure a Fundraiser Cell
    func configureFundraiserCell(post: Post, img: UIImage? = nil) {
        //Initialize a post
        self.post = post
        
        //Set the controls on the cell to the post object
        self.titleLabel.text = post.title
        self.amountLabel.text = "\(post.donationGoal)"
        self.dateLabel.text = post.StartDate 
        self.dateTypeLabel.text = "Posted On"
        
        
    }
    //Method to configure a donation Cell
    func configureDonationCell(donation: Donation,postTitle: String = "", img:UIImage? = nil){
        //Initialize the donation
        self.donation = donation
        //Debug Message
        print("JOE2: \(postTitle)")
        //Set the controls on the cell to the donation Object
        self.dateTypeLabel.text = "Donated on"
        self.amountLabel.text = "$\(donation.DonationAmount)"
        self.dateLabel.text = self.donation.DonationDate
        //Get the title of this donation post
        DataService.ds.REF_FUNDRAISERS.child(donation.FundraiserKey).observeSingleEvent(of: .value, with:  { (snapshot)  in
              if let fundDict = snapshot.value as? Dictionary<String,AnyObject> {
                self.titleLabel.text = fundDict["title"] as! String
            }
        })
    }
}
