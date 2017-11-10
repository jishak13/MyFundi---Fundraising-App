//
//  ProfileHistoryCell.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/15/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
class ProfileHistoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateTypeLabel: UILabel!
    
    var post: Post!
    var donation: Donation!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureFundraiserCell(post: Post, img: UIImage? = nil) {
      
        self.post = post
        
        self.titleLabel.text = post.title
        self.amountLabel.text = "\(post.donationGoal)"
        self.dateLabel.text = post.StartDate 
        self.dateTypeLabel.text = "Posted On"
        
        
    }
    func configureDonationCell(donation: Donation,postTitle: String = "", img:UIImage? = nil){
        
        self.donation = donation
        
        print("JOE2: \(postTitle)")
//        self.titleLabel.text = postTitle
        self.dateTypeLabel.text = "Donated on"
        self.amountLabel.text = "$\(donation.DonationAmount)"
        self.dateLabel.text = self.donation.DonationDate
        
        DataService.ds.REF_FUNDRAISERS.child(donation.FundraiserKey).observeSingleEvent(of: .value, with:  { (snapshot)  in
              if let fundDict = snapshot.value as? Dictionary<String,AnyObject> {
                self.titleLabel.text = fundDict["title"] as! String
            }
        })
        
    }
    


}
