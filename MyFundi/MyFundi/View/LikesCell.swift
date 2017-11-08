//
//  LikesCell.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/7/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class LikesCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var fundraiserImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(displayP3Red: 149/255, green: 246/255, blue: 253/255, alpha: 1)
        self.selectedBackgroundView = bgColorView
    }
    
    func ConfigureCell(notification: Notification){
        
        let user = notification.User
        let post = notification.Post
        notificationLabel.text = "\(user.Name) liked your fundraiser \(post.title)"
        
        let ref = Storage.storage().reference(forURL: notification.Post.imageUrl)
        ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("KHALID: Unable to download image from firebase storage")
            } else {
                print("KHALID: Image downloaded from firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.fundraiserImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: notification.Post.imageUrl as AnyObject)
                    }
                }
            }
        })
        
        let ref2 = Storage.storage().reference(forURL: notification.User.ImageUrl)
        ref2.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("KHALID: Unable to download image from firebase storage")
            } else {
                print("KHALID: Image downloaded from firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        self.profileImage.image = img
                        FeedVC.profileImageCache.setObject(img, forKey: notification.User.ImageUrl as AnyObject)
                    }
                }
            }
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
