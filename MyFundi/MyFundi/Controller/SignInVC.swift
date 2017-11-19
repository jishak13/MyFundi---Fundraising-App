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

//Public class for the Sign IN View Controller
class SignInVC: UIViewController {
    //Outlet Declarations for the email and password
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pswdField: FancyField!
    
    //When the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Enables this view controller to hide the keyboard when tapped around
        hideKeyboardWhenTappedAround()
    }

    //When the View Appears
    override func viewDidAppear(_ animated: Bool) {
       //If the keychain wrapper has a value for KEY_UID
//        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
//            //Debug Message
//            print("KHALID: ID found in \(KEY_UID.characters)")
//           //Go to the Feed VC
//            performSegue(withIdentifier: "goToFeed", sender: nil)
//        }
    }

    //when the Facebook Button is tapped
    @IBAction func facebookButtonTapped(_ sender: AnyObject) {
    //Set the Facbeook Login
        let facebookLogin = FBSDKLoginManager()
        
        //use the Facebook API login
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            //IF there is an error
            if error != nil {
                print("KHALID: Unable to authenticate with facebook! - \(String(describing: error))")
            } else if result?.isCancelled == true //If the user cancels
            {
                print("KHALID: User canceled facebook authentication!")
            } //Else user successfully logged in
            else {
                print("KHALID: Successfully authenticated with facebook")
                //SEt the Credential
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                //Set the Firebase Authentication crednetial
                self.firebaseAuth(credential)
            }
            
        }
    }
    //Completes the sign in for the user
    func firebaseAuth(_ credential: AuthCredential) {
        //Call the authentication API with firebase
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                //Not Authenticated
                print("KHALID: Unable to authenticate with Firebase")
            } else {
                //Authenticated
                print("KHALID: Successfully authenticated with Firebase")
                //Set the user
                if let user = user {
                    let userData = ["provider": credential.provider]
                    //Complete the sign in
                    self.compeleteSignIn(id: user.uid, userData: userData)
                }
                
            }
        }}

    //When the Login Button Is Tapped
    @IBAction func LoginTapped(_ sender: AnyObject) {
      //Validate the email and password
        if let email = emailField.text, let password = pswdField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("KHALID: Email user authenticated with Firebase!")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        //Complete User Sign In
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
                                //complete User Sign In
                                self.compeleteSignIn(id: user.uid, userData: userData)
                            }
                            
                        }
                    })
                }
            })
        }
    }
    //Method to complete Signing In
    func compeleteSignIn(id: String, userData: Dictionary<String, String>) {
        print("JOE USER ID: \(id)")
       //Create a firebase user
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        //Ad the user to the keychaing
        let keychainResult =  KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("KHALID: Data saved to keychain \(keychainResult)")
      //Take the user to the Feed
        performSegue(withIdentifier: "showTabController", sender: nil)
    }
    
}

