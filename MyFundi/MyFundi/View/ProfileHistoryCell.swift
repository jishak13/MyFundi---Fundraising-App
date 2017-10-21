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
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        self.titleLabel.text = post.title
        self.amountLabel.text = "\(post.donationGoal)"
        self.dateLabel.text = post.StartDate 
        
        
        
    }


}
