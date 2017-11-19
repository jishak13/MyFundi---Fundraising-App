//
//  LikesCell.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 11/7/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
//Class that Handles the Likes Cell UI Element
class LikesCell: UITableViewCell {

    //IBOUTLETS for the controls
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var fundraiserImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       //Let the colorView to a UI VIEW
        let bgColorView = UIView()
        //Set the BGcolor view background color to the a hue of blue
        bgColorView.backgroundColor = UIColor(displayP3Red: 149/255, green: 246/255, blue: 253/255, alpha: 1)
        //Set the selected background color to bgColorView
        self.selectedBackgroundView = bgColorView
    }
    
    //Method to Configure the Notification Cell
    func ConfigureCell(notification: Notification){
        //Vairables for the notification User and Post
        let user = notification.User
        let post = notification.Post
        //Set the notification text label
        notificationLabel.text = "\(user.Name) liked your fundraiser \(post.title)"
        
        //Set the storage ref to the Post Images
        let ref = Storage.storage().reference(forURL: notification.Post.imageUrl)
        ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("KHALID: Unable to download image from firebase storage")
            } else {
                print("KHALID: Image downloaded from firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        //Set the image to the fundraiser image found
                        self.fundraiserImage.image = img
                        //Add the image to the cache
                        FeedVC.imageCache.setObject(img, forKey: notification.Post.imageUrl as AnyObject)
                    }
                }
            }
        })
        
        //Set the storage reference to the User Storage
        let ref2 = Storage.storage().reference(forURL: notification.User.ImageUrl)
        ref2.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("KHALID: Unable to download image from firebase storage")
            } else {
                print("KHALID: Image downloaded from firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        //Profile Image is being set
                        self.profileImage.image = img
                        //Add the image to the profile image cache
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
