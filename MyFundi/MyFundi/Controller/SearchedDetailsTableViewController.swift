//
//  SearchedDetailsTableViewController.swift
//  MyFundi
//
//  Created by Khalid Al Ibrahim on 10/18/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase

class SearchedDetailsTableViewController: UITableViewController, UISearchResultsUpdating {

    
    var loggedInUser: Auth?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var searchResultTableView: UITableView!
    
    var postArray = [NSDictionary?]()
    var filterResults = [NSDictionary?]()
    
    var databaseRef = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        databaseRef.child("fundraisers").queryOrdered(byChild: "title").observe(.childAdded, with: { (snapshot) in
            
            self.postArray.append(snapshot.value as? NSDictionary)
            
            //insert the rows
            
            self.searchResultTableView.insertRows(at: [IndexPath(row:self.postArray.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            return filterResults.count
        }
        return self.postArray.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let post: NSDictionary?
        if searchController.isActive && searchController.searchBar.text != ""{
            
            post = filterResults[indexPath.row]
        } else {
            post = self.postArray[indexPath.row]
        }
        
        cell.textLabel?.text = post?["title"] as? String
        cell.detailTextLabel?.text = post?["caption"] as? String
        
        
        
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

    @IBAction func dissmissResultsView(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContent(searchText: self.searchController.searchBar.text!)
        
    }
    
    func filterContent(searchText: String){
        self.filterResults = self.postArray.filter{ post in
            
            let postTitle = post!["title"] as? String
            
            return(postTitle?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
}
