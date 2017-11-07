//
//  SearchedDetailsTableViewController.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/18/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class SearchedDetailsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UISearchResultsUpdating {

    
    var loggedInUser: Auth?
    var selectedPost:  Post!

    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var searchResultTableView: UITableView!
    
    var postArray = [Post]()
    var filterResults = [Post]()
    var posts = [Post]()
    
    var databaseRef = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchResultTableView.tableHeaderView = searchController.searchBar
        
//        databaseRef.child("fundraisers").queryOrdered(byChild: "title").observe(.childAdded, with: { (snapshot) in
//            print("JOE: \(snapshot.value)")
        
        DataService.ds.REF_FUNDRAISERS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                var posts = [Post]()
                
                for snap in snapshot {
                    if let postDic = snap.value as? Dictionary<String, AnyObject> {
                        print("KHALID: \(snap.value)")
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDic)
                        self.postArray.append(post)
                    }
                }
                self.posts = posts
                self.searchResultTableView.reloadData()
            }
//            self.searchResultTableView.insertRows(at: [IndexPath(row:self.postArray.count, section: 0)], with: UITableViewRowAnimation.automatic)
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            return filterResults.count
        }
        return self.postArray.count
        
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let post: Post?
        if searchController.isActive && searchController.searchBar.text != ""{
            
            post = filterResults[indexPath.row]
            
        } else {
            post = self.postArray[indexPath.row]
        }
        
        cell.textLabel?.text = post?.title
        cell.detailTextLabel?.text = post?.caption
        
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
       
        if searchController.isActive && searchController.searchBar.text != ""{
            
            self.selectedPost = filterResults[indexPath.row]
            
        } else {
            print("JOE: \(self.postArray[indexPath.row])")
            self.selectedPost = self.postArray[indexPath.row]
        }
         performSegue(withIdentifier: "searchToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToDetails" {
            if let ResultDetails = segue.destination as? ResultDetailsVC {
                ResultDetails.post = self.selectedPost
            }
        }
    }

    @IBAction func dissmissResultsView(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContent(searchText: self.searchController.searchBar.text!)
        
    }

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func filterContent(searchText: String){
        self.filterResults = self.postArray.filter{ post in
            
//            let postTitle = post.title
            
            return(post.title.lowercased().contains(searchText.lowercased()))
        }
        searchResultTableView.reloadData()
    }
    
}
