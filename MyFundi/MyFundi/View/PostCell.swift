//
//  PostCell.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/2/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var fundraiserLbl: UILabel!
    @IBOutlet weak var donationProgress: UIProgressView!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var donationGoalLbl: UILabel!
    @IBOutlet weak var currentDonationLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var donateButton: UIButton!
    
    var post: Post!
    var user: User!
    var likesRef : DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(postImgDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        postImg.addGestureRecognizer(doubleTap)
        postImg.isUserInteractionEnabled = true
    }
    
    @objc func postImgDoubleTap(sender: UITapGestureRecognizer) {
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    @objc func likeTapped(sender: UITapGestureRecognizer) {
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    func configureCell(post: Post, user: User,img: UIImage? = nil, profImg: UIImage? = nil) {
        self.post = post
        self.user = user
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        self.currentDonationLbl.text = "\(post.currentDonation)"
        self.donationGoalLbl.text = "\(post.donationGoal)"
        self.fundraiserLbl.text = post.title
        self.donationProgress.setProgress((post.currentDonation/post.donationGoal), animated: false)
        
        
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("KHALID: Unable to download image from firebase storage")
                } else {
                    print("KHALID: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as AnyObject)
                        }
                    }
                }
            })
        }
        
        if profImg != nil {
            self.profileImg.image = img
        } else {
            let ref = Storage.storage().reference(forURL: self.user.ImageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("KHALID: Unable to download image from firebase storage")
                } else {
                    print("KHALID: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                            FeedVC.profileImageCache.setObject(img, forKey: user.ImageUrl as AnyObject)
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "empty-heart")
            } else {
                self.likeImage.image = UIImage(named: "filled-heart")
            }
        }
        
        
        
    }
    
    
    
}
