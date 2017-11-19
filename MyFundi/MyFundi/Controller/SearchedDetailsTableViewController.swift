//
//  SearchedDetailsTableViewController.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/18/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
//PUblic class for the Search Details Controller
class SearchedDetailsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UISearchResultsUpdating {

    
    //Initialize the search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    //Declare the IBoutlett for the table view of search results
    @IBOutlet var searchResultTableView: UITableView!
    
    //Declare the local Variables for this View Controller
    var postArray = [Post]()
    var filterResults = [Post]()
    var posts = [Post]()
    var loggedInUser: Auth?
    var selectedPost:  Post!
    var databaseRef = Database.database().reference()
    
    
    //When the view controller loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Enables this view controller to hide the keyboard when tapped around
        hideKeyboardWhenTappedAround()
        
        //Initialize the search controller properties
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        //Initialize the search results properties
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
        searchResultTableView.tableHeaderView = searchController.searchBar
        //Set the Presentation Context to True
        definesPresentationContext = true
        
        //Access all the fundraisers in firebase
        DataService.ds.REF_FUNDRAISERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                //New Post object to ensure no repeats
                var posts = [Post]()
                for snap in snapshot {
                    if let postDic = snap.value as? Dictionary<String, AnyObject> {
                        print("KHALID: \(snap.value)")
                        let key = snap.key
                        //Initialize the post with the dictionary and key
                        let post = Post(postKey: key, postData: postDic)
                        //append to the array
                        self.postArray.append(post)
                    }
                }
                //Set the posts
                self.posts = posts
                //Reload the Table View
                self.searchResultTableView.reloadData()
            }
        })

    }

    //Set the number of sections to 1 in the table view
     func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    //If the search controller is active user the filter results length, other wise user the post array count
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            return filterResults.count
        }
        return self.postArray.count
        
    }

    //Initialize each post
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Initialize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //Declare a new post
        let post: Post?
        //If the search controller is active
        if searchController.isActive && searchController.searchBar.text != ""{
            //use the filter results post
            post = filterResults[indexPath.row]
            
        } else {
            //use the post array post
            post = self.postArray[indexPath.row]
        }
        //For future use set up a new View for this
        //Set the cell text table and details
        cell.textLabel?.text = post?.title
        cell.detailTextLabel?.text = post?.caption
        
        
        //Return the Cell
        return cell
    }
    
    //When the user Selects a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
       //Decide on which array to use
        if searchController.isActive && searchController.searchBar.text != ""{
            //Set the selected post to filter results post at this indexPath
            self.selectedPost = filterResults[indexPath.row]
            
        } else {
            //Debug Message
            print("JOE: \(self.postArray[indexPath.row])")
            //Set the selected post  to the post at this index path
            self.selectedPost = self.postArray[indexPath.row]
        }
        //Perform the segue that takes this post to the search details
         performSegue(withIdentifier: "searchToDetails", sender: self)
    }
    //Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       //if the segue is search to details
        if segue.identifier == "searchToDetails" {
         //Set the ResultsDetailsVC
            if let ResultDetails = segue.destination as? ResultDetailsVC {
               //Set the reuslts details post to this selected post
                ResultDetails.post = self.selectedPost
            }
        }
    }

    //Method to go dismiss the reuslts
    @IBAction func dissmissResultsView(_ sender: AnyObject) {
       //Dismiss this view controller
        dismiss(animated: true, completion: nil)
    }
    
    //Function to update the search results
    func updateSearchResults(for searchController: UISearchController) {
        //Filter the content based on the search text
        filterContent(searchText: self.searchController.searchBar.text!)
        
    }

    //When the back button is pressed
    @IBAction func backBtn(_ sender: Any) {
        //Dismiss this VC
        self.dismiss(animated: true, completion: nil)
    }
    
    //Method to Filter the content in the Table View
    func filterContent(searchText: String){
        //Set the filter results to post array
        self.filterResults = self.postArray.filter{ post in
            return(post.title.lowercased().contains(searchText.lowercased()))
        }
        //Reload the table view
        searchResultTableView.reloadData()
    }
    
}
