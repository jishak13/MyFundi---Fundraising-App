//
//  ResultDetailsVC.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/29/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit

class ResultDetailsVC: UIViewController {

    var post: NSDictionary?
  
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
print("JOE: \(self.post!["caption"])")
        // Do any additional setup after loading the view.
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
