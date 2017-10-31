//
//  ViewController.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 9/30/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pswdField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            print("KHALID: ID found in \(KEY_UID.characters)")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookButtonTapped(_ sender: AnyObject) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("KHALID: Unable to authenticate with facebook! - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("KHALID: User canceled facebook authentication!")
            }
            else {
                print("KHALID: Successfully authenticated with facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
            
        }
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("KHALID: Unable to authenticate with Firebase")
            } else {
                print("KHALID: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.compeleteSignIn(id: user.uid, userData: userData)
                }
                
            }
        }}

    @IBAction func LoginTapped(_ sender: AnyObject) {
        if let email = emailField.text, let password = pswdField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("KHALID: Email user authenticated with Firebase!")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.compeleteSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("KHALID: Unable to authenticate with Firebase using Email")
                        } else {
                            print("KHALID: Successfully authenticated with Firebase using email")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.compeleteSignIn(id: user.uid, userData: userData)
                            }
                            
                        }
                    })
                }
            })
        }
    }
    
    func compeleteSignIn(id: String, userData: Dictionary<String, String>) {
        print("JOE USER ID: \(id)")
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult =  KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("KHALID: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "showTabController", sender: nil)
    }
    
}

