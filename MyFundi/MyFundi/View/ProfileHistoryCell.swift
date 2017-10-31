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
        
        
        
    }
    func configureDonationCell(donation: Donation,postTitle: String = "", img:UIImage? = nil){
        
        self.donation = donation
        
        print("JOE2: \(postTitle)")
//        self.titleLabel.text = postTitle
        self.amountLabel.text = "\(donation.DonationAmount)"
        self.dateLabel.text = self.donation.DonationDate
    }
    


}
